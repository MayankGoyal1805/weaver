# Source Code Guide: `app/schemas/chat.py`

This file defines the data contracts for the **Chat and Agent** systems. It handles the input prompts from the user and the structured responses from the AI, including any tool calls it made.

---

## 1. Complete Code (Highlights)

```python
class ChatIn(BaseModel):
    """Simple chat request."""
    prompt: str
    system_prompt: str | None = None
    model_name: str | None = None

class AgentPromptIn(BaseModel):
    """Advanced agentic request."""
    prompt: str
    system_prompt: str | None = None
    model_name: str | None = None
    enabled_tool_ids: list[str] = []
    history: list[dict] = []
    discord_channel_id: str | None = None

class AgentPromptOut(BaseModel):
    """The agent's comprehensive response."""
    chat: ChatOut | None = None
    chat_error: str | None = None
    tool_calls: list[AgentToolCallOut]
    discord_send: dict | None = None
```

---

## 2. Line-by-Line Deep Dive

### Input Schemas

- **Lines 16-24**: `AgentPromptIn`
  - **`enabled_tool_ids`**: The list of tools the user has "toggled on" in the UI. We only allow the agent to use tools from this list.
  - **`history`**: A list of previous messages. This is how the AI "Remembers" what you said two minutes ago.

### Output Schemas

- **Lines 32-36**: `AgentPromptOut`
  - **`chat`**: The actual text response from the AI.
  - **`tool_calls`**: A list of what the agent actually *did*. This is why Weaver is "Agentic"—the response isn't just text; it's a record of actions taken.
  - **`discord_send`**: A special field that returns the result of a Discord notification if one was triggered.

### Nesting

- **Line 33**: `chat: ChatOut | None = None`
  - **What**: Pydantic allows you to nest models. `AgentPromptOut` contains a `ChatOut` object. 
  - **Why**: This keeps the JSON structure organized and hierarchical.

---

## 3. Educational Callouts

> [!TIP]
> **Optional vs. Required**:
> In Pydantic, if a field has a default value (like `= None` or `= []`), it is **Optional**. If it doesn't have a default, the frontend **MUST** provide it, or the request will fail.

---

## Key References
- [Pydantic: Optional Fields](https://docs.pydantic.dev/latest/concepts/models/#optional-fields)
- [LLM Message Formats](https://platform.openai.com/docs/guides/text-generation/chat-completions-api)
