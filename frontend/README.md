# Weaver Frontend

Flutter desktop UI for Weaver with live backend integration.

## What Is Integrated

- Backend auto-start from the app (Linux desktop flow)
- Live tool catalog and tool auth status from backend
- OAuth connect flow for Google and Discord from UI buttons
- Tool-aware agent prompt route (`/api/v1/chat/agent`)
- Prompt flows for Gmail, Drive, Discord, and filesystem tools
- Configurable backend base URL and default Discord channel in Settings

## Run

From this folder:

1. `flutter pub get`
2. `flutter run -d linux`

By default, the app tries to start backend at `http://127.0.0.1:8000`.
You can change this from Settings -> Backend Runtime.

## Auth Flow

From UI:

1. Open Settings -> Auth & Tools
2. Click Connect for Google (used by both Gmail and Drive)
3. Complete browser OAuth callback
4. Click Connect for Discord if needed
5. Save a Discord channel id in Settings -> Agent Defaults

## Prompt Testing

Use chat prompts such as:

- `fetch the latest gmail`
- `list drive files`
- `fetch the latest gmail and send to discord`
- `list files in sandbox`

## Notes

- n8n integration is intentionally deferred.
- Workflows panel still uses starter data and is not yet backend-driven.
