"""One shape for every JSON body this API returns.

A client that has to guess where the payload is -- top level here, under a key
there, an error that is sometimes ``detail`` and sometimes a list of pydantic
dictionaries -- writes a branch for each endpoint. So every response leaves this
API in the same envelope:

.. code-block:: json

    {
      "errors": null,
      "data": {"token_type": "Bearer"},
      "isSuccess": true,
      "statusCode": 200,
      "title": "SUCCESS",
      "description": "The request succeeded."
    }

``title`` is the part worth understanding. It is a stable enum member, never a
sentence, so a client can key its own translations off it and show the user a
message in their language. ``description`` is the English gloss of the same
thing, for the developer reading a log or a failed request in a console -- it is
not meant to be shown to an end user and is not translated.

The wrapping happens in :class:`EnvelopeRenderer`, at the point where the body is
serialised, rather than in each endpoint. Views therefore go on returning their
own schemas, and the envelope cannot be forgotten on the one path nobody tested.
Handlers that need to say more than the status code does -- an error's message,
a domain-specific title -- build the body themselves with :func:`envelope`, and
the renderer leaves an :class:`Enveloped` body alone.

The one body this does not cover is a 500 raised by a bug: Django Ninja re-raises
those for Django to handle, so they never reach this renderer.
"""

import json
from enum import StrEnum
from typing import Any

from django.http import HttpRequest, JsonResponse
from ninja import NinjaAPI, Schema
from ninja.renderers import JSONRenderer

ENVELOPE_KEYS = ("errors", "data", "isSuccess", "statusCode", "title", "description")


