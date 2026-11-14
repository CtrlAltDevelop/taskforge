"""``GET /metrics`` in the Prometheus text exposition format.

Gauges only, computed when scraped: nothing here keeps a counter in process memory, because
under several workers a per-process counter is a wrong number. Request rates and latency come
from the reverse proxy (Caddy exposes its own metrics).
"""

from collections.abc import Mapping

from infrastructure.system import status
from infrastructure.system.version import server_version

_STATE_UP = {"ok": 1, "in_memory": 1, "not_configured": 0, "unavailable": 0}


def _escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def _line(name: str, value: float, labels: Mapping[str, str] | None = None) -> str:
    rendered = ""
    if labels:
        rendered = "{" + ",".join(f'{k}="{_escape(v)}"' for k, v in labels.items()) + "}"
    return f"{name}{rendered} {value}"


def render() -> str:
    from infrastructure.common.services import health_service

    health = status.queue_health()
    lines = [
        "# HELP taskforge_info Build information; the value is always 1.",
        "# TYPE taskforge_info gauge",
        _line("taskforge_info", 1, {"version": server_version()}),
        "# HELP taskforge_database_up 1 when the database answers a query.",
        "# TYPE taskforge_database_up gauge",
        _line("taskforge_database_up", 1 if health_service.database_is_ready() else 0),
        "# HELP taskforge_redis_up 1 when Redis answers a ping.",
        "# TYPE taskforge_redis_up gauge",
        _line("taskforge_redis_up", _STATE_UP[health.redis]),
        "# HELP taskforge_broker_up 1 when the Celery broker accepts a connection.",
        "# TYPE taskforge_broker_up gauge",
        _line("taskforge_broker_up", _STATE_UP[health.broker]),
        "# HELP taskforge_due_backlog Due-work rows whose time has come and are not handled.",
        "# TYPE taskforge_due_backlog gauge",
        *(_line("taskforge_due_backlog", n, {"kind": kind}) for kind, n in health.backlog.items()),
    ]
    return "\n".join(lines) + "\n"
