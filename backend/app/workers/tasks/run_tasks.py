from app.services.orchestration.langgraph.runtime import single_tool_graph


async def execute_tool_run(run_id: str, tool_id: str, arguments: dict) -> dict:
    return await single_tool_graph.ainvoke({"run_id": run_id, "tool_id": tool_id, "arguments": arguments})
