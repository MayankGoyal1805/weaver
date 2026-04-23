# Backend Source Reference

This document includes every line from all Python files under backend/app with line numbers.

## backend/app/api/__init__.py

```python
```

## backend/app/api/v1/__init__.py

```python
```

## backend/app/api/v1/router.py

```python
     1	from fastapi import APIRouter
     2	
     3	from app.api.v1.routes import auth, automations, chat, runs, tools
     4	
     5	api_router = APIRouter(prefix="/api/v1")
     6	api_router.include_router(auth.router)
     7	api_router.include_router(chat.router)
     8	api_router.include_router(tools.router)
     9	api_router.include_router(runs.router)
    10	api_router.include_router(automations.router)
```

## backend/app/api/v1/routes/auth.py

```python
     1	import secrets
     2	
     3	from fastapi import APIRouter, HTTPException, Query
     4	from fastapi.responses import RedirectResponse
     5	
     6	from app.core.config import get_settings
     7	from app.core.security import create_access_token, create_refresh_token
     8	from app.schemas.auth import LoginIn, TokenPairOut
     9	from app.services.providers.discord.service import discord_service
    10	from app.services.providers.google.service import google_service
    11	from app.services.providers.token_store import oauth_token_store
    12	
    13	router = APIRouter(prefix="/auth", tags=["auth"])
    14	
    15	
    16	@router.post("/dev-login", response_model=TokenPairOut)
    17	async def dev_login(payload: LoginIn) -> TokenPairOut:
    18	    if "@" not in payload.email:
    19	        raise HTTPException(status_code=400, detail="Valid email required")
    20	    return TokenPairOut(
    21	        access_token=create_access_token(payload.email),
    22	        refresh_token=create_refresh_token(payload.email),
    23	    )
    24	
    25	
    26	@router.get("/google/connect")
    27	async def google_connect() -> dict:
    28	    state = secrets.token_urlsafe(24)
    29	    return {"auth_url": google_service.build_oauth_url(state=state), "state": state}
    30	
    31	
    32	@router.get("/google/start")
    33	async def google_start() -> RedirectResponse:
    34	    state = secrets.token_urlsafe(24)
    35	    return RedirectResponse(url=google_service.build_oauth_url(state=state), status_code=307)
    36	
    37	
    38	@router.get("/google/callback")
    39	async def google_callback(code: str = Query(...), state: str = Query(...)) -> dict:
    40	    token_bundle = await google_service.exchange_code(code)
    41	    profile = {}
    42	    if token_bundle.get("access_token"):
    43	        try:
    44	            profile = await google_service.get_user_info(token_bundle["access_token"])
    45	        except Exception:
    46	            profile = {}
    47	
    48	    oauth_token_store.set_tokens(
    49	        "google",
    50	        token_bundle,
    51	        state=state,
    52	        metadata={"profile": profile},
    53	    )
    54	    return {"provider": "google", "state": state, "token_bundle": token_bundle}
    55	
    56	
    57	@router.get("/google/status")
    58	async def google_status() -> dict:
    59	    return oauth_token_store.get_status("google")
    60	
    61	
    62	@router.get("/google/userinfo")
    63	async def google_userinfo() -> dict:
    64	    status = oauth_token_store.get_status("google")
    65	    metadata = status.get("metadata", {}) if isinstance(status, dict) else {}
    66	    profile = metadata.get("profile", {}) if isinstance(metadata, dict) else {}
    67	    if status.get("authenticated") and not profile:
    68	        tokens = oauth_token_store.get_tokens("google")
    69	        access_token = tokens.get("access_token", "")
    70	        if access_token:
    71	            try:
    72	                profile = await google_service.get_user_info(access_token)
    73	                oauth_token_store.set_tokens(
    74	                    "google",
    75	                    tokens,
    76	                    metadata={"profile": profile},
    77	                )
    78	            except Exception:
    79	                profile = {}
    80	            if not profile:
    81	                try:
    82	                    profile = await google_service.get_gmail_profile(access_token)
    83	                    oauth_token_store.set_tokens(
    84	                        "google",
    85	                        tokens,
    86	                        metadata={"profile": profile},
    87	                    )
    88	                except Exception:
    89	                    profile = {}
    90	        if not profile:
    91	            refresh_token = tokens.get("refresh_token", "")
    92	            if refresh_token:
    93	                try:
    94	                    refreshed = await google_service.refresh_access_token(refresh_token)
    95	                    merged = {**tokens, **refreshed}
    96	                    oauth_token_store.set_tokens(
    97	                        "google",
    98	                        merged,
    99	                        metadata=metadata if isinstance(metadata, dict) else None,
   100	                    )
   101	                    fresh_access = merged.get("access_token", "")
   102	                    if fresh_access:
   103	                        try:
   104	                            profile = await google_service.get_user_info(fresh_access)
   105	                        except Exception:
   106	                            profile = await google_service.get_gmail_profile(fresh_access)
   107	                        oauth_token_store.set_tokens("google", merged, metadata={"profile": profile})
   108	                except Exception:
   109	                    profile = {}
   110	    return {
   111	        "provider": "google",
   112	        "authenticated": status.get("authenticated", False),
   113	        "profile": profile,
   114	    }
   115	
   116	
   117	@router.get("/discord/connect")
   118	async def discord_connect() -> dict:
   119	    state = secrets.token_urlsafe(24)
   120	    return {"auth_url": discord_service.build_oauth_url(state=state), "state": state}
   121	
   122	
   123	@router.get("/discord/start")
   124	async def discord_start() -> RedirectResponse:
   125	    state = secrets.token_urlsafe(24)
   126	    return RedirectResponse(url=discord_service.build_oauth_url(state=state), status_code=307)
   127	
   128	
   129	@router.get("/discord/callback")
   130	async def discord_callback(code: str = Query(...), state: str = Query(...)) -> dict:
   131	    token_bundle = await discord_service.exchange_code(code)
   132	    profile = {}
   133	    if token_bundle.get("access_token"):
   134	        try:
   135	            profile = await discord_service.get_user_info(token_bundle["access_token"])
   136	        except Exception:
   137	            profile = {}
   138	
   139	    oauth_token_store.set_tokens(
   140	        "discord",
   141	        token_bundle,
   142	        state=state,
   143	        metadata={"profile": profile},
   144	    )
   145	    return {"provider": "discord", "state": state, "token_bundle": token_bundle}
   146	
   147	
   148	@router.get("/discord/status")
   149	async def discord_status() -> dict:
   150	    return oauth_token_store.get_status("discord")
   151	
   152	
   153	@router.get("/discord/userinfo")
   154	async def discord_userinfo() -> dict:
   155	    status = oauth_token_store.get_status("discord")
   156	    metadata = status.get("metadata", {}) if isinstance(status, dict) else {}
   157	    profile = metadata.get("profile", {}) if isinstance(metadata, dict) else {}
   158	    if status.get("authenticated") and not profile:
   159	        tokens = oauth_token_store.get_tokens("discord")
   160	        access_token = tokens.get("access_token", "")
   161	        if access_token:
   162	            try:
   163	                profile = await discord_service.get_user_info(access_token)
   164	                oauth_token_store.set_tokens(
   165	                    "discord",
   166	                    tokens,
   167	                    metadata={"profile": profile},
   168	                )
   169	            except Exception:
   170	                profile = {}
   171	    return {
   172	        "provider": "discord",
   173	        "authenticated": status.get("authenticated", False),
   174	        "profile": profile,
   175	    }
   176	
   177	
   178	@router.get("/discord/bot-status")
   179	async def discord_bot_status() -> dict:
   180	    settings = get_settings()
   181	    try:
   182	        identity = await discord_service.get_bot_identity(settings.discord_bot_token)
   183	        return identity
   184	    except Exception as exc:
   185	        return {
   186	            "configured": bool(settings.discord_bot_token),
   187	            "error": str(exc),
   188	        }
```

## backend/app/api/v1/routes/automations.py

```python
     1	from fastapi import APIRouter
     2	
     3	router = APIRouter(prefix="/automations", tags=["automations"])
     4	
     5	
     6	@router.get("")
     7	async def list_automations() -> list[dict]:
     8	    # Placeholder endpoint for upcoming n8n-style builder runtime.
     9	    return []
```

## backend/app/api/v1/routes/chat.py

```python
     1	import re
     2	
     3	from fastapi import APIRouter, HTTPException
     4	
     5	from app.schemas.chat import AgentPromptIn, AgentPromptOut, AgentToolCallOut, ChatIn, ChatOut
     6	from app.services.llm import LLMConfigError, llm_service
     7	from app.services.tools import tool_execution_service
     8	
     9	router = APIRouter(prefix="/chat", tags=["chat"])
    10	
    11	
    12	@router.post("", response_model=ChatOut)
    13	async def chat(payload: ChatIn) -> ChatOut:
    14	    try:
    15	        out = await llm_service.chat(
    16	            prompt=payload.prompt,
    17	            system_prompt=payload.system_prompt,
    18	            model_name=payload.model_name,
    19	        )
    20	    except LLMConfigError as exc:
    21	        raise HTTPException(status_code=400, detail=str(exc)) from exc
    22	    except Exception as exc:
    23	        raise HTTPException(status_code=502, detail=f"LLM request failed: {exc}") from exc
    24	
    25	    return ChatOut(**out)
    26	
    27	
    28	@router.post("/agent", response_model=AgentPromptOut)
    29	async def agent_prompt(payload: AgentPromptIn) -> AgentPromptOut:
    30	    enabled = set(payload.enabled_tool_ids)
    31	    prompt_lower = payload.prompt.lower()
    32	
    33	    has_send_intent = any(x in prompt_lower for x in ["send", "post", "share", "forward", "publish", "notify"])
    34	    mentions_discord_target = any(
    35	        x in prompt_lower for x in ["discord", "channel", "server", "bot", "there", "that channel"]
    36	    )
    37	
    38	    wants_latest_gmail = any(
    39	        x in prompt_lower
    40	        for x in [
    41	            "latest gmail",
    42	            "latest email",
    43	            "last gmail",
    44	            "last email",
    45	            "newest email",
    46	            "check gmail",
    47	            "read gmail",
    48	            "inbox",
    49	        ]
    50	    )
    51	    wants_drive_files = any(
    52	        x in prompt_lower
    53	        for x in [
    54	            "drive files",
    55	            "google drive",
    56	            "list drive",
    57	            "drive folder",
    58	            "show drive",
    59	            "browse drive",
    60	        ]
    61	    )
    62	    wants_discord = "discord" in enabled and (
    63	        any(x in prompt_lower for x in ["discord", "channel", "send to discord", "post to discord"])
    64	        or (has_send_intent and mentions_discord_target)
    65	        or (
    66	            has_send_intent
    67	            and payload.discord_channel_id
    68	            and any(x in prompt_lower for x in ["email", "gmail", "summary", "summarize", "latest"])
    69	        )
    70	    )
    71	
    72	    tool_calls: list[AgentToolCallOut] = []
    73	    latest_email: dict | None = None
    74	    drive_files: dict | None = None
    75	    gmail_error: str | None = None
    76	
    77	    if wants_latest_gmail and "gmail" in enabled:
    78	        out = await tool_execution_service.execute("google.gmail.get_latest_email", {})
    79	        tool_calls.append(AgentToolCallOut(tool_id="google.gmail.get_latest_email", result=out))
    80	        if out.get("status") == "ok":
    81	            latest_email = out.get("result")
    82	        else:
    83	            gmail_error = (
    84	                (out.get("result") or {}).get("payload", {}).get("error")
    85	                or str((out.get("result") or {}).get("payload") or "")
    86	                or "Unknown Gmail tool error"
    87	            )
    88	
    89	    if wants_drive_files and "google-drive" in enabled:
    90	        out = await tool_execution_service.execute("google.drive.list_files", {"page_size": 10})
    91	        tool_calls.append(AgentToolCallOut(tool_id="google.drive.list_files", result=out))
    92	        if out.get("status") == "ok":
    93	            drive_files = out.get("result")
    94	
    95	    llm_system_prompt = payload.system_prompt
    96	    llm_prompt = payload.prompt
    97	    context_chunks: list[str] = []
    98	
    99	    if latest_email is not None:
   100	        context_chunks.append(_compact_email_context(latest_email))
   101	    if drive_files is not None:
   102	        context_chunks.append(_compact_drive_context(drive_files))
   103	
   104	    if context_chunks:
   105	        llm_prompt = payload.prompt + "\n\nTool results:\n" + "\n\n".join(context_chunks)
   106	
   107	    if wants_discord and payload.discord_channel_id and latest_email is not None:
   108	        llm_system_prompt = (
   109	            "Write a concise Discord notification under 900 characters. "
   110	            "Do not include code blocks, setup instructions, or policy text. "
   111	            "Use plain text with sender, subject, and short summary only."
   112	        )
   113	        llm_prompt = (
   114	            "Create a concise Discord message for this Gmail item. "
   115	            "Return message text only.\n\n"
   116	            f"{_compact_email_context(latest_email)}"
   117	        )
   118	
   119	    chat_out: ChatOut | None = None
   120	    chat_error: str | None = None
   121	
   122	    if wants_latest_gmail and latest_email is None and gmail_error is not None:
   123	        if "401" in gmail_error or "unauthorized" in gmail_error.lower():
   124	            chat_error = (
   125	                "Gmail access failed (401 Unauthorized). Please reconnect Google in Settings and try again."
   126	            )
   127	        else:
   128	            chat_error = f"Gmail fetch failed: {gmail_error}"
   129	
   130	        chat_out = ChatOut(
   131	            model_name=payload.model_name or "agent",
   132	            content=chat_error,
   133	            raw_response={"reason": "gmail_fetch_failed"},
   134	        )
   135	        return AgentPromptOut(
   136	            chat=chat_out,
   137	            chat_error=chat_error,
   138	            tool_calls=tool_calls,
   139	            discord_send=None,
   140	        )
   141	
   142	    if has_send_intent and "discord" in enabled and not payload.discord_channel_id:
   143	        chat_error = "Discord send was requested, but no default Discord channel id is configured in Settings."
   144	        chat_out = ChatOut(
   145	            model_name=payload.model_name or "agent",
   146	            content=(
   147	                "Discord send is enabled, but no default channel ID is configured. "
   148	                "Open Settings -> Agent Defaults -> Default Discord Channel ID, save it, then try again."
   149	            ),
   150	            raw_response={"reason": "missing_discord_channel_id"},
   151	        )
   152	        return AgentPromptOut(
   153	            chat=chat_out,
   154	            chat_error=chat_error,
   155	            tool_calls=tool_calls,
   156	            discord_send=None,
   157	        )
   158	
   159	    try:
   160	        out = await llm_service.chat(
   161	            prompt=llm_prompt,
   162	            system_prompt=llm_system_prompt,
   163	            model_name=payload.model_name,
   164	            llm_api_key=payload.llm_api_key,
   165	            llm_base_url=payload.llm_base_url,
   166	            history=payload.history,
   167	        )
   168	        chat_out = ChatOut(**out)
   169	    except LLMConfigError as exc:
   170	        chat_error = str(exc)
   171	    except Exception as exc:
   172	        chat_error = f"LLM request failed: {exc}"
   173	
   174	    discord_send: dict | None = None
   175	    can_send_discord = wants_discord and payload.discord_channel_id and "discord" in enabled
   176	    if wants_latest_gmail and latest_email is None:
   177	        can_send_discord = False
   178	
   179	    if can_send_discord:
   180	        content = (chat_out.content if chat_out else "").strip()
   181	        if not content and latest_email:
   182	            content = _format_email_fallback(latest_email)
   183	        if content:
   184	            content = _discord_safe_content(content)
   185	            send_out = await tool_execution_service.execute(
   186	                "discord.send_message",
   187	                {"channel_id": payload.discord_channel_id, "content": content},
   188	            )
   189	            tool_calls.append(AgentToolCallOut(tool_id="discord.send_message", result=send_out))
   190	            discord_send = send_out
   191	
   192	    return AgentPromptOut(
   193	        chat=chat_out,
   194	        chat_error=chat_error,
   195	        tool_calls=tool_calls,
   196	        discord_send=discord_send,
   197	    )
   198	
   199	
   200	def _discord_safe_content(text: str, max_chars: int = 1900) -> str:
   201	    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL | re.IGNORECASE).strip()
   202	    if len(cleaned) <= max_chars:
   203	        return cleaned
   204	    return cleaned[: max_chars - 3].rstrip() + "..."
   205	
   206	
   207	def _format_email_fallback(email: dict) -> str:
   208	    body = (email.get("body_text") or email.get("snippet") or "").strip()
   209	    if len(body) > 800:
   210	        body = body[:800] + "..."
   211	    return (
   212	        "Latest Gmail received:\n"
   213	        f"From: {email.get('from', '')}\n"
   214	        f"Subject: {email.get('subject', '(no subject)')}\n"
   215	        f"Date: {email.get('date', '')}\n"
   216	        f"Summary: {email.get('snippet', '')}\n"
   217	        f"Body: {body}"
   218	    )
   219	
   220	
   221	def _compact_email_context(email: dict) -> str:
   222	    body = (email.get("body_text") or email.get("snippet") or "").strip()
   223	    if len(body) > 1200:
   224	        body = body[:1200].rstrip() + "..."
   225	    snippet = (email.get("snippet") or "").strip()
   226	    if len(snippet) > 400:
   227	        snippet = snippet[:400].rstrip() + "..."
   228	
   229	    return (
   230	        "Latest Gmail:\n"
   231	        f"From: {email.get('from', '')}\n"
   232	        f"Subject: {email.get('subject', '(no subject)')}\n"
   233	        f"Date: {email.get('date', '')}\n"
   234	        f"Snippet: {snippet}\n"
   235	        f"Body: {body}"
   236	    )
   237	
   238	
   239	def _compact_drive_context(drive_files: dict) -> str:
   240	    files = (drive_files.get("files") or [])[:10]
   241	    lines: list[str] = ["Drive Files:"]
   242	    for item in files:
   243	        name = (item.get("name") or "").strip()
   244	        if len(name) > 140:
   245	            name = name[:140].rstrip() + "..."
   246	        mime = (item.get("mimeType") or "").strip()
   247	        modified = (item.get("modifiedTime") or "").strip()
   248	        lines.append(f"- {name} ({mime}) modified={modified}")
   249	    return "\n".join(lines)
```

