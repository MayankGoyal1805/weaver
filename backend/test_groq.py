import asyncio
from app.services.llm import llm_service
from app.core.config import get_settings

async def main():
    settings = get_settings()
    out = await llm_service.chat(
        prompt="Think step by step and tell me what 2+2 is",
        model_name="qwen/qwen3-32b",
    )
    print(out)

asyncio.run(main())
