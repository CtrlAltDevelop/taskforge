"""Request and response bodies for second-factor enrolment and challenges."""

from ninja import Schema


class ChallengeIn(Schema):
    login_ticket: str
    method: str


class VerifyIn(Schema):
    login_ticket: str
    code: str
    method: str = ""
    # Phase 37: remember this device so the next sign-in skips the code (30 days).
    remember_device: bool = False
    device_label: str = ""


class EnrolledFactor(Schema):
    method: str
    destination: str
    confirmed: bool
    last_used_at: str = ""


class FactorListOut(Schema):
    methods: list[EnrolledFactor]
    available: list[str]
    unused_recovery_codes: int


class TotpEnrollOut(Schema):
    """The shared secret, in the two forms an authenticator app accepts."""

    secret: str
    otpauth_uri: str


class CodeIn(Schema):
    code: str


class TicketCodeIn(Schema):
    ticket: str
    code: str


class PhoneIn(Schema):
    phone: str


class RecoveryCodesOut(Schema):
    """Shown once. The server keeps only digests from here on."""

    codes: list[str]