## backend/app/api/v1/routes/__init__.py

```python
```

## backend/app/api/v1/routes/runs.py

```python
     1	import asyncio
     2	import json
     3	import uuid
     4	
     5	from fastapi import APIRouter
     6	from fastapi.responses import StreamingResponse
     7	
     8	from app.schemas.runs import RunCreateIn, RunInvokeToolIn
     9	from app.services.orchestration.langgraph.runtime import single_tool_graph
    10	from app.services.tracing.event_bus import trace_event_bus
    11	
    12	router = APIRouter(prefix="/runs", tags=["runs"])
    13	
    14	
    15	@router.post("")
    16	async def create_run(payload: RunCreateIn) -> dict:
    17	    run_id = str(uuid.uuid4())
    18	    return {
    19	        "id": run_id,
    20	        "mode": payload.mode,
    21	        "status": "queued",
    22	        "prompt": payload.prompt,
    23	        "graph_json": {"type": "single_tool_graph"},
    24	    }
    25	
    26	
    27	@router.post("/{run_id}/invoke-tool")
    28	async def invoke_tool_graph(run_id: str, payload: RunInvokeToolIn) -> dict:
    29	    state = {"run_id": run_id, "tool_id": payload.tool_id, "arguments": payload.arguments}
    30	    out = await single_tool_graph.ainvoke(state)
    31	    return out
    32	
    33	
    34	@router.get("/{run_id}/trace")
    35	async def stream_trace(run_id: str) -> StreamingResponse:
    36	    queue = trace_event_bus.subscribe(run_id)
    37	
    38	    async def event_stream():
    39	        try:
    40	            while True:
    41	                message = await asyncio.wait_for(queue.get(), timeout=30)
    42	                yield f"data: {message}\n\n"
    43	        except TimeoutError:
    44	            keepalive = json.dumps({"run_id": run_id, "event_type": "keepalive"})
    45	            yield f"data: {keepalive}\n\n"
    46	        finally:
    47	            trace_event_bus.unsubscribe(run_id, queue)
    48	
    49	    return StreamingResponse(event_stream(), media_type="text/event-stream")
```

## backend/app/api/v1/routes/tools.py

```python
     1	from fastapi import APIRouter, HTTPException
     2	
     3	from app.schemas.tooling import ToolCardStateOut, ToolDefinitionOut, ToolExecuteIn, ToolExecuteOut
     4	from app.services.providers.filesystem.service import filesystem_service
     5	from app.services.providers.token_store import oauth_token_store
     6	from app.services.tools import tool_execution_service
     7	
     8	router = APIRouter(prefix="/tools", tags=["tools"])
     9	
    10	
    11	@router.get("/catalog", response_model=list[ToolDefinitionOut])
    12	async def get_tool_catalog() -> list[ToolDefinitionOut]:
    13	    return [ToolDefinitionOut(**tool.model_dump()) for tool in tool_execution_service.catalog]
    14	
    15	
    16	@router.post("/execute", response_model=ToolExecuteOut)
    17	async def execute_tool(payload: ToolExecuteIn) -> ToolExecuteOut:
    18	    known_tool_ids = {tool.tool_id for tool in tool_execution_service.catalog}
    19	    if payload.tool_id not in known_tool_ids:
    20	        raise HTTPException(status_code=404, detail="Unknown tool_id")
    21	
    22	    result = await tool_execution_service.execute(
    23	        tool_id=payload.tool_id,
    24	        arguments=payload.arguments,
    25	        run_id=payload.run_id,
    26	    )
    27	    return ToolExecuteOut(**result)
    28	
    29	
    30	@router.get("/cards/state", response_model=list[ToolCardStateOut])
    31	async def get_card_states() -> list[ToolCardStateOut]:
    32	    google_status = oauth_token_store.get_status("google")
    33	    discord_status = oauth_token_store.get_status("discord")
    34	
    35	    def _provider_state(status: dict) -> tuple[str, dict]:
    36	        authenticated = bool(status.get("authenticated"))
    37	        metadata = status.get("metadata", {}) if isinstance(status, dict) else {}
    38	        return ("connected" if authenticated else "auth_required", metadata)
    39	
    40	    google_state, google_meta = _provider_state(google_status)
    41	    discord_state, discord_meta = _provider_state(discord_status)
    42	
    43	    return [
    44	        ToolCardStateOut(
    45	            provider="filesystem",
    46	            status="connected",
    47	            scopes=[],
    48	            metadata=filesystem_service.get_allowed_root(),
    49	        ),
    50	        ToolCardStateOut(
    51	            provider="google",
    52	            status=google_state,
    53	            scopes=google_status.get("scopes", []),
    54	            metadata=google_meta,
    55	        ),
    56	        ToolCardStateOut(
    57	            provider="discord",
    58	            status=discord_state,
    59	            scopes=discord_status.get("scopes", []),
    60	            metadata=discord_meta,
    61	        ),
    62	    ]
    63	
    64	
    65	@router.get("/filesystem/root")
    66	async def get_filesystem_root() -> dict:
    67	    return filesystem_service.get_allowed_root()
    68	
    69	
    70	@router.post("/filesystem/root")
    71	async def set_filesystem_root(payload: dict) -> dict:
    72	    root_path = (payload.get("allowed_root") or "").strip()
    73	    if not root_path:
    74	        raise HTTPException(status_code=400, detail="allowed_root is required")
    75	    return filesystem_service.set_allowed_root(root_path)
```

## backend/app/cli.py

