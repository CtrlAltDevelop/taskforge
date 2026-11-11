# Phase 24 — Automations

**Status:** DONE

## Feature
No-code **rules**: *When* something happens, *if* conditions match, *then* do actions — unlimited runs, with a run history.

## Why it exists
Both tools cap automation runs on cheaper plans and give poor visibility when a rule misbehaves. Ours is unlimited and every run is inspectable.

## How it works (plain words)
A rule has a **trigger** (task created, status changed, field changed, assigned, due date reached, comment added), optional **conditions** (reuse the TFQL filter from phase 14 on the task), and **actions** (set field/status/assignee, add comment, create subtask, notify user, call webhook). Triggers consume the same domain events as realtime/notifications. A worker evaluates matching rules (in-process for now, see Reality check), runs actions as the special actor “Automation: <rule name>”, and writes a **run record** with input, result and any error. Loop protection stops chains where rule A triggers rule B triggers A.

## Reality check (no Celery yet)
There is no Celery in this repo (see `docs/01-architecture.md`). The backend therefore:
- consumes the existing signals (`task_activity`, `task_changed`, `comment_changed`) in `automations/receivers.py` and queues each matching rule through `automations/queue.py: run_later` — a two-thread pool in the process (like the inbox pushes), or inline with `DJANGO_AUTOMATIONS_SYNC_RUN=1` (tests). `run_later` is the single seam Celery replaces; the job itself (`engine.execute(rule_id, event)`) is already idempotent and takes only plain data.
- fires "due date reached" from `manage.py automations_tick` (added to `make tick`), once per (rule, task, due date); the same command prunes run history (30 days, newest 500 per rule).
- a "field changed" event names the fields whose `field_versions` entry equals the event's version.
- the "special actor" is the rule's owner with a run depth: actions go through the normal services as the owner (so the permission ceiling is real), the depth travels in a context variable, and comments carry an `[Automation: <name>]` prefix. Switching a rule on or editing it makes the editor its owner.
- new permission `automation.manage` (Owner, Admin); reading rules and runs needs `workspace.view`.
- "completion date" is a custom date field set with the `{today}` placeholder (Tasks have no built-in completed-at).
- webhooks are SSRF-safe (`automations/safe_http.py`): http(s) only, every resolved address public, connection pinned to the checked address, no redirects, 5 s timeout, 64 KB response cap.

## Scope
**In:** rule builder UI, triggers, conditions, actions listed above, enable/disable, test run (dry run on a chosen task), run history with failure reasons, rate/loop guards, per-rule owner.
**Out:** cross-project rules, scheduled “cron” rules beyond due-date triggers, code/script actions.

## Data model
- `Automation(id, workspace, project, name, enabled, trigger jsonb, condition_ast jsonb, actions jsonb, owner, created_at)`
- `AutomationRun(id, automation, task, started_at, status, steps jsonb, error)`

## API surface
- gRPC: `Automations.List/Create/Update/Delete/Toggle`, `DryRun(automation, task)`, `Runs.List`
- Internal: event consumer → `evaluate_rules` Celery task.

## Flutter UI
Rule builder as a vertical “When → If → Then” stack of cards with typed pickers; run history list with expandable step details and a “why didn’t this run?” explainer showing which condition failed.

## Rules and edge cases
- Max chain depth 5 (actor carries `automation_depth`); exceeded → run marked `skipped_loop`.
- Actions run with the rule owner’s permission ceiling, never higher.
- Idempotency key per (rule, task, event id) so retries don’t duplicate actions.
- If a referenced field/status is deleted the rule is auto-disabled with a notice.

## Acceptance criteria
- [ ] Status → Done sets completion date and notifies the assignee
- [ ] Loop test terminates and records `skipped_loop`
- [ ] Dry run shows exact would-be changes without applying
- [ ] Deleting a used status disables rule and tells the owner

## Tests
Trigger matching, condition via TFQL, idempotency, loop guard, permission ceiling (including an owner who keeps `automation.manage` but loses `task.update`), the in-process queue (lanes, cap, de-duplication, refusal), idempotency per (rule, task, event) and the bounded retry of crashed runs, the `automations_tick` command, and stable run paging.

## Depends on
Phases 07, 14, 19.
