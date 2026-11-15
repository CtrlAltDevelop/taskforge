"""Container health probe for the API: GET /api/health/live with the Host header Django expects."""

import os
import sys
import urllib.request

host = os.environ.get("DJANGO_ALLOWED_HOSTS", "localhost").split(",")[0].strip() or "localhost"
request = urllib.request.Request(
    "http://127.0.0.1:8010/api/health/live", headers={"Host": host}
)
try:
    with urllib.request.urlopen(request, timeout=4) as response:  # noqa: S310
        sys.exit(0 if response.status == 200 else 1)
except Exception:
    sys.exit(1)
