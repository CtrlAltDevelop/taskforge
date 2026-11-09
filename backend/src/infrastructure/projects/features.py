"""The one list of per-project feature switches. All default off; turning one off keeps its data."""

from dataclasses import dataclass
from typing import Final


@dataclass(frozen=True, slots=True)
class Feature:
    key: str
    label: str
    description: str


FEATURES: Final = (
    Feature("subtasks", "Subtasks", "Break a task into smaller tasks."),
    Feature("dependencies", "Dependencies", "Mark tasks that block or wait on other tasks."),
    Feature("custom_fields", "Custom fields", "Add your own typed fields to tasks."),
    Feature("time_tracking", "Time tracking", "Log time spent on tasks and see totals."),
    Feature("sprints", "Sprints", "Plan work in time-boxed sprints."),
)
FEATURE_KEYS: Final = tuple(f.key for f in FEATURES)
