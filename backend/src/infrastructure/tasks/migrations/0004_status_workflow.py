"""Phase 07 (3/3): drop the old status word, make the project status the status.

Phase 07 turns ``Task.status`` from three fixed words into a project status; see 0002 and 0003.
"""

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("tasks", "0003_status_data")]

    operations = [
        migrations.RemoveField(model_name="task", name="status"),
        migrations.RenameField(model_name="task", old_name="status_ref", new_name="status"),
        migrations.AlterField(
            model_name="task",
            name="status",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                related_name="tasks",
                to="workflows.status",
            ),
        ),
        migrations.AddIndex(
            model_name="task",
            index=models.Index(fields=["project", "status"], name="task_project_status_idx"),
        ),
    ]
