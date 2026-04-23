# Source Code Guide: `app/core/tracing.py`

Tracing is how we visualize the "Life of a Request." In Weaver, an agent might call several tools and LLM models. Tracing allows us to see exactly how long each part took and where errors occurred.

We use **OpenTelemetry**, the industry standard for observability.

---

## 1. Complete Code

```python
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

# 1. Name used to identify logs from this service
TRACER_NAME = "weaver-backend"

def configure_tracing() -> None:
    # 2. Setup the Provider
    provider = TracerProvider(
        resource=Resource.create({"service.name": TRACER_NAME})
    )
    
    # 3. Setup the Exporter (Where do logs go?)
    provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
    
    # 4. Set as Global
    trace.set_tracer_provider(provider)

def get_tracer():
    return trace.get_tracer(TRACER_NAME)
```

---

## 2. Line-by-Line Deep Dive

### OpenTelemetry Setup

- **Line 11**: `TracerProvider(resource=...)`
  - **What**: The central factory for creating "Spans" (timing blocks).
  - **Resource**: We tag everything with the service name `weaver-backend`. If we had 10 different microservices, this is how we'd distinguish them in a tracing UI like Jaeger.

- **Line 12**: `BatchSpanProcessor(ConsoleSpanExporter())`
  - **Exporter**: Currently, we are just printing traces to the **Console** (`ConsoleSpanExporter`).
  - **Batching**: Instead of printing every single line immediately (which is slow), `BatchSpanProcessor` groups them together and prints them in chunks.

- **Line 17**: `get_tracer()`
  - **Usage**: Other files call this to start measuring things. 
  - **Example**:
    ```python
    tracer = get_tracer()
    with tracer.start_as_current_span("llm_call"):
        # run LLM logic here
    ```

---

## 3. Educational Callouts

> [!TIP]
> **Logs vs. Traces**:
> **Logs** are single events: "User clicked button."
> **Traces** are connected events: "User clicked button -> API called -> DB queried -> Response sent." Traces show the **Relationship** and the **Time** between events.

---

## Key References
- [OpenTelemetry Python Documentation](https://opentelemetry.io/docs/instrumentation/python/)
- [Observability: Logs, Metrics, and Traces](https://www.honeycomb.io/blog/observability-logs-metrics-traces)
