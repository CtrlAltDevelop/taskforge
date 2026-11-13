"""The clocks that existed before the registry, registered as due workers.

Each wraps its management command so the logic stays in one place and `manage.py <name>` keeps
working on its own. New delayed work should register a plain function instead.
"""

from django.core.management import call_command

from infrastructure.common import dueworkers

_LEGACY_COMMANDS = (
    "inbox_tick",
    "sprint_snapshots",
    "automations_tick",
    "recurrence_tick",
    "imports_tick",
)


def _command_worker(command: str) -> dueworkers.DueWorker:
    def run() -> str:
        from io import StringIO

        out = StringIO()
        call_command(command, stdout=out)
        return out.getvalue().strip()

    return run


def register_builtin_workers() -> None:
    for command in _LEGACY_COMMANDS:
        dueworkers.register(command, _command_worker(command))
