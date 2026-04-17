from collections.abc import Awaitable, Callable
from typing import Any


NativeToolHandler = Callable[[dict[str, Any]], Awaitable[dict[str, Any]]]


class NativeToolAdapter:
    def __init__(self) -> None:
        self._handlers: dict[str, NativeToolHandler] = {}

    def register(self, tool_id: str, handler: NativeToolHandler) -> None:
        self._handlers[tool_id] = handler

    async def invoke(self, tool_id: str, arguments: dict[str, Any]) -> dict[str, Any]:
        if tool_id not in self._handlers:
            raise ValueError(f"Unknown tool_id: {tool_id}")
        return await self._handlers[tool_id](arguments)


native_tool_adapter = NativeToolAdapter()
