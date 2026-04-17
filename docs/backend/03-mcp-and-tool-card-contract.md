# MCP and Tool Card Contract

## 1. Core Principle

Every tool in Weaver should satisfy one canonical contract regardless of backend implementation style.

That means the UI card and runtime both rely on stable metadata:
- Tool identity
- Auth requirements
- Input schema
- Output schema
- Side effects
- Risk/safety level

## 2. Contract Shape (Conceptual)

Each tool definition should include:
- `tool_id`: unique machine ID (`google.drive.list_files`)
- `display_name`: card title (`List Drive Files`)
- `provider`: (`google_drive`, `gmail`, `discord`, `filesystem`)
- `capabilities`: list of action tags
- `auth_type`: (`none`, `oauth2`, `api_key`, `bot_token`)
- `required_scopes`: provider scopes/permissions
- `input_schema`: JSON schema
- `output_schema`: JSON schema
- `idempotency`: safe or side-effecting
- `rate_limit_hint`
- `timeout_ms`

## 3. Card States (Needed by UI)

A card should expose these states from backend:
- `disconnected`
- `auth_required`
- `connected`
- `degraded`
- `error`

And health metadata:
- last successful invocation time
- last error code/message
- quota/rate-limit indicators when available

## 4. MCP Positioning in Weaver

Use MCP as the interoperability boundary:
- Weaver runtime can call local Python tools directly.
- The same tools can be exposed through MCP-compatible adapters.
- Third-party MCP tool servers can be mounted into Weaver catalog.

Result:
- You are not locked to one execution style.
- Cards remain stable because contract remains stable.

## 5. Execution Event Model for Trace View

For every tool call, emit events:
- `tool_call_started`
- `tool_call_input_validated`
- `tool_call_dispatched`
- `tool_call_succeeded` or `tool_call_failed`
- `tool_call_completed`

Event payload should contain:
- run_id
- trace_id
- parent_span_id
- tool_id
- summarized input (with secrets redacted)
- latency_ms
- status
- error details (if any)

## 6. Safety Requirements

- Redact secrets from traces/logs.
- Require explicit confirmation for destructive local file actions.
- Add allowlist path boundaries for file tools.
- Enforce per-tool timeout and retry policy.
- Persist audit events for side-effecting operations.
