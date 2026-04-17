import secrets

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import RedirectResponse

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
    oauth_token_store.set_tokens("google", token_bundle, state=state)
    return {"provider": "google", "state": state, "token_bundle": token_bundle}


@router.get("/google/status")
async def google_status() -> dict:
    return oauth_token_store.get_status("google")


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
    oauth_token_store.set_tokens("discord", token_bundle, state=state)
    return {"provider": "discord", "state": state, "token_bundle": token_bundle}


@router.get("/discord/status")
async def discord_status() -> dict:
    return oauth_token_store.get_status("discord")
