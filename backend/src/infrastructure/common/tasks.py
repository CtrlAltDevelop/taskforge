from celery import shared_task

from infrastructure.common import dueworkers


@shared_task(name="infrastructure.common.tick")
def tick() -> dict[str, str]:
    """The beat entry point: run every registered due worker (what `make tick` does)."""
    return {name: repr(result) for name, result in dueworkers.run_all().items()}
