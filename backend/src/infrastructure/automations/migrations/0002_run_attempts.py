from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("automations", "0001_initial")]

    operations = [
        migrations.AddField(
            model_name="automationrun",
            name="attempts",
            field=models.PositiveSmallIntegerField(default=1),
        ),
    ]
