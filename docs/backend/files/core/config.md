# Source Code Guide: `app/core/config.py`

In a production-grade application, you never hardcode secrets or settings. Instead, you use environment variables. This file, `config.py`, is the central source of truth for all configuration in Weaver.

It uses **Pydantic Settings**, a powerful library that ensures your configuration is type-safe. If you expect a port to be an integer but provide a string like "abc", the application will fail to start with a clear error message.

---

## 1. Complete Code

```python
from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


# 1. Dynamic Path Discovery
_BACKEND_ROOT = Path(__file__).resolve().parents[2]
_ENV_FILE = _BACKEND_ROOT / ".env"


class Settings(BaseSettings):
    """
    Main Settings class. Pydantic automatically looks for environment
    variables that match these field names (case-insensitive).
    """
    model_config = SettingsConfigDict(
        env_file=str(_ENV_FILE), 
        env_file_encoding="utf-8", 
        extra="ignore"
    )

    # General App Settings
    app_env: str = "dev"
    app_host: str = "0.0.0.0"
    app_port: int = 8000

    # Security (Crucial for encryption and sessions)
    app_secret_key: str = "replace_me"
    token_encryption_key: str = "replace_me_32_bytes_min"

    # Filesystem Permissions
    allowed_file_root: str = "/tmp/weaver_sandbox"

    # Database & Cache
    database_url: str = "sqlite+aiosqlite:///./weaver.db"
    redis_url: str = "redis://localhost:6379/0"

    # LLM Provider Configuration
    llm_model_name: str = "gpt-4.1-mini"
    llm_api_key: str = ""
    llm_base_url: str = "https://api.openai.com/v1"

    # Google OAuth Credentials
    google_client_id: str = ""
    google_client_secret: str = ""
    google_redirect_uri: str = "http://localhost:8000/api/v1/auth/google/callback"
    oauth_token_store_path: str = ".weaver_tokens.json"

    # Discord OAuth Credentials
    discord_client_id: str = ""
    discord_client_secret: str = ""
    discord_redirect_uri: str = "http://localhost:8000/api/v1/auth/discord/callback"
    discord_bot_token: str = ""

    # JWT (JSON Web Token) Configuration
    jwt_access_ttl_minutes: int = 30
    jwt_refresh_ttl_minutes: int = 10080


@lru_cache
def get_settings() -> Settings:
    """
    Provides a singleton instance of Settings.
    The @lru_cache ensures we only parse the .env file once.
    """
    return Settings()
```

---

## 2. Line-by-Line Deep Dive

### Imports

- **Line 1**: `from functools import lru_cache`
  - **What**: Imports a Least Recently Used (LRU) cache decorator.
  - **Why**: Reading from the disk (the `.env` file) is slow. We use this to cache the result of `get_settings()` so subsequent calls return the already-loaded object instantly.

- **Line 2**: `from pathlib import Path`
  - **What**: Imports the modern object-oriented way to handle file paths.
  - **Why**: `pathlib` is much cleaner than the old `os.path.join` methods. It handles slashes correctly across Windows and Linux.

- **Line 4**: `from pydantic_settings import BaseSettings, SettingsConfigDict`
  - **What**: The core engine of our configuration system.
  - **Why**: `BaseSettings` handles the logic of checking environment variables -> `.env` file -> default values in that specific order.

---

### Path Discovery Logic

- **Line 8**: `_BACKEND_ROOT = Path(__file__).resolve().parents[2]`
  - `__file__`: The path to this current file (`app/core/config.py`).
  - `.resolve()`: Gets the absolute path.
  - `.parents[2]`: Goes up two levels to find the backend root.
- **Line 9**: `_ENV_FILE = _BACKEND_ROOT / ".env"`
  - Uses the `/` operator (overloaded by `Path`) to join paths safely.

---

### The Settings Class

- **Line 12**: `class Settings(BaseSettings):`
  - Any field defined here can be overridden by an environment variable. For example, setting `APP_PORT=9000` in your terminal will override the default `8000`.

- **Lines 17-21**: `model_config`
  - `env_file`: Tells Pydantic where the `.env` file is located.
  - `extra="ignore"`: If you have extra junk in your `.env` file, Pydantic won't crash; it will just ignore it.

---

### Field Explanations

- **`app_host` / `app_port`**: Where the server listens. `0.0.0.0` means "all network interfaces."
- **`app_secret_key`**: Used by FastAPI/Starlette to sign cookies so they can't be tampered with.
- **`token_encryption_key`**: We store Google/Discord tokens in a local JSON file. We encrypt them using this key so a stolen JSON file is useless without the key.
- **`database_url`**: The connection string. We use `sqlite+aiosqlite` for asynchronous SQLite support.
- **`llm_base_url`**: By changing this, you can point Weaver at a local LLM server (like Ollama or vLLM) instead of OpenAI.

---

### The Getter Function

- **Lines 56-62**: `get_settings()`
  - In other files, you don't do `settings = Settings()`. Instead, you do `from app.core.config import get_settings` and then `settings = get_settings()`.
  - This ensures that the entire app shares the **same instance** of the settings, making it easier to manage and test.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Production vs. Development**:
> In development, we use the defaults or the `.env` file. In production (like a Docker container), we usually set these as real Environment Variables in the OS, which Pydantic will pick up with higher priority.

---

## Key References
- [Pydantic Settings: The Gold Standard](https://docs.pydantic.dev/latest/usage/pydantic_settings/)
- [Python Functools: lru_cache](https://docs.python.org/3/library/functools.html#functools.lru_cache)
- [Pathlib Tutorial](https://realpython.com/python-pathlib/)
