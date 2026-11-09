"""Invitation lifecycle and member management (services)."""

from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.auth.core import delivery
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import invitations, members, services
from infrastructure.workspaces.models import Invitation, MemberStatus, WorkspaceMember
from infrastructure.workspaces.scoping import require_workspace


@pytest.fixture(autouse=True)
def _clean_outbox() -> None:
    delivery.outbox.clear()


@pytest.fixture
def acme(alice: Any) -> Any:
    return services.create(alice, "Acme", "acme")


def _invite(acme: Any, alice: Any, email: str) -> invitations.Created:
    return invitations.create_invitations(acme, alice, [email]).created[0]


def _title(refusal: Any) -> Any:
    return refusal.value.title


def test_email_invite_stores_only_the_hash_and_emails_the_token(acme: Any, alice: Any) -> None:
    made = _invite(acme, alice, "Bob@Example.com")

    assert made.invitation.email == "bob@example.com"
    assert made.token not in made.invitation.token_hash
    assert made.invitation.token_hash == invitations.hash_token(made.token)
    assert len(delivery.outbox) == 1 and made.token in delivery.outbox[0].body


def test_accept_joins_and_is_idempotent(acme: Any, alice: Any, bob: Any) -> None:
    made = _invite(acme, alice, "bob@example.com")

    first = invitations.accept(made.token, bob)
    second = invitations.accept(made.token, bob)

    assert first.pk == second.pk and first.invited_by == alice
    made.invitation.refresh_from_db()
    assert made.invitation.uses == 1 and made.invitation.accepted_at is not None
    assert require_workspace(bob, str(acme.id)) == acme


def test_bound_invite_refuses_a_mismatched_email(
    acme: Any, alice: Any, bob: Any, make_user: Any
) -> None:
    made = _invite(acme, alice, "bob@example.com")

    with pytest.raises(ApiError) as refusal:
        invitations.accept(made.token, make_user("carol"))
    assert _title(refusal) is ResponseTitle.INVITE_EMAIL_MISMATCH
    assert bob.email_verified_at is None  # unverified but matching: accepted
    assert invitations.accept(made.token, bob).user == bob


def test_email_match_is_case_insensitive(acme: Any, alice: Any, make_user: Any) -> None:
    made = _invite(acme, alice, "dave@example.com")
    dave = make_user("dave")
    dave.email = "Dave@Example.com"
    dave.save()

    assert invitations.accept(made.token, dave).user == dave


def test_link_uses_expiry_and_revoke_have_distinct_errors(
    acme: Any, alice: Any, bob: Any, make_user: Any
) -> None:
    link = invitations.create_link(acme, alice, max_uses=1)
    invitations.accept(link.token, bob)
    with pytest.raises(ApiError) as used:
        invitations.accept(link.token, make_user("carol"))
    assert _title(used) is ResponseTitle.INVITE_USED_UP and used.value.status == 410

    expiring = invitations.create_link(acme, alice)
    Invitation.objects.filter(pk=expiring.invitation.pk).update(
        expires_at=timezone.now() - timedelta(seconds=1)
    )
    with pytest.raises(ApiError) as expired:
        invitations.accept(expiring.token, make_user("erin"))
    assert _title(expired) is ResponseTitle.INVITE_EXPIRED

    revoked = invitations.create_link(acme, alice)
    invitations.revoke(acme, alice, str(revoked.invitation.id))
    with pytest.raises(ApiError) as gone:
        invitations.accept(revoked.token, make_user("finn"))
    assert _title(gone) is ResponseTitle.INVITE_REVOKED


def test_unlimited_link_counts_each_new_member(
    acme: Any, alice: Any, bob: Any, make_user: Any
) -> None:
    link = invitations.create_link(acme, alice)
    invitations.accept(link.token, bob)
    invitations.accept(link.token, make_user("carol"))
    invitations.accept(link.token, bob)

    link.invitation.refresh_from_db()
    assert (link.invitation.uses, link.invitation.max_uses) == (2, 0)


@pytest.mark.parametrize("expires_in", [1, 3599, 30 * 86400 + 1, -5])
def test_link_expiry_bounds(acme: Any, alice: Any, expires_in: int) -> None:
    with pytest.raises(ApiError):
        invitations.create_link(acme, alice, expires_in=expires_in)


@pytest.mark.parametrize("max_uses", [-1, 1001])
def test_link_max_uses_bounds(acme: Any, alice: Any, max_uses: int) -> None:
    with pytest.raises(ApiError):
        invitations.create_link(acme, alice, max_uses=max_uses)


def test_email_limits_and_validation(acme: Any, alice: Any) -> None:
    for bad in ([], ["not-an-email"], [f"u{i}@example.com" for i in range(21)]):
        with pytest.raises(ApiError):
            invitations.create_invitations(acme, alice, bad)


