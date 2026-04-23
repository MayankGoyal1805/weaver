# Source Code Guide: `app/services/llm.py`

This file is the **Interface to the LLM**. It has been updated to support **Tool Calling (Function Calling)**, allowing the model to interact with the external world (Gmail, Drive, Discord) using a standardized JSON schema.

---

## 1. Complete Code

```python
class LLMService:
    async def chat(
        self,
        prompt: str,
        system_prompt: str | None = None,
        model_name: str | None = None,
        llm_api_key: str | None = None,
        llm_base_url: str | None = None,
        history: list[dict] | None = None,
        tools: list[dict] | None = None, # New: Tool definitions
    ) -> dict:
        # 1. Prepare Messages
        messages = _build_bounded_messages(...)

        # 2. Build Payload
        payload = {
            "model": chosen_model,
            "messages": messages,
            "temperature": 0.2,
        }
        if tools:
            payload["tools"] = tools
            payload["tool_choice"] = "auto"

        # 3. Request
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(endpoint, headers=headers, json=payload)
            data = response.json()

        # 4. Extract Result
        message = data["choices"][0]["message"]
        return {
            "model_name": chosen_model,
            "content": message.get("content", ""),
            "tool_calls": message.get("tool_calls", []), # New: Extraction
            "raw_response": data,
        }
```

---

## 2. Line-by-Line Deep Dive

### Tool Calling Integration

- **Line 23**: `tools: list[dict] | None`.
  - We now accept a list of tool definitions in the OpenAI `function` format. These are passed directly to the LLM.
- **Lines 49-51**: `payload["tools"]`.
  - If tools are provided, we set `tool_choice: "auto"`. This tells the model: "You can either answer normally or ask to use one of these tools."
- **Line 63**: `tool_calls = message.get("tool_calls", [])`.
  - We extract any tool requests made by the AI. This is a list of objects containing the `function name` and `arguments` (e.g., `{"name": "google_gmail_read", "arguments": "{}"}`).

### Enhanced Context Budgeting (`_build_bounded_messages`)

- **Lines 93-104**: Support for `role: "tool"`.
  - **Why**: Tool results are a special type of message. They don't just have `content`; they require a `tool_call_id` that matches the request from the `assistant`.
  - **Trimming**: We now check if a message has `tool_calls` or a `tool_call_id`. If so, we preserve those fields when cleaning the history to ensure the conversation state remains valid.
- **Line 115**: `_strip_think`.
  - We continue to strip internal "reasoning" tags (like `<think>`) to keep the context clean and save tokens.

---

## 3. Educational Callouts

> [!TIP]
> **What is a "Tool Call"?**
> When the AI decides it needs to use a tool, it doesn't actually run any code. It just outputs a specifically formatted JSON object saying, "I would like to call `google_gmail_read` with these parameters." It is the **Backend's responsibility** (in `chat.py`) to see this, run the tool, and send the result back.

---

## Key References
- [OpenAI: Function Calling Documentation](https://platform.openai.com/docs/guides/function-calling)
- [Httpx: Async HTTP Client for Python](https://www.python-httpx.org/)
- [JSON Schema in Tool Calling](https://json-schema.org/understanding-json-schema/)
