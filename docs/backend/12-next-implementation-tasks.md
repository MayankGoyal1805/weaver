# Next Implementation Tasks (Priority)

## P0 (Security + Durability)

1. Persist OAuth token bundles in `tool_connections` with encryption.
2. Add auth middleware and user identity binding to tool execution.
3. Add DB-backed run and event persistence in tool execution path.
4. Add provider-specific error mapping and retry policy.

## P1 (Feature Completeness)

1. Gmail tools:
   - read thread/message
   - create/send draft
2. Drive tools:
   - upload/download
   - get file metadata/details
3. Discord tools:
   - list guild channels
   - read recent channel messages where permitted

## P1 (Automation Convergence)

1. Add automation schema (nodes, edges, triggers).
2. Add scheduler/trigger processor worker.
3. Reuse same tool execution service from chat and automations.

## P2 (Multi-Agent Manager)

1. Add coordinator/supervisor agent with routing policy.
2. Add specialist agents (filesystem, communication, planning).
3. Add handoff trace events and visualizer payloads.

## P2 (Frontend Contract Enhancements)

1. Add card health endpoint backed by real provider diagnostics.
2. Add per-tool execution stats for card UI.
3. Add stream compression and reconnect semantics for trace SSE.
