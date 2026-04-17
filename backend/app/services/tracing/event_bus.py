import asyncio
import json
from collections import defaultdict
from typing import Any


class TraceEventBus:
    def __init__(self) -> None:
        self._queues: dict[str, list[asyncio.Queue[str]]] = defaultdict(list)

    async def publish(self, run_id: str, event: dict[str, Any]) -> None:
        payload = json.dumps(event)
        for queue in self._queues[run_id]:
            await queue.put(payload)

    def subscribe(self, run_id: str) -> asyncio.Queue[str]:
        queue: asyncio.Queue[str] = asyncio.Queue()
        self._queues[run_id].append(queue)
        return queue

    def unsubscribe(self, run_id: str, queue: asyncio.Queue[str]) -> None:
        if run_id in self._queues:
            self._queues[run_id] = [q for q in self._queues[run_id] if q is not queue]
            if not self._queues[run_id]:
                del self._queues[run_id]


trace_event_bus = TraceEventBus()
