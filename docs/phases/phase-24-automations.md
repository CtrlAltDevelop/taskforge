# Phase 24 — Automations

## Feature
No-code **rules**: *When* something happens, *if* conditions match, *then* do actions — unlimited runs, with a run history.

## Why it exists
Both tools cap automation runs on cheaper plans and give poor visibility when a rule misbehaves. Ours is unlimited and every run is inspectable.

## How it works (plain words)
A rule has a **trigger** (task created, status changed, field changed, assigned, due date reached, comment added), optional **conditions** (reuse the TFQL filter from phase 14 on the task), and **actions** (set field/status/assignee, add comment, create subtask, notify user, call webhook). Triggers consume the same domain events as realtime/notifications. A Celery worker evaluates matching rules, runs actions as the special actor “Automation: <rule name>”, and writes a **run record** with input, result and any error. Loop protection stops chains where rule A triggers rule B triggers A.

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
Trigger matching, condition via TFQL, idempotency, loop guard, permission ceiling, Celery retry behaviour.

## Depends on
Phases 07, 14, 19.
