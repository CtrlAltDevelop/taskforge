"""What an import needs to exist before the first task: the project, statuses, fields, sprints and
people, each made once (and remembered in ``ImportedRef`` so an undo removes exactly them)."""

import uuid
from dataclasses import dataclass, field
from typing import Any, Final

from django.contrib.auth import get_user_model
from django.db import transaction
from django.utils import timezone

from infrastructure.audit import context as audit_context
from infrastructure.common.errors import ApiError
from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.imports import mapping as mapping_rules
from infrastructure.imports.models import ImportedRef, ImportJob, PlaceholderUser
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project, ProjectMember, Visibility
from infrastructure.sprints.models import Sprint, State
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces.models import Workspace

LABELS_FIELD: Final = "Labels"


@dataclass(slots=True)
class Run:
    """The state of one run: what exists, what the mapping says, what was counted."""

    job: ImportJob
    workspace: Workspace
    creator: Any
    family: str
    mapping: dict[str, Any]
    project: Project | None = None
    statuses: dict[str, Status] = field(default_factory=dict)  # source status -> status
    default_status: Status | None = None
    users: dict[str, Any] = field(default_factory=dict)  # person key -> User | None
    placeholders: dict[str, PlaceholderUser] = field(default_factory=dict)
    label_field: FieldDefinition | None = None
    label_options: dict[str, str] = field(default_factory=dict)
    fields: dict[str, FieldDefinition] = field(default_factory=dict)  # by name (our export)
    sprints: dict[str, Sprint] = field(default_factory=dict)
    project_members: set[Any] | None = None  # None: the project is open to every member
    existing: dict[tuple[str, str], uuid.UUID] = field(default_factory=dict)
    stats: dict[str, int] = field(default_factory=dict)
    problems: list[dict[str, Any]] = field(default_factory=list)

    def count(self, name: str, n: int = 1) -> None:
        self.stats[name] = self.stats.get(name, 0) + n

    def warn(self, line: int, message: str, level: str = "warning") -> None:
        self.count(f"{level}s")
        if len(self.problems) < 1000:
            self.problems.append({"line": line, "message": message, "level": level})


def ref(
    run: Run, entity_type: str, source_id: str, entity_id: Any, meta: dict[str, Any] | None = None
) -> None:
    ImportedRef.objects.get_or_create(
        workspace=run.workspace,
        family=run.family,
        entity_type=entity_type,
        source_id=source_id,
        defaults={"job": run.job, "entity_id": entity_id, "meta": meta or {}},
    )


def load_existing(run: Run) -> None:
    rows = ImportedRef.objects.filter(workspace=run.workspace, family=run.family)
    run.existing = {
        (r.entity_type, r.source_id): r.entity_id for r in rows.iterator(chunk_size=2000)
    }


def make_project(run: Run) -> None:
    target = run.mapping["target"]
    if "project_id" in target:
        run.project = Project.objects.get(pk=target["project_id"], workspace=run.workspace)
    elif run.job.project_id:
        run.project = run.job.project  # an earlier run of this job made it
    else:
        with audit_context.suppressed():
            made = projects.create(run.creator, run.workspace, target["name"], target["key"])
        run.project = made.project
        ref(run, "project", str(run.job.pk), run.project.pk)
        ImportJob.objects.filter(pk=run.job.pk).update(project=run.project)
    if run.project.visibility == Visibility.PRIVATE:
        run.project_members = set(
            ProjectMember.objects.filter(project=run.project).values_list("user_id", flat=True)
        )


def make_statuses(run: Run, names: dict[str, int], known: dict[str, dict[str, Any]]) -> None:
    project = run.project
    assert project is not None
    workflows.ensure(project)
    have = {s.name.lower(): s for s in Status.objects.filter(project=project)}
    run.default_status = next((s for s in have.values() if s.is_default), None) or next(
        iter(have.values())
    )
    last = max((s.position for s in have.values()), default=-1)
    for name in names:
        choice = run.mapping["statuses"].get(name, "new")
        if choice.startswith("id:"):
            run.statuses[name] = next(s for s in have.values() if str(s.pk) == choice[3:])
            continue
        found = have.get(name.lower())
        if found is None:
            last += 1
            said = known.get(name, {})
            category = said.get("category")
            found = Status.objects.create(
                project=project,
                name=name[:40],
                color=str(said.get("color", ""))[:7],
                category=category
                if category in Category.values
                else mapping_rules.category_of(name),
                position=last,
            )
            have[name.lower()] = found
            ref(run, "status", f"{project.pk}:{name.lower()}", found.pk)
            run.count("statuses")
        run.statuses[name] = found


