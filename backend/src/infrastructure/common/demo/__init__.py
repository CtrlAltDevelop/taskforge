"""The full demo dataset: one module per area, run in order by ``manage.py seed_demo``.

Every module exposes ``seed(ctx: Ctx) -> None`` and writes through the apps' own service
functions, so rules, signals, audit entries and live events behave as in real use.
"""
