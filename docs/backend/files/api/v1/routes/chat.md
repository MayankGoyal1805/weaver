# Source Code Guide: `app/api/v1/routes/chat.py`

This file is the **Intelligence Hub** of Weaver. It doesn't just pass text to an LLM; it performs **Intent Recognition** to decide if it needs to fetch your emails or files *before* asking the LLM for a response.

---

## 1. Complete Code (Highlights)

```python
import re
from fastapi import APIRouter, HTTPException
from app.schemas.chat import AgentPromptIn, AgentPromptOut, ChatIn, ChatOut
from app.services.llm import llm_service
from app.services.tools import tool_execution_service

router = APIRouter(prefix="/chat", tags=["chat"])

@router.post("/agent", response_model=AgentPromptOut)
async def agent_prompt(payload: AgentPromptIn) -> AgentPromptOut:
    # 1. Intent Recognition (Keywords)
    prompt_lower = payload.prompt.lower()
    wants_latest_gmail = any(x in prompt_lower for x in ["latest gmail", "check email", "inbox"])
    wants_discord = "discord" in enabled and "discord" in prompt_lower

    # 2. Pre-emptive Tool Execution
    if wants_latest_gmail and "gmail" in enabled:
        out = await tool_execution_service.execute("google.gmail.get_latest_email", {})
        latest_email = out.get("result")

    # 3. Context Injection
    llm_prompt = payload.prompt
    if latest_email:
        llm_prompt += f"\n\nContext (Latest Email):\n{latest_email}"

    # 4. Final LLM Generation
    out = await llm_service.chat(prompt=llm_prompt, ...)
    chat_out = ChatOut(**out)

    return AgentPromptOut(chat=chat_out, tool_calls=tool_calls, ...)
```

---

## 2. Line-by-Line Deep Dive

### Intent Recognition

- **Lines 31-70**: Manual Keyword Matching.
  - **Why not use the LLM for this?**: Using simple keyword matching (`any(x in prompt_lower for x in [...])`) is **instant and free**. It saves us from sending an extra request to the LLM just to ask "Does the user want to see their email?".
  - **Logic**: We look for words like "send", "post", "gmail", "drive", etc.

### Pre-emptive Execution

- **Lines 77-94**: `tool_execution_service.execute`
  - If we detect the user wants their Gmail, we fetch it **immediately**.
  - **The Magic**: When the LLM finally receives the prompt, it already sees the content of the email in its "Context". This makes the agent feel very smart and proactive.

### Automated Workflows (The "Discord" special case)

- **Lines 107-117**: Custom Prompting.
  - If the user wants to send an email summary to Discord, we override the `system_prompt`.
  - We tell the LLM: "Write a concise Discord notification... sender, subject, and short summary only."
  - This ensures the output is formatted perfectly for a chat app (no long headers or legal jargon).

### Context Compression

- **Lines 221-250**: `_compact_email_context` and `_compact_drive_context`
  - LLMs have a "Context Window" (a limit on how much they can read). 
  - These helpers strip out the "junk" from emails and file lists, keeping only the important parts (sender, subject, filename, modified date).

---

## 3. Educational Callouts

> [!IMPORTANT]
> **RAG (Retrieval-Augmented Generation)**:
> This file is a simple implementation of RAG. Instead of the LLM knowing everything, we **Retrieve** your latest data (email/files) and **Augment** the prompt with that data so the LLM can **Generate** a relevant response.

---

## Key References
- [Retrieval-Augmented Generation (RAG) Explained](https://aws.amazon.com/what-is/retrieval-augmented-generation/)
- [Python Regular Expressions (`re.sub`)](https://docs.python.org/3/library/re.html#re.sub)
