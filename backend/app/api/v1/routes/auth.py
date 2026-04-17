import secrets

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import RedirectResponse

from app.core.config import get_settings
from app.core.security import create_access_token, create_refresh_token
from app.schemas.auth import LoginIn, TokenPairOut
from app.services.providers.discord.service import discord_service
from app.services.providers.google.service import google_service
from app.services.providers.token_store import oauth_token_store

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/dev-login", response_model=TokenPairOut)
async def dev_login(payload: LoginIn) -> TokenPairOut:
    if "@" not in payload.email:
        raise HTTPException(status_code=400, detail="Valid email required")
    return TokenPairOut(
        access_token=create_access_token(payload.email),
        refresh_token=create_refresh_token(payload.email),
    )


@router.get("/google/connect")
async def google_connect() -> dict:
    state = secrets.token_urlsafe(24)
    return {"auth_url": google_service.build_oauth_url(state=state), "state": state}


@router.get("/google/start")
async def google_start() -> RedirectResponse:
    state = secrets.token_urlsafe(24)
    return RedirectResponse(url=google_service.build_oauth_url(state=state), status_code=307)


@router.get("/google/callback")
async def google_callback(code: str = Query(...), state: str = Query(...)) -> dict:
    token_bundle = await google_service.exchange_code(code)
    profile = {}
    if token_bundle.get("access_token"):
        try:
            profile = await google_service.get_user_info(token_bundle["access_token"])
        except Exception:
            profile = {}

    oauth_token_store.set_tokens(
        "google",
        token_bundle,
        state=state,
        metadata={"profile": profile},
    )
    return {"provider": "google", "state": state, "token_bundle": token_bundle}


@router.get("/google/status")
async def google_status() -> dict:
    return oauth_token_store.get_status("google")


@router.get("/google/userinfo")
async def google_userinfo() -> dict:
    status = oauth_token_store.get_status("google")
    metadata = status.get("metadata", {}) if isinstance(status, dict) else {}
    profile = metadata.get("profile", {}) if isinstance(metadata, dict) else {}
    if status.get("authenticated") and not profile:
        tokens = oauth_token_store.get_tokens("google")
        access_token = tokens.get("access_token", "")
        if access_token:
            try:
                profile = await google_service.get_user_info(access_token)
                oauth_token_store.set_tokens(
                    "google",
                    tokens,
                    metadata={"profile": profile},
                )
            except Exception:
                profile = {}
            if not profile:
                try:
                    profile = await google_service.get_gmail_profile(access_token)
                    oauth_token_store.set_tokens(
                        "google",
                        tokens,
                        metadata={"profile": profile},
                    )
                except Exception:
                    profile = {}
        if not profile:
            refresh_token = tokens.get("refresh_token", "")
            if refresh_token:
                try:
                    refreshed = await google_service.refresh_access_token(refresh_token)
                    merged = {**tokens, **refreshed}
                    oauth_token_store.set_tokens(
                        "google",
                        merged,
                        metadata=metadata if isinstance(metadata, dict) else None,
                    )
                    fresh_access = merged.get("access_token", "")
                    if fresh_access:
                        try:
                            profile = await google_service.get_user_info(fresh_access)
                        except Exception:
                            profile = await google_service.get_gmail_profile(fresh_access)
                        oauth_token_store.set_tokens("google", merged, metadata={"profile": profile})
                except Exception:
                    profile = {}
    return {
        "provider": "google",
        "authenticated": status.get("authenticated", False),
        "profile": profile,
    }


@router.get("/discord/connect")
async def discord_connect() -> dict:
    state = secrets.token_urlsafe(24)
    return {"auth_url": discord_service.build_oauth_url(state=state), "state": state}


@router.get("/discord/start")
async def discord_start() -> RedirectResponse:
    state = secrets.token_urlsafe(24)
    return RedirectResponse(url=discord_service.build_oauth_url(state=state), status_code=307)


@router.get("/discord/callback")
async def discord_callback(code: str = Query(...), state: str = Query(...)) -> dict:
    token_bundle = await discord_service.exchange_code(code)
    profile = {}
    if token_bundle.get("access_token"):
        try:
            profile = await discord_service.get_user_info(token_bundle["access_token"])
        except Exception:
            profile = {}

    oauth_token_store.set_tokens(
        "discord",
        token_bundle,
        state=state,
        metadata={"profile": profile},
    )
    return {"provider": "discord", "state": state, "token_bundle": token_bundle}


@router.get("/discord/status")
async def discord_status() -> dict:
    return oauth_token_store.get_status("discord")


@router.get("/discord/userinfo")
async def discord_userinfo() -> dict:
    status = oauth_token_store.get_status("discord")
    metadata = status.get("metadata", {}) if isinstance(status, dict) else {}
    profile = metadata.get("profile", {}) if isinstance(metadata, dict) else {}
    if status.get("authenticated") and not profile:
        tokens = oauth_token_store.get_tokens("discord")
        access_token = tokens.get("access_token", "")
        if access_token:
            try:
                profile = await discord_service.get_user_info(access_token)
                oauth_token_store.set_tokens(
                    "discord",
                    tokens,
                    metadata={"profile": profile},
                )
            except Exception:
                profile = {}
    return {
        "provider": "discord",
        "authenticated": status.get("authenticated", False),
        "profile": profile,
    }


@router.get("/discord/bot-status")
async def discord_bot_status() -> dict:
    settings = get_settings()
    try:
        identity = await discord_service.get_bot_identity(settings.discord_bot_token)
        return identity
    except Exception as exc:
        return {
            "configured": bool(settings.discord_bot_token),
            "error": str(exc),
        }
