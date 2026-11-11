"""PostgreSQL only: the generated ``search_vector`` column, its GIN index and a trigram index on the
title (typos). Other databases do nothing. Existing data is indexed by ``manage.py reindex`` (``make
migrate`` runs it), not here: a migration must not use the live models."""

from django.db import migrations

VECTOR = """
ALTER TABLE search_searchentry ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', title), 'A') || setweight(to_tsvector('simple', body), 'B')
) STORED;
CREATE INDEX search_vector_gin ON search_searchentry USING gin (search_vector);
CREATE INDEX search_title_trgm ON search_searchentry USING gin (title gin_trgm_ops);
"""
DROP = """
DROP INDEX IF EXISTS search_title_trgm;
DROP INDEX IF EXISTS search_vector_gin;
ALTER TABLE search_searchentry DROP COLUMN IF EXISTS search_vector;
"""


def create(apps, schema_editor):  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor != "postgresql":
        return
    schema_editor.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
    schema_editor.execute(VECTOR)


def remove(apps, schema_editor):  # type: ignore[no-untyped-def]
    if schema_editor.connection.vendor == "postgresql":
        schema_editor.execute(DROP)


class Migration(migrations.Migration):
    dependencies = [("search", "0001_initial")]

    operations = [
        migrations.RunPython(create, remove),
    ]
