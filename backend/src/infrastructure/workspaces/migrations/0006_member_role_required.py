import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0005_seed_roles")]
    operations = [
        migrations.AlterField(
            model_name="workspacemember",
            name="role",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                related_name="members",
                to="workspaces.role",
            ),
        ),
    ]