class ResponseTitle(StrEnum):
    """The i18n key a client translates. Add members; never reword them.

    The value is the member name, so what a client matches on is what the code
    reads. Renaming one is a breaking change to every client that translated it,
    which is the whole reason it is an enum and not the human sentence next to it.
    """

    # Success
    SUCCESS = "SUCCESS"
    CREATED = "CREATED"

    # Failures that the status code alone already describes
    BAD_REQUEST = "BAD_REQUEST"
    VALIDATION_ERROR = "VALIDATION_ERROR"
    AUTHENTICATION_REQUIRED = "AUTHENTICATION_REQUIRED"
    FORBIDDEN = "FORBIDDEN"
    NOT_FOUND = "NOT_FOUND"
    CONFLICT = "CONFLICT"
    GONE = "GONE"
    RATE_LIMITED = "RATE_LIMITED"
    SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE"
    INTERNAL_ERROR = "INTERNAL_ERROR"

    # Accounts and passwords
    INVALID_CREDENTIALS = "INVALID_CREDENTIALS"
    INVALID_IDENTIFIER = "INVALID_IDENTIFIER"
    USERNAME_REQUIRED = "USERNAME_REQUIRED"
    ACCOUNT_EXISTS = "ACCOUNT_EXISTS"
    ACCOUNT_NOT_FOUND = "ACCOUNT_NOT_FOUND"
    ACCOUNT_DISABLED = "ACCOUNT_DISABLED"
    PHONE_IN_USE = "PHONE_IN_USE"
    ACCOUNT_HAS_NO_EMAIL = "ACCOUNT_HAS_NO_EMAIL"
    WEAK_PASSWORD = "WEAK_PASSWORD"
    INCORRECT_PASSWORD = "INCORRECT_PASSWORD"

    # Codes and the sign-ins they belong to
    INVALID_CODE = "INVALID_CODE"
    CODE_NOT_REQUESTED = "CODE_NOT_REQUESTED"
    CODE_EXPIRED = "CODE_EXPIRED"
    TOO_MANY_ATTEMPTS = "TOO_MANY_ATTEMPTS"
    CHALLENGE_INVALID = "CHALLENGE_INVALID"
    SIGN_IN_EXPIRED = "SIGN_IN_EXPIRED"

    # Second factors
    SECOND_FACTOR_UNSPECIFIED = "SECOND_FACTOR_UNSPECIFIED"
    SECOND_FACTOR_NOT_ENABLED = "SECOND_FACTOR_NOT_ENABLED"
    SECOND_FACTOR_NOT_SET_UP = "SECOND_FACTOR_NOT_SET_UP"
    SECOND_FACTOR_EXISTS = "SECOND_FACTOR_EXISTS"
    SECOND_FACTOR_NOT_CODE_BASED = "SECOND_FACTOR_NOT_CODE_BASED"
    SECOND_FACTOR_NO_DESTINATION = "SECOND_FACTOR_NO_DESTINATION"
    ENROLMENT_NOT_STARTED = "ENROLMENT_NOT_STARTED"
    SECOND_FACTOR_LOCKED = "SECOND_FACTOR_LOCKED"

    # Security policy and single sign-on
    TWO_FACTOR_REQUIRED = "TWO_FACTOR_REQUIRED"
    SSO_REQUIRED = "SSO_REQUIRED"
    SSO_FAILED = "SSO_FAILED"
    SSO_NOT_CONFIGURED = "SSO_NOT_CONFIGURED"
    SSO_EMAIL_UNVERIFIED = "SSO_EMAIL_UNVERIFIED"
    SSO_DOMAIN_NOT_ALLOWED = "SSO_DOMAIN_NOT_ALLOWED"
    SSO_NO_ACCOUNT = "SSO_NO_ACCOUNT"
    SSO_MEMBER_REMOVED = "SSO_MEMBER_REMOVED"

    # Credentials and sessions
    TOKEN_REQUIRED = "TOKEN_REQUIRED"
    TOKEN_INVALID = "TOKEN_INVALID"
    TOKEN_EXPIRED = "TOKEN_EXPIRED"
    TOKEN_REUSED = "TOKEN_REUSED"
    REFRESH_RACE = "REFRESH_RACE"
    TOKENS_UNSUPPORTED = "TOKENS_UNSUPPORTED"
    SESSION_ENDED = "SESSION_ENDED"
    SESSION_NOT_FOUND = "SESSION_NOT_FOUND"
    NOT_SIGNED_IN = "NOT_SIGNED_IN"

    # Social sign-in
    OAUTH_NOT_CONFIGURED = "OAUTH_NOT_CONFIGURED"
    OAUTH_STATE_MISSING = "OAUTH_STATE_MISSING"
    OAUTH_FAILED = "OAUTH_FAILED"

    # Workspaces
    VERSION_CONFLICT = "VERSION_CONFLICT"
    SLUG_INVALID = "SLUG_INVALID"
    SLUG_TAKEN = "SLUG_TAKEN"
    CONFIRMATION_MISMATCH = "CONFIRMATION_MISMATCH"
    UPLOAD_INVALID = "UPLOAD_INVALID"
    INVITE_EXPIRED = "INVITE_EXPIRED"
    INVITE_REVOKED = "INVITE_REVOKED"
    INVITE_USED_UP = "INVITE_USED_UP"
    INVITE_EMAIL_MISMATCH = "INVITE_EMAIL_MISMATCH"
    INVITE_NOT_PENDING = "INVITE_NOT_PENDING"
    INVITE_BEFORE_REMOVAL = "INVITE_BEFORE_REMOVAL"
    OWNER_PROTECTED = "OWNER_PROTECTED"
    PERMISSION_DENIED_REASON = "PERMISSION_DENIED_REASON"
    ROLE_BUILTIN = "ROLE_BUILTIN"
    ROLE_NAME_TAKEN = "ROLE_NAME_TAKEN"

    # Projects
    KEY_TAKEN = "KEY_TAKEN"
    KEY_LOCKED = "KEY_LOCKED"
    PROJECT_ARCHIVED = "PROJECT_ARCHIVED"
    LAST_MEMBER = "LAST_MEMBER"

    # Workflows
    WORKFLOW_INVALID = "WORKFLOW_INVALID"
    TRANSITION_NOT_ALLOWED = "TRANSITION_NOT_ALLOWED"

    # Subtasks
    HAS_SUBTASKS = "HAS_SUBTASKS"
    SUBTASK_CYCLE = "SUBTASK_CYCLE"
    LINK_CYCLE = "LINK_CYCLE"
    LINK_EXISTS = "LINK_EXISTS"
    TASK_BLOCKED = "TASK_BLOCKED"

    # Custom fields
    FIELD_INVALID = "FIELD_INVALID"
    FIELD_REQUIRED = "FIELD_REQUIRED"
    FIELD_NAME_TAKEN = "FIELD_NAME_TAKEN"
    FIELD_LIMIT = "FIELD_LIMIT"
    OPTION_NEEDS_REMAP = "OPTION_NEEDS_REMAP"

    # Saved views
    VIEW_INVALID = "VIEW_INVALID"
    VIEW_NAME_TAKEN = "VIEW_NAME_TAKEN"
    VIEW_LIMIT = "VIEW_LIMIT"

    # Shortcuts
    SHORTCUT_INVALID = "SHORTCUT_INVALID"
    SHORTCUT_CONFLICT = "SHORTCUT_CONFLICT"

    # Dashboards
    DASHBOARD_INVALID = "DASHBOARD_INVALID"
    DASHBOARD_LIMIT = "DASHBOARD_LIMIT"
    DASHBOARD_TOO_HEAVY = "DASHBOARD_TOO_HEAVY"

    # Filters
    FILTER_INVALID = "FILTER_INVALID"
    FILTER_NAME_TAKEN = "FILTER_NAME_TAKEN"
    FILTER_LIMIT = "FILTER_LIMIT"

    # Comments
    COMMENT_INVALID = "COMMENT_INVALID"
    COMMENT_LOCKED = "COMMENT_LOCKED"
    DOC_INVALID = "DOC_INVALID"
    DOC_ARCHIVED = "DOC_ARCHIVED"
    DOC_CYCLE = "DOC_CYCLE"
    MENTION_NO_ACCESS = "MENTION_NO_ACCESS"

    # Attachments
    ATTACHMENT_TOO_BIG = "ATTACHMENT_TOO_BIG"
    ATTACHMENT_REFUSED = "ATTACHMENT_REFUSED"
    ATTACHMENT_QUOTA = "ATTACHMENT_QUOTA"
    UPLOAD_INCOMPLETE = "UPLOAD_INCOMPLETE"
    UPLOAD_EXPIRED = "UPLOAD_EXPIRED"
    LINK_EXPIRED = "LINK_EXPIRED"


