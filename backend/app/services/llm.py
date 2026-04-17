from urllib.parse import urljoin

import httpx

from app.core.config import get_settings


class LLMConfigError(Exception):
    pass


class LLMService:
    async def chat(self, prompt: str, system_prompt: str | None = None, model_name: str | None = None) -> dict:
        settings = get_settings()
        api_key = settings.llm_api_key.strip()
        if not api_key:
            raise LLMConfigError("LLM_API_KEY is missing")

        base_url = settings.llm_base_url.strip()
        if not base_url:
            raise LLMConfigError("LLM_BASE_URL is missing")

        chosen_model = model_name or settings.llm_model_name
        endpoint = urljoin(base_url.rstrip("/") + "/", "chat/completions")
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        }

        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})

        payload = {
            "model": chosen_model,
            "messages": messages,
            "temperature": 0.2,
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(endpoint, headers=headers, json=payload)
            response.raise_for_status()
            data = response.json()

        choices = data.get("choices", [])
        message = choices[0].get("message", {}) if choices else {}
        content = message.get("content", "")

        return {
            "model_name": chosen_model,
            "content": content,
            "raw_response": data,
        }


llm_service = LLMService()
