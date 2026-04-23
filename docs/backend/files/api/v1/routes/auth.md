# Source Code Guide: `app/api/v1/routes/auth.py`

This file handles **Authentication and OAuth 2.0 Flows**. It's the bridge that lets Weaver securely connect to your Google (Gmail/Drive) and Discord accounts.

For a developer, this is the most "Interaction Heavy" part of the backend because it deals with external redirects, secret states, and token management.

---

## 1. Complete Code (Highlights)

```python
import secrets
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import RedirectResponse

from app.core.security import create_access_token, create_refresh_token
from app.schemas.auth import LoginIn, TokenPairOut
from app.services.providers.discord.service import discord_service
from app.services.providers.google.service import google_service
from app.services.providers.token_store import oauth_token_store

router = APIRouter(prefix="/auth", tags=["auth"])

# 1. Dev Login (Bypasses OAuth for quick testing)
@router.post("/dev-login", response_model=TokenPairOut)
async def dev_login(payload: LoginIn) -> TokenPairOut:
    if "@" not in payload.email:
        raise HTTPException(status_code=400, detail="Valid email required")
    return TokenPairOut(
        access_token=create_access_token(payload.email),
        refresh_token=create_refresh_token(payload.email),
    )

# 2. Start OAuth Flow
@router.get("/google/connect")
async def google_connect() -> dict:
    state = secrets.token_urlsafe(24)
    return {"auth_url": google_service.build_oauth_url(state=state), "state": state}

# 3. Handle Callback from Google
@router.get("/google/callback")
async def google_callback(code: str = Query(...), state: str = Query(...)) -> dict:
    token_bundle = await google_service.exchange_code(code)
    # ... (fetch profile and save to store)
    oauth_token_store.set_tokens("google", token_bundle, state=state, metadata={"profile": profile})
    return {"provider": "google", "state": state, "token_bundle": token_bundle}
```

---

## 2. Line-by-Line Deep Dive

### Development Login

- **Lines 16-23**: `dev_login`
  - **What**: A shortcut to get a JWT (JSON Web Token) without doing real social auth.
  - **Why**: Useful when developing the frontend so you don't have to go through the Google login screen every time you refresh.
  - **Security**: In a real production app, this would be disabled or protected by a secret key.

### OAuth "Connect" Phase

- **Lines 26-29**: `google_connect`
  - **`secrets.token_urlsafe(24)`**: Generates a long, random "State" string.
  - **State Parameter**: This is a security feature. We send this to Google, and Google sends it back to us in the callback. If the state doesn't match, we know someone might be trying a "Cross-Site Request Forgery" (CSRF) attack.

### OAuth "Callback" Phase

- **Lines 38-54**: `google_callback`
  - **`code`**: This is a temporary "Authorization Code" Google gives us. It's only valid for a few seconds.
  - **`exchange_code`**: We immediately swap that code for real `access_token` and `refresh_token` by calling Google's servers.
  - **`oauth_token_store.set_tokens`**: We save these tokens locally. Since Weaver is a desktop-first app, we store these in an encrypted JSON file so the agent can use them even after you restart the computer.

### Profile Resolution

- **Lines 62-114**: `google_userinfo`
  - This is a complex helper. It doesn't just return the name; it **auto-refreshes** tokens.
  - If the `access_token` is expired, it uses the `refresh_token` to get a new one automatically. This is why you don't have to click "Connect" every hour.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **What is a RedirectResponse?**
> On line 35, we return `RedirectResponse`. This tells the user's browser: "Go to this URL immediately." This is how the "Login with Google" button works—it redirects you from our app to Google's secure login page.

---

## Key References
- [OAuth 2.0 Simplified](https://www.oauth.com/)
- [FastAPI: Response Model](https://fastapi.tiangolo.com/tutorial/response-model/)
- [Python Secrets Module](https://docs.python.org/3/library/secrets.html)
