# Weaver Backend Stack Decisions

This document makes explicit decisions for backend technologies.

## 1. Language and Package/Env Management

- **Language**: Python 3.12+
- **Package and environment manager**: `uv`

Why:
- Fast installs and lockfile workflow.
- Simple project bootstrap.
- Good fit for modern Python backend teams.

## 2. API and Runtime

- **API framework**: FastAPI
- **ASGI server**: Uvicorn (Gunicorn+Uvicorn workers in production)
- **Validation**: Pydantic v2

Why:
- Async-friendly and excellent for tool-heavy systems.
- Strong typing + OpenAPI generation.
- Good developer experience for rapid iteration.

## 3. Agent Orchestration

- **Decision**: Use LangGraph for agent orchestration.

Why LangGraph for Weaver:
- Graph-native control flow maps naturally to your “weaving” concept.
- Better durability and controllability than simple linear chains.
- Supports multi-agent handoff patterns.
- Natural fit for emitting trace nodes/edges for Trace View.

When not to use LangGraph:
- If the system were only simple chat with minimal tool calls.
- Weaver needs richer orchestration and eventual automation convergence, so LangGraph is a strong fit.

## 4. Tool Protocol and Execution Boundary

- **Decision**: Use MCP as the tool contract boundary.
- Keep a hybrid model:
  - Native internal Python tools for highest performance/dev speed.
  - MCP-compatible wrappers so every tool still exposes a standard interface.
  - Optional external MCP servers for isolated or third-party tool packs.

Why:
- Future-proof for ecosystem interoperability.
- Lets your tool cards stay stable while implementations evolve.
- Easier to plug in new tool providers.

## 5. Database and State

- **Primary database**: PostgreSQL
- **ORM**: SQLAlchemy 2.x
- **Migrations**: Alembic
- **Cache + transient state + pub/sub**: Redis

Why:
- PostgreSQL gives reliable relational modeling for users/tools/runs.
- Redis is ideal for short-lived runtime signals and event fanout.

## 6. Background Jobs and Automation Execution

- **Decision for v0**: Start with ARQ (Redis-backed async task queue).
- **Future upgrade path**: Temporal when durable long-running workflows become a major requirement.

Why:
- ARQ keeps complexity low early.
- Temporal can be adopted later for stronger replay/history guarantees.

## 7. Auth and Integrations

- **User auth**: JWT-based session tokens (access + refresh)
- **OAuth**: Authlib for OAuth 2.0 providers
- **Google APIs**: google-api-python-client + google-auth + google-auth-oauthlib
- **Discord**:
  - OAuth2 for account linking
  - Bot token/webhook capabilities for actions

## 8. Observability and Trace View

- **Structured logging**: structlog
- **Tracing**: OpenTelemetry
- **Metrics**: Prometheus-compatible endpoints
- **Realtime trace stream**: Server-Sent Events (SSE) first; WebSockets optional later

Why:
- You need transparent tool execution for card-centric UX.
- Traces must be first-class, not afterthought.

## 9. Testing and Quality

- **Test framework**: pytest
- **Async tests**: pytest-asyncio
- **HTTP tests**: httpx test client
- **Lint/format/type checks**:
  - ruff
  - mypy (incremental strictness)

## 10. Deployment Baseline

- Dockerized services:
  - api
  - worker
  - postgres
  - redis
- Reverse proxy: Caddy or Nginx
- CI: GitHub Actions
