import asyncio
import json
import uuid

from fastapi import APIRouter
from fastapi.responses import StreamingResponse

from app.schemas.runs import RunCreateIn, RunInvokeToolIn
from app.services.orchestration.langgraph.runtime import single_tool_graph
from app.services.tracing.event_bus import trace_event_bus

router = APIRouter(prefix="/runs", tags=["runs"])


@router.post("")
async def create_run(payload: RunCreateIn) -> dict:
    run_id = str(uuid.uuid4())
    return {
        "id": run_id,
        "mode": payload.mode,
        "status": "queued",
        "prompt": payload.prompt,
        "graph_json": {"type": "single_tool_graph"},
    }


@router.post("/{run_id}/invoke-tool")
async def invoke_tool_graph(run_id: str, payload: RunInvokeToolIn) -> dict:
    state = {"run_id": run_id, "tool_id": payload.tool_id, "arguments": payload.arguments}
    out = await single_tool_graph.ainvoke(state)
    return out


@router.get("/{run_id}/trace")
async def stream_trace(run_id: str) -> StreamingResponse:
    queue = trace_event_bus.subscribe(run_id)

    async def event_stream():
        try:
            while True:
                message = await asyncio.wait_for(queue.get(), timeout=30)
                yield f"data: {message}\n\n"
        except TimeoutError:
            keepalive = json.dumps({"run_id": run_id, "event_type": "keepalive"})
            yield f"data: {keepalive}\n\n"
        finally:
            trace_event_bus.unsubscribe(run_id, queue)

    return StreamingResponse(event_stream(), media_type="text/event-stream")
