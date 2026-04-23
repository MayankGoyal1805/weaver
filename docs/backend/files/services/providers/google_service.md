# Source Code Guide: `app/services/providers/google/service.py`

This file is the **Low-Level Engine** for interacting with Google's APIs. It handles everything from the "Login with Google" URL generation to complex operations like fetching and decoding Gmail messages.

---

## 1. Complete Code (Highlights)

```python
import httpx
from urllib.parse import urlencode
from app.core.config import get_settings

class GoogleIntegrationService:
    @staticmethod
    def build_oauth_url(state: str) -> str:
        # 1. Generate the 'Login with Google' link
        params = {
            "client_id": settings.google_client_id,
            "scope": " ".join(GOOGLE_SCOPES),
            "access_type": "offline", # Crucial for getting refresh tokens
            "prompt": "consent",      # Always show the permissions screen
            "state": state,
        }
        return f"https://accounts.google.com/o/oauth2/v2/auth?{urlencode(params)}"

    @staticmethod
    async def exchange_code(code: str) -> dict:
        # 2. Swap code for tokens
        payload = {"code": code, "grant_type": "authorization_code", ...}
        async with httpx.AsyncClient() as client:
            response = await client.post("https://oauth2.googleapis.com/token", data=payload)
            return response.json()

    @staticmethod
    async def get_latest_gmail_email(access_token: str) -> dict:
        # 3. Complex multi-step API call
        headers = {"Authorization": f"Bearer {access_token}"}
        async with httpx.AsyncClient() as client:
            # Step A: Get list of messages
            list_resp = await client.get(".../messages", headers=headers, params={"maxResults": 1})
            # Step B: Get full content of the first message
            msg_id = list_resp.json()["messages"][0]["id"]
            msg_resp = await client.get(f".../messages/{msg_id}", headers=headers)
            return _process_gmail(msg_resp.json())
```

---

## 2. Line-by-Line Deep Dive

### OAuth Configuration

- **Line 26**: `"access_type": "offline"`
  - **Why**: By default, Google only gives you an `access_token` (valid for 1 hour). If you want a `refresh_token` (to stay logged in for days), you **MUST** set this to "offline".
- **Line 28**: `"prompt": "consent"`
  - **Why**: This forces Google to show the permissions screen to the user, ensuring we get a fresh refresh token every time they connect.

### Networking with `httpx`

- **Line 43**: `async with httpx.AsyncClient(timeout=20.0) as client:`
  - **Async**: We use `httpx` because it's built for `async/await`. This prevents the backend from "Freezing" while waiting for Google's servers to respond.
  - **Timeout**: We set a 20-second timeout. Google is usually fast, but sometimes their APIs can hang.

### Gmail Decoding Logic

- **Lines 193-224**: `_extract_message_body` and `_decode_base64url`
  - **The Problem**: Google sends email bodies as "Base64URL" encoded strings. This is not standard text!
  - **The Solution**: We have to replace `-` with `+` and `_` with `/`, add padding (`=`), and then use Python's `base64` module to turn it back into readable text.
  - **Recursion**: Emails are often "Multipart" (e.g., a text version and an HTML version). `_find_plain_text` is a **Recursive Function** that digs through the email layers until it finds the plain text version.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Static Methods (`@staticmethod`)**:
> Notice we use `@staticmethod` for everything here. This means we don't need to create an instance of the class (`service = GoogleIntegrationService()`) to use them. They act like grouped functions.

---

## Key References
- [Google OAuth 2.0 for Web Servers](https://developers.google.com/identity/protocols/oauth2/web-server)
- [Gmail API: Users.messages.get](https://developers.google.com/gmail/api/reference/rest/v1/users.messages/get)
- [Base64 Encoding Explained](https://developer.mozilla.org/en-US/docs/Glossary/Base64)
