# Source Code Guide: `app/services/orchestration/langgraph/runtime.py`

This file implements a **State Machine** using the `LangGraph` library. In simple terms, it defines a flowchart for how an agent should process a request. 

Even though we currently only have a "Single Tool" graph, this architecture allows us to build complex multi-step workflows in the future.

---

## 1. Complete Code

```python
from typing import Any, TypedDict
from langgraph.graph import END, START, StateGraph
from app.services.tools import tool_execution_service

# 1. Define the 'State' (What data flows through the graph?)
class WeaverAgentState(TypedDict, total=False):
    run_id: str
    tool_id: str
    arguments: dict[str, Any]
    tool_result: dict[str, Any]

# 2. Define a 'Node' (An action the graph takes)
async def execute_tool_node(state: WeaverAgentState) -> WeaverAgentState:
    result = await tool_execution_service.execute(
        tool_id=state["tool_id"],
        arguments=state.get("arguments", {}),
        run_id=state.get("run_id"),
    )
    state["tool_result"] = result
    return state

# 3. Build the Graph
def build_single_tool_graph():
    graph = StateGraph(WeaverAgentState)
    graph.add_node("execute_tool", execute_tool_node)
    graph.add_edge(START, "execute_tool")
    graph.add_edge("execute_tool", END)
    return graph.compile()
```

---

## 2. Line-by-Line Deep Dive

### The State (`TypedDict`)

- **Line 8**: `class WeaverAgentState(TypedDict, total=False):`
  - **What**: This is the "Shared Memory" of the graph. Every node in the graph reads from and writes to this dictionary.
  - **`total=False`**: This means not every key is required in every step.

### Nodes and Actions

- **Lines 15-22**: `execute_tool_node`
  - A node is just a function that takes the current `state`, does some work, and returns the updated `state`.
  - Here, it calls our standard `tool_execution_service` and saves the result into the `tool_result` key of the state.

### The Flowchart (Graph)

- **Line 26**: `graph = StateGraph(WeaverAgentState)`
  - Creates a new graph that will use our `WeaverAgentState`.
- **Lines 28-29**: `add_edge(START, ...)` and `add_edge(..., END)`
  - **Edges** define the transitions.
  - **Logic**: "When the graph starts (`START`), go to the `execute_tool` node. When that node finishes, end the graph (`END`)."

---

## 3. Educational Callouts

> [!TIP]
> **Why use a Graph?**
> Currently, this seems like overkill for a single tool call. But imagine you want to:
> 1. Fetch Email.
> 2. **Check**: Is it an invoice?
> 3. **If Yes**: Save to Drive.
> 4. **If No**: Ignore.
>
> A Graph allows you to define this "Branching Logic" visually and cleanly.

---

## Key References
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [TypedDict in Python](https://docs.python.org/3/library/typing.html#typing.TypedDict)
- [State Machines for AI Agents](https://blog.langchain.dev/langgraph/)
