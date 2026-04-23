# Source Code Guide: `app/schemas/tooling.py`

Schemas are the **Contracts** between the frontend and the backend. While "Models" define how data looks in the database, "Schemas" (using Pydantic) define how data looks when it's sent over the network as JSON.

This file defines the data structures for tools.

---

## 1. Complete Code

```python
from typing import Any
from pydantic import BaseModel, Field

class ToolDefinitionOut(BaseModel):
    """
    Schema for sending tool info to the UI.
    """
    tool_id: str
    display_name: str
    provider: str
    auth_type: str
    capabilities: list[str]
    required_scopes: list[str]
    input_schema: dict[str, Any]
    output_schema: dict[str, Any]
    is_side_effecting: bool
    description: str | None = None

class ToolExecuteIn(BaseModel):
    """
    Schema for the frontend's request to run a tool.
    """
    run_id: str | None = None
    tool_id: str
    arguments: dict[str, Any] = Field(default_factory=dict)

class ToolExecuteOut(BaseModel):
    """
    Schema for the backend's response after tool execution.
    """
    status: str
    tool_id: str
    result: dict[str, Any]
    trace_id: str
```

---

## 2. Line-by-Line Deep Dive

### Pydantic `BaseModel`

- **Line 6**: `class ToolDefinitionOut(BaseModel):`
  - **What**: Every schema inherits from `BaseModel`.
  - **Validation**: If the frontend sends an integer where we expect a string, Pydantic will automatically throw a 422 Error before our code even runs. This is one of FastAPI's best features.

### Advanced Types

- **Line 13**: `input_schema: dict[str, Any]`
  - **What**: A dictionary where keys are strings and values can be anything (`Any`). 
  - **Why**: This is where we store the complex JSON schemas that tell the AI how to use the tool.

### Default Values

- **Line 22**: `arguments: dict[str, Any] = Field(default_factory=dict)`
  - **Why use `default_factory`?**: In Python, you should never use `default={}` for a dictionary. Because dictionaries are mutable, every instance of the class would share the *same* dictionary object. `default_factory=dict` ensures that every new request gets its own fresh, empty dictionary.

### Execution Response

- **Line 29**: `trace_id: str`
  - **Why**: Every tool execution is given a unique ID so we can find it in our tracing logs later if something goes wrong.

---

## 3. Educational Callouts

> [!TIP]
> **Schema vs. Model**:
> A **Model** (`User`) might have a password field. A **Schema** (`UserOut`) would leave the password field out. This ensures we never accidentally leak sensitive data to the frontend.

---

## Key References
- [Pydantic: Models](https://docs.pydantic.dev/latest/concepts/models/)
- [FastAPI: Response Model](https://fastapi.tiangolo.com/tutorial/response-model/)