```python
     1	import argparse
     2	import json
     3	import re
     4	import subprocess
     5	import sys
     6	import time
     7	from pathlib import Path
     8	from urllib.parse import urlparse
     9	import webbrowser
    10	
    11	import httpx
    12	import uvicorn
    13	
    14	
    15	DEFAULT_BASE_URL = "http://127.0.0.1:8000"
    16	
    17	
    18	def _build_parser() -> argparse.ArgumentParser:
    19	    parser = argparse.ArgumentParser(description="Weaver backend local CLI")
    20	    sub = parser.add_subparsers(dest="command", required=True)
    21	
    22	    runserver = sub.add_parser("runserver", help="Run local FastAPI server")
    23	    runserver.add_argument("--host", default="0.0.0.0")
    24	    runserver.add_argument("--port", type=int, default=8000)
    25	
    26	    health = sub.add_parser("health", help="Check backend health")
    27	    health.add_argument("--base-url", default=DEFAULT_BASE_URL)
    28	    health.add_argument("--no-auto-start", action="store_true")
    29	
    30	    chat = sub.add_parser("chat", help="Send prompt to /api/v1/chat")
    31	    chat.add_argument("prompt")
    32	    chat.add_argument("--base-url", default=DEFAULT_BASE_URL)
    33	    chat.add_argument("--no-auto-start", action="store_true")
    34	    chat.add_argument("--system-prompt", default=None)
    35	    chat.add_argument("--model-name", default=None)
    36	    chat.add_argument("--allow-tools", action="store_true")
    37	    chat.add_argument("--discord-channel-id", default=None)
    38	
    39	    prompt = sub.add_parser("prompt", help="Alias of chat; quick prompt test")
    40	    prompt.add_argument("prompt")
    41	    prompt.add_argument("--base-url", default=DEFAULT_BASE_URL)
    42	    prompt.add_argument("--no-auto-start", action="store_true")
    43	    prompt.add_argument("--system-prompt", default=None)
    44	    prompt.add_argument("--model-name", default=None)
    45	    prompt.add_argument("--allow-tools", action="store_true")
    46	    prompt.add_argument("--discord-channel-id", default=None)
    47	
    48	    catalog = sub.add_parser("catalog", help="List tool catalog")
    49	    catalog.add_argument("--base-url", default=DEFAULT_BASE_URL)
    50	    catalog.add_argument("--no-auto-start", action="store_true")
    51	
    52	    execute = sub.add_parser("execute-tool", help="Execute a tool")
    53	    execute.add_argument("tool_id")
    54	    execute.add_argument("--arguments-json", default="{}")
    55	    execute.add_argument("--run-id", default=None)
    56	    execute.add_argument("--base-url", default=DEFAULT_BASE_URL)
    57	    execute.add_argument("--no-auto-start", action="store_true")
    58	
    59	    auth_google = sub.add_parser("auth-google", help="Authenticate Google OAuth in browser")
    60	    auth_google.add_argument("--base-url", default=DEFAULT_BASE_URL)
    61	    auth_google.add_argument("--no-auto-start", action="store_true")
    62	    auth_google.add_argument("--no-open", action="store_true")
    63	    auth_google.add_argument("--timeout-seconds", type=int, default=180)
    64	
    65	    auth_discord = sub.add_parser("auth-discord", help="Authenticate Discord OAuth in browser")
    66	    auth_discord.add_argument("--base-url", default=DEFAULT_BASE_URL)
    67	    auth_discord.add_argument("--no-auto-start", action="store_true")
    68	    auth_discord.add_argument("--no-open", action="store_true")
    69	    auth_discord.add_argument("--timeout-seconds", type=int, default=180)
    70	
    71	    google_drive = sub.add_parser(
    72	        "google-drive",
    73	        aliases=["google_drive"],
    74	        help="Google Drive provider helper commands",
    75	    )
    76	    google_drive_sub = google_drive.add_subparsers(dest="google_drive_command", required=True)
    77	    google_drive_auth = google_drive_sub.add_parser("auth", help="Authenticate Google OAuth for Drive/Gmail")
    78	    google_drive_auth.add_argument("--base-url", default=DEFAULT_BASE_URL)
    79	    google_drive_auth.add_argument("--no-auto-start", action="store_true")
    80	    google_drive_auth.add_argument("--no-open", action="store_true")
    81	    google_drive_auth.add_argument("--timeout-seconds", type=int, default=180)
    82	    google_drive_status = google_drive_sub.add_parser("status", help="Show Google OAuth status")
    83	    google_drive_status.add_argument("--base-url", default=DEFAULT_BASE_URL)
    84	    google_drive_status.add_argument("--no-auto-start", action="store_true")
    85	
    86	    gmail_to_discord = sub.add_parser(
    87	        "gmail-to-discord",
    88	        help="Send latest Gmail message to a Discord channel",
    89	    )
    90	    gmail_to_discord.add_argument("--channel-id", required=True)
    91	    gmail_to_discord.add_argument("--base-url", default=DEFAULT_BASE_URL)
    92	    gmail_to_discord.add_argument("--no-auto-start", action="store_true")
    93	    gmail_to_discord.add_argument("--format-with-llm", action="store_true")
    94	
    95	    discord_send = sub.add_parser("discord-send", help="Send a test message to a Discord channel")
    96	    discord_send.add_argument("--channel-id", required=True)
    97	    discord_send.add_argument("--message", required=True)
    98	    discord_send.add_argument("--base-url", default=DEFAULT_BASE_URL)
    99	    discord_send.add_argument("--no-auto-start", action="store_true")
   100	
   101	    return parser
   102	
   103	
   104	def _request_json(method: str, url: str, payload: dict | None = None) -> dict:
   105	    with httpx.Client(timeout=60.0) as client:
   106	        response = client.request(method, url, json=payload)
   107	        if response.is_error:
   108	            detail = response.text
   109	            raise RuntimeError(f"HTTP {response.status_code} from {url}: {detail}")
   110	        return response.json()
   111	
   112	
   113	def _is_server_healthy(base_url: str) -> bool:
   114	    try:
   115	        _request_json("GET", f"{base_url.rstrip('/')}/health")
   116	        return True
   117	    except Exception:
   118	        return False
   119	
   120	
   121	def _start_local_server(base_url: str) -> subprocess.Popen | None:
   122	    parsed = urlparse(base_url)
   123	    host = parsed.hostname
   124	    port = parsed.port or 8000
   125	    if host not in {"127.0.0.1", "localhost"}:
   126	        raise RuntimeError(
   127	            "Server is not reachable and auto-start is only supported for localhost/127.0.0.1. "
   128	            "Start your remote server manually."
   129	        )
   130	
   131	    backend_root = Path(__file__).resolve().parents[1]
   132	    command = [
   133	        sys.executable,
   134	        "-m",
   135	        "uvicorn",
   136	        "app.main:app",
   137	        "--host",
   138	        host,
   139	        "--port",
   140	        str(port),
   141	    ]
   142	    process = subprocess.Popen(command, cwd=str(backend_root))
   143	
   144	    for _ in range(40):
   145	        if process.poll() is not None:
   146	            raise RuntimeError("Auto-started server exited unexpectedly.")
   147	        if _is_server_healthy(base_url):
   148	            print(f"Auto-started backend server at {base_url}")
   149	            return process
   150	        time.sleep(0.25)
   151	
   152	    process.terminate()
   153	    raise RuntimeError("Timed out waiting for auto-started backend server to become healthy.")
   154	
   155	
   156	def _ensure_server(base_url: str, no_auto_start: bool) -> subprocess.Popen | None:
   157	    if _is_server_healthy(base_url):
   158	        return None
   159	
   160	    if no_auto_start:
   161	        raise RuntimeError(
   162	            "Backend server is not reachable. Run weaver-cli runserver or remove --no-auto-start."
   163	        )
   164	
   165	    return _start_local_server(base_url)
   166	
   167	
   168	def _stop_server(process: subprocess.Popen | None) -> None:
   169	    if process is None:
   170	        return
   171	    process.terminate()
   172	    try:
   173	        process.wait(timeout=5)
   174	    except Exception:
   175	        process.kill()
   176	
   177	
   178	def _run_browser_auth(provider: str, base_url: str, no_open: bool, timeout_seconds: int) -> int:
   179	    start_url = f"{base_url.rstrip('/')}/api/v1/auth/{provider}/start"
   180	    status_url = f"{base_url.rstrip('/')}/api/v1/auth/{provider}/status"
   181	
   182	    print(f"Open this URL to authenticate {provider}: {start_url}")
   183	    if not no_open:
   184	        webbrowser.open(start_url)
   185	
   186	    deadline = time.time() + timeout_seconds
   187	    while time.time() < deadline:
   188	        try:
   189	            status = _request_json("GET", status_url)
   190	        except Exception:
   191	            time.sleep(1)
   192	            continue
   193	
   194	        if status.get("authenticated"):
   195	            print(json.dumps(status, indent=2))
   196	            print(f"{provider} auth completed.")
   197	            return 0
   198	        time.sleep(2)
   199	
   200	    print(f"Timed out waiting for {provider} auth completion.", file=sys.stderr)
   201	    return 1
   202	
   203	
   204	def _format_latest_email_message(email: dict) -> str:
   205	    if not email.get("found"):
   206	        return "No recent email found in inbox."
   207	
   208	    body = (email.get("body_text") or email.get("snippet") or "").strip()
   209	    if len(body) > 800:
   210	        body = body[:800] + "..."
   211	
   212	    return (
   213	        "Latest Gmail received:\n"
   214	        f"From: {email.get('from', '')}\n"
   215	        f"Subject: {email.get('subject', '(no subject)')}\n"
   216	        f"Date: {email.get('date', '')}\n"
   217	        f"Summary: {email.get('snippet', '')}\n"
   218	        f"Body: {body}"
   219	    )
   220	
   221	
   222	def _discord_safe_content(text: str, max_chars: int = 1900) -> str:
   223	    # Some reasoning-capable models may include <think> blocks that bloat payloads.
   224	    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL | re.IGNORECASE).strip()
   225	    if len(cleaned) <= max_chars:
   226	        return cleaned
   227	    return cleaned[: max_chars - 3].rstrip() + "..."
   228	
   229	
   230	def _execute_tool(base_url: str, tool_id: str, arguments: dict) -> dict:
   231	    return _request_json(
   232	        "POST",
   233	        f"{base_url.rstrip('/')}/api/v1/tools/execute",
   234	        {"tool_id": tool_id, "arguments": arguments},
   235	    )
   236	
   237	
   238	def _tool_intent(prompt: str) -> dict:
   239	    p = prompt.lower()
   240	    wants_latest_gmail = any(x in p for x in ["latest gmail", "latest email", "last gmail", "last email"])
   241	    wants_discord = "discord" in p or "channel" in p
   242	    return {"gmail_latest": wants_latest_gmail, "discord": wants_discord}
   243	
   244	
   245	def _tool_aware_prompt(
   246	    *,
   247	    base_url: str,
   248	    prompt: str,
   249	    system_prompt: str | None,
   250	    model_name: str | None,
   251	    discord_channel_id: str | None,
   252	) -> dict:
   253	    intent = _tool_intent(prompt)
   254	    tool_calls: list[dict] = []
   255	    latest_email: dict | None = None
   256	    chat_error: str | None = None
   257	
   258	    if intent["gmail_latest"]:
   259	        gmail_out = _execute_tool(base_url, "google.gmail.get_latest_email", {})
   260	        tool_calls.append({"tool_id": "google.gmail.get_latest_email", "result": gmail_out})
   261	        latest_email = gmail_out.get("result", {})
   262	
   263	    tool_context = ""
   264	    if latest_email is not None:
   265	        tool_context = "\n\nTool result for latest gmail:\n" + json.dumps(latest_email, ensure_ascii=False)
   266	
   267	    chat_out: dict = {}
   268	    llm_prompt = prompt + tool_context
   269	    llm_system_prompt = system_prompt
   270	    if intent["gmail_latest"] and intent["discord"] and latest_email is not None:
   271	        llm_system_prompt = (
   272	            "Write a concise Discord notification under 900 characters. "
   273	            "Do not include code blocks, setup instructions, or policy text. "
   274	            "Use plain text with sender, subject, and short summary only."
   275	        )
   276	        llm_prompt = (
   277	            "Create a concise Discord message for this latest Gmail item. "
   278	            "Return message text only.\n\n"
   279	            f"{json.dumps(latest_email, ensure_ascii=False)}"
   280	        )
   281	
   282	    try:
   283	        chat_out = _request_json(
   284	            "POST",
   285	            f"{base_url.rstrip('/')}/api/v1/chat",
   286	            {
   287	                "prompt": llm_prompt,
   288	                "system_prompt": llm_system_prompt,
   289	                "model_name": model_name,
   290	            },
   291	        )
   292	    except Exception as exc:
   293	        chat_error = str(exc)
   294	
   295	    discord_send: dict | None = None
   296	    if intent["discord"] and discord_channel_id:
   297	        content = (chat_out.get("content") or "").strip()
   298	        if not content and latest_email is not None:
   299	            content = _format_latest_email_message(latest_email)
   300	        if not content:
   301	            content = "Requested Discord message could not be generated from prompt."
   302	        content = _discord_safe_content(content)
   303	
   304	        send_out = _execute_tool(
   305	            base_url,
   306	            "discord.send_message",
   307	            {"channel_id": discord_channel_id, "content": content},
   308	        )
   309	        tool_calls.append({"tool_id": "discord.send_message", "result": send_out})
   310	        discord_send = send_out
   311	
   312	    return {
   313	        "intent": intent,
   314	        "chat": chat_out,
   315	        "chat_error": chat_error,
   316	        "tool_calls": tool_calls,
   317	        "discord_send": discord_send,
   318	    }
   319	
   320	
   321	def main() -> int:
   322	    parser = _build_parser()
   323	    args = parser.parse_args()
   324	
   325	    if args.command == "runserver":
   326	        uvicorn.run("app.main:app", host=args.host, port=args.port, reload=False)
   327	        return 0
   328	
   329	    if args.command == "health":
   330	        proc = None
   331	        try:
   332	            proc = _ensure_server(args.base_url, args.no_auto_start)
   333	            data = _request_json("GET", f"{args.base_url.rstrip('/')}/health")
   334	        except Exception as exc:
   335	            print(str(exc), file=sys.stderr)
   336	            return 1
   337	        finally:
   338	            _stop_server(proc)
   339	        print(json.dumps(data, indent=2))
   340	        return 0
   341	
   342	    if args.command in {"chat", "prompt"}:
   343	        proc = None
   344	        payload = {
   345	            "prompt": args.prompt,
   346	            "system_prompt": args.system_prompt,
   347	            "model_name": args.model_name,
   348	        }
   349	        try:
   350	            proc = _ensure_server(args.base_url, args.no_auto_start)
   351	            if args.allow_tools:
   352	                data = _tool_aware_prompt(
   353	                    base_url=args.base_url,
   354	                    prompt=args.prompt,
   355	                    system_prompt=args.system_prompt,
   356	                    model_name=args.model_name,
   357	                    discord_channel_id=args.discord_channel_id,
   358	                )
   359	            else:
   360	                data = _request_json("POST", f"{args.base_url.rstrip('/')}/api/v1/chat", payload)
   361	        except Exception as exc:
   362	            print(str(exc), file=sys.stderr)
   363	            return 1
   364	        finally:
   365	            _stop_server(proc)
   366	        print(json.dumps(data, indent=2))
   367	        return 0
   368	
   369	    if args.command == "catalog":
   370	        proc = None
   371	        try:
   372	            proc = _ensure_server(args.base_url, args.no_auto_start)
   373	            data = _request_json("GET", f"{args.base_url.rstrip('/')}/api/v1/tools/catalog")
   374	        except Exception as exc:
   375	            print(str(exc), file=sys.stderr)
   376	            return 1
   377	        finally:
   378	            _stop_server(proc)
   379	        print(json.dumps(data, indent=2))
   380	        return 0
   381	
   382	    if args.command == "execute-tool":
   383	        try:
   384	            args_obj = json.loads(args.arguments_json)
   385	            if not isinstance(args_obj, dict):
   386	                raise ValueError("arguments-json must decode to a JSON object")
   387	        except Exception as exc:
   388	            print(f"Invalid --arguments-json: {exc}", file=sys.stderr)
   389	            return 2
   390	
   391	        payload = {"run_id": args.run_id, "tool_id": args.tool_id, "arguments": args_obj}
   392	        proc = None
   393	        try:
   394	            proc = _ensure_server(args.base_url, args.no_auto_start)
   395	            data = _request_json("POST", f"{args.base_url.rstrip('/')}/api/v1/tools/execute", payload)
   396	        except Exception as exc:
   397	            print(str(exc), file=sys.stderr)
   398	            return 1
   399	        finally:
   400	            _stop_server(proc)
   401	        print(json.dumps(data, indent=2))
   402	        return 0
   403	
   404	    if args.command == "auth-google":
   405	        proc = None
   406	        try:
   407	            proc = _ensure_server(args.base_url, args.no_auto_start)
   408	            return _run_browser_auth("google", args.base_url, args.no_open, args.timeout_seconds)
   409	        except Exception as exc:
   410	            print(str(exc), file=sys.stderr)
   411	            return 1
   412	        finally:
   413	            _stop_server(proc)
   414	
   415	    if args.command == "auth-discord":
   416	        proc = None
   417	        try:
   418	            proc = _ensure_server(args.base_url, args.no_auto_start)
   419	            return _run_browser_auth("discord", args.base_url, args.no_open, args.timeout_seconds)
   420	        except Exception as exc:
   421	            print(str(exc), file=sys.stderr)
   422	            return 1
   423	        finally:
   424	            _stop_server(proc)
   425	
   426	    if args.command in {"google-drive", "google_drive"}:
   427	        if args.google_drive_command == "auth":
   428	            proc = None
   429	            try:
   430	                proc = _ensure_server(args.base_url, args.no_auto_start)
   431	                return _run_browser_auth("google", args.base_url, args.no_open, args.timeout_seconds)
   432	            except Exception as exc:
   433	                print(str(exc), file=sys.stderr)
   434	                return 1
   435	            finally:
   436	                _stop_server(proc)
   437	
   438	        if args.google_drive_command == "status":
   439	            proc = None
   440	            try:
   441	                proc = _ensure_server(args.base_url, args.no_auto_start)
   442	                data = _request_json("GET", f"{args.base_url.rstrip('/')}/api/v1/auth/google/status")
   443	            except Exception as exc:
   444	                print(str(exc), file=sys.stderr)
   445	                return 1
   446	            finally:
   447	                _stop_server(proc)
   448	            print(json.dumps(data, indent=2))
   449	            return 0
   450	
   451	    if args.command == "gmail-to-discord":
   452	        proc = None
   453	        try:
   454	            proc = _ensure_server(args.base_url, args.no_auto_start)
   455	            email_tool = _request_json(
   456	                "POST",
   457	                f"{args.base_url.rstrip('/')}/api/v1/tools/execute",
   458	                {"tool_id": "google.gmail.get_latest_email", "arguments": {}},
   459	            )
   460	            email_result = email_tool.get("result", {})
   461	            message_content = _format_latest_email_message(email_result)
   462	
   463	            if args.format_with_llm:
   464	                chat = _request_json(
   465	                    "POST",
   466	                    f"{args.base_url.rstrip('/')}/api/v1/chat",
   467	                    {
   468	                        "system_prompt": "You rewrite notifications for Discord.",
   469	                        "prompt": (
   470	                            "Rewrite the following email notification into a concise Discord message "
   471	                            "under 1200 characters. Keep sender, subject, and key context.\n\n"
   472	                            + message_content
   473	                        ),
   474	                    },
   475	                )
   476	                message_content = (chat.get("content") or message_content).strip()
   477	
   478	            message_content = _discord_safe_content(message_content)
   479	
   480	            send_tool = _request_json(
   481	                "POST",
   482	                f"{args.base_url.rstrip('/')}/api/v1/tools/execute",
   483	                {
   484	                    "tool_id": "discord.send_message",
   485	                    "arguments": {"channel_id": args.channel_id, "content": message_content},
   486	                },
   487	            )
   488	        except Exception as exc:
   489	            print(str(exc), file=sys.stderr)
   490	            return 1
   491	        finally:
   492	            _stop_server(proc)
   493	
   494	        print(json.dumps({"latest_email": email_result, "discord_send": send_tool}, indent=2))
   495	        return 0
   496	
   497	    if args.command == "discord-send":
   498	        proc = None
   499	        try:
   500	            proc = _ensure_server(args.base_url, args.no_auto_start)
   501	            out = _execute_tool(
   502	                args.base_url,
   503	                "discord.send_message",
   504	                {"channel_id": args.channel_id, "content": args.message},
   505	            )
   506	        except Exception as exc:
   507	            print(str(exc), file=sys.stderr)
   508	            return 1
   509	        finally:
   510	            _stop_server(proc)
   511	
   512	        print(json.dumps(out, indent=2))
   513	        return 0
   514	
   515	    parser.print_help()
   516	    return 1
   517	
   518	
   519	if __name__ == "__main__":
   520	    raise SystemExit(main())
```

