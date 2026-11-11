"""What the upload and file endpoints take and return."""

from uuid import UUID

from ninja import Field, Schema


class UploadIn(Schema):
    workspace_id: UUID
    project_id: UUID
    task_id: UUID
    comment_id: UUID | None = None
    filename: str = Field(max_length=1000)
    size: int


class UploadOut(Schema):
    id: str
    chunk_size: int
    chunk_count: int
    received: list[int]
    expires_at: str


class ChunkOut(Schema):
    received: list[int]


class AttachmentOut(Schema):
    id: str
    task_id: str
    comment_id: str
    uploader_id: str
    filename: str
    mime: str
    size: int
    has_thumb: bool
    created_at: str


class LinkOut(Schema):
    url: str
    expires_at: str
