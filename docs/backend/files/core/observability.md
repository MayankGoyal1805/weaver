# Source Code Guide: Backend Observability (`core/`)

This guide covers the `logging.py` and `tracing.py` files in the `core/` module. These files are essential for monitoring the application's health and performance.

---

## 1. `app/core/logging.py`

This file configures **structured logging** using the `structlog` library. Unlike standard line-based logs, structured logs are output as JSON, making them easy for machines to parse and search.

### Complete Code
```python
import logging
import structlog

def configure_logging() -> None:
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.add_log_level,
            structlog.processors.JSONRenderer(),
        ],
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )
```

### Line-by-Line Explanation
- **Line 7**: Sets the standard Python logging level to `INFO`.
- **Line 9-13**: Defines the "pipeline" of processors that every log message goes through:
    - `TimeStamper`: Adds a timestamp in ISO format.
    - `add_log_level`: Adds the level (INFO, ERROR, etc.) to the JSON object.
    - `JSONRenderer`: The final step that turns the log record into a JSON string.
- **Line 14**: Integrates `structlog` with the standard library's logger factory.

---

## 2. `app/core/tracing.py`

This file sets up **OpenTelemetry**, a standard for distributed tracing. Tracing allows you to see exactly how long each part of a request (like a database query or an LLM call) takes.

### Complete Code
```python
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

TRACER_NAME = "weaver-backend"

def configure_tracing() -> None:
    provider = TracerProvider(resource=Resource.create({"service.name": TRACER_NAME}))
    provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
    trace.set_tracer_provider(provider)

def get_tracer():
    return trace.get_tracer(TRACER_NAME)
```

### Line-by-Line Explanation
- **Line 7**: Sets a global name for our tracer.
- **Line 11**: Initializes a `TracerProvider`. The "Resource" identifies this specific service.
- **Line 12**: Adds a "Processor". In this case, we use `ConsoleSpanExporter`, which prints the traces to the terminal. In production, you would replace this with an exporter for Jaeger or Honeycomb.
- **Line 17**: `get_tracer()` is used by other parts of the app to create "spans" (units of work) to measure specific functions.

---

## Why use Observability?
In a multi-agent system, requests can be complex. You might have an LLM call that triggers three tool calls, which in turn perform database operations. Without logging and tracing, it is nearly impossible to figure out why a specific request was slow or why it failed.

## Key References
- [Structlog Documentation](https://www.structlog.org/)
- [OpenTelemetry Python SDK](https://opentelemetry.io/docs/instrumentation/python/)
