"""The upload lifecycle and the rules around it, against real (temporary) storage."""

from typing import Any

import pytest
from django.core.files.storage import default_storage

from infrastructure.attachments import services
from infrastructure.attachments.models import Attachment, UploadSession
from infrastructure.attachments.tests.conftest import real_png
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access


def _chunks(data: bytes, size: int = 16) -> list[bytes]:
    return [data[i : i + size] for i in range(0, len(data), size)] or [b""]


def _begin(team: Any, project: Any, task: Any, name: str, data: bytes, *, who: Any = None) -> Any:
    return services.start_upload(
        who or team.member, team.ws, str(project.pk), str(task.pk), name, len(data)
    )


def upload(
    team: Any,
    project: Any,
    task: Any,
    data: bytes,
    name: str = "note.txt",
    *,
    who: Any = None,
    comment_id: str = "",
) -> Attachment:
    who = who or team.member
    session = services.start_upload(
        who, team.ws, str(project.pk), str(task.pk), name, len(data), comment_id=comment_id
    )
    for n, part in enumerate(_chunks(data, session.chunk_size)):
        services.put_chunk(who, str(session.pk), n, part)
    return services.complete(who, str(session.pk))


# -- starting ------------------------------------------------------------------------------------


def test_a_session_tells_the_client_how_to_cut_the_file(team: Any, project: Any, task: Any) -> None:
    session = _begin(team, project, task, "a.txt", b"x" * 40)

    assert (session.chunk_size, session.chunk_count, session.received) == (16, 3, [])
    assert session.expires_at > session.created_at