DESCRIPTIONS: dict[ResponseTitle, str] = {
    ResponseTitle.SUCCESS: "The request succeeded.",
    ResponseTitle.CREATED: "The resource was created.",
    ResponseTitle.BAD_REQUEST: "The request was refused.",
    ResponseTitle.VALIDATION_ERROR: "The request body did not validate.",
    ResponseTitle.AUTHENTICATION_REQUIRED: "This endpoint needs a credential.",
    ResponseTitle.FORBIDDEN: "This account may not do that.",
    ResponseTitle.NOT_FOUND: "There is no such thing to act on.",
    ResponseTitle.CONFLICT: "That would conflict with something that already exists.",
    ResponseTitle.GONE: "What the request refers to has expired.",
    ResponseTitle.RATE_LIMITED: "Too many attempts. Wait and try again.",
    ResponseTitle.SERVICE_UNAVAILABLE: "A dependency this endpoint needs is unavailable.",
    ResponseTitle.INTERNAL_ERROR: "The request failed for a reason the client cannot fix.",
    ResponseTitle.INVALID_CREDENTIALS: "The identifier or the password is wrong.",
    ResponseTitle.INVALID_IDENTIFIER: "That is not a usable email address or phone number.",
    ResponseTitle.USERNAME_REQUIRED: "A username is required.",
    ResponseTitle.ACCOUNT_EXISTS: "An account already uses that identifier.",
    ResponseTitle.ACCOUNT_NOT_FOUND: "No account uses that identifier.",
    ResponseTitle.ACCOUNT_DISABLED: "The account exists but may not sign in.",
    ResponseTitle.PHONE_IN_USE: "Another account already uses that phone number.",
    ResponseTitle.ACCOUNT_HAS_NO_EMAIL: "The account has no email address to send to.",
    ResponseTitle.WEAK_PASSWORD: "The password does not meet the policy.",
    ResponseTitle.INCORRECT_PASSWORD: "The current password given is not this account's.",
    ResponseTitle.VERSION_CONFLICT: "Someone else changed this first; reload and retry.",
    ResponseTitle.SLUG_INVALID: "That URL name is malformed or reserved.",
    ResponseTitle.SLUG_TAKEN: "That URL name is already in use.",
    ResponseTitle.CONFIRMATION_MISMATCH: "The confirmation text does not match.",
    ResponseTitle.UPLOAD_INVALID: "The uploaded file is too large or not a supported image.",
    ResponseTitle.INVITE_EXPIRED: "This invitation has expired.",
    ResponseTitle.INVITE_REVOKED: "This invitation was revoked.",
    ResponseTitle.INVITE_USED_UP: "This invitation has no uses left.",
    ResponseTitle.INVITE_EMAIL_MISMATCH: "This invitation is for a different email.",
    ResponseTitle.INVITE_NOT_PENDING: "This invitation is no longer pending.",
    ResponseTitle.INVITE_BEFORE_REMOVAL: "This invitation predates your removal.",
    ResponseTitle.OWNER_PROTECTED: "The last workspace owner cannot be demoted, removed or leave.",
    ResponseTitle.PERMISSION_DENIED_REASON: "Your role lacks a permission this needs.",
    ResponseTitle.ROLE_BUILTIN: "Built-in roles cannot be changed or deleted.",
    ResponseTitle.ROLE_NAME_TAKEN: "A role with that name already exists.",
    ResponseTitle.KEY_TAKEN: "That project key is already used in this workspace.",
    ResponseTitle.KEY_LOCKED: "The project key cannot change once the project has tasks.",
    ResponseTitle.PROJECT_ARCHIVED: "This project is archived and read-only.",
    ResponseTitle.LAST_MEMBER: "A private project needs at least one member.",
    ResponseTitle.WORKFLOW_INVALID: "The workflow has problems; see the list.",
    ResponseTitle.TRANSITION_NOT_ALLOWED: "The workflow does not allow that move.",
    ResponseTitle.HAS_SUBTASKS: "The task has subtasks: delete them with it or promote them.",
    ResponseTitle.SUBTASK_CYCLE: "A task cannot be put under itself or one of its own subtasks.",
    ResponseTitle.LINK_CYCLE: "That link would make tasks block each other in a loop.",
    ResponseTitle.LINK_EXISTS: "These tasks are already linked that way.",
    ResponseTitle.TASK_BLOCKED: "The task is blocked by tasks that are not done yet.",
    ResponseTitle.FIELD_INVALID: "A custom field value or definition is not valid.",
    ResponseTitle.FIELD_REQUIRED: "A required custom field has no value.",
    ResponseTitle.FIELD_NAME_TAKEN: "A field with that name already exists in this project.",
    ResponseTitle.FIELD_LIMIT: "A project can have at most 50 active custom fields.",
    ResponseTitle.OPTION_NEEDS_REMAP: "Removed options are in use: say what their values become.",
    ResponseTitle.VIEW_INVALID: "The saved layout is not valid.",
    ResponseTitle.VIEW_NAME_TAKEN: "You already have a layout with that name in this project.",
    ResponseTitle.VIEW_LIMIT: "That is the most layouts one list can hold.",
    ResponseTitle.SHORTCUT_INVALID: "The shortcut is not valid.",
    ResponseTitle.SHORTCUT_CONFLICT: "Another action already uses those keys.",
    ResponseTitle.DASHBOARD_INVALID: "The dashboard or widget is not valid (the detail says why).",
    ResponseTitle.DASHBOARD_LIMIT: "That is the most widgets or dashboards one place can hold.",
    ResponseTitle.DASHBOARD_TOO_HEAVY: "This widget takes too long to compute. Narrow its filter.",
    ResponseTitle.FILTER_INVALID: "The filter is not valid (the detail says where).",
    ResponseTitle.FILTER_NAME_TAKEN: "A filter with that name already exists here.",
    ResponseTitle.FILTER_LIMIT: "That is the most saved filters one place can hold.",
    ResponseTitle.COMMENT_INVALID: "The comment is not valid (the detail says why).",
    ResponseTitle.COMMENT_LOCKED: "That comment can no longer be edited.",
    ResponseTitle.DOC_INVALID: "The page is not valid (the detail says why).",
    ResponseTitle.DOC_ARCHIVED: "That page is archived. Restore it first.",
    ResponseTitle.DOC_CYCLE: "A page cannot be put under itself or one of its own subpages.",
    ResponseTitle.MENTION_NO_ACCESS: "Somebody mentioned cannot see this task.",
    ResponseTitle.ATTACHMENT_TOO_BIG: "That file is larger than an attachment may be.",
    ResponseTitle.ATTACHMENT_REFUSED: "That kind of file is not accepted (the detail says why).",
    ResponseTitle.ATTACHMENT_QUOTA: "The workspace has used all its storage.",
    ResponseTitle.UPLOAD_INCOMPLETE: "Some chunks of the upload have not arrived (data.missing).",
    ResponseTitle.UPLOAD_EXPIRED: "That upload expired; start it again.",
    ResponseTitle.LINK_EXPIRED: "That file link has expired; ask for a new one.",
    ResponseTitle.INVALID_CODE: "The code is wrong.",
    ResponseTitle.CODE_NOT_REQUESTED: "Ask for a code before trying to verify one.",
    ResponseTitle.CODE_EXPIRED: "The code has expired. Ask for another.",
    ResponseTitle.TOO_MANY_ATTEMPTS: "Too many wrong attempts. Start again.",
    ResponseTitle.CHALLENGE_INVALID: "The ticket is unknown or no longer usable.",
    ResponseTitle.SIGN_IN_EXPIRED: "This sign-in is no longer valid. Start again.",
    ResponseTitle.SECOND_FACTOR_UNSPECIFIED: "The request must say which second factor it means.",
    ResponseTitle.SECOND_FACTOR_NOT_ENABLED: "This deployment does not offer that second factor.",
    ResponseTitle.SECOND_FACTOR_NOT_SET_UP: "This account has not set that second factor up.",
    ResponseTitle.SECOND_FACTOR_EXISTS: "That second factor is already set up.",
    ResponseTitle.SECOND_FACTOR_NOT_CODE_BASED: "That second factor does not use a sent code.",
    ResponseTitle.SECOND_FACTOR_NO_DESTINATION: "That second factor has no destination on file.",
    ResponseTitle.ENROLMENT_NOT_STARTED: "Begin enrolment before confirming it.",
    ResponseTitle.SECOND_FACTOR_LOCKED: "Too many wrong codes. Wait a while before trying again.",
    ResponseTitle.TWO_FACTOR_REQUIRED: (
        "This workspace requires two-factor authentication. Turn it on in Security settings."
    ),
    ResponseTitle.SSO_REQUIRED: "This workspace requires single sign-on. Use Continue with SSO.",
    ResponseTitle.SSO_FAILED: "Single sign-on could not be completed. Start again.",
    ResponseTitle.SSO_NOT_CONFIGURED: "Single sign-on is not set up for that workspace.",
    ResponseTitle.SSO_EMAIL_UNVERIFIED: (
        "The identity provider did not confirm this email address, so it cannot be used to sign in."
    ),
    ResponseTitle.SSO_DOMAIN_NOT_ALLOWED: "That email domain may not sign in to this workspace.",
    ResponseTitle.SSO_NO_ACCOUNT: "No account exists for this identity and sign-up is off.",
    ResponseTitle.SSO_MEMBER_REMOVED: "You were removed from this workspace. Ask for an invitation.",  # noqa: E501
    ResponseTitle.TOKEN_REQUIRED: "A token is required and none was given.",
    ResponseTitle.TOKEN_INVALID: "The token is not one this deployment issued.",
    ResponseTitle.TOKEN_EXPIRED: "The token has expired.",
    ResponseTitle.TOKEN_REUSED: "A spent token was presented again; the session was ended.",
    ResponseTitle.REFRESH_RACE: "That refresh token was just spent; retry with the newer one.",
    ResponseTitle.TOKENS_UNSUPPORTED: "This deployment does not issue that kind of credential.",
    ResponseTitle.SESSION_ENDED: "The session has ended. Sign in again.",
    ResponseTitle.SESSION_NOT_FOUND: "No such session.",
    ResponseTitle.NOT_SIGNED_IN: "There is no signed-in session to act on.",
    ResponseTitle.OAUTH_NOT_CONFIGURED: "This provider has no credentials configured.",
    ResponseTitle.OAUTH_STATE_MISSING: "The callback arrived without its state.",
    ResponseTitle.OAUTH_FAILED: "The provider did not complete the sign-in.",
}

