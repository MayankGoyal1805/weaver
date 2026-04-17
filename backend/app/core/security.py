from datetime import datetime, timedelta, timezone
from typing import Any

from jose import jwt

from app.core.config import get_settings


ALGORITHM = "HS256"


def create_access_token(subject: str) -> str:
    settings = get_settings()
    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_access_ttl_minutes)
    payload: dict[str, Any] = {"sub": subject, "type": "access", "exp": exp}
    return jwt.encode(payload, settings.app_secret_key, algorithm=ALGORITHM)


def create_refresh_token(subject: str) -> str:
    settings = get_settings()
    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_refresh_ttl_minutes)
    payload: dict[str, Any] = {"sub": subject, "type": "refresh", "exp": exp}
    return jwt.encode(payload, settings.app_secret_key, algorithm=ALGORITHM)
