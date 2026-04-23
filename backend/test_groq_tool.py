import asyncio
import json
from app.services.llm import llm_service
from app.services.tools import tool_execution_service

async def main():
    tools = []
    for t in tool_execution_service.catalog:
        if t.tool_id == "discord.send_message":
            tools.append({
                "type": "function",
                "function": {
                    "name": t.tool_id.replace(".", "_"),
                    "description": t.description,
                    "parameters": t.input_schema,
                }
            })
    
    out = await llm_service.chat(
        prompt="send a message to discord saying hello",
        model_name="qwen/qwen3-32b",
        tools=tools,
    )
    print(json.dumps(out, indent=2))

asyncio.run(main())
