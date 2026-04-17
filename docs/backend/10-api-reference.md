# Backend API Reference (Current Build)

Base URL (local):
- `http://localhost:8000`

Version prefix:
- `/api/v1`

## 1. Health

### GET /health
Returns backend liveness.

Response:
- `{ "status": "ok" }`

## 2. Auth

### POST /api/v1/auth/dev-login
Development-only JWT issuance.

Request:
- `email` (string)
- `display_name` (optional string)

Response:
- `access_token`
- `refresh_token`
- `token_type`

### GET /api/v1/auth/google/connect
Returns OAuth URL and state.

### GET /api/v1/auth/google/callback?code=...&state=...
Exchanges code and returns token bundle payload.

### GET /api/v1/auth/discord/connect
Returns OAuth URL and state.

### GET /api/v1/auth/discord/callback?code=...&state=...
Exchanges code and returns token bundle payload.

## 3. Tools

### GET /api/v1/tools/catalog
Returns tool card catalog metadata.

### GET /api/v1/tools/cards/state
Returns provider card states for UI status badges.

### POST /api/v1/tools/execute
Executes one tool by tool_id.

Request:
- `run_id` (optional)
- `tool_id` (required)
- `arguments` (object)

Response:
- `status`
- `tool_id`
- `result`
- `trace_id`

## 4. Chat

### POST /api/v1/chat
Runs a prompt against the configured LLM provider.

Request:
- `prompt` (required)
- `system_prompt` (optional)
- `model_name` (optional override)

Response:
- `model_name`
- `content`
- `raw_response`

## 5. Runs + Trace

### POST /api/v1/runs
Creates a run record (lightweight current implementation).

Request:
- `mode`
- `prompt` (optional)

### POST /api/v1/runs/{run_id}/invoke-tool
Invokes LangGraph single-tool flow.

Request:
- `tool_id`
- `arguments`

### GET /api/v1/runs/{run_id}/trace
SSE stream of trace events for run.

Event payload includes:
- run_id
- trace_id
- tool_id
- event_type
- status
- payload
- created_at

## 6. Automations

### GET /api/v1/automations
Placeholder list endpoint for upcoming automation engine.
