# Implemented Backend (What Exists Right Now)

This document describes what has been implemented in code under `backend/`.

## 1. Project Setup and Tooling

Implemented:
- `uv`-managed Python project with dependencies in `backend/pyproject.toml`
- local environment template in `backend/.env.example`
- local infrastructure in `backend/docker-compose.yml` (PostgreSQL + Redis)

## 2. App Bootstrapping

Implemented:
- FastAPI app entrypoint: `backend/app/main.py`
- API router wiring: `backend/app/api/v1/router.py`
- logging config: `backend/app/core/logging.py`
- OpenTelemetry tracer setup: `backend/app/core/tracing.py`
- settings loader: `backend/app/core/config.py`
- JWT helpers: `backend/app/core/security.py`

Health endpoint:
- `GET /health`

## 3. API Surface Implemented

### Auth Routes
File: `backend/app/api/v1/routes/auth.py`

Endpoints:
- `POST /api/v1/auth/dev-login`
- `GET /api/v1/auth/google/connect`
- `GET /api/v1/auth/google/callback`
- `GET /api/v1/auth/discord/connect`
- `GET /api/v1/auth/discord/callback`

### Tool Routes
File: `backend/app/api/v1/routes/tools.py`

Endpoints:
- `GET /api/v1/tools/catalog`
- `POST /api/v1/tools/execute`
- `GET /api/v1/tools/cards/state`

### Run/Trace Routes
File: `backend/app/api/v1/routes/runs.py`

Endpoints:
- `POST /api/v1/runs`
- `POST /api/v1/runs/{run_id}/invoke-tool`
- `GET /api/v1/runs/{run_id}/trace` (SSE stream)

### Automation Placeholder Route
File: `backend/app/api/v1/routes/automations.py`

Endpoint:
- `GET /api/v1/automations`

## 4. Tool Card Catalog + Execution Engine

Implemented in `backend/app/services/tools.py`:
- tool contract-driven catalog
- native tool handler registration
- execution service with event emission
- event payload redaction for secrets

Current tool IDs available:
- `filesystem.list_directory`
- `filesystem.read_file`
- `filesystem.write_file`
- `filesystem.copy_path`
- `filesystem.move_path`
- `filesystem.delete_path`
- `google.gmail.list_threads`
- `google.drive.list_files`
- `discord.send_message`

## 5. Filesystem Provider (Real Implementation)

Implemented in `backend/app/services/providers/filesystem/service.py`:
- sandboxed path resolution using `ALLOWED_FILE_ROOT`
- list/read/write/copy/move/delete
- guardrails against path escape attempts

## 6. Google Provider (OAuth + API Calls)

Implemented in `backend/app/services/providers/google/service.py`:
- OAuth URL builder
- authorization code exchange via `https://oauth2.googleapis.com/token`
- Gmail list threads call
- Drive list files call

Notes:
- current callbacks return token bundle payload to help frontend wiring and manual verification.
- token persistence/encryption model is scaffolded in DB models and planned for next hardening pass.

## 7. Discord Provider (OAuth + API Calls)

Implemented in `backend/app/services/providers/discord/service.py`:
- OAuth URL builder
- authorization code exchange via `https://discord.com/api/oauth2/token`
- send message endpoint using bot token and REST API v10

## 8. LangGraph Runtime

Implemented in `backend/app/services/orchestration/langgraph/runtime.py`:
- single-tool execution graph state machine
- async invoke support
- wired into run invoke endpoint

## 9. Trace View Foundation (Realtime)

Implemented in `backend/app/services/tracing/event_bus.py`:
- in-process pub/sub event bus keyed by run_id
- SSE route streams trace events
- tool execution emits lifecycle events (`started`, `succeeded`, `failed`)

## 10. Database Layer (Schema Foundation)

Implemented:
- SQLAlchemy declarative base and async session
- models for users, tools, connections, runs, tool events

Files:
- `backend/app/db/base.py`
- `backend/app/db/session.py`
- `backend/app/db/models/user.py`
- `backend/app/db/models/tool.py`
- `backend/app/db/models/run.py`

## 11. MCP Compatibility Direction

Implemented:
- native tool adapter abstraction in `backend/app/mcp/adapters/native_adapter.py`
- tool contract model in `backend/app/mcp/registry/contracts.py`

This gives a direct path to expose/consume external MCP servers later without redesigning card metadata.

## 12. Tests and Validation

Implemented tests:
- `backend/tests/unit/test_health.py`
- `backend/tests/unit/test_tools_catalog.py`

Validated:
- dependency installation via `uv sync`
- tests pass (`2 passed`)
- lint pass (`ruff check`)

## 13. What Is Intentionally Next (Not Yet Implemented)

1. Token encryption-at-rest and persisted provider connections in callbacks.
2. Alembic migration files and DB bootstrapping commands.
3. Full Gmail/Drive action set (read message, send draft, upload/download).
4. Discord read/list actions and richer permission diagnostics.
5. Multi-agent routing graph (specialists + coordinator).
6. Durable automation runtime (trigger/schedule/retries/replay history).
