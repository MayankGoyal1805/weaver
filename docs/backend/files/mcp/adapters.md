# Source Code Guide: `app/mcp/adapters/native_adapter.py`

This file implements the **Native Adapter**. In the Model Context Protocol (MCP) world, an "Adapter" is something that connects the system to a specific type of tool.

"Native" here means tools that are implemented as Python functions within the same memory space as the FastAPI server.

---

## 1. Complete Code

```python
from collections.abc import Awaitable, Callable
from typing import Any

# 1. Type Alias for Readability
NativeToolHandler = Callable[[dict[str, Any]], Awaitable[dict[str, Any]]]


class NativeToolAdapter:
    """
    The internal registry and dispatcher for Python-based tools.
    """
    def __init__(self) -> None:
        # 2. Storage for Handlers
        self._handlers: dict[str, NativeToolHandler] = {}

    def register(self, tool_id: str, handler: NativeToolHandler) -> None:
        """
        Binds a string ID to a specific Python function.
        """
        self._handlers[tool_id] = handler

    async def invoke(self, tool_id: str, arguments: dict[str, Any]) -> dict[str, Any]:
        """
        Runs the handler associated with the tool_id.
        """
        if tool_id not in self._handlers:
            raise ValueError(f"Unknown tool_id: {tool_id}")
        
        # 3. Dynamic Dispatch
        return await self._handlers[tool_id](arguments)


# 4. Global Singleton
native_tool_adapter = NativeToolAdapter()
```

---

## 2. Line-by-Line Deep Dive

### Type Definitions

- **Line 5**: `NativeToolHandler = Callable[...]`
  - **What**: This is a Type Hint. It says a handler must be a function that takes a `dict` and returns an `Awaitable` (an `async` function) that eventually results in another `dict`.
  - **Why**: This prevents bugs. If someone tries to register a synchronous function (no `async def`), their IDE (and our type checker) will complain immediately.

### The Adapter Logic

- **Line 10**: `self._handlers = {}`
  - A simple dictionary. The keys are IDs like `filesystem.read_file` and the values are the function pointers.
- **Lines 12-13**: `register`
  - This is called in `app/services/tools.py` during startup. It populates our dictionary.
- **Lines 15-18**: `invoke`
  - This is where the magic happens. When the Agent says "Run tool X," we look up X in our dictionary and execute it.
  - **Error Handling**: If the ID isn't found, we raise a `ValueError`. This is caught by the `ToolExecutionService` and reported back to the Agent/User.

---

## 3. Educational Callouts

> [!TIP]
> **Why use an Adapter?**
> Imagine tomorrow we want to support tools written in **Javascript (Node.js)**. We would create a `NodeJSAdapter` that talks to a separate process. Because we use this pattern, the rest of the Weaver backend wouldn't even know the difference!

---

## Key References
- [Python Type Hints (`typing`)](https://docs.python.org/3/library/typing.html)
- [Adapter Design Pattern](https://refactoring.guru/design-patterns/adapter)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/docs/concepts/tools)
