from fastapi import APIRouter, HTTPException

from app.schemas.tooling import ToolCardStateOut, ToolDefinitionOut, ToolExecuteIn, ToolExecuteOut
from app.services.providers.filesystem.service import filesystem_service
from app.services.providers.token_store import oauth_token_store
from app.services.tools import tool_execution_service

router = APIRouter(prefix="/tools", tags=["tools"])


@router.get("/catalog", response_model=list[ToolDefinitionOut])
async def get_tool_catalog() -> list[ToolDefinitionOut]:
    return [ToolDefinitionOut(**tool.model_dump()) for tool in tool_execution_service.catalog]


@router.post("/execute", response_model=ToolExecuteOut)
async def execute_tool(payload: ToolExecuteIn) -> ToolExecuteOut:
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
    google_status = oauth_token_store.get_status("google")
    discord_status = oauth_token_store.get_status("discord")

    def _provider_state(status: dict) -> tuple[str, dict]:
        authenticated = bool(status.get("authenticated"))
        metadata = status.get("metadata", {}) if isinstance(status, dict) else {}
        return ("connected" if authenticated else "auth_required", metadata)

    google_state, google_meta = _provider_state(google_status)
    discord_state, discord_meta = _provider_state(discord_status)

    return [
        ToolCardStateOut(
            provider="filesystem",
            status="connected",
            scopes=[],
            metadata=filesystem_service.get_allowed_root(),
        ),
        ToolCardStateOut(
            provider="google",
            status=google_state,
            scopes=google_status.get("scopes", []),
            metadata=google_meta,
        ),
        ToolCardStateOut(
            provider="discord",
            status=discord_state,
            scopes=discord_status.get("scopes", []),
            metadata=discord_meta,
        ),
    ]


@router.get("/filesystem/root")
async def get_filesystem_root() -> dict:
    return filesystem_service.get_allowed_root()


@router.post("/filesystem/root")
async def set_filesystem_root(payload: dict) -> dict:
    root_path = (payload.get("allowed_root") or "").strip()
    if not root_path:
        raise HTTPException(status_code=400, detail="allowed_root is required")
    return filesystem_service.set_allowed_root(root_path)
