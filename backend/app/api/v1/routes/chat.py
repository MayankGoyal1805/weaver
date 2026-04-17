import re

from fastapi import APIRouter, HTTPException

from app.schemas.chat import AgentPromptIn, AgentPromptOut, AgentToolCallOut, ChatIn, ChatOut
from app.services.llm import LLMConfigError, llm_service
from app.services.tools import tool_execution_service

router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("", response_model=ChatOut)
async def chat(payload: ChatIn) -> ChatOut:
    try:
        out = await llm_service.chat(
            prompt=payload.prompt,
            system_prompt=payload.system_prompt,
            model_name=payload.model_name,
        )
    except LLMConfigError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"LLM request failed: {exc}") from exc

    return ChatOut(**out)


@router.post("/agent", response_model=AgentPromptOut)
async def agent_prompt(payload: AgentPromptIn) -> AgentPromptOut:
    enabled = set(payload.enabled_tool_ids)
    prompt_lower = payload.prompt.lower()

    has_send_intent = any(x in prompt_lower for x in ["send", "post", "share", "forward", "publish", "notify"])
    mentions_discord_target = any(
        x in prompt_lower for x in ["discord", "channel", "server", "bot", "there", "that channel"]
    )

    wants_latest_gmail = any(
        x in prompt_lower
        for x in [
            "latest gmail",
            "latest email",
            "last gmail",
            "last email",
            "newest email",
            "check gmail",
            "read gmail",
            "inbox",
        ]
    )
    wants_drive_files = any(
        x in prompt_lower
        for x in [
            "drive files",
            "google drive",
            "list drive",
            "drive folder",
            "show drive",
            "browse drive",
        ]
    )
    wants_discord = "discord" in enabled and (
        any(x in prompt_lower for x in ["discord", "channel", "send to discord", "post to discord"])
        or (has_send_intent and mentions_discord_target)
        or (
            has_send_intent
            and payload.discord_channel_id
            and any(x in prompt_lower for x in ["email", "gmail", "summary", "summarize", "latest"])
        )
    )

    tool_calls: list[AgentToolCallOut] = []
    latest_email: dict | None = None
    drive_files: dict | None = None
    gmail_error: str | None = None

    if wants_latest_gmail and "gmail" in enabled:
        out = await tool_execution_service.execute("google.gmail.get_latest_email", {})
        tool_calls.append(AgentToolCallOut(tool_id="google.gmail.get_latest_email", result=out))
        if out.get("status") == "ok":
            latest_email = out.get("result")
        else:
            gmail_error = (
                (out.get("result") or {}).get("payload", {}).get("error")
                or str((out.get("result") or {}).get("payload") or "")
                or "Unknown Gmail tool error"
            )

    if wants_drive_files and "google-drive" in enabled:
        out = await tool_execution_service.execute("google.drive.list_files", {"page_size": 10})
        tool_calls.append(AgentToolCallOut(tool_id="google.drive.list_files", result=out))
        if out.get("status") == "ok":
            drive_files = out.get("result")

    llm_system_prompt = payload.system_prompt
    llm_prompt = payload.prompt
    context_chunks: list[str] = []

    if latest_email is not None:
        context_chunks.append(_compact_email_context(latest_email))
    if drive_files is not None:
        context_chunks.append(_compact_drive_context(drive_files))

    if context_chunks:
        llm_prompt = payload.prompt + "\n\nTool results:\n" + "\n\n".join(context_chunks)

    if wants_discord and payload.discord_channel_id and latest_email is not None:
        llm_system_prompt = (
            "Write a concise Discord notification under 900 characters. "
            "Do not include code blocks, setup instructions, or policy text. "
            "Use plain text with sender, subject, and short summary only."
        )
        llm_prompt = (
            "Create a concise Discord message for this Gmail item. "
            "Return message text only.\n\n"
            f"{_compact_email_context(latest_email)}"
        )

    chat_out: ChatOut | None = None
    chat_error: str | None = None

    if wants_latest_gmail and latest_email is None and gmail_error is not None:
        if "401" in gmail_error or "unauthorized" in gmail_error.lower():
            chat_error = (
                "Gmail access failed (401 Unauthorized). Please reconnect Google in Settings and try again."
            )
        else:
            chat_error = f"Gmail fetch failed: {gmail_error}"

        chat_out = ChatOut(
            model_name=payload.model_name or "agent",
            content=chat_error,
            raw_response={"reason": "gmail_fetch_failed"},
        )
        return AgentPromptOut(
            chat=chat_out,
            chat_error=chat_error,
            tool_calls=tool_calls,
            discord_send=None,
        )

    if has_send_intent and "discord" in enabled and not payload.discord_channel_id:
        chat_error = "Discord send was requested, but no default Discord channel id is configured in Settings."
        chat_out = ChatOut(
            model_name=payload.model_name or "agent",
            content=(
                "Discord send is enabled, but no default channel ID is configured. "
                "Open Settings -> Agent Defaults -> Default Discord Channel ID, save it, then try again."
            ),
            raw_response={"reason": "missing_discord_channel_id"},
        )
        return AgentPromptOut(
            chat=chat_out,
            chat_error=chat_error,
            tool_calls=tool_calls,
            discord_send=None,
        )

    try:
        out = await llm_service.chat(
            prompt=llm_prompt,
            system_prompt=llm_system_prompt,
            model_name=payload.model_name,
            llm_api_key=payload.llm_api_key,
            llm_base_url=payload.llm_base_url,
            history=payload.history,
        )
        chat_out = ChatOut(**out)
    except LLMConfigError as exc:
        chat_error = str(exc)
    except Exception as exc:
        chat_error = f"LLM request failed: {exc}"

    discord_send: dict | None = None
    can_send_discord = wants_discord and payload.discord_channel_id and "discord" in enabled
    if wants_latest_gmail and latest_email is None:
        can_send_discord = False

    if can_send_discord:
        content = (chat_out.content if chat_out else "").strip()
        if not content and latest_email:
            content = _format_email_fallback(latest_email)
        if content:
            content = _discord_safe_content(content)
            send_out = await tool_execution_service.execute(
                "discord.send_message",
                {"channel_id": payload.discord_channel_id, "content": content},
            )
            tool_calls.append(AgentToolCallOut(tool_id="discord.send_message", result=send_out))
            discord_send = send_out

    return AgentPromptOut(
        chat=chat_out,
        chat_error=chat_error,
        tool_calls=tool_calls,
        discord_send=discord_send,
    )


