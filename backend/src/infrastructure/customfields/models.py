"""Custom fields: a project's typed field definitions and the values tasks hold for them."""

import uuid

from django.db import models
from django.db.models import Q
from django.db.models.functions import Lower
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task


class FieldType(models.TextChoices):
    TEXT = "text"
    NUMBER = "number"
    SELECT = "select"
    MULTISELECT = "multiselect"
    DATE = "date"
    CHECKBOX = "checkbox"
    URL = "url"
    USER = "user"
    MONEY = "money"


class FieldDefinition(models.Model):
    """A typed field a project defines for its tasks.

    ``options`` is ``[{"id", "label", "color"}]`` for the select types (else ``[]``);
    ``default`` is the value in its wire form (``""``: none). ``hidden_views`` names the views
    (``list``, ``board`` ...) that do not show the field. ``version`` is the optimistic lock of a
    definition save. An archived field keeps its values until ``archived_at`` is 30 days old."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="custom_fields")
    name = models.CharField(max_length=60)
    type = models.CharField(max_length=12, choices=FieldType.choices)
    options = models.JSONField(default=list, blank=True)
    required = models.BooleanField(default=False)
    default = models.CharField(max_length=3400, blank=True)
    hidden_views = models.JSONField(default=list, blank=True)
    position = models.PositiveIntegerField(default=0)
    version = models.PositiveIntegerField(default=1)
    archived_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["position", "created_at"]
        constraints = [
            models.UniqueConstraint(
                Lower("name"),
                "project",
                condition=Q(archived_at__isnull=True),
                name="custom_field_name_unique",
            )
        ]

    def __str__(self) -> str:
        return self.name


class FieldValue(models.Model):
    """The value one task holds for one field.

    Each kind uses the column that can be indexed for it: ``value_text``
    (text, url, a select option id, a user id, a money currency), ``value_number`` (number,
    money amount, checkbox as 0/1), ``value_date`` and ``value_json`` (a multi-select's ids)."""

    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="field_values")
    field = models.ForeignKey(FieldDefinition, on_delete=models.CASCADE, related_name="values")
    value_text = models.CharField(max_length=2000, blank=True, default="")
    value_number = models.DecimalField(max_digits=28, decimal_places=6, null=True, blank=True)
    value_date = models.DateField(null=True, blank=True)
    value_json = models.JSONField(null=True, blank=True)

    class Meta:
        constraints = [models.UniqueConstraint(fields=["task", "field"], name="field_value_unique")]
        indexes = [
            models.Index(fields=["field", "value_text"], name="fv_text_idx"),
            models.Index(fields=["field", "value_number"], name="fv_number_idx"),
            models.Index(fields=["field", "value_date"], name="fv_date_idx"),
        ]

    def __str__(self) -> str:
        return f"{self.field_id} on {self.task_id}"
