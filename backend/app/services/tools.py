import uuid
from datetime import datetime, timezone
from typing import Any

from app.core.config import get_settings
from app.mcp.adapters.native_adapter import native_tool_adapter
from app.mcp.registry.contracts import ToolContract
from app.services.providers.discord.service import discord_service
from app.services.providers.filesystem.service import FileSandboxError, filesystem_service
from app.services.providers.google.service import google_service
from app.services.providers.token_store import oauth_token_store
from app.services.tracing.event_bus import trace_event_bus


def _tool_catalog() -> list[ToolContract]:
    return [
        ToolContract(
            tool_id="filesystem.list_directory",
            display_name="List Directory",
            provider="filesystem",
            auth_type="none",
            capabilities=["read"],
            required_scopes=[],
            input_schema={"type": "object", "properties": {"path": {"type": "string"}}},
            output_schema={"type": "object"},
            is_side_effecting=False,
            description="List files and folders under a sandboxed path.",
        ),
        ToolContract(
            tool_id="filesystem.read_file",
            display_name="Read File",
            provider="filesystem",
            auth_type="none",
            capabilities=["read"],
            required_scopes=[],
            input_schema={"type": "object", "properties": {"path": {"type": "string"}}},
            output_schema={"type": "object"},
            is_side_effecting=False,
            description="Read text content from a sandboxed file.",
        ),
        ToolContract(
            tool_id="filesystem.write_file",
            display_name="Write File",
            provider="filesystem",
            auth_type="none",
            capabilities=["write"],
            required_scopes=[],
            input_schema={
                "type": "object",
                "properties": {"path": {"type": "string"}, "content": {"type": "string"}},
                "required": ["path", "content"],
            },
            output_schema={"type": "object"},
            is_side_effecting=True,
            description="Write text content to a sandboxed file.",
        ),
        ToolContract(
            tool_id="filesystem.copy_path",
            display_name="Copy Path",
            provider="filesystem",
            auth_type="none",
            capabilities=["write"],
            required_scopes=[],
            input_schema={
                "type": "object",
                "properties": {"source": {"type": "string"}, "destination": {"type": "string"}},
                "required": ["source", "destination"],
            },
            output_schema={"type": "object"},
            is_side_effecting=True,
            description="Copy file or directory within sandbox.",
        ),
        ToolContract(
            tool_id="filesystem.move_path",
            display_name="Move Path",
            provider="filesystem",
            auth_type="none",
            capabilities=["write"],
            required_scopes=[],
            input_schema={
                "type": "object",
                "properties": {"source": {"type": "string"}, "destination": {"type": "string"}},
                "required": ["source", "destination"],
            },
            output_schema={"type": "object"},
            is_side_effecting=True,
            description="Move file or directory within sandbox.",
        ),
        ToolContract(
            tool_id="filesystem.delete_path",
            display_name="Delete Path",
            provider="filesystem",
            auth_type="none",
            capabilities=["write"],
            required_scopes=[],
            input_schema={
                "type": "object",
                "properties": {"path": {"type": "string"}, "recursive": {"type": "boolean"}},
                "required": ["path"],
            },
            output_schema={"type": "object"},
            is_side_effecting=True,
            description="Delete file or directory in sandbox.",
        ),
        ToolContract(
            tool_id="google.gmail.list_threads",
            display_name="List Gmail Threads",
            provider="google",
            auth_type="oauth2",
            capabilities=["read"],
            required_scopes=["https://www.googleapis.com/auth/gmail.readonly"],
            input_schema={"type": "object", "properties": {"max_results": {"type": "integer"}}},
            output_schema={"type": "object"},
            is_side_effecting=False,
            description="List threads from Gmail inbox.",
        ),
        ToolContract(
            tool_id="google.gmail.get_latest_email",
            display_name="Get Latest Gmail Email",
            provider="google",
            auth_type="oauth2",
            capabilities=["read"],
            required_scopes=["https://www.googleapis.com/auth/gmail.readonly"],
            input_schema={"type": "object", "properties": {}},
            output_schema={"type": "object"},
            is_side_effecting=False,
            description="Fetch the latest email from Gmail inbox.",
        ),
        ToolContract(
            tool_id="google.drive.list_files",
            display_name="List Drive Files",
            provider="google",
            auth_type="oauth2",
            capabilities=["read"],
            required_scopes=["https://www.googleapis.com/auth/drive.metadata.readonly"],
            input_schema={"type": "object", "properties": {"page_size": {"type": "integer"}}},
            output_schema={"type": "object"},
            is_side_effecting=False,
            description="List files from Google Drive.",
        ),
        ToolContract(
            tool_id="discord.send_message",
            display_name="Send Discord Message",
            provider="discord",
            auth_type="oauth2",
            capabilities=["write"],
            required_scopes=["identify"],
            input_schema={
                "type": "object",
                "properties": {"channel_id": {"type": "string"}, "content": {"type": "string"}},
                "required": ["channel_id", "content"],
            },
            output_schema={"type": "object"},
            is_side_effecting=True,
            description="Send a message to a Discord channel.",
        ),
    ]


