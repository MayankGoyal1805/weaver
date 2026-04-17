from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "dev"
    app_host: str = "0.0.0.0"
    app_port: int = 8000

    app_secret_key: str = "replace_me"
    token_encryption_key: str = "replace_me_32_bytes_min"

    allowed_file_root: str = "/tmp/weaver_sandbox"

    database_url: str = "sqlite+aiosqlite:///./weaver.db"
    redis_url: str = "redis://localhost:6379/0"

    llm_model_name: str = "gpt-4.1-mini"
    llm_api_key: str = ""
    llm_base_url: str = "https://api.openai.com/v1"

    google_client_id: str = ""
    google_client_secret: str = ""
    google_redirect_uri: str = "http://localhost:8000/api/v1/auth/google/callback"
    oauth_token_store_path: str = ".weaver_tokens.json"

    discord_client_id: str = ""
    discord_client_secret: str = ""
    discord_redirect_uri: str = "http://localhost:8000/api/v1/auth/discord/callback"
    discord_bot_token: str = ""

    jwt_access_ttl_minutes: int = 30
    jwt_refresh_ttl_minutes: int = 10080


@lru_cache
def get_settings() -> Settings:
    return Settings()
