from fastapi import APIRouter

router = APIRouter(prefix="/automations", tags=["automations"])


@router.get("")
async def list_automations() -> list[dict]:
    # Placeholder endpoint for upcoming n8n-style builder runtime.
    return []
