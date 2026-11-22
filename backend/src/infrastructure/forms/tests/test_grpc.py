"""The form RPCs carry the default field values (labels) and the effective logo."""

from typing import Any

from infrastructure.customfields import services as fields
from infrastructure.forms.grpc import forms_pb2 as pb
from infrastructure.forms.grpc import forms_pb2_grpc as stubs
from infrastructure.sync.actor import set_actor
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

FORM = stubs.FormControllerStub


def test_field_defaults_round_trip_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    owner = world.workspace.created_by
    set_actor(owner)
    field = fields.create(
        owner,
        world.workspace,
        world.project_id,
        name="Labels",
        type="multiselect",
        options=[{"label": "bug"}],
    )
    option = field.options[0]["id"]
    token = world.tokens["Owner"]

    made = grpc_call(
        FORM,
        "Create",
        pb.FormCreateRequest(
            workspace_id=world.ws,
            project_id=world.project_id,
            name="Bug",
            form_fields=[pb.IntakeField(id="t", kind="title", label="Title")],
            priority="none",
            send_confirmation=True,
            field_defaults=[pb.FieldDefault(field_id=str(field.pk), value=option)],
        ),
        token=token,
    ).form

    assert [(d.field_id, d.value) for d in made.field_defaults] == [(str(field.pk), option)]

    cleared = grpc_call(
        FORM,
        "Update",
        pb.FormUpdateRequest(
            workspace_id=world.ws,
            form_id=made.id,
            changed=["defaults"],
            expected_version=made.version,
            priority="none",
        ),
        token=token,
    ).form

    assert list(cleared.field_defaults) == []
