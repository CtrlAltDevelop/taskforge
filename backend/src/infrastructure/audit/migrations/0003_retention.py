"""PostgreSQL: let a DELETE through only inside a purge (``SET LOCAL audit.purging = 'on'``, see
``retention.py``). UPDATE and every other DELETE stay refused. Other databases have no trigger."""

from django.db import migrations

ALLOW_PURGE = """
CREATE OR REPLACE FUNCTION audit_entry_immutable() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'DELETE' AND current_setting('audit.purging', true) = 'on' THEN
        RETURN OLD;
    END IF;
    RAISE EXCEPTION 'audit entries are append-only (% refused)', TG_OP
        USING ERRCODE = 'insufficient_privilege';
END;
$$ LANGUAGE plpgsql;
"""
STRICT = """
CREATE OR REPLACE FUNCTION audit_entry_immutable() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'audit entries are append-only (% refused)', TG_OP
        USING ERRCODE = 'insufficient_privilege';
END;
$$ LANGUAGE plpgsql;
"""


def forwards(apps, schema_editor):  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(ALLOW_PURGE)


def backwards(apps, schema_editor):  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(STRICT)


class Migration(migrations.Migration):
    dependencies = [("audit", "0002_immutable")]
    operations = [migrations.RunPython(forwards, backwards)]