async def _filesystem_list_directory(arguments: dict[str, Any]) -> dict[str, Any]:
    return filesystem_service.list_directory(path=arguments.get("path", "."))


async def _filesystem_read_file(arguments: dict[str, Any]) -> dict[str, Any]:
    return filesystem_service.read_file(path=arguments["path"])


async def _filesystem_write_file(arguments: dict[str, Any]) -> dict[str, Any]:
    return filesystem_service.write_file(path=arguments["path"], content=arguments["content"])


async def _filesystem_copy_path(arguments: dict[str, Any]) -> dict[str, Any]:
    return filesystem_service.copy_path(source=arguments["source"], destination=arguments["destination"])


async def _filesystem_move_path(arguments: dict[str, Any]) -> dict[str, Any]:
    return filesystem_service.move_path(source=arguments["source"], destination=arguments["destination"])


async def _filesystem_delete_path(arguments: dict[str, Any]) -> dict[str, Any]:
    return filesystem_service.delete_path(
        path=arguments["path"],
        recursive=bool(arguments.get("recursive", False)),
    )


async def _google_gmail_list_threads(arguments: dict[str, Any]) -> dict[str, Any]:
    access_token = await _resolve_google_access_token(arguments)
    return await google_service.list_gmail_threads(
        access_token,
        max_results=int(arguments.get("max_results", 20)),
    )


async def _google_gmail_get_latest_email(arguments: dict[str, Any]) -> dict[str, Any]:
    access_token = await _resolve_google_access_token(arguments)
    return await google_service.get_latest_gmail_email(access_token)


async def _google_drive_list_files(arguments: dict[str, Any]) -> dict[str, Any]:
    access_token = await _resolve_google_access_token(arguments)
    return await google_service.list_drive_files(
        access_token,
        page_size=int(arguments.get("page_size", 20)),
    )


async def _discord_send_message(arguments: dict[str, Any]) -> dict[str, Any]:
    settings = get_settings()
    return await discord_service.send_message(
        channel_id=arguments["channel_id"],
        content=arguments["content"],
        bot_token=arguments.get("bot_token") or settings.discord_bot_token,
    )


from datetime import UTC, datetime

async def _resolve_google_access_token(arguments: dict[str, Any]) -> str:
    provided = arguments.get("access_token", "")
    if provided:
        return provided

    stored = oauth_token_store.get_tokens("google")
    if not stored:
        raise RuntimeError("Google auth missing. Run CLI auth-google first.")

    access_token = stored.get("access_token", "")
    refresh_token = stored.get("refresh_token", "")
    expires_at_str = stored.get("expires_at")

    is_expired = False
    if expires_at_str:
        try:
            # Handle ISO format with Z or +00:00
            if expires_at_str.endswith("Z"):
                expires_at_str = expires_at_str[:-1] + "+00:00"
            expires_at = datetime.fromisoformat(expires_at_str)
            if datetime.now(UTC) >= expires_at:
                is_expired = True
        except ValueError:
            is_expired = True

    if access_token and not is_expired:
        return access_token

    if not refresh_token:
        if access_token:
            return access_token # fallback if we can't refresh
        raise RuntimeError("Google auth has no usable token. Re-run auth-google.")

    refreshed = await google_service.refresh_access_token(refresh_token)
    oauth_token_store.set_tokens("google", refreshed)
    return refreshed.get("access_token", "")


