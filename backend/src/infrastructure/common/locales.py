"""The languages TaskForge speaks, and how a request picks one.

Stored values are the bare language (``fa``, never ``fa-AF``): the UI is
translated per language, not per region, so a region would only split one
person's preference across keys that all mean the same thing.

Clients translate by ``title``; the server only localizes the one sentence it
sends along (``description``), and only when that sentence is the generic one
for its title -- a specific message ("slug must be 3-40 characters") stays as
written, because translating it by title would throw its detail away.
"""

from typing import Any

SUPPORTED_LOCALES = ("en", "fa", "ar", "ps")
DEFAULT_LOCALE = "en"
RTL_LOCALES = frozenset({"fa", "ar", "ps"})

CALENDAR_SYSTEMS = ("gregorian", "jalali")
WEEK_STARTS = ("sat", "sun", "mon")
NUMERALS = ("latin", "native")


def normalize_locale(raw: str) -> str | None:
    """``en-US`` -> ``en``; an unsupported or empty value -> ``None``."""
    language = raw.replace("_", "-").split("-", 1)[0].strip().lower()
    return language if language in SUPPORTED_LOCALES else None


def is_rtl(locale: str) -> bool:
    return locale in RTL_LOCALES


def pick_from_accept_language(header: str) -> str:
    """The supported language the client likes best, or the default."""
    ranked: list[tuple[float, int, str]] = []
    for position, part in enumerate(header.split(",")):
        tag, *params = (piece.strip() for piece in part.split(";"))
        language = normalize_locale(tag)
        if language is None:
            continue
        quality = 1.0
        for param in params:
            if param.startswith("q="):
                try:
                    quality = float(param[2:])
                except ValueError:
                    quality = 0.0
        if quality > 0:
            ranked.append((-quality, position, language))
    return min(ranked)[2] if ranked else DEFAULT_LOCALE


def request_locale(request: Any) -> str:
    """A person's saved language, else the workspace default, else the browser's."""
    user = getattr(request, "user", None)
    if user is not None and getattr(user, "is_authenticated", False):
        saved = normalize_locale(getattr(getattr(user, "profile", None), "locale", "") or "")
        if saved:
            return saved
    workspace_default = normalize_locale(
        getattr(getattr(request, "workspace", None), "default_locale", "") or ""
    )
    if workspace_default:
        return workspace_default
    return pick_from_accept_language(request.META.get("HTTP_ACCEPT_LANGUAGE", ""))


# The generic sentence of the titles a person is most likely to meet. A missing
# entry is fine: the English sentence goes out instead.
MESSAGES: dict[str, dict[str, str]] = {
    "AUTHENTICATION_REQUIRED": {
        "fa": "برای این کار باید وارد شوید.",
        "ar": "يجب تسجيل الدخول لتنفيذ هذا الإجراء.",
        "ps": "د دې کار لپاره باید ننوځئ.",
    },
    "FORBIDDEN": {
        "fa": "این حساب اجازهٔ انجام این کار را ندارد.",
        "ar": "ليس لهذا الحساب صلاحية تنفيذ ذلك.",
        "ps": "دا حساب د دې کار اجازه نه لري.",
    },
    "NOT_FOUND": {
        "fa": "موردی برای این درخواست پیدا نشد.",
        "ar": "لم يتم العثور على العنصر المطلوب.",
        "ps": "د دې غوښتنې لپاره څه ونه موندل شول.",
    },
    "VALIDATION_ERROR": {
        "fa": "اطلاعات ارسال‌شده معتبر نیست.",
        "ar": "البيانات المرسلة غير صالحة.",
        "ps": "ورکړل شوې معلومات معتبر نه دي.",
    },
    "RATE_LIMITED": {
        "fa": "تلاش‌های بیش از حد. کمی صبر کنید و دوباره امتحان کنید.",
        "ar": "محاولات كثيرة جدًا. انتظر قليلًا ثم حاول مجددًا.",
        "ps": "ډیرې هڅې. لږ صبر وکړئ او بیا هڅه وکړئ.",
    },
    "VERSION_CONFLICT": {
        "fa": "شخص دیگری پیش از شما این را تغییر داده است؛ صفحه را بارگذاری مجدد کنید.",
        "ar": "قام شخص آخر بتغييره أولًا؛ أعد التحميل وحاول مجددًا.",
        "ps": "بل چا دا مخکې بدل کړی دی؛ بیا یې پورته کړئ او هڅه وکړئ.",
    },
    "INVALID_CREDENTIALS": {
        "fa": "شناسه یا گذرواژه نادرست است.",
        "ar": "المعرّف أو كلمة المرور غير صحيحة.",
        "ps": "پیژند یا پټنوم ناسم دی.",
    },
    "CONFLICT": {
        "fa": "این با مورد موجود تداخل دارد.",
        "ar": "هذا يتعارض مع عنصر موجود.",
        "ps": "دا له شته څه سره په ټکر کې دی.",
    },
    "SERVICE_UNAVAILABLE": {
        "fa": "سرویس موقتاً در دسترس نیست.",
        "ar": "الخدمة غير متاحة مؤقتًا.",
        "ps": "خدمت اوس شتون نه لري.",
    },
}


def localized_message(title: str, locale: str, fallback: str) -> str:
    """The sentence for ``title`` in ``locale``, or ``fallback`` when there is none."""
    return MESSAGES.get(title, {}).get(locale, fallback)
