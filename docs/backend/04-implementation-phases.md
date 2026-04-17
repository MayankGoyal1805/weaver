# Backend Implementation Phases

## Phase 0: Foundation Setup

Deliverables:
- Python project initialized with `uv`
- FastAPI service skeleton
- PostgreSQL + Redis via docker compose
- Alembic migration setup
- Basic JWT auth scaffolding
- Structured logging + trace IDs

Exit criteria:
- Health endpoint works
- Auth bootstrap route works
- Database migrations run cleanly

## Phase 1: Tool Registry + File Tools

Deliverables:
- Tool registry table + API endpoints
- Tool card metadata endpoint for frontend
- Local file/directory tools:
  - list directory
  - read file
  - write file (gated)
  - move/copy/delete (gated)
- Path sandbox guardrails
- Trace events for each tool call

Exit criteria:
- File tool cards render with live status
- Calls are visible in trace stream

## Phase 2: Google OAuth + Gmail + Drive

Deliverables:
- Google OAuth connect flow
- Token encryption at rest
- Gmail tools:
  - list threads/messages
  - read message
  - send draft/send message
- Drive tools:
  - list/search files
  - read metadata
  - upload/download basic files
- Scope-aware card metadata

Exit criteria:
- User can connect Google account once and use both Gmail/Drive cards
- Tool actions execute from chat and are traced

## Phase 3: Discord Integration

Deliverables:
- Discord OAuth account link
- Optional bot token configuration
- Tools:
  - list guild channels (where permitted)
  - send message
  - read recent messages (if permitted)
- Permission diagnostics in card state

Exit criteria:
- Discord card shows permission health
- Basic send/read tools work with trace events

## Phase 4: Agent Runtime + Automation Convergence

Deliverables:
- LangGraph runtime with tool call nodes
- Run store and execution replay
- Basic automation graph schema (trigger + action chain)
- Shared execution engine for chat and automation runs

Exit criteria:
- Same tool runtime used by chat and automation pipelines
- Trace view shows graph path end-to-end

## Phase 5: Multi-Agent Manager

Deliverables:
- Agent profiles and capability tags
- Routing policy (which agent handles which request)
- Handoff traces between agents
- Supervisor-style orchestration in LangGraph

Exit criteria:
- At least two specialized agents + one coordinator agent in production path
