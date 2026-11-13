from celery import shared_task

from infrastructure.developer import delivery


@shared_task(name="infrastructure.developer.deliver")
def deliver(delivery_id: str) -> bool:
    """The first try of one webhook delivery (inline in debug); later tries are the due worker's."""
    return delivery.attempt(delivery_id) is not None
