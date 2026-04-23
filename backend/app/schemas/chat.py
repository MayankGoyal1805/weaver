from pydantic import BaseModel


class ChatIn(BaseModel):
    prompt: str
    system_prompt: str | None = None
    model_name: str | None = None


class ChatOut(BaseModel):
    model_name: str
    content: str | None = None
    raw_response: dict
    tool_calls: list[dict] = []


class AgentPromptIn(BaseModel):
    prompt: str
    system_prompt: str | None = None
    model_name: str | None = None
    llm_api_key: str | None = None
    llm_base_url: str | None = None
    enabled_tool_ids: list[str] = []
    discord_channel_id: str | None = None
    history: list[dict] = []


class AgentToolCallOut(BaseModel):
    tool_id: str
    arguments: dict
    result: dict


class AgentBlockOut(BaseModel):
    block_type: str # "text" or "tool_call"
    text: str | None = None
    tool_call: AgentToolCallOut | None = None


class AgentPromptOut(BaseModel):
    chat: ChatOut | None = None
    chat_error: str | None = None
    tool_calls: list[AgentToolCallOut]
    discord_send: dict | None = None
    blocks: list[AgentBlockOut] = []
