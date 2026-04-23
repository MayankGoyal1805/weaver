# Source Code Guide: `app/core/security.py`

This file handles the creation of **JWT (JSON Web Tokens)**. In Weaver, we use these tokens to verify the identity of the user (or the internal agent) between the frontend and backend.

---

## 1. Complete Code

```python
from datetime import datetime, timedelta, timezone
from typing import Any
from jose import jwt
from app.core.config import get_settings

# 1. The hashing algorithm used to sign the tokens
ALGORITHM = "HS256"

def create_access_token(subject: str) -> str:
    """
    Creates a short-lived token (usually 30 minutes).
    """
    settings = get_settings()
    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_access_ttl_minutes)
    payload: dict[str, Any] = {"sub": subject, "type": "access", "exp": exp}
    return jwt.encode(payload, settings.app_secret_key, algorithm=ALGORITHM)

def create_refresh_token(subject: str) -> str:
    """
    Creates a long-lived token (usually 7 days).
    """
    settings = get_settings()
    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_refresh_ttl_minutes)
    payload: dict[str, Any] = {"sub": subject, "type": "refresh", "exp": exp}
    return jwt.encode(payload, settings.app_secret_key, algorithm=ALGORITHM)
```

---

## 2. Line-by-Line Deep Dive

### JWT Concepts

- **Line 9**: `ALGORITHM = "HS256"`
  - **What**: HMAC with SHA-256. 
  - **Why**: This is a symmetric signing algorithm. It uses our `app_secret_key` to create a signature. If the key is secret, no one can fake a token.

- **Line 15**: `payload = {"sub": subject, "type": "access", "exp": exp}`
  - **`sub` (Subject)**: Usually the user's email or ID. It's who the token is for.
  - **`exp` (Expiration)**: The exact time when this token becomes invalid. JWTs carry their own expiration date!

### Access vs. Refresh Tokens

- **`create_access_token`**: 
  - **Usage**: Sent with every API request in the `Authorization` header.
  - **Duration**: Short (e.g., 30 mins) so that if it's stolen, it's only useful for a short time.
- **`create_refresh_token`**:
  - **Usage**: Used ONLY to get a new access token when the old one expires.
  - **Duration**: Long (e.g., 7 days). This keeps the user logged in without them having to re-enter their password constantly.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Why sign tokens?**
> A JWT is just a Base64-encoded string. Anyone can decode it and see the email. However, the **Signature** at the end (created using the `ALGORITHM`) proves that the content wasn't modified. If a hacker changes the email, the signature won't match, and the backend will reject it.

---

## Key References
- [JWT.io Introduction](https://jwt.io/introduction)
- [Python-jose Library](https://python-jose.readthedocs.io/en/latest/)
- [FastAPI: Security Guide](https://fastapi.tiangolo.com/tutorial/security/)
