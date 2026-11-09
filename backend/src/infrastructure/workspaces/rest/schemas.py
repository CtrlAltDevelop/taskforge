"""What the workspace endpoints return."""

from ninja import Schema


class WorkspaceOut(Schema):
    id: str
    name: str
    slug: str
    logo: str
    version: int
