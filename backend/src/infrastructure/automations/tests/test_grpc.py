"""The automation controllers over a real gRPC server: the contract."""

import json
from typing import Any

import grpc

from infrastructure.automations.grpc import automations_pb2 as pb
from infrastructure.automations.grpc import automations_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

team = base.team
A = stubs.AutomationControllerStub
R = stubs.AutomationRunControllerStub

TRIGGER = json.dumps({"type": "task_created"})
ACTIONS = json.dumps([{"type": "add_comment", "text": "Welcome {title}"}])


def _ref(team: dict[str, Any]) -> dict[str, Any]:
    return {"workspace_id": team["ws"], "project_id": team["project"]}


def _make(call: GrpcCall, team: dict[str, Any], **fields: Any) -> Any:
    request = pb.AutomationCreateRequest(
        **_ref(team),
        **{
            "name": "Welcome",
            "trigger_json": TRIGGER,
            "actions_json": ACTIONS,
            "enabled": True,
            **fields,
        },
    )
    return call(A, "Create", request, token=team["tokens"]["zoe"]).automation


def test_rule_round_trip_run_and_history(team: Any, grpc_call: GrpcCall) -> None:
    zoe = team["tokens"]["zoe"]
    rule = _make(grpc_call, team, condition_tfql="priority = high")
    assert (
        rule.owner_id == str(team["users"]["zoe"].pk) and rule.condition_tfql == "priority = high"
    )

    listed = grpc_call(A, "List", pb.AutomationListRequest(**_ref(team)), token=zoe)
    assert [a.id for a in listed.automations] == [rule.id]

    task = _create(grpc_call, team, who="zoe", title="Fix", priority="high")
    runs = grpc_call(
        R, "List", pb.AutomationRunListRequest(**_ref(team), automation_id=rule.id), token=zoe
    )
    assert [r.status for r in runs.runs] == ["succeeded"]
    one = grpc_call(
        R, "Get", pb.AutomationRunGetRequest(**_ref(team), run_id=runs.runs[0].id), token=zoe
    )
    assert one.run.task_key.endswith("-1") and json.loads(one.run.steps_json)[0]["status"] == "ok"

    dry = grpc_call(
        A,
        "DryRun",
        pb.AutomationDryRunRequest(**_ref(team), automation_id=rule.id, task_id=task.id),
        token=zoe,
    )
    assert dry.would_run and json.loads(dry.steps_json)[0]["detail"] == "Welcome Fix"

    renamed = grpc_call(
        A,
        "Update",
        pb.AutomationUpdateRequest(
            **_ref(team),
            automation_id=rule.id,
            fields=["name", "condition"],
            expected_version=rule.version,
            name="Greeter",
            condition_tfql="",
        ),
        token=zoe,
    ).automation
    assert renamed.name == "Greeter" and renamed.condition_tfql == "" and renamed.version == 2
    stale = _refused(
        grpc_call,
        A,
        "Update",
        pb.AutomationUpdateRequest(
            **_ref(team), automation_id=rule.id, fields=["name"], expected_version=1, name="X"
        ),
        token=zoe,
    )
    assert stale.code() == grpc.StatusCode.ABORTED

    off = grpc_call(
        A,
        "Toggle",
        pb.AutomationToggleRequest(**_ref(team), automation_id=rule.id, enabled=False),
        token=zoe,
    )
    assert not off.automation.enabled
    gone = grpc_call(
        A, "Delete", pb.AutomationDeleteRequest(**_ref(team), automation_id=rule.id), token=zoe
    )
    assert gone.id == rule.id
    again = _refused(
        grpc_call,
        A,
        "Toggle",
        pb.AutomationToggleRequest(**_ref(team), automation_id=rule.id, enabled=True),
        token=zoe,
    )
    assert again.code() == grpc.StatusCode.NOT_FOUND


def test_bad_rules_and_unsafe_webhooks_are_invalid_arguments(
    team: Any, grpc_call: GrpcCall
) -> None:
    zoe = team["tokens"]["zoe"]
    for fields in (
        {"trigger_json": "not json"},
        {"trigger_json": json.dumps({"type": "nope"})},
        {"actions_json": json.dumps([{"type": "webhook", "url": "http://127.0.0.1:8010/admin"}])},
        {"actions_json": json.dumps([{"type": "webhook", "url": "http://169.254.169.254/"}])},
    ):
        payload: dict[str, Any] = {
            "name": "Bad",
            "trigger_json": TRIGGER,
            "actions_json": ACTIONS,
            **fields,
        }
        request = pb.AutomationCreateRequest(**_ref(team), **payload)
        refused = _refused(grpc_call, A, "Create", request, token=zoe)
        assert refused.code() == grpc.StatusCode.INVALID_ARGUMENT


def test_members_may_read_but_not_change_and_strangers_see_nothing(
    team: Any, grpc_call: GrpcCall
) -> None:
    rule = _make(grpc_call, team)
    max_token, eve = team["tokens"]["max"], team["tokens"]["eve"]

    assert (
        len(
            grpc_call(
                A, "List", pb.AutomationListRequest(**_ref(team)), token=max_token
            ).automations
        )
        == 1
    )
    denied = _refused(
        grpc_call,
        A,
        "Toggle",
        pb.AutomationToggleRequest(**_ref(team), automation_id=rule.id, enabled=False),
        token=max_token,
    )
    assert denied.code() == grpc.StatusCode.PERMISSION_DENIED
    stranger = _refused(grpc_call, A, "List", pb.AutomationListRequest(**_ref(team)), token=eve)
    assert stranger.code() == grpc.StatusCode.PERMISSION_DENIED