def make_people(run: Run, people: dict[str, str]) -> None:
    users = {str(u.pk): u for u in mapping_rules.members(run.workspace)}
    for key, name in people.items():
        choice = run.mapping["users"].get(key, "placeholder")
        if choice in users:
            run.users[key] = users[choice]
        elif choice == "skip":
            run.users[key] = None
        else:
            email = key if "@" in key else ""
            holder, made = PlaceholderUser.objects.get_or_create(
                workspace=run.workspace,
                key=key,
                defaults={"name": name[:200], "source_email": email},
            )
            if holder.claimed_by_id and holder.claimed_by_id in {u.pk for u in users.values()}:
                run.users[key] = get_user_model().objects.get(pk=holder.claimed_by_id)
                continue
            run.placeholders[key] = holder
            run.users[key] = None
            if made:
                ref(run, "placeholder", key, holder.pk)
                run.count("placeholders")


def make_labels(run: Run, labels: list[str]) -> None:
    if not run.mapping.get("labels") or not labels:
        return
    project = run.project
    assert project is not None
    field_row = FieldDefinition.objects.filter(
        project=project, name=LABELS_FIELD, archived_at__isnull=True
    ).first()
    if field_row is None:
        kept = sorted(labels)[: mapping_rules.MAX_LABEL_OPTIONS]
        field_row = FieldDefinition.objects.create(
            project=project,
            name=LABELS_FIELD,
            type=FieldType.MULTISELECT,
            options=[{"id": uuid.uuid4().hex, "label": x[:40], "color": ""} for x in kept],
            position=FieldDefinition.objects.filter(project=project).count(),
        )
        ref(run, "field", f"{project.pk}:{LABELS_FIELD}", field_row.pk)
        if len(labels) > len(kept):
            run.warn(
                0, f"Only {len(kept)} of {len(labels)} labels fit one field; the rest are dropped."
            )
    run.label_field = field_row
    run.label_options = {o["label"].casefold(): o["id"] for o in field_row.options}


def make_sprints(run: Run, sprints: dict[str, tuple[Any, Any, str]]) -> None:
    project = run.project
    assert project is not None
    today = timezone.localdate()
    for name, (start, end, state) in sprints.items():
        found = Sprint.objects.filter(project=project, name=name[:80]).first()
        if found is None:
            start = start or end or today
            end = end or start
            closed = state.lower() in ("closed", "completed")
            found = Sprint.objects.create(
                workspace=run.workspace,
                project=project,
                name=name[:80],
                start_date=start,
                end_date=max(end, start),
                state=State.COMPLETED if closed else State.PLANNED,
                completed_at=timezone.now() if closed else None,
            )
            ref(run, "sprint", f"{project.pk}:{name}", found.pk)
            run.count("sprints")
        run.sprints[name] = found


def prepare(run: Run, scan_result: Any, header: dict[str, Any]) -> None:
    """Everything an issue refers to, made in one transaction."""
    with transaction.atomic():
        make_project(run)
        make_statuses(
            run,
            scan_result.analysis.statuses,
            {str(s.get("name")): s for s in header.get("statuses") or [] if isinstance(s, dict)},
        )
        make_people(run, scan_result.analysis.people)
        make_labels(run, sorted(scan_result.labels))
        make_sprints(run, scan_result.sprint_names)
        make_fields(run, header.get("fields") or [])


def make_fields(run: Run, definitions: list[dict[str, Any]]) -> None:
    """The custom fields of a TaskForge export, by name (made when the project lacks them)."""
    project = run.project
    assert project is not None
    for item in definitions:
        if not isinstance(item, dict) or not item.get("name") or item["name"] == LABELS_FIELD:
            continue
        found = FieldDefinition.objects.filter(
            project=project, name=str(item["name"])[:60], archived_at__isnull=True
        ).first()
        if found is None:
            options = [
                {
                    "id": str(o.get("id") or uuid.uuid4().hex),
                    "label": str(o["label"]),
                    "color": str(o.get("color", "")),
                }
                for o in item.get("options") or []
                if isinstance(o, dict) and o.get("label")
            ]
            try:
                found = FieldDefinition.objects.create(
                    project=project,
                    name=str(item["name"])[:60],
                    type=str(item.get("type", "text")),
                    options=options,
                    position=FieldDefinition.objects.filter(project=project).count(),
                )
            except (ApiError, ValueError):
                continue
            ref(run, "field", f"{project.pk}:{found.name}", found.pk)
        run.fields[found.name] = found
