"""Phase 07 (1/3): a nullable ``status_ref`` beside the old status word.

Split from the data copy and the clean-up because PostgreSQL refuses to ALTER a table in the same
transaction that updated rows holding deferred foreign keys ("pending trigger events").
"""

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("tasks", "0001_initial"),
        ("workflows", "0001_initial"),
    ]

    operations = [
        migrations.RemoveIndex(model_name="task", name="task_project_status_idx"),
        migrations.AddField(
            model_name="task",
            name="status_ref",
            field=models.ForeignKey(
                null=True,
                on_delete=django.db.models.deletion.PROTECT,
                related_name="tasks",
                to="workflows.status",
            ),
        ),
    ]
