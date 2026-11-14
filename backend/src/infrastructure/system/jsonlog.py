"""Structured logging: one JSON object per line, for a log shipper (Loki, CloudWatch, ELK)."""

import json
import logging
from datetime import UTC, datetime
from typing import Any

# Attributes every LogRecord has; anything else was passed with `extra=` and is kept.
_STANDARD = set(vars(logging.makeLogRecord({}))) | {"message", "asctime", "taskName"}


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "time": datetime.fromtimestamp(record.created, UTC).isoformat(timespec="milliseconds"),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        for key, value in vars(record).items():
            if key not in _STANDARD and not key.startswith("_"):
                payload[key] = value
        return json.dumps(payload, default=str, ensure_ascii=False)


def logging_config(*, fmt: str, level: str) -> dict[str, Any]:
    """The ``LOGGING`` setting for a format (``json`` or ``text``) and a level."""
    formatter: dict[str, Any] = (
        {"()": "infrastructure.system.jsonlog.JsonFormatter"}
        if fmt == "json"
        else {"format": "%(asctime)s %(levelname)s %(name)s: %(message)s"}
    )
    return {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {"default": formatter},
        "handlers": {"console": {"class": "logging.StreamHandler", "formatter": "default"}},
        "root": {"handlers": ["console"], "level": level},
        "loggers": {"django.server": {"level": "WARNING"}},
    }