TITLE_FOR_STATUS: dict[int, ResponseTitle] = {
    201: ResponseTitle.CREATED,
    400: ResponseTitle.BAD_REQUEST,
    401: ResponseTitle.AUTHENTICATION_REQUIRED,
    403: ResponseTitle.FORBIDDEN,
    404: ResponseTitle.NOT_FOUND,
    409: ResponseTitle.CONFLICT,
    410: ResponseTitle.GONE,
    422: ResponseTitle.VALIDATION_ERROR,
    429: ResponseTitle.RATE_LIMITED,
    503: ResponseTitle.SERVICE_UNAVAILABLE,
}


def title_for_status(status: int) -> ResponseTitle:
    """The title to use when nothing more specific was supplied."""
    if status in TITLE_FOR_STATUS:
        return TITLE_FOR_STATUS[status]
    if status < 400:
        return ResponseTitle.SUCCESS
    if status < 500:
        return ResponseTitle.BAD_REQUEST
    return ResponseTitle.INTERNAL_ERROR


class Enveloped(dict[str, Any]):
    """A body that is already in the envelope. The renderer passes it through."""


def envelope(
    *,
    status: int,
    data: Any = None,
    errors: list[str] | None = None,
    title: ResponseTitle | None = None,
    description: str = "",
) -> Enveloped:
    """Build the one response shape, filling in whatever was not spelled out."""
    resolved = title or title_for_status(status)
    return Enveloped(
        errors=errors or None,
        data=data,
        isSuccess=status < 400,
        statusCode=status,
        title=resolved.value,
        description=description or DESCRIPTIONS[resolved],
    )


