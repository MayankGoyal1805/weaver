# Source Code Guide: `app/api/v1/routes/runs.py`

This file handles the **Lifecycle of an Agentic Run**. It defines how we start a session, how we invoke tools within that session, and most importantly, how we stream real-time logs (traces) back to the frontend.

---

## 1. Complete Code

```python
import asyncio
import json
import uuid
from fastapi import APIRouter
from fastapi.responses import StreamingResponse

from app.services.orchestration.langgraph.runtime import single_tool_graph
from app.services.tracing.event_bus import trace_event_bus

router = APIRouter(prefix="/runs", tags=["runs"])

@router.post("/{run_id}/invoke-tool")
async def invoke_tool_graph(run_id: str, payload: RunInvokeToolIn) -> dict:
    # 1. State setup
    state = {"run_id": run_id, "tool_id": payload.tool_id, "arguments": payload.arguments}
    # 2. Invoke the graph (LangGraph)
    out = await single_tool_graph.ainvoke(state)
    return out

@router.get("/{run_id}/trace")
async def stream_trace(run_id: str) -> StreamingResponse:
    # 3. Server-Sent Events (SSE) Logic
    queue = trace_event_bus.subscribe(run_id)

    async def event_stream():
        try:
            while True:
                message = await asyncio.wait_for(queue.get(), timeout=30)
                yield f"data: {message}\n\n"
        finally:
            trace_event_bus.unsubscribe(run_id, queue)

    return StreamingResponse(event_stream(), media_type="text/event-stream")
```

---

## 2. Line-by-Line Deep Dive

### Running the Graph

- **Line 30**: `await single_tool_graph.ainvoke(state)`
  - **What**: This triggers the LangGraph we defined in the services layer.
  - **Why**: Instead of just running a function, we run it through a graph so we can track the state, handle retries, and log events consistently.

### Real-time Streaming (SSE)

- **Line 35**: `StreamingResponse(event_stream(), ...)`
  - **What**: This is **Server-Sent Events (SSE)**.
  - **Why**: Standard APIs are "Request-Response." But if a tool takes 30 seconds to run, the user wants to see "Tool Started..." immediately. SSE allows the backend to "Push" messages to the frontend whenever something happens.

### The Event Bus

- **Line 36**: `trace_event_bus.subscribe(run_id)`
  - This is a "Pub/Sub" (Publisher/Subscriber) pattern. 
  - The `runs.py` file **Subscribes** to events for a specific `run_id`.
  - Somewhere else in the code (inside the tools), the system **Publishes** a message like `{"event": "tool_started"}`. 
  - The Event Bus ensures that message finds its way to this specific streaming connection.

### Memory Management

- **Line 47**: `trace_event_bus.unsubscribe(...)`
  - **Critical**: If we don't unsubscribe when the user closes the chat or the browser, the backend will keep trying to send messages to a "Ghost" connection, eventually crashing the server with a "Memory Leak."

---

## 3. Educational Callouts

> [!IMPORTANT]
> **What is `yield`?**
> In the `event_stream` function, we use `yield` instead of `return`. This turns the function into a **Generator**. It returns data bit-by-bit over time, rather than all at once at the end.

---

## Key References
- [FastAPI: Streaming Responses](https://fastapi.tiangolo.com/advanced/custom-response/#streamingresponse)
- [MDN: Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events)
- [Python Asyncio Queues](https://docs.python.org/3/library/asyncio-queue.html)