def test_resend_rotates_token_and_expiry(acme: Any, alice: Any, bob: Any) -> None:
    made = _invite(acme, alice, "bob@example.com")
    Invitation.objects.filter(pk=made.invitation.pk).update(
        expires_at=timezone.now() - timedelta(days=1)
    )

    again = invitations.resend(acme, alice, str(made.invitation.id))

    assert again.token != made.token
    assert invitations.preview(again.token).state == invitations.VALID
    with pytest.raises(ApiError) as old:
        invitations.preview(made.token)
    assert old.value.status == 404
    assert len(delivery.outbox) == 2


def test_resend_refuses_links_and_closed_invites(acme: Any, alice: Any) -> None:
    link = invitations.create_link(acme, alice)
    with pytest.raises(ApiError):
        invitations.resend(acme, alice, str(link.invitation.id))
    made = _invite(acme, alice, "bob@example.com")
    invitations.revoke(acme, alice, str(made.invitation.id))
    with pytest.raises(ApiError) as refusal:
        invitations.resend(acme, alice, str(made.invitation.id))
    assert refusal.value.status == 409


def test_reinvite_replaces_pending_and_skips_members(acme: Any, alice: Any, bob: Any) -> None:
    first = _invite(acme, alice, "bob@example.com")
    result = invitations.create_invitations(acme, alice, ["bob@example.com", "alice@example.com"])

    assert result.skipped_emails == ["alice@example.com"]
    assert [i.email for i in invitations.list_pending(acme, alice)] == ["bob@example.com"]
    first.invitation.refresh_from_db()
    assert first.invitation.revoked_at is not None


def test_decline_revokes_only_for_the_invited_account(
    acme: Any, alice: Any, bob: Any, make_user: Any
) -> None:
    made = _invite(acme, alice, "bob@example.com")
    invitations.decline(made.token, make_user("carol"))
    assert invitations.preview(made.token).state == invitations.VALID

    invitations.decline(made.token, bob)
    assert invitations.preview(made.token).state == invitations.REVOKED


def test_preview_reveals_little_and_unknown_tokens_are_404(acme: Any, alice: Any) -> None:
    made = _invite(acme, alice, "bob@example.com")

    seen = invitations.preview(made.token)

    assert (seen.workspace_name, seen.inviter_name, seen.email_bound) == ("Acme", "alice", True)
    for token in ("garbage", "", made.token[:-1] + "x"):
        with pytest.raises(ApiError) as refusal:
            invitations.preview(token)
        assert refusal.value.status == 404


def test_deleted_workspace_invites_are_not_found(acme: Any, alice: Any) -> None:
    link = invitations.create_link(acme, alice)
    services.delete(alice, str(acme.id), "Acme")

    with pytest.raises(ApiError) as refusal:
        invitations.preview(link.token)
    assert refusal.value.status == 404


def test_invitation_rate_limit(acme: Any, alice: Any, settings: Any) -> None:
    settings.WORKSPACE_INVITES_PER_HOUR = 2
    invitations.create_invitations(acme, alice, ["a@example.com", "b@example.com"])

    with pytest.raises(ApiError) as refusal:
        invitations.create_link(acme, alice)
    assert refusal.value.status == 429


def test_cross_tenant_revoke_and_resend_are_not_found(acme: Any, alice: Any, bob: Any) -> None:
    other = services.create(bob, "Other", "other")
    made = _invite(other, bob, "x@example.com")

    for call in (
        lambda: invitations.revoke(acme, alice, str(made.invitation.id)),
        lambda: invitations.resend(acme, alice, str(made.invitation.id)),
    ):
        with pytest.raises(ApiError) as refusal:
            call()
        assert refusal.value.status == 404
    assert invitations.list_pending(acme, alice) == []


def test_removed_member_is_denied_everywhere_and_reactivated_by_invite(
    acme: Any, alice: Any, bob: Any
) -> None:
    invitations.accept(invitations.create_link(acme, alice).token, bob)
    members.remove(acme, alice, str(bob.pk))

    with pytest.raises(ApiError) as scoped:
        require_workspace(bob, str(acme.id))
    assert scoped.value.status == 403
    assert services.list_mine(bob) == []
    with pytest.raises(ApiError):
        services.update(bob, str(acme.id), 1, name="X")
    assert [m.user for m in members.list_members(acme, alice)] == [alice]

    invitations.accept(invitations.create_link(acme, alice).token, bob)

    assert WorkspaceMember.objects.filter(workspace=acme, user=bob).count() == 1
    assert require_workspace(bob, str(acme.id)) == acme


def test_removed_owner_row_cannot_list_deleted(alice: Any) -> None:
    gone = services.create(alice, "Gone", "gone")
    services.delete(alice, str(gone.id), "Gone")
    WorkspaceMember.objects.filter(workspace=gone).update(status=MemberStatus.REMOVED)

    assert services.list_deleted(alice) == []


