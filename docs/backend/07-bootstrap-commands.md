# Backend Bootstrap Commands (uv + FastAPI)

Use these commands to initialize the backend quickly.

## 1. Create backend folder and init project

```bash
mkdir -p backend
cd backend
uv init --package weaver-backend
```

## 2. Add runtime dependencies

```bash
uv add fastapi uvicorn[standard] pydantic-settings sqlalchemy alembic asyncpg redis arq authlib httpx structlog opentelemetry-api opentelemetry-sdk
```

## 3. Add provider dependencies

```bash
uv add google-api-python-client google-auth google-auth-oauthlib google-auth-httplib2
```

For Discord REST/webhook style:

```bash
uv add aiohttp
```

If you later need full bot framework behavior:

```bash
uv add discord.py
```

## 4. Add LangGraph and related AI stack

```bash
uv add langgraph langchain langchain-core
```

Add model provider SDK(s) as needed later (OpenAI, Anthropic, etc.).

## 5. Add development dependencies

```bash
uv add --dev pytest pytest-asyncio ruff mypy
```

## 6. Initialize Alembic

```bash
uv run alembic init app/db/migrations
```

## 7. Run local API server

```bash
uv run uvicorn app.main:app --reload --port 8000
```

## 8. Suggested first environment file

Create `.env` with at least:

```env
APP_ENV=dev
APP_SECRET_KEY=replace_me
TOKEN_ENCRYPTION_KEY=replace_me
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/weaver
REDIS_URL=redis://localhost:6379/0
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=
DISCORD_CLIENT_ID=
DISCORD_CLIENT_SECRET=
DISCORD_REDIRECT_URI=
DISCORD_BOT_TOKEN=
```

## 9. Start local infra with Docker Compose (example)

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: weaver
    ports:
      - "5432:5432"
  redis:
    image: redis:7
    ports:
      - "6379:6379"
```

## 10. First milestone check

You should be able to:
- Start API successfully
- Reach health endpoint
- Connect to DB and Redis
- Register one file tool card in tool registry
