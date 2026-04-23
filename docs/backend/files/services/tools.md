# Source Code Guide: `app/services/tools.py`

This file is the **Registry and Execution Engine** for all tools available to the Weaver agent. It defines which tools exist, what their inputs look like, and how to execute them.

If you are coming from a Python background, think of this as a "Dispatch Table" where tool names are mapped to specific functions.

---

## 1. Complete Code

```python
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
    """
    Defines the metadata for every tool. This is what the LLM 'sees'.
    """
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
        # ... (other tools defined here)
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

# ... (Handler functions like _filesystem_list_directory)

def register_native_handlers() -> None:
    """
    Binds the tool IDs to their actual Python functions.
    """
    native_tool_adapter.register("filesystem.list_directory", _filesystem_list_directory)
    # ... (other registrations)

class ToolExecutionService:
    """
    The orchestrator that handles tool execution, tracing, and error handling.
    """
    def __init__(self) -> None:
        self.catalog = _tool_catalog()

    async def execute(self, tool_id: str, arguments: dict[str, Any], run_id: str | None = None) -> dict[str, Any]:
        # 1. Start Tracing
        trace_id = str(uuid.uuid4())
        # ... (tracing logic)

        try:
            # 2. Invoke the Tool
            result = await native_tool_adapter.invoke(tool_id, arguments)
        except Exception as exc:
            # 3. Handle Errors
            # ... (error tracing)
            return {"status": "error", "tool_id": tool_id, "trace_id": trace_id, "result": str(exc)}

        # 4. Finalize Trace and Return
        return {"status": "ok", "tool_id": tool_id, "trace_id": trace_id, "result": result}

tool_execution_service = ToolExecutionService()
```

---

## 2. Line-by-Line Deep Dive

### The Catalog (`_tool_catalog`)

- **Lines 15-28**: `ToolContract`
  - **`tool_id`**: The unique identifier for the tool. This is what the LLM uses to refer to the tool.
  - **`input_schema`**: A JSON Schema defining the arguments. If the LLM tries to send a string when an integer is expected, the system will catch it.
  - **`is_side_effecting`**: Tells the system if this tool changes state (like writing a file). This is important for "Undo" functionality or security confirmations.

---

### The Handlers

- **Lines 160-214**: Private handler functions (e.g., `_filesystem_list_directory`).
  - These are small wrappers that take the `arguments` dictionary from the LLM and call the appropriate specialized service (like `filesystem_service`).
  - **`arguments.get("path", ".")`**: We provide safe defaults.

---

### OAuth Resolution

- **Lines 217-237**: `_resolve_google_access_token`
  - **Complex Logic**: For tools like Gmail, we need an OAuth token. This function checks if a token is provided in the arguments, if not it looks in our local `oauth_token_store`.
  - **Auto-Refresh**: If the token is expired but we have a `refresh_token`, it automatically calls Google to get a fresh one. This makes the agent "just work" without the user constantly re-authenticating.

---

### The Execution Service

- **Line 257**: `async def execute(...)`
  - This is the main entry point for running a tool.
  - **Tracing**: Before running the tool, it publishes a `tool_call_started` event to the `trace_event_bus`. This is what allows the Flutter frontend to show the "Agent is thinking..." or "Writing file..." animations in real-time.
  - **Redaction**: Notice the `_redact(arguments)` call on line 267. We never save secrets or API keys into our trace logs for security reasons.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Why use an Adapter?**
> We use `native_tool_adapter` (part of our MCP implementation). This allows us to easily swap out "Native" Python tools for "External" tools (running in separate processes) without changing the `ToolExecutionService` logic.

---

## Key References
- [JSON Schema Specification](https://json-schema.org/)
- [OAuth 2.0 Simplified](https://www.oauth.com/)
- [OpenTelemetry Event Publishing](https://opentelemetry.io/docs/concepts/signals/events/)
