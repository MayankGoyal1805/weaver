from fastapi import APIRouter, HTTPException

from app.schemas.tooling import ToolCardStateOut, ToolDefinitionOut, ToolExecuteIn, ToolExecuteOut
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
    # This is a starter implementation; wire DB-backed connection health in next iteration.
    return [
        ToolCardStateOut(provider="filesystem", status="connected", scopes=[], metadata={}),
        ToolCardStateOut(provider="google", status="auth_required", scopes=[], metadata={}),
        ToolCardStateOut(provider="discord", status="auth_required", scopes=[], metadata={}),
    ]
