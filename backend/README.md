# Weaver Backend

Python backend for Weaver, a tool-card-first multi-agent and automation platform.

## Quick Start

1. Install dependencies with uv:
   - `uv sync`
2. Copy environment file:
   - `cp .env.example .env`
3. Run API:
   - `uv run uvicorn app.main:app --reload --port 8000`

SQLite is the default local database (`sqlite+aiosqlite:///./weaver.db`) and requires no DB container.
Redis via docker compose is optional for queue/event expansion paths.

## Local CLI

Use CLI for local testing. Most commands now auto-start a local server at http://127.0.0.1:8000 if it is not already running.

- `uv run weaver-cli --help`
- `uv run weaver-cli health`
- `uv run weaver-cli prompt "Summarize Weaver backend in one paragraph"`
- `uv run weaver-cli catalog`
- `uv run weaver-cli execute-tool filesystem.list_directory --arguments-json '{"path":"."}'`
- `uv run weaver-cli google-drive auth`
- `uv run weaver-cli google-drive status`
- `uv run weaver-cli auth-discord`
- `uv run weaver-cli gmail-to-discord --channel-id YOUR_CHANNEL_ID --format-with-llm`
- `uv run weaver-cli discord-send --channel-id YOUR_CHANNEL_ID --message "hello from weaver"`

### OAuth from CLI

1. Run Google auth (opens browser and waits for callback completion):
   - `uv run weaver-cli google-drive auth`
2. Verify token status:
   - `uv run weaver-cli google-drive status`
3. Optional Discord user auth:
   - `uv run weaver-cli auth-discord`

### Prompt Testing

- Simple LLM prompt test:
  - `uv run weaver-cli prompt "Reply with exactly HELLO"`
- Chat command remains available:
  - `uv run weaver-cli chat "What tools are available?"`

### Tool-Aware Prompt Mode

- Prompt with automatic tool use for Gmail intent:
   - `uv run weaver-cli prompt "fetch the latest gmail" --allow-tools`
- Prompt with Gmail fetch and Discord send in one run:
   - `uv run weaver-cli prompt "fetch the latest gmail and send it to discord" --allow-tools --discord-channel-id YOUR_CHANNEL_ID`

If `--allow-tools` is not set, the CLI sends only a plain LLM chat request and no tools are invoked.

### Gmail -> Discord Test Flow

1. Ensure `DISCORD_BOT_TOKEN` is set in `.env`.
2. Authenticate Google account with `google-drive auth`.
3. Send latest Gmail email to Discord test channel:
   - `uv run weaver-cli gmail-to-discord --channel-id YOUR_CHANNEL_ID --format-with-llm`

### Discord Channel Setup

1. Enable Developer Mode in Discord (Settings -> Advanced -> Developer Mode).
2. Right-click target channel in your test server and select Copy Channel ID.
3. Invite your bot to the server and ensure it has permissions in that channel:
   - View Channel
   - Send Messages
4. Put bot token in `.env` as `DISCORD_BOT_TOKEN`.
5. Use that copied channel id in CLI commands with `--channel-id` or `--discord-channel-id`.
6. Verify channel delivery first:
   - `uv run weaver-cli discord-send --channel-id YOUR_CHANNEL_ID --message "discord setup ok"`

## Initial Implemented Scope

- Tool registry and execution endpoint
- Chat endpoint through configurable OpenAI-compatible LLM API
- Trace event stream (SSE)
- Filesystem tools (list/read/write/copy/move/delete with sandbox controls)
- Gmail/Drive/Discord integration tools with OAuth start/callback endpoints and local dev token storage
- LangGraph orchestration starter for tool-call flows
