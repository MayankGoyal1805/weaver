from __future__ import annotations

import json
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Any

from app.core.config import get_settings


class OAuthTokenStore:
    """Lightweight local token storage for development workflows.

    This intentionally uses a local JSON file to keep setup simple for local testing.
    Move to encrypted-at-rest DB storage for production use.
    """

    def __init__(self) -> None:
        settings = get_settings()
        self.path = Path(settings.oauth_token_store_path).expanduser().resolve()
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def _load(self) -> dict[str, Any]:
        if not self.path.exists():
            return {"providers": {}}
        try:
            return json.loads(self.path.read_text(encoding="utf-8"))
        except Exception:
            return {"providers": {}}

    def _save(self, payload: dict[str, Any]) -> None:
        self.path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")

    def set_tokens(
        self,
        provider: str,
        token_bundle: dict[str, Any],
        state: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        payload = self._load()
        providers = payload.setdefault("providers", {})

        record: dict[str, Any] = {
            "access_token": token_bundle.get("access_token", ""),
            "refresh_token": token_bundle.get("refresh_token", ""),
            "token_type": token_bundle.get("token_type"),
            "scopes": token_bundle.get("scopes", []),
            "updated_at": datetime.now(UTC).isoformat(),
        }

        expires_in = token_bundle.get("expires_in")
        if isinstance(expires_in, int) and expires_in > 0:
            expires_at = datetime.now(UTC) + timedelta(seconds=max(expires_in - 60, 0))
            record["expires_at"] = expires_at.isoformat()

        if state:
            record["last_state"] = state

        if metadata:
            record["metadata"] = metadata

        providers[provider] = record
        self._save(payload)
        return record

    def get_tokens(self, provider: str) -> dict[str, Any]:
        payload = self._load()
        providers = payload.get("providers", {})
        return providers.get(provider, {})

    def get_status(self, provider: str) -> dict[str, Any]:
        record = self.get_tokens(provider)
        if not record:
            return {"provider": provider, "authenticated": False, "scopes": [], "expires_at": None}

        return {
            "provider": provider,
            "authenticated": bool(record.get("access_token") or record.get("refresh_token")),
            "scopes": record.get("scopes", []),
            "expires_at": record.get("expires_at"),
            "updated_at": record.get("updated_at"),
            "metadata": record.get("metadata", {}),
        }


oauth_token_store = OAuthTokenStore()