def _discord_safe_content(text: str, max_chars: int = 1900) -> str:
    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL | re.IGNORECASE).strip()
    if len(cleaned) <= max_chars:
        return cleaned
    return cleaned[: max_chars - 3].rstrip() + "..."


def _format_email_fallback(email: dict) -> str:
    body = (email.get("body_text") or email.get("snippet") or "").strip()
    if len(body) > 800:
        body = body[:800] + "..."
    return (
        "Latest Gmail received:\n"
        f"From: {email.get('from', '')}\n"
        f"Subject: {email.get('subject', '(no subject)')}\n"
        f"Date: {email.get('date', '')}\n"
        f"Summary: {email.get('snippet', '')}\n"
        f"Body: {body}"
    )


def _compact_email_context(email: dict) -> str:
    body = (email.get("body_text") or email.get("snippet") or "").strip()
    if len(body) > 1200:
        body = body[:1200].rstrip() + "..."
    snippet = (email.get("snippet") or "").strip()
    if len(snippet) > 400:
        snippet = snippet[:400].rstrip() + "..."

    return (
        "Latest Gmail:\n"
        f"From: {email.get('from', '')}\n"
        f"Subject: {email.get('subject', '(no subject)')}\n"
        f"Date: {email.get('date', '')}\n"
        f"Snippet: {snippet}\n"
        f"Body: {body}"
    )


def _compact_drive_context(drive_files: dict) -> str:
    files = (drive_files.get("files") or [])[:10]
    lines: list[str] = ["Drive Files:"]
    for item in files:
        name = (item.get("name") or "").strip()
        if len(name) > 140:
            name = name[:140].rstrip() + "..."
        mime = (item.get("mimeType") or "").strip()
        modified = (item.get("modifiedTime") or "").strip()
        lines.append(f"- {name} ({mime}) modified={modified}")
    return "\n".join(lines)
