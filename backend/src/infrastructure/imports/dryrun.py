"""What an import would do, said before it does anything: counts and warnings from the same scan
and the same rules the run uses, so the review step and the result agree."""

from collections import Counter
from dataclasses import dataclass, field
from typing import Any

from infrastructure.imports import (
    engine,
    files,
    parsers,
)
from infrastructure.imports import (
    mapping as mapping_rules,
)
from infrastructure.imports import (
    scan as scanning,
)
from infrastructure.imports.models import ImportedRef, ImportJob
from infrastructure.imports.prepare import Run
from infrastructure.imports.records import Problem
from infrastructure.workspaces.models import Workspace

MAX_WARNINGS = 100


@dataclass(slots=True)
class Report:
    counts: dict[str, int] = field(default_factory=dict)
    warnings: list[dict[str, Any]] = field(default_factory=list)
    errors: int = 0  # rows that cannot be imported
    warning_total: int = 0
    already_imported: int = 0


def _head(job: ImportJob) -> dict[str, Any]:
    return engine._header(job)


def report(job: ImportJob, workspace: Workspace, mapping: dict[str, Any]) -> Report:
    """Scan the file under ``mapping`` (already checked) and describe the run."""
    head = _head(job)
    binary = files.open_job(job)
    try:
        found = scanning.scan(job.source, binary, mapping, head)
    finally:
        binary.close()
    info = scanning.finish(found)
    out = Report()
    out.counts = {
        "tasks": info.issues,
        "subtasks": info.subtasks,
        "comments": info.comments,
        "links": info.links,
        "sprints": len(info.sprints),
        "labels": info.labels if mapping.get("labels") else 0,
        "new_statuses": sum(1 for v in mapping["statuses"].values() if v == "new"),
        "placeholders": sum(
            1 for k in info.people if mapping["users"].get(k, "placeholder") == "placeholder"
        ),
        "people": len(info.people),
    }
    out.already_imported = ImportedRef.objects.filter(
        workspace=workspace,
        family=parsers.FAMILY[job.source],
        entity_type="task",
        source_id__in=list(found.ids)[:50_000],
    ).count()
    problems: list[Problem] = list(info.problems)
    run = Run(job, workspace, job.created_by, parsers.FAMILY[job.source], mapping)
    engine.Structure(run, found)  # its warnings: missing parents, cycles
    problems += [Problem(w["line"], w["message"], w["level"]) for w in run.problems]
    _more(found, info, mapping, problems)
    out.errors = sum(1 for p in problems if p.level == "error")
    out.warning_total = len(problems) - out.errors
    kinds: Counter[str] = Counter()
    for p in problems:
        if p.level == "error" or kinds[p.message[:40]] < 3:
            kinds[p.message[:40]] += 1
            if len(out.warnings) < MAX_WARNINGS:
                out.warnings.append({"line": p.line, "message": p.message, "level": p.level})
    return out


def _more(
    found: scanning.Scan, info: Any, mapping: dict[str, Any], problems: list[Problem]
) -> None:
    unmapped = [s for s in info.statuses if s not in mapping["statuses"]]
    if unmapped:
        problems.append(
            Problem(
                0, f"{len(unmapped)} status(es) were not mapped and will be created.", "warning"
            )
        )
    if found.due_before_start:
        problems.append(
            Problem(
                0,
                f"{found.due_before_start} issue(s) are due before they start: start dropped.",
                "warning",
            )
        )
    if found.long_texts:
        problems.append(
            Problem(
                0,
                f"{found.long_texts} description(s) are longer than TaskForge keeps and are cut.",
                "warning",
            )
        )
    missing = {t for t in found.targets if found.keys.get(t, t) not in found.ids}
    if missing:
        problems.append(
            Problem(
                0,
                f"{len(missing)} linked issue(s) are not in the file: those links are skipped.",
                "warning",
            )
        )
    if mapping.get("labels") and info.labels > mapping_rules.MAX_LABEL_OPTIONS:
        problems.append(
            Problem(
                0,
                f"{info.labels} labels: only {mapping_rules.MAX_LABEL_OPTIONS} fit one field.",
                "warning",
            )
        )
    if found.undated_sprints:
        problems.append(
            Problem(
                0, "Some sprints have no dates; they start the day they are imported.", "warning"
            )
        )
