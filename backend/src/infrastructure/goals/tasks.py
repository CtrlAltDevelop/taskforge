from celery import shared_task

from infrastructure.goals import recompute


@shared_task(name="infrastructure.goals.recompute_due", ignore_result=True)
def recompute_due() -> int:
    return recompute.process_due()
