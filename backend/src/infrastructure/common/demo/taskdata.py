"""The demo's tasks as data. Parents come before their subtasks; ``ref`` names a task for links.

``who`` is a string of one-letter people: o owner, a admin, m member, d dev, s designer,
v viewer, g guest. Dates are day offsets from today (negative = past); est is hours.
"""

from dataclasses import dataclass, field


@dataclass(frozen=True, slots=True)
class Spec:
    title: str
    status: str
    prio: str = "none"
    who: str = ""
    start: int | None = None
    due: int | None = None
    est: int | None = None
    pts: str = ""
    parent: str = ""
    ref: str = ""
    desc: str = ""
    f: dict[str, str] = field(default_factory=dict)  # custom field name -> wire hint (see taskseed)
    by: str = "o"
    age: int = 0  # created this many days ago (0: spread automatically)


PERSIAN_DESC = """## توضیح
بعد از ورود، کاربر به صفحهٔ اصلی نمی‌رسد و دوباره به صفحهٔ ورود برمی‌گردد.
- روی مرورگر سافاری رخ می‌دهد
- با ایمیل‌هایی که علامت + دارند بیشتر دیده می‌شود
- [ ] بازتولید خطا
- [x] ثبت لاگ"""

CHECKOUT_DESC = """## Goal
Cut the checkout from five screens to three without losing the order summary.

## Scope
- New payment step with saved cards
- Address autofill
- Apple Pay and Google Pay

## Done when
- [x] Funnel audit shared with the team
- [ ] Payment step designed and reviewed
- [ ] API client merged behind a flag
- [ ] Conversion measured for two weeks

> Owner: design. Engineering joins after the review.

See the [spec](https://example.com/specs/checkout) for the numbers."""

LOGIN_DESC = """Users land back on the sign-in page after a successful login when the
return URL contains a plus sign.

1. Open the app from an email link
2. Sign in
3. Observe the redirect loop

```
GET /sign-in?next=/projects/a+b  ->  302 /sign-in
```"""