def test_a_viewer_cannot_start_an_upload_nor_anyone_in_an_archived_project(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.projects import services as projects

    with pytest.raises(access.PermissionDenied):
        _begin(team, project, task, "a.txt", b"x", who=team.viewer)
    projects.archive(team.owner, team.ws, str(project.pk), project.version)
    with pytest.raises(ApiError):
        _begin(team, project, task, "a.txt", b"x")


def test_a_stranger_cannot_start_an_upload_on_somebody_elses_task(
    team: Any, project: Any, task: Any
) -> None:
    with pytest.raises(ApiError) as refused:
        services.start_upload(team.outsider, team.ws, str(project.pk), str(task.pk), "a.txt", 1)
    assert refused.value.status == 403


def test_too_big_empty_and_blocked_names_are_refused_up_front(
    team: Any, project: Any, task: Any
) -> None:
    for size, name, title in (
        (2000, "a.txt", ResponseTitle.ATTACHMENT_TOO_BIG),
        (0, "a.txt", ResponseTitle.ATTACHMENT_REFUSED),
        (5, "setup.exe", ResponseTitle.ATTACHMENT_REFUSED),
        (5, "", ResponseTitle.ATTACHMENT_REFUSED),
    ):
        with pytest.raises(ApiError) as refusal:
            services.start_upload(team.member, team.ws, str(project.pk), str(task.pk), name, size)
        assert refusal.value.title is title


def test_a_folder_in_the_name_is_dropped(team: Any, project: Any, task: Any) -> None:
    session = services.start_upload(
        team.member, team.ws, str(project.pk), str(task.pk), "..\\..\\etc/passwd\x00.txt", 5
    )

    assert session.filename == "passwd.txt"


def test_the_workspace_quota_counts_files_and_uploads_still_arriving(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES = 100
    upload(team, project, task, b"a" * 60)
    _begin(team, project, task, "b.txt", b"b" * 30)

    with pytest.raises(ApiError) as refusal:
        _begin(team, project, task, "c.txt", b"c" * 20)

    assert refusal.value.title is ResponseTitle.ATTACHMENT_QUOTA and refusal.value.status == 409


# -- chunks and resuming -------------------------------------------------------------------------


def test_chunks_may_arrive_in_any_order_and_twice(team: Any, project: Any, task: Any) -> None:
    data = bytes(range(40))
    session = _begin(team, project, task, "a.bin", data)
    parts = _chunks(data)

    assert services.put_chunk(team.member, str(session.pk), 2, parts[2]) == [2]
    assert services.put_chunk(team.member, str(session.pk), 0, parts[0]) == [0, 2]
    assert services.put_chunk(team.member, str(session.pk), 0, parts[0]) == [0, 2]
    assert services.upload_status(team.member, str(session.pk)).received == [0, 2]


def test_a_chunk_of_the_wrong_size_or_number_is_refused(team: Any, project: Any, task: Any) -> None:
    session = _begin(team, project, task, "a.bin", b"x" * 40)

    for n, part in (
        (0, b"x" * 15),
        (0, b"x" * 17),
        (1, b"x" * 17),
        (2, b"x" * 9),
        (3, b"x"),
        (-1, b"x"),
    ):
        with pytest.raises(ApiError):
            services.put_chunk(team.member, str(session.pk), n, part)
    assert services.upload_status(team.member, str(session.pk)).received == []


def test_only_the_uploader_sees_or_feeds_an_upload(team: Any, project: Any, task: Any) -> None:
    session = _begin(team, project, task, "a.bin", b"x" * 20)

    for other in (team.owner, team.admin):
        with pytest.raises(ApiError) as hidden:
            services.upload_status(other, str(session.pk))
        assert hidden.value.status == 404
        with pytest.raises(ApiError):
            services.put_chunk(other, str(session.pk), 0, b"x" * 16)


def test_an_upload_that_lost_its_connection_resumes_where_it_stopped(
    team: Any, project: Any, task: Any
) -> None:
    data = bytes(range(100))
    session = _begin(team, project, task, "big.bin", data)
    parts = _chunks(data)
    for n in (0, 1, 2):  # ... and then the network drops
        services.put_chunk(team.member, str(session.pk), n, parts[n])

    again = services.upload_status(team.member, str(session.pk))
    for n in range(again.chunk_count):
        if n not in again.received:
            services.put_chunk(team.member, str(session.pk), n, parts[n])
    attachment = services.complete(team.member, str(session.pk))

    assert attachment.size == 100
    with default_storage.open(attachment.storage_key) as stored:
        assert stored.read() == data


def test_an_expired_upload_cannot_be_continued(team: Any, project: Any, task: Any) -> None:
    from datetime import timedelta

    from django.utils import timezone

    session = _begin(team, project, task, "a.bin", b"x" * 20)
    UploadSession.objects.filter(pk=session.pk).update(expires_at=timezone.now() - timedelta(1))

    with pytest.raises(ApiError) as gone:
        services.put_chunk(team.member, str(session.pk), 0, b"x" * 16)
    assert gone.value.status == 404 and gone.value.title is ResponseTitle.UPLOAD_EXPIRED


def test_cancelling_removes_the_session_and_its_chunks(team: Any, project: Any, task: Any) -> None:
    session = _begin(team, project, task, "a.bin", b"x" * 20)
    services.put_chunk(team.member, str(session.pk), 0, b"x" * 16)

    services.cancel(team.member, str(session.pk))

    assert not UploadSession.objects.exists()
    assert not default_storage.exists(services.chunk_key(session, 0))


# -- completing ----------------------------------------------------------------------------------


def test_completing_with_chunks_missing_says_which(team: Any, project: Any, task: Any) -> None:
    session = _begin(team, project, task, "a.bin", b"x" * 40)
    services.put_chunk(team.member, str(session.pk), 1, b"x" * 16)

    with pytest.raises(ApiError) as incomplete:
        services.complete(team.member, str(session.pk))

    assert incomplete.value.title is ResponseTitle.UPLOAD_INCOMPLETE
    assert incomplete.value.data == {"missing": "0,2"}


def test_a_completed_upload_is_an_attachment_of_the_task(
    team: Any, project: Any, task: Any
) -> None:
    attachment = upload(team, project, task, b"remember the milk\n", "milk.txt")

    assert (attachment.filename, attachment.mime, attachment.size) == (
        "milk.txt",
        "text/plain",
        18,
    )
    assert attachment.task_id == task.pk and attachment.uploader_id == team.member.pk
    assert len(attachment.sha256) == 64 and attachment.thumb_key == ""
    assert not UploadSession.objects.exists()
    assert services.list_for_task(team.viewer, team.ws, str(project.pk), str(task.pk)) == [
        attachment
    ]


def test_the_type_is_what_the_content_says_not_what_the_name_claims(
    team: Any, project: Any, task: Any
) -> None:
    attachment = upload(team, project, task, real_png(), "photo.txt")

    assert attachment.mime == "image/png"


def test_a_program_is_refused_whatever_it_is_called_and_nothing_is_kept(
    team: Any, project: Any, task: Any, storage: Any
) -> None:
    session = _begin(team, project, task, "holiday.png", b"MZ\x90\x00" + b"\0" * 30)
    for n, part in enumerate(_chunks(b"MZ\x90\x00" + b"\0" * 30)):
        services.put_chunk(team.member, str(session.pk), n, part)

    with pytest.raises(ApiError) as refused:
        services.complete(team.member, str(session.pk))

    assert refused.value.title is ResponseTitle.ATTACHMENT_REFUSED and refused.value.status == 422
    assert not Attachment.objects.exists() and not UploadSession.objects.exists()
    assert not any(p.is_file() for p in (storage / "attachments").rglob("*"))


def test_programs_are_accepted_when_the_deployment_allows_them(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    settings.ATTACHMENT_ALLOW_EXECUTABLES = True

    assert upload(team, project, task, b"MZ\x90\x00" + b"\0" * 30, "tool.exe").mime == (
        "application/x-msdownload"
    )


def test_a_file_the_virus_scanner_flags_is_refused(
    team: Any, project: Any, task: Any, settings: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.attachments import scan

    settings.ATTACHMENT_CLAMAV_ADDRESS = "clam:3310"
    monkeypatch.setattr(scan, "scan", lambda path, address: "Eicar-Test-Signature")

    with pytest.raises(ApiError) as refused:
        upload(team, project, task, b"X5O!P%@AP", "eicar.txt")

    assert refused.value.title is ResponseTitle.ATTACHMENT_REFUSED
    assert "Eicar" in str(refused.value.data)


def test_a_scanner_that_is_down_means_the_file_is_not_kept(
    team: Any, project: Any, task: Any, settings: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    from infrastructure.attachments import scan

    def down(path: Any, address: str) -> None:
        raise scan.ScanUnavailable("refused")

    settings.ATTACHMENT_CLAMAV_ADDRESS = "clam:3310"
    monkeypatch.setattr(scan, "scan", down)

    with pytest.raises(ApiError) as refused:
        upload(team, project, task, b"hello", "a.txt")

    assert refused.value.status == 503 and not Attachment.objects.exists()
    assert UploadSession.objects.count() == 1  # the upload survives: complete can be tried again


def test_pictures_and_pdfs_get_thumbnails(team: Any, project: Any, task: Any) -> None:
    import io

    from PIL import Image

    pdf = io.BytesIO()
    Image.new("RGB", (200, 300), "white").save(pdf, "PDF")
    settings_max = 1024 * 1024

    png = upload(team, project, task, real_png(), "a.png")
    from django.test import override_settings

    with override_settings(ATTACHMENT_MAX_BYTES=settings_max):
        doc = upload(team, project, task, pdf.getvalue(), "a.pdf")

    assert png.thumb_key and doc.thumb_key
    assert default_storage.exists(png.thumb_key) and default_storage.exists(doc.thumb_key)


def test_the_same_bytes_are_stored_once(team: Any, project: Any, task: Any, storage: Any) -> None:
    first = upload(team, project, task, b"same words in both\n", "one.txt")
    second = upload(team, project, task, b"same words in both\n", "two.txt", who=team.owner)

    assert first.storage_key == second.storage_key and first.pk != second.pk
    blobs = [p for p in (storage / "attachments" / "blobs").rglob("*") if p.is_file()]
    assert len(blobs) == 1


def test_a_comments_attachment_is_its_authors_alone(team: Any, project: Any, task: Any) -> None:
    from infrastructure.comments import services as comments
    from infrastructure.comments.tests.conftest import say

    comment = comments.create(team.member, team.ws, str(project.pk), str(task.pk), say("see"))

    attached = upload(team, project, task, b"proof\n", "p.txt", comment_id=str(comment.pk))

    assert attached.comment_id == comment.pk
    with pytest.raises(access.PermissionDenied):
        upload(team, project, task, b"x", "q.txt", who=team.owner, comment_id=str(comment.pk))
    with pytest.raises(ApiError):
        upload(team, project, task, b"x", "q.txt", comment_id="not-an-id")


# -- deleting, listing, usage --------------------------------------------------------------------


def test_the_uploader_deletes_and_the_bytes_go_when_nobody_else_holds_them(
    team: Any, project: Any, task: Any
) -> None:
    kept = upload(team, project, task, b"keep me\n", "a.txt")
    twin = upload(team, project, task, b"keep me\n", "b.txt", who=team.owner)

    services.delete(team.member, team.ws, str(project.pk), str(kept.pk))
    assert default_storage.exists(twin.storage_key)  # still held by the other attachment
    services.delete(team.owner, team.ws, str(project.pk), str(twin.pk))

    assert not default_storage.exists(twin.storage_key)
    assert services.list_for_task(team.owner, team.ws, str(project.pk), str(task.pk)) == []
    assert Attachment.objects.get(pk=kept.pk).deleted_at is not None


def test_somebody_elses_attachment_needs_the_manage_right(
    team: Any, project: Any, task: Any
) -> None:
    mine = upload(team, project, task, b"mine\n", "a.txt")

    with pytest.raises(access.PermissionDenied):
        services.delete(team.pm, team.ws, str(project.pk), str(mine.pk))
    services.delete(team.admin, team.ws, str(project.pk), str(mine.pk))

    assert Attachment.objects.get(pk=mine.pk).is_deleted


def test_nothing_is_deleted_in_an_archived_project(team: Any, project: Any, task: Any) -> None:
    from infrastructure.projects import services as projects

    mine = upload(team, project, task, b"mine\n", "a.txt")
    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    with pytest.raises(ApiError):
        services.delete(team.member, team.ws, str(project.pk), str(mine.pk))


def test_a_workspace_never_reaches_into_another(team: Any, project: Any, task: Any) -> None:
    mine = upload(team, project, task, b"mine\n", "a.txt")

    with pytest.raises(ApiError) as refused:
        services.delete(team.outsider, team.ws, str(project.pk), str(mine.pk))
    assert refused.value.status == 403
    with pytest.raises(ApiError) as hidden:
        services.delete(team.outsider, team.other_ws, str(project.pk), str(mine.pk))
    assert hidden.value.status == 404


def test_usage_counts_live_files_against_the_quota(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES = 500
    gone = upload(team, project, task, b"x" * 100, "a.txt")
    upload(team, project, task, b"y" * 30, "b.txt")
    services.delete(team.member, team.ws, str(project.pk), str(gone.pk))

    assert services.usage(team.viewer, team.ws) == {
        "used_bytes": 30,
        "quota_bytes": 500,
        "file_count": 1,
        "max_file_bytes": 1024,
    }


# -- links and serving ---------------------------------------------------------------------------


def test_a_signed_link_opens_the_file_until_it_expires(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    attachment = upload(team, project, task, b"secret plans\n", "plans.txt")
    token = services.link_token(team.viewer, team.ws, attachment.pk, thumb=False)

    opened, thumb = services.resolve_token(token)
    assert opened.pk == attachment.pk and thumb is False

    settings.ATTACHMENT_LINK_TTL_SECONDS = -1
    with pytest.raises(ApiError) as late:
        services.resolve_token(token)
    assert late.value.status == 403 and late.value.title is ResponseTitle.LINK_EXPIRED


def test_a_forged_or_foreign_token_opens_nothing(team: Any) -> None:
    for token in ("", "garbage", "a:b:c"):
        with pytest.raises(ApiError) as refused:
            services.resolve_token(token)
        assert refused.value.status == 403


def test_a_non_member_cannot_get_a_link_at_all(team: Any, project: Any, task: Any) -> None:
    attachment = upload(team, project, task, b"x", "a.txt")

    with pytest.raises(ApiError) as refused:
        services.link_token(team.outsider, team.ws, attachment.pk, thumb=False)
    assert refused.value.status == 403
    with pytest.raises(ApiError) as hidden:
        services.link_token(team.outsider, team.other_ws, attachment.pk, thumb=False)
    assert hidden.value.status == 404


def test_a_link_to_a_thumbnail_that_does_not_exist_is_a_404(
    team: Any, project: Any, task: Any
) -> None:
    attachment = upload(team, project, task, b"x", "a.txt")

    with pytest.raises(ApiError) as none:
        services.link_token(team.member, team.ws, attachment.pk, thumb=True)
    assert none.value.status == 404


def test_a_deleted_attachments_old_link_stops_working(team: Any, project: Any, task: Any) -> None:
    attachment = upload(team, project, task, b"x", "a.txt")
    token = services.link_token(team.member, team.ws, attachment.pk, thumb=False)
    services.delete(team.member, team.ws, str(project.pk), str(attachment.pk))

    with pytest.raises(ApiError) as gone:
        services.resolve_token(token)
    assert gone.value.status == 404


# -- cleaning up ---------------------------------------------------------------------------------


def test_orphaned_uploads_are_purged_with_their_chunks(team: Any, project: Any, task: Any) -> None:
    from datetime import timedelta

    from django.utils import timezone

    stale = _begin(team, project, task, "a.bin", b"x" * 40)
    services.put_chunk(team.member, str(stale.pk), 0, b"x" * 16)
    fresh = _begin(team, project, task, "b.bin", b"x" * 40)
    UploadSession.objects.filter(pk=stale.pk).update(expires_at=timezone.now() - timedelta(hours=1))

    assert services.purge_expired() == 1

    assert list(UploadSession.objects.values_list("pk", flat=True)) == [fresh.pk]
    assert not default_storage.exists(services.chunk_key(stale, 0))


def test_a_large_file_is_assembled_without_holding_it_in_memory(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    import hashlib
    import tracemalloc

    mb = 1024 * 1024
    settings.ATTACHMENT_CHUNK_BYTES = 4 * mb
    settings.ATTACHMENT_MAX_BYTES = 128 * mb
    data = (b"0123456789abcdef" * (mb // 16)) * 48  # 48 MB, made before measuring
    session = services.start_upload(
        team.member, team.ws, str(project.pk), str(task.pk), "big.bin", len(data)
    )
    for n in range(session.chunk_count):
        services.put_chunk(team.member, str(session.pk), n, data[n * 4 * mb : (n + 1) * 4 * mb])

    tracemalloc.start()
    attachment = services.complete(team.member, str(session.pk))
    peak = tracemalloc.get_traced_memory()[1]
    tracemalloc.stop()

    assert attachment.size == len(data)
    assert attachment.sha256 == hashlib.sha256(data).hexdigest()
    assert peak < 16 * mb  # a chunk-sized block at a time, never the whole file


def test_a_chunk_that_arrives_after_a_cancel_is_refused_and_leaves_nothing(
    team: Any, project: Any, task: Any
) -> None:
    session = _begin(team, project, task, "a.bin", b"x" * 20)
    services.cancel(team.member, str(session.pk))

    with pytest.raises(ApiError) as gone:
        services.put_chunk(team.member, str(session.pk), 0, b"x" * 16)

    assert gone.value.status == 404
    assert not default_storage.exists(services.chunk_key(session, 0))


def test_a_person_may_have_only_so_many_uploads_open(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    settings.ATTACHMENT_MAX_OPEN_UPLOADS = 2
    _begin(team, project, task, "a.bin", b"x")
    _begin(team, project, task, "b.bin", b"x")

    with pytest.raises(ApiError) as many:
        _begin(team, project, task, "c.bin", b"x")

    assert many.value.status == 429


def test_expired_uploads_still_count_against_the_quota_until_they_are_purged(
    team: Any, project: Any, task: Any, settings: Any
) -> None:
    from datetime import timedelta

    from django.utils import timezone

    settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES = 100
    stale = _begin(team, project, task, "a.bin", b"x" * 90)
    UploadSession.objects.filter(pk=stale.pk).update(expires_at=timezone.now() - timedelta(hours=1))

    _begin(team, project, task, "b.bin", b"x" * 90)  # starting purges the stale one first

    assert not UploadSession.objects.filter(pk=stale.pk).exists()


@pytest.mark.parametrize(
    ("raw", "clean"),
    [
        ("invoice.exe.", "invoice.exe"),
        ("a\u200b.txt", "a.txt"),
        ("evil\u202egpj.exe", "evilgpj.exe"),
        ("  spaced.txt  ", "spaced.txt"),
    ],
)
def test_names_lose_trailing_dots_and_invisible_or_reordering_characters(
    team: Any, project: Any, task: Any, raw: str, clean: str, settings: Any
) -> None:
    settings.ATTACHMENT_ALLOW_EXECUTABLES = True

    session = services.start_upload(team.member, team.ws, str(project.pk), str(task.pk), raw, 5)

    assert session.filename == clean


def test_a_name_that_ends_in_a_dot_after_an_extension_is_still_a_program(
    team: Any, project: Any, task: Any
) -> None:
    with pytest.raises(ApiError):
        _begin(team, project, task, "setup.exe.", b"x")


def test_deleting_a_comment_takes_its_files_with_it(team: Any, project: Any, task: Any) -> None:
    from infrastructure.comments import services as comments
    from infrastructure.comments.tests.conftest import say

    comment = comments.create(team.member, team.ws, str(project.pk), str(task.pk), say("see"))
    attached = upload(team, project, task, b"proof\n", "p.txt", comment_id=str(comment.pk))
    loose = upload(team, project, task, b"other\n", "q.txt")

    comments.delete(team.member, team.ws, str(project.pk), str(comment.pk))

    assert Attachment.objects.get(pk=attached.pk).is_deleted
    assert not default_storage.exists(attached.storage_key)
    assert services.list_for_task(team.owner, team.ws, str(project.pk), str(task.pk)) == [loose]


def test_an_upload_for_a_comment_removed_meanwhile_is_dropped(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.comments import services as comments
    from infrastructure.comments.tests.conftest import say

    comment = comments.create(team.member, team.ws, str(project.pk), str(task.pk), say("see"))
    session = services.start_upload(
        team.member, team.ws, str(project.pk), str(task.pk), "p.txt", 5, comment_id=str(comment.pk)
    )
    services.put_chunk(team.member, str(session.pk), 0, b"hello")
    comments.delete(team.member, team.ws, str(project.pk), str(comment.pk))

    with pytest.raises(ApiError) as gone:
        services.complete(team.member, str(session.pk))

    assert gone.value.status == 404 and not Attachment.objects.exists()


def test_a_file_on_a_trashed_task_gets_no_link(team: Any, project: Any, task: Any) -> None:
    from infrastructure.tasks import services as tasks

    attachment = upload(team, project, task, b"x", "a.txt")
    token = services.link_token(team.member, team.ws, attachment.pk, thumb=False)
    tasks.delete(team.owner, team.ws, str(project.pk), str(task.pk), "subtree")

    with pytest.raises(ApiError):
        services.link_token(team.member, team.ws, attachment.pk, thumb=False)
    with pytest.raises(ApiError):
        services.resolve_token(token)
    with pytest.raises(ApiError):
        services.workspace_of(team.member, str(attachment.pk))


def test_bytes_are_not_shared_between_workspaces(team: Any, project: Any, task: Any) -> None:
    from infrastructure.projects import services as projects
    from infrastructure.tasks import services as tasks

    mine = upload(team, project, task, b"same bytes\n", "a.txt")
    other_project = projects.create(team.outsider, team.other_ws, "Other", "OTH").project
    other_task = tasks.create(team.outsider, team.other_ws, str(other_project.pk), "T")
    session = services.start_upload(
        team.outsider, team.other_ws, str(other_project.pk), str(other_task.pk), "b.txt", 11
    )
    services.put_chunk(team.outsider, str(session.pk), 0, b"same bytes\n")
    theirs = services.complete(team.outsider, str(session.pk))

    assert mine.sha256 == theirs.sha256 and mine.storage_key != theirs.storage_key
    services.delete(team.member, team.ws, str(project.pk), str(mine.pk))
    assert default_storage.exists(theirs.storage_key)


def test_a_blob_deleted_by_a_racing_delete_is_put_back_when_the_row_is_made(
    team: Any, project: Any, task: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    first = upload(team, project, task, b"shared words\n", "a.txt")
    session = _begin(team, project, task, "b.txt", b"shared words\n", who=team.owner)
    services.put_chunk(team.owner, str(session.pk), 0, b"shared words\n")
    real_keep = services._keep
    calls = {"n": 0}

    def keep_then_lose_the_blob(key: str, source: Any, size: int) -> str:
        result = real_keep(key, source, size)
        calls["n"] += 1
        if calls["n"] == 1:  # the other delete lands after the first look, before the row exists
            services.delete(team.member, team.ws, str(project.pk), str(first.pk))
        return result

    monkeypatch.setattr(services, "_keep", keep_then_lose_the_blob)

    second = services.complete(team.owner, str(session.pk))

    with default_storage.open(second.storage_key) as stored:
        assert stored.read() == b"shared words\n"


def test_a_truncated_leftover_blob_is_replaced_not_reused(
    team: Any, project: Any, task: Any
) -> None:
    import hashlib

    data = b"complete content\n"
    sha = hashlib.sha256(data).hexdigest()
    default_storage.save(
        services.blob_key(team.ws.pk, sha),
        __import__("django").core.files.base.ContentFile(b"compl"),
    )

    attachment = upload(team, project, task, data, "a.txt")

    with default_storage.open(attachment.storage_key) as stored:
        assert stored.read() == data


def test_the_uploader_who_lost_write_access_cannot_delete(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.workspaces.models import Role, WorkspaceMember

    mine = upload(team, project, task, b"mine\n", "a.txt")
    WorkspaceMember.objects.filter(workspace=team.ws, user=team.member).update(
        role=Role.objects.get(workspace=None, name="Viewer")
    )

    with pytest.raises(access.PermissionDenied):
        services.delete(team.member, team.ws, str(project.pk), str(mine.pk))
