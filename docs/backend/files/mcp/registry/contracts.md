# Source Code Guide: `app/mcp/registry/contracts.py`

In Weaver, we don't just "pass strings around." We use strictly defined structures to describe what a tool can do. This file defines the **ToolContract**, which is the blueprint for every tool in the system.

It uses **Pydantic**, which is the industry standard for data validation in modern Python.

---

## 1. Complete Code

```python
from typing import Any
from pydantic import BaseModel

class ToolContract(BaseModel):
    """
    Defines the standard interface for any tool in Weaver.
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
```

---

## 2. Line-by-Line Deep Dive

### The ToolContract Class

- **Line 6**: `class ToolContract(BaseModel):`
  - Inheriting from `BaseModel` gives us automatic validation. If we try to create a contract with a missing `tool_id`, Pydantic will raise an error immediately.

### Field Explanations

- **`tool_id`**: The "technical name" (e.g., `google.gmail.send`).
- **`display_name`**: The "human name" (e.g., `Send Email via Gmail`).
- **`provider`**: Which service provides this (e.g., `google`, `discord`, `local`).
- **`auth_type`**: How the user authenticates (`none`, `oauth2`, `api_key`).
- **`input_schema`**: A **JSON Schema** object. This is what we send to the LLM so it knows exactly what fields to provide (e.g., `recipient`, `subject`, `body`).
- **`is_side_effecting`**: 
  - **`False`**: The tool only reads data (like `list_files`).
  - **`True`**: The tool changes something (like `delete_file`). 
  - **Why?**: This allows the UI to show a warning or ask for confirmation before running "dangerous" tools.

---

## 3. Educational Callouts

> [!NOTE]
> **Pydantic vs. Standard Classes**:
> If you used a normal Python class, you'd have to write `self.tool_id = tool_id` and manually check if it's a string. Pydantic does all of this for you automatically and even allows for easy conversion to JSON (`contract.model_dump_json()`).

---

## Key References
- [Pydantic Models Documentation](https://docs.pydantic.dev/latest/concepts/models/)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
