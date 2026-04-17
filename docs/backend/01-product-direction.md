# Weaver Backend Product Direction (v0)

## 1. What Weaver Is

Weaver is a multi-agent and automation platform centered around **Tool Cards**.

Each Tool Card represents a capability (for example: Gmail, Google Drive, Discord, File Tools) and includes:
- Auth state
- Connection health
- Available actions
- Permissions/scopes
- Execution history
- Runtime traces

Core value proposition:
- Users can chat with an agent that uses tools.
- Users can also compose n8n-style automations using the same tool cards.
- Tool usage is transparent via trace view (showing each function/tool call and result path).

## 2. Two Primary Product Modes

### A) Agent Chat Mode
- User chats with an agent.
- Agent decides whether to call tools.
- Tool calls are logged and emitted as trace events.
- UI highlights the corresponding card when that tool is invoked.

### B) Automation Builder Mode
- User builds workflows with trigger + actions using tool cards.
- Same card catalog, same auth tokens, same tool definitions.
- Runs can be tested manually, scheduled, or trigger-based.

## 3. Why This Architecture Matters

You want one unified ecosystem instead of separate products:
- One auth model for all tools.
- One execution model for both chat and automations.
- One trace/event stream for observability.
- One card contract that drives UX and backend execution.

## 4. Initial Scope (Phase 1)

Implement first tools only:
- Local File & Directory tools
- Gmail tools
- Google Drive tools
- Discord tools

Do this with production-friendly foundations so later expansions (Classroom, Slack, Notion, etc.) are easy.

## 5. Non-Goals for Phase 1

- Full no-code workflow editor parity with n8n.
- Very large agent marketplace.
- Enterprise RBAC and SSO.

These can come after core execution, card UX, and reliability are proven.
