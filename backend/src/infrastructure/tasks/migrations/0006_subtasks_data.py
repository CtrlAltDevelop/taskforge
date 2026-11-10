"""Phase 08 (2/2): every existing task is a top-level task with its own path and tree key.

Separate from 0005 (which adds the columns) because PostgreSQL refuses to ALTER a table in the
transaction that has just updated its rows.
"""

from django.db import migrations

BATCH = 1000
SEP = "0"  # tasks.tree.SEP, frozen here: a migration must not follow later changes


def fill(apps, schema_editor):  # type: ignore[no-untyped-def]
    task_model = apps.get_model("tasks", "Task")
    pending = []
    for task in (
        task_model.objects.filter(path="").only("id", "position").iterator(chunk_size=BATCH)
    ):
        task.path = f"{task.id}/"
        task.tree_key = f"{task.position}{SEP}"
        pending.append(task)
        if len(pending) >= BATCH:
            task_model.objects.bulk_update(pending, ["path", "tree_key"])
            pending = []
    if pending:
        task_model.objects.bulk_update(pending, ["path", "tree_key"])


class Migration(migrations.Migration):
    dependencies = [("tasks", "0005_subtasks")]

    operations = [migrations.RunPython(fill, migrations.RunPython.noop)]
