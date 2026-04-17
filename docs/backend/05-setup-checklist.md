# Setup Checklist (Accounts, Credentials, and Infra)

This is the exact checklist for initial backend development.

## 1. Local Development Prerequisites

Install:
- Python 3.12+
- `uv`
- Docker + Docker Compose
- Git

Recommended:
- Make
- jq

## 2. Core Infrastructure

You need running:
- PostgreSQL (local docker)
- Redis (local docker)

Create:
- `DATABASE_URL`
- `REDIS_URL`
- `APP_SECRET_KEY`
- `TOKEN_ENCRYPTION_KEY`

## 3. Google (Gmail + Drive) Requirements

In Google Cloud Console:
- Create a project
- Enable APIs:
  - Gmail API
  - Google Drive API
- Configure OAuth consent screen
- Add test users (during development)
- Create OAuth Client Credentials (Web application)

Collect and store:
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_REDIRECT_URI`

Scopes to request initially:
- Gmail read basic:
  - `https://www.googleapis.com/auth/gmail.readonly`
- Gmail send:
  - `https://www.googleapis.com/auth/gmail.send`
- Drive file access:
  - `https://www.googleapis.com/auth/drive.file`
- Drive metadata read:
  - `https://www.googleapis.com/auth/drive.metadata.readonly`

## 4. Discord Requirements

In Discord Developer Portal:
- Create application
- Configure OAuth2 redirect URI
- Add required OAuth scopes
- Optional: create bot and invite it to server(s)

Collect and store:
- `DISCORD_CLIENT_ID`
- `DISCORD_CLIENT_SECRET`
- `DISCORD_REDIRECT_URI`
- `DISCORD_BOT_TOKEN` (if bot capabilities are used)

## 5. Security and Secret Storage

Minimum for v0:
- Environment variables for local dev
- Encrypt OAuth tokens before storing in DB

Preferred later:
- Secret manager (Vault, AWS Secrets Manager, GCP Secret Manager)

## 6. Operational Guardrails

Required from day one:
- Rate limiting per user/tool
- Tool-level timeout
- Retry policy with backoff for network tools
- Path allowlist for filesystem tools
- Redaction policy for logs/traces

## 7. Frontend-Backend Contract Inputs (for Flutter Team)

Backend must expose:
- tool card catalog endpoint
- card state endpoint
- connect/disconnect auth endpoints per provider
- tool execution endpoint
- run/trace stream endpoint (SSE)

This lets frontend show:
- rich card state
- auth health
- live tool execution timeline