## backend/app/core/config.py

```python
     1	from functools import lru_cache
     2	from pathlib import Path
     3	
     4	from pydantic_settings import BaseSettings, SettingsConfigDict
     5	
     6	
     7	_BACKEND_ROOT = Path(__file__).resolve().parents[2]
     8	_ENV_FILE = _BACKEND_ROOT / ".env"
     9	
    10	
    11	class Settings(BaseSettings):
    12	    model_config = SettingsConfigDict(env_file=str(_ENV_FILE), env_file_encoding="utf-8", extra="ignore")
    13	
    14	    app_env: str = "dev"
    15	    app_host: str = "0.0.0.0"
    16	    app_port: int = 8000
    17	
    18	    app_secret_key: str = "replace_me"
    19	    token_encryption_key: str = "replace_me_32_bytes_min"
    20	
    21	    allowed_file_root: str = "/tmp/weaver_sandbox"
    22	
    23	    database_url: str = "sqlite+aiosqlite:///./weaver.db"
    24	    redis_url: str = "redis://localhost:6379/0"
    25	
    26	    llm_model_name: str = "gpt-4.1-mini"
    27	    llm_api_key: str = ""
    28	    llm_base_url: str = "https://api.openai.com/v1"
    29	
    30	    google_client_id: str = ""
    31	    google_client_secret: str = ""
    32	    google_redirect_uri: str = "http://localhost:8000/api/v1/auth/google/callback"
    33	    oauth_token_store_path: str = ".weaver_tokens.json"
    34	
    35	    discord_client_id: str = ""
    36	    discord_client_secret: str = ""
    37	    discord_redirect_uri: str = "http://localhost:8000/api/v1/auth/discord/callback"
    38	    discord_bot_token: str = ""
    39	
    40	    jwt_access_ttl_minutes: int = 30
    41	    jwt_refresh_ttl_minutes: int = 10080
    42	
    43	
    44	@lru_cache
    45	def get_settings() -> Settings:
    46	    return Settings()
```

## backend/app/core/__init__.py

```python
```

## backend/app/core/logging.py

```python
     1	import logging
     2	
     3	import structlog
     4	
     5	
     6	def configure_logging() -> None:
     7	    logging.basicConfig(level=logging.INFO, format="%(message)s")
     8	    structlog.configure(
     9	        processors=[
    10	            structlog.processors.TimeStamper(fmt="iso"),
    11	            structlog.processors.add_log_level,
    12	            structlog.processors.JSONRenderer(),
    13	        ],
    14	        logger_factory=structlog.stdlib.LoggerFactory(),
    15	        wrapper_class=structlog.stdlib.BoundLogger,
    16	        cache_logger_on_first_use=True,
    17	    )
```

## backend/app/core/security.py

```python
     1	from datetime import datetime, timedelta, timezone
     2	from typing import Any
     3	
     4	from jose import jwt
     5	
     6	from app.core.config import get_settings
     7	
     8	
     9	ALGORITHM = "HS256"
    10	
    11	
    12	def create_access_token(subject: str) -> str:
    13	    settings = get_settings()
    14	    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_access_ttl_minutes)
    15	    payload: dict[str, Any] = {"sub": subject, "type": "access", "exp": exp}
    16	    return jwt.encode(payload, settings.app_secret_key, algorithm=ALGORITHM)
    17	
    18	
    19	def create_refresh_token(subject: str) -> str:
    20	    settings = get_settings()
    21	    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_refresh_ttl_minutes)
    22	    payload: dict[str, Any] = {"sub": subject, "type": "refresh", "exp": exp}
    23	    return jwt.encode(payload, settings.app_secret_key, algorithm=ALGORITHM)
```

## backend/app/core/tracing.py

```python
     1	from opentelemetry import trace
     2	from opentelemetry.sdk.resources import Resource
     3	from opentelemetry.sdk.trace import TracerProvider
     4	from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
     5	
     6	
     7	TRACER_NAME = "weaver-backend"
     8	
     9	
    10	def configure_tracing() -> None:
    11	    provider = TracerProvider(resource=Resource.create({"service.name": TRACER_NAME}))
    12	    provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
    13	    trace.set_tracer_provider(provider)
    14	
    15	
    16	def get_tracer():
    17	    return trace.get_tracer(TRACER_NAME)
```

## backend/app/db/base.py

```python
     1	from sqlalchemy.orm import DeclarativeBase
     2	
     3	
     4	class Base(DeclarativeBase):
     5	    pass
```

## backend/app/db/__init__.py

```python
```

## backend/app/db/migrations/env.py

```python
     1	from logging.config import fileConfig
     2	
     3	from alembic import context
     4	from sqlalchemy import engine_from_config, pool
     5	
     6	from app.core.config import get_settings
     7	from app.db.base import Base
     8	from app.db.models import run, tool, user  # noqa: F401
     9	
    10	config = context.config
    11	settings = get_settings()
    12	
    13	
    14	def _to_sync_database_url(database_url: str) -> str:
    15	    if "+asyncpg" in database_url:
    16	        return database_url.replace("+asyncpg", "+psycopg")
    17	    if "+aiosqlite" in database_url:
    18	        return database_url.replace("+aiosqlite", "")
    19	    return database_url
    20	
    21	
    22	sync_database_url = _to_sync_database_url(settings.database_url)
    23	config.set_main_option("sqlalchemy.url", sync_database_url)
    24	
    25	if config.config_file_name is not None:
    26	    fileConfig(config.config_file_name)
    27	
    28	target_metadata = Base.metadata
    29	
    30	
    31	def run_migrations_offline() -> None:
    32	    url = config.get_main_option("sqlalchemy.url")
    33	    context.configure(url=url, target_metadata=target_metadata, literal_binds=True)
    34	
    35	    with context.begin_transaction():
    36	        context.run_migrations()
    37	
    38	
    39	def run_migrations_online() -> None:
    40	    connectable = engine_from_config(
    41	        config.get_section(config.config_ini_section, {}),
    42	        prefix="sqlalchemy.",
    43	        poolclass=pool.NullPool,
    44	    )
    45	
    46	    with connectable.connect() as connection:
    47	        context.configure(connection=connection, target_metadata=target_metadata)
    48	
    49	        with context.begin_transaction():
    50	            context.run_migrations()
    51	
    52	
    53	if context.is_offline_mode():
    54	    run_migrations_offline()
    55	else:
    56	    run_migrations_online()
```

## backend/app/db/migrations/versions/0001_initial.py

```python
     1	"""initial schema
     2	
     3	Revision ID: 0001_initial
     4	Revises: None
     5	Create Date: 2026-04-17 00:00:00
     6	"""
     7	
     8	from typing import Sequence, Union
     9	
    10	from alembic import op
    11	import sqlalchemy as sa
    12	
    13	
    14	revision: str = "0001_initial"
    15	down_revision: Union[str, None] = None
    16	branch_labels: Union[str, Sequence[str], None] = None
    17	depends_on: Union[str, Sequence[str], None] = None
    18	
    19	
    20	def upgrade() -> None:
    21	    op.create_table(
    22	        "users",
    23	        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
    24	        sa.Column("email", sa.String(length=320), nullable=False, unique=True),
    25	        sa.Column("display_name", sa.String(length=120), nullable=True),
    26	        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    27	    )
    28	
    29	    op.create_table(
    30	        "tool_definitions",
    31	        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
    32	        sa.Column("tool_id", sa.String(length=200), nullable=False, unique=True),
    33	        sa.Column("display_name", sa.String(length=200), nullable=False),
    34	        sa.Column("provider", sa.String(length=80), nullable=False),
    35	        sa.Column("auth_type", sa.String(length=40), nullable=False),
    36	        sa.Column("capabilities", sa.JSON(), nullable=False),
    37	        sa.Column("required_scopes", sa.JSON(), nullable=False),
    38	        sa.Column("input_schema", sa.JSON(), nullable=False),
    39	        sa.Column("output_schema", sa.JSON(), nullable=False),
    40	        sa.Column("is_side_effecting", sa.Boolean(), nullable=False, server_default=sa.text("false")),
    41	        sa.Column("description", sa.Text(), nullable=True),
    42	        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    43	    )
    44	
    45	    op.create_table(
    46	        "tool_connections",
    47	        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
    48	        sa.Column("user_id", sa.String(length=36), nullable=False),
    49	        sa.Column("provider", sa.String(length=80), nullable=False),
    50	        sa.Column("status", sa.String(length=40), nullable=False, server_default="auth_required"),
    51	        sa.Column("encrypted_access_token", sa.Text(), nullable=True),
    52	        sa.Column("encrypted_refresh_token", sa.Text(), nullable=True),
    53	        sa.Column("scopes", sa.JSON(), nullable=False),
    54	        sa.Column("metadata_json", sa.JSON(), nullable=False),
    55	        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    56	    )
    57	
    58	    op.create_table(
    59	        "runs",
    60	        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
    61	        sa.Column("user_id", sa.String(length=36), nullable=False),
    62	        sa.Column("mode", sa.String(length=20), nullable=False),
    63	        sa.Column("status", sa.String(length=30), nullable=False, server_default="queued"),
    64	        sa.Column("prompt", sa.Text(), nullable=True),
    65	        sa.Column("graph_json", sa.JSON(), nullable=False),
    66	        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    67	    )
    68	
    69	    op.create_table(
    70	        "tool_call_events",
    71	        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
    72	        sa.Column("run_id", sa.String(length=36), nullable=False),
    73	        sa.Column("tool_id", sa.String(length=200), nullable=False),
    74	        sa.Column("event_type", sa.String(length=60), nullable=False),
    75	        sa.Column("payload", sa.JSON(), nullable=False),
    76	        sa.Column("status", sa.String(length=30), nullable=False, server_default="ok"),
    77	        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    78	    )
    79	
    80	    op.create_index("ix_tool_connections_user_provider", "tool_connections", ["user_id", "provider"], unique=False)
    81	    op.create_index("ix_tool_call_events_run_id", "tool_call_events", ["run_id"], unique=False)
    82	
    83	
    84	def downgrade() -> None:
    85	    op.drop_index("ix_tool_call_events_run_id", table_name="tool_call_events")
    86	    op.drop_index("ix_tool_connections_user_provider", table_name="tool_connections")
    87	    op.drop_table("tool_call_events")
    88	    op.drop_table("runs")
    89	    op.drop_table("tool_connections")
    90	    op.drop_table("tool_definitions")
    91	    op.drop_table("users")
```

