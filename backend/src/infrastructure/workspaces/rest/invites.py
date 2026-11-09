"""Public invitation endpoints: preview a token, accept it.

The token travels in the body, never the URL (access logs).
Preview needs no sign-in and is rate limited per IP; an unknown token is a plain
404 whatever it looks like. Accept needs a signed-in account.
"""

from django.http import HttpRequest
from ninja import Router

from infrastructure.auth.core.sessions import api_auth
from infrastructure.common.throttling import ScopedAnonThrottle
from infrastructure.workspaces import invitations
from infrastructure.workspaces.rest.schemas import InvitePreviewOut, InviteTokenIn, WorkspaceOut

router = Router()


@router.post(
    "/preview",
    response=InvitePreviewOut,
    auth=None,
    throttle=[ScopedAnonThrottle("invite")],
    summary="Preview an invitation (public)",
)
def preview(request: HttpRequest, payload: InviteTokenIn) -> InvitePreviewOut:
    result = invitations.preview(payload.token)
    return InvitePreviewOut(
        workspace_name=result.workspace_name,
        inviter_name=result.inviter_name,
        email_bound=result.email_bound,
        state=result.state,
    )


@router.post("/accept", response=WorkspaceOut, auth=api_auth, summary="Join via invitation")
def accept(request: HttpRequest, payload: InviteTokenIn) -> WorkspaceOut:
    workspace = invitations.accept(payload.token, request.user).workspace
    return WorkspaceOut(
        id=str(workspace.id),
        name=workspace.name,
        slug=workspace.slug,
        logo=workspace.logo.url if workspace.logo else "",
        version=workspace.version,
    )
