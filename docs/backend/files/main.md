# Source Code Guide: `app/main.py`

The `main.py` file is the entry point for the FastAPI backend. It's responsible for the "Wiring" of the application—bringing together the API routes, global configurations, and essential startup services.

For Python developers, this is analogous to the `if __name__ == "__main__":` block, but specifically tailored for a web server context.

---

## 1. Complete Code

```python
from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.logging import configure_logging
from app.core.tracing import configure_tracing
from app.services.tools import register_native_handlers

# 1. Immediate Configuration
configure_logging()
configure_tracing()
register_native_handlers()

# 2. Application Instance
app = FastAPI(
    title="Weaver Backend",
    version="0.1.0",
    description="The orchestration engine for the Weaver platform."
)

# 3. Router Mounting
app.include_router(api_router)

# 4. Global Health Endpoint
@app.get("/health")
async def health() -> dict[str, str]:
    """
    Used by the Flutter frontend to verify backend availability.
    """
    return {"status": "ok"}
```

---

## 2. Line-by-Line Deep Dive

### The Imports

- **Line 1**: `from fastapi import FastAPI`
  - **What**: Imports the core class that manages the web application.
  - **Why**: FastAPI is built on top of Starlette and Pydantic. It handles request routing, data validation, and automatic OpenAPI (Swagger) documentation generation.

- **Line 3**: `from app.api.v1.router import api_router`
  - **What**: Imports the "Master Router". 
  - **Why**: Instead of defining all endpoints in one file, we group them in the `api/` directory. This keeps the entry point clean.

- **Line 4-6**: `configure_logging`, `configure_tracing`, `register_native_handlers`
  - **What**: Specialized initialization functions.
  - **Why**: 
    - `logging`: Sets up structured logs (JSON format usually) so we can debug agent behavior.
    - `tracing`: Sets up OpenTelemetry. This is critical for agents because we need to see the "path" a request took through various LLM calls and tool executions.
    - `register_native_handlers`: Weaver allows the LLM to use "Tools" (like reading a file or sending a Discord message). These tools need to be "registered" in a global registry before the app starts.

---

### Bootstrapping Services

- **Lines 9-11**: Global function calls.
  - **Execution Order**: These are called at the module level (the top of the file). In Python, when you run `uvicorn app.main:app`, Python imports `app.main`. During the import, these lines execute immediately.
  - **Criticality**: If `register_native_handlers()` isn't called here, the agent will appear "dumb" because it won't know it has access to any tools.

---

### The FastAPI Instance

- **Lines 14-18**: `app = FastAPI(...)`
  - **Metadata**: We provide a `title` and `version`. 
  - **Auto-Docs**: You can view the automatic documentation by visiting `http://localhost:8000/docs` while the server is running. This is a huge time-saver for frontend developers (Flutter) to see what data the backend expects.

---

### Routing & Endpoints

- **Line 21**: `app.include_router(api_router)`
  - **Mounting**: This tells FastAPI to take all the paths defined in `api_router` and make them available under the main application. 
  - **Structure**: If `api_router` has a path `/chat`, it becomes available at `http://localhost:8000/chat`.

- **Lines 24-28**: `async def health() -> dict[str, str]:`
  - **Async**: FastAPI is built for `async/await`. This allows the server to handle thousands of concurrent requests without blocking.
  - **Health Check**: This is a standard pattern in microservices. The Flutter app pings this every few seconds to show the "Backend Online" green dot in the status bar.

---

## 3. Educational Callouts

> [!TIP]
> **Python vs. Dart Entry Points**:
> In Python, we often use `main.py` as the entry point. In Dart/Flutter, it's `main.dart`. The main difference is that Dart requires a `void main()` function, whereas Python executes anything at the top level of the script being run.

---

## Key References
- [FastAPI: Bigger Applications - Multiple Files](https://fastapi.tiangolo.com/tutorial/bigger-applications/)
- [Asyncio in Python](https://docs.python.org/3/library/asyncio.html)
- [OpenTelemetry Python Instrumentation](https://opentelemetry.io/docs/instrumentation/python/)
