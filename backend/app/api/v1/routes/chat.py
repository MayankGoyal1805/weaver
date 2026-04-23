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

    def _is_tool_enabled(tool_id: str) -> bool:
        if "gmail" in enabled and tool_id.startswith("google.gmail."):
            return True
        if "google-drive" in enabled and tool_id.startswith("google.drive."):
            return True
        if "discord" in enabled and tool_id.startswith("discord."):
            return True
        if "filesystem" in enabled and tool_id.startswith("filesystem."):
            return True
        return False

    openai_tools = []
    for t in tool_execution_service.catalog:
        if _is_tool_enabled(t.tool_id):
            # Special case: inject discord_channel_id if needed, but the model can just not provide it if we inject it later.
            # Actually, the model needs to provide it, or we can intercept discord.send_message.
            openai_tools.append({
                "type": "function",
                "function": {
                    "name": t.tool_id.replace(".", "_"), # OpenAI doesn't allow periods in function names
                    "description": t.description or t.display_name,
                    "parameters": t.input_schema,
                }
            })

    # Create mapping back from OpenAI name to actual tool_id
    tool_name_map = {t.tool_id.replace(".", "_"): t.tool_id for t in tool_execution_service.catalog}

    system_prompt = payload.system_prompt or "You are Weaver, a helpful AI assistant."
    if "discord" in enabled and payload.discord_channel_id:
        system_prompt += f"\nIf asked to send to Discord without specifying a channel, use the default channel ID: {payload.discord_channel_id}."

    history = list(payload.history)
    current_prompt = payload.prompt

    all_tool_calls_out: list[AgentToolCallOut] = []
    chat_out: ChatOut | None = None
    chat_error: str | None = None
    accumulated_content: list[str] = []
    
    from app.schemas.chat import AgentBlockOut
    agent_blocks: list[AgentBlockOut] = []

    import json

    for iteration in range(5): # Max 5 iterations
        try:
            out = await llm_service.chat(
                prompt=current_prompt if iteration == 0 else "",
                system_prompt=system_prompt,
                model_name=payload.model_name,
                llm_api_key=payload.llm_api_key,
                llm_base_url=payload.llm_base_url,
                history=history,
                tools=openai_tools if openai_tools else None,
            )
        except LLMConfigError as exc:
            chat_error = str(exc)
            break
        except Exception as exc:
            chat_error = f"LLM request failed: {exc}"
            break

        chat_out = ChatOut(**out)
        if chat_out.content:
            accumulated_content.append(chat_out.content)
            agent_blocks.append(AgentBlockOut(block_type="text", text=chat_out.content))
        
        # Add the assistant's message to history
        assistant_msg = {"role": "assistant", "content": chat_out.content or ""}
        if chat_out.tool_calls:
            assistant_msg["tool_calls"] = chat_out.tool_calls
        history.append(assistant_msg)

        if not chat_out.tool_calls:
            break # No more tools to call, we are done!

        # Execute tool calls
        for tc in chat_out.tool_calls:
            function_call = tc.get("function", {})
            func_name_openai = function_call.get("name")
            arguments_str = function_call.get("arguments", "{}")
            
            try:
                arguments = json.loads(arguments_str)
            except json.JSONDecodeError:
                arguments = {}

            real_tool_id = tool_name_map.get(func_name_openai)
            if not real_tool_id:
                result = {"status": "error", "error": f"Unknown tool {func_name_openai}"}
            else:
                result = await tool_execution_service.execute(real_tool_id, arguments)
            
            tc_out = AgentToolCallOut(
                tool_id=real_tool_id or func_name_openai, 
                arguments=arguments,
                result=result
            )
            all_tool_calls_out.append(tc_out)
            agent_blocks.append(AgentBlockOut(block_type="tool_call", tool_call=tc_out))
            
            # Append tool result to history
            history.append({
                "role": "tool",
                "tool_call_id": tc.get("id"),
                "name": func_name_openai,
                "content": json.dumps(result)
            })

    if chat_out and accumulated_content:
        chat_out.content = "\n\n".join(accumulated_content)

    return AgentPromptOut(
        chat=chat_out,
        chat_error=chat_error,
        tool_calls=all_tool_calls_out,
        discord_send=None,
        blocks=agent_blocks,
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
