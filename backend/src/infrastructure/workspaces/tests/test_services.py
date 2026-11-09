"""Workspace rules: slugs, ownership, soft delete, versions."""

from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import services
from infrastructure.workspaces.models import Workspace


def test_create_makes_the_creator_the_sole_member(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    assert workspace.created_by == alice
    assert list(workspace.members.values_list("user", flat=True)) == [alice.pk]
    assert workspace.version == 1


@pytest.mark.parametrize(
    "slug", ["ab", "a" * 41, "-abc", "abc-", "ABC", "a_b", "a b", "api", "admin", "www", "login"]
)
def test_create_rejects_bad_or_reserved_slugs(alice: Any, slug: str) -> None:
    with pytest.raises(ApiError) as refusal:
        services.create(alice, "Acme", slug)

    assert refusal.value.title is ResponseTitle.SLUG_INVALID


def test_create_accepts_the_slug_boundaries(alice: Any) -> None:
    services.create(alice, "Short", "abc")
    services.create(alice, "Long", "a" + "b" * 38 + "c")


def test_create_rejects_a_blank_name(alice: Any) -> None:
    with pytest.raises(ApiError) as refusal:
        services.create(alice, "   ", "acme")

    assert refusal.value.status == 400


def test_slug_is_unique(alice: Any, bob: Any) -> None:
    services.create(alice, "Acme", "acme")

    with pytest.raises(ApiError) as refusal:
        services.create(bob, "Other", "acme")

    assert refusal.value.status == 409
    assert refusal.value.title is ResponseTitle.SLUG_TAKEN


def test_list_mine_only_returns_my_live_workspaces(alice: Any, bob: Any) -> None:
    mine = services.create(alice, "Mine", "mine")
    gone = services.create(alice, "Gone", "gone")
    services.create(bob, "Theirs", "theirs")
    services.delete(alice, str(gone.id), "Gone")

    assert [w.id for w in services.list_mine(alice)] == [mine.id]


def test_rename_bumps_the_version(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    renamed = services.rename(alice, str(workspace.id), "Acme Inc", expected_version=1)

    assert (renamed.name, renamed.version) == ("Acme Inc", 2)


def test_stale_expected_version_is_a_conflict(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    services.rename(alice, str(workspace.id), "One", expected_version=1)

    with pytest.raises(ApiError) as refusal:
        services.rename(alice, str(workspace.id), "Two", expected_version=1)

    assert refusal.value.status == 409
    assert refusal.value.title is ResponseTitle.VERSION_CONFLICT
    assert Workspace.objects.get(pk=workspace.pk).name == "One"


def test_change_slug_checks_rules_and_uniqueness(alice: Any) -> None:
    first = services.create(alice, "A", "first")
    services.create(alice, "B", "second")

    with pytest.raises(ApiError):
        services.change_slug(alice, str(first.id), "second", expected_version=1)
    with pytest.raises(ApiError):
        services.change_slug(alice, str(first.id), "admin", expected_version=1)
    changed = services.change_slug(alice, str(first.id), "third", expected_version=1)

    assert changed.slug == "third"


def test_update_applies_name_and_slug_together(alice: Any) -> None:
    workspace = services.create(alice, "A", "first")

    updated = services.update(alice, str(workspace.id), 1, name="B", slug="second")

    assert (updated.name, updated.slug) == ("B", "second")


def test_update_is_all_or_nothing(alice: Any) -> None:
    workspace = services.create(alice, "A", "first")

    with pytest.raises(ApiError):
        services.update(alice, str(workspace.id), 1, name="B", slug="admin")

    assert Workspace.objects.get(pk=workspace.pk).name == "A"


def test_delete_needs_the_typed_name(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    with pytest.raises(ApiError) as refusal:
        services.delete(alice, str(workspace.id), "acme")

    assert refusal.value.title is ResponseTitle.CONFIRMATION_MISMATCH


def test_delete_is_soft_and_keeps_the_slug(alice: Any, bob: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    services.delete(alice, str(workspace.id), "Acme")

    assert Workspace.objects.get(pk=workspace.pk).deleted_at is not None
    with pytest.raises(ApiError) as refusal:
        services.create(bob, "Other", "acme")
    assert refusal.value.title is ResponseTitle.SLUG_TAKEN


def test_restore_brings_it_back_within_seven_days(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    services.delete(alice, str(workspace.id), "Acme")
    Workspace.objects.filter(pk=workspace.pk).update(
        deleted_at=timezone.now() - timedelta(days=6, hours=23)
    )

    restored = services.restore(alice, str(workspace.id))

    assert restored.deleted_at is None
    assert [w.id for w in services.list_mine(alice)] == [workspace.id]


def test_restore_after_seven_days_is_gone(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    services.delete(alice, str(workspace.id), "Acme")
    Workspace.objects.filter(pk=workspace.pk).update(
        deleted_at=timezone.now() - timedelta(days=7, minutes=1)
    )

    with pytest.raises(ApiError) as refusal:
        services.restore(alice, str(workspace.id))

    assert refusal.value.status == 410


def test_restoring_a_live_workspace_is_refused(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    with pytest.raises(ApiError) as refusal:
        services.restore(alice, str(workspace.id))

    assert refusal.value.status == 400


def test_purge_expired_frees_the_slug(alice: Any, bob: Any) -> None:
    old = services.create(alice, "Old", "old")
    recent = services.create(alice, "Recent", "recent")
    services.delete(alice, str(old.id), "Old")
    services.delete(alice, str(recent.id), "Recent")
    Workspace.objects.filter(pk=old.pk).update(deleted_at=timezone.now() - timedelta(days=8))

    purged = services.purge_expired()

    assert purged == 1
    assert not Workspace.objects.filter(pk=old.pk).exists()
    assert Workspace.objects.filter(pk=recent.pk).exists()
    services.create(bob, "New", "old")


def test_non_owner_cannot_mutate(alice: Any, bob: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    workspace.members.create(user=bob)

    for call in (
        lambda: services.rename(bob, str(workspace.id), "X", expected_version=1),
        lambda: services.delete(bob, str(workspace.id), "Acme"),
    ):
        with pytest.raises(ApiError) as refusal:
            call()
        assert refusal.value.status == 403


def test_outsider_and_missing_id_are_indistinguishable(alice: Any, bob: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    errors = []
    for target in (str(workspace.id), "00000000-0000-0000-0000-000000000000", "not-a-uuid"):
        with pytest.raises(ApiError) as refusal:
            services.rename(bob, target, "X", expected_version=1)
        errors.append((refusal.value.status, refusal.value.title, str(refusal.value)))

    assert len(set(errors)) == 1 and errors[0][0] == 403


PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 32


def test_set_logo_stores_a_valid_image(alice: Any, tmp_path: Any, settings: Any) -> None:
    settings.MEDIA_ROOT = tmp_path
    workspace = services.create(alice, "Acme", "acme")

    updated = services.set_logo(alice, str(workspace.id), PNG)

    assert updated.logo.name.endswith(".png")
    assert updated.version == 2


@pytest.mark.parametrize(
    "content", [b"GIF89a....", b"", b"\x89PNG\r\n\x1a\n" + b"0" * (2 * 1024 * 1024)]
)
def test_set_logo_rejects_non_images_and_oversize(
    alice: Any, tmp_path: Any, settings: Any, content: bytes
) -> None:
    settings.MEDIA_ROOT = tmp_path
    workspace = services.create(alice, "Acme", "acme")

    with pytest.raises(ApiError) as refusal:
        services.set_logo(alice, str(workspace.id), content)

    assert refusal.value.title is ResponseTitle.UPLOAD_INVALID


def test_list_deleted_shows_only_own_recent_deletions(alice: Any, bob: Any) -> None:
    mine = services.create(alice, "Mine", "mine")
    stale = services.create(alice, "Stale", "stale")
    services.create(alice, "Live", "live")
    theirs = services.create(bob, "Theirs", "theirs")
    for row, name in ((mine, "Mine"), (stale, "Stale")):
        services.delete(alice, str(row.id), name)
    services.delete(bob, str(theirs.id), "Theirs")
    Workspace.objects.filter(pk=stale.pk).update(deleted_at=timezone.now() - timedelta(days=8))

    assert [w.id for w in services.list_deleted(alice)] == [mine.id]


def test_purge_expired_removes_the_logo_file(alice: Any, tmp_path: Any, settings: Any) -> None:
    settings.MEDIA_ROOT = tmp_path
    workspace = services.create(alice, "Old", "old")
    row = services.set_logo(alice, str(workspace.id), b"\x89PNG\r\n\x1a\n" + b"0" * 8)
    path = tmp_path / row.logo.name
    assert path.exists()
    services.delete(alice, str(workspace.id), "Old")
    Workspace.objects.filter(pk=workspace.pk).update(deleted_at=timezone.now() - timedelta(days=8))

    services.purge_expired()

    assert not path.exists()


def test_purge_workspaces_command_reports_count(alice: Any) -> None:
    from io import StringIO

    from django.core.management import call_command

    workspace = services.create(alice, "Old", "old")
    services.delete(alice, str(workspace.id), "Old")
    Workspace.objects.filter(pk=workspace.pk).update(deleted_at=timezone.now() - timedelta(days=8))
    out = StringIO()

    call_command("purge_workspaces", stdout=out)

    assert "1" in out.getvalue()
    assert not Workspace.objects.filter(pk=workspace.pk).exists()
