# Source Code Guide: `app/db/models/run.py`

This file tracks the **History of Actions**. A "Run" is a single session where the AI agent attempts to solve a prompt. "ToolCallEvents" are the specific steps the agent took during that run (e.g., "Step 1: List files", "Step 2: Summarize text").

---

## 1. Complete Code

```python
class Run(Base):
    """
    A single session of agent execution.
    """
    __tablename__ = "runs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), nullable=False)
    mode: Mapped[str] = mapped_column(String(20), nullable=False) # 'chat' or 'workflow'
    status: Mapped[str] = mapped_column(String(30), default="queued")
    prompt: Mapped[str | None] = mapped_column(Text)
    graph_json: Mapped[dict] = mapped_column(JSON, default=dict)

class ToolCallEvent(Base):
    """
    Logs every time a tool is called by the agent.
    """
    __tablename__ = "tool_call_events"

    run_id: Mapped[str] = mapped_column(String(36), nullable=False)
    tool_id: Mapped[str] = mapped_column(String(200), nullable=False)
    event_type: Mapped[str] = mapped_column(String(60), nullable=False) # 'started', 'finished'
    payload: Mapped[dict] = mapped_column(JSON, default=dict)
    status: Mapped[str] = mapped_column(String(30), default="ok")
```

---

## 2. Line-by-Line Deep Dive

### Run Management

- **Line 15**: `mode: Mapped[str]`
  - Weaver has two modes: **Chat** (freeform) and **Workflow** (structured). This column tells us which one was used for this specific run.
- **Line 18**: `graph_json`
  - For advanced workflows, we store the entire "Execution Graph" (which nodes are connected to which) in this JSON blob.

### Event Logging (The "Audit Trail")

- **Line 28**: `event_type`
  - We log both when a tool **starts** and when it **finishes**.
  - **Why?**: If a tool crashes the entire backend, we can look at the database and see "Tool X started, but never finished."

- **Line 29**: `payload`
  - This stores the **Arguments** sent to the tool and the **Result** it returned.
  - **Educational Tip**: This is vital for "Debugging" AI behavior. If the AI hallucinates a filename, you'll see the wrong filename right here in the payload.

---

## 3. Educational Callouts

> [!TIP]
> **Relational Data**:
> Even though there is no "Physical" foreign key constraint here (for simplicity in this project), `run_id` in the `ToolCallEvent` table points back to the `id` in the `Run` table. This allows you to say "Give me all tool calls for Run XYZ."

---

## Key References
- [SQLAlchemy: Relationship Patterns](https://docs.sqlalchemy.org/en/20/orm/basic_relationships.html)
- [Agentic Workflow Auditing](https://www.deeplearning.ai/short-courses/ai-agentic-workflows-with-langgraph/)