## backend/app/db/models/__init__.py

```python
     1	from app.db.models.run import Run, ToolCallEvent
     2	from app.db.models.tool import ToolConnection, ToolDefinition
     3	from app.db.models.user import User
     4	
     5	__all__ = [
     6	    "Run",
     7	    "ToolCallEvent",
     8	    "ToolConnection",
     9	    "ToolDefinition",
    10	    "User",
    11	]
```

## backend/app/db/models/run.py

```python
     1	import uuid
     2	from datetime import datetime
     3	
     4	from sqlalchemy import JSON, DateTime, String, Text, func
     5	from sqlalchemy.orm import Mapped, mapped_column
     6	
     7	from app.db.base import Base
     8	
     9	
    10	class Run(Base):
    11	    __tablename__ = "runs"
    12	
    13	    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    14	    user_id: Mapped[str] = mapped_column(String(36), nullable=False)
    15	    mode: Mapped[str] = mapped_column(String(20), nullable=False)
    16	    status: Mapped[str] = mapped_column(String(30), nullable=False, default="queued")
    17	    prompt: Mapped[str | None] = mapped_column(Text)
    18	    graph_json: Mapped[dict] = mapped_column(JSON, default=dict)
    19	    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    20	
    21	
    22	class ToolCallEvent(Base):
    23	    __tablename__ = "tool_call_events"
    24	
    25	    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    26	    run_id: Mapped[str] = mapped_column(String(36), nullable=False)
    27	    tool_id: Mapped[str] = mapped_column(String(200), nullable=False)
    28	    event_type: Mapped[str] = mapped_column(String(60), nullable=False)
    29	    payload: Mapped[dict] = mapped_column(JSON, default=dict)
    30	    status: Mapped[str] = mapped_column(String(30), nullable=False, default="ok")
    31	    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
```

## backend/app/db/models/tool.py

```python
     1	import uuid
     2	from datetime import datetime
     3	
     4	from sqlalchemy import JSON, Boolean, DateTime, String, Text, func
     5	from sqlalchemy.orm import Mapped, mapped_column
     6	
     7	from app.db.base import Base
     8	
     9	
    10	class ToolDefinition(Base):
    11	    __tablename__ = "tool_definitions"
    12	
    13	    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    14	    tool_id: Mapped[str] = mapped_column(String(200), unique=True, nullable=False)
    15	    display_name: Mapped[str] = mapped_column(String(200), nullable=False)
    16	    provider: Mapped[str] = mapped_column(String(80), nullable=False)
    17	    auth_type: Mapped[str] = mapped_column(String(40), nullable=False)
    18	    capabilities: Mapped[list[str]] = mapped_column(JSON, default=list)
    19	    required_scopes: Mapped[list[str]] = mapped_column(JSON, default=list)
    20	    input_schema: Mapped[dict] = mapped_column(JSON, default=dict)
    21	    output_schema: Mapped[dict] = mapped_column(JSON, default=dict)
    22	    is_side_effecting: Mapped[bool] = mapped_column(Boolean, default=False)
    23	    description: Mapped[str | None] = mapped_column(Text)
    24	    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    25	
    26	
    27	class ToolConnection(Base):
    28	    __tablename__ = "tool_connections"
    29	
    30	    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    31	    user_id: Mapped[str] = mapped_column(String(36), nullable=False)
    32	    provider: Mapped[str] = mapped_column(String(80), nullable=False)
    33	    status: Mapped[str] = mapped_column(String(40), nullable=False, default="auth_required")
    34	    encrypted_access_token: Mapped[str | None] = mapped_column(Text)
    35	    encrypted_refresh_token: Mapped[str | None] = mapped_column(Text)
    36	    scopes: Mapped[list[str]] = mapped_column(JSON, default=list)
    37	    metadata_json: Mapped[dict] = mapped_column(JSON, default=dict)
    38	    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```

## backend/app/db/models/user.py

```python
     1	import uuid
     2	from datetime import datetime
     3	
     4	from sqlalchemy import DateTime, String, func
     5	from sqlalchemy.orm import Mapped, mapped_column
     6	
     7	from app.db.base import Base
     8	
     9	
    10	class User(Base):
    11	    __tablename__ = "users"
    12	
    13	    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    14	    email: Mapped[str] = mapped_column(String(320), unique=True, nullable=False)
    15	    display_name: Mapped[str | None] = mapped_column(String(120))
    16	    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
```

## backend/app/db/session.py

```python
     1	from collections.abc import AsyncGenerator
     2	
     3	from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
     4	
     5	from app.core.config import get_settings
     6	
     7	settings = get_settings()
     8	
     9	engine = create_async_engine(settings.database_url, future=True, pool_pre_ping=True)
    10	SessionLocal = async_sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)
    11	
    12	
    13	async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    14	    async with SessionLocal() as session:
    15	        yield session
```

## backend/app/__init__.py

```python
```

## backend/app/main.py

```python
     1	from fastapi import FastAPI
     2	
     3	from app.api.v1.router import api_router
     4	from app.core.logging import configure_logging
     5	from app.core.tracing import configure_tracing
     6	from app.services.tools import register_native_handlers
     7	
     8	configure_logging()
     9	configure_tracing()
    10	register_native_handlers()
    11	
    12	app = FastAPI(title="Weaver Backend", version="0.1.0")
    13	app.include_router(api_router)
    14	
    15	
    16	@app.get("/health")
    17	async def health() -> dict[str, str]:
    18	    return {"status": "ok"}
```

## backend/app/mcp/adapters/__init__.py

```python
```

## backend/app/mcp/adapters/native_adapter.py

```python
     1	from collections.abc import Awaitable, Callable
     2	from typing import Any
     3	
     4	
     5	NativeToolHandler = Callable[[dict[str, Any]], Awaitable[dict[str, Any]]]
     6	
     7	
     8	class NativeToolAdapter:
     9	    def __init__(self) -> None:
    10	        self._handlers: dict[str, NativeToolHandler] = {}
    11	
    12	    def register(self, tool_id: str, handler: NativeToolHandler) -> None:
    13	        self._handlers[tool_id] = handler
    14	
    15	    async def invoke(self, tool_id: str, arguments: dict[str, Any]) -> dict[str, Any]:
    16	        if tool_id not in self._handlers:
    17	            raise ValueError(f"Unknown tool_id: {tool_id}")
    18	        return await self._handlers[tool_id](arguments)
    19	
    20	
    21	native_tool_adapter = NativeToolAdapter()
```

## backend/app/mcp/__init__.py

```python
```

## backend/app/mcp/registry/contracts.py

```python
     1	from typing import Any
     2	
     3	from pydantic import BaseModel
     4	
     5	
     6	class ToolContract(BaseModel):
     7	    tool_id: str
     8	    display_name: str
     9	    provider: str
    10	    auth_type: str
    11	    capabilities: list[str]
    12	    required_scopes: list[str]
    13	    input_schema: dict[str, Any]
    14	    output_schema: dict[str, Any]
    15	    is_side_effecting: bool
    16	    description: str | None = None
```

## backend/app/mcp/registry/__init__.py

```python
```

## backend/app/schemas/auth.py

```python
     1	from pydantic import BaseModel
     2	
     3	
     4	class TokenPairOut(BaseModel):
     5	    access_token: str
     6	    refresh_token: str
     7	    token_type: str = "bearer"
     8	
     9	
    10	class LoginIn(BaseModel):
    11	    email: str
    12	    display_name: str | None = None
```

## backend/app/schemas/chat.py

```python
     1	from pydantic import BaseModel
     2	
     3	
     4	class ChatIn(BaseModel):
     5	    prompt: str
     6	    system_prompt: str | None = None
     7	    model_name: str | None = None
     8	
     9	
    10	class ChatOut(BaseModel):
    11	    model_name: str
    12	    content: str
    13	    raw_response: dict
    14	
    15	
    16	class AgentPromptIn(BaseModel):
    17	    prompt: str
    18	    system_prompt: str | None = None
    19	    model_name: str | None = None
    20	    llm_api_key: str | None = None
    21	    llm_base_url: str | None = None
    22	    enabled_tool_ids: list[str] = []
    23	    discord_channel_id: str | None = None
    24	    history: list[dict] = []
    25	
    26	
    27	class AgentToolCallOut(BaseModel):
    28	    tool_id: str
    29	    result: dict
    30	
    31	
    32	class AgentPromptOut(BaseModel):
    33	    chat: ChatOut | None = None
    34	    chat_error: str | None = None
    35	    tool_calls: list[AgentToolCallOut]
    36	    discord_send: dict | None = None
```

## backend/app/schemas/__init__.py

```python
```

## backend/app/schemas/runs.py

```python
     1	from datetime import datetime
     2	from typing import Any
     3	
     4	from pydantic import BaseModel
     5	
     6	
     7	class RunCreateIn(BaseModel):
     8	    mode: str
     9	    prompt: str | None = None
    10	
    11	
    12	class RunInvokeToolIn(BaseModel):
    13	    tool_id: str
    14	    arguments: dict[str, Any]
    15	
    16	
    17	class RunOut(BaseModel):
    18	    id: str
    19	    mode: str
    20	    status: str
    21	    prompt: str | None
    22	    graph_json: dict[str, Any]
    23	    created_at: datetime
    24	
    25	
    26	class TraceEventOut(BaseModel):
    27	    run_id: str
    28	    tool_id: str
    29	    event_type: str
    30	    payload: dict[str, Any]
    31	    status: str
    32	    created_at: datetime
```

## backend/app/schemas/tooling.py

```python
     1	from typing import Any
     2	
     3	from pydantic import BaseModel, Field
     4	
     5	
     6	class ToolDefinitionOut(BaseModel):
     7	    tool_id: str
     8	    display_name: str
     9	    provider: str
    10	    auth_type: str
    11	    capabilities: list[str]
    12	    required_scopes: list[str]
    13	    input_schema: dict[str, Any]
    14	    output_schema: dict[str, Any]
    15	    is_side_effecting: bool
    16	    description: str | None = None
    17	
    18	
    19	class ToolExecuteIn(BaseModel):
    20	    run_id: str | None = None
    21	    tool_id: str
    22	    arguments: dict[str, Any] = Field(default_factory=dict)
    23	
    24	
    25	class ToolExecuteOut(BaseModel):
    26	    status: str
    27	    tool_id: str
    28	    result: dict[str, Any]
    29	    trace_id: str
    30	
    31	
    32	class ToolCardStateOut(BaseModel):
    33	    provider: str
    34	    status: str
    35	    scopes: list[str]
    36	    metadata: dict[str, Any]
```

## backend/app/services/__init__.py

```python
```

## backend/app/services/llm.py

```python
     1	from urllib.parse import urljoin
     2	import re
     3	
     4	import httpx
     5	
     6	from app.core.config import get_settings
     7	
     8	
     9	class LLMConfigError(Exception):
    10	    pass
    11	
    12	
    13	class LLMService:
    14	    async def chat(
    15	        self,
    16	        prompt: str,
    17	        system_prompt: str | None = None,
    18	        model_name: str | None = None,
    19	        llm_api_key: str | None = None,
    20	        llm_base_url: str | None = None,
    21	        history: list[dict] | None = None,
    22	    ) -> dict:
    23	        settings = get_settings()
    24	        api_key = (llm_api_key or settings.llm_api_key).strip()
    25	        if not api_key:
    26	            raise LLMConfigError("LLM_API_KEY is missing")
    27	
    28	        base_url = (llm_base_url or settings.llm_base_url).strip()
    29	        if not base_url:
    30	            raise LLMConfigError("LLM_BASE_URL is missing")
    31	
    32	        chosen_model = model_name or settings.llm_model_name
    33	        endpoint = urljoin(base_url.rstrip("/") + "/", "chat/completions")
    34	        headers = {
    35	            "Authorization": f"Bearer {api_key}",
    36	            "Content-Type": "application/json",
    37	        }
    38	
    39	        messages = _build_bounded_messages(
    40	            prompt=prompt,
    41	            system_prompt=system_prompt,
    42	            history=history or [],
    43	        )
    44	
    45	        payload = {
    46	            "model": chosen_model,
    47	            "messages": messages,
    48	            "temperature": 0.2,
    49	        }
    50	
    51	        async with httpx.AsyncClient(timeout=60.0) as client:
    52	            response = await client.post(endpoint, headers=headers, json=payload)
    53	            response.raise_for_status()
    54	            data = response.json()
    55	
    56	        choices = data.get("choices", [])
    57	        message = choices[0].get("message", {}) if choices else {}
    58	        content = message.get("content", "")
    59	
    60	        return {
    61	            "model_name": chosen_model,
    62	            "content": content,
    63	            "raw_response": data,
    64	        }
    65	
    66	
    67	llm_service = LLMService()
    68	
    69	
    70	_MAX_HISTORY_MESSAGES = 12
    71	_MAX_SINGLE_MESSAGE_CHARS = 1800
    72	_MAX_PROMPT_CHARS = 3500
    73	_MAX_SYSTEM_CHARS = 1200
    74	_MAX_TOTAL_CHARS = 12000
    75	
    76	
    77	def _build_bounded_messages(prompt: str, system_prompt: str | None, history: list[dict]) -> list[dict]:
    78	    bounded: list[dict] = []
    79	
    80	    if system_prompt:
    81	        bounded.append({"role": "system", "content": _trim_text(system_prompt, _MAX_SYSTEM_CHARS)})
    82	
    83	    cleaned_history: list[dict] = []
    84	    for item in history[-_MAX_HISTORY_MESSAGES:]:
    85	        role = item.get("role", "user")
    86	        content = item.get("content", "")
    87	        if role not in {"user", "assistant", "system"}:
    88	            continue
    89	        if not content:
    90	            continue
    91	        text = _strip_think(content)
    92	        text = _trim_text(text, _MAX_SINGLE_MESSAGE_CHARS)
    93	        if not text:
    94	            continue
    95	        cleaned_history.append({"role": role, "content": text})
    96	
    97	    prompt_text = _trim_text(_strip_think(prompt), _MAX_PROMPT_CHARS)
    98	    bounded.extend(cleaned_history)
    99	    bounded.append({"role": "user", "content": prompt_text})
   100	
   101	    # Enforce hard total budget by trimming oldest history first.
   102	    while _total_chars(bounded) > _MAX_TOTAL_CHARS:
   103	        # Preserve system (index 0 if present) and last user prompt.
   104	        if len(bounded) <= 2:
   105	            break
   106	        remove_index = 1 if bounded[0].get("role") == "system" else 0
   107	        if remove_index >= len(bounded) - 1:
   108	            break
   109	        bounded.pop(remove_index)
   110	
   111	    # Final safety: if still oversized, trim final user prompt.
   112	    if _total_chars(bounded) > _MAX_TOTAL_CHARS and bounded:
   113	        overflow = _total_chars(bounded) - _MAX_TOTAL_CHARS
   114	        last = bounded[-1]
   115	        shortened = _trim_text(last.get("content", ""), max(200, len(last.get("content", "")) - overflow - 32))
   116	        bounded[-1] = {"role": last.get("role", "user"), "content": shortened}
   117	
   118	    return bounded
   119	
   120	
   121	def _strip_think(text: str) -> str:
   122	    return re.sub(r"<think>[\s\S]*?</think>", "", text, flags=re.IGNORECASE).strip()
   123	
   124	
   125	def _trim_text(text: str, max_chars: int) -> str:
   126	    value = (text or "").strip()
   127	    if len(value) <= max_chars:
   128	        return value
   129	    return value[: max_chars - 3].rstrip() + "..."
   130	
   131	
   132	def _total_chars(messages: list[dict]) -> int:
   133	    return sum(len((msg.get("content") or "")) for msg in messages)
```