def test_member_rules(acme: Any, alice: Any, bob: Any) -> None:
    invitations.accept(invitations.create_link(acme, alice).token, bob)

    listed = members.list_members(acme, alice)
    assert [(m.user_id == acme.created_by_id) for m in listed] == [True, False]

    with pytest.raises(ApiError) as non_owner:
        members.remove(acme, bob, str(alice.pk))
    assert non_owner.value.status == 403
    with pytest.raises(ApiError) as owner_target:
        members.remove(acme, alice, str(alice.pk))
    assert _title(owner_target) is ResponseTitle.OWNER_PROTECTED
    with pytest.raises(ApiError) as owner_leaves:
        members.leave(acme, alice)
    assert _title(owner_leaves) is ResponseTitle.OWNER_PROTECTED
    for bogus in ("garbage", "00000000-0000-0000-0000-000000000000"):
        with pytest.raises(ApiError) as missing:
            members.remove(acme, alice, bogus)
        assert missing.value.status == 404

    members.leave(acme, bob)
    assert [m.user for m in members.list_members(acme, alice)] == [alice]
    with pytest.raises(ApiError):
        members.leave(acme, bob)


def _remove_bob(acme: Any, alice: Any, bob: Any) -> None:
    invitations.accept(invitations.create_link(acme, alice).token, bob)
    members.remove(acme, alice, str(bob.pk))


def test_removed_member_cannot_rejoin_by_an_old_link(acme: Any, alice: Any, bob: Any) -> None:
    old = invitations.create_link(acme, alice)
    invitations.accept(old.token, bob)
    members.remove(acme, alice, str(bob.pk))

    with pytest.raises(ApiError) as refusal:
        invitations.accept(old.token, bob)

    assert _title(refusal) is ResponseTitle.INVITE_BEFORE_REMOVAL and refusal.value.status == 410
    assert not WorkspaceMember.objects.filter(workspace=acme, user=bob, status="active").exists()


def test_links_and_invites_made_by_the_removed_user_die_with_removal(
    acme: Any, alice: Any, bob: Any, make_user: Any
) -> None:
    invitations.accept(invitations.create_link(acme, alice).token, bob)
    link = invitations.create_link(acme, bob)
    mail = _invite(acme, bob, "carol@example.com")

    members.remove(acme, alice, str(bob.pk))

    carol = make_user("carol")
    for token in (link.token, mail.token):
        with pytest.raises(ApiError) as refusal:
            invitations.accept(token, carol)
        assert _title(refusal) is ResponseTitle.INVITE_REVOKED


def test_leaving_also_revokes_what_the_leaver_created(
    acme: Any, alice: Any, bob: Any, make_user: Any
) -> None:
    invitations.accept(invitations.create_link(acme, alice).token, bob)
    link = invitations.create_link(acme, bob)

    members.leave(acme, bob)

    with pytest.raises(ApiError) as refusal:
        invitations.accept(link.token, make_user("carol"))
    assert _title(refusal) is ResponseTitle.INVITE_REVOKED


def test_a_new_invitation_after_removal_reactivates_and_clears_removed_at(
    acme: Any, alice: Any, bob: Any
) -> None:
    _remove_bob(acme, alice, bob)
    assert WorkspaceMember.objects.get(workspace=acme, user=bob).removed_at is not None

    member = invitations.accept(invitations.create_link(acme, alice).token, bob)

    assert member.status == MemberStatus.ACTIVE and member.removed_at is None


def test_list_pending_filters_orders_and_caps(acme: Any, alice: Any) -> None:
    now = timezone.now()
    used = invitations.create_link(acme, alice, max_uses=1).invitation
    Invitation.objects.filter(pk=used.pk).update(uses=1)
    stale = invitations.create_link(acme, alice).invitation
    Invitation.objects.filter(pk=stale.pk).update(expires_at=now - timedelta(days=31))
    recent = invitations.create_link(acme, alice).invitation
    Invitation.objects.filter(pk=recent.pk).update(expires_at=now - timedelta(days=1))
    revoked = invitations.create_link(acme, alice).invitation
    invitations.revoke(acme, alice, str(revoked.id))
    fresh = invitations.create_link(acme, alice).invitation

    assert [i.pk for i in invitations.list_pending(acme, alice)] == [fresh.pk, recent.pk]


def test_list_pending_is_capped(acme: Any, alice: Any) -> None:
    now = timezone.now()
    Invitation.objects.bulk_create(
        Invitation(
            workspace=acme,
            token_hash=f"h{i}",
            created_by=alice,
            expires_at=now + timedelta(days=1),
        )
        for i in range(invitations.MAX_PENDING_LISTED + 5)
    )

    assert len(invitations.list_pending(acme, alice)) == invitations.MAX_PENDING_LISTED
