"""PostgreSQL refuses UPDATE and DELETE on the audit table, whatever role asks (the app's own
included). TRUNCATE stays possible so a test database can be reset. Other databases rely on the
model and queryset guards."""

from django.db import migrations

CREATE = """
CREATE FUNCTION audit_entry_immutable() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'audit entries are append-only (% refused)', TG_OP
        USING ERRCODE = 'insufficient_privilege';
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER audit_entry_no_change
    BEFORE UPDATE OR DELETE ON audit_auditentry
    FOR EACH ROW EXECUTE FUNCTION audit_entry_immutable();
"""
DROP = """
DROP TRIGGER IF EXISTS audit_entry_no_change ON audit_auditentry;
DROP FUNCTION IF EXISTS audit_entry_immutable();
"""


def forwards(apps, schema_editor):  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(CREATE)


def backwards(apps, schema_editor):  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(DROP)


class Migration(migrations.Migration):
    dependencies = [("audit", "0001_initial")]
    operations = [migrations.RunPython(forwards, backwards)]
