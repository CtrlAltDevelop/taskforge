"""What the workspace endpoints return."""

from ninja import Schema


class WorkspaceOut(Schema):
    id: str
    name: str
    slug: str
    logo: str
    version: int


class InviteTokenIn(Schema):
    token: str


class InvitePreviewOut(Schema):
    workspace_name: str
    inviter_name: str
    email_bound: bool
    state: str  # valid | expired | revoked | used_up
