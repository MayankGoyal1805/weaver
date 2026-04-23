# Backend Guide

This backend is a FastAPI service that acts as an agent runtime with tool integrations (Google, Discord, filesystem), model invocation, and orchestration endpoints.

## System Overview

Core runtime layers:

1. API layer (`app/api/v1/routes`)
   - Receives HTTP requests.
   - Validates request bodies with schema models.
   - Calls services.
   - Shapes response payloads.

2. Schema layer (`app/schemas`)
   - Defines Pydantic request/response contracts.

3. Service layer (`app/services`)
   - LLM invocation and payload budgeting.
   - Tool execution and provider adapters.
   - Provider token/profile persistence.

4. Persistence layer (`app/db`)
   - SQLAlchemy models and session management.
   - Alembic migrations.

5. Core/config layer (`app/core`)
   - Settings, security, logging, tracing primitives.

## Backend Directory Breakdown

### App bootstrap

- `backend/app/main.py`
  - Creates FastAPI app.
  - Mounts API routers.
  - Configures middleware and startup behavior.

- `backend/app/cli.py`
  - CLI entry points for local backend operations.

### API versioned routes

- `backend/app/api/v1/router.py`
  - Root v1 API router; includes feature route modules.

- `backend/app/api/v1/routes/chat.py`
  - Main agent endpoint.
  - Intent parsing for tool behavior.
  - Tool-call sequencing.
  - LLM completion call.
  - Post-processing and optional Discord send.

- `backend/app/api/v1/routes/tools.py`
  - Tool catalog/card state APIs.
  - Filesystem root get/set APIs.

- `backend/app/api/v1/routes/auth.py`
  - OAuth auth/connect/disconnect state.
  - User profile/userinfo retrieval.

- `backend/app/api/v1/routes/runs.py`
  - Run lifecycle and run records.

- `backend/app/api/v1/routes/automations.py`
  - Automation/workflow route handling.

### Schemas

- `backend/app/schemas/chat.py`
  - Chat request and response contracts.
- `backend/app/schemas/tooling.py`
  - Tool metadata and state contracts.
- `backend/app/schemas/auth.py`
  - Provider auth status/identity contracts.
- `backend/app/schemas/runs.py`
  - Run state contracts.

### Services

- `backend/app/services/llm.py`
  - Builds model message payload.
  - Applies history truncation and budget constraints.
  - Calls model provider and normalizes output.

- `backend/app/services/tools.py`
  - Tool execution orchestration and utility wrappers.

- `backend/app/services/providers/token_store.py`
  - Persists provider tokens and metadata.

- `backend/app/services/providers/google/service.py`
  - Gmail/Drive user and data operations.

- `backend/app/services/providers/discord/service.py`
  - Discord user/bot identity and message send behavior.

- `backend/app/services/providers/filesystem/service.py`
  - Filesystem operations constrained by configured root.

### Database and migrations

- `backend/app/db/models/*.py`
  - ORM entities.
- `backend/app/db/session.py`
  - Session and engine management.
- `backend/app/db/migrations/*`
  - Alembic migration environment and versions.

### Orchestration and tracing

- `backend/app/services/orchestration/langgraph/runtime.py`
  - Graph-style runtime orchestration.
- `backend/app/services/tracing/event_bus.py`
  - Internal tracing event bus.

## Request Flow: /api/v1/chat/agent

1. Request enters `chat.py` route.
2. Route inspects message intent and settings.
3. Route calls tool services if needed.
4. Tool results are compacted and injected into context.
5. LLM payload is assembled in `services/llm.py` with strict token/size budget.
6. Model output is post-processed.
7. Optional side effects (such as Discord send) run only when prerequisites are satisfied.
8. Response includes chat output, tool calls, and error state.

## Reliability Patterns To Notice

1. Defensive truncation and prompt budgeting in `services/llm.py`.
2. Explicit tool failure handling and fail-fast behavior in `routes/chat.py`.
3. Auth/profile refresh logic in `routes/auth.py` and provider services.
4. Route-level deterministic fallback errors instead of silent failures.

## How To Read The Complete Source

Use [../reference/backend-source-reference.md](../reference/backend-source-reference.md) and study in this order:

1. `backend/app/main.py`
2. `backend/app/api/v1/router.py`
3. `backend/app/api/v1/routes/chat.py`
4. `backend/app/services/llm.py`
5. `backend/app/services/providers/*`
6. `backend/app/schemas/*`
7. `backend/app/db/*`

For each file:

1. Read imports and identify dependencies.
2. Identify data contracts and return types.
3. Trace exception paths and external API calls.
4. Confirm how the frontend consumes that data.