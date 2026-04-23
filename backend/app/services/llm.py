from urllib.parse import urljoin
import re

import httpx

from app.core.config import get_settings


class LLMConfigError(Exception):
    pass


class LLMService:
    async def chat(
        self,
        prompt: str,
        system_prompt: str | None = None,
        model_name: str | None = None,
        llm_api_key: str | None = None,
        llm_base_url: str | None = None,
        history: list[dict] | None = None,
        tools: list[dict] | None = None,
    ) -> dict:
        settings = get_settings()
        api_key = (llm_api_key or settings.llm_api_key).strip()
        if not api_key:
            raise LLMConfigError("LLM_API_KEY is missing")

        base_url = (llm_base_url or settings.llm_base_url).strip()
        if not base_url:
            raise LLMConfigError("LLM_BASE_URL is missing")

        chosen_model = model_name or settings.llm_model_name
        endpoint = urljoin(base_url.rstrip("/") + "/", "chat/completions")
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        }

        messages = _build_bounded_messages(
            prompt=prompt,
            system_prompt=system_prompt,
            history=history or [],
        )

        payload = {
            "model": chosen_model,
            "messages": messages,
            "temperature": 0.2,
        }
        if tools:
            payload["tools"] = tools
            payload["tool_choice"] = "auto"

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(endpoint, headers=headers, json=payload)
            response.raise_for_status()
            data = response.json()

        choices = data.get("choices", [])
        message = choices[0].get("message", {}) if choices else {}
        content = message.get("content", "") or ""
        reasoning = message.get("reasoning_content") or message.get("reasoning") or ""
        tool_calls = message.get("tool_calls", [])
        
        if reasoning:
            content = f"<think>\n{reasoning}\n</think>\n\n{content}".strip()

        return {
            "model_name": chosen_model,
            "content": content,
            "raw_response": data,
            "tool_calls": tool_calls,
        }

llm_service = LLMService()


_MAX_HISTORY_MESSAGES = 12
_MAX_SINGLE_MESSAGE_CHARS = 1800
_MAX_PROMPT_CHARS = 3500
_MAX_SYSTEM_CHARS = 1200
_MAX_TOTAL_CHARS = 12000


def _build_bounded_messages(prompt: str, system_prompt: str | None, history: list[dict]) -> list[dict]:
    bounded: list[dict] = []

    if system_prompt:
        bounded.append({"role": "system", "content": _trim_text(system_prompt, _MAX_SYSTEM_CHARS)})

    cleaned_history: list[dict] = []
    for item in history[-_MAX_HISTORY_MESSAGES:]:
        role = item.get("role", "user")
        content = item.get("content", "")
        if role not in {"user", "assistant", "system", "tool"}:
            continue
        
        if not content and not item.get("tool_calls"):
            continue
            
        text = _strip_think(content) if content else ""
        text = _trim_text(text, _MAX_SINGLE_MESSAGE_CHARS)
        
        msg = {"role": role, "content": text}
        if item.get("tool_calls"):
            msg["tool_calls"] = item.get("tool_calls")
        if item.get("tool_call_id"):
            msg["tool_call_id"] = item.get("tool_call_id")
        if item.get("name"):
            msg["name"] = item.get("name")
            
        cleaned_history.append(msg)

    prompt_text = _trim_text(_strip_think(prompt), _MAX_PROMPT_CHARS)
    bounded.extend(cleaned_history)
    bounded.append({"role": "user", "content": prompt_text})

    # Enforce hard total budget by trimming oldest history first.
    while _total_chars(bounded) > _MAX_TOTAL_CHARS:
        # Preserve system (index 0 if present) and last user prompt.
        if len(bounded) <= 2:
            break
        remove_index = 1 if bounded[0].get("role") == "system" else 0
        if remove_index >= len(bounded) - 1:
            break
        bounded.pop(remove_index)

    # Final safety: if still oversized, trim final user prompt.
    if _total_chars(bounded) > _MAX_TOTAL_CHARS and bounded:
        overflow = _total_chars(bounded) - _MAX_TOTAL_CHARS
        last = bounded[-1]
        shortened = _trim_text(last.get("content", ""), max(200, len(last.get("content", "")) - overflow - 32))
        bounded[-1] = {"role": last.get("role", "user"), "content": shortened}

    return bounded


def _strip_think(text: str) -> str:
    return re.sub(r"<think>[\s\S]*?</think>", "", text, flags=re.IGNORECASE).strip()


def _trim_text(text: str, max_chars: int) -> str:
    value = (text or "").strip()
    if len(value) <= max_chars:
        return value
    return value[: max_chars - 3].rstrip() + "..."


def _total_chars(messages: list[dict]) -> int:
    return sum(len((msg.get("content") or "")) for msg in messages)
