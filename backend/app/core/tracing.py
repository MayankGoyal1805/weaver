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
