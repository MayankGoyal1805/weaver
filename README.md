# Weaver

Weaver is a multi-agent automation platform and chat interface built around a "tool card" philosophy. It allows you to run AI chat agents that can interact natively with your filesystem and external services like Google Workspace (Gmail, Drive) and Discord.

Unlike traditional web-based LLM wrappers, Weaver splits its architecture into a powerful Python-based local orchestrator and a fast, native Flutter desktop frontend. This enables true local file access and background task automation while keeping the UI snappy.

## Overview

* **Agent Backend**: Written in Python using FastAPI, LangGraph, and a local SQLite database. It orchestrates tool calls, handles LLM context window budgeting, and manages OAuth states.
* **Native Desktop Client**: Written in Dart using Flutter. Provides the persistent chat interface, configurable model settings, and dynamic tool cards to toggle integrations on and off.
* **Bring Your Own Keys**: Supports any OpenAI-compatible API endpoint (OpenAI, DeepSeek, Groq, local models via LM Studio/Ollama).

## Tech Stack

* **Backend**: Python 3.10+, FastAPI, SQLAlchemy (SQLite), Alembic, Pydantic, LangGraph. Dependency management is handled by `uv`.
* **Frontend**: Flutter (Linux, macOS, Windows support), Provider for state management.

## Setup Instructions

### Prerequisites
* [uv](https://github.com/astral-sh/uv) (for fast Python package installation)
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* An API key for an OpenAI-compatible LLM provider.

### 1. Backend Setup

The backend handles the agent orchestration, tool execution, and local database.

```bash
cd backend

# Install dependencies using uv
uv sync

# Setup your environment variables
cp .env.example .env
```

Edit the `.env` file to add your API keys. Next, initialize the local database:

```bash
# This creates a local SQLite file (weaver.db) and applies all schema migrations
uv run alembic upgrade head
```

Start the backend server:

```bash
uv run uvicorn app.main:app --reload --port 8000
```
The backend will run on `http://127.0.0.1:8000`.

### 2. Frontend Setup

In a new terminal window, build and run the Flutter desktop application.

```bash
cd frontend

# Fetch Dart dependencies
flutter pub get

# Run the app natively on your host OS
flutter run -d linux  # Replace 'linux' with 'macos' or 'windows' depending on your OS
```

## Configuring Integrations

Once the app is running, you can manage integrations via the UI:
* Go to the **Settings** or use the **Tool Cards** in the right sidebar.
* **Google (Gmail/Drive)**: Requires a Google Cloud Client ID and Secret in your `.env`. Click "Connect" in the UI to complete the OAuth flow.
* **Discord**: Requires a Discord Bot Token. Configure a default channel to let Weaver send messages on your behalf.
* **Filesystem**: Configured strictly via the `ALLOWED_FILE_ROOT` variable in your `.env` to prevent the agent from wandering outside your designated workspace.

## License

MIT