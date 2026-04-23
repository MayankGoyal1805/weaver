# Backend Module Overview

The `backend/app/` directory is organized into logical modules. Each module has a specific responsibility in the system.

## Directory Structure

- `api/`: API route definitions and versioning.
- `core/`: Global configuration, logging, and tracing.
- `db/`: Database models, session management, and migrations.
- `mcp/`: (Model Context Protocol) Implementation for standardized AI tool interaction.
- `schemas/`: Pydantic models for data validation and API contracts.
- `services/`: Business logic, LLM orchestration, and tool integrations.
- `workers/`: Background task processing logic.
- `main.py`: Entry point for the FastAPI application.
- `cli.py`: Command-line interface for managing and testing the backend.

---

## Detailed Module Descriptions

### 1. `api/`
This module contains the endpoint definitions. It is typically structured by version (e.g., `v1/`).
- `router.py`: Aggregates all sub-routers.
- `routes/`: Contains logic for specific domains like `chat`, `tools`, `auth`, etc.

### 2. `core/`
The "brain" of the configuration.
- `config.py`: Handles environment variables and app-wide settings.
- `logging.py`: Configures structured logging.
- `tracing.py`: Sets up OpenTelemetry for performance monitoring.

### 3. `db/`
Handles persistence.
- `base.py`: The SQLAlchemy declarative base.
- `session.py`: Database connection and session factory.
- `models/`: Database table definitions.

### 4. `schemas/`
Defines the "shape" of data.
- **Request Schemas**: What the API expects from the frontend.
- **Response Schemas**: What the API returns to the frontend.
- **Shared Models**: Common types used across the application.

### 5. `services/`
Where the heavy lifting happens.
- `llm.py`: Interaction with Large Language Models.
- `tools.py`: The tool registration and execution framework.
- `providers/`: Integration logic for third-party services (Gmail, Discord).

### 6. `cli.py`
A powerful tool for developers. It allows running health checks, testing prompts, and managing OAuth flows directly from the terminal.

---

## Internal Dependencies

Most requests follow this internal dependency flow:
`api` -> `schemas` -> `services` -> `db` / `external APIs`