## backend/app/services/orchestration/__init__.py

```python
```

## backend/app/services/orchestration/langgraph/__init__.py

```python
```

## backend/app/services/orchestration/langgraph/runtime.py

```python
     1	from typing import Any, TypedDict
     2	
     3	from langgraph.graph import END, START, StateGraph
     4	
     5	from app.services.tools import tool_execution_service
     6	
     7	
     8	class WeaverAgentState(TypedDict, total=False):
     9	    run_id: str
    10	    tool_id: str
    11	    arguments: dict[str, Any]
    12	    tool_result: dict[str, Any]
    13	
    14	
    15	async def execute_tool_node(state: WeaverAgentState) -> WeaverAgentState:
    16	    result = await tool_execution_service.execute(
    17	        tool_id=state["tool_id"],
    18	        arguments=state.get("arguments", {}),
    19	        run_id=state.get("run_id"),
    20	    )
    21	    state["tool_result"] = result
    22	    return state
    23	
    24	
    25	def build_single_tool_graph():
    26	    graph = StateGraph(WeaverAgentState)
    27	    graph.add_node("execute_tool", execute_tool_node)
    28	    graph.add_edge(START, "execute_tool")
    29	    graph.add_edge("execute_tool", END)
    30	    return graph.compile()
    31	
    32	
    33	single_tool_graph = build_single_tool_graph()
```

## backend/app/services/providers/discord/__init__.py

```python
```

## backend/app/services/providers/discord/service.py

```python
     1	from urllib.parse import urlencode
     2	
     3	import httpx
     4	
     5	from app.core.config import get_settings
     6	
     7	
     8	DISCORD_SCOPES = ["identify", "guilds", "email"]
     9	
    10	
    11	class DiscordIntegrationService:
    12	    @staticmethod
    13	    def build_oauth_url(state: str) -> str:
    14	        settings = get_settings()
    15	        params = {
    16	            "client_id": settings.discord_client_id,
    17	            "redirect_uri": settings.discord_redirect_uri,
    18	            "response_type": "code",
    19	            "scope": " ".join(DISCORD_SCOPES),
    20	            "prompt": "consent",
    21	            "state": state,
    22	        }
    23	        return f"https://discord.com/oauth2/authorize?{urlencode(params)}"
    24	
    25	    @staticmethod
    26	    async def exchange_code(code: str) -> dict:
    27	        settings = get_settings()
    28	        payload = {
    29	            "grant_type": "authorization_code",
    30	            "code": code,
    31	            "redirect_uri": settings.discord_redirect_uri,
    32	        }
    33	        auth = (settings.discord_client_id, settings.discord_client_secret)
    34	        headers = {"Content-Type": "application/x-www-form-urlencoded"}
    35	        async with httpx.AsyncClient(timeout=20.0) as client:
    36	            response = await client.post(
    37	                "https://discord.com/api/oauth2/token",
    38	                data=payload,
    39	                headers=headers,
    40	                auth=auth,
    41	            )
    42	            response.raise_for_status()
    43	            token_data = response.json()
    44	
    45	        return {
    46	            "access_token": token_data.get("access_token", ""),
    47	            "refresh_token": token_data.get("refresh_token", ""),
    48	            "scopes": token_data.get("scope", "").split(),
    49	            "provider_account_id": "",
    50	            "expires_in": token_data.get("expires_in"),
    51	            "token_type": token_data.get("token_type"),
    52	        }
    53	
    54	    @staticmethod
    55	    async def send_message(channel_id: str, content: str, bot_token: str) -> dict:
    56	        if not bot_token:
    57	            return {
    58	                "channel_id": channel_id,
    59	                "content": content,
    60	                "sent": False,
    61	                "error": "DISCORD_BOT_TOKEN missing",
    62	            }
    63	
    64	        headers = {
    65	            "Authorization": f"Bot {bot_token}",
    66	            "Content-Type": "application/json",
    67	        }
    68	        payload = {"content": content}
    69	        async with httpx.AsyncClient(timeout=20.0) as client:
    70	            response = await client.post(
    71	                f"https://discord.com/api/v10/channels/{channel_id}/messages",
    72	                headers=headers,
    73	                json=payload,
    74	            )
    75	            if response.is_error:
    76	                raise RuntimeError(_format_discord_error(response, channel_id))
    77	            data = response.json()
    78	        return {
    79	            "channel_id": channel_id,
    80	            "message_id": data.get("id"),
    81	            "content": data.get("content"),
    82	            "sent": True,
    83	        }
    84	
    85	    @staticmethod
    86	    async def get_user_info(access_token: str) -> dict:
    87	        headers = {"Authorization": f"Bearer {access_token}"}
    88	        async with httpx.AsyncClient(timeout=20.0) as client:
    89	            response = await client.get(
    90	                "https://discord.com/api/v10/users/@me",
    91	                headers=headers,
    92	            )
    93	            response.raise_for_status()
    94	            data = response.json()
    95	
    96	        username = data.get("username", "")
    97	        discriminator = data.get("discriminator", "")
    98	        if discriminator and discriminator != "0":
    99	            display = f"{username}#{discriminator}"
   100	        else:
   101	            display = username
   102	
   103	        return {
   104	            "id": data.get("id"),
   105	            "username": username,
   106	            "display_name": display,
   107	            "global_name": data.get("global_name"),
   108	            "email": data.get("email"),
   109	            "verified": data.get("verified"),
   110	        }
   111	
   112	    @staticmethod
   113	    async def get_bot_identity(bot_token: str) -> dict:
   114	        if not bot_token:
   115	            return {"configured": False}
   116	
   117	        headers = {"Authorization": f"Bot {bot_token}"}
   118	        async with httpx.AsyncClient(timeout=20.0) as client:
   119	            response = await client.get("https://discord.com/api/v10/users/@me", headers=headers)
   120	            response.raise_for_status()
   121	            data = response.json()
   122	
   123	        return {
   124	            "configured": True,
   125	            "id": data.get("id"),
   126	            "username": data.get("username"),
   127	            "global_name": data.get("global_name"),
   128	            "bot": data.get("bot", True),
   129	        }
   130	
   131	
   132	def _format_discord_error(response: httpx.Response, channel_id: str) -> str:
   133	    status = response.status_code
   134	    text = response.text
   135	    code = None
   136	    message = None
   137	    try:
   138	        payload = response.json()
   139	        code = payload.get("code")
   140	        message = payload.get("message")
   141	    except Exception:
   142	        payload = None
   143	
   144	    parts = [f"Discord API error {status} for channel {channel_id}."]
   145	
   146	    if code is not None or message:
   147	        parts.append(f"code={code} message={message}")
   148	
   149	    if status == 403:
   150	        parts.append(
   151	            "Bot lacks access/permission for this channel. "
   152	            "Check bot is in server and has View Channel + Send Messages in target channel."
   153	        )
   154	    elif status == 404:
   155	        parts.append("Channel not found for this bot. Verify channel id and server membership.")
   156	    elif status == 401:
   157	        parts.append("Invalid bot token. Rotate DISCORD_BOT_TOKEN and update .env.")
   158	
   159	    if not (code or message):
   160	        parts.append(f"raw={text[:300]}")
   161	
   162	    return " ".join(parts)
   163	
   164	
   165	discord_service = DiscordIntegrationService()
```

## backend/app/services/providers/filesystem/__init__.py

```python
```

## backend/app/services/providers/filesystem/service.py

```python
     1	from pathlib import Path
     2	import shutil
     3	
     4	from app.core.config import get_settings
     5	
     6	
     7	class FileSandboxError(Exception):
     8	    pass
     9	
    10	
    11	class FilesystemToolService:
    12	    def __init__(self) -> None:
    13	        settings = get_settings()
    14	        self.allowed_root = Path(settings.allowed_file_root).resolve()
    15	        self.allowed_root.mkdir(parents=True, exist_ok=True)
    16	
    17	    def _resolve(self, path: str) -> Path:
    18	        candidate = (self.allowed_root / path).resolve()
    19	        if not str(candidate).startswith(str(self.allowed_root)):
    20	            raise FileSandboxError("Path escapes allowed file root")
    21	        return candidate
    22	
    23	    def set_allowed_root(self, root_path: str) -> dict:
    24	        candidate = Path(root_path).expanduser().resolve()
    25	        candidate.mkdir(parents=True, exist_ok=True)
    26	        self.allowed_root = candidate
    27	        return {"allowed_root": str(self.allowed_root)}
    28	
    29	    def get_allowed_root(self) -> dict:
    30	        return {"allowed_root": str(self.allowed_root)}
    31	
    32	    def list_directory(self, path: str = ".") -> dict:
    33	        directory = self._resolve(path)
    34	        if not directory.exists() or not directory.is_dir():
    35	            raise FileSandboxError("Directory does not exist")
    36	        entries = []
    37	        for entry in sorted(directory.iterdir(), key=lambda x: x.name):
    38	            entries.append(
    39	                {
    40	                    "name": entry.name,
    41	                    "is_dir": entry.is_dir(),
    42	                    "size": entry.stat().st_size if entry.exists() and entry.is_file() else None,
    43	                }
    44	            )
    45	        return {"path": str(directory), "entries": entries}
    46	
    47	    def read_file(self, path: str) -> dict:
    48	        target = self._resolve(path)
    49	        if not target.exists() or not target.is_file():
    50	            raise FileSandboxError("File does not exist")
    51	        return {"path": str(target), "content": target.read_text(encoding="utf-8")}
    52	
    53	    def write_file(self, path: str, content: str, create_dirs: bool = True) -> dict:
    54	        target = self._resolve(path)
    55	        if create_dirs:
    56	            target.parent.mkdir(parents=True, exist_ok=True)
    57	        target.write_text(content, encoding="utf-8")
    58	        return {"path": str(target), "bytes_written": len(content.encode("utf-8"))}
    59	
    60	    def copy_path(self, source: str, destination: str) -> dict:
    61	        src = self._resolve(source)
    62	        dest = self._resolve(destination)
    63	        if not src.exists():
    64	            raise FileSandboxError("Source path does not exist")
    65	        if src.is_dir():
    66	            shutil.copytree(src, dest, dirs_exist_ok=True)
    67	            return {"source": str(src), "destination": str(dest), "copied": "directory"}
    68	        dest.parent.mkdir(parents=True, exist_ok=True)
    69	        shutil.copy2(src, dest)
    70	        return {"source": str(src), "destination": str(dest), "copied": "file"}
    71	
    72	    def move_path(self, source: str, destination: str) -> dict:
    73	        src = self._resolve(source)
    74	        dest = self._resolve(destination)
    75	        if not src.exists():
    76	            raise FileSandboxError("Source path does not exist")
    77	        dest.parent.mkdir(parents=True, exist_ok=True)
    78	        moved_to = shutil.move(str(src), str(dest))
    79	        return {"source": str(src), "destination": moved_to}
    80	
    81	    def delete_path(self, path: str, recursive: bool = False) -> dict:
    82	        target = self._resolve(path)
    83	        if not target.exists():
    84	            raise FileSandboxError("Path does not exist")
    85	        if target.is_dir():
    86	            if recursive:
    87	                shutil.rmtree(target)
    88	            else:
    89	                target.rmdir()
    90	            return {"path": str(target), "deleted": "directory"}
    91	        target.unlink()
    92	        return {"path": str(target), "deleted": "file"}
    93	
    94	
    95	filesystem_service = FilesystemToolService()
```

## backend/app/services/providers/google/__init__.py

```python
```

## backend/app/services/providers/google/service.py

