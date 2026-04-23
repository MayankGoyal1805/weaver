# Installation & Setup Guide: Weaver

This guide provides a comprehensive walkthrough for setting up the Weaver development environment. Weaver is a sophisticated platform combining a **Python (FastAPI)** backend and a **Dart (Flutter)** frontend. 

For someone coming from a pure Python background, some of the frontend tools might be new. We have included explanations for why these specific tools are used.

---

## 1. Prerequisites

Before you begin, ensure you have the following installed on your system:

### 1.1 Python 3.10+ & `uv`
We use `uv` for Python package management. 
- **Why `uv`?**: In the Python ecosystem, tools like `pip`, `venv`, and `poetry` are common. `uv` is an extremely fast replacement written in Rust. It manages virtual environments and dependencies much faster than standard tools.
- **Installation**: [Install uv](https://github.com/astral-sh/uv#installation)

### 1.2 Flutter SDK (Stable)
Flutter is Google's UI toolkit for building natively compiled applications.
- **Dart Language**: Flutter uses the Dart programming language. If you know Python, you'll find Dart's syntax familiar but more structured (it's statically typed).
- **Installation**: [Install Flutter](https://docs.flutter.dev/get-started/install)

### 1.3 Operating System: Linux
While Flutter is cross-platform, the backend "Auto-Start" and native tool integrations are optimized for Linux (Ubuntu/Fedora/etc.). 

### 1.4 API Keys
You will need:
- **OpenAI API Key**: To power the agent's logic. (Weaver also supports OpenAI-compatible endpoints like DeepSeek or local LLMs).
- **Optional**: Discord Bot Token, Google Cloud Credentials (for Gmail/Drive tools).

---

## 2. Backend Setup

The backend handles the "brain" of the application: agent orchestration, tool execution, and database management.

### Step 2.1: Initialize the Environment
Navigate to the `backend/` directory and use `uv` to create a virtual environment and install dependencies.

```bash
cd backend
uv sync
```
- **What happens?**: `uv sync` reads the `pyproject.toml` file, creates a `.venv` directory, and installs all required libraries (FastAPI, LangChain, SQLAlchemy, etc.) in a fraction of the time `pip install` would take.

### Step 2.2: Configure Environment Variables
We use a `.env` file to store sensitive configuration.
```bash
cp .env.example .env
```
Open `.env` in your editor and fill in the following:

| Variable | Description | Importance |
| :--- | :--- | :--- |
| `OPENAI_API_KEY` | Your primary LLM key. | **Required** |
| `DATABASE_URL` | Defaults to `sqlite+aiosqlite:///weaver.db`. | Optional change |
| `LOG_LEVEL` | Set to `INFO` or `DEBUG`. | For troubleshooting |

### Step 2.3: Run the Development Server
```bash
uv run uvicorn app.main:app --reload --port 8000
```
- **`uv run`**: Ensures the command runs inside the virtual environment managed by `uv`.
- **`uvicorn`**: The ASGI server that runs FastAPI.
- **`--reload`**: Automatically restarts the server when you change a `.py` file. This is very similar to "Hot Reload" in development.

---

## 3. Frontend Setup

The frontend is a high-performance desktop application built with Flutter.

### Step 3.1: Install Dart Packages
Navigate to the `frontend/` directory and fetch the necessary libraries.
```bash
cd frontend
flutter pub get
```
- **`flutter pub get`**: This is equivalent to `pip install -r requirements.txt`. It reads `pubspec.yaml` and downloads the dependencies.

### Step 3.2: Run the App
Launch the application as a native Linux process:
```bash
flutter run -d linux
```
- **`-d linux`**: Specifies the target device. Since this is a desktop app, we target the host OS.

---

## 4. Connecting Frontend & Backend

Once both are running, they communicate via REST APIs and WebSockets.

1.  **Server Detection**: By default, the Flutter app looks for the backend at `http://localhost:8000`. 
2.  **Health Check**: The app calls the `/health` endpoint on the backend to confirm a connection.
3.  **Authentication**: If you are using Google or Discord tools, you will need to go to **Settings -> Auth & Tools** in the app and click "Connect". This triggers an OAuth flow handled by the backend.

---

## 5. Troubleshooting Common Issues

### "Backend not detected"
- Ensure `uvicorn` is running and bound to `127.0.0.1:8000`.
- Check if a firewall is blocking the port.

### "Flutter build failed"
- Run `flutter doctor` to ensure your Flutter installation is healthy.
- Ensure you have the necessary Linux development headers installed (`libgtk-3-dev`, `libsecret-1-dev`, etc.).

### "No module named 'app'"
- Ensure you are running the `uvicorn` command from the `backend/` directory, **not** from inside `backend/app/`.

---

## Key References
- [Official Flutter Documentation](https://docs.flutter.dev/)
- [FastAPI: Tutorial - User Guide](https://fastapi.tiangolo.com/tutorial/)
- [Uv Package Manager Guide](https://docs.astral.sh/uv/)
- [Dart for Python Developers](https://dart.dev/guides/language/coming-from/python) (Highly Recommended)
