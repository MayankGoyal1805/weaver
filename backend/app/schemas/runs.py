from datetime import datetime
from typing import Any

from pydantic import BaseModel


class RunCreateIn(BaseModel):
    mode: str
    prompt: str | None = None


class RunInvokeToolIn(BaseModel):
    tool_id: str
    arguments: dict[str, Any]


class RunOut(BaseModel):
    id: str
    mode: str
    status: str
    prompt: str | None
    graph_json: dict[str, Any]
    created_at: datetime


class TraceEventOut(BaseModel):
    run_id: str
    tool_id: str
    event_type: str
    payload: dict[str, Any]
    status: str
    created_at: datetime
