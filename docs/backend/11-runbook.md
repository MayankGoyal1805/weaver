# Local Runbook

## 1. Start from Clean Checkout

1. `cd backend`
2. `cp .env.example .env`
3. Fill required env vars.

## 2. Start Infra

- SQLite requires no DB container.
- Optional for Redis and future queue paths:
	- `docker compose up -d`

## 3. Install and Run API

- `uv sync`
- `uv run uvicorn app.main:app --reload --port 8000`

Alternative with CLI:
- `uv run weaver-cli runserver --port 8000`

## 4. Verify Core Endpoints

1. `GET /health`
2. `GET /api/v1/tools/catalog`
3. `POST /api/v1/auth/dev-login`
4. `POST /api/v1/chat`

## 5. Validate Trace Flow

1. Create run with `POST /api/v1/runs`
2. Open SSE on `GET /api/v1/runs/{run_id}/trace`
3. Execute a filesystem tool via `POST /api/v1/tools/execute` with same run_id
4. Confirm trace events arrive in order.

## 6. Validate Google OAuth

1. hit `/api/v1/auth/google/connect`
2. open returned URL in browser and authorize
3. callback should return token bundle

## 7. Validate Discord OAuth + Message

1. hit `/api/v1/auth/discord/connect`
2. authorize in browser
3. callback returns token bundle
4. call `discord.send_message` tool with channel_id/content and bot token

## 8. Run Tests and Lint

- `uv run pytest -q`
- `uv run ruff check app tests`

## 9. CLI Smoke Tests

- Health:
	- `uv run weaver-cli health`
- Chat prompt:
	- `uv run weaver-cli chat "Summarize this project in one line"`
- Tool catalog:
	- `uv run weaver-cli catalog`
- Execute file tool:
	- `uv run weaver-cli execute-tool filesystem.list_directory --arguments-json '{"path":"."}'`
