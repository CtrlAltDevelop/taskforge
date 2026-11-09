"""Phase 07 (2/3): point every task at the project status its old word meant.

Every project that has tasks gets the default workflow (To do / In progress / Done) and each task
is pointed at the status its old word meant, so nothing changes for anyone. Projects without tasks
get their workflow the first time they are opened.
"""

from django.db import migrations

from infrastructure.workflows.defaults import create_default_statuses

CATEGORY_TO_LEGACY = {
    "not_started": "todo",
    "active": "in_progress",
    "done": "done",
    "cancelled": "done",
}


def to_statuses(apps, schema_editor):  # type: ignore[no-untyped-def]
    task_model = apps.get_model("tasks", "Task")
    workflow_model = apps.get_model("workflows", "Workflow")
    status_model = apps.get_model("workflows", "Status")
    project_ids = task_model.objects.values_list("project_id", flat=True).distinct()
    for project_id in list(project_ids):
        workflow_model.objects.get_or_create(project_id=project_id)
        statuses = status_model.objects.filter(project_id=project_id)
        by_legacy = (
            {
                legacy: status_model.objects.get(project_id=project_id, name=name)
                for legacy, name in (
                    ("todo", "To do"),
                    ("in_progress", "In progress"),
                    ("done", "Done"),
                )
            }
            if statuses.exists()
            else create_default_statuses(status_model, project_id)
        )
        for legacy, status in by_legacy.items():
            task_model.objects.filter(project_id=project_id, status=legacy).update(
                status_ref=status
            )


def to_words(apps, schema_editor):  # type: ignore[no-untyped-def]
    task_model = apps.get_model("tasks", "Task")
    for category, legacy in CATEGORY_TO_LEGACY.items():
        task_model.objects.filter(status_ref__category=category).update(status=legacy)


class Migration(migrations.Migration):
    dependencies = [("tasks", "0002_status_ref")]

    operations = [migrations.RunPython(to_statuses, to_words)]
