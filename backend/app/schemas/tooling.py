from typing import Any

from pydantic import BaseModel, Field


class ToolDefinitionOut(BaseModel):
    tool_id: str
    display_name: str
    provider: str
    auth_type: str
    capabilities: list[str]
    required_scopes: list[str]
    input_schema: dict[str, Any]
    output_schema: dict[str, Any]
    is_side_effecting: bool
    description: str | None = None


class ToolExecuteIn(BaseModel):
    run_id: str | None = None
    tool_id: str
    arguments: dict[str, Any] = Field(default_factory=dict)


class ToolExecuteOut(BaseModel):
    status: str
    tool_id: str
    result: dict[str, Any]
    trace_id: str


class ToolCardStateOut(BaseModel):
    provider: str
    status: str
    scopes: list[str]
    metadata: dict[str, Any]
