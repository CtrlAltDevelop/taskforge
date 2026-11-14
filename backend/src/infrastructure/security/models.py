"""Workspace security policy, trusted devices and OIDC single sign-on.

Two-factor secrets and recovery codes are the starter's (``auth_twofactor``); this app adds what
is TaskForge's own: a workspace's *policy* about them, remembered devices, and the identity
provider a workspace signs in through. Every secret here (a client secret, a PKCE verifier) is
stored encrypted with the field key (``DJANGO_FIELD_ENCRYPTION_KEY``).
"""

import uuid

from django.conf import settings
from django.db import models
from django.utils import timezone


class SecurityPolicy(models.Model):
    """What a workspace requires of its members. One row per workspace, made on first change.

    ``enforced_from`` is when "require two-factor" starts to bite: switching the policy on sets it
    to now plus ``grace_days``, so people have time to enrol. From then on a member without a
    confirmed authenticator is refused every workspace call until they enrol.
    """

    workspace = models.OneToOneField(
        "workspaces.Workspace",
        on_delete=models.CASCADE,
        related_name="security_policy",
        primary_key=True,
    )
    require_2fa = models.BooleanField(default=False)
    grace_days = models.PositiveSmallIntegerField(default=7)
    enforced_from = models.DateTimeField(null=True, blank=True)
    updated_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    updated_at = models.DateTimeField(auto_now=True)
    version = models.PositiveIntegerField(default=1)

    def __str__(self) -> str:
        return f"policy of {self.workspace_id}"


class TrustedDevice(models.Model):
    """A device that skipped the second factor after one successful check, for a while.

    Only the SHA-256 of the token is stored. The token is a bearer secret handed to the client
    once; losing the device means revoking the row.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="trusted_devices"
    )
    token_hash = models.CharField(max_length=64, unique=True, editable=False)
    label = models.CharField(max_length=120, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    last_used_at = models.DateTimeField(null=True, blank=True)
    expires_at = models.DateTimeField()
    revoked_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["user", "revoked_at", "expires_at"])]

    def __str__(self) -> str:
        return f"{self.user_id}:{self.id}"

    @property
    def is_usable(self) -> bool:
        return self.revoked_at is None and self.expires_at > timezone.now()


class IdentityProviderKind(models.TextChoices):
    OIDC = "oidc", "OpenID Connect"


class IdentityProvider(models.Model):
    """The OpenID Connect provider a workspace signs in through (one per workspace).

    ``group_role_map`` maps a value of the ``group_claim`` claim to a role id of the workspace
    (or a built-in); ``default_role`` is what a person created or admitted through SSO gets when
    no group matches. ``enforce_sso`` turns password (and every other non-SSO) sign-in off for
    the workspace's members, except for its Owners, who keep one door open in case the provider
    is down.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workspace = models.OneToOneField(
        "workspaces.Workspace", on_delete=models.CASCADE, related_name="identity_provider"
    )
    kind = models.CharField(
        max_length=16, choices=IdentityProviderKind.choices, default=IdentityProviderKind.OIDC
    )
    name = models.CharField(max_length=80, blank=True)
    issuer = models.URLField(max_length=500)
    client_id = models.CharField(max_length=255)
    client_secret_encrypted = models.TextField(blank=True, editable=False)
    scopes = models.CharField(max_length=255, default="openid email profile")
    allowed_domains = models.JSONField(default=list, blank=True)
    group_claim = models.CharField(max_length=64, default="groups", blank=True)
    group_role_map = models.JSONField(default=dict, blank=True)
    default_role = models.ForeignKey(
        "workspaces.Role", null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    auto_create_users = models.BooleanField(default=True)
    enabled = models.BooleanField(default=True)
    enforce_sso = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    version = models.PositiveIntegerField(default=1)

    def __str__(self) -> str:
        return f"{self.name or self.issuer} ({self.workspace_id})"

    def set_client_secret(self, value: str) -> None:
        from infrastructure.oauth.core.crypto import encrypt_secret

        self.client_secret_encrypted = encrypt_secret(value)

    def client_secret(self) -> str:
        from infrastructure.oauth.core.crypto import decrypt_secret

        return decrypt_secret(self.client_secret_encrypted)


class ExternalIdentity(models.Model):
    """A person as the identity provider knows them: ``subject`` is the provider's stable id."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="external_identities"
    )
    provider = models.ForeignKey(
        IdentityProvider, on_delete=models.CASCADE, related_name="identities"
    )
    subject = models.CharField(max_length=255)
    email = models.CharField(max_length=254, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    last_login_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["provider", "subject"], name="external_identity_subject_unique"
            ),
            models.UniqueConstraint(
                fields=["provider", "user"], name="external_identity_user_unique"
            ),
        ]

    def __str__(self) -> str:
        return f"{self.user_id}@{self.provider_id}"


class SsoAttempt(models.Model):
    """One sign-in in flight: the state, nonce and PKCE verifier of a single redirect.

    Everything the callback must match is here and nowhere else: the ``state`` and ``nonce`` as
    digests, the verifier encrypted, and the digest of a binding secret held in a cookie by the
    browser that started the attempt. It is consumed by the first callback that names it.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    provider = models.ForeignKey(
        IdentityProvider, on_delete=models.CASCADE, related_name="attempts"
    )
    state_hash = models.CharField(max_length=64, unique=True, editable=False)
    nonce_hash = models.CharField(max_length=64, editable=False)
    binding_hash = models.CharField(max_length=64, editable=False)
    code_verifier_encrypted = models.TextField(editable=False)
    client_challenge = models.CharField(max_length=128, blank=True)
    redirect_uri = models.CharField(max_length=500)
    return_to = models.CharField(max_length=500)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField()
    consumed_at = models.DateTimeField(null=True, blank=True)
    error = models.CharField(max_length=255, blank=True)

    class Meta:
        indexes = [models.Index(fields=["expires_at"])]

    def __str__(self) -> str:
        return f"{self.provider_id}:{self.pk}"

    @property
    def is_active(self) -> bool:
        return self.consumed_at is None and self.expires_at > timezone.now()
