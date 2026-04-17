from fastapi import APIRouter

from app.api.v1.routes import auth, automations, chat, runs, tools

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth.router)
api_router.include_router(chat.router)
api_router.include_router(tools.router)
api_router.include_router(runs.router)
api_router.include_router(automations.router)
