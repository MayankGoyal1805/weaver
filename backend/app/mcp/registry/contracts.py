from typing import Any

from pydantic import BaseModel


class ToolContract(BaseModel):
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
