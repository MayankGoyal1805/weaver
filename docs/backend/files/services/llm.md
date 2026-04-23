# Source Code Guide: `app/services/llm.py`

This file is the **Interface to the LLM**. Instead of scattering API calls to OpenAI throughout the codebase, we centralize them here. This makes it easy to switch models, add logging, or implement "Context Budgeting" (ensuring we don't send too much text to the model).

---

## 1. Complete Code

```python
import re
import httpx
from urllib.parse import urljoin
from app.core.config import get_settings

class LLMService:
    async def chat(
        self,
        prompt: str,
        system_prompt: str | None = None,
        model_name: str | None = None,
        llm_api_key: str | None = None,
        llm_base_url: str | None = None,
        history: list[dict] | None = None,
    ) -> dict:
        # 1. Resolve Configuration
        settings = get_settings()
        api_key = (llm_api_key or settings.llm_api_key).strip()
        base_url = (llm_base_url or settings.llm_base_url).strip()
        chosen_model = model_name or settings.llm_model_name

        # 2. Build Endpoint
        endpoint = urljoin(base_url.rstrip("/") + "/", "chat/completions")

        # 3. Prepare Messages with Budgeting
        messages = _build_bounded_messages(
            prompt=prompt,
            system_prompt=system_prompt,
            history=history or [],
        )

        # 4. Make Async Request
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                endpoint, 
                headers={"Authorization": f"Bearer {api_key}"},
                json={"model": chosen_model, "messages": messages, "temperature": 0.2}
            )
            response.raise_for_status()
            data = response.json()

        return {
            "model_name": chosen_model,
            "content": data["choices"][0]["message"]["content"],
            "raw_response": data,
        }

# ... (Utility functions for context management)
```

---

## 2. Line-by-Line Deep Dive

### The `chat` Method

- **Lines 14-22**: Function signature.
  - We allow overriding the `model_name`, `api_key`, and `base_url` per call. This is useful for testing different models or letting the user use their own key for specific tasks.
- **Lines 23-33**: Configuration Resolution.
  - We use `urljoin` to safely construct the OpenAI-compatible endpoint. Even if the user provides a base URL with or without a trailing slash, it works correctly.
- **Lines 39-43**: `_build_bounded_messages`.
  - **Critical Logic**: You cannot just send a million lines of text to an LLM. This function (explained below) trims the history and prompt to fit within a specific character budget.
- **Lines 51-54**: `httpx.AsyncClient`.
  - **Async I/O**: LLM calls can take several seconds. By using `httpx` with `async/await`, the backend can handle other requests (like health checks or file listing) while waiting for the model to respond.

---

### Context Budgeting (`_build_bounded_messages`)

- **Lines 70-75**: Constants.
  - We define hard limits for `_MAX_HISTORY_MESSAGES` (12) and `_MAX_TOTAL_CHARS` (12,000).
- **Line 122**: `_strip_think`.
  - Some models (like DeepSeek R1) output their internal "thoughts" in `<think>...</think>` tags. We strip these out before sending them back to the user or back into history to save tokens.
- **Lines 102-109**: The Trimming Loop.
  - If the total character count exceeds our budget, we start popping the **oldest** history messages first.
  - **Priority**: We always try to keep the `system` prompt (index 0) and the very last `user` prompt (the actual instruction).

---

## 3. Educational Callouts

> [!TIP]
> **What is an OpenAI-Compatible API?**
> Almost every modern LLM provider (Anthropic, DeepSeek, local runners like Ollama) now provides an API that looks exactly like OpenAI's. By following this standard, Weaver can work with almost any model on the market just by changing the `llm_base_url`.

---

## Key References
- [OpenAI Chat Completions API](https://platform.openai.com/docs/api-reference/chat)
- [HTTPX: A next-generation HTTP client](https://www.python-httpx.org/)
- [Python Regular Expressions (`re`)](https://docs.python.org/3/library/re.html)
