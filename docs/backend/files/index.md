# Backend Source Code Index

This guide provides a file-by-file breakdown of the Weaver backend. Click on any file to see its complete source code and a line-by-line explanation of how it works.

---

## 🚀 Entry Point
- [**main.py**](main.md): The bootstrapping logic and API initialization.

## ⚙️ Core Configuration
- [**config.py**](core/config.md): Environment variables and Pydantic settings.
- [**logging.py**](core/logging.md): Structured JSON logging setup.
- [**security.py**](core/security.md): JWT token generation and hashing.
- [**tracing.py**](core/tracing.md): OpenTelemetry and request tracing.

## 🛣️ API Routes (v1)
- [**router.py**](api/v1/router.md): The master router aggregation.
- [**auth.py**](api/v1/routes/auth.md): OAuth 2.0 flows for Google and Discord.
- [**tools.py**](api/v1/routes/tools.md): Tool discovery and catalog management.
- [**chat.py**](api/v1/routes/chat.md): Intelligence hub and agentic prompt logic.
- [**runs.py**](api/v1/routes/runs.md): Real-time tool execution and trace streaming.

## 🗄️ Database & Models
- [**base.py**](db/base.md): The SQLAlchemy declarative base.
- [**session.py**](db/session.md): Database connection and engine management.
- [**user.py**](db/models/user.md): The User identity model.
- [**tool.py**](db/models/tool.md): Tool definitions and encrypted connection storage.
- [**run.py**](db/models/run.md): Execution history and event logs.

## 🛠️ Services & Logic
- [**llm.py**](services/llm.md): High-level wrapper for AI model interactions.
- [**tools.py**](services/tools.md): The tool execution and registration service.
- [**google_service.py**](services/providers/google_service.md): Low-level Gmail and Drive API client.
- [**token_store.py**](services/providers/token_store.md): Persistent local storage for OAuth tokens.
- [**langgraph.py**](services/orchestration/langgraph.md): State machine logic for tool execution.
- [**event_bus.py**](services/tracing/event_bus.md): Async message relay for real-time logs.

---

## 🧩 Shared Schemas (Pydantic)
- [**tooling.py**](schemas/tooling.md): Data contracts for tool execution.
- [**chat.py**](schemas/chat.md): Data contracts for agent communication.

---

### [← Back to Documentation Hub](../README.md)
