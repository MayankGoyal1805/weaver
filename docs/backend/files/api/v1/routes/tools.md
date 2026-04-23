# Source Code Guide: `app/api/v1/routes/tools.py`

This file handles **Tool Discovery and Execution**. It allows the frontend to ask "What can this agent do?" and then "Run this specific tool."

It also manages the "Card State," which tells the UI if a specific integration (like Google or Discord) is currently active.

---

## 1. Complete Code

```python
from fastapi import APIRouter, HTTPException

from app.schemas.tooling import ToolCardStateOut, ToolDefinitionOut, ToolExecuteIn, ToolExecuteOut
from app.services.providers.filesystem.service import filesystem_service
from app.services.providers.token_store import oauth_token_store
from app.services.tools import tool_execution_service

router = APIRouter(prefix="/tools", tags=["tools"])


@router.get("/catalog", response_model=list[ToolDefinitionOut])
async def get_tool_catalog() -> list[ToolDefinitionOut]:
    """
    Returns every tool registered in the system.
    """
    return [ToolDefinitionOut(**tool.model_dump()) for tool in tool_execution_service.catalog]


@router.post("/execute", response_model=ToolExecuteOut)
async def execute_tool(payload: ToolExecuteIn) -> ToolExecuteOut:
    """
    Manually triggers a tool execution.
    """
    known_tool_ids = {tool.tool_id for tool in tool_execution_service.catalog}
    if payload.tool_id not in known_tool_ids:
        raise HTTPException(status_code=404, detail="Unknown tool_id")

    result = await tool_execution_service.execute(
        tool_id=payload.tool_id,
        arguments=payload.arguments,
        run_id=payload.run_id,
    )
    return ToolExecuteOut(**result)


@router.get("/cards/state", response_model=list[ToolCardStateOut])
async def get_card_states() -> list[ToolCardStateOut]:
    """
    Tells the UI if Google, Discord, etc. are connected.
    """
    # ... (status logic)
    return [
        ToolCardStateOut(provider="filesystem", status="connected", metadata=...),
        ToolCardStateOut(provider="google", status=..., metadata=...),
    ]
```

---

## 2. Line-by-Line Deep Dive

### The Tool Catalog

- **Lines 11-13**: `get_tool_catalog`
  - **`tool_execution_service.catalog`**: This is the list we defined in `app/services/tools.py`. 
  - **`ToolDefinitionOut(**tool.model_dump())`**: This is a common Pydantic pattern. We take our internal `ToolContract` object, convert it to a dictionary (`model_dump`), and then re-create it as a `ToolDefinitionOut` (the schema specifically for API output).

### Execution Endpoint

- **Lines 16-27**: `execute_tool`
  - **Validation**: We first check if the `tool_id` actually exists before trying to run it.
  - **`await tool_execution_service.execute(...)`**: This is where the actual work happens. It's asynchronous because the tool might be slow (e.g., sending a large email or downloading a file).

### Card States

- **Lines 30-62**: `get_card_states`
  - The Flutter UI has "Cards" for each tool provider. 
  - **`_provider_state`**: A small helper function that checks if a provider is "connected" or if "auth_required". 
  - **Metadata**: We also return metadata (like your Google profile picture or current filesystem root) so the UI can display it in the card.

---

## 3. Educational Callouts

> [!TIP]
> **List Comprehensions**:
> On line 13, `[ToolDefinitionOut(...) for tool in ...]` is a Python **List Comprehension**. It's a concise way to create a new list by transforming every item in an existing one. It's equivalent to a `.map()` in Javascript or Dart.

---

## Key References
- [FastAPI: Path Parameters and Numeric Validations](https://fastapi.tiangolo.com/tutorial/path-params-numeric-validations/)
- [Pydantic: model_dump](https://docs.pydantic.dev/latest/concepts/serialization/#modelmodel_dump)