```python
     1	from urllib.parse import urlencode
     2	import base64
     3	
     4	import httpx
     5	
     6	from app.core.config import get_settings
     7	
     8	
     9	GOOGLE_SCOPES = [
    10	    "https://www.googleapis.com/auth/gmail.readonly",
    11	    "https://www.googleapis.com/auth/gmail.send",
    12	    "https://www.googleapis.com/auth/drive.file",
    13	    "https://www.googleapis.com/auth/drive.metadata.readonly",
    14	]
    15	
    16	
    17	class GoogleIntegrationService:
    18	    @staticmethod
    19	    def build_oauth_url(state: str) -> str:
    20	        settings = get_settings()
    21	        params = {
    22	            "client_id": settings.google_client_id,
    23	            "redirect_uri": settings.google_redirect_uri,
    24	            "response_type": "code",
    25	            "scope": " ".join(GOOGLE_SCOPES),
    26	            "access_type": "offline",
    27	            "include_granted_scopes": "true",
    28	            "prompt": "consent",
    29	            "state": state,
    30	        }
    31	        return f"https://accounts.google.com/o/oauth2/v2/auth?{urlencode(params)}"
    32	
    33	    @staticmethod
    34	    async def exchange_code(code: str) -> dict:
    35	        settings = get_settings()
    36	        payload = {
    37	            "code": code,
    38	            "client_id": settings.google_client_id,
    39	            "client_secret": settings.google_client_secret,
    40	            "redirect_uri": settings.google_redirect_uri,
    41	            "grant_type": "authorization_code",
    42	        }
    43	        async with httpx.AsyncClient(timeout=20.0) as client:
    44	            response = await client.post("https://oauth2.googleapis.com/token", data=payload)
    45	            response.raise_for_status()
    46	            token_data = response.json()
    47	        return {
    48	            "access_token": token_data.get("access_token", ""),
    49	            "refresh_token": token_data.get("refresh_token", ""),
    50	            "scopes": token_data.get("scope", "").split(),
    51	            "provider_account_id": token_data.get("id_token", ""),
    52	            "expires_in": token_data.get("expires_in"),
    53	            "token_type": token_data.get("token_type"),
    54	        }
    55	
    56	    @staticmethod
    57	    async def refresh_access_token(refresh_token: str) -> dict:
    58	        settings = get_settings()
    59	        payload = {
    60	            "client_id": settings.google_client_id,
    61	            "client_secret": settings.google_client_secret,
    62	            "refresh_token": refresh_token,
    63	            "grant_type": "refresh_token",
    64	        }
    65	        async with httpx.AsyncClient(timeout=20.0) as client:
    66	            response = await client.post("https://oauth2.googleapis.com/token", data=payload)
    67	            response.raise_for_status()
    68	            token_data = response.json()
    69	        return {
    70	            "access_token": token_data.get("access_token", ""),
    71	            "refresh_token": refresh_token,
    72	            "scopes": token_data.get("scope", "").split(),
    73	            "provider_account_id": "",
    74	            "expires_in": token_data.get("expires_in"),
    75	            "token_type": token_data.get("token_type"),
    76	        }
    77	
    78	    @staticmethod
    79	    async def list_gmail_threads(access_token: str, max_results: int = 20) -> dict:
    80	        headers = {"Authorization": f"Bearer {access_token}"}
    81	        params = {"maxResults": max_results}
    82	        async with httpx.AsyncClient(timeout=20.0) as client:
    83	            response = await client.get(
    84	                "https://gmail.googleapis.com/gmail/v1/users/me/threads",
    85	                headers=headers,
    86	                params=params,
    87	            )
    88	            response.raise_for_status()
    89	            data = response.json()
    90	        return {
    91	            "threads": data.get("threads", []),
    92	            "next_page_token": data.get("nextPageToken"),
    93	            "result_size_estimate": data.get("resultSizeEstimate", 0),
    94	        }
    95	
    96	    @staticmethod
    97	    async def list_drive_files(access_token: str, page_size: int = 20) -> dict:
    98	        headers = {"Authorization": f"Bearer {access_token}"}
    99	        params = {
   100	            "pageSize": page_size,
   101	            "fields": "files(id,name,mimeType,modifiedTime,size),nextPageToken",
   102	            "supportsAllDrives": "true",
   103	            "includeItemsFromAllDrives": "true",
   104	        }
   105	        async with httpx.AsyncClient(timeout=20.0) as client:
   106	            response = await client.get(
   107	                "https://www.googleapis.com/drive/v3/files",
   108	                headers=headers,
   109	                params=params,
   110	            )
   111	            response.raise_for_status()
   112	            data = response.json()
   113	        return {"files": data.get("files", []), "next_page_token": data.get("nextPageToken")}
   114	
   115	    @staticmethod
   116	    async def get_latest_gmail_email(access_token: str) -> dict:
   117	        headers = {"Authorization": f"Bearer {access_token}"}
   118	        params = {"maxResults": 1, "labelIds": "INBOX", "q": "-in:chats"}
   119	        async with httpx.AsyncClient(timeout=20.0) as client:
   120	            list_resp = await client.get(
   121	                "https://gmail.googleapis.com/gmail/v1/users/me/messages",
   122	                headers=headers,
   123	                params=params,
   124	            )
   125	            list_resp.raise_for_status()
   126	            list_data = list_resp.json()
   127	
   128	            messages = list_data.get("messages", [])
   129	            if not messages:
   130	                return {"found": False, "reason": "No messages found in inbox"}
   131	
   132	            message_id = messages[0].get("id", "")
   133	            msg_resp = await client.get(
   134	                f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{message_id}",
   135	                headers=headers,
   136	                params={"format": "full"},
   137	            )
   138	            msg_resp.raise_for_status()
   139	            msg = msg_resp.json()
   140	
   141	        payload = msg.get("payload", {})
   142	        headers_list = payload.get("headers", [])
   143	        by_name = {h.get("name", "").lower(): h.get("value", "") for h in headers_list}
   144	        body_text = _extract_message_body(payload)
   145	
   146	        return {
   147	            "found": True,
   148	            "id": msg.get("id"),
   149	            "thread_id": msg.get("threadId"),
   150	            "subject": by_name.get("subject", "(no subject)"),
   151	            "from": by_name.get("from", ""),
   152	            "date": by_name.get("date", ""),
   153	            "snippet": msg.get("snippet", ""),
   154	            "body_text": body_text,
   155	        }
   156	
   157	    @staticmethod
   158	    async def get_user_info(access_token: str) -> dict:
   159	        headers = {"Authorization": f"Bearer {access_token}"}
   160	        async with httpx.AsyncClient(timeout=20.0) as client:
   161	            response = await client.get(
   162	                "https://www.googleapis.com/oauth2/v2/userinfo",
   163	                headers=headers,
   164	            )
   165	            response.raise_for_status()
   166	            data = response.json()
   167	        return {
   168	            "id": data.get("id"),
   169	            "email": data.get("email"),
   170	            "name": data.get("name"),
   171	            "picture": data.get("picture"),
   172	            "verified_email": data.get("verified_email"),
   173	        }
   174	
   175	    @staticmethod
   176	    async def get_gmail_profile(access_token: str) -> dict:
   177	        headers = {"Authorization": f"Bearer {access_token}"}
   178	        async with httpx.AsyncClient(timeout=20.0) as client:
   179	            response = await client.get(
   180	                "https://gmail.googleapis.com/gmail/v1/users/me/profile",
   181	                headers=headers,
   182	            )
   183	            response.raise_for_status()
   184	            data = response.json()
   185	
   186	        return {
   187	            "email": data.get("emailAddress"),
   188	            "messages_total": data.get("messagesTotal"),
   189	            "threads_total": data.get("threadsTotal"),
   190	        }
   191	
   192	
   193	def _extract_message_body(payload: dict) -> str:
   194	    plain_text = _find_plain_text(payload)
   195	    if plain_text:
   196	        return plain_text
   197	
   198	    data = payload.get("body", {}).get("data")
   199	    if not data:
   200	        return ""
   201	
   202	    return _decode_base64url(data)
   203	
   204	
   205	def _find_plain_text(part: dict) -> str:
   206	    mime_type = part.get("mimeType", "")
   207	    body_data = part.get("body", {}).get("data")
   208	    if mime_type == "text/plain" and body_data:
   209	        return _decode_base64url(body_data)
   210	
   211	    for child in part.get("parts", []) or []:
   212	        found = _find_plain_text(child)
   213	        if found:
   214	            return found
   215	    return ""
   216	
   217	
   218	def _decode_base64url(data: str) -> str:
   219	    normalized = data.replace("-", "+").replace("_", "/")
   220	    pad = len(normalized) % 4
   221	    if pad:
   222	        normalized += "=" * (4 - pad)
   223	    decoded = base64.b64decode(normalized)
   224	    return decoded.decode("utf-8", errors="replace")
   225	
   226	
   227	google_service = GoogleIntegrationService()
```

## backend/app/services/providers/__init__.py

```python
```

## backend/app/services/providers/token_store.py

```python
     1	from __future__ import annotations
     2	
     3	import json
     4	from datetime import UTC, datetime, timedelta
     5	from pathlib import Path
     6	from typing import Any
     7	
     8	from app.core.config import get_settings
     9	
    10	
    11	class OAuthTokenStore:
    12	    """Lightweight local token storage for development workflows.
    13	
    14	    This intentionally uses a local JSON file to keep setup simple for local testing.
    15	    Move to encrypted-at-rest DB storage for production use.
    16	    """
    17	
    18	    def __init__(self) -> None:
    19	        settings = get_settings()
    20	        self.path = Path(settings.oauth_token_store_path).expanduser().resolve()
    21	        self.path.parent.mkdir(parents=True, exist_ok=True)
    22	
    23	    def _load(self) -> dict[str, Any]:
    24	        if not self.path.exists():
    25	            return {"providers": {}}
    26	        try:
    27	            return json.loads(self.path.read_text(encoding="utf-8"))
    28	        except Exception:
    29	            return {"providers": {}}
    30	
    31	    def _save(self, payload: dict[str, Any]) -> None:
    32	        self.path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")
    33	
    34	    def set_tokens(
    35	        self,
    36	        provider: str,
    37	        token_bundle: dict[str, Any],
    38	        state: str | None = None,
    39	        metadata: dict[str, Any] | None = None,
    40	    ) -> dict[str, Any]:
    41	        payload = self._load()
    42	        providers = payload.setdefault("providers", {})
    43	
    44	        record: dict[str, Any] = {
    45	            "access_token": token_bundle.get("access_token", ""),
    46	            "refresh_token": token_bundle.get("refresh_token", ""),
    47	            "token_type": token_bundle.get("token_type"),
    48	            "scopes": token_bundle.get("scopes", []),
    49	            "updated_at": datetime.now(UTC).isoformat(),
    50	        }
    51	
    52	        expires_in = token_bundle.get("expires_in")
    53	        if isinstance(expires_in, int) and expires_in > 0:
    54	            expires_at = datetime.now(UTC) + timedelta(seconds=max(expires_in - 60, 0))
    55	            record["expires_at"] = expires_at.isoformat()
    56	
    57	        if state:
    58	            record["last_state"] = state
    59	
    60	        if metadata:
    61	            record["metadata"] = metadata
    62	
    63	        providers[provider] = record
    64	        self._save(payload)
    65	        return record
    66	
    67	    def get_tokens(self, provider: str) -> dict[str, Any]:
    68	        payload = self._load()
    69	        providers = payload.get("providers", {})
    70	        return providers.get(provider, {})
    71	
    72	    def get_status(self, provider: str) -> dict[str, Any]:
    73	        record = self.get_tokens(provider)
    74	        if not record:
    75	            return {"provider": provider, "authenticated": False, "scopes": [], "expires_at": None}
    76	
    77	        return {
    78	            "provider": provider,
    79	            "authenticated": bool(record.get("access_token") or record.get("refresh_token")),
    80	            "scopes": record.get("scopes", []),
    81	            "expires_at": record.get("expires_at"),
    82	            "updated_at": record.get("updated_at"),
    83	            "metadata": record.get("metadata", {}),
    84	        }
    85	
    86	
    87	oauth_token_store = OAuthTokenStore()
```

## backend/app/services/tools.py

