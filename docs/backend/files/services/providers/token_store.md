# Source Code Guide: `app/services/providers/token_store.py`

This file is a **Persistent Storage** for OAuth tokens. Because Weaver is a desktop application, we need a way to remember that you "Logged in with Google" even if you close and reopen the app.

---

## 1. Complete Code

```python
import json
from pathlib import Path
from datetime import UTC, datetime, timedelta
from app.core.config import get_settings

class OAuthTokenStore:
    """
    Saves tokens to a local JSON file.
    """
    def __init__(self) -> None:
        settings = get_settings()
        # 1. Expand paths like '~/.weaver/tokens.json'
        self.path = Path(settings.oauth_token_store_path).expanduser().resolve()
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def _load(self) -> dict:
        if not self.path.exists():
            return {"providers": {}}
        return json.loads(self.path.read_text())

    def _save(self, payload: dict) -> None:
        self.path.write_text(json.dumps(payload, indent=2))

    def set_tokens(self, provider: str, token_bundle: dict, ...) -> dict:
        # 2. Logic: Process and save the bundle
        record = {
            "access_token": token_bundle.get("access_token"),
            "refresh_token": token_bundle.get("refresh_token"),
            "updated_at": datetime.now(UTC).isoformat(),
        }
        # 3. Auto-calculate expiration time
        expires_in = token_bundle.get("expires_in")
        if expires_in:
            expires_at = datetime.now(UTC) + timedelta(seconds=expires_in - 60)
            record["expires_at"] = expires_at.isoformat()
        
        payload = self._load()
        payload["providers"][provider] = record
        self._save(payload)
```

---

## 2. Line-by-Line Deep Dive

### Path Handling

- **Line 20**: `Path(settings.oauth_token_store_path).expanduser().resolve()`
  - **`expanduser()`**: Converts `~` to `/home/user`. 
  - **`resolve()`**: Converts relative paths to absolute ones. This ensures the file is saved in the exact same place every time, no matter where you start the app from.

### Token Bundling

- **Lines 34-65**: `set_tokens`
  - This method takes the "Raw" JSON from Google/Discord and translates it into our "Record" format.
  - **`expires_in - 60`**: We subtract 60 seconds from the expiration time. This is a **Buffer**. It prevents us from trying to use a token that expires in the exact same millisecond we send the request.

### JSON Persistence

- **Lines 23-32**: `_load` and `_save`
  - These are internal (private) helper methods. 
  - **Educational Tip**: Notice the `indent=2`. This makes the JSON file "Human Readable." You can actually open the `tokens.json` file on your computer and read your tokens if you want to.

---

## 3. Educational Callouts

> [!CAUTION]
> **Security Note**:
> This project uses a plain JSON file for simplicity. In a high-security production environment, you would use **Encryption-at-Rest** (like AES-256) to ensure that if someone steals your laptop, they can't read your Gmail tokens.

---

## Key References
- [Python Pathlib Module](https://docs.python.org/3/library/pathlib.html)
- [Python Datetime (Timezones)](https://docs.python.org/3/library/datetime.html#timezone-objects)
- [OAuth 2.0 Token Expiration](https://auth0.com/docs/secure/tokens/access-tokens#token-expiration)
