"""Existing members were never shown a first-run checklist: mark theirs dismissed, so the
"Getting started" card only appears for people who join (or create a workspace) from now on."""

from django.db import migrations
from django.utils import timezone

BATCH = 1000


def dismiss_for_members(apps, schema_editor):
    member = apps.get_model("workspaces", "WorkspaceMember")
    onboarding = apps.get_model("home", "UserOnboarding")
    now = timezone.now()
    pairs = member.objects.values_list("user_id", "workspace_id").iterator(chunk_size=BATCH)
    batch = []
    for user_id, workspace_id in pairs:
        batch.append(onboarding(user_id=user_id, workspace_id=workspace_id, dismissed_at=now))
        if len(batch) >= BATCH:
            onboarding.objects.bulk_create(batch, ignore_conflicts=True)
            batch = []
    onboarding.objects.bulk_create(batch, ignore_conflicts=True)


class Migration(migrations.Migration):
    dependencies = [
        ("home", "0001_initial"),
        ("workspaces", "0001_initial"),
    ]

    operations = [migrations.RunPython(dismiss_for_members, migrations.RunPython.noop)]