WEB = (
    Spec(
        "Redesign checkout flow",
        "In progress",
        "high",
        "sd",
        -12,
        9,
        40,
        "13",
        ref="chk",
        desc=CHECKOUT_DESC,
        f={
            "Team": "Design",
            "Labels": "feature",
            "Spec link": "yes",
            "Budget": "12000.00 USD",
            "Review by": "+6",
            "Sponsor": "o",
        },
    ),
    Spec(
        "Audit current checkout funnel",
        "Done",
        "normal",
        "d",
        -12,
        -8,
        6,
        parent="chk",
        ref="chk-audit",
        f={"Team": "Backend", "Effort": "3"},
    ),
    Spec(
        "Design new payment step",
        "In review",
        "high",
        "s",
        -6,
        2,
        12,
        "5",
        parent="chk",
        ref="chk-pay",
        f={"Team": "Design", "Needs QA": "true"},
    ),
    Spec(
        "Wireframes for payment step",
        "Done",
        "normal",
        "s",
        -6,
        -3,
        parent="chk-pay",
        ref="chk-wire",
    ),
    Spec("Hi-fi mockups", "In progress", "normal", "s", -3, 1, 8, parent="chk-pay", ref="chk-hifi"),
    Spec("Dark mode variants", "Backlog", "low", "s", parent="chk-hifi", ref="chk-dark"),
    Spec(
        "Implement payment API client",
        "In progress",
        "high",
        "d",
        -4,
        5,
        16,
        "8",
        parent="chk",
        ref="chk-api",
        f={"Team": "Backend", "Effort": "8"},
    ),
    Spec(
        "Fix the login redirect",
        "In progress",
        "urgent",
        "d",
        -2,
        0,
        4,
        "3",
        ref="login",
        desc=LOGIN_DESC,
        f={"Team": "Backend", "Labels": "bug"},
    ),
    Spec(
        "Write the launch announcement",
        "In review",
        "high",
        "m",
        None,
        1,
        3,
        ref="launch",
        f={"Team": "Design", "Labels": "docs"},
    ),
    Spec("Review onboarding copy", "Backlog", "normal", "", None, 7),
    Spec("Tidy the backlog", "Backlog", "low"),
    Spec("Plan next sprint", "Backlog", "none", "a", None, None),
    Spec("Set up error monitoring", "Done", "normal", "d", -20, -14, 5, f={"Team": "Backend"}),
    Spec(
        "Migrate analytics to the new vendor",
        "In progress",
        "high",
        "dm",
        -9,
        -2,
        24,
        "8",
        ref="analytics",
        f={"Team": "Backend", "Customer": "Initech", "Budget": "4200.50 EUR"},
    ),
    Spec("Update privacy policy page", "Backlog", "normal", "g", None, 4, f={"Labels": "docs"}),
    Spec(
        "Accessibility audit of the homepage",
        "In review",
        "high",
        "s",
        -8,
        -1,
        10,
        f={"Team": "QA", "Needs QA": "true"},
    ),
    Spec(
        "Speed up image loading",
        "On hold",
        "normal",
        "d",
        ref="perf",
        est=12,
        f={"Team": "Frontend", "Effort": "5"},
    ),
    Spec("Cookie banner wording", "Done", "low", "m", None, -20, f={"Labels": "docs"}),
    Spec("Q4 roadmap review", "Backlog", "normal", "oa", None, 45),
    Spec(
        "رفع خطای ورود به صفحهٔ اصلی",
        "In progress",
        "high",
        "d",
        -1,
        3,
        6,
        ref="fa-bug",
        desc=PERSIAN_DESC,
        f={"Team": "Frontend", "Labels": "bug"},
    ),
    Spec("طراحی صفحهٔ تنظیمات", "Backlog", "normal", "s", None, 10, f={"Team": "Design"}),
    Spec("بررسی متن‌های راهنما", "Done", "low", "m", None, -5),
    Spec(
        "Investigate why exporting very large workspaces sometimes times out after exactly "
        "thirty seconds, but only in Safari with a throttled network and a user who has more "
        "than ten thousand tasks spread across forty projects and a dozen custom fields",
        "Backlog",
        "high",
        "d",
        ref="long",
        f={"Team": "Backend", "Labels": "bug"},
    ),
    Spec("Add a keyboard shortcuts cheat sheet", "Backlog", "low", "m"),
    Spec(
        "Customer escalation: Globex invoice mismatch",
        "In progress",
        "urgent",
        "ad",
        -3,
        0,
        5,
        f={"Customer": "Globex", "Labels": "customer", "Budget": "980.00 USD"},
    ),
    Spec("Publish changelog for v2.4", "Cancelled", "low", "m"),
    Spec("Refactor the settings screen", "Done", "normal", "d", -30, -22, 14),
    Spec("Upgrade Flutter to the next minor", "Backlog", "normal", "d", ref="flutter", est=8),
    Spec(
        "Support SSO for enterprise customers",
        "In progress",
        "high",
        "d",
        -6,
        20,
        60,
        "21",
        f={"Team": "Backend", "Labels": "feature", "Sponsor": "a"},
    ),
    Spec("Write API docs for webhooks", "Backlog", "normal", "m", None, 12, f={"Labels": "docs"}),
    Spec("Fix flaky checkout test", "Backlog", "high", "d", ref="flaky", f={"Team": "QA"}),
    Spec("Checkout test fails intermittently on CI", "Backlog", "normal", "", ref="flaky-dup"),
    Spec("Weekly design sync notes", "Backlog", "none", "s", ref="trash-web"),
)
MOBILE = (
    Spec("Ship iOS 2.4", "To do", "high", "m", -2, 6, 8, "5", ref="release"),
    Spec("Update the release notes", "Done", "normal", "m", -2, -1, parent="release"),
    Spec("Regression pass on iPhone SE", "In progress", "high", "d", -1, 3, 6, parent="release"),
    Spec("Submit to App Store review", "To do", "high", "m", None, 5, parent="release"),
    Spec(
        "Crash on launch for Android 13", "In progress", "urgent", "d", -3, -1, 10, "8", ref="crash"
    ),
    Spec("Push notification permission prompt", "To do", "normal", "s", ref="push", est=6),
    Spec("Dark mode for the settings screen", "Done", "normal", "s", -12, -7),
    Spec("Offline sync indicator", "In progress", "normal", "d", -5, 4, 12, "5"),
    Spec("App Store screenshots", "To do", "low", "s", None, 10),
    Spec("Deep link to a task", "Done", "normal", "d", -15, -9, 6),
    Spec("Biometric unlock", "To do", "high", "d", None, 18, 20, "8"),
    Spec("Reduce the app size", "To do", "low", "d", ref="trash-mob"),
    Spec("Localize into Arabic", "In progress", "normal", "sg", -4, 14, 16),
    Spec("Fix keyboard overlap on small phones", "Done", "high", "d", -9, -6),
    Spec("Home screen widgets", "To do", "none", "", None, 60),
    Spec("Tablet layout for the board", "To do", "normal", "s", None, 25),
    Spec("Crash reporting opt-in", "Done", "low", "d", -25, -20),
)
BUGS = (
    Spec("Login fails with a plus sign in the email", "Triaged", "high", "d", ref="bug-plus"),
    Spec(
        "Board drag drops the card in the wrong column",
        "In progress",
        "urgent",
        "d",
        -2,
        1,
        ref="bug-a",
        by="m",
    ),
    Spec("Card order is wrong after a drag", "Reported", "normal", "", ref="bug-b", by="g"),
    Spec("Timer keeps running after sign out", "In review", "high", "d", by="m"),
    Spec("Avatar upload rejects WebP", "Fixed", "normal", "m", by="m"),
    Spec("CSV export has the wrong date format", "Triaged", "normal", "m", by="g"),
    Spec("Calendar week starts on the wrong day in RTL", "Reported", "high", "s", by="g"),
    Spec("Search ignores Persian digits", "Reported", "normal", "g", by="s"),
    Spec("Tooltip overlaps the close button", "Fixed", "low", "s", by="m"),
    Spec("Emails land in spam on Outlook", "Won't fix", "low", "a", by="g"),
    Spec("Crash when deleting a project with sprints", "In progress", "urgent", "da", -3, -2),
    Spec("Slow list scroll with 5,000 tasks", "Triaged", "high", "d", by="a"),
    Spec("Wrong unread count after archive", "Reported", "low", "", ref="trash-bug"),
    Spec("Password reset link expires too fast", "Fixed", "normal", "a", by="g"),
)
MARKETING = (
    Spec("Spring campaign landing page", "Drafting", "high", "s", -5, 8, 20),
    Spec("Newsletter: October roundup", "Scheduled", "normal", "m", None, 2, 4),
    Spec("Blog: how we use TaskForge", "Idea", "low", "m"),
    Spec("Customer case study: Globex", "Review", "normal", "ma", -10, 5, 12),
    Spec("Webinar announcement", "Published", "normal", "m", -14, -9),
    Spec("Social media calendar Q1", "Drafting", "normal", "s", None, 15),
    Spec("Press kit refresh", "Idea", "none"),
    Spec("Partner co-marketing deck", "Review", "high", "a", None, 3, 6),
    Spec("Old banner ad set", "Dropped", "low", "s"),
)
PRIVATE = (
    Spec("Salary review preparation", "To do", "high", "a"),
    Spec("Board deck draft", "In progress", "high", "o", -4, 6, 10),
    Spec("Acquisition due-diligence list", "To do", "urgent", "oa", None, 2),
    Spec("Investor update email", "Done", "normal", "o", -12, -8),
)
ARCHIVED = (
    Spec("Migrate the old forum", "Done", "normal", "m", -80, -70),
    Spec("Retire the Flash widget", "Done", "low", "d", -75, -68),
    Spec("Redo the logo", "In progress", "normal", "s", -60),
)
BY_PROJECT = {
    "web": WEB,
    "mobile": MOBILE,
    "bugs": BUGS,
    "marketing": MARKETING,
    "private": PRIVATE,
    "archived": ARCHIVED,
}
# (project, task ref, kind from that task's side, other task ref)
LINKS = (
    ("web", "flutter", "blocked_by", "login"),
    ("web", "chk-api", "blocks", "launch"),
    ("web", "perf", "relates", "analytics"),
    ("web", "flaky-dup", "duplicates", "flaky"),
    ("web", "chk-hifi", "relates", "chk-wire"),
    ("mobile", "crash", "blocks", "release"),
    ("mobile", "push", "relates", "crash"),
    ("bugs", "bug-b", "duplicates", "bug-a"),
)
TRASHED = (("web", "trash-web"), ("mobile", "trash-mob"), ("bugs", "trash-bug"))
