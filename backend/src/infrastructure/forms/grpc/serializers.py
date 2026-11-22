"""The messages the form controller speaks. Times are ISO 8601, empty when unset."""

from rest_framework import serializers


class IntakeField(serializers.Serializer[dict[str, object]]):
    """One question. ``kind``: title | description | custom | file. ``custom_field_id`` names the
    project custom field a ``custom`` question asks for; ``max_files`` is for ``file``. ``id`` is
    chosen by the client (letters, digits, dash, underscore; unique in the form)."""

    id = serializers.CharField()
    kind = serializers.CharField()
    label = serializers.CharField()
    help = serializers.CharField()
    required = serializers.BooleanField()
    custom_field_id = serializers.CharField()
    max_files = serializers.IntegerField()


class FieldDefault(serializers.Serializer[dict[str, object]]):
    """A project field value every task of the form starts with: ``field_id`` is a custom field
    of the project, ``value`` its wire value (a multi-select's option ids joined by commas).
    Labels are a multi-select field."""

    field_id = serializers.CharField()
    value = serializers.CharField()


class IntakeForm(serializers.Serializer[dict[str, object]]):
    """A form. ``token`` is the secret in its public URL (``/f/<token>``). ``problem`` says why
    submissions would fail now (empty when none): the owner lost a permission, the project was
    archived. ``owner_id`` is the member whose permissions create the tasks. ``logo_url`` is what
    the public page shows: the uploaded logo (``POST /api/v1/forms/{id}/logo``) or the linked
    one."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField()
    token = serializers.CharField()
    form_fields = IntakeField(many=True)
    status_id = serializers.CharField()
    priority = serializers.CharField()
    assignee_ids = serializers.ListField(child=serializers.CharField())
    enabled = serializers.BooleanField()
    require_email = serializers.BooleanField()
    send_confirmation = serializers.BooleanField()
    notify_status = serializers.BooleanField()
    brand_color = serializers.CharField()
    logo_url = serializers.CharField()
    field_defaults = FieldDefault(many=True)
    version = serializers.IntegerField()
    submission_count = serializers.IntegerField()
    problem = serializers.CharField()
    owner_id = serializers.CharField()
    created_at = serializers.CharField()
    updated_at = serializers.CharField()


class IntakeSubmission(serializers.Serializer[dict[str, object]]):
    """One send. ``task_id`` is empty when the task was deleted since."""

    id = serializers.CharField()
    form_id = serializers.CharField()
    reference = serializers.CharField()
    project_id = serializers.CharField()
    task_id = serializers.CharField()
    task_key = serializers.CharField()
    task_title = serializers.CharField()
    status_name = serializers.CharField()
    submitter_email = serializers.CharField()
    at = serializers.CharField()
