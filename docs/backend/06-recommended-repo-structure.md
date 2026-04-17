# Recommended Backend Repository Structure

Below is a practical structure for Weaver backend.

```text
backend/
  pyproject.toml
  uv.lock
  alembic.ini
  .env.example
  docker-compose.yml
  app/
    main.py
    api/
      v1/
        routes/
          auth.py
          tools.py
          runs.py
          automations.py
    core/
      config.py
      security.py
      logging.py
      tracing.py
    db/
      base.py
      models/
      session.py
      migrations/
    schemas/
    services/
      auth/
      tools/
      providers/
        filesystem/
        google/
        discord/
      orchestration/
        langgraph/
      automations/
      tracing/
    mcp/
      adapters/
      registry/
    workers/
      tasks/
  tests/
    unit/
    integration/
```

## Why this layout

- Keeps provider-specific logic isolated.
- Preserves a stable service layer for API and worker reuse.
- Makes it easier to export MCP-compatible adapters.
- Supports incremental growth into multi-agent + automation engine.