def envelope_response(
    *,
    status: int,
    data: Any = None,
    errors: list[str] | None = None,
    title: ResponseTitle | None = None,
    description: str = "",
) -> JsonResponse:
    """The same envelope, for the few views that answer outside the API layer.

    The OAuth callbacks are plain Django views -- they may end in a redirect --
    so they never pass through the renderer and have to wrap their own bodies.
    """
    return JsonResponse(
        envelope(
            status=status,
            data=data,
            errors=errors,
            title=title,
            description=description,
        ),
        status=status,
    )


class EnvelopeRenderer(JSONRenderer):
    """Wrap every JSON body on its way out, unless it is wrapped already."""

    def render(self, request: HttpRequest, data: Any, *, response_status: int) -> Any:
        if not isinstance(data, Enveloped):
            data = envelope(status=response_status, data=data)
        return json.dumps(data, cls=self.encoder_class, **self.json_dumps_params)


class EnvelopeOut(Schema):
    """The envelope itself, so that ``/docs`` has something to point at.

    Endpoints keep declaring the schema of what they put in ``data``; this class
    documents the six keys wrapped around it, and
    :func:`document_envelope` is what rewrites the published operations to say so.
    """

    errors: list[str] | None = None
    data: Any = None
    isSuccess: bool
    statusCode: int
    title: ResponseTitle
    description: str