def register_native_handlers() -> None:
    native_tool_adapter.register("filesystem.list_directory", _filesystem_list_directory)
    native_tool_adapter.register("filesystem.read_file", _filesystem_read_file)
    native_tool_adapter.register("filesystem.write_file", _filesystem_write_file)
    native_tool_adapter.register("filesystem.copy_path", _filesystem_copy_path)
    native_tool_adapter.register("filesystem.move_path", _filesystem_move_path)
    native_tool_adapter.register("filesystem.delete_path", _filesystem_delete_path)
    native_tool_adapter.register("google.gmail.list_threads", _google_gmail_list_threads)
    native_tool_adapter.register("google.gmail.get_latest_email", _google_gmail_get_latest_email)
    native_tool_adapter.register("google.drive.list_files", _google_drive_list_files)
    native_tool_adapter.register("discord.send_message", _discord_send_message)


class ToolExecutionService:
    def __init__(self) -> None:
        self.catalog = _tool_catalog()

    async def execute(self, tool_id: str, arguments: dict[str, Any], run_id: str | None = None) -> dict[str, Any]:
        trace_id = str(uuid.uuid4())
        effective_run_id = run_id or str(uuid.uuid4())
        start_event = {
            "run_id": effective_run_id,
            "trace_id": trace_id,
            "tool_id": tool_id,
            "event_type": "tool_call_started",
            "status": "ok",
            "created_at": datetime.now(timezone.utc).isoformat(),
            "payload": {"arguments": _redact(arguments)},
        }
        await trace_event_bus.publish(effective_run_id, start_event)

        try:
            result = await native_tool_adapter.invoke(tool_id, arguments)
        except FileSandboxError as exc:
            failure_event = {
                "run_id": effective_run_id,
                "trace_id": trace_id,
                "tool_id": tool_id,
                "event_type": "tool_call_failed",
                "status": "error",
                "created_at": datetime.now(timezone.utc).isoformat(),
                "payload": {"error": str(exc)},
            }
            await trace_event_bus.publish(effective_run_id, failure_event)
            return {"status": "error", "tool_id": tool_id, "trace_id": trace_id, "result": failure_event}
        except Exception as exc:
            failure_event = {
                "run_id": effective_run_id,
                "trace_id": trace_id,
                "tool_id": tool_id,
                "event_type": "tool_call_failed",
                "status": "error",
                "created_at": datetime.now(timezone.utc).isoformat(),
                "payload": {"error": str(exc)},
            }
            await trace_event_bus.publish(effective_run_id, failure_event)
            return {"status": "error", "tool_id": tool_id, "trace_id": trace_id, "result": failure_event}

        success_event = {
            "run_id": effective_run_id,
            "trace_id": trace_id,
            "tool_id": tool_id,
            "event_type": "tool_call_succeeded",
            "status": "ok",
            "created_at": datetime.now(timezone.utc).isoformat(),
            "payload": {"result_summary": _summarize(result)},
        }
        await trace_event_bus.publish(effective_run_id, success_event)
        return {"status": "ok", "tool_id": tool_id, "trace_id": trace_id, "result": result}


def _redact(arguments: dict[str, Any]) -> dict[str, Any]:
    redacted = {}
    for key, value in arguments.items():
        if "token" in key or "secret" in key or "password" in key:
            redacted[key] = "***"
        else:
            redacted[key] = value
    return redacted


def _summarize(result: dict[str, Any]) -> dict[str, Any]:
    if "entries" in result and isinstance(result["entries"], list):
        return {"entries_count": len(result["entries"])}
    return {k: v for k, v in result.items() if k in {"path", "bytes_written", "deleted", "copied"}}


tool_execution_service = ToolExecutionService()
