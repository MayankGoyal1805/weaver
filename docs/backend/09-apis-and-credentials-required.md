# APIs, Credentials, and Console Setup You Need

This is the exact checklist of external APIs, credentials, and app configuration required for your current backend implementation.

## 1. Local Infra (Required)

### SQLite (default for local development)
Needed for:
- users
- tool definitions
- provider connections
- runs and tool events

Provide:
- `DATABASE_URL`

Example:
- `sqlite+aiosqlite:///./weaver.db`

Note:
- SQLite is now the default and recommended local path.
- PostgreSQL can still be used later by switching `DATABASE_URL`.

### Redis
Needed for:
- background queue later (ARQ)
- transient event signaling and future distributed trace fanout

Provide:
- `REDIS_URL`

Example:
- `redis://localhost:6379/0`

## 2. Backend App Secrets (Required)

Provide:
- `APP_SECRET_KEY` (JWT signing)
- `TOKEN_ENCRYPTION_KEY` (OAuth token encryption at rest)

Recommendation:
- use at least 32 random bytes, base64-encoded where appropriate.

## 3. Google (Gmail + Drive) (Required for those cards)

### 3.1 Create Google Cloud Project
1. Open Google Cloud Console.
2. Create/select project for Weaver.
3. Enable APIs:
   - Gmail API
   - Google Drive API

### 3.2 Configure OAuth Consent Screen
1. Set app name, support email, authorized domains.
2. Add test users in development mode.
3. Add required scopes.

### 3.3 Create OAuth Client ID (Web Application)
Provide redirect URI matching backend:
- `http://localhost:8000/api/v1/auth/google/callback`

Collect:
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_REDIRECT_URI`

### 3.4 Scopes to Request (Current Implementation)
- `https://www.googleapis.com/auth/gmail.readonly`
- `https://www.googleapis.com/auth/gmail.send`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/drive.metadata.readonly`

Important:
- Gmail scopes can be sensitive/restricted; production launch may require OAuth verification and potentially security assessment depending on scope/data handling.

## 4. Discord (Required for Discord cards)

### 4.1 Create Discord Application
1. Go to Discord Developer Portal.
2. Create new application.
3. Configure OAuth2 redirect URI:
   - `http://localhost:8000/api/v1/auth/discord/callback`

Collect:
- `DISCORD_CLIENT_ID`
- `DISCORD_CLIENT_SECRET`
- `DISCORD_REDIRECT_URI`

### 4.2 Discord OAuth Endpoints Used
- Authorization URL base: `https://discord.com/oauth2/authorize`
- Token URL: `https://discord.com/api/oauth2/token`
- Token revocation URL: `https://discord.com/api/oauth2/token/revoke`

### 4.3 Scopes Used in Current Flow
- `identify`
- `guilds`
- `email`

### 4.4 Bot Token for Message Sending
Current `discord.send_message` tool uses bot token and channel message endpoint.

Provide:
- `DISCORD_BOT_TOKEN`

Also ensure:
- Bot is invited to target server.
- Bot has permission to view/send in target channel.

## 5. Optional but Highly Recommended Immediately

### 5.1 LLM Provider Credential
The backend now uses an OpenAI-compatible chat endpoint contract.

Use these variables:
- `LLM_MODEL_NAME`
- `LLM_API_KEY`
- `LLM_BASE_URL`

Examples:
- `LLM_MODEL_NAME=gpt-4.1-mini`
- `LLM_API_KEY=...`
- `LLM_BASE_URL=https://api.openai.com/v1`

Do not combine base URL into API key. Keep these as separate variables.

### 5.2 Observability Export Targets
If you want persistent production telemetry beyond console:
- OTLP endpoint (for traces)
- metrics backend (Prometheus/Grafana)
- central logs destination

## 6. Exact Environment Variables to Fill

From `.env.example`, you must fill these before integration tests:
- `APP_SECRET_KEY`
- `TOKEN_ENCRYPTION_KEY`
- `DATABASE_URL`
- `REDIS_URL`
- `LLM_MODEL_NAME`
- `LLM_API_KEY`
- `LLM_BASE_URL`
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_REDIRECT_URI`
- `DISCORD_CLIENT_ID`
- `DISCORD_CLIENT_SECRET`
- `DISCORD_REDIRECT_URI`
- `DISCORD_BOT_TOKEN`

## 7. Recommended Order to Obtain Everything

1. Start SQLite locally via `DATABASE_URL` and keep redis for queue/event use.
2. Set app secrets and verify health endpoint.
3. Complete Google project + OAuth setup.
4. Complete Discord app + bot setup.
5. Wire keys to `.env` and run auth connect endpoints.
6. Validate Gmail/Drive list and Discord send message tools.
7. Add production secret manager after local success.

## 8. Web-Verified Provider Notes

The current setup aligns with provider docs:
- Google OAuth scope catalog and Gmail scope sensitivity model.
- Discord OAuth authorize/token URLs and form-encoded token exchange requirement.