```python
     1	import uuid
     2	from datetime import datetime, timezone
     3	from typing import Any
     4	
     5	from app.core.config import get_settings
     6	from app.mcp.adapters.native_adapter import native_tool_adapter
     7	from app.mcp.registry.contracts import ToolContract
     8	from app.services.providers.discord.service import discord_service
     9	from app.services.providers.filesystem.service import FileSandboxError, filesystem_service
    10	from app.services.providers.google.service import google_service
    11	from app.services.providers.token_store import oauth_token_store
    12	from app.services.tracing.event_bus import trace_event_bus
    13	
    14	
    15	def _tool_catalog() -> list[ToolContract]:
    16	    return [
    17	        ToolContract(
    18	            tool_id="filesystem.list_directory",
    19	            display_name="List Directory",
    20	            provider="filesystem",
    21	            auth_type="none",
    22	            capabilities=["read"],
    23	            required_scopes=[],
    24	            input_schema={"type": "object", "properties": {"path": {"type": "string"}}},
    25	            output_schema={"type": "object"},
    26	            is_side_effecting=False,
    27	            description="List files and folders under a sandboxed path.",
    28	        ),
    29	        ToolContract(
    30	            tool_id="filesystem.read_file",
    31	            display_name="Read File",
    32	            provider="filesystem",
    33	            auth_type="none",
    34	            capabilities=["read"],
    35	            required_scopes=[],
    36	            input_schema={"type": "object", "properties": {"path": {"type": "string"}}},
    37	            output_schema={"type": "object"},
    38	            is_side_effecting=False,
    39	            description="Read text content from a sandboxed file.",
    40	        ),
    41	        ToolContract(
    42	            tool_id="filesystem.write_file",
    43	            display_name="Write File",
    44	            provider="filesystem",
    45	            auth_type="none",
    46	            capabilities=["write"],
    47	            required_scopes=[],
    48	            input_schema={
    49	                "type": "object",
    50	                "properties": {"path": {"type": "string"}, "content": {"type": "string"}},
    51	                "required": ["path", "content"],
    52	            },
    53	            output_schema={"type": "object"},
    54	            is_side_effecting=True,
    55	            description="Write text content to a sandboxed file.",
    56	        ),
    57	        ToolContract(
    58	            tool_id="filesystem.copy_path",
    59	            display_name="Copy Path",
    60	            provider="filesystem",
    61	            auth_type="none",
    62	            capabilities=["write"],
    63	            required_scopes=[],
    64	            input_schema={
    65	                "type": "object",
    66	                "properties": {"source": {"type": "string"}, "destination": {"type": "string"}},
    67	                "required": ["source", "destination"],
    68	            },
    69	            output_schema={"type": "object"},
    70	            is_side_effecting=True,
    71	            description="Copy file or directory within sandbox.",
    72	        ),
    73	        ToolContract(
    74	            tool_id="filesystem.move_path",
    75	            display_name="Move Path",
    76	            provider="filesystem",
    77	            auth_type="none",
    78	            capabilities=["write"],
    79	            required_scopes=[],
    80	            input_schema={
    81	                "type": "object",
    82	                "properties": {"source": {"type": "string"}, "destination": {"type": "string"}},
    83	                "required": ["source", "destination"],
    84	            },
    85	            output_schema={"type": "object"},
    86	            is_side_effecting=True,
    87	            description="Move file or directory within sandbox.",
    88	        ),
    89	        ToolContract(
    90	            tool_id="filesystem.delete_path",
    91	            display_name="Delete Path",
    92	            provider="filesystem",
    93	            auth_type="none",
    94	            capabilities=["write"],
    95	            required_scopes=[],
    96	            input_schema={
    97	                "type": "object",
    98	                "properties": {"path": {"type": "string"}, "recursive": {"type": "boolean"}},
    99	                "required": ["path"],
   100	            },
   101	            output_schema={"type": "object"},
   102	            is_side_effecting=True,
   103	            description="Delete file or directory in sandbox.",
   104	        ),
   105	        ToolContract(
   106	            tool_id="google.gmail.list_threads",
   107	            display_name="List Gmail Threads",
   108	            provider="google",
   109	            auth_type="oauth2",
   110	            capabilities=["read"],
   111	            required_scopes=["https://www.googleapis.com/auth/gmail.readonly"],
   112	            input_schema={"type": "object", "properties": {"max_results": {"type": "integer"}}},
   113	            output_schema={"type": "object"},
   114	            is_side_effecting=False,
   115	            description="List threads from Gmail inbox.",
   116	        ),
   117	        ToolContract(
   118	            tool_id="google.gmail.get_latest_email",
   119	            display_name="Get Latest Gmail Email",
   120	            provider="google",
   121	            auth_type="oauth2",
   122	            capabilities=["read"],
   123	            required_scopes=["https://www.googleapis.com/auth/gmail.readonly"],
   124	            input_schema={"type": "object", "properties": {}},
   125	            output_schema={"type": "object"},
   126	            is_side_effecting=False,
   127	            description="Fetch the latest email from Gmail inbox.",
   128	        ),
   129	        ToolContract(
   130	            tool_id="google.drive.list_files",
   131	            display_name="List Drive Files",
   132	            provider="google",
   133	            auth_type="oauth2",
   134	            capabilities=["read"],
   135	            required_scopes=["https://www.googleapis.com/auth/drive.metadata.readonly"],
   136	            input_schema={"type": "object", "properties": {"page_size": {"type": "integer"}}},
   137	            output_schema={"type": "object"},
   138	            is_side_effecting=False,
   139	            description="List files from Google Drive.",
   140	        ),
   141	        ToolContract(
   142	            tool_id="discord.send_message",
   143	            display_name="Send Discord Message",
   144	            provider="discord",
   145	            auth_type="oauth2",
   146	            capabilities=["write"],
   147	            required_scopes=["identify"],
   148	            input_schema={
   149	                "type": "object",
   150	                "properties": {"channel_id": {"type": "string"}, "content": {"type": "string"}},
   151	                "required": ["channel_id", "content"],
   152	            },
   153	            output_schema={"type": "object"},
   154	            is_side_effecting=True,
   155	            description="Send a message to a Discord channel.",
   156	        ),
   157	    ]
   158	
   159	
   160	async def _filesystem_list_directory(arguments: dict[str, Any]) -> dict[str, Any]:
   161	    return filesystem_service.list_directory(path=arguments.get("path", "."))
   162	
   163	
   164	async def _filesystem_read_file(arguments: dict[str, Any]) -> dict[str, Any]:
   165	    return filesystem_service.read_file(path=arguments["path"])
   166	
   167	
   168	async def _filesystem_write_file(arguments: dict[str, Any]) -> dict[str, Any]:
   169	    return filesystem_service.write_file(path=arguments["path"], content=arguments["content"])
   170	
   171	
   172	async def _filesystem_copy_path(arguments: dict[str, Any]) -> dict[str, Any]:
   173	    return filesystem_service.copy_path(source=arguments["source"], destination=arguments["destination"])
   174	
   175	
   176	async def _filesystem_move_path(arguments: dict[str, Any]) -> dict[str, Any]:
   177	    return filesystem_service.move_path(source=arguments["source"], destination=arguments["destination"])
   178	
   179	
   180	async def _filesystem_delete_path(arguments: dict[str, Any]) -> dict[str, Any]:
   181	    return filesystem_service.delete_path(
   182	        path=arguments["path"],
   183	        recursive=bool(arguments.get("recursive", False)),
   184	    )
   185	
   186	
   187	async def _google_gmail_list_threads(arguments: dict[str, Any]) -> dict[str, Any]:
   188	    access_token = await _resolve_google_access_token(arguments)
   189	    return await google_service.list_gmail_threads(
   190	        access_token,
   191	        max_results=int(arguments.get("max_results", 20)),
   192	    )
   193	
   194	
   195	async def _google_gmail_get_latest_email(arguments: dict[str, Any]) -> dict[str, Any]:
   196	    access_token = await _resolve_google_access_token(arguments)
   197	    return await google_service.get_latest_gmail_email(access_token)
   198	
   199	
   200	async def _google_drive_list_files(arguments: dict[str, Any]) -> dict[str, Any]:
   201	    access_token = await _resolve_google_access_token(arguments)
   202	    return await google_service.list_drive_files(
   203	        access_token,
   204	        page_size=int(arguments.get("page_size", 20)),
   205	    )
   206	
   207	
   208	async def _discord_send_message(arguments: dict[str, Any]) -> dict[str, Any]:
   209	    settings = get_settings()
   210	    return await discord_service.send_message(
   211	        channel_id=arguments["channel_id"],
   212	        content=arguments["content"],
   213	        bot_token=arguments.get("bot_token") or settings.discord_bot_token,
   214	    )
   215	
   216	
   217	async def _resolve_google_access_token(arguments: dict[str, Any]) -> str:
   218	    provided = arguments.get("access_token", "")
   219	    if provided:
   220	        return provided
   221	
   222	    stored = oauth_token_store.get_tokens("google")
   223	    if not stored:
   224	        raise RuntimeError("Google auth missing. Run CLI auth-google first.")
   225	
   226	    access_token = stored.get("access_token", "")
   227	    refresh_token = stored.get("refresh_token", "")
   228	
   229	    if access_token:
   230	        return access_token
   231	
   232	    if not refresh_token:
   233	        raise RuntimeError("Google auth has no usable token. Re-run auth-google.")
   234	
   235	    refreshed = await google_service.refresh_access_token(refresh_token)
   236	    oauth_token_store.set_tokens("google", refreshed)
   237	    return refreshed.get("access_token", "")
   238	
   239	
   240	def register_native_handlers() -> None:
   241	    native_tool_adapter.register("filesystem.list_directory", _filesystem_list_directory)
   242	    native_tool_adapter.register("filesystem.read_file", _filesystem_read_file)
   243	    native_tool_adapter.register("filesystem.write_file", _filesystem_write_file)
   244	    native_tool_adapter.register("filesystem.copy_path", _filesystem_copy_path)
   245	    native_tool_adapter.register("filesystem.move_path", _filesystem_move_path)
   246	    native_tool_adapter.register("filesystem.delete_path", _filesystem_delete_path)
   247	    native_tool_adapter.register("google.gmail.list_threads", _google_gmail_list_threads)
   248	    native_tool_adapter.register("google.gmail.get_latest_email", _google_gmail_get_latest_email)
   249	    native_tool_adapter.register("google.drive.list_files", _google_drive_list_files)
   250	    native_tool_adapter.register("discord.send_message", _discord_send_message)
   251	
   252	
   253	class ToolExecutionService:
   254	    def __init__(self) -> None:
   255	        self.catalog = _tool_catalog()
   256	
   257	    async def execute(self, tool_id: str, arguments: dict[str, Any], run_id: str | None = None) -> dict[str, Any]:
   258	        trace_id = str(uuid.uuid4())
   259	        effective_run_id = run_id or str(uuid.uuid4())
   260	        start_event = {
   261	            "run_id": effective_run_id,
   262	            "trace_id": trace_id,
   263	            "tool_id": tool_id,
   264	            "event_type": "tool_call_started",
   265	            "status": "ok",
   266	            "created_at": datetime.now(timezone.utc).isoformat(),
   267	            "payload": {"arguments": _redact(arguments)},
   268	        }
   269	        await trace_event_bus.publish(effective_run_id, start_event)
   270	
   271	        try:
   272	            result = await native_tool_adapter.invoke(tool_id, arguments)
   273	        except FileSandboxError as exc:
   274	            failure_event = {
   275	                "run_id": effective_run_id,
   276	                "trace_id": trace_id,
   277	                "tool_id": tool_id,
   278	                "event_type": "tool_call_failed",
   279	                "status": "error",
   280	                "created_at": datetime.now(timezone.utc).isoformat(),
   281	                "payload": {"error": str(exc)},
   282	            }
   283	            await trace_event_bus.publish(effective_run_id, failure_event)
   284	            return {"status": "error", "tool_id": tool_id, "trace_id": trace_id, "result": failure_event}
   285	        except Exception as exc:
   286	            failure_event = {
   287	                "run_id": effective_run_id,
   288	                "trace_id": trace_id,
   289	                "tool_id": tool_id,
   290	                "event_type": "tool_call_failed",
   291	                "status": "error",
   292	                "created_at": datetime.now(timezone.utc).isoformat(),
   293	                "payload": {"error": str(exc)},
   294	            }
   295	            await trace_event_bus.publish(effective_run_id, failure_event)
   296	            return {"status": "error", "tool_id": tool_id, "trace_id": trace_id, "result": failure_event}
   297	
   298	        success_event = {
   299	            "run_id": effective_run_id,
   300	            "trace_id": trace_id,
   301	            "tool_id": tool_id,
   302	            "event_type": "tool_call_succeeded",
   303	            "status": "ok",
   304	            "created_at": datetime.now(timezone.utc).isoformat(),
   305	            "payload": {"result_summary": _summarize(result)},
   306	        }
   307	        await trace_event_bus.publish(effective_run_id, success_event)
   308	        return {"status": "ok", "tool_id": tool_id, "trace_id": trace_id, "result": result}
   309	
   310	
   311	def _redact(arguments: dict[str, Any]) -> dict[str, Any]:
   312	    redacted = {}
   313	    for key, value in arguments.items():
   314	        if "token" in key or "secret" in key or "password" in key:
   315	            redacted[key] = "***"
   316	        else:
   317	            redacted[key] = value
   318	    return redacted
   319	
   320	
   321	def _summarize(result: dict[str, Any]) -> dict[str, Any]:
   322	    if "entries" in result and isinstance(result["entries"], list):
   323	        return {"entries_count": len(result["entries"])}
   324	    return {k: v for k, v in result.items() if k in {"path", "bytes_written", "deleted", "copied"}}
   325	
   326	
   327	tool_execution_service = ToolExecutionService()
```

## backend/app/services/tracing/event_bus.py

```python
     1	import asyncio
     2	import json
     3	from collections import defaultdict
     4	from typing import Any
     5	
     6	
     7	class TraceEventBus:
     8	    def __init__(self) -> None:
     9	        self._queues: dict[str, list[asyncio.Queue[str]]] = defaultdict(list)
    10	
    11	    async def publish(self, run_id: str, event: dict[str, Any]) -> None:
    12	        payload = json.dumps(event)
    13	        for queue in self._queues[run_id]:
    14	            await queue.put(payload)
    15	
    16	    def subscribe(self, run_id: str) -> asyncio.Queue[str]:
    17	        queue: asyncio.Queue[str] = asyncio.Queue()
    18	        self._queues[run_id].append(queue)
    19	        return queue
    20	
    21	    def unsubscribe(self, run_id: str, queue: asyncio.Queue[str]) -> None:
    22	        if run_id in self._queues:
    23	            self._queues[run_id] = [q for q in self._queues[run_id] if q is not queue]
    24	            if not self._queues[run_id]:
    25	                del self._queues[run_id]
    26	
    27	
    28	trace_event_bus = TraceEventBus()
```

## backend/app/services/tracing/__init__.py

```python
```

## backend/app/workers/__init__.py

```python
```

## backend/app/workers/tasks/__init__.py

```python
```

## backend/app/workers/tasks/run_tasks.py

```python
     1	from app.services.orchestration.langgraph.runtime import single_tool_graph
     2	
     3	
     4	async def execute_tool_run(run_id: str, tool_id: str, arguments: dict) -> dict:
     5	    return await single_tool_graph.ainvoke({"run_id": run_id, "tool_id": tool_id, "arguments": arguments})
```

