from django.db import migrations


def blank_seeded_locale(apps, schema_editor):
    """``en-us`` was only ever the signup seed (a chosen language is stored bare)."""
    apps.get_model("accounts", "Profile").objects.filter(locale="en-us").update(locale="")


class Migration(migrations.Migration):
    dependencies = [("accounts", "0002_localization")]
    operations = [migrations.RunPython(blank_seeded_locale, migrations.RunPython.noop)]
