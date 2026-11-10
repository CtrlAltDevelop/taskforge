"""A GIN index on the multi-select values, so "has this option" can use an index (PostgreSQL only;
other databases have no such index kind and answer with a scan)."""

from django.db import migrations


def add_index(apps, schema_editor) -> None:  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(
            "CREATE INDEX fv_json_gin_idx ON customfields_fieldvalue USING gin (value_json jsonb_path_ops)"
        )


def drop_index(apps, schema_editor) -> None:  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute("DROP INDEX IF EXISTS fv_json_gin_idx")


class Migration(migrations.Migration):
    dependencies = [("customfields", "0001_initial")]
    operations = [migrations.RunPython(add_index, drop_index)]
