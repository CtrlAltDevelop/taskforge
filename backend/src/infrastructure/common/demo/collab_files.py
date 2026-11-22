"""Attachments: images (with thumbnails), a log, a CSV and a PDF on tasks, and files on comments."""

import io
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw

from infrastructure.attachments import services as attachments
from infrastructure.attachments.models import Attachment
from infrastructure.comments.models import Comment
from infrastructure.common.demo.base import Ctx

MAX_BYTES = 5 * 1024 * 1024
PDF = (
    b"%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n"
    b"2 0 obj<</Type/Pages/Count 0/Kids[]>>endobj\ntrailer<</Root 1 0 R>>\n%%EOF\n"
)


def _png(color: tuple[int, int, int], label: str) -> bytes:
    image = Image.new("RGB", (640, 400), color)
    draw = ImageDraw.Draw(image)
    draw.rectangle((40, 40, 600, 80), fill=(255, 255, 255))
    draw.text((52, 52), label, fill=(30, 30, 30))
    out = io.BytesIO()
    image.save(out, "PNG")
    return out.getvalue()


FILES: tuple[tuple[str, str, str, bytes, str], ...] = (
    # (task ref, uploader, filename, content, "" or the key of a comment (ctx.extra) to hang it on)
    ("login", "designer", "login-mockup.png", _png((70, 110, 200), "Login screen"), "login-fa"),
    ("login", "designer", "error-states.png", _png((200, 90, 90), "Error states"), ""),
    ("chk", "designer", "checkout-flow.png", _png((60, 160, 120), "Checkout flow"), "chk-top"),
    ("chk", "owner", "payment-spec.pdf", PDF, ""),
    (
        "crash",
        "dev",
        "crash-log.txt",
        b"E/AndroidRuntime: FATAL EXCEPTION: main\nat push.TokenRefresh.run(TokenRefresh.kt:42)\n",
        "",
    ),
    (
        "analytics",
        "admin",
        "events.csv",
        b"event,screen,owner\nsign_in,login,member\ncheckout_started,cart,dev\n",
        "",
    ),
    (
        "launch",
        "owner",
        "launch-plan.md",
        b"# Launch plan\n\n- Freeze Monday\n- Ship Wednesday\n",
        "",
    ),
    ("bug-a", "guest", "desktop-screenshot.png", _png((230, 170, 60), "Desktop repro"), ""),
)


def create_attachments(ctx: Ctx) -> None:
    kept = ctx.extra.get("comments", {})
    with tempfile.TemporaryDirectory() as folder:
        for ref, who, name, content, comment_key in FILES:
            path = Path(folder) / name
            path.write_bytes(content)
            row = attachments.attach_local_file(
                ctx.users[who], ctx.tasks[ref], name, path, max_bytes=MAX_BYTES
            )
            comment: Comment | None = kept.get(comment_key)
            if comment is not None:
                # No service attaches a file to a comment without a chunked upload session.
                Attachment.objects.filter(pk=row.pk).update(comment=comment)
