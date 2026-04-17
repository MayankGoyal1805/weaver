from typing import Any, TypedDict

from langgraph.graph import END, START, StateGraph

from app.services.tools import tool_execution_service


class WeaverAgentState(TypedDict, total=False):
    run_id: str
    tool_id: str
    arguments: dict[str, Any]
    tool_result: dict[str, Any]


async def execute_tool_node(state: WeaverAgentState) -> WeaverAgentState:
    result = await tool_execution_service.execute(
        tool_id=state["tool_id"],
        arguments=state.get("arguments", {}),
        run_id=state.get("run_id"),
    )
    state["tool_result"] = result
    return state


def build_single_tool_graph():
    graph = StateGraph(WeaverAgentState)
    graph.add_node("execute_tool", execute_tool_node)
    graph.add_edge(START, "execute_tool")
    graph.add_edge("execute_tool", END)
    return graph.compile()


single_tool_graph = build_single_tool_graph()