def _envelope_schema(data_schema: dict[str, Any] | None) -> dict[str, Any]:
    """The OpenAPI schema for one enveloped body, around a given ``data``."""
    return {
        "title": "ResponseEnvelope",
        "type": "object",
        "properties": {
            "errors": {"type": ["array", "null"], "items": {"type": "string"}},
            "data": data_schema if data_schema is not None else {"type": "null"},
            "isSuccess": {"type": "boolean"},
            "statusCode": {"type": "integer"},
            "title": {"$ref": "#/components/schemas/ResponseTitle"},
            "description": {"type": "string"},
        },
        "required": list(ENVELOPE_KEYS),
    }


def document_envelope(schema: dict[str, Any], media_type: str) -> dict[str, Any]:
    """Rewrite a generated OpenAPI document to describe what is actually sent.

    Django Ninja documents the schema a view returns, which is now the *inside*
    of the envelope. Rather than restate the wrapper on 50-odd operations by
    hand -- where it would be wrong the first time somebody added one -- each
    documented response is wrapped here, once, on the way out.

    Every operation also gains a ``default`` response, because the errors that
    are raised rather than returned -- a rejected body, a missing credential --
    are answers no endpoint declares but every endpoint can give.
    """
    components = schema.setdefault("components", {}).setdefault("schemas", {})
    components["ResponseTitle"] = {
        "title": "ResponseTitle",
        "description": "Stable key for the message a client shows its user.",
        "type": "string",
        "enum": [title.value for title in ResponseTitle],
    }
    for operations in schema.get("paths", {}).values():
        for operation in operations.values():
            responses = operation.get("responses", {})
            for response in responses.values():
                content = response.get("content", {}).get(media_type)
                if content is not None:
                    content["schema"] = _envelope_schema(content.get("schema"))
            responses["default"] = {
                "description": "An error, in the same envelope, with `data` null.",
                "content": {media_type: {"schema": _envelope_schema(None)}},
            }
    return schema


class EnvelopeAPI(NinjaAPI):
    """A :class:`~ninja.NinjaAPI` whose documentation matches its renderer."""

    def get_openapi_schema(
        self,
        *,
        path_prefix: str | None = None,
        path_params: dict[str, Any] | None = None,
    ) -> Any:
        schema = super().get_openapi_schema(path_prefix=path_prefix, path_params=path_params)
        return document_envelope(schema, self.renderer.media_type or "application/json")
