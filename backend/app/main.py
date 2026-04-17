from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.logging import configure_logging
from app.core.tracing import configure_tracing
from app.services.tools import register_native_handlers

configure_logging()
configure_tracing()
register_native_handlers()

app = FastAPI(title="Weaver Backend", version="0.1.0")
app.include_router(api_router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
