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

    wants_latest_gmail = any(x in prompt_lower for x in ["latest gmail", "latest email", "last gmail", "last email"])
    wants_drive_files = any(x in prompt_lower for x in ["drive files", "google drive", "list drive"])
    wants_discord = "discord" in prompt_lower or "channel" in prompt_lower

    tool_calls: list[AgentToolCallOut] = []
    latest_email: dict | None = None
    drive_files: dict | None = None

    if wants_latest_gmail and "gmail" in enabled:
        out = await tool_execution_service.execute("google.gmail.get_latest_email", {})
        tool_calls.append(AgentToolCallOut(tool_id="google.gmail.get_latest_email", result=out))
        if out.get("status") == "ok":
            latest_email = out.get("result")

    if wants_drive_files and "google-drive" in enabled:
        out = await tool_execution_service.execute("google.drive.list_files", {"page_size": 10})
        tool_calls.append(AgentToolCallOut(tool_id="google.drive.list_files", result=out))
        if out.get("status") == "ok":
            drive_files = out.get("result")

    llm_system_prompt = payload.system_prompt
    llm_prompt = payload.prompt
    context_chunks: list[str] = []

    if latest_email is not None:
        context_chunks.append(f"Latest Gmail:\n{latest_email}")
    if drive_files is not None:
        context_chunks.append(f"Drive Files:\n{drive_files}")

    if context_chunks:
        llm_prompt = payload.prompt + "\n\nTool results:\n" + "\n\n".join(context_chunks)

    if wants_discord and payload.discord_channel_id and latest_email is not None:
        llm_system_prompt = (
            "Write a concise Discord notification under 900 characters. "
            "Do not include code blocks, setup instructions, or policy text. "
            "Use plain text with sender, subject, and short summary only."
        )
        llm_prompt = f"Create a concise Discord message for this Gmail item. Return message text only.\n\n{latest_email}"

    chat_out: ChatOut | None = None
    chat_error: str | None = None
    try:
        out = await llm_service.chat(
            prompt=llm_prompt,
            system_prompt=llm_system_prompt,
            model_name=payload.model_name,
        )
        chat_out = ChatOut(**out)
    except LLMConfigError as exc:
        chat_error = str(exc)
    except Exception as exc:
        chat_error = f"LLM request failed: {exc}"

    discord_send: dict | None = None
    if wants_discord and payload.discord_channel_id and "discord" in enabled:
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
