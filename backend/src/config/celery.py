"""The Celery app.

In debug (`config.settings.development`) tasks run eagerly, inline in the caller, so no worker or
broker is needed. In production a worker and `beat` run against Redis (see `CELERY_*` in the
settings). Delayed work is never held in a broker: it is a database row with a due time, drained by
a function registered in `infrastructure.common.dueworkers`, which `make tick` and the beat `tick`
task both call. Define a task with `@shared_task` in an app's `tasks.py`; it is autodiscovered.
"""

import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.development")

app = Celery("taskforge")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
