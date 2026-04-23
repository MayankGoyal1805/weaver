# Source Code Guide: `app/core/logging.py`

In a production application, standard print statements are not enough. This file configures **Structured Logging** using the `structlog` library. 

Structured logs are easier for machines to read (JSON format) and provide consistent metadata (timestamps, log levels) for every entry.

---

## 1. Complete Code

```python
import logging
import structlog

def configure_logging() -> None:
    # 1. Standard Python Logging Setup
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    
    # 2. Structlog Configuration
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"), # Add ISO timestamp
            structlog.processors.add_log_level,         # Add 'info', 'error', etc.
            structlog.processors.JSONRenderer(),        # Output as JSON
        ],
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )
```

---

## 2. Line-by-Line Deep Dive

### Integration with Standard Logging

- **Line 7**: `logging.basicConfig(...)`
  - **What**: Sets the global level for Python's built-in `logging` module.
  - **Why**: Many libraries we use (like `httpx` or `sqlalchemy`) use the standard logging module. We set the level to `INFO` so we don't get flooded with `DEBUG` messages from internal libraries.

### Structlog Processors

- **Line 10**: `TimeStamper(fmt="iso")`
  - **Why**: Every log entry needs a time. ISO format (`2023-10-27T10:00:00Z`) is the standard for log analysis tools.
- **Line 12**: `JSONRenderer()`
  - **What**: This is the most important part. Instead of printing text like `INFO: User logged in`, it prints: 
    `{"event": "User logged in", "level": "info", "timestamp": "2023-10-27T..."}`.
  - **Benefit**: If you ever use a tool like Datadog, ELK stack, or even just `grep`, JSON logs are infinitely more searchable.

---

## 3. Educational Callouts

> [!TIP]
> **Why use Structlog?**
> Standard logging is "Text-based". If you want to log a dictionary of data, you have to stringify it. Structlog allows you to pass actual Python objects: `logger.info("request_finished", duration=0.5, status=200)`.

---

## Key References
- [Structlog Documentation](https://www.structlog.org/en/stable/)
- [Python Logging Module](https://docs.python.org/3/library/logging.html)
