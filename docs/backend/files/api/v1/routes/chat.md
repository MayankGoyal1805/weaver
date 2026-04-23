# Source Code Guide: `app/api/v1/routes/chat.py`

This file is the **Intelligence Hub** of Weaver. It has been upgraded from a simple keyword-matching script to a true **Agentic Reasoning Loop**. Instead of hardcoded rules, it now uses a multi-turn conversation with the LLM where the model itself decides which tools to call and how to use their results.

---

## 1. Complete Code (Highlights)

```python
@router.post("/agent", response_model=AgentPromptOut)
async def agent_prompt(payload: AgentPromptIn) -> AgentPromptOut:
    # 1. Dynamic Tool Mapping
    openai_tools = []
    for t in tool_execution_service.catalog:
        if _is_tool_enabled(t.tool_id):
            openai_tools.append({
                "type": "function",
                "function": {
                    "name": t.tool_id.replace(".", "_"),
                    "description": t.description,
                    "parameters": t.input_schema,
                }
            })

    # 2. Iterative Reasoning Loop (Max 5 turns)
    for iteration in range(5):
        # A. Call LLM with current history and tool definitions
        out = await llm_service.chat(..., tools=openai_tools)
        chat_out = ChatOut(**out)
        
        # B. Check for Tool Calls
        if not chat_out.tool_calls:
            break # No more tools needed, return final text
            
        # C. Execute Tools and append to history
        for tc in chat_out.tool_calls:
            result = await tool_execution_service.execute(...)
            history.append({"role": "tool", "content": json.dumps(result), ...})
            
    return AgentPromptOut(chat=chat_out, tool_calls=all_tool_calls, ...)
```

---

## 2. Line-by-Line Deep Dive

### Dynamic Tool Mapping

- **Lines 43-61**: Mapping to OpenAI Format.
  - **What**: We iterate through the `tool_execution_service.catalog` and convert Weaver's internal `ToolContract` into the standard JSON Schema format required by LLMs (OpenAI/Gemini style).
  - **Why**: This allows the LLM to "understand" the capabilities of your Gmail, Drive, and Discord tools just by reading their descriptions and parameter schemas.
  - **Function Naming**: OpenAI doesn't allow dots in function names, so we replace `.` with `_` (e.g., `google.gmail.read` becomes `google_gmail_read`).

### The Reasoning Loop

- **Line 83**: `for iteration in range(5):`
  - This is a **Reasoning Loop** (often called ReAct). 
  - Instead of one request, the backend might talk to the LLM multiple times in a single second. 
  - **Step 1**: Assistant says "I need to see your emails." (returns `tool_calls`)
  - **Step 2**: Backend executes Gmail tool, gets result.
  - **Step 3**: Backend sends result back to Assistant.
  - **Step 4**: Assistant says "Okay, I see the email about the meeting. I will now post a summary to Discord." (returns another `tool_call`)
  - This continues until the AI determines it has enough information to give you a final answer.

### Tool History & State

- **Lines 125-144**: Handling `role: "tool"`.
  - In a standard chat, you have `user` and `assistant`. In an agentic chat, we add a third role: `tool`.
  - These messages contain the raw output from your tools. They are never shown directly to the user but are essential for the AI to "read" the results of its actions.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Tool Calling vs. Keyword Matching**:
> Previously, if you said "Check my mail," the backend would fetch it. But if you said "If I have an email from John, summarize it," the old backend would fail because it couldn't reason about the "If". The new loop allows the AI to decide *conditionally* when to use a tool.

---

## Key References
- [OpenAI: Function Calling Guide](https://platform.openai.com/docs/guides/function-calling)
- [LangChain: ReAct Agent Pattern](https://python.langchain.com/docs/modules/agents/agent_types/react)
- [JSON Schema Standard](https://json-schema.org/)
