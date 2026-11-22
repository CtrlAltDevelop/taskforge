"""Text the server writes for a person (notifications, emails), in that person's language.

A plain dict, no gettext: ``TEXT[key][locale]``. English is the source and is the
fallback for any missing language or key, so adding a sentence never breaks a send.
Stored or dedup identifiers (notification types, dedupe keys) never come from here.
"""

from typing import Any

from infrastructure.common.locales import DEFAULT_LOCALE, normalize_locale

TEXT: dict[str, dict[str, str]] = {
    "notify.someone": {
        "en": "Someone",
        "fa": "کسی",
        "ar": "شخص ما",
        "ps": "یو څوک",
    },
    "notify.more": {
        "en": " (+{n} more)",
        "fa": " (+{n} مورد دیگر)",
        "ar": " (+{n} أخرى)",
        "ps": " (+{n} نور)",
    },
    "notify.assigned.title": {
        "en": "{who} assigned you a task",
        "fa": "{who} یک کار را به شما سپرد",
        "ar": "{who} أسند إليك مهمة",
        "ps": "{who} تاسو ته یو کار وسپاره",
    },
    "notify.mentioned.title": {
        "en": "{who} mentioned you",
        "fa": "{who} شما را نام برد",
        "ar": "{who} أشار إليك",
        "ps": "{who} تاسو یاد کړل",
    },
    "notify.commented.title": {
        "en": "{who} commented{more}",
        "fa": "{who} نظر داد{more}",
        "ar": "{who} علّق{more}",
        "ps": "{who} نظر ورکړ{more}",
    },
    "notify.status_changed.title": {
        "en": "{who} moved a task{more}",
        "fa": "{who} وضعیت یک کار را تغییر داد{more}",
        "ar": "{who} نقل مهمة{more}",
        "ps": "{who} یو کار ولېږداوه{more}",
    },
    "notify.task_changed.title": {
        "en": "{who} changed a task{more}",
        "fa": "{who} یک کار را تغییر داد{more}",
        "ar": "{who} غيّر مهمة{more}",
        "ps": "{who} یو کار بدل کړ{more}",
    },
    "notify.status_changed.body": {
        "en": "{task}: {moved}",
        "fa": "{task}: {moved}",
        "ar": "{task}: {moved}",
        "ps": "{task}: {moved}",
    },
    "notify.due_soon.title": {
        "en": "A task is due soon",
        "fa": "مهلت یک کار نزدیک است",
        "ar": "اقترب موعد مهمة",
        "ps": "د یو کار موده نژدې ده",
    },
    "notify.due_soon.body": {
        "en": "{task} is due {date}",
        "fa": "{task} تا {date} مهلت دارد",
        "ar": "{task} موعده {date}",
        "ps": "{task} موده یې {date} ده",
    },
    "notify.timer_long.title": {
        "en": "Your timer is still running",
        "fa": "زمان‌سنج شما هنوز در حال اجراست",
        "ar": "المؤقت لا يزال يعمل",
        "ps": "ستاسو ټایمر لا هم روان دی",
    },
    "notify.timer_long.body": {
        "en": "{task}: {hours} h so far",
        "fa": "{task}: تاکنون {hours} ساعت",
        "ar": "{task}: {hours} ساعة حتى الآن",
        "ps": "{task}: تر اوسه {hours} ساعته",
    },
    "notify.automation.title": {
        "en": "Automation: {name}",
        "fa": "خودکارسازی: {name}",
        "ar": "الأتمتة: {name}",
        "ps": "اتومات: {name}",
    },
    "notify.automation_disabled.title": {
        "en": "Automation switched off: {name}",
        "fa": "خودکارسازی خاموش شد: {name}",
        "ar": "تم إيقاف الأتمتة: {name}",
        "ps": "اتومات بند شو: {name}",
    },
    "notify.webhook_disabled.title": {
        "en": "Webhook switched off: {name}",
        "fa": "وب‌هوک خاموش شد: {name}",
        "ar": "تم إيقاف الويب هوك: {name}",
        "ps": "ویب هوک بند شو: {name}",
    },
    "notify.goal_reached.title": {
        "en": "Goal reached: {name}",
        "fa": "هدف محقق شد: {name}",
        "ar": "تم تحقيق الهدف: {name}",
        "ps": "موخه ترسره شوه: {name}",
    },
    "notify.goal_at_risk.title": {
        "en": "Goal falling behind: {name}",
        "fa": "هدف عقب افتاده است: {name}",
        "ar": "الهدف يتأخر: {name}",
        "ps": "موخه شاته پاتې کیږي: {name}",
    },
    "notify.goal_at_risk.body": {
        "en": "Now at {percent} %",
        "fa": "اکنون {percent}٪",
        "ar": "الآن {percent}٪",
        "ps": "اوس {percent}٪",
    },
    "notify.chat_mentioned.title": {
        "en": "{who} mentioned you in {space}",
        "fa": "{who} شما را در {space} نام برد",
        "ar": "{who} أشار إليك في {space}",
        "ps": "{who} تاسو په {space} کې یاد کړل",
    },
    "notify.chat_dm.title": {
        "en": "{who} sent you a message",
        "fa": "{who} برای شما پیام فرستاد",
        "ar": "{who} أرسل إليك رسالة",
        "ps": "{who} تاسو ته پیغام واستاوه",
    },
    "notify.chat_channel_all.title": {
        "en": "{who} notified everyone in {space}",
        "fa": "{who} همه را در {space} مطلع کرد",
        "ar": "{who} نبّه الجميع في {space}",
        "ps": "{who} په {space} کې ټول خبر کړل",
    },
    "notify.chat_message.title": {
        "en": "{who} wrote in {space}",
        "fa": "{who} در {space} نوشت",
        "ar": "{who} كتب في {space}",
        "ps": "{who} په {space} کې ولیکل",
    },
    "notify.fallback.title": {
        "en": "Notification",
        "fa": "اعلان",
        "ar": "إشعار",
        "ps": "خبرتیا",
    },
    "notify.private.title": {
        "en": "New activity",
        "fa": "فعالیت تازه",
        "ar": "نشاط جديد",
        "ps": "نوې فعالیت",
    },
    "email.stop": {
        "en": "Stop these emails: {link}",
        "fa": "توقف این ایمیل‌ها: {link}",
        "ar": "إيقاف هذه الرسائل: {link}",
        "ps": "دا برېښنالیکونه بند کړئ: {link}",
    },
    "digest.subject": {
        "en": "Your daily TaskForge digest",
        "fa": "خلاصهٔ روزانهٔ TaskForge شما",
        "ar": "ملخّصك اليومي من TaskForge",
        "ps": "ستاسو ورځنی TaskForge لنډيز",
    },
    "digest.other": {
        "en": "Other",
        "fa": "سایر",
        "ar": "أخرى",
        "ps": "نور",
    },
    "digest.more": {
        "en": "…and {n} more in your inbox.",
        "fa": "…و {n} مورد دیگر در صندوق ورودی شما.",
        "ar": "…و{n} أخرى في صندوق الوارد.",
        "ps": "…او {n} نور ستاسو په صندوق کې.",
    },
    # Sign-in mail. The English text is the key: callers pass it as ``intro``.
    "auth.Your sign-in code": {
        "en": "Your sign-in code",
        "fa": "کد ورود شما",
        "ar": "رمز تسجيل الدخول الخاص بك",
        "ps": "ستاسو د ننوتلو کوډ",
    },
    "auth.Your sign-up code": {
        "en": "Your sign-up code",
        "fa": "کد ثبت‌نام شما",
        "ar": "رمز التسجيل الخاص بك",
        "ps": "ستاسو د نوم لیکنې کوډ",
    },
    "auth.Your sign-in link": {
        "en": "Your sign-in link",
        "fa": "پیوند ورود شما",
        "ar": "رابط تسجيل الدخول الخاص بك",
        "ps": "ستاسو د ننوتلو لینک",
    },
    "auth.Your sign-up link": {
        "en": "Your sign-up link",
        "fa": "پیوند ثبت‌نام شما",
        "ar": "رابط التسجيل الخاص بك",
        "ps": "ستاسو د نوم لیکنې لینک",
    },
    "auth.Your password reset code": {
        "en": "Your password reset code",
        "fa": "کد بازنشانی گذرواژهٔ شما",
        "ar": "رمز إعادة تعيين كلمة المرور",
        "ps": "ستاسو د پټنوم بیا تنظیم کوډ",
    },
    "auth.link_once": {
        "en": "This link can be used once.",
        "fa": "این پیوند فقط یک بار قابل استفاده است.",
        "ar": "يمكن استخدام هذا الرابط مرة واحدة فقط.",
        "ps": "دا لینک یوازې یو ځل کارول کیدای شي.",
    },
    "auth.verification_subject": {
        "en": "Your verification code",
        "fa": "کد تأیید شما",
        "ar": "رمز التحقق الخاص بك",
        "ps": "ستاسو د تایید کوډ",
    },
    "auth.verification_body": {
        "en": "Your verification code is {code}.",
        "fa": "کد تأیید شما {code} است.",
        "ar": "رمز التحقق الخاص بك هو {code}.",
        "ps": "ستاسو د تایید کوډ {code} دی.",
    },
    "invite.subject": {
        "en": "{inviter} invited you to {workspace}",
        "fa": "{inviter} شما را به {workspace} دعوت کرد",
        "ar": "{inviter} دعاك إلى {workspace}",
        "ps": "{inviter} تاسو {workspace} ته بلنه درکړه",
    },
    "invite.body": {
        "en": "{inviter} invited you to join {workspace} on TaskForge.",
        "fa": "{inviter} شما را به پیوستن به {workspace} در TaskForge دعوت کرد.",
        "ar": "{inviter} دعاك للانضمام إلى {workspace} على TaskForge.",
        "ps": "{inviter} تاسو په TaskForge کې {workspace} سره یوځای کیدو ته بلنه درکړه.",
    },
    "invite.join": {
        "en": "Join: {url}",
        "fa": "پیوستن: {url}",
        "ar": "للانضمام: {url}",
        "ps": "ګډون: {url}",
    },
    "forms.confirm.subject": {
        "en": "We received your request ({reference})",
        "fa": "درخواست شما دریافت شد ({reference})",
        "ar": "تم استلام طلبك ({reference})",
        "ps": "ستاسو غوښتنه ترلاسه شوه ({reference})",
    },
    "forms.confirm.body": {
        "en": 'Thank you. Your request "{title}" was sent through {form}.\nYour reference is {reference}; quote it if you write to us.',  # noqa: E501
        "fa": "سپاسگزاریم. درخواست «{title}» شما از طریق {form} ارسال شد.\nشمارهٔ پیگیری شما {reference} است؛ هنگام تماس آن را ذکر کنید.",  # noqa: E501
        "ar": 'شكرًا لك. تم إرسال طلبك "{title}" عبر {form}.\nرقمك المرجعي {reference}؛ اذكره عند مراسلتنا.',  # noqa: E501
        "ps": "مننه. ستاسو غوښتنه «{title}» د {form} له لارې ولېږل شوه.\nستاسو ریفرنس {reference} دی؛ کله چې موږ ته لیکئ یې یاد کړئ.",  # noqa: E501
    },
    "forms.status.subject": {
        "en": "Update on your request ({reference})",
        "fa": "به‌روزرسانی درخواست شما ({reference})",
        "ar": "تحديث بشأن طلبك ({reference})",
        "ps": "ستاسو د غوښتنې تازه حال ({reference})",
    },
    "forms.status.body": {
        "en": 'Your request "{title}" is now: {status}.\nReference: {reference}',
        "fa": "وضعیت درخواست «{title}» شما اکنون: {status}.\nشمارهٔ پیگیری: {reference}",
        "ar": 'أصبحت حالة طلبك "{title}": {status}.\nالمرجع: {reference}',
        "ps": "ستاسو د غوښتنې «{title}» حالت اوس دی: {status}.\nریفرنس: {reference}",
    },
}


def tr(key: str, locale: str | None = None, **values: Any) -> str:
    """``key`` in ``locale`` (English when the language or the key has no entry)."""
    entry = TEXT[key]
    template = entry.get(locale or DEFAULT_LOCALE) or entry[DEFAULT_LOCALE]
    return template.format(**values) if values else template


def tr_auth(english: str, locale: str | None) -> str:
    """A sign-in sentence passed around as its English text; unknown text stays as written."""
    key = f"auth.{english}"
    return tr(key, locale) if key in TEXT else english


def recipient_locale(user: Any, workspace: Any = None) -> str:
    """The person's own language, else their workspace's default, else English."""
    profile = getattr(user, "profile", None) if user is not None else None
    own = normalize_locale(getattr(profile, "locale", "") or "")
    if own:
        return own
    return normalize_locale(getattr(workspace, "default_locale", "") or "") or DEFAULT_LOCALE


def locale_for_email(email: str) -> str:
    """The language of the account that owns ``email`` (English when there is none)."""
    from django.contrib.auth import get_user_model

    user = (
        get_user_model()
        ._default_manager.filter(email__iexact=email)
        .select_related("profile")
        .first()
    )
    return recipient_locale(user)
