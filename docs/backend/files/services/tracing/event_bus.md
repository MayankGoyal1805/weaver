# Source Code Guide: `app/services/tracing/event_bus.py`

The `TraceEventBus` is an **Asynchronous Message Relay**. It allows different parts of the backend to talk to each other without being directly connected. 

In Weaver, this is primarily used to stream tool logs from the deep backend all the way to the user's screen in real-time.

---

## 1. Complete Code

```python
import asyncio
import json
from collections import defaultdict
from typing import Any

class TraceEventBus:
    def __init__(self) -> None:
        # 1. Map of RunID -> List of Subscriber Queues
        self._queues: dict[str, list[asyncio.Queue[str]]] = defaultdict(list)

    async def publish(self, run_id: str, event: dict[str, Any]) -> None:
        # 2. Send an event to all subscribers
        payload = json.dumps(event)
        for queue in self._queues[run_id]:
            await queue.put(payload)

    def subscribe(self, run_id: str) -> asyncio.Queue[str]:
        # 3. Create a new subscription
        queue: asyncio.Queue[str] = asyncio.Queue()
        self._queues[run_id].append(queue)
        return queue

    def unsubscribe(self, run_id: str, queue: asyncio.Queue[str]) -> None:
        # 4. Clean up
        if run_id in self._queues:
            self._queues[run_id] = [q for q in self._queues[run_id] if q is not queue]
```

---

## 2. Line-by-Line Deep Dive

### The Data Structure

- **Line 9**: `defaultdict(list)`
  - **What**: A dictionary that automatically creates an empty list if you access a key that doesn't exist.
  - **Why**: When the first person subscribes to `run_123`, we don't have to check `if 'run_123' in self._queues`. We just append to it.

### Publishing

- **Lines 11-14**: `publish(run_id, event)`
  - **`json.dumps(event)`**: We convert the Python dictionary into a JSON string *once*. This is more efficient than doing it for every subscriber.
  - **`queue.put(payload)`**: We put the message into the subscriber's queue. If the subscriber is busy, the queue will hold the message for them until they are ready to read it.

### Subscribing

- **Lines 16-19**: `subscribe(run_id)`
  - **`asyncio.Queue()`**: This is an asynchronous "First-In, First-Out" (FIFO) pipe. 
  - **Multiple Subscribers**: Notice that we use a **list** of queues. This means if you have three different browser tabs open for the same chat, all three will receive the real-time logs simultaneously.

---

## 3. Educational Callouts

> [!TIP]
> **Observer Pattern**:
> This is a classic implementation of the **Observer Pattern**. The `publish` method is the "Subject," and the `queues` are the "Observers." This keeps the "Business Logic" (running tools) completely separate from the "UI Logic" (streaming logs).

---

## Key References
- [Python Asyncio: Queues](https://docs.python.org/3/library/asyncio-queue.html)
- [Design Patterns: Observer Pattern](https://refactoring.guru/design-patterns/observer)
- [Python Collections: defaultdict](https://docs.python.org/3/library/collections.html#collections.defaultdict)
