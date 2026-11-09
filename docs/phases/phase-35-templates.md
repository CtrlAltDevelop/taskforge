# Phase 35 — Templates

**Status:** TODO

## Feature
Save a **task, subtask tree, or whole project** as a template and create new ones from it.

## Why it exists
Repeated setups (sprint structure, client onboarding, release checklist) waste time. Incumbents have templates but limited or paywalled, and projects templates often miss workflows and fields.

## How it works (plain words)
From any task (with its subtasks) choose **Save as template**; from a project choose **Save project as template**. A template stores structure and defaults: statuses/workflow, custom fields, automations (optional checkbox), feature toggles, and example tasks with relative dates (“+3 days from start”). When creating a project, pick a template (or built-ins: Software team, Marketing, Bug tracker) and a **start date**; the server clones everything in one transaction, shifting relative dates. Variables like `{{client_name}}` in titles are prompted at creation time.

## Scope
**In:** task-tree templates, project templates, built-in set, variables, relative dates, choose what to include, template gallery with search, edit/delete, workspace-shared templates.
**Out:** public template marketplace, versioned templates with updates pushed to existing projects.

## Data model
- `Template(id, workspace, kind(task|project), name, description, content jsonb, created_by, visibility)` — `content` is a portable snapshot using local temp ids.

## API surface
- gRPC: `Templates.List/Get/Create/Update/Delete`, `Templates.SaveFromTask(task)`, `SaveFromProject(project, include[])`, `Templates.Apply(template, target, params) → created ids`.

## Flutter UI
Template gallery with preview of structure (tree, statuses), apply dialog collecting variables and start date, “Save as template” sheet with include checkboxes.

## Rules and edge cases
- Apply is a single transaction and also emits the normal events/audit entries so history looks natural.
- Template content is **validated against current schema** on apply (fields removed since → skipped with warning).
- Users referenced by assignees are mapped: kept only if still members, else unassigned.
- Size cap (e.g. 2,000 tasks) to prevent abuse.

## Acceptance criteria
- [ ] Save a project with workflow/fields/tasks → create a new project identical in structure
- [ ] Relative dates shift correctly from chosen start date
- [ ] Variables substituted everywhere they appear
- [ ] Failure midway leaves nothing behind

## Tests
Snapshot→apply round-trip, date shifting, validation drift, transactional rollback.

## Depends on
Phases 05–10, 24 (optional include).
