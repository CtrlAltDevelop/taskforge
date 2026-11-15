// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تاسك فورج';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get close => 'إغلاق';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get inbox => 'صندوق الوارد';

  @override
  String get workspaceSettings => 'إعدادات مساحة العمل';

  @override
  String get homeLoadWorkspacesFailed =>
      'تعذّر تحميل مساحات العمل. أعد المحاولة';

  @override
  String get homeLoadAccountFailed => 'تعذّر تحميل حسابك.';

  @override
  String get calendar => 'التقويم';

  @override
  String get calendarSubtitle => 'كل المواعيد النهائية عبر مشاريعك';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get notificationSettingsSubtitle =>
      'ما الذي ينبّهك، وساعات الهدوء والملخص';

  @override
  String get offlineAndStorage => 'دون اتصال والتخزين';

  @override
  String get offlineAndStorageSubtitle => 'التغييرات دون اتصال والنسخة المحلية';

  @override
  String get sessions => 'الجلسات';

  @override
  String get sessionsSubtitle => 'الأجهزة المسجّلة الدخول إلى حسابك';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get connectivity => 'الاتصال';

  @override
  String get languageAndRegion => 'اللغة والمنطقة';

  @override
  String get languageAndRegionSubtitle =>
      'اللغة والتقويم وبداية الأسبوع والأرقام';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get createAnAccount => 'إنشاء حساب جديد';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get backToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get setNewPassword => 'تعيين كلمة مرور جديدة';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get codeFromEmail => 'الرمز الوارد في بريدك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور. سجّل الدخول مجددًا.';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور. سجّل الدخول بها.';

  @override
  String get enterEmail => 'أدخل عنوان بريدك الإلكتروني.';

  @override
  String get enterValidEmail => 'أدخل عنوان بريد إلكتروني صالحًا.';

  @override
  String get enterPassword => 'أدخل كلمة مرور.';

  @override
  String passwordTooShort(int min) {
    return 'استخدم $min أحرف على الأقل.';
  }

  @override
  String get enterResetCode => 'أدخل الرمز الوارد في بريدك.';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور.';

  @override
  String get errWrongCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errTooManyAttempts =>
      'محاولات كثيرة جدًا. حاول مجددًا بعد بضع دقائق.';

  @override
  String get errAccountExists => 'يوجد حساب بهذا البريد الإلكتروني بالفعل.';

  @override
  String get errServerProblem => 'حدثت مشكلة في الخادم. حاول مجددًا بعد قليل.';

  @override
  String get errNoConnection =>
      'تعذّر الوصول إلى الخادم. تحقّق من اتصالك وحاول مجددًا.';

  @override
  String get errGeneric => 'حدث خطأ ما. حاول مجددًا.';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get calendarSystemLabel => 'التقويم';

  @override
  String get calendarGregorian => 'ميلادي';

  @override
  String get calendarJalali => 'جلالي (هجري شمسي)';

  @override
  String get weekStartLabel => 'يبدأ الأسبوع يوم';

  @override
  String get weekStartDefault => 'الافتراضي للغة';

  @override
  String get weekSaturday => 'السبت';

  @override
  String get weekSunday => 'الأحد';

  @override
  String get weekMonday => 'الاثنين';

  @override
  String get numeralsLabel => 'الأرقام';

  @override
  String get numeralsLatin => 'غربية (0123)';

  @override
  String get numeralsNative => 'عربية (٠١٢٣)';

  @override
  String get previewLabel => 'معاينة';

  @override
  String get prefsSaveFailed =>
      'تم الحفظ على هذا الجهاز فقط. تعذّر الوصول إلى الخادم.';

  @override
  String get workspaceDefaultLanguage => 'اللغة الافتراضية للأعضاء الجدد';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا مهام',
    );
    return '$_temp0';
  }

  @override
  String get jalaliMonth1 => 'فروردين';

  @override
  String get jalaliMonth2 => 'أرديبهشت';

  @override
  String get jalaliMonth3 => 'خرداد';

  @override
  String get jalaliMonth4 => 'تير';

  @override
  String get jalaliMonth5 => 'مرداد';

  @override
  String get jalaliMonth6 => 'شهريور';

  @override
  String get jalaliMonth7 => 'مهر';

  @override
  String get jalaliMonth8 => 'آبان';

  @override
  String get jalaliMonth9 => 'آذر';

  @override
  String get jalaliMonth10 => 'دي';

  @override
  String get jalaliMonth11 => 'بهمن';

  @override
  String get jalaliMonth12 => 'إسفند';

  @override
  String get pickDateOk => 'موافق';

  @override
  String get pickDateTitle => 'اختر التاريخ';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String get weekdayShortMon => 'الاثنين';

  @override
  String get weekdayShortTue => 'الثلاثاء';

  @override
  String get weekdayShortWed => 'الأربعاء';

  @override
  String get weekdayShortThu => 'الخميس';

  @override
  String get weekdayShortFri => 'الجمعة';

  @override
  String get weekdayShortSat => 'السبت';

  @override
  String get weekdayShortSun => 'الأحد';

  @override
  String get grpACancel => 'إلغاء';

  @override
  String get grpASave => 'حفظ';

  @override
  String get grpARetry => 'إعادة المحاولة';

  @override
  String get grpADone => 'تم';

  @override
  String get grpAClose => 'إغلاق';

  @override
  String get grpAEdit => 'تعديل';

  @override
  String get grpADelete => 'حذف';

  @override
  String get grpANote => 'ملاحظة';

  @override
  String get grpATotal => 'الإجمالي';

  @override
  String get grpATask => 'المهمة';

  @override
  String get grpAMerge => 'دمج';

  @override
  String get grpARemove => 'إزالة';

  @override
  String get grpAOfflineBack => 'رجوع';

  @override
  String get grpAOfflineTitle => 'العمل دون اتصال والتخزين';

  @override
  String get grpAOfflineChooseWorkspace => 'اختر مساحة عمل أولاً.';

  @override
  String get grpAOfflineNeedsAttention => 'يحتاج إلى انتباهك';

  @override
  String get grpAOfflineNothingToDecide =>
      'لا شيء. أُرسلت كل التغييرات التي أُجريت دون اتصال.';

  @override
  String grpAOfflineWaiting(int count) {
    return 'بانتظار الإرسال ($count)';
  }

  @override
  String get grpASyncNow => 'زامن الآن';

  @override
  String get grpAOfflineNothingWaiting => 'لا شيء في الانتظار.';

  @override
  String get grpAEntryATask => 'مهمة';

  @override
  String grpAEntryNewTask(String title) {
    return 'مهمة جديدة «$title»';
  }

  @override
  String grpAEntryEdit(String name, String fields) {
    return 'تعديل $name: $fields';
  }

  @override
  String grpAEntryDelete(String name) {
    return 'حذف $name';
  }

  @override
  String grpAEntryComment(String name) {
    return 'تعليق على $name';
  }

  @override
  String grpAEntryUpload(String file, String name) {
    return 'رفع «$file» إلى $name';
  }

  @override
  String grpAOfflineClash(String field, String current, String mine) {
    return 'نسختهم ($field): $current\nنسختك: $mine';
  }

  @override
  String get grpAKeepMine => 'الإبقاء على تغييراتي';

  @override
  String get grpATakeTheirs => 'أخذ تغييراتهم';

  @override
  String get grpATryAgain => 'حاول مجددًا';

  @override
  String get grpADiscard => 'تجاهل';

  @override
  String get grpAMergeTitle => 'أي تغييراتك تريد الإبقاء عليها؟';

  @override
  String get grpAStorage => 'التخزين';

  @override
  String get grpAReading => 'جارٍ القراءة…';

  @override
  String grpAStorageUsage(String size, int cap) {
    return 'تشغل النسخة على هذا الجهاز $size ميغابايت من أصل $cap ميغابايت كحد أقصى.';
  }

  @override
  String get grpAMostItMayHold => 'الحد الأقصى المسموح';

  @override
  String grpAMegabytes(int mb) {
    return '$mb ميغابايت';
  }

  @override
  String get grpAClearCopy => 'مسح النسخة على هذا الجهاز';

  @override
  String get grpAStorageNote =>
      'التغييرات التي لا تزال بانتظار الإرسال تبقى محفوظة. تُخزَّن النسخة دون تشفير: استخدم تشفير قرص جهازك.';

  @override
  String get grpAClearTitle => 'هل تريد مسح النسخة على هذا الجهاز؟';

  @override
  String get grpAClearBody =>
      'ما قرأته يُجلب مجددًا عند اتصالك بالإنترنت. التغييرات التي بانتظار الإرسال لا تُحذف.';

  @override
  String get grpAClear => 'مسح';

  @override
  String get grpAKeepOfflineTitle => 'إبقاء المشاريع متاحة دون اتصال';

  @override
  String get grpAKeepOfflineBody =>
      'يُنسخ المشروع المحفوظ بالكامل، فتتوفر مهامه وحالاته وأعضاؤه دون اتصال. أما المشاريع الأخرى فتعرض آخر ما قرأته.';

  @override
  String grpACopying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جارٍ النسخ… $count مهمة',
      many: 'جارٍ النسخ… $count مهمة',
      few: 'جارٍ النسخ… $count مهام',
      two: 'جارٍ النسخ… مهمتان',
      one: 'جارٍ النسخ… مهمة واحدة',
      zero: 'جارٍ النسخ… $count مهمة',
    );
    return '$_temp0';
  }

  @override
  String get grpASprintsTitle => 'السبرنتات';

  @override
  String grpASprintsTitleProject(String name) {
    return 'السبرنتات · $name';
  }

  @override
  String get grpASprintsDisabled =>
      'السبرنتات متوقفة في هذا المشروع. فعّلها من إعدادات المشروع.';

  @override
  String get grpAProjectNotFound => 'لم يتم العثور على المشروع.';

  @override
  String grpAAddedAfterStart(int count) {
    return 'أُضيف $count بعد بدء السبرنت (يظهر كتغيير في النطاق).';
  }

  @override
  String grpASprintCompleted(String name) {
    return 'اكتمل $name.';
  }

  @override
  String get grpAPlanning => 'التخطيط';

  @override
  String get grpAReports => 'التقارير';

  @override
  String get grpANewSprint => 'سبرنت جديد';

  @override
  String get grpABacklog => 'قائمة الانتظار';

  @override
  String get grpABacklogEmpty => 'قائمة الانتظار فارغة.';

  @override
  String get grpAAddToSprint => 'إضافة إلى السبرنت';

  @override
  String get grpANoOpenSprint =>
      'لا يوجد سبرنت مفتوح. أنشئ واحدًا لبدء التخطيط.';

  @override
  String get grpADragHere =>
      'اسحب المهام إلى هنا، أو حدد بعضها في قائمة الانتظار.';

  @override
  String grpADatesRange(String start, String end) {
    return '$start إلى $end';
  }

  @override
  String grpADaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متبقٍ',
      many: '$count يومًا متبقيًا',
      few: '$count أيام متبقية',
      two: 'يومان متبقيان',
      one: 'يوم واحد متبقٍ',
      zero: 'لا أيام متبقية',
    );
    return '$_temp0';
  }

  @override
  String grpASprintGoalText(String goal) {
    return 'الهدف: $goal';
  }

  @override
  String get grpAShowOnBoard => 'عرض على اللوحة';

  @override
  String get grpAEditSprint => 'تعديل السبرنت';

  @override
  String get grpAStartSprint => 'بدء السبرنت';

  @override
  String get grpACompleteSprint => 'إكمال السبرنت';

  @override
  String get grpANoSprintsYet => 'لا توجد سبرنتات بعد.';

  @override
  String get grpASprintNameRequired => 'أعطِ السبرنت اسمًا.';

  @override
  String get grpASprintDatesFormat => 'تُكتب التواريخ بصيغة YYYY-MM-DD.';

  @override
  String get grpASprintEndBeforeStart =>
      'لا يمكن أن ينتهي السبرنت قبل أن يبدأ.';

  @override
  String get grpASprintCapacityNumber =>
      'السعة رقم، أو اتركها فارغة لعدم التحديد.';

  @override
  String get grpASprintSaved => 'تم حفظ السبرنت';

  @override
  String get grpASprintName => 'الاسم';

  @override
  String get grpASprintGoal => 'الهدف';

  @override
  String get grpASprintStartLabel => 'البداية (YYYY-MM-DD)';

  @override
  String get grpASprintEndLabel => 'النهاية (YYYY-MM-DD)';

  @override
  String get grpAPickStartDate => 'اختر تاريخ البداية';

  @override
  String get grpAPickEndDate => 'اختر تاريخ النهاية';

  @override
  String get grpACapacityPointsOptional => 'السعة بالنقاط (اختياري)';

  @override
  String get grpACapacityHoursOptional => 'السعة بالساعات (اختياري)';

  @override
  String grpASprintOverlap(String names) {
    return 'تتداخل هذه التواريخ مع $names.';
  }

  @override
  String grpACompleteTitle(String name) {
    return 'إكمال $name';
  }

  @override
  String grpACompleteCounts(int done, int open) {
    return '$done منجزة، $open غير مكتملة';
  }

  @override
  String get grpACompleteWhatHappens => 'ماذا يحدث للمهام غير المكتملة؟';

  @override
  String get grpACompleteMoveNext => 'النقل إلى السبرنت التالي';

  @override
  String get grpACompleteNoPlanned => 'لا يوجد سبرنت مخطط لنقلها إليه';

  @override
  String get grpACompleteBackToBacklog => 'العودة إلى قائمة الانتظار';

  @override
  String grpAPointsFor(String key) {
    return 'نقاط $key';
  }

  @override
  String get grpAPointsInvalid => 'استخدم رقمًا، أو اتركه فارغًا للمسح.';

  @override
  String get grpAStoryPoints => 'نقاط القصة';

  @override
  String get grpACapacityInHours => 'السعة بالساعات';

  @override
  String get grpACapacityInPoints => 'السعة بالنقاط';

  @override
  String grpABurndownTitle(String name) {
    return 'مخطط الإنجاز: $name';
  }

  @override
  String get grpAPoints => 'النقاط';

  @override
  String get grpATasks => 'المهام';

  @override
  String get grpABurndownEmpty => 'يبدأ مخطط الإنجاز بمجرد بدء السبرنت.';

  @override
  String grpABurndownChart(int days, int changes) {
    return 'مخطط الإنجاز، $days أيام، $changes تغييرات في النطاق';
  }

  @override
  String grpABurndownBackfilled(int count) {
    return '، $count أيام مملوءة لاحقًا';
  }

  @override
  String get grpALegendRemaining => 'المتبقي';

  @override
  String get grpALegendIdeal => 'المثالي';

  @override
  String get grpALegendScopeChange => 'تغيير النطاق';

  @override
  String get grpALegendBackfilled => 'يوم مملوء لاحقًا';

  @override
  String get grpAVelocityEmpty => 'تظهر السرعة بعد أول سبرنت مكتمل.';

  @override
  String grpAVelocityTitle(int count, String average) {
    return 'السرعة (آخر $count سبرنتات): المتوسط $average نقطة';
  }

  @override
  String grpAVelocityChart(int count) {
    return 'مخطط السرعة، $count سبرنتات';
  }

  @override
  String get grpALegendCommitted => 'الملتزم به';

  @override
  String get grpALegendCompleted => 'المكتمل';

  @override
  String get grpATimesheetTitle => 'سجل الوقت';

  @override
  String get grpAPreviousWeek => 'الأسبوع السابق';

  @override
  String get grpANextWeek => 'الأسبوع التالي';

  @override
  String get grpAThisWeek => 'هذا الأسبوع';

  @override
  String get grpATimesheetEmpty => 'لم يُسجَّل أي وقت هذا الأسبوع.';

  @override
  String get grpARunning => 'قيد التشغيل';

  @override
  String get grpAAddTime => 'إضافة وقت';

  @override
  String get grpAYou => 'أنت';

  @override
  String get grpAProjectTotals => 'إجمالي المشروع';

  @override
  String get grpAChooseProject => 'اختر مشروعًا';

  @override
  String get grpATotalsEmpty => 'لم يُسجَّل أي وقت في هذا المشروع هذا الأسبوع.';

  @override
  String grpABillableAmount(String duration) {
    return '  ($duration قابل للفوترة)';
  }

  @override
  String get grpAEditTime => 'تعديل الوقت';

  @override
  String get grpATimeSpent => 'الوقت المستغرق';

  @override
  String get grpABillable => 'قابل للفوترة';

  @override
  String get grpABadDuration => 'أدخل وقتًا مثل 1h 30m أو 90m أو 1:30.';

  @override
  String get grpAEstimate => 'التقدير';

  @override
  String get grpAEstimatedTime => 'الوقت المقدَّر';

  @override
  String get grpAEmptyForNone => 'اتركه فارغًا لعدم التحديد';

  @override
  String get grpADeleteTimeTitle => 'هل تريد حذف هذا الوقت؟';

  @override
  String get grpADeleteTimeBody => 'سيُزال الوقت المسجَّل نهائيًا.';

  @override
  String get grpAKeep => 'الإبقاء';

  @override
  String get grpBCancel => 'إلغاء';

  @override
  String get grpBOk => 'موافق';

  @override
  String get grpBClose => 'إغلاق';

  @override
  String get grpBSave => 'حفظ';

  @override
  String get grpBRetry => 'إعادة المحاولة';

  @override
  String get grpBRestore => 'استعادة';

  @override
  String get grpBHistory => 'السجل';

  @override
  String get grpBCopy => 'نسخ';

  @override
  String get grpBSaveAsFile => 'حفظ كملف';

  @override
  String get grpBReply => 'رد';

  @override
  String get grpBEdit => 'تعديل';

  @override
  String get grpBDelete => 'حذف';

  @override
  String get grpBBack => 'رجوع';

  @override
  String get grpBSomeone => 'شخص ما';

  @override
  String get grpBYou => 'أنت';

  @override
  String get grpBLoading => 'جارٍ التحميل…';

  @override
  String get grpBPages => 'الصفحات';

  @override
  String get grpBRestricted => 'مقيّد';

  @override
  String get grpBLinkTitle => 'رابط';

  @override
  String get grpBLinkAddressLabel => 'العنوان (http أو https أو mailto)';

  @override
  String get grpBLinkInvalid => 'استخدم عنوان http أو https أو mailto.';

  @override
  String get grpBIconTitle => 'أيقونة الصفحة';

  @override
  String get grpBIconLabel =>
      'رمز تعبيري أو نص قصير (اتركه فارغًا لعدم الاختيار)';

  @override
  String get grpBIconInvalid => 'استخدم أربعة أحرف على الأكثر.';

  @override
  String get grpBImageTitle => 'صورة';

  @override
  String get grpBImageAddressLabel => 'عنوان الصورة (http أو https)';

  @override
  String get grpBDescription => 'الوصف';

  @override
  String get grpBImageInvalid => 'استخدم عنوان http أو https.';

  @override
  String get grpBEmbedTaskTitle => 'تضمين مهمة';

  @override
  String get grpBTaskSearchLabel => 'ابحث عن المهام أو الصق رابط مهمة';

  @override
  String get grpBUsePastedTask => 'استخدام المهمة الملصقة';

  @override
  String get grpBSnippetRemoved => '(محذوف)';

  @override
  String get grpBConflictTitle => 'قام شخص آخر بتغيير هذه الصفحة';

  @override
  String get grpBConflictClean =>
      'لا تتداخل تغييراتهم مع تغييراتك. سيتم دمجها.';

  @override
  String get grpBConflictOverlap =>
      'لقد غيّرتما هذه الكتل معًا. اختر ما تريد الاحتفاظ به؛ وسيتم دمج كل ما عداه.';

  @override
  String grpBConflictBlock(String snippet) {
    return 'الكتلة: $snippet';
  }

  @override
  String grpBConflictMine(String snippet) {
    return 'نسختي: $snippet';
  }

  @override
  String grpBConflictTheirs(String snippet) {
    return 'نسختهم: $snippet';
  }

  @override
  String get grpBDecideLater => 'القرار لاحقًا';

  @override
  String get grpBDiscardMine => 'تجاهل نسختي';

  @override
  String get grpBApplyAndSave => 'تطبيق وحفظ';

  @override
  String get grpBShareTitle => 'الوصول إلى الصفحة';

  @override
  String get grpBShareRestrict => 'تقييد هذه الصفحة';

  @override
  String get grpBShareRestrictedHint =>
      'فقط الأشخاص أدناه ومنشئها ومديرو الصفحة (وكذلك للصفحات التابعة لها).';

  @override
  String get grpBShareOpenHint => 'يمكن لكل من يستطيع فتح الصفحة الأم فتحها.';

  @override
  String get grpBShareNeedPermission =>
      'تحتاج إلى الصلاحية \"doc.manage\" لتغيير هذا.';

  @override
  String get grpBEmptyPage => '(صفحة فارغة)';

  @override
  String grpBImageBlock(String alt) {
    return '[صورة $alt]';
  }

  @override
  String get grpBTaskCardBlock => '[بطاقة مهمة]';

  @override
  String get grpBAllRevisions => 'كل المراجعات';

  @override
  String get grpBNoRevisions => 'لا توجد مراجعات بعد.';

  @override
  String grpBVersionN(int version) {
    return 'الإصدار $version';
  }

  @override
  String grpBVersionShort(int version) {
    return 'إصدار $version';
  }

  @override
  String get grpBRevisionsLoadFailed => 'تعذر تحميل السجل. أعد المحاولة';

  @override
  String get grpBRevisionLoadFailed => 'تعذر تحميل هذه المراجعة.';

  @override
  String get grpBRestoreVersion => 'استعادة هذا الإصدار';

  @override
  String grpBLinkedFrom(int count) {
    return 'مرتبطة من ($count)';
  }

  @override
  String get grpBNoBacklinks => 'لا توجد صفحة تشير إلى هذه الصفحة.';

  @override
  String grpBMarkdownTitle(String title) {
    return 'Markdown: $title';
  }

  @override
  String get grpBMarkdownCopied => 'تم نسخ Markdown.';

  @override
  String get grpBSaveSaved => 'تم الحفظ';

  @override
  String get grpBSaveDirty => 'تغييرات غير محفوظة';

  @override
  String get grpBSaveSaving => 'جارٍ الحفظ...';

  @override
  String get grpBSaveError => 'تعذر الحفظ';

  @override
  String get grpBSaveConflict => 'تعارض: اختر ما تريد الاحتفاظ به';

  @override
  String get grpBDocsCrumb => 'المستندات';

  @override
  String get grpBDocNotFound => 'هذه الصفحة غير موجودة أو لا يمكنك فتحها.';

  @override
  String get grpBBackToAllPages => 'العودة إلى كل الصفحات';

  @override
  String get grpBArchivedBanner => 'هذه الصفحة مؤرشفة. وهي للقراءة فقط.';

  @override
  String get grpBConflictBanner =>
      'قام شخص آخر بتغيير هذه الصفحة. لم يتم حفظ تغييراتك بعد.';

  @override
  String get grpBResolve => 'حل';

  @override
  String get grpBRemoteBanner =>
      'حفظ شخص آخر إصدارًا أحدث. سيتم دمجه عند الحفظ.';

  @override
  String grpBIsEditing(String name) {
    return '$name يقوم بالتعديل';
  }

  @override
  String grpBAreEditing(String names) {
    return '$names يقومون بالتعديل';
  }

  @override
  String get grpBChangeIcon => 'تغيير الأيقونة';

  @override
  String get grpBUntitled => 'بدون عنوان';

  @override
  String get grpBReadOnly => 'للقراءة فقط';

  @override
  String get grpBAccess => 'الوصول';

  @override
  String get grpBExportMarkdown => 'تصدير Markdown';

  @override
  String grpBMoveUnder(String name) {
    return 'نقل \"$name\" إلى تحت';
  }

  @override
  String get grpBTopLevel => 'المستوى الأعلى';

  @override
  String get grpBCollapse => 'طيّ';

  @override
  String get grpBExpand => 'توسيع';

  @override
  String get grpBPageOptions => 'خيارات الصفحة';

  @override
  String get grpBNewSubpage => 'صفحة فرعية جديدة';

  @override
  String get grpBMoveUp => 'نقل لأعلى';

  @override
  String get grpBMoveDown => 'نقل لأسفل';

  @override
  String get grpBMoveTo => 'نقل إلى...';

  @override
  String get grpBArchive => 'أرشفة';

  @override
  String get grpBHideArchived => 'إخفاء المؤرشف';

  @override
  String get grpBShowArchived => 'إظهار المؤرشف';

  @override
  String get grpBNewPage => 'صفحة جديدة';

  @override
  String get grpBNoPagesYet => 'لا توجد صفحات بعد.';

  @override
  String get grpBPagesLoadFailed => 'تعذر تحميل الصفحات. أعد المحاولة';

  @override
  String get grpBToday => 'اليوم';

  @override
  String get grpBYesterday => 'أمس';

  @override
  String get grpBSubtaskCreated => 'تم إنشاء المهمة الفرعية.';

  @override
  String get grpBComments => 'التعليقات';

  @override
  String grpBCommentsCount(int count) {
    return 'التعليقات ($count)';
  }

  @override
  String get grpBNoComments => 'لا توجد تعليقات بعد.';

  @override
  String get grpBLoadEarlier => 'تحميل تعليقات أقدم';

  @override
  String get grpBPinned => 'مثبّت';

  @override
  String get grpBReplyHint => 'رد…';

  @override
  String get grpBArchivedReadOnly =>
      'هذا المشروع مؤرشف: التعليقات للقراءة فقط.';

  @override
  String get grpBReadOnlyComments =>
      'يمكنك قراءة التعليقات ولكن لا يمكنك كتابتها.';

  @override
  String get grpBCommentRemoved => 'تمت إزالة التعليق';

  @override
  String get grpBUnpin => 'إلغاء التثبيت';

  @override
  String get grpBPin => 'تثبيت';

  @override
  String get grpBMakeSubtask => 'تحويل إلى مهمة فرعية';

  @override
  String get grpBEditHistory => 'سجل التعديلات';

  @override
  String grpBEditedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم التعديل $count مرة: انقر لعرض السجل',
      many: 'تم التعديل $count مرة: انقر لعرض السجل',
      few: 'تم التعديل $count مرات: انقر لعرض السجل',
      two: 'تم التعديل مرتين: انقر لعرض السجل',
      one: 'تم التعديل مرة واحدة: انقر لعرض السجل',
      zero: 'لم يتم التعديل: انقر لعرض السجل',
    );
    return '$_temp0';
  }

  @override
  String get grpBEdited => 'معدّل';

  @override
  String get grpBCommentActions => 'إجراءات التعليق';

  @override
  String get grpBWaitingToSend => 'بانتظار الإرسال';

  @override
  String get grpBSending => 'جارٍ الإرسال…';

  @override
  String get grpBNotSent => 'لم يُرسل';

  @override
  String get grpBDiscard => 'تجاهل';

  @override
  String get grpBAddReaction => 'إضافة تفاعل';

  @override
  String get grpBAuditAll => 'الكل';

  @override
  String get grpBAuditTasks => 'المهام';

  @override
  String get grpBAuditFiles => 'الملفات';

  @override
  String get grpBAuditProjects => 'المشاريع';

  @override
  String get grpBAuditMembers => 'الأعضاء';

  @override
  String get grpBAuditRoles => 'الأدوار';

  @override
  String get grpBAuditInvitations => 'الدعوات';

  @override
  String get grpBAuditSignIn => 'تسجيل الدخول';

  @override
  String get grpBAuditTitle => 'سجل التدقيق';

  @override
  String get grpBExportCsv => 'تصدير بصيغة CSV';

  @override
  String get grpBAuditDenied => 'غير مسموح لك بقراءة سجل التدقيق.';

  @override
  String get grpBAuditEmpty => 'لا يوجد شيء مسجّل لهذه المرشحات.';

  @override
  String get grpBShowOlder => 'عرض الأقدم';

  @override
  String get grpBAnyone => 'أي شخص';

  @override
  String get grpBAnyProject => 'أي مشروع';

  @override
  String get grpBAnyTime => 'أي وقت';

  @override
  String get grpBClearFilters => 'مسح المرشحات';

  @override
  String get grpBBulkChange => 'جزء من تغيير جماعي';

  @override
  String grpBCharacters(String size) {
    return '($size حرفًا)';
  }

  @override
  String get grpBNoFieldChanges => 'لم يتم تسجيل أي تغييرات في الحقول.';

  @override
  String get grpBAuditExportTitle => 'سجل التدقيق (CSV)';

  @override
  String grpBAuditExportNote(int shown, int total) {
    return 'عرض أول $shown من $total سطرًا. النسخ أو الحفظ يشمل كلها.';
  }

  @override
  String get grpBCsvCopied => 'تم نسخ CSV.';

  @override
  String get grpCCancel => 'إلغاء';

  @override
  String get grpCDelete => 'حذف';

  @override
  String get grpCRetry => 'إعادة المحاولة';

  @override
  String get grpCBack => 'رجوع';

  @override
  String get grpCUndo => 'تراجع';

  @override
  String get grpCField => 'حقل';

  @override
  String get grpCStatus => 'الحالة';

  @override
  String get grpCComment => 'تعليق';

  @override
  String get grpCValue => 'القيمة';

  @override
  String get grpCDashNew => 'لوحة معلومات جديدة';

  @override
  String grpCDashDeleteTitle(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get grpCDashDeleteBody =>
      'ستُحذف عناصرها معها. لا يمكن التراجع عن ذلك.';

  @override
  String get grpCDashTitle => 'لوحات المعلومات';

  @override
  String grpCDashTitleProject(String project) {
    return 'لوحات المعلومات · $project';
  }

  @override
  String get grpCDashEmpty => 'لا توجد لوحات معلومات بعد.';

  @override
  String get grpCDashBlankDashboard => 'لوحة معلومات فارغة';

  @override
  String get grpCDashProjectOverview => 'نظرة عامة على المشروع';

  @override
  String get grpCDashMyWork => 'أعمالي';

  @override
  String get grpCDashBlank => 'فارغة';

  @override
  String get grpCDashEdit => 'تعديل';

  @override
  String get grpCDashRefresh => 'تحديث';

  @override
  String get grpCDashAddWidget => 'إضافة عنصر';

  @override
  String get grpCDashSave => 'حفظ';

  @override
  String get grpCDashDialogTitle => 'لوحة المعلومات';

  @override
  String get grpCDashName => 'الاسم';

  @override
  String get grpCDashShareDenied => 'تتطلب المشاركة صلاحية dashboard.manage.';

  @override
  String get grpCDashOk => 'موافق';

  @override
  String get grpCImpTitle => 'الاستيراد والتصدير';

  @override
  String get grpCImpExport => 'تصدير';

  @override
  String get grpCImpDenied => 'يمكن للمشرفين فقط استيراد البيانات وتصديرها.';

  @override
  String get grpCImpPast => 'عمليات الاستيراد السابقة';

  @override
  String get grpCImpNothing => 'لم يتم استيراد أي شيء بعد.';

  @override
  String grpCImpTasksCount(int count) {
    return '$count مهام';
  }

  @override
  String get grpCImpResume => 'استئناف';

  @override
  String get grpCImpContinue => 'متابعة';

  @override
  String get grpCImpForget => 'نسيان';

  @override
  String get grpCImpUndoTitle => 'هل تريد التراجع عن هذا الاستيراد؟';

  @override
  String get grpCImpUndoBody =>
      'سيؤدي هذا إلى إزالة ما أنشأه. وسيتم الاحتفاظ بكل ما أضفته يدويًا.';

  @override
  String get grpCImpUndoConfirm => 'التراجع عن الاستيراد';

  @override
  String grpCImpClaimTitle(String name) {
    return 'إعطاء مهام $name إلى...';
  }

  @override
  String get grpCImpChooseMember => 'اختر عضوًا';

  @override
  String get grpCImpAssign => 'تعيين';

  @override
  String grpCImpAssigned(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'تم تعيين $n مهمة.',
      many: 'تم تعيين $n مهمة.',
      few: 'تم تعيين $n مهام.',
      two: 'تم تعيين مهمتين.',
      one: 'تم تعيين مهمة واحدة.',
      zero: 'لم يتم تعيين أي مهمة.',
    );
    return '$_temp0';
  }

  @override
  String get grpCImpWaiting => 'أشخاص في انتظار الانضمام';

  @override
  String get grpCImpWaitingBody =>
      'تُعيَّن مهامهم تلقائيًا عندما ينضم شخص بالبريد الإلكتروني نفسه.';

  @override
  String get grpCImpNoEmail => 'بدون بريد إلكتروني';

  @override
  String grpCImpPersonSub(String email, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا مهام',
    );
    return '$email · $_temp0';
  }

  @override
  String get grpCImpAssignTo => 'تعيين إلى...';

  @override
  String get grpCImpStepSource => 'المصدر';

  @override
  String get grpCImpStepUpload => 'رفع';

  @override
  String get grpCImpStepMap => 'مطابقة';

  @override
  String get grpCImpStepReview => 'مراجعة';

  @override
  String get grpCImpStepImport => 'استيراد';

  @override
  String get grpCImpWhere => 'من أين تأتي بياناتك؟';

  @override
  String get grpCImpAuto => 'لست متأكدًا: استنتج ذلك من الملف';

  @override
  String get grpCImpNext => 'التالي';

  @override
  String get grpCImpZipSeveral =>
      'يحتوي هذا الملف المضغوط على عدة ملفات بيانات. أيها تريد استيراده؟ (يحتوي تصدير مساحة العمل على ملف لكل مشروع.)';

  @override
  String get grpCImpChooseAFile => 'اختر ملفًا';

  @override
  String get grpCImpChooseGeneric =>
      'اختر الملف المراد استيراده (‎.csv‎ أو ‎.json‎ أو ‎.zip‎ يحتوي عليه).';

  @override
  String grpCImpChooseSource(String source) {
    return 'اختر ملف $source الخاص بك (‎.csv‎ أو ‎.json‎ أو ‎.zip‎ يحتوي عليه).';
  }

  @override
  String get grpCImpSentNote =>
      'يُرسَل الملف إلى خادم TaskForge ويُقرأ كتدفق، لذا لا مشكلة في الملفات الكبيرة. لن يتغير شيء حتى تؤكد.';

  @override
  String get grpCImpPickFile => 'اختيار ملف';

  @override
  String get grpCImpResumeThis => 'استئناف هذا الاستيراد';

  @override
  String get grpCImpWhatHappens => 'هذا ما سيحدث';

  @override
  String get grpCImpCountTasks => 'مهام';

  @override
  String get grpCImpCountSubtasks => 'منها مهام فرعية';

  @override
  String get grpCImpCountComments => 'تعليقات';

  @override
  String get grpCImpCountLinks => 'روابط';

  @override
  String get grpCImpCountSprints => 'سباقات';

  @override
  String get grpCImpCountLabels => 'تسميات';

  @override
  String get grpCImpCountStatuses => 'حالات جديدة';

  @override
  String get grpCImpCountPlaceholders => 'أشخاص في الانتظار';

  @override
  String grpCImpAlready(int count) {
    return 'تم استيراد $count منها سابقًا وسيتم تخطيها دون تكرار.';
  }

  @override
  String grpCImpRowErrors(int count) {
    return 'لا يمكن استيراد $count صف (صفوف) وسيتم استبعادها.';
  }

  @override
  String get grpCImpResumeImport => 'استئناف الاستيراد';

  @override
  String get grpCImpStart => 'بدء الاستيراد';

  @override
  String get grpCImpUndoRunBody =>
      'سيؤدي هذا إلى إزالة المهام والتعليقات والروابط والسباقات والحالات التي أنشأها هذا الاستيراد. وسيتم الاحتفاظ بكل ما أضفته إليها يدويًا.';

  @override
  String get grpCImpWaitingStart => 'في انتظار البدء...';

  @override
  String get grpCImpLinking => 'جارٍ ربط المهام...';

  @override
  String grpCImpProgress(int done, int total) {
    return '$done من $total مهمة';
  }

  @override
  String get grpCImpCancel => 'إلغاء الاستيراد';

  @override
  String get grpCImpFinished => 'اكتمل الاستيراد';

  @override
  String get grpCImpUndone => 'تم التراجع عن الاستيراد';

  @override
  String get grpCImpCancelled => 'تم إلغاء الاستيراد';

  @override
  String get grpCImpStopped => 'توقف الاستيراد';

  @override
  String get grpCImpOpenProject => 'فتح المشروع';

  @override
  String get grpCImpAnother => 'استيراد ملف آخر';

  @override
  String grpCImpRemoved(num tasks) {
    return 'تمت إزالة $tasks مهمة.';
  }

  @override
  String grpCImpRemovedKept(num tasks, num kept) {
    return 'تمت إزالة $tasks مهمة، مع الاحتفاظ بـ $kept لديها مهام فرعية خاصة بك.';
  }

  @override
  String get grpCImpTheFile => 'الملف';

  @override
  String grpCImpSummary(int issues, int comments, int links, String file) {
    return 'تم العثور على $issues مهمة و$comments تعليق و$links رابط في $file.';
  }

  @override
  String grpCImpSummarySub(
    int issues,
    int subtasks,
    int comments,
    int links,
    String file,
  ) {
    return 'تم العثور على $issues مهمة ($subtasks مهام فرعية) و$comments تعليق و$links رابط في $file.';
  }

  @override
  String get grpCImpPriUrgent => 'عاجل';

  @override
  String get grpCImpPriHigh => 'مرتفع';

  @override
  String get grpCImpPriNormal => 'عادي';

  @override
  String get grpCImpPriLow => 'منخفض';

  @override
  String get grpCImpPriNone => 'لا شيء';

  @override
  String get grpCImpFTitle => 'العنوان *';

  @override
  String get grpCImpFDescription => 'الوصف';

  @override
  String get grpCImpFPriority => 'الأولوية';

  @override
  String get grpCImpFAssignee => 'المكلّف';

  @override
  String get grpCImpFReporter => 'المُبلّغ';

  @override
  String get grpCImpFCreated => 'تاريخ الإنشاء';

  @override
  String get grpCImpFUpdated => 'تاريخ التحديث';

  @override
  String get grpCImpFStart => 'تاريخ البدء';

  @override
  String get grpCImpFDue => 'تاريخ الاستحقاق';

  @override
  String get grpCImpFLabels => 'التسميات';

  @override
  String get grpCImpFSprint => 'السباق';

  @override
  String get grpCImpFParent => 'الأصل (المعرّف)';

  @override
  String get grpCImpFId => 'المعرّف';

  @override
  String get grpCImpFKey => 'المفتاح';

  @override
  String get grpCImpFPoints => 'نقاط القصة';

  @override
  String get grpCImpFEstimate => 'التقدير';

  @override
  String get grpCImpFType => 'النوع';

  @override
  String get grpCImpPriorities => 'الأولويات';

  @override
  String grpCImpKeepLabels(int count) {
    return 'الاحتفاظ بـ $count تسمية';
  }

  @override
  String get grpCImpKeepLabelsSub => 'كحقل «التسميات» في كل مهمة.';

  @override
  String grpCImpSprintsCreated(String sprints) {
    return 'السباقات التي سيتم إنشاؤها: $sprints';
  }

  @override
  String get grpCImpReview => 'مراجعة';

  @override
  String get grpCImpReadAs => 'قراءة كـ';

  @override
  String get grpCImpZipFile => 'الملف داخل الأرشيف';

  @override
  String get grpCImpChooseOne => 'اختر واحدًا';

  @override
  String get grpCImpInto => 'الاستيراد إلى';

  @override
  String get grpCImpNewProject => 'مشروع جديد';

  @override
  String get grpCImpExistingProject => 'مشروع موجود';

  @override
  String get grpCImpProjectName => 'اسم المشروع';

  @override
  String get grpCImpColumns => 'الأعمدة';

  @override
  String get grpCImpNotInFile => '(غير موجود في الملف)';

  @override
  String get grpCImpStatuses => 'الحالات';

  @override
  String get grpCImpSameName => 'الاسم نفسه (يُنشأ إن لم يوجد)';

  @override
  String get grpCImpPeople => 'الأشخاص';

  @override
  String get grpCImpNotMember => 'ليس عضوًا بعد (يُعيَّن عند الانضمام)';

  @override
  String get grpCImpUnassigned => 'اتركه بلا تكليف';

  @override
  String get grpCImpFirst200 =>
      'تم إدراج أول 200 شخص فقط؛ والبقية ينتظرون كعناصر نائبة.';

  @override
  String grpCAutoDeleteTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get grpCAutoDeleteBody =>
      'ستتوقف القاعدة نهائيًا. وسيُحذف سجل تشغيلها أيضًا.';

  @override
  String get grpCAutoTitle => 'الأتمتة';

  @override
  String grpCAutoTitleProject(String project) {
    return 'الأتمتة · $project';
  }

  @override
  String get grpCAutoMissing => 'لم يتم العثور على المشروع.';

  @override
  String get grpCAutoRules => 'القواعد';

  @override
  String get grpCAutoRunHistory => 'سجل التشغيل';

  @override
  String get grpCAutoNew => 'أتمتة جديدة';

  @override
  String get grpCAutoReadOnly => 'للقراءة فقط';

  @override
  String grpCAutoLimit(int limit) {
    return 'تم بلوغ حد $limit قاعدة.';
  }

  @override
  String grpCAutoRuleFilter(String name) {
    return 'القاعدة: $name';
  }

  @override
  String get grpCAutoEmpty =>
      'لا توجد أتمتة بعد. تقول القاعدة: عندما يحدث شيء ما، وإذا تطابق، فافعل هذه الأمور.';

  @override
  String grpCAutoWhen(String trigger, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجراء',
      many: '$count إجراءً',
      few: '$count إجراءات',
      two: 'إجراءان',
      one: 'إجراء واحد',
      zero: 'لا إجراءات',
    );
    return 'عندما $trigger · $_temp0';
  }

  @override
  String get grpCAutoNeverRun => 'لم يُشغَّل أبدًا';

  @override
  String get grpCAutoHistory => 'السجل';

  @override
  String get grpCAutoDryRun => 'تشغيل تجريبي';

  @override
  String get grpCAutoStatusChanges => 'تتغير حالة';

  @override
  String grpCAutoMovesTo(String status) {
    return 'تنتقل مهمة إلى $status';
  }

  @override
  String grpCAutoFieldChanges(String field) {
    return 'يتغير $field';
  }

  @override
  String get grpCAutoSomeoneAssigned => 'يتم تعيين شخص ما';

  @override
  String grpCAutoUserAssigned(String user) {
    return 'يتم تعيين $user';
  }

  @override
  String get grpCAutoDueReached => 'يحين موعد الاستحقاق';

  @override
  String grpCAutoDaysBefore(int days) {
    return 'قبل $days أيام من موعد الاستحقاق';
  }

  @override
  String get grpCAutoDeletedStatus => 'حالة محذوفة';

  @override
  String get grpCAutoUnknownPerson => 'شخص غير معروف';

  @override
  String get grpCAutoEvent => 'الحدث';

  @override
  String get grpCAutoMovesToLabel => 'ينتقل إلى';

  @override
  String get grpCAutoAnyStatus => 'أي حالة';

  @override
  String get grpCAutoAssignedPerson => 'الشخص المُعيَّن';

  @override
  String get grpCAutoAnyone => 'أي شخص';

  @override
  String grpCAutoDaysLabel(int max) {
    return 'الأيام قبل موعد الاستحقاق (من 0 إلى $max)';
  }

  @override
  String grpCAutoTokensHelp(String tokens) {
    return 'يمكنك استخدام $tokens';
  }

  @override
  String get grpCAutoDateHint => 'YYYY-MM-DD';

  @override
  String grpCAutoUseToken(String token) {
    return 'استخدام $token';
  }

  @override
  String get grpCAutoHow => 'كيف';

  @override
  String get grpCAutoReplaceAssignees => 'استبدال المكلّفين بـ';

  @override
  String get grpCAutoAdd => 'إضافة';

  @override
  String get grpCAutoRemoveEveryone => 'إزالة الجميع';

  @override
  String get grpCAutoSubtaskTitle => 'عنوان المهمة الفرعية';

  @override
  String get grpCAutoMessage => 'الرسالة';

  @override
  String get grpCAutoAddress => 'العنوان';

  @override
  String get grpCAutoAddressHelp =>
      'عناوين http(s) العامة فقط؛ تُرفض العناوين الخاصة.';

  @override
  String get grpCAutoMethod => 'الطريقة';

  @override
  String get grpCAutoDoThis => 'نفّذ هذا';

  @override
  String grpDActionFailed(String error) {
    return 'لم تنجح هذه العملية ($error).';
  }

  @override
  String get grpDSwitchWorkspace => 'تبديل مساحة العمل';

  @override
  String grpDWorkspaceHere(String name) {
    return '$name (هنا)';
  }

  @override
  String get grpDNewDoc => 'مستند جديد';

  @override
  String get grpDTitle => 'العنوان';

  @override
  String get grpDUntitled => 'بدون عنوان';

  @override
  String get grpDNewDashboard => 'لوحة معلومات جديدة';

  @override
  String get grpDNewSprint => 'سبرنت جديد';

  @override
  String grpDStatusOf(String id) {
    return 'حالة $id';
  }

  @override
  String get grpDNewTask => 'مهمة جديدة';

  @override
  String get grpDCancel => 'إلغاء';

  @override
  String get grpDCreate => 'إنشاء';

  @override
  String get grpDSort => 'ترتيب';

  @override
  String get grpDNoSort => 'بدون ترتيب';

  @override
  String grpDSortBy(String names) {
    return 'ترتيب: $names';
  }

  @override
  String get grpDGroup => 'مجموعة';

  @override
  String get grpDNoGrouping => 'بدون تجميع';

  @override
  String grpDGroupBy(String name) {
    return 'المجموعة: $name';
  }

  @override
  String get grpDColumns => 'الأعمدة';

  @override
  String get grpDRefresh => 'تحديث';

  @override
  String get grpDLayoutNotSaved =>
      'تعذر حفظ تخطيطك. ستتم إعادة المحاولة عند تغييرك التالي.';

  @override
  String get grpDLayouts => 'التخطيطات';

  @override
  String get grpDResetLayout => 'إعادة ضبط تخطيطي';

  @override
  String get grpDShareLayoutMenu => 'مشاركة هذا التخطيط…';

  @override
  String grpDDeleteShared(String name) {
    return 'حذف «$name» المشترك';
  }

  @override
  String grpDDeleteSharedTitle(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get grpDDeleteSharedBody => 'سيختفي للجميع في هذا المشروع.';

  @override
  String get grpDDelete => 'حذف';

  @override
  String grpDDeletedNamed(String name) {
    return 'تم حذف «$name»';
  }

  @override
  String grpDSharedNamed(String name) {
    return 'تمت مشاركة «$name»';
  }

  @override
  String get grpDShareLayoutTitle => 'مشاركة هذا التخطيط';

  @override
  String get grpDName => 'الاسم';

  @override
  String get grpDShare => 'مشاركة';

  @override
  String get grpDTaskNotFound => 'لم يتم العثور على المهمة.';

  @override
  String get grpDDeleteTask => 'حذف المهمة';

  @override
  String get grpDClose => 'إغلاق';

  @override
  String get grpDPriority => 'الأولوية';

  @override
  String get grpDStart => 'البداية';

  @override
  String get grpDDue => 'الاستحقاق';

  @override
  String get grpDAssignees => 'المكلّفون';

  @override
  String get grpDDescription => 'الوصف';

  @override
  String grpDTaskDeleted(String id) {
    return 'تم حذف $id';
  }

  @override
  String get grpDUndo => 'تراجع';

  @override
  String get grpDStatus => 'الحالة';

  @override
  String grpDClearField(String label) {
    return 'مسح $label';
  }

  @override
  String get grpDDueTime => 'وقت الاستحقاق (ساعتك)';

  @override
  String get grpDClearDueTime => 'مسح وقت الاستحقاق';

  @override
  String get grpDAllOf => 'كل هذه';

  @override
  String get grpDAnyOf => 'أي من هذه';

  @override
  String get grpDNot => 'ليس';

  @override
  String get grpDRemoveGroup => 'إزالة المجموعة';

  @override
  String get grpDCondition => 'شرط';

  @override
  String get grpDFieldRemoved => 'حقل (محذوف)';

  @override
  String get grpDRemoveCondition => 'إزالة الشرط';

  @override
  String get grpDOpBefore => 'قبل';

  @override
  String get grpDOpOnOrBefore => 'في أو قبل';

  @override
  String get grpDOpAfter => 'بعد';

  @override
  String get grpDOpOnOrAfter => 'في أو بعد';

  @override
  String get grpDOpLessThan => 'أقل من';

  @override
  String get grpDOpAtMost => 'على الأكثر';

  @override
  String get grpDOpMoreThan => 'أكثر من';

  @override
  String get grpDOpAtLeast => 'على الأقل';

  @override
  String get grpDYes => 'نعم';

  @override
  String get grpDNo => 'لا';

  @override
  String get grpDCurrentSprint => 'السبرنت الحالي';

  @override
  String get grpDMe => 'أنا';

  @override
  String get grpDChoose => 'اختر…';

  @override
  String get grpDValue => 'القيمة';

  @override
  String get grpDPickDate => 'اختر تاريخًا';

  @override
  String get grpDOrderByLabel => 'الترتيب حسب ';

  @override
  String get grpDAscending => 'تصاعدي';

  @override
  String get grpDDescending => 'تنازلي';

  @override
  String get grpDRemoveOrdering => 'إزالة الترتيب';

  @override
  String get grpDOrderBy => 'الترتيب حسب';

  @override
  String get grpDRepeatNothingToUpdate =>
      'ستستخدم المهام الجديدة هذه المهمة. لا توجد مهمة مفتوحة تحتاج إلى تغيير.';

  @override
  String grpDRepeatUpdatedLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة مفتوحة لاحقة',
      many: '$count مهمة مفتوحة لاحقة',
      few: '$count مهام مفتوحة لاحقة',
      two: 'مهمتين مفتوحتين لاحقتين',
      one: 'مهمة مفتوحة لاحقة واحدة',
      zero: 'لا مهام مفتوحة لاحقة',
    );
    return 'تم تحديث $_temp0.';
  }

  @override
  String get grpDRepeat => 'التكرار';

  @override
  String grpDRepeatUnsupported(String summary) {
    return 'تم ضبط «$summary» بطريقة لا يستطيع هذا المحرر عرضها، لذا لا يمكن تغييره هنا. ما زال بإمكانك إيقافه مؤقتًا أو إيقافه.';
  }

  @override
  String get grpDSkipWeekends => 'تخطي عطلات نهاية الأسبوع';

  @override
  String get grpDStopRepeating => 'إيقاف التكرار';

  @override
  String get grpDResume => 'استئناف';

  @override
  String get grpDPause => 'إيقاف مؤقت';

  @override
  String get grpDUseForFuture => 'استخدام هذه المهمة للمهام المستقبلية';

  @override
  String get grpDSave => 'حفظ';

  @override
  String get grpDEvery => 'كل';

  @override
  String get grpDRepeatByDay => 'في يوم من الشهر';

  @override
  String get grpDRepeatByWeekday => 'في اليوم n من الأسبوع';

  @override
  String grpDDayNumber(int day) {
    return 'اليوم $day';
  }

  @override
  String get grpDNth1 => 'الأول';

  @override
  String get grpDNth2 => 'الثاني';

  @override
  String get grpDNth3 => 'الثالث';

  @override
  String get grpDNth4 => 'الرابع';

  @override
  String get grpDNthLast => 'الأخير';

  @override
  String get grpDEnds => 'ينتهي';

  @override
  String get grpDEndNever => 'أبدًا';

  @override
  String get grpDEndAfter => 'بعد';

  @override
  String get grpDEndOn => 'في';

  @override
  String get grpDTasksWord => 'مهام';

  @override
  String get grpDMakeIt => 'أنشئها قبل';

  @override
  String get grpDDaysAhead => 'أيام قبل تاريخ الاستحقاق';

  @override
  String grpDRepeatAt(String time) {
    return 'عند $time';
  }

  @override
  String get grpDNoFurtherDates => 'لا توجد تواريخ أخرى.';

  @override
  String grpDNextDates(String dates) {
    return 'التالي: $dates';
  }

  @override
  String get grpEBack => 'رجوع';

  @override
  String get grpECancel => 'إلغاء';

  @override
  String get grpEName => 'الاسم';

  @override
  String get grpERetry => 'إعادة المحاولة';

  @override
  String get grpEWorkspaceSettingsTitle => 'إعدادات مساحة العمل';

  @override
  String get grpEWorkspacesLoadRetry =>
      'تعذر تحميل مساحات العمل الخاصة بك. إعادة المحاولة';

  @override
  String get grpEMembers => 'الأعضاء';

  @override
  String get grpEMembersSub => 'الأشخاص والدعوات والمغادرة';

  @override
  String get grpERolesPerms => 'الأدوار والصلاحيات';

  @override
  String get grpERolesPermsSub => 'من يمكنه فعل ماذا';

  @override
  String get grpEAuditLog => 'سجل التدقيق';

  @override
  String get grpEAuditLogSub => 'من غيّر ماذا ومتى';

  @override
  String get grpEImportExport => 'الاستيراد والتصدير';

  @override
  String get grpEImportExportSub =>
      'استورد بيانات Jira أو ClickUp أو CSV، أو صدّرها';

  @override
  String get grpEWorkspaceUpdated => 'تم تحديث مساحة العمل.';

  @override
  String get grpEGeneral => 'عام';

  @override
  String get grpEChangeLogo => 'تغيير الشعار';

  @override
  String get grpEUrl => 'الرابط';

  @override
  String get grpERefresh => 'تحديث';

  @override
  String get grpESaveChanges => 'حفظ التغييرات';

  @override
  String get grpENotifSettings => 'إعدادات الإشعارات';

  @override
  String get grpEPushOffNotice =>
      'الإشعارات متوقفة على هذا الجهاز. يمكنك السماح بها من إعدادات النظام؛ تم حفظ اختيارك.';

  @override
  String get grpEZoneInvalid => 'استخدم اسمًا مثل Europe/Paris أو UTC.';

  @override
  String get grpEQuietDifferent => 'يجب أن يختلف وقت البدء عن وقت الانتهاء.';

  @override
  String get grpEWhatReachesYou => 'ما يصلك';

  @override
  String get grpEInbox => 'الوارد';

  @override
  String get grpEPush => 'الإشعار الفوري';

  @override
  String get grpEEmail => 'البريد الإلكتروني';

  @override
  String get grpEQuietHours => 'ساعات الهدوء';

  @override
  String get grpEQuietHold => 'تأجيل الإشعارات الفورية والبريد في ساعات الهدوء';

  @override
  String get grpEQuietHoldSub => 'يمتلئ الوارد دائمًا؛ فقط التنبيهات تنتظر.';

  @override
  String get grpEFrom => 'من';

  @override
  String get grpEUntil => 'حتى';

  @override
  String get grpETimeZoneDigest => 'المنطقة الزمنية والملخص';

  @override
  String get grpETimeZone => 'المنطقة الزمنية';

  @override
  String get grpETimeZoneHelper => 'تتبع ساعات الهدوء والملخص هذه المنطقة.';

  @override
  String get grpEUseDeviceZone => 'استخدام المنطقة الزمنية لهذا الجهاز';

  @override
  String get grpETypeZone =>
      'اكتب منطقتك الزمنية بدلًا من ذلك، مثل Europe/Paris.';

  @override
  String get grpEDigestAt => 'يُرسل الملخص اليومي عند';

  @override
  String get grpEEditField => 'تعديل الحقل';

  @override
  String get grpENewField => 'حقل جديد';

  @override
  String get grpEType => 'النوع';

  @override
  String get grpEOptions => 'الخيارات';

  @override
  String get grpEColour => 'اللون';

  @override
  String get grpELabel => 'التسمية';

  @override
  String get grpERemoveOption => 'إزالة الخيار';

  @override
  String get grpEAddOption => 'إضافة خيار';

  @override
  String get grpERequired => 'مطلوب';

  @override
  String get grpERequiredSub => 'يجب أن تحتوي المهام الجديدة على قيمة.';

  @override
  String get grpEDefaultValue => 'القيمة الافتراضية';

  @override
  String get grpEShowIn => 'عرض في';

  @override
  String get grpESave => 'حفظ';

  @override
  String get grpEAddField => 'إضافة حقل';

  @override
  String get grpEOptionN => 'الخيار 1';

  @override
  String get grpEProblemName => 'أعطِ الحقل اسمًا.';

  @override
  String get grpEProblemOne => 'أضف خيارًا واحدًا على الأقل.';

  @override
  String get grpEProblemLabel => 'كل خيار يحتاج إلى تسمية.';

  @override
  String get grpEProblemDup => 'خياران لهما التسمية نفسها.';

  @override
  String get grpEOptionsInUse => 'الخيارات قيد الاستخدام';

  @override
  String get grpERemovedOption => 'خيار محذوف';

  @override
  String grpERemapLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قيمة',
      many: '$count قيمة',
      few: '$count قيم',
      two: 'قيمتان',
      one: 'قيمة واحدة',
      zero: 'لا قيم',
    );
    return '$label ($_temp0) تصبح';
  }

  @override
  String get grpENothingClear => 'لا شيء (مسح)';

  @override
  String get grpEApply => 'تطبيق';

  @override
  String get grpEPrivate => 'خاص';

  @override
  String get grpESprints => 'السبرنتات';

  @override
  String get grpEAutomations => 'الأتمتة';

  @override
  String get grpESearch => 'بحث';

  @override
  String get grpETimesheet => 'سجل الوقت';

  @override
  String get grpEDashboards => 'لوحات المعلومات';

  @override
  String get grpEDocs => 'المستندات';

  @override
  String get grpEProjects => 'المشاريع';

  @override
  String get grpENewProject => 'مشروع جديد';

  @override
  String get grpEFavorites => 'المفضلة';

  @override
  String get grpEProjectsLoadRetry => 'تعذر تحميل المشاريع. إعادة المحاولة';

  @override
  String get grpEArchivedProjects => 'المشاريع المؤرشفة';

  @override
  String get grpEPrivateProjects => 'المشاريع الخاصة';

  @override
  String get grpENoProjects => 'لا توجد مشاريع بعد';

  @override
  String get grpECreateFirstProject => 'أنشئ مشروعك الأول';

  @override
  String get grpEMonth1 => 'يناير';

  @override
  String get grpEMonth2 => 'فبراير';

  @override
  String get grpEMonth3 => 'مارس';

  @override
  String get grpEMonth4 => 'أبريل';

  @override
  String get grpEMonth5 => 'مايو';

  @override
  String get grpEMonth6 => 'يونيو';

  @override
  String get grpEMonth7 => 'يوليو';

  @override
  String get grpEMonth8 => 'أغسطس';

  @override
  String get grpEMonth9 => 'سبتمبر';

  @override
  String get grpEMonth10 => 'أكتوبر';

  @override
  String get grpEMonth11 => 'نوفمبر';

  @override
  String get grpEMonth12 => 'ديسمبر';

  @override
  String get grpEWeekLocale => 'افتراضي اللغة';

  @override
  String get grpEMonday => 'الاثنين';

  @override
  String get grpESaturday => 'السبت';

  @override
  String get grpESunday => 'الأحد';

  @override
  String get grpEPrevious => 'السابق';

  @override
  String get grpENext => 'التالي';

  @override
  String get grpEToday => 'اليوم';

  @override
  String get grpEUnscheduled => 'غير مجدول';

  @override
  String get grpEMonth => 'شهر';

  @override
  String get grpEWeek => 'أسبوع';

  @override
  String get grpEDay => 'يوم';

  @override
  String get grpEColourBy => 'التلوين حسب';

  @override
  String get grpEColourByProject => 'التلوين حسب المشروع';

  @override
  String get grpEColourByStatus => 'التلوين حسب الحالة';

  @override
  String get grpEColourByPriority => 'التلوين حسب الأولوية';

  @override
  String get grpEColourChip => 'اللون';

  @override
  String get grpEWeekStartsOn => 'يبدأ الأسبوع في';

  @override
  String get grpEHideDone => 'إخفاء المنجز';

  @override
  String get grpELayoutNotSaved =>
      'تعذر حفظ تخطيط التقويم. ستتم المحاولة مرة أخرى عند التغيير التالي.';

  @override
  String get grpEEnterName => 'أدخل اسمًا.';

  @override
  String get grpENewRole => 'دور جديد';

  @override
  String get grpECreate => 'إنشاء';

  @override
  String get grpERenameRole => 'إعادة تسمية الدور';

  @override
  String get grpERename => 'إعادة تسمية';

  @override
  String grpEDeleteRoleTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get grpERoleNoOne => 'لا أحد لديه هذا الدور.';

  @override
  String grpERoleMoveMembers(int count) {
    return '$count عضو (أعضاء) لديهم هذا الدور. انقلهم إلى:';
  }

  @override
  String get grpEChooseRole => 'اختر دورًا';

  @override
  String get grpEDelete => 'حذف';

  @override
  String grpFBulkDeleted(int count) {
    return 'تم حذف $count مهام';
  }

  @override
  String grpFBulkUpdated(int count) {
    return 'تم تحديث $count مهام';
  }

  @override
  String grpFBulkPartialDeleted(int done, int total, int failed) {
    return 'تم حذف $done من $total مهام؛ تعذر حذف $failed.';
  }

  @override
  String grpFBulkPartialUpdated(int done, int total, int failed) {
    return 'تم تحديث $done من $total مهام؛ تعذر تحديث $failed.';
  }

  @override
  String get grpFDetails => 'التفاصيل';

  @override
  String grpFBulkDeleteTitle(int count) {
    return 'حذف $count مهام؟';
  }

  @override
  String get grpFBulkDeleteBody =>
      'تُحذف المهام الفرعية معها. يمكنك استعادتها من سلة المحذوفات.';

  @override
  String get grpFDelete => 'حذف';

  @override
  String get grpFSetStatus => 'تعيين الحالة';

  @override
  String get grpFSetPriority => 'تعيين الأولوية';

  @override
  String get grpFStatus => 'الحالة';

  @override
  String get grpFPriority => 'الأولوية';

  @override
  String get grpFAssign => 'تعيين';

  @override
  String get grpFClear => 'مسح';

  @override
  String grpFBulkUpdating(int done, int total) {
    return 'جارٍ تحديث $done من $total…';
  }

  @override
  String grpFBulkSelected(int count) {
    return 'تم تحديد $count';
  }

  @override
  String grpFBulkNotChanged(int count) {
    return 'لم تتغير $count مهام';
  }

  @override
  String get grpFTask => 'المهمة';

  @override
  String get grpFLinks => 'الروابط';

  @override
  String get grpFAddLink => 'إضافة رابط';

  @override
  String get grpFNoLinks => 'لا توجد روابط بعد.';

  @override
  String get grpFRemoveLink => 'إزالة الرابط';

  @override
  String get grpFLinkSearchHint => 'ابحث عن المهام في أي مشروع';

  @override
  String get grpFCloseDuplicate => 'إغلاق المهمة المكررة';

  @override
  String get grpFLinkAction => 'ربط';

  @override
  String get grpFUnassigned => 'غير معيّن';

  @override
  String get grpFNoValue => 'بلا قيمة';

  @override
  String get grpFAssignee => 'المكلّف';

  @override
  String grpFPresenceEditing(String name) {
    return '$name يحرّر';
  }

  @override
  String grpFPresenceViewing(String name) {
    return '$name يشاهد';
  }

  @override
  String grpFEditingOne(String name) {
    return '$name يحرّر هذا';
  }

  @override
  String grpFEditingMany(int count) {
    return '$count أشخاص يحرّرون هذا';
  }

  @override
  String grpFDeleteTaskTitle(String id) {
    return 'حذف $id؟';
  }

  @override
  String grpFDeleteSubtasksExplain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لديها $count مهمة فرعية. ماذا يجب أن يحدث لها؟',
      many: 'لديها $count مهمة فرعية. ماذا يجب أن يحدث لها؟',
      few: 'لديها $count مهام فرعية. ماذا يجب أن يحدث لها؟',
      two: 'لديها مهمتان فرعيتان. ماذا يجب أن يحدث لهما؟',
      one: 'لديها مهمة فرعية واحدة. ماذا يجب أن يحدث لها؟',
      zero: 'ليست لديها مهام فرعية. ماذا يجب أن يحدث لها؟',
    );
    return '$_temp0';
  }

  @override
  String get grpFKeepSubtasks => 'إبقاؤها (نقلها مستوى للأعلى)';

  @override
  String get grpFDeleteThemToo => 'احذفها أيضًا';

  @override
  String grpFOpenSubtasksTitle(String id) {
    return '$id لديها مهام فرعية مفتوحة';
  }

  @override
  String grpFOpenSubtasksExplain(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة فرعية لم تنتهِ. هل تنقلها إلى $status أيضًا؟',
      many: '$count مهمة فرعية لم تنتهِ. هل تنقلها إلى $status أيضًا؟',
      few: '$count مهام فرعية لم تنتهِ. هل تنقلها إلى $status أيضًا؟',
      two: 'مهمتان فرعيتان لم تنتهيا. هل تنقلهما إلى $status أيضًا؟',
      one: 'مهمة فرعية واحدة لم تنتهِ. هل تنقلها إلى $status أيضًا؟',
      zero: 'لا توجد مهام فرعية غير منتهية. هل تنقلها إلى $status أيضًا؟',
    );
    return '$_temp0';
  }

  @override
  String get grpFLeaveOpen => 'اتركها مفتوحة';

  @override
  String get grpFCompleteAll => 'إكمال الكل';

  @override
  String grpFMoveUnderTitle(String id) {
    return 'نقل $id تحت…';
  }

  @override
  String get grpFTopLevel => 'المستوى الأعلى (بلا أب)';

  @override
  String get grpFNoOtherParent => 'لا توجد مهمة أخرى لوضعها تحتها.';

  @override
  String get grpFSubtasks => 'المهام الفرعية';

  @override
  String get grpFAddSubtaskHint => 'أضف مهمة فرعية واضغط Enter';

  @override
  String get grpFActionAddSubtask => 'إضافة مهمة فرعية';

  @override
  String get grpFActionMoveUnder => 'نقل تحت…';

  @override
  String get grpFActionMakeTopLevel => 'جعلها في المستوى الأعلى';

  @override
  String get grpFBlockedByPending => 'محظورة بمهام لم تكتمل بعد';

  @override
  String grpFBlockedBy(String names) {
    return 'محظورة بواسطة $names';
  }

  @override
  String get grpFBlocked => 'محظورة';

  @override
  String get grpFBlockedTitle => 'هذه المهمة محظورة';

  @override
  String grpFBlockedTextOne(String blockers) {
    return 'محظورة بواسطة $blockers الذي لم يكتمل بعد.';
  }

  @override
  String grpFBlockedTextMany(String blockers) {
    return 'محظورة بواسطة $blockers اللتين لم تكتملا بعد.';
  }

  @override
  String get grpFOk => 'موافق';

  @override
  String get grpFCompleteAnyway => 'إكمال على أي حال';

  @override
  String grpFConflictTitle(String field) {
    return 'قام شخص ما بتغيير $field';
  }

  @override
  String get grpFTheirs => 'قيمتهم';

  @override
  String get grpFYours => 'قيمتك';

  @override
  String get grpFEmpty => '(فارغ)';

  @override
  String get grpFTakeTheirs => 'خذ قيمتهم';

  @override
  String get grpFKeepMine => 'أبقِ قيمتي';

  @override
  String get grpFFieldTitle => 'العنوان';

  @override
  String get grpFFieldDescription => 'الوصف';

  @override
  String get grpFFieldStatus => 'الحالة';

  @override
  String get grpFFieldPriority => 'الأولوية';

  @override
  String get grpFFieldStartDate => 'تاريخ البدء';

  @override
  String get grpFFieldDueDate => 'تاريخ الاستحقاق';

  @override
  String get grpFFieldAssignees => 'المكلّفون';

  @override
  String get grpFFields => 'الحقول';

  @override
  String get grpFRequiredFieldsIntro =>
      'تحتاج هذه الحقول إلى قيمة قبل إنشاء المهمة.';

  @override
  String get grpFRequired => 'مطلوب';

  @override
  String get grpFCreate => 'إنشاء';

  @override
  String get grpFChangeStatus => 'تغيير الحالة';

  @override
  String get grpFChangePriority => 'تغيير الأولوية';

  @override
  String get grpFDate => 'التاريخ';

  @override
  String get grpFPickDay => 'اختر يومًا…';

  @override
  String get grpFAssignees => 'المكلّفون';

  @override
  String get grpFViewList => 'قائمة';

  @override
  String get grpFViewBoard => 'لوحة';

  @override
  String get grpFViewTimeline => 'الجدول الزمني';

  @override
  String grpFErrorRetry(String message) {
    return '$message أعد المحاولة';
  }

  @override
  String get grpFNoTasksYet => 'لا توجد مهام بعد. أضف الأولى أعلاه.';

  @override
  String get grpFSwipeComplete => 'إكمال';

  @override
  String get grpFUndo => 'تراجع';

  @override
  String get grpFMore => 'المزيد';

  @override
  String grpFAddSubtaskTo(String id) {
    return 'إضافة مهمة فرعية إلى $id';
  }

  @override
  String grpFTaskDeleted(String id) {
    return 'تم حذف $id';
  }

  @override
  String get grpFColTitle => 'العنوان';

  @override
  String grpFTrashTitle(String name) {
    return '$name · سلة المحذوفات';
  }

  @override
  String get grpFTrashEmpty => 'سلة المحذوفات فارغة.';

  @override
  String grpFTrashedRow(String id) {
    return '$id · محذوفة';
  }

  @override
  String get grpFRestore => 'استعادة';

  @override
  String grpFTaskRestored(String id) {
    return 'تمت استعادة $id';
  }

  @override
  String get grpFMoveTo => 'نقل إلى…';

  @override
  String grpFMoveToColumn(String name) {
    return 'نقل إلى $name';
  }

  @override
  String grpFPlusCount(int count) {
    return '+$count';
  }

  @override
  String get grpFFoldColumn => 'طي العمود';

  @override
  String get grpFColumn => 'العمود';

  @override
  String get grpFSetWipLimit => 'تحديد حد للعمل الجاري…';

  @override
  String get grpFChangeLimit => 'تغيير الحد…';

  @override
  String get grpFAddTask => 'إضافة مهمة';

  @override
  String get grpFWipTitle => 'حد العمل الجاري';

  @override
  String get grpFWipMost => 'أقصى عدد من البطاقات في هذا العمود';

  @override
  String get grpFColumnsBy => 'الأعمدة حسب';

  @override
  String grpFColumnsChip(String name) {
    return 'الأعمدة: $name';
  }

  @override
  String get grpFSwimlanes => 'المسارات';

  @override
  String get grpFLanesAssignee => 'المسارات: المكلّف';

  @override
  String get grpFNoSwimlanes => 'بلا مسارات';

  @override
  String get grpFByAssignee => 'حسب المكلّف';

  @override
  String get grpFCardFields => 'حقول البطاقة';

  @override
  String get grpFCurrentSprint => 'السبرنت الحالي';

  @override
  String get grpFRefresh => 'تحديث';

  @override
  String get grpFBoardLayoutNotSaved =>
      'تعذر حفظ تخطيط اللوحة. ستتم المحاولة مرة أخرى عند تغييرك التالي.';

  @override
  String get grpFReschedule => 'إعادة الجدولة…';

  @override
  String get grpFSchedule => 'جدولة…';

  @override
  String get grpFRepeatsNotMade => 'تكرار: لم تُنشأ بعد';

  @override
  String get grpFEverythingDated => 'كل شيء له تاريخ.';

  @override
  String grpFNothingOn(String day) {
    return 'لا شيء في $day.';
  }

  @override
  String get grpFKindTasks => 'المهام';

  @override
  String get grpFKindComments => 'التعليقات';

  @override
  String get grpFKindProjects => 'المشاريع';

  @override
  String get grpFKindPeople => 'الأشخاص';

  @override
  String get grpFKindPages => 'الصفحات';

  @override
  String get grpFChipAssignedToMe => 'المعيّنة لي';

  @override
  String get grpFChipOpen => 'مفتوحة';

  @override
  String get grpFChipDone => 'مكتملة';

  @override
  String get grpFSearchErrGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get grpFSearchErrNetwork => 'تعذر الوصول إلى الخادم. تحقق من اتصالك.';

  @override
  String get grpFSearchErrDenied => 'ليس لديك صلاحية البحث هنا.';

  @override
  String get grpFSearchErrRate => 'عمليات بحث كثيرة. انتظر لحظة.';

  @override
  String get grpFSearchErrInvalid => 'هذا البحث غير صالح.';

  @override
  String get grpFSearchHint => 'ابحث في المهام والتعليقات والمشاريع والأشخاص';

  @override
  String get grpFSearchClose => 'إغلاق البحث';

  @override
  String get grpFSearchNothing =>
      'لم يتم العثور على شيء. جرّب كلمات أقل أو معرّفًا مثل WEB-12. ضيّق البحث بـ in:KEY أو assignee:me أو status:open.';

  @override
  String get grpFSearchTips =>
      'اكتب للبحث. جرّب معرّفًا مثل WEB-12 أو عوامل مثل in:KEY وassignee:me وstatus:open.';

  @override
  String get grpFGoTo => 'انتقل إلى';

  @override
  String grpFShowMore(String kind) {
    return 'عرض المزيد من $kind';
  }

  @override
  String get grpFRecent => 'الأحدث';

  @override
  String grpFPlusMore(int count) {
    return '+$count أخرى';
  }

  @override
  String get grpFSubtaskDepthLimit =>
      'المهام الفرعية متداخلة هنا بأقصى عمق يسمح به التطبيق.';

  @override
  String get grpFUnscheduled => 'غير مجدولة';

  @override
  String get grpGCloseShortcuts => 'إغلاق اختصارات لوحة المفاتيح';

  @override
  String get grpGKeyboardShortcuts => 'اختصارات لوحة المفاتيح';

  @override
  String get grpGClose => 'إغلاق';

  @override
  String get grpGChangedByYou => 'غيّرته أنت';

  @override
  String get grpGNone => 'لا شيء';

  @override
  String grpGChangeKeysFor(String title) {
    return 'تغيير مفاتيح «$title»';
  }

  @override
  String grpGKeysFor(String title) {
    return 'مفاتيح «$title»';
  }

  @override
  String get grpGPressKeys => 'اضغط المفاتيح التي تريدها.';

  @override
  String get grpGUseDefault => 'استخدام الافتراضي';

  @override
  String get grpGNoKey => 'بلا مفتاح';

  @override
  String get grpGCancel => 'إلغاء';

  @override
  String get grpGSave => 'حفظ';

  @override
  String grpGBrowserKeeps(String keys) {
    return 'المتصفح يحتفظ بـ $keys.';
  }

  @override
  String grpGAlreadyUsedBy(String title) {
    return 'مستخدم بالفعل من قبل «$title».';
  }

  @override
  String get grpGKeysTaken => 'إجراء آخر يستخدم هذه المفاتيح بالفعل.';

  @override
  String get grpGKeysInvalid => 'لا يمكن استخدام هذه المفاتيح.';

  @override
  String get grpGSaveFailed => 'تعذّر الحفظ. تحقق من اتصالك.';

  @override
  String grpGDefaultUsedBy(String title) {
    return 'المفاتيح الافتراضية مستخدمة من قبل «$title».';
  }

  @override
  String get grpGDefaultUsedByOther =>
      'المفاتيح الافتراضية مستخدمة من قبل إجراء آخر.';

  @override
  String get grpGPaletteHint => 'اكتب أمرًا، أو > إجراءات  # مشاريع  @ أشخاص';

  @override
  String get grpGNothingMatches => 'لا شيء مطابق.';

  @override
  String get grpGSearchUnavailable => 'البحث غير متاح الآن.';

  @override
  String get grpGName => 'الاسم';

  @override
  String get grpGCreate => 'إنشاء';

  @override
  String get grpGQuickActions => 'إجراءات سريعة';

  @override
  String grpGDryRunTitle(String name) {
    return 'تشغيل تجريبي: $name';
  }

  @override
  String get grpGDryRunIntro =>
      'يعرض ما سيحدث على مهمة. لا يتم تغيير أي شيء أو إرساله أو الإشعار به.';

  @override
  String get grpGTask => 'المهمة';

  @override
  String get grpGTasksLoadFailed => 'تعذّر تحميل المهام.';

  @override
  String get grpGWouldRun => 'سيتم تشغيلها.';

  @override
  String get grpGWouldNotRun => 'لن تعمل على هذه المهمة.';

  @override
  String get grpGRun => 'تشغيل';

  @override
  String get grpGConditionProblem => 'في الشرط مشكلة: انظر أسفل بطاقة «إذا».';

  @override
  String get grpGRuleGone => 'هذه القاعدة لم تعد موجودة.';

  @override
  String get grpGRule => 'قاعدة';

  @override
  String get grpGNewAutomation => 'أتمتة جديدة';

  @override
  String get grpGEditAutomation => 'تعديل الأتمتة';

  @override
  String get grpGWhen => 'عندما';

  @override
  String get grpGIfOptional => 'إذا (اختياري)';

  @override
  String get grpGThen => 'ثم';

  @override
  String get grpGAndThen => 'وبعد ذلك';

  @override
  String grpGActionLimit(int max) {
    return 'تم بلوغ حد $max إجراءات';
  }

  @override
  String get grpGAddAction => 'إضافة إجراء';

  @override
  String get grpGLoadLatest => 'تحميل أحدث نسخة';

  @override
  String get grpGMoveUp => 'نقل لأعلى';

  @override
  String get grpGMoveDown => 'نقل لأسفل';

  @override
  String get grpGRemoveAction => 'إزالة الإجراء';

  @override
  String grpGSwitchedOff(String reason) {
    return 'تم الإيقاف: $reason\nللإصلاح: افتح القاعدة، واختر شيئًا ما زال موجودًا في المشغّل أو الإجراءات، ثم احفظ وأعد تشغيلها.';
  }

  @override
  String get grpGUnknown => 'غير معروف';

  @override
  String get grpGEmptyValue => '(فارغ)';

  @override
  String get grpGNothingRunYet => 'لم يتم تشغيل أي شيء بعد.';

  @override
  String get grpGLoadMore => 'تحميل المزيد';

  @override
  String get grpGRetry => 'إعادة المحاولة';

  @override
  String grpGWhyNotRun(String explanation) {
    return 'لماذا لم يعمل هذا؟ $explanation';
  }

  @override
  String grpGChainDepth(int depth) {
    return 'عمق السلسلة $depth';
  }

  @override
  String get grpGFilter => 'تصفية';

  @override
  String grpGFilterCount(int count) {
    return 'تصفية ($count)';
  }

  @override
  String get grpGSavedFilters => 'التصفيات المحفوظة';

  @override
  String get grpGNoSavedFilters => 'لا توجد تصفيات محفوظة بعد';

  @override
  String grpGFieldGoneNamed(String name) {
    return '$name (حقل مفقود)';
  }

  @override
  String get grpGManageSaved => 'إدارة التصفيات المحفوظة…';

  @override
  String grpGConditionCount(int count) {
    return '$count شرط/شروط';
  }

  @override
  String get grpGClearFilterTip => 'مسح التصفية';

  @override
  String get grpGNothingSaved => 'لم يتم حفظ أي شيء بعد.';

  @override
  String get grpGFieldItUsedGone => 'حقل كان يستخدمه لم يعد موجودًا';

  @override
  String get grpGDelete => 'حذف';

  @override
  String get grpGFinishConditions => 'أكمل الشروط أولًا.';

  @override
  String get grpGEveryoneWorkspace => 'الجميع في مساحة العمل';

  @override
  String get grpGEveryoneProject => 'الجميع في هذا المشروع';

  @override
  String get grpGBuilder => 'المنشئ';

  @override
  String get grpGAdvanced => 'متقدم';

  @override
  String get grpGClearFilter => 'مسح التصفية';

  @override
  String get grpGSaveAs => 'حفظ باسم…';

  @override
  String get grpGApply => 'تطبيق';

  @override
  String get grpGSaveThisFilter => 'حفظ هذه التصفية';

  @override
  String get grpGOnlyMe => 'أنا فقط';

  @override
  String get grpGExportSaveFailed => 'تعذّر حفظ الملف. حاول مرة أخرى.';

  @override
  String get grpGExport => 'تصدير';

  @override
  String get grpGEveryProject => 'كل مشروع يمكنني فتحه';

  @override
  String get grpGOneProject => 'مشروع واحد';

  @override
  String get grpGExportInfo =>
      'ملف zip يحتوي على tasks.json (الذي يمكن لـ TaskForge استيراده مجددًا) وtasks.csv والتعليقات وقائمة المرفقات وملف README.';

  @override
  String grpGExportSavedSized(String name, String size) {
    return 'تم حفظ $name ($size).';
  }

  @override
  String grpGExportSaved(String name) {
    return 'تم حفظ $name.';
  }

  @override
  String grpGNotesAboutFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاحظة حول هذا الملف',
      many: '$count ملاحظة حول هذا الملف',
      few: '$count ملاحظات حول هذا الملف',
      two: 'ملاحظتان حول هذا الملف',
      one: 'ملاحظة واحدة حول هذا الملف',
      zero: 'لا ملاحظات حول هذا الملف',
    );
    return '$_temp0';
  }

  @override
  String grpGRowNumber(int line) {
    return 'الصف $line';
  }

  @override
  String grpGAndMore(int count) {
    return '...و$count أخرى.';
  }

  @override
  String get grpGNotesReadFailed => 'تعذّرت قراءة الملاحظات حول هذا الاستيراد.';

  @override
  String get grpGDragToOtherList => 'اسحب إلى القائمة الأخرى';

  @override
  String get grpGAddedAfterStart => 'أُضيفت بعد البدء';

  @override
  String get grpGStoryPoints => 'نقاط القصة';

  @override
  String get grpGUnitHours => 'س';

  @override
  String get grpGUnitPoints => ' نقطة';

  @override
  String grpGLoadOf(String load, String unit, String cap) {
    return 'الحمل $load$unit من $cap$unit';
  }

  @override
  String grpGLoadNoCapacity(String load, String unit) {
    return 'الحمل $load$unit (لم تُحدَّد سعة)';
  }

  @override
  String get grpGSetCapacity => 'تحديد السعة';

  @override
  String get grpGPoints => 'نقاط';

  @override
  String get grpGHours => 'ساعات';

  @override
  String grpGOverCapacity(String amount, String unit) {
    return 'تجاوز السعة بمقدار $amount$unit';
  }

  @override
  String grpGTitleWithCount(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get grpHCancel => 'إلغاء';

  @override
  String get grpHArchive => 'أرشفة';

  @override
  String get grpHRestore => 'استعادة';

  @override
  String get grpHRetry => 'إعادة المحاولة';

  @override
  String get grpHCreate => 'إنشاء';

  @override
  String get grpHName => 'الاسم';

  @override
  String get grpHDescription => 'الوصف';

  @override
  String grpHArchiveTitle(String name) {
    return 'هل تريد أرشفة \"$name\"؟';
  }

  @override
  String get grpHArchiveBody =>
      'سيصبح للقراءة فقط ويختفي من الشريط الجانبي. يمكنك استعادته في أي وقت.';

  @override
  String get grpHDangerZone => 'منطقة الخطر';

  @override
  String get grpHRestoreProject => 'استعادة المشروع';

  @override
  String get grpHArchiveProject => 'أرشفة المشروع';

  @override
  String get grpHArchivedBanner => 'هذا المشروع مؤرشف وللقراءة فقط.';

  @override
  String get grpHArchivedProjects => 'المشاريع المؤرشفة';

  @override
  String get grpHNoArchived => 'لا توجد مشاريع مؤرشفة.';

  @override
  String get grpHLoadProjectsRetry => 'تعذر تحميل المشاريع. إعادة المحاولة';

  @override
  String get grpHNewProject => 'مشروع جديد';

  @override
  String get grpHKey => 'المفتاح';

  @override
  String get grpHKeyHelp => 'بادئة أرقام المهام، مثل WEB-12';

  @override
  String get grpHFeatures => 'الميزات';

  @override
  String get grpHFeaturesHint => 'إيقاف ميزة يخفيها لكنه يحتفظ ببياناتها.';

  @override
  String get grpHProjectUpdated => 'تم تحديث المشروع.';

  @override
  String get grpHGeneral => 'عام';

  @override
  String grpHKeyFixed(String taskKey) {
    return 'المفتاح ثابت لأن المهام تستخدمه بالفعل ($taskKey).';
  }

  @override
  String get grpHSaveChanges => 'حفظ التغييرات';

  @override
  String get grpHAddAMember => 'إضافة عضو';

  @override
  String get grpHAllAreMembers => 'جميع من في مساحة العمل أعضاء بالفعل.';

  @override
  String get grpHMembers => 'الأعضاء';

  @override
  String get grpHAddMember => 'إضافة عضو';

  @override
  String get grpHRemove => 'إزالة';

  @override
  String get grpHLoadMembersRetry => 'تعذر تحميل الأعضاء. إعادة المحاولة';

  @override
  String get grpHPrivateProjects => 'المشاريع الخاصة';

  @override
  String get grpHNoPrivate => 'لا توجد مشاريع خاصة.';

  @override
  String grpHKeyAndMembers(String key, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
      zero: 'لا أعضاء',
    );
    return '$key · $_temp0';
  }

  @override
  String get grpHAddMe => 'أضفني';

  @override
  String grpHColorLabel(String color) {
    return 'اللون $color';
  }

  @override
  String get grpHVisOpen => 'مفتوح';

  @override
  String get grpHVisPrivate => 'خاص';

  @override
  String get grpHVisOpenHint => 'يمكن لجميع من في مساحة العمل رؤيته.';

  @override
  String get grpHVisPrivateHint => 'لا يراه إلا الأعضاء المدعوون.';

  @override
  String get grpHProject => 'المشروع';

  @override
  String get grpHRemoveFavorite => 'إزالة من المفضلة';

  @override
  String get grpHAddFavorite => 'إضافة إلى المفضلة';

  @override
  String get grpHTrash => 'سلة المحذوفات';

  @override
  String get grpHProjectSettings => 'إعدادات المشروع';

  @override
  String get grpHLoadProjectRetry => 'تعذر تحميل المشروع. إعادة المحاولة';

  @override
  String get grpHProjectNotFound => 'لم يتم العثور على المشروع.';

  @override
  String get grpHBack => 'رجوع';

  @override
  String get grpHWorkflow => 'سير العمل';

  @override
  String get grpHWorkflowHint => 'الحالات وفئاتها والانتقالات المسموح بها.';

  @override
  String get grpHFields => 'الحقول';

  @override
  String get grpHFieldsHint => 'حقول مخصصة مثل العميل أو نقاط القصة أو البيئة.';

  @override
  String get grpHAdd => 'إضافة';

  @override
  String get grpHAttachFile => 'إرفاق ملف';

  @override
  String get grpHTakePhoto => 'التقاط صورة';

  @override
  String get grpHChooseGallery => 'اختيار من المعرض';

  @override
  String get grpHPasteImage => 'لصق صورة';

  @override
  String get grpHDeleteFileQ => 'هل تريد حذف هذا الملف؟';

  @override
  String grpHFileWillBeRemoved(String filename) {
    return 'سيتم إزالة $filename.';
  }

  @override
  String get grpHDelete => 'حذف';

  @override
  String grpHOpenFile(String filename) {
    return 'فتح $filename';
  }

  @override
  String grpHDeleteFile(String filename) {
    return 'حذف $filename';
  }

  @override
  String get grpHWaitingConnection => 'في انتظار الاتصال…';

  @override
  String get grpHWaiting => 'في الانتظار…';

  @override
  String get grpHUploadDone => 'تم';

  @override
  String get grpHUploadCancelled => 'أُلغي';

  @override
  String grpHPercentUploaded(String filename, int percent) {
    return '$filename، تم رفع $percent بالمئة';
  }

  @override
  String get grpHWaitingToBeSent => 'في انتظار الإرسال';

  @override
  String grpHCancelFile(String filename) {
    return 'إلغاء $filename';
  }

  @override
  String grpHTryFileAgain(String filename) {
    return 'إعادة محاولة $filename';
  }

  @override
  String grpHDismissFile(String filename) {
    return 'إخفاء $filename';
  }

  @override
  String get grpHOpen => 'فتح';

  @override
  String get grpHDownload => 'تنزيل';

  @override
  String get grpHClose => 'إغلاق';

  @override
  String get grpHCouldNotOpenFile => 'تعذر فتح الملف.';

  @override
  String get grpHCouldNotLoadPicture => 'تعذر تحميل الصورة.';

  @override
  String get grpHCouldNotReadFileViewer => 'تعذرت قراءة الملف.';

  @override
  String get grpHCouldNotPlayVideo => 'تعذر تشغيل الفيديو.';

  @override
  String get grpHPause => 'إيقاف مؤقت';

  @override
  String get grpHPlay => 'تشغيل';

  @override
  String grpHTextTruncated(String size) {
    return 'يتم عرض أول $size. نزّل الملف لقراءة الباقي.';
  }

  @override
  String get grpHAttachments => 'المرفقات';

  @override
  String grpHAttachmentsCount(int count) {
    return 'المرفقات ($count)';
  }

  @override
  String get grpHCouldNotReadFile => 'تعذرت قراءة ذلك الملف.';

  @override
  String get grpHDismiss => 'إخفاء';

  @override
  String get grpHNoAttachments => 'لا توجد مرفقات.';

  @override
  String get grpHDropZoneLabel =>
      'إرفاق الملفات: أفلتها هنا أو انقر، ثم الصق صورة';

  @override
  String get grpHDropToAttach => 'أفلت للإرفاق';

  @override
  String get grpHDropFilesHere => 'أفلت الملفات هنا لإرفاقها';

  @override
  String get grpHSnoozeLaterToday => 'لاحقًا اليوم';

  @override
  String get grpHSnoozeTomorrow => 'غدًا';

  @override
  String get grpHSnoozeNextWeek => 'الأسبوع القادم';

  @override
  String get grpHMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get grpHNotificationSettings => 'إعدادات الإشعارات';

  @override
  String get grpHInbox => 'البريد الوارد';

  @override
  String grpHUnreadCount(int count) {
    return '$count غير مقروء';
  }

  @override
  String get grpHLoadMore => 'تحميل المزيد';

  @override
  String get grpHEmptyAll => 'لا شيء هنا. لقد اطلعت على كل شيء.';

  @override
  String get grpHEmptyUnread => 'لا توجد إشعارات غير مقروءة.';

  @override
  String get grpHEmptyMentions => 'لم يذكرك أحد.';

  @override
  String get grpHEmptyAssigned => 'لم يتم إسناد أي شيء إليك مؤخرًا.';

  @override
  String get grpHEmptySnoozed => 'لا شيء مؤجَّل.';

  @override
  String get grpHEmptyArchived => 'لا شيء مؤرشف.';

  @override
  String grpHDueDate(String date) {
    return 'الاستحقاق $date';
  }

  @override
  String grpHUnreadPrefix(String title) {
    return 'غير مقروء. $title';
  }

  @override
  String grpHMoreCount(int count) {
    return '+$count أخرى';
  }

  @override
  String get grpHMore => 'المزيد';

  @override
  String get grpHMarkUnread => 'تحديد كغير مقروء';

  @override
  String get grpHMarkRead => 'تحديد كمقروء';

  @override
  String get grpHStopSnoozing => 'إيقاف التأجيل';

  @override
  String get grpHSnoozeEllipsis => 'تأجيل…';

  @override
  String get grpHMoveToInbox => 'نقل إلى البريد الوارد';

  @override
  String get grpHPushTitle => 'احصل على تنبيه عندما يهم الأمر';

  @override
  String get grpHPushBody =>
      'يمكن لـ TaskForge عرض إشعار عند إسناد مهمة إليك أو ذكرك أو اقتراب موعد مهمة، حتى عندما يكون التطبيق في الخلفية. بعد ذلك سيطلب جهازك الإذن. أنت تختار أنواع الإشعارات التي تصلك، وتمنعها ساعات الهدوء من إيقاظك.';

  @override
  String get grpHNotNow => 'ليس الآن';

  @override
  String get grpHContinue => 'متابعة';

  @override
  String get grpHPickDateTime => 'اختيار التاريخ والوقت';

  @override
  String get grpHRepeatReadError => 'تعذرت قراءة كيفية تكرار هذا.';

  @override
  String get grpHRepeat => 'تكرار';

  @override
  String get grpHFirstOfSeries => 'الأول في سلسلة';

  @override
  String get grpHRepeatingTask => 'مهمة متكررة';

  @override
  String grpHSeriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة في هذه السلسلة',
      many: '$count مهمة في هذه السلسلة',
      few: '$count مهام في هذه السلسلة',
      two: 'مهمتان في هذه السلسلة',
      one: 'مهمة واحدة في هذه السلسلة',
      zero: 'لا مهام في هذه السلسلة',
    );
    return '$_temp0';
  }

  @override
  String get grpHRepeatPaused => 'متوقف مؤقتًا: لا يتم إنشاء مهام جديدة.';

  @override
  String grpHRepeatPausedBySystem(String reason) {
    return 'أوقفه النظام مؤقتًا: $reason';
  }

  @override
  String grpHRepeatNext(String dates) {
    return 'التالي: $dates';
  }

  @override
  String get grpHRepeatWaits => 'سيتم إنشاء التالية عند إكمال هذه.';

  @override
  String get grpHRepeatsTitle => 'هذه المهمة تتكرر';

  @override
  String grpHRepeatsBody(String summary) {
    return 'إنها قالب \"$summary\". يمكن للحذف إيقاف السلسلة، أو يمكن للسلسلة متابعة إنشاء مهام جديدة.';
  }

  @override
  String get grpHDeleteKeepRepeating => 'حذف مع متابعة التكرار';

  @override
  String get grpHDeleteAndStop => 'حذف وإيقاف';

  @override
  String get grpHChartGroup => 'المجموعة';

  @override
  String get grpHOfflineReview => 'مراجعة';

  @override
  String get grpHOfflineSyncing => 'جارٍ المزامنة…';

  @override
  String get grpHOfflineSyncNow => 'زامن الآن';

  @override
  String get grpHOfflineSaved =>
      'أنت غير متصل. يتم حفظ التغييرات على هذا الجهاز.';

  @override
  String grpHOfflineWaitsOnline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغيير في انتظار الإرسال.',
      many: '$count تغييرًا في انتظار الإرسال.',
      few: '$count تغييرات في انتظار الإرسال.',
      two: 'تغييران في انتظار الإرسال.',
      one: 'تغيير واحد في انتظار الإرسال.',
      zero: 'لا تغييرات في انتظار الإرسال.',
    );
    return '$_temp0';
  }

  @override
  String grpHOfflineWaitsOffline(int count) {
    return '$count في انتظار الإرسال.';
  }

  @override
  String grpHOfflineAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغيير يحتاج إلى انتباهك.',
      many: '$count تغييرًا يحتاج إلى انتباهك.',
      few: '$count تغييرات تحتاج إلى انتباهك.',
      two: 'تغييران يحتاجان إلى انتباهك.',
      one: 'تغيير واحد يحتاج إلى انتباهك.',
      zero: 'لا تغييرات تحتاج إلى انتباهك.',
    );
    return '$_temp0';
  }

  @override
  String get grpHReconnecting =>
      'جارٍ إعادة الاتصال… سيتم تحديث ما تراه بمجرد عودتك.';

  @override
  String get grpICancel => 'إلغاء';

  @override
  String get grpIDone => 'تم';

  @override
  String get grpIRetry => 'إعادة المحاولة';

  @override
  String get grpIClose => 'إغلاق';

  @override
  String get grpIBack => 'رجوع';

  @override
  String get grpIEdit => 'تعديل';

  @override
  String get grpISave => 'حفظ';

  @override
  String get grpISaving => 'جارٍ الحفظ…';

  @override
  String get grpIDelete => 'حذف';

  @override
  String get grpICopy => 'نسخ';

  @override
  String get grpIUndo => 'تراجع';

  @override
  String get grpIRestore => 'استعادة';

  @override
  String get grpIUnnamed => '(بدون اسم)';

  @override
  String grpIErrorRetry(String message) {
    return '$message إعادة المحاولة';
  }

  @override
  String get grpIMergeTitle => 'قام شخص آخر بحفظ سير العمل أولاً';

  @override
  String get grpIMergeBody =>
      'تم الاحتفاظ بتعديلاتك ولم يُستبدل عملهم. هذا ما تغيّر في مسودتك:';

  @override
  String get grpIMergeKeep => 'قرأت هذا، احتفظ بمسودتي';

  @override
  String get grpIMergeReload => 'تجاهل مسودتي';

  @override
  String get grpINoProblems => 'لا مشاكل';

  @override
  String get grpIEveryTaskValid => 'تحتفظ كل مهمة بحالة صالحة.';

  @override
  String grpIProblemsToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشكلة يجب إصلاحها قبل الحفظ',
      many: '$count مشكلة يجب إصلاحها قبل الحفظ',
      few: '$count مشكلات يجب إصلاحها قبل الحفظ',
      two: 'مشكلتان يجب إصلاحهما قبل الحفظ',
      one: 'مشكلة واحدة يجب إصلاحها قبل الحفظ',
      zero: 'لا مشكلات يجب إصلاحها قبل الحفظ',
    );
    return '$_temp0';
  }

  @override
  String get grpIAnyStatusMoves => 'يمكن نقل أي حالة إلى أي حالة أخرى.';

  @override
  String grpIWorkflowGraphLabel(int statuses, int moves) {
    return 'سير عمل بـ $statuses حالات و$moves انتقالات مسموحة';
  }

  @override
  String get grpINeedsAssignee => 'يحتاج إلى مكلّف';

  @override
  String get grpINeedsSubtasksDone => 'يحتاج إلى إنجاز كل المهام الفرعية';

  @override
  String grpIOnlyRoleLower(String role) {
    return '$role فقط';
  }

  @override
  String get grpIOneRole => 'دور واحد';

  @override
  String get grpIDragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String get grpIColour => 'اللون';

  @override
  String get grpINewTasksStartHere => 'تبدأ المهام الجديدة هنا';

  @override
  String get grpIMakeDefaultStatus => 'اجعل هذه الحالة بداية المهام الجديدة';

  @override
  String get grpIDeleteStatus => 'حذف الحالة';

  @override
  String grpITaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: '$count مهمة',
    );
    return '$_temp0';
  }

  @override
  String get grpICanMoveTo => 'يمكن النقل إلى';

  @override
  String get grpIConditionsForMove => 'شروط هذا الانتقال';

  @override
  String get grpIName => 'الاسم';

  @override
  String grpIDeleteStatusTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String grpITasksInStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة في هذه الحالة. اختر وجهتها.',
      many: '$count مهمة في هذه الحالة. اختر وجهتها.',
      few: '$count مهام في هذه الحالة. اختر وجهتها.',
      two: 'مهمتان في هذه الحالة. اختر وجهتهما.',
      one: 'مهمة واحدة في هذه الحالة. اختر وجهتها.',
      zero: 'لا مهام في هذه الحالة.',
    );
    return '$_temp0';
  }

  @override
  String get grpIMoveTasksTo => 'نقل المهام إلى';

  @override
  String get grpIMoveTasksAndDelete => 'نقل المهام والحذف';

  @override
  String get grpIWhoMayMove => 'من يستطيع إجراء هذا الانتقال';

  @override
  String get grpIAnyRole => 'أي دور';

  @override
  String grpIOnlyRole(String name) {
    return '$name فقط';
  }

  @override
  String get grpITaskNeedsAssignee => 'تحتاج المهمة إلى مكلّف';

  @override
  String get grpIAllSubtasksDone => 'يجب إنجاز كل المهام الفرعية';

  @override
  String get grpIDoneOrCancelledDepth => 'منجزة أو ملغاة، بأي عمق.';

  @override
  String get grpIWorkflow => 'سير العمل';

  @override
  String get grpIDiscard => 'تجاهل';

  @override
  String get grpIWorkflowSaved => 'تم حفظ سير العمل';

  @override
  String get grpIRestrictTransitions => 'تقييد الانتقالات';

  @override
  String get grpIRestrictTransitionsHint =>
      'متوقف: يمكن نقل أي حالة إلى أي حالة أخرى. قيد التشغيل: الأسهم التي تسمح بها فقط.';

  @override
  String get grpIRestrictCreation =>
      'تبدأ المهام الجديدة في الحالة الافتراضية فقط';

  @override
  String get grpIRestrictCreationHint =>
      'متوقف: يمكن إنشاء المهمة في أي حالة. قيد التشغيل: تبدأ في الحالة المميزة بنجمة وتصل إلى الباقي بنقلها.';

  @override
  String get grpIAddStatus => 'إضافة حالة';

  @override
  String get grpINewStatus => 'حالة جديدة';

  @override
  String get grpIMigrationNeedsPlace =>
      'المهام التي اخترت نقلها إلى هنا تحتاج إلى مكان جديد.';

  @override
  String grpIMoveArrow(String from, String to) {
    return '$from ← $to';
  }

  @override
  String grpIDeletedStillHasTasks(String name) {
    return 'تم حذف $name لكن لا تزال فيه مهام.';
  }

  @override
  String get grpIMoveItsTasksTo => 'نقل مهامها إلى';

  @override
  String grpIDrillTitle(String title, int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مهمة',
      many: 'مهمة',
      few: 'مهام',
      two: 'مهمة',
      one: 'مهمة',
      zero: 'مهمة',
    );
    return '$title · $count$more $_temp0';
  }

  @override
  String get grpINoTasks => 'لا توجد مهام.';

  @override
  String get grpIDrillTruncated =>
      'تم عرض المهام الأولى فقط؛ ضيّق عامل التصفية لرؤية الباقي.';

  @override
  String grpIDueOn(String date) {
    return 'الاستحقاق $date';
  }

  @override
  String get grpINothingToShow => 'لا شيء لعرضه بعد.';

  @override
  String get grpIRefresh => 'تحديث';

  @override
  String get grpIWidgetMenu => 'قائمة الأداة';

  @override
  String get grpIExportCsv => 'تصدير CSV';

  @override
  String get grpIRemove => 'إزالة';

  @override
  String get grpISaveToSeeNumbers => 'احفظ لعرض الأرقام.';

  @override
  String grpICsvTitle(String title) {
    return '$title (CSV)';
  }

  @override
  String get grpICsvCopied => 'تم نسخ CSV.';

  @override
  String get grpISaveAsFile => 'حفظ كملف';

  @override
  String grpILatestPoints(int limit) {
    return 'عرض آخر $limit نقطة؛ قصّر النطاق لرؤيتها كلها.';
  }

  @override
  String grpITopLimit(int limit) {
    return 'عرض أعلى $limit؛ ضيّق عامل التصفية لرؤية الباقي.';
  }

  @override
  String get grpIWidget => 'أداة';

  @override
  String get grpITitle => 'العنوان';

  @override
  String get grpIGroupBy => 'تجميع حسب';

  @override
  String get grpIFilterTfqlOptional => 'عامل التصفية (TFQL، اختياري)';

  @override
  String get grpIPreview => 'معاينة';

  @override
  String get grpIProject => 'المشروع';

  @override
  String get grpISprint => 'السبرنت';

  @override
  String grpIDateRange(String start, String end) {
    return '$start ← $end';
  }

  @override
  String grpIFromDate(String date) {
    return 'من $date';
  }

  @override
  String get grpINoDates => 'بلا تواريخ';

  @override
  String grpIDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: '$count يوم',
    );
    return '$_temp0';
  }

  @override
  String get grpINothingScheduled => 'لا شيء مجدول في هذا النطاق.';

  @override
  String get grpIOnCriticalPath => 'على المسار الحرج';

  @override
  String get grpIBlocked => 'محظورة';

  @override
  String grpIMovingPushes(String id, int count) {
    return 'نقل $id يدفع $count';
  }

  @override
  String grpIRangeShift(String from, String to) {
    return '$from  ←  $to';
  }

  @override
  String get grpIKeepThem => 'إبقاؤها (إظهار التعارض)';

  @override
  String get grpIShiftDependents => 'نقل التابعات';

  @override
  String get grpIWeekdayMon => 'الاثنين';

  @override
  String get grpIWeekdayTue => 'الثلاثاء';

  @override
  String get grpIWeekdayWed => 'الأربعاء';

  @override
  String get grpIWeekdayThu => 'الخميس';

  @override
  String get grpIWeekdayFri => 'الجمعة';

  @override
  String get grpIWeekdaySat => 'السبت';

  @override
  String get grpIWeekdaySun => 'الأحد';

  @override
  String get grpIWorkingDays => 'أيام العمل';

  @override
  String get grpIWorkingDaysHint => 'نقل مهمة بعد أخرى يتخطى أيام الإجازة.';

  @override
  String get grpIHolidays => 'العطل';

  @override
  String get grpIHolidaysHint => 'تواريخ مثل 2026-12-25، مفصولة بفواصل';

  @override
  String grpITimelineChartLabel(int count) {
    return 'مخطط زمني لـ $count مهام. انتقل إلى عرض القائمة لقراءتها.';
  }

  @override
  String get grpITimelineDragHint =>
      'اسحب شريطاً لنقله، أو طرفه لتغيير حجمه. Ctrl + العجلة أو القرص للتكبير.';

  @override
  String get grpIUnscheduled => 'غير مجدولة';

  @override
  String get grpIMovedLinksBreak =>
      'تم النقل. تظهر الروابط التي ينقطع بها باللون الأحمر.';

  @override
  String get grpITimelineSaved => 'تم حفظ الجدول الزمني.';

  @override
  String get grpIDay => 'يوم';

  @override
  String get grpIWeek => 'أسبوع';

  @override
  String get grpIMonth => 'شهر';

  @override
  String get grpIQuarter => 'ربع';

  @override
  String get grpITaskTree => 'شجرة المهام';

  @override
  String get grpIByAssignee => 'حسب المكلّف';

  @override
  String get grpIByStatus => 'حسب الحالة';

  @override
  String get grpIEarlier => 'أسبق';

  @override
  String get grpIToday => 'اليوم';

  @override
  String get grpILater => 'لاحقاً';

  @override
  String get grpICriticalPath => 'المسار الحرج';

  @override
  String get grpIHideDone => 'إخفاء المنجز';

  @override
  String get grpIShowChart => 'إظهار المخطط';

  @override
  String get grpIShowList => 'عرض كقائمة';

  @override
  String get grpIExportImage => 'تصدير كصورة';

  @override
  String get grpICurrency => 'العملة';

  @override
  String get grpIClear => 'مسح';

  @override
  String get grpINone => 'لا شيء';

  @override
  String grpIFieldArchived(String name) {
    return 'تمت أرشفة $name. تُحفظ القيم 30 يوماً.';
  }

  @override
  String get grpIFields => 'الحقول';

  @override
  String get grpIAddField => 'إضافة حقل';

  @override
  String get grpINoCustomFields =>
      'لا توجد حقول مخصصة بعد. أضف حقلاً لأشياء مثل العميل أو نقاط القصة.';

  @override
  String get grpIArchivedRestorable => 'مؤرشفة (قابلة للاستعادة لمدة 30 يوماً)';

  @override
  String get grpIRequired => 'مطلوب';

  @override
  String grpIOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خيار',
      many: '$count خيارًا',
      few: '$count خيارات',
      two: 'خياران',
      one: 'خيار واحد',
      zero: '$count خيار',
    );
    return '$_temp0';
  }

  @override
  String get grpIArchive => 'أرشفة';

  @override
  String get grpIWriteComment => 'اكتب تعليقاً… (@ للإشارة)';

  @override
  String get grpIComment => 'تعليق';

  @override
  String get grpIBulletList => 'قائمة نقطية';

  @override
  String get grpIQuote => 'اقتباس';

  @override
  String get grpICodeBlock => 'كتلة برمجية';

  @override
  String get grpILink => 'رابط';

  @override
  String get grpICouldNotReadFile => 'تعذّرت قراءة هذا الملف.';

  @override
  String get grpICtrlEnterToSend => 'Ctrl+Enter للإرسال';

  @override
  String get grpIDeleteCommentTitle => 'حذف هذا التعليق؟';

  @override
  String get grpIDeleteCommentBody =>
      'سيظهر كـ \"تمت إزالة التعليق\". يُحذف محتواه وسجل تعديلاته.';

  @override
  String get grpICannotSeeTask => 'لا يستطيعون رؤية هذه المهمة';

  @override
  String grpICannotSeeGrant(String names) {
    return 'لا يستطيع $names رؤية هذه المهمة. أضفهم إلى المشروع وأرسل التعليق، أو أزل الإشارة.';
  }

  @override
  String grpICannotSeeRefuse(String names) {
    return 'لا يستطيع $names رؤية هذه المهمة، لذلك لا يمكن الإشارة إليهم. أزل الإشارة، أو اطلب ممن يدير المشروع إضافتهم.';
  }

  @override
  String get grpIOk => 'موافق';

  @override
  String get grpIAddThemAndSend => 'إضافتهم والإرسال';

  @override
  String grpIEditHistory(String author) {
    return 'سجل التعديلات · $author';
  }

  @override
  String grpIRevisionCurrent(String stamp) {
    return '$stamp · الحالي';
  }

  @override
  String get grpISessions => 'الجلسات';

  @override
  String get grpISignOutOthers => 'تسجيل الخروج من الأجهزة الأخرى';

  @override
  String get grpIUnknownDevice => 'جهاز غير معروف';

  @override
  String get grpIThisDevice => 'هذا الجهاز';

  @override
  String get grpISignOutThis => 'تسجيل الخروج من هذا الجهاز';

  @override
  String get grpJLink => 'رابط';

  @override
  String get grpJInviteEmails => 'عناوين البريد الإلكتروني';

  @override
  String grpJInviteEmailsHelp(int max) {
    return 'افصل بين عدة عناوين بفواصل. حتى $max.';
  }

  @override
  String get grpJAdd => 'إضافة';

  @override
  String grpJInviteInvalidEmail(String email) {
    return '«$email» ليس عنوان بريد إلكتروني صالحًا.';
  }

  @override
  String grpJInviteTooMany(int max) {
    return 'يمكنك دعوة $max أشخاص كحد أقصى في المرة الواحدة.';
  }

  @override
  String get grpJInviteSendAll => 'إرسال الدعوات';

  @override
  String grpJInviteSendCount(int count) {
    return 'إرسال $count';
  }

  @override
  String grpJInvited(int count) {
    return 'تمت دعوة $count.';
  }

  @override
  String grpJInviteSkipped(String emails) {
    return 'أعضاء بالفعل، تم التخطي: $emails';
  }

  @override
  String get grpJExpiresAfter => 'تنتهي الصلاحية بعد';

  @override
  String grpJDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: '$count يوم',
    );
    return '$_temp0';
  }

  @override
  String get grpJMaxUses => 'أقصى عدد للاستخدام';

  @override
  String get grpJMaxUsesHelp => 'اتركه فارغًا لعدد غير محدود.';

  @override
  String grpJMaxUsesInvalid(int max) {
    return 'أدخل رقمًا من 1 إلى $max أو اتركه فارغًا.';
  }

  @override
  String get grpJCreateLink => 'إنشاء رابط';

  @override
  String get grpJCopyLink => 'نسخ الرابط';

  @override
  String get grpJRole => 'الدور';

  @override
  String get grpJInvitationTitle => 'الدعوة';

  @override
  String get grpJJoin => 'انضمام';

  @override
  String get grpJDecline => 'رفض';

  @override
  String get grpJGoToTaskForge => 'الانتقال إلى TaskForge';

  @override
  String get grpJInvitedToJoin => 'تمت دعوتك للانضمام';

  @override
  String grpJInviterInvitedYou(String name) {
    return 'دعاك $name للانضمام';
  }

  @override
  String get grpJBack => 'رجوع';

  @override
  String get grpJMembers => 'الأعضاء';

  @override
  String get grpJInvite => 'دعوة';

  @override
  String get grpJPending => 'قيد الانتظار';

  @override
  String grpJJoined(String date) {
    return 'انضم في $date';
  }

  @override
  String get grpJRemoveFromWorkspace => 'إزالة من مساحة العمل';

  @override
  String get grpJSearchMembers => 'البحث عن الأعضاء';

  @override
  String grpJRemoveMember(String name) {
    return 'إزالة $name';
  }

  @override
  String get grpJOwnerCannotLeave =>
      'أنت مالك مساحة العمل هذه، لذا لا يمكنك مغادرتها. لا يمكن نقل الملكية بعد.';

  @override
  String get grpJLeaveWorkspace => 'مغادرة مساحة العمل';

  @override
  String grpJRemoveMemberTitle(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get grpJRemoveMemberBody =>
      'سيفقدون الوصول إلى مساحة العمل هذه. يمكنك دعوتهم مجددًا لاحقًا.';

  @override
  String get grpJRemove => 'إزالة';

  @override
  String grpJLeaveTitle(String name) {
    return 'مغادرة $name؟';
  }

  @override
  String get grpJLeaveBody =>
      'ستفقد الوصول إلى مساحة العمل هذه حتى يدعوك أحد مجددًا.';

  @override
  String get grpJLeave => 'مغادرة';

  @override
  String grpJErrorRetry(String error) {
    return '$error إعادة المحاولة';
  }

  @override
  String get grpJLinkCopied => 'تم نسخ الرابط.';

  @override
  String get grpJNoInvitations => 'لا توجد دعوات بعد.';

  @override
  String get grpJInvitationResent => 'تمت إعادة إرسال الدعوة.';

  @override
  String get grpJResend => 'إعادة الإرسال';

  @override
  String get grpJRevoke => 'إلغاء';

  @override
  String get grpJStatePending => 'قيد الانتظار';

  @override
  String get grpJStateExpired => 'منتهية';

  @override
  String get grpJStateRevoked => 'ملغاة';

  @override
  String get grpJStateUsedUp => 'مستنفدة';

  @override
  String grpJUsesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count استخدام',
      many: '$count استخدامًا',
      few: '$count استخدامات',
      two: 'استخدامان',
      one: 'استخدام واحد',
      zero: '$count استخدام',
    );
    return '$_temp0';
  }

  @override
  String grpJUsesOfMax(int uses, int max) {
    return '$uses/$max استخدام';
  }

  @override
  String get grpJInviteLink => 'رابط الدعوة';

  @override
  String grpJInvitationMeta(String name, String date) {
    return 'بواسطة $name · تنتهي $date';
  }

  @override
  String get grpJChangeRole => 'تغيير الدور';

  @override
  String get grpJBlockOptions => 'خيارات الكتلة';

  @override
  String get grpJMoveUp => 'نقل لأعلى';

  @override
  String get grpJMoveDown => 'نقل لأسفل';

  @override
  String get grpJAddBlockBelow => 'إضافة كتلة أسفله';

  @override
  String get grpJDelete => 'حذف';

  @override
  String grpJTurnInto(String label) {
    return 'تحويل إلى $label';
  }

  @override
  String get grpJClickToWrite => 'انقر هنا لبدء الكتابة';

  @override
  String get grpJAddBlock => 'إضافة كتلة';

  @override
  String get grpJDocs => 'المستندات';

  @override
  String get grpJPickPage => 'اختر صفحة أو أنشئ واحدة.';

  @override
  String get grpJNoMatchingBlocks => 'لا توجد كتل مطابقة';

  @override
  String get grpJNoMatchingPages => 'لا توجد صفحات مطابقة';

  @override
  String get grpJTableRow => 'صف';

  @override
  String get grpJTableColumn => 'عمود';

  @override
  String get grpJNoImageAddress => 'لا يوجد عنوان للصورة بعد';

  @override
  String get grpJImageLoadFailed => 'تعذر تحميل الصورة';

  @override
  String get grpJEditImage => 'تعديل الصورة';

  @override
  String get grpJLoadingTask => 'جارٍ تحميل المهمة...';

  @override
  String get grpJNoAccessTask => 'لا يمكنك الوصول إلى هذه المهمة';

  @override
  String grpJUnknownBlock(String type) {
    return 'تحتاج هذه الكتلة ($type) إلى إصدار أحدث من TaskForge. تم الاحتفاظ بها كما هي.';
  }

  @override
  String get grpJLinkAPage => 'ربط صفحة';

  @override
  String get grpJNoPagesYetLong => 'لا توجد صفحات بعد.';

  @override
  String get grpJRelatedDocs => 'المستندات ذات الصلة';

  @override
  String get grpJNoPagesYet => 'لا توجد صفحات بعد.';

  @override
  String get grpJLinked => 'مرتبطة';

  @override
  String get grpJEmbedded => 'مضمّنة';

  @override
  String get grpJUnlink => 'إلغاء الربط';

  @override
  String grpJChangeTone(String tone) {
    return 'تغيير النبرة ($tone)';
  }

  @override
  String get grpJBold => 'غامق';

  @override
  String get grpJItalic => 'مائل';

  @override
  String get grpJStrikethrough => 'يتوسطه خط';

  @override
  String get grpJCode => 'رمز';

  @override
  String get grpJHintParagraph => 'اكتب \'/\' للكتل أو \'[[\' للإشارة إلى صفحة';

  @override
  String grpJHintHeading(int level) {
    return 'عنوان $level';
  }

  @override
  String get grpJCodeLanguageHint => 'اللغة';

  @override
  String get grpJUndo => 'تراجع';

  @override
  String get grpJRestore => 'استعادة';

  @override
  String get grpJName => 'الاسم';

  @override
  String grpJWorkspaceDeleted(String name) {
    return 'تم حذف «$name». يمكن استعادته لمدة 7 أيام.';
  }

  @override
  String get grpJDangerZone => 'منطقة الخطر';

  @override
  String get grpJDangerZoneBody =>
      'يؤدي حذف مساحة العمل إلى إخفائها عن الجميع. يمكنك استعادتها خلال 7 أيام.';

  @override
  String get grpJDeleteWorkspace => 'حذف مساحة العمل';

  @override
  String get grpJDeleteWorkspaceQ => 'حذف مساحة العمل؟';

  @override
  String grpJTypeNameToConfirm(String name) {
    return 'اكتب «$name» للتأكيد';
  }

  @override
  String get grpJNewWorkspace => 'مساحة عمل جديدة';

  @override
  String get grpJCreateYourWorkspace => 'أنشئ مساحة عملك';

  @override
  String get grpJWorkspaceHolds => 'تحتوي مساحة العمل على مشاريع فريقك ومهامه.';

  @override
  String get grpJUrl => 'عنوان URL';

  @override
  String get grpJCreateWorkspace => 'إنشاء مساحة عمل';

  @override
  String get grpJRecentlyDeleted => 'المحذوفة مؤخرًا';

  @override
  String get grpJSwitchWorkspace => 'تبديل مساحة العمل';

  @override
  String get grpJTimerRunning => 'المؤقت قيد التشغيل';

  @override
  String grpJTimerStoppedOn(String key, String title) {
    return 'تم إيقاف المؤقت على $key $title';
  }

  @override
  String get grpJTime => 'الوقت';

  @override
  String get grpJStop => 'إيقاف';

  @override
  String get grpJStartTimer => 'بدء المؤقت';

  @override
  String get grpJAddTime => 'إضافة وقت';

  @override
  String grpJTimeOfEstimate(String logged, String estimate) {
    return '$logged من $estimate';
  }

  @override
  String grpJTimeLogged(String logged) {
    return 'تم تسجيل $logged';
  }

  @override
  String grpJTimeBillable(String duration) {
    return '$duration قابل للفوترة';
  }

  @override
  String get grpJChangeEstimate => 'تغيير التقدير';

  @override
  String get grpJSetEstimate => 'تحديد التقدير';

  @override
  String get grpJRunning => 'قيد التشغيل';

  @override
  String get grpJLoggedLabel => 'مسجّل';

  @override
  String get grpJYou => 'أنت';

  @override
  String get grpJBillableSuffix => 'قابل للفوترة';

  @override
  String get grpJOverlapsEntry => 'يتداخل مع إدخال آخر';

  @override
  String get grpJOver24h => 'أكثر من 24 ساعة: تحقق منه';

  @override
  String get grpJEdit => 'تعديل';

  @override
  String get grpJStopTheTimer => 'إيقاف المؤقت';

  @override
  String get grpJRoleActions => 'إجراءات الدور';

  @override
  String get grpJRename => 'إعادة التسمية';

  @override
  String get grpJBuiltInReadOnly => 'مدمج، للقراءة فقط';

  @override
  String get grpJRolesAndPermissions => 'الأدوار والأذونات';

  @override
  String get grpJNewRole => 'دور جديد';

  @override
  String get grpJActivity => 'النشاط';

  @override
  String get grpJNoActivity => 'لا يوجد نشاط بعد.';

  @override
  String get grpJDebugTitle => 'TaskForge — الاتصال';

  @override
  String grpJPingLabel(String label) {
    return 'اختبار $label';
  }

  @override
  String grpJPingError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get grpKClosePalette => 'إغلاق لوحة الأوامر';

  @override
  String get grpKGroupGeneral => 'عام';

  @override
  String get grpKGroupGoTo => 'الانتقال إلى';

  @override
  String get grpKGroupProjects => 'المشاريع';

  @override
  String get grpKGroupWorkspace => 'مساحة العمل';

  @override
  String get grpKGroupAccount => 'الحساب';

  @override
  String get grpKGroupThisProject => 'هذا المشروع';

  @override
  String get grpKGroupDocs => 'المستندات';

  @override
  String get grpKGroupDashboards => 'لوحات المعلومات';

  @override
  String get grpKGroupListView => 'عرض القائمة';

  @override
  String get grpKGroupThisTask => 'هذه المهمة';

  @override
  String grpKGoTo(String title) {
    return 'الانتقال إلى $title';
  }

  @override
  String grpKProjectPageOf(String title) {
    return '$title لهذا المشروع';
  }

  @override
  String get grpKPaletteOpen => 'فتح لوحة الأوامر';

  @override
  String get grpKSearch => 'بحث';

  @override
  String get grpKSearchSem => 'البحث في المهام والتعليقات والمشاريع والأشخاص';

  @override
  String get grpKShortcuts => 'اختصارات لوحة المفاتيح';

  @override
  String get grpKShortcutsSem => 'عرض اختصارات لوحة المفاتيح';

  @override
  String get grpKTHome => 'الرئيسية';

  @override
  String get grpKTInbox => 'صندوق الوارد';

  @override
  String get grpKTCalendar => 'تقويم مساحة العمل';

  @override
  String get grpKTDocs => 'المستندات';

  @override
  String get grpKTDashboards => 'لوحات المعلومات';

  @override
  String get grpKTTimesheet => 'سجل الوقت';

  @override
  String get grpKTMembers => 'الأعضاء';

  @override
  String get grpKTArchivedProjects => 'المشاريع المؤرشفة';

  @override
  String get grpKTPrivateProjects => 'المشاريع الخاصة';

  @override
  String get grpKTWorkspaceSettings => 'إعدادات مساحة العمل';

  @override
  String get grpKAuditLog => 'سجل التدقيق';

  @override
  String get grpKAuditSem => 'الانتقال إلى سجل التدقيق';

  @override
  String get grpKTRoles => 'الأدوار والأذونات';

  @override
  String get grpKTCreateWorkspace => 'إنشاء مساحة عمل';

  @override
  String get grpKTNotifPrefs => 'تفضيلات الإشعارات';

  @override
  String get grpKTDevices => 'الأجهزة المسجّل دخولها';

  @override
  String get grpKTChangePassword => 'تغيير كلمة المرور';

  @override
  String get grpKTTasks => 'المهام';

  @override
  String get grpKTSprints => 'السبرنتات';

  @override
  String get grpKTAutomations => 'الأتمتة';

  @override
  String get grpKTWorkflow => 'سير العمل';

  @override
  String get grpKTCustomFields => 'حقول مخصصة';

  @override
  String get grpKTProjectSettings => 'إعدادات المشروع';

  @override
  String get grpKSwitchWs => 'تبديل مساحة العمل';

  @override
  String get grpKSwitchWsSem => 'التبديل إلى مساحة عمل أخرى';

  @override
  String get grpKToggleDark => 'تبديل الوضع الداكن';

  @override
  String get grpKToggleDarkSem => 'التبديل بين السمة الفاتحة والداكنة';

  @override
  String get grpKCreateProject => 'إنشاء مشروع';

  @override
  String get grpKCreateDoc => 'إنشاء مستند';

  @override
  String get grpKCreateDashboard => 'إنشاء لوحة معلومات';

  @override
  String get grpKCreateSprint => 'إنشاء سبرنت';

  @override
  String get grpKCreateSprintSem => 'إنشاء سبرنت في هذا المشروع';

  @override
  String get grpKInviteMember => 'دعوة عضو';

  @override
  String get grpKInviteMemberSem => 'دعوة شخص إلى مساحة العمل هذه';

  @override
  String get grpKTImportExport => 'الاستيراد والتصدير';

  @override
  String get grpKTOffline => 'دون اتصال والتخزين';

  @override
  String get grpKSignOut => 'تسجيل الخروج';

  @override
  String get grpKSignOutSem => 'تسجيل الخروج من هذا الجهاز';

  @override
  String get grpKNewTask => 'مهمة جديدة';

  @override
  String get grpKNewTaskSem => 'إنشاء مهمة في هذا المشروع';

  @override
  String get grpKRenameTask => 'إعادة تسمية المهمة تحت المؤشر';

  @override
  String get grpKRenameTaskSem =>
      'إعادة تسمية المهمة التي عليها المؤشر في القائمة';

  @override
  String get grpKChangeStatus => 'تغيير حالة هذه المهمة';

  @override
  String get grpKChangeStatusSem => 'تغيير حالة المهمة المفتوحة';

  @override
  String get grpKAssignMe => 'إسناد هذه المهمة إليّ';

  @override
  String get grpKAssignMeSem => 'إسناد المهمة المفتوحة إليّ';

  @override
  String get grpKTimerStart => 'بدء المؤقت لهذه المهمة';

  @override
  String get grpKTimerStartSem => 'بدء المؤقت للمهمة المفتوحة';

  @override
  String get grpKTimerStop => 'إيقاف المؤقت';

  @override
  String get grpKTimerStopSem => 'إيقاف المؤقت الجاري';

  @override
  String get grpKViewList => 'عرض القائمة';

  @override
  String get grpKViewBoard => 'عرض اللوحة';

  @override
  String get grpKViewCalendar => 'عرض التقويم';

  @override
  String get grpKViewTimeline => 'عرض الجدول الزمني';

  @override
  String get grpKShowList => 'عرض هذا المشروع كقائمة';

  @override
  String get grpKShowBoard => 'عرض هذا المشروع كلوحة';

  @override
  String get grpKShowCalendar => 'عرض هذا المشروع كتقويم';

  @override
  String get grpKShowTimeline => 'عرض هذا المشروع كجدول زمني';

  @override
  String get grpLGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get grpLNetCheck =>
      'تعذر الوصول إلى الخادم. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get grpLNetCheckShort => 'تعذر الوصول إلى الخادم. تحقق من اتصالك.';

  @override
  String get grpLNetTry => 'تعذر الوصول إلى الخادم. حاول مرة أخرى.';

  @override
  String get grpLNetOffline =>
      'يحتاج هذا إلى اتصال بالخادم. سيعمل مجددًا عند عودتك إلى الإنترنت.';

  @override
  String get grpLNoConn => 'لا يوجد اتصال. تحقق منه وحاول مرة أخرى.';

  @override
  String get grpLNoPerm => 'ليس لديك إذن.';

  @override
  String get grpLNoPermDo => 'ليس لديك إذن للقيام بذلك.';

  @override
  String get grpLNoAccess => 'ليس لديك صلاحية الوصول إلى ذلك.';

  @override
  String get grpLCheckValues => 'تحقق من القيم وحاول مرة أخرى.';

  @override
  String get grpLNotValid => 'هذا غير صالح.';

  @override
  String get grpLArchived => 'هذا المشروع مؤرشف. استعده لإجراء تغييرات.';

  @override
  String get grpLGone => 'لم يعد هذا موجودًا.';

  @override
  String get grpLTaskConflict => 'قام شخص آخر بتغيير هذه المهمة أولاً.';

  @override
  String get grpLTaskTransition => 'لا يسمح سير العمل بهذا الانتقال.';

  @override
  String get grpLTaskHasSubtasks =>
      'لهذه المهمة مهام فرعية: اختر ما سيحدث لها.';

  @override
  String get grpLTaskCycle =>
      'لا يمكن أن تصبح المهمة مهمة فرعية لنفسها أو لإحدى مهامها الفرعية.';

  @override
  String grpLTaskBlocked(String detail) {
    return 'محظورة بسبب $detail: أنهِ تلك أولاً.';
  }

  @override
  String grpLTaskLinkCycle(String detail) {
    return 'ستحظر هذه المهام بعضها بعضًا في حلقة: $detail.';
  }

  @override
  String get grpLTaskLinkExists => 'هذه المهام مرتبطة بالفعل بهذه الطريقة.';

  @override
  String get grpLFieldRequired => 'حقل مطلوب بلا قيمة.';

  @override
  String get grpLTaskGone => 'لم تعد هذه المهمة موجودة.';

  @override
  String get grpLCommentConflict => 'قام شخص ما بتغيير هذا التعليق أولاً.';

  @override
  String get grpLCommentLocked => 'لم يعد بالإمكان تعديل هذا التعليق.';

  @override
  String get grpLMentionNoAccess => 'شخص ذكرته لا يستطيع رؤية هذه المهمة.';

  @override
  String get grpLCommentCheck => 'تحقق من التعليق وحاول مرة أخرى.';

  @override
  String get grpLCommentGone => 'لم يعد هذا التعليق موجودًا.';

  @override
  String get grpLSlugTaken => 'هذا العنوان مستخدم';

  @override
  String get grpLWsStale =>
      'تم تغيير مساحة العمل هذه في مكان آخر. حدّث الصفحة لرؤية أحدث نسخة.';

  @override
  String get grpLWsNotRestorable => 'لم يعد بالإمكان استعادة مساحة العمل هذه.';

  @override
  String get grpLOwnerNeeded => 'تحتاج مساحة العمل إلى مالك واحد على الأقل.';

  @override
  String get grpLInvEmailMismatch =>
      'هذه الدعوة موجهة إلى عنوان بريد إلكتروني آخر.';

  @override
  String get grpLInvExpired => 'انتهت صلاحية هذه الدعوة. اطلب دعوة جديدة.';

  @override
  String get grpLInvRevoked => 'تم إلغاء هذه الدعوة.';

  @override
  String get grpLInvBeforeRemoval =>
      'هذه الدعوة سابقة لإزالتك. اطلب دعوة جديدة.';

  @override
  String get grpLInvUsedUp => 'تم استخدام هذه الدعوة بالكامل بالفعل.';

  @override
  String get grpLInvNotFound => 'هذه الدعوة غير موجودة.';

  @override
  String get grpLInvRate =>
      'دعوات كثيرة جدًا الآن. انتظر قليلًا وحاول مرة أخرى.';

  @override
  String get grpLInvExists => 'هذا الشخص مدعو بالفعل أو عضو.';

  @override
  String get grpLWfInvalid => 'سير العمل فيه مشكلات. أصلحها للحفظ.';

  @override
  String get grpLWfConflict =>
      'حفظ شخص آخر سير العمل أولاً. تغييراتك ما زالت هنا: راجع ما تغيّر واحفظ مرة أخرى.';

  @override
  String get grpLProjectGone => 'لم يعد هذا المشروع موجودًا.';

  @override
  String get grpLDashDenied => 'غير مسموح لك بفعل ذلك في لوحة المعلومات هذه.';

  @override
  String get grpLDashNotFound => 'لوحة المعلومات أو الأداة هذه غير متاحة.';

  @override
  String get grpLDashHeavy =>
      'تستغرق هذه الأداة وقتًا طويلًا في الحساب. ضيّق عامل التصفية الخاص بها.';

  @override
  String get grpLDashConflict =>
      'قام شخص آخر بتغيير لوحة المعلومات هذه. أعد تحميلها وحاول مرة أخرى.';

  @override
  String get grpLNotifGone => 'لم يعد هذا الإشعار موجودًا.';

  @override
  String get grpLViewConflict => 'قام شخص آخر بتغيير هذا التخطيط أولاً.';

  @override
  String get grpLViewInvalid => 'هذا التخطيط غير صالح.';

  @override
  String get grpLViewNameTaken => 'يوجد تخطيط بهذا الاسم بالفعل.';

  @override
  String get grpLViewLimit =>
      'هذا أقصى عدد من التخطيطات يمكنك الاحتفاظ به هنا.';

  @override
  String get grpLViewGone => 'لم يعد هذا التخطيط موجودًا.';

  @override
  String get grpLAutoDenied => 'تحتاج إلى إذن «إدارة الأتمتة» لذلك.';

  @override
  String get grpLAutoConflict =>
      'قام شخص آخر بتغيير هذه القاعدة أولاً. حمّل أحدث نسخة وأعد المحاولة.';

  @override
  String get grpLImpCannot => 'لا يمكن القيام بذلك الآن.';

  @override
  String get grpLImpTooBig => 'هذا الملف أكبر مما يقبله هذا الخادم.';

  @override
  String get grpLImpDenied => 'يستطيع المسؤولون فقط استيراد البيانات وتصديرها.';

  @override
  String get grpLImpNotFound => 'لم يعد هذا الاستيراد موجودًا.';

  @override
  String get grpLAuditDenied => 'غير مسموح لك بقراءة سجل التدقيق.';

  @override
  String get grpLAuditTaskNA => 'هذه المهمة غير متاحة.';

  @override
  String get grpLAuditFilters => 'عوامل التصفية هذه غير صالحة.';

  @override
  String get grpLSprintConflict =>
      'قام شخص آخر بتغيير هذا أولاً. أعد التحميل وحاول مرة أخرى.';

  @override
  String get grpLFieldNameTaken => 'يوجد حقل بهذا الاسم بالفعل.';

  @override
  String grpLFieldLimit(int count) {
    return 'يمكن أن يحتوي المشروع على $count حقلًا نشطًا كحد أقصى.';
  }

  @override
  String get grpLFieldNeedsRemap =>
      'بعض الخيارات المحذوفة لا تزال مستخدمة: اختر ما ستصبح عليه قيمها.';

  @override
  String get grpLFieldConflict =>
      'قام شخص آخر بتغيير هذا الحقل أولاً؛ أعد التحميل وحاول مرة أخرى.';

  @override
  String get grpLFieldGone => 'لم يعد هذا الحقل موجودًا.';

  @override
  String get grpLFilterInvalid => 'عامل التصفية هذا غير صالح.';

  @override
  String get grpLFilterNameTaken => 'يوجد عامل تصفية بهذا الاسم هنا بالفعل.';

  @override
  String get grpLFilterLimit =>
      'هذا أقصى عدد من عوامل التصفية يمكنك الاحتفاظ به هنا.';

  @override
  String get grpLFilterGone => 'لم يعد عامل التصفية هذا موجودًا.';

  @override
  String get grpLFilterConflict => 'قام شخص آخر بتغيير عامل التصفية هذا أولاً.';

  @override
  String get grpLAttTooBig => 'هذا الملف أكبر من الحجم المسموح للمرفق.';

  @override
  String get grpLAttQuota => 'استخدمت مساحة العمل هذه كل مساحة التخزين.';

  @override
  String get grpLAttTooMany =>
      'هناك عمليات رفع مفتوحة كثيرة. أنهِ بعضها أو ألغِه أولاً.';

  @override
  String get grpLAttUnavailable => 'تعذر فحص الملف الآن. حاول مرة أخرى.';

  @override
  String get grpLAttChunk => 'لم يتم قبول جزء من الملف. حاول مرة أخرى.';

  @override
  String get grpLAttRefusedPlain => 'هذا النوع من الملفات غير مقبول.';

  @override
  String grpLAttRefused(String detail) {
    return 'هذا الملف غير مقبول: $detail';
  }

  @override
  String get grpLAttIncomplete => 'لم يكتمل الرفع. حاول مرة أخرى.';

  @override
  String get grpLAttExpired => 'انتهت صلاحية عملية الرفع. حاول مرة أخرى.';

  @override
  String get grpLAttUnreadable => 'تعذرت قراءة هذا الملف.';

  @override
  String get grpLAttNotAllowed => 'غير مسموح لك بفعل ذلك.';

  @override
  String get grpLAttArchived => 'هذا المشروع مؤرشف: الملفات للقراءة فقط.';

  @override
  String get grpLAttGone =>
      'لم يعد موجودًا: تمت إزالة الملف أو التعليق أو المهمة.';

  @override
  String get grpLDocNotFound => 'هذه الصفحة غير موجودة أو لا يمكنك فتحها.';

  @override
  String get grpLDocConflict => 'قام شخص آخر بتغيير هذه الصفحة أولاً.';

  @override
  String get grpLDocArchived => 'هذه الصفحة مؤرشفة.';

  @override
  String get grpLDocCycle => 'لا يمكن وضع صفحة تحت نفسها.';

  @override
  String get grpLKeyTaken => 'هذا المفتاح مستخدم بالفعل في مشروع آخر.';

  @override
  String get grpLKeyLocked =>
      'لا يمكن تغيير المفتاح بعد أن يحتوي المشروع على مهام.';

  @override
  String get grpLLastMember => 'يحتاج المشروع الخاص إلى عضو واحد على الأقل.';

  @override
  String get grpLProjConflict =>
      'تغيّر هذا المشروع في هذه الأثناء. تمت إعادة التحميل — حاول مرة أخرى.';

  @override
  String get grpLRoleBuiltin => 'لا يمكن تغيير الأدوار المضمنة أو حذفها.';

  @override
  String get grpLRoleNameTaken => 'يوجد دور بهذا الاسم بالفعل.';

  @override
  String get grpLRoleGone => 'لم يعد هذا الدور موجودًا.';

  @override
  String get grpLRoleConflict =>
      'تغيّر هذا الدور في هذه الأثناء. تمت إعادة التحميل — حاول مرة أخرى.';

  @override
  String get grpLRepeatInvalid => 'هذا التكرار غير صالح.';

  @override
  String get grpLRepeatDenied => 'غير مسموح لك بتغيير طريقة تكرار هذا.';

  @override
  String get grpMPriUrgent => 'عاجل';

  @override
  String get grpMPriHigh => 'مرتفع';

  @override
  String get grpMPriNormal => 'عادي';

  @override
  String get grpMPriLow => 'منخفض';

  @override
  String get grpMPriNone => 'بدون';

  @override
  String get grpMLinkBlocks => 'يحجب';

  @override
  String get grpMLinkBlockedBy => 'محجوب بواسطة';

  @override
  String get grpMLinkRelates => 'مرتبط بـ';

  @override
  String get grpMLinkDuplicates => 'يكرّر';

  @override
  String get grpMLinkDuplicatedBy => 'مكرَّر بواسطة';

  @override
  String get grpMCatNotStarted => 'لم يبدأ';

  @override
  String get grpMCatActive => 'نشط';

  @override
  String get grpMCatDone => 'مكتمل';

  @override
  String get grpMCatCancelled => 'ملغى';

  @override
  String get grpMFtypeText => 'نص';

  @override
  String get grpMFtypeNumber => 'رقم';

  @override
  String get grpMFtypeSelect => 'اختيار';

  @override
  String get grpMFtypeMulti => 'متعدد الاختيار';

  @override
  String get grpMFtypeDate => 'تاريخ';

  @override
  String get grpMFtypeCheckbox => 'خانة اختيار';

  @override
  String get grpMFtypeUrl => 'رابط';

  @override
  String get grpMFtypeUser => 'مستخدم';

  @override
  String get grpMFtypeMoney => 'مال';

  @override
  String get grpMTrigTaskCreated => 'تم إنشاء مهمة';

  @override
  String get grpMTrigStatusChanged => 'تغيّرت حالة';

  @override
  String get grpMTrigFieldChanged => 'تغيّر حقل';

  @override
  String get grpMTrigAssigned => 'تم تكليف شخص';

  @override
  String get grpMTrigDueDateReached => 'حان موعد استحقاق';

  @override
  String get grpMTrigCommentAdded => 'أُضيف تعليق';

  @override
  String get grpMActSetField => 'تعيين حقل';

  @override
  String get grpMActSetStatus => 'تعيين الحالة';

  @override
  String get grpMActSetAssignee => 'تغيير المكلّفين';

  @override
  String get grpMActAddComment => 'إضافة تعليق';

  @override
  String get grpMActCreateSubtask => 'إنشاء مهمة فرعية';

  @override
  String get grpMActNotify => 'إشعار الأشخاص';

  @override
  String get grpMActWebhook => 'استدعاء webhook';

  @override
  String get grpMRunSucceeded => 'نجح';

  @override
  String get grpMRunFailed => 'فشل';

  @override
  String get grpMRunSkippedCondition => 'تم التخطي: الشرط';

  @override
  String get grpMRunSkippedLoop => 'توقف: حلقة';

  @override
  String get grpMRunSkippedRate => 'متوقف: تشغيلات كثيرة';

  @override
  String get grpMWkNumber => 'رقم';

  @override
  String get grpMWkBar => 'مخطط شريطي';

  @override
  String get grpMWkLine => 'مخطط خطي';

  @override
  String get grpMWkPie => 'مخطط دائري';

  @override
  String get grpMWkTable => 'جدول';

  @override
  String get grpMWkBurndown => 'المخطط التنازلي';

  @override
  String get grpMWkWorkload => 'عبء العمل';

  @override
  String get grpMMeasCount => 'عدد المهام';

  @override
  String get grpMMeasPoints => 'نقاط القصة';

  @override
  String get grpMMeasEstimateHours => 'الساعات المقدَّرة';

  @override
  String get grpMMeasLoggedHours => 'الساعات المسجّلة';

  @override
  String get grpMMeasCycleDays => 'زمن الدورة (أيام)';

  @override
  String get grpMScopeAll => 'كل المهام';

  @override
  String get grpMScopeOpen => 'المهام المفتوحة';

  @override
  String get grpMScopeDone => 'المهام المنجزة';

  @override
  String get grpMVisPersonal => 'أنا فقط';

  @override
  String get grpMVisProject => 'الجميع في المشروع';

  @override
  String get grpMVisWorkspace => 'الجميع في مساحة العمل';

  @override
  String get grpMLblStatus => 'الحالة';

  @override
  String get grpMLblStatusCategory => 'فئة الحالة';

  @override
  String get grpMLblPerson => 'الشخص';

  @override
  String get grpMLblPriority => 'الأولوية';

  @override
  String get grpMLblProject => 'المشروع';

  @override
  String get grpMLblSprint => 'السبرنت';

  @override
  String get grpMLblCreatedDay => 'الإنشاء (يوم)';

  @override
  String get grpMLblCreatedWeek => 'الإنشاء (أسبوع)';

  @override
  String get grpMLblDueWeek => 'الاستحقاق (أسبوع)';

  @override
  String get grpMImpJiraCsv => 'Jira (تصدير CSV)';

  @override
  String get grpMImpJiraJson => 'Jira (JSON)';

  @override
  String get grpMImpClickupCsv => 'ClickUp (تصدير CSV)';

  @override
  String get grpMImpClickupJson => 'ClickUp (JSON)';

  @override
  String get grpMImpCsv => 'أي ملف CSV';

  @override
  String get grpMImpTaskforge => 'تصدير TaskForge (tasks.json)';

  @override
  String get grpMNkAssigned => 'مُكلَّف إليك';

  @override
  String get grpMNkMentioned => 'الإشارات';

  @override
  String get grpMNkCommented => 'التعليقات';

  @override
  String get grpMNkStatusChanged => 'تغييرات الحالة';

  @override
  String get grpMNkDueSoon => 'موعدها قريب';

  @override
  String get grpMNkTimerLong => 'مؤقّتات طويلة';

  @override
  String get grpMNkUnknown => 'إشعار';

  @override
  String get grpMIfAll => 'الكل';

  @override
  String get grpMIfUnread => 'غير المقروءة';

  @override
  String get grpMIfMentions => 'الإشارات';

  @override
  String get grpMIfAssigned => 'المُكلَّف بها';

  @override
  String get grpMIfSnoozed => 'المؤجَّلة';

  @override
  String get grpMIfArchived => 'المؤرشفة';

  @override
  String get grpMEmOff => 'متوقف';

  @override
  String get grpMEmInstant => 'فوري';

  @override
  String get grpMEmDigest => 'ملخص يومي';

  @override
  String get grpMRkSchedule => 'وفق جدول';

  @override
  String get grpMRkAfterCompletion => 'بعد اكتماله';

  @override
  String get grpMLblOpEq => 'يساوي';

  @override
  String get grpMLblOpNe => 'لا يساوي';

  @override
  String get grpMLblOpLt => 'قبل / أقل من';

  @override
  String get grpMLblOpLte => 'في أو قبل / على الأكثر';

  @override
  String get grpMLblOpGt => 'بعد / أكثر من';

  @override
  String get grpMLblOpGte => 'في أو بعد / على الأقل';

  @override
  String get grpMLblOpContains => 'يحتوي على';

  @override
  String get grpMLblOpNotContains => 'لا يحتوي على';

  @override
  String get grpMLblOpIn => 'هو أحد';

  @override
  String get grpMLblOpNotIn => 'ليس أيًّا من';

  @override
  String get grpMLblOpEmpty => 'فارغ';

  @override
  String get grpMLblOpNotEmpty => 'غير فارغ';

  @override
  String get grpMLblAssignee => 'المكلَّف';

  @override
  String get grpMLblStart => 'البداية';

  @override
  String get grpMLblDue => 'الاستحقاق';

  @override
  String get grpMLblCreated => 'الإنشاء';

  @override
  String get grpMLblUpdated => 'التحديث';

  @override
  String get grpMLblDueDate => 'تاريخ الاستحقاق';

  @override
  String get grpMLblProgress => 'تقدّم المهام الفرعية';

  @override
  String get grpMLblViewList => 'قائمة';

  @override
  String get grpMLblViewBoard => 'لوحة';

  @override
  String get grpMLblViewCalendar => 'التقويم';

  @override
  String get grpMLblViewTimeline => 'الجدول الزمني';

  @override
  String get grpMRelNow => 'الآن';

  @override
  String get grpMRelJustNow => 'للتو';

  @override
  String grpMRelMin(int n) {
    return 'قبل $n دقيقة';
  }

  @override
  String grpMRelHour(int n) {
    return 'قبل $n ساعة';
  }

  @override
  String get grpMRelYesterday => 'أمس';

  @override
  String grpMRelDay(int n) {
    return 'قبل $n يوم';
  }

  @override
  String get grpMNotifSomeone => 'شخص ما';

  @override
  String grpMNotifAssigned(String who) {
    return '$who كلّفك بـ';
  }

  @override
  String grpMNotifMentioned(String who) {
    return '$who أشار إليك في';
  }

  @override
  String grpMNotifCommented(String who) {
    return '$who علّق على';
  }

  @override
  String grpMNotifStatusChanged(String who) {
    return '$who غيّر حالة';
  }

  @override
  String grpMNotifMoved(String who, String fromStatus, String toStatus) {
    return '$who نقل من $fromStatus إلى $toStatus';
  }

  @override
  String get grpMNotifDueSoon => 'موعد قريب:';

  @override
  String get grpMNotifTimer => 'مؤقّتك لا يزال يعمل على';

  @override
  String get grpMNotifNew => 'نشاط جديد في';

  @override
  String get grpMUnitDay => 'يوم';

  @override
  String get grpMUnitDays => 'أيام';

  @override
  String get grpMUnitWeek => 'أسبوع';

  @override
  String get grpMUnitWeeks => 'أسابيع';

  @override
  String get grpMUnitMonth => 'شهر';

  @override
  String get grpMUnitMonths => 'أشهر';

  @override
  String get grpMUnitYear => 'سنة';

  @override
  String get grpMUnitYears => 'سنوات';

  @override
  String get grpMSlashText => 'نص';

  @override
  String get grpMSlashH1 => 'عنوان 1';

  @override
  String get grpMSlashH2 => 'عنوان 2';

  @override
  String get grpMSlashH3 => 'عنوان 3';

  @override
  String get grpMSlashBullet => 'قائمة نقطية';

  @override
  String get grpMSlashNumbered => 'قائمة مرقّمة';

  @override
  String get grpMSlashTodo => 'قائمة مراجعة';

  @override
  String get grpMSlashQuote => 'اقتباس';

  @override
  String get grpMSlashCode => 'شيفرة';

  @override
  String get grpMSlashTable => 'جدول';

  @override
  String get grpMSlashDivider => 'فاصل';

  @override
  String get grpMSlashImage => 'صورة';

  @override
  String get grpMSlashCallout => 'تنبيه';

  @override
  String get grpMSlashTask => 'بطاقة مهمة';

  @override
  String get grpMMeanSucceeded => 'نُفِّذت كل الإجراءات.';

  @override
  String get grpMMeanFailed =>
      'فشل أحد الإجراءات؛ وتبقى الإجراءات السابقة له منفَّذة.';

  @override
  String get grpMMeanSkippedCondition =>
      'تطابق الحدث، لكن المهمة لم تستوفِ الشرط.';

  @override
  String get grpMMeanSkippedLoop =>
      'شغّلت القواعد قواعد أخرى بعمق يزيد على 5 مراحل، لذا أُوقف هذا التشغيل لإنهاء حلقة.';

  @override
  String get grpMMeanSkippedRate =>
      'سبق أن شُغّلت هذه القاعدة 30 مرة في الدقيقة الأخيرة، لذا تم تخطي هذا التشغيل.';

  @override
  String get grpMStepOk => 'موفق';

  @override
  String get grpMStepFailed => 'فشل';

  @override
  String get grpMStepNotRun => 'لم يُنفَّذ';

  @override
  String get grpMStepPlanned => 'مخطَّط';

  @override
  String get grpMStepWouldFail => 'سيفشل';

  @override
  String get grp1DropCardHere => 'أفلت بطاقة هنا';

  @override
  String get grp1NoCards => 'لا توجد بطاقات';

  @override
  String get grp1StopWatchingTask => 'إيقاف متابعة هذه المهمة';

  @override
  String get grp1WatchTask => 'متابعة هذه المهمة';

  @override
  String get grp1SecondFactorRequired => 'العامل الثاني مطلوب.';

  @override
  String get grp1AnAutomation => 'أتمتة';

  @override
  String get grp1TheSystem => 'النظام';

  @override
  String grp1MemberCount(int count) {
    return '$count عضو';
  }

  @override
  String get grp1SyncLive => 'مباشر';

  @override
  String get grp1SyncConnecting => 'جارٍ الاتصال…';

  @override
  String get grp1SyncReconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String get grp1SyncLiveTip => 'تظهر تغييرات الآخرين فور حدوثها';

  @override
  String get grp1SyncNotLiveTip =>
      'غير مباشر: ستظهر تغييرات الآخرين بعد إعادة الاتصال';

  @override
  String get grp1EnterNumber => 'أدخل رقماً.';

  @override
  String get grp1EnterAmount => 'أدخل مبلغاً.';

  @override
  String get grp1EnterCurrency => 'أدخل عملة من 3 أحرف، مثل USD.';

  @override
  String get grp1EnterUrl => 'أدخل عنوان ويب يبدأ بـ http(s)://';

  @override
  String get grp1UseIsoDate => 'استخدم الصيغة YYYY-MM-DD.';

  @override
  String get taskAddHint => 'أضف مهمة واضغط Enter';

  @override
  String grpRMnAdded(String name) {
    return 'أضافه شخص آخر: $name.';
  }

  @override
  String grpRMnKept(String name) {
    return 'تم الإبقاء على $name: لقد حذفته، لكن شخصاً آخر غيّره أولاً. احذفه مرة أخرى إن كنت لا تزال ترغب في ذلك.';
  }

  @override
  String grpRMnDeleted(String name) {
    return 'حذفه شخص آخر: $name.';
  }

  @override
  String grpRMnDeletedEdited(String name) {
    return 'حذفه شخص آخر: $name. تم إسقاط تعديلاتك عليه.';
  }

  @override
  String grpRMnFieldAdopted(String what, String status, String value) {
    return 'غيّر شخص آخر $what «$status» إلى $value.';
  }

  @override
  String grpRMnFieldDropped(
    String what,
    String status,
    String mine,
    String value,
  ) {
    return 'تم إسقاط تغييرك على $what «$status» ($mine): غيّره شخص آخر إلى $value.';
  }

  @override
  String grpRMnSwitchAdopted(String what, String state) {
    return 'قام شخص آخر بجعل «$what» $state.';
  }

  @override
  String grpRMnSwitchDropped(String what, String state) {
    return 'تم إسقاط تغييرك على «$what»: جعله شخص آخر $state.';
  }

  @override
  String get grpRMnOrderDropped =>
      'تم إسقاط ترتيبك الجديد للحالات: أعاد شخص آخر ترتيبها أيضاً.';

  @override
  String get grpRMnReordered => 'أعاد شخص آخر ترتيب الحالات.';

  @override
  String grpRMnMigrationLost(String name) {
    return 'الحالة التي اخترتها لمهام «$name» حذفها شخص آخر: اختر مكاناً آخر لها.';
  }

  @override
  String get grpRMnDeletedStatus => 'حالة محذوفة';

  @override
  String grpRMnMoveAllowed(String name) {
    return 'سمح شخص آخر بالانتقال $name.';
  }

  @override
  String grpRMnMoveRemoved(String name) {
    return 'أزال شخص آخر الانتقال $name.';
  }

  @override
  String grpRMnConditionsAdopted(String name) {
    return 'غيّر شخص آخر شروط الانتقال $name.';
  }

  @override
  String grpRMnConditionsDropped(String name) {
    return 'تم إسقاط تغييرك على شروط الانتقال $name: غيّرها شخص آخر أيضاً.';
  }

  @override
  String grpRMnMovesDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'تم إسقاط $count انتقال من انتقالاتك لأن حالة كانت تستخدمها لم تعد موجودة.',
      many:
          'تم إسقاط $count انتقالاً من انتقالاتك لأن حالة كانت تستخدمها لم تعد موجودة.',
      few:
          'تم إسقاط $count انتقالات من انتقالاتك لأن حالة كانت تستخدمها لم تعد موجودة.',
      two: 'تم إسقاط انتقالين من انتقالاتك لأن حالة كانا يستخدمانها لم تعد موجودة.',
      one: 'تم إسقاط أحد انتقالاتك لأن حالة كان يستخدمها لم تعد موجودة.',
      zero: 'لم يتم إسقاط أي انتقال.',
    );
    return '$_temp0';
  }

  @override
  String get grpRMnWhatName => 'اسم';

  @override
  String get grpRMnWhatColour => 'لون';

  @override
  String get grpRMnWhatCategory => 'فئة';

  @override
  String get grpRMnWhatDefault => 'الافتراضي';

  @override
  String get grpRMnNone => 'لا شيء';

  @override
  String get grpRMnIsDefault => 'الافتراضية';

  @override
  String get grpRMnNotDefault => 'غير الافتراضية';

  @override
  String get grpRMnOn => 'قيد التشغيل';

  @override
  String get grpRMnOff => 'متوقف';

  @override
  String get grpRKeyCtrl => 'Ctrl';

  @override
  String get grpRKeyAlt => 'Alt';

  @override
  String get grpRKeyShift => 'Shift';

  @override
  String get grpRKeyEnter => 'Enter';

  @override
  String get grpRKeyEsc => 'Esc';

  @override
  String get grpRKeySpace => 'مسافة';

  @override
  String get grpRKeyTab => 'Tab';

  @override
  String get grpRKeyBackspace => 'Backspace';

  @override
  String get grpRKeyDelete => 'Delete';

  @override
  String get grpRKeyHome => 'Home';

  @override
  String get grpRKeyEnd => 'End';

  @override
  String get grpRKeyPgUp => 'PgUp';

  @override
  String get grpRKeyPgDn => 'PgDn';

  @override
  String get grpRCmForbidden => 'لم يعد بإمكانك التعليق على هذه المهمة.';

  @override
  String get grpRCmGone => 'تم حذف المهمة.';

  @override
  String get grpRCmArchived => 'تمت أرشفة المشروع.';

  @override
  String get grpRCmInvalid => 'التعليق غير صالح.';

  @override
  String get grpRCmMention => 'لا يستطيع شخص تمت الإشارة إليه رؤية هذه المهمة.';

  @override
  String get grpRCmRefused => 'رفض الخادم التعليق.';

  @override
  String grpRDependsRefused(String reason) {
    return 'هذا يعتمد على تغيير تم رفضه: $reason';
  }

  @override
  String get grpRKeepUnreadable => 'تعذّرت قراءته. حاول مرة أخرى.';

  @override
  String grpRDenyNeed(String permission) {
    return 'تحتاج إلى الإذن «$permission»';
  }

  @override
  String grpRDenyNeedRole(String permission, String role) {
    return 'تحتاج إلى الإذن «$permission» — دورك هو $role';
  }

  @override
  String get grpRRequestFailed => 'فشل الطلب.';

  @override
  String get grpRUnitB => 'بايت';

  @override
  String get grpRUnitKB => 'ك.ب';

  @override
  String get grpRUnitMB => 'م.ب';

  @override
  String get grpRUnitGB => 'ج.ب';

  @override
  String get grpRUnitTB => 'ت.ب';

  @override
  String grpRStorageOf(String used, String quota) {
    return '$used من $quota مستخدم';
  }

  @override
  String grpRStorageUsed(String used) {
    return '$used مستخدم';
  }

  @override
  String grpRChartBars(String label, int count) {
    return '$label، $count أعمدة';
  }

  @override
  String grpRChartSlices(String label, int count) {
    return '$label، $count شرائح';
  }

  @override
  String grpRChartLines(String label, int lines, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines خط',
      many: '$lines خطاً',
      few: '$lines خطوط',
      two: 'خطان',
      one: 'خط واحد',
    );
    return '$label، $_temp0، $points نقطة';
  }

  @override
  String grpRChartPercent(String label, String shown, int percent) {
    return '$label، $shown، $percent بالمئة';
  }

  @override
  String get grpRAuCreated => 'أنشأ هذه المهمة';

  @override
  String get grpRAuTrashed => 'نقل هذه المهمة إلى سلة المهملات';

  @override
  String get grpRAuRestored => 'استعاد هذه المهمة';

  @override
  String grpRAuStatus(String from, String to) {
    return 'غيّر الحالة $from → $to';
  }

  @override
  String grpRAuAssigned(String names) {
    return 'أسند إلى $names';
  }

  @override
  String grpRAuUnassigned(String names) {
    return 'ألغى إسناد $names';
  }

  @override
  String grpRAuAnd(String a, String b) {
    return '$a و$b';
  }

  @override
  String get grpRAuCommented => 'علّق';

  @override
  String get grpRAuCommentEdited => 'عدّل تعليقاً';

  @override
  String get grpRAuCommentDeleted => 'حذف تعليقاً';

  @override
  String grpRAuReacted(String emoji) {
    return 'تفاعل بـ $emoji مع تعليق';
  }

  @override
  String grpRAuUnreacted(String emoji) {
    return 'سحب $emoji من تعليق';
  }

  @override
  String grpRAuAttached(String file) {
    return 'أرفق $file';
  }

  @override
  String grpRAuFileRemoved(String file) {
    return 'أزال الملف $file';
  }

  @override
  String get grpRAuTimeLogged => 'سجّل وقتاً';

  @override
  String get grpRAuTimeUpdated => 'حدّث إدخال وقت';

  @override
  String get grpRAuTimeDeleted => 'حذف إدخال وقت';

  @override
  String grpRAuLinked(String type, String task) {
    return 'ربط $type $task';
  }

  @override
  String get grpRAuLinkRemoved => 'أزال رابطاً';

  @override
  String get grpRAuFieldSet => 'ضبط حقلاً مخصصاً';

  @override
  String get grpRAuDocLinked => 'ربط صفحة';

  @override
  String get grpRAuDocUnlinked => 'فك ربط صفحة';

  @override
  String get grpRAuEdited => 'عدّل هذه المهمة';

  @override
  String grpRAuChanged(String parts) {
    return 'غيّر $parts';
  }

  @override
  String grpRAuPart(String label, String from, String to) {
    return '$label $from ← $to';
  }

  @override
  String get grpRAuSomething => 'قام بإجراء ما';

  @override
  String get grpRAuFStatus => 'الحالة';

  @override
  String get grpRAuFSprint => 'السبرنت';

  @override
  String get grpRAuFParent => 'المهمة الأم';

  @override
  String get grpRAuFDueDate => 'تاريخ الاستحقاق';

  @override
  String get grpRAuFDueTime => 'وقت الاستحقاق';

  @override
  String get grpRAuFStartDate => 'تاريخ البدء';

  @override
  String get grpRAuFEstimate => 'التقدير';

  @override
  String get devTitle => 'المطور';

  @override
  String get devSub => 'رموز API وخطافات الويب';

  @override
  String get devTokensTab => 'رموز API';

  @override
  String get devWebhooksTab => 'خطافات الويب';

  @override
  String get devTokenNew => 'رمز جديد';

  @override
  String get devTokenName => 'الاسم';

  @override
  String get devTokenScopes => 'ما يمكنه فعله';

  @override
  String get devTokenExpiry => 'ينتهي';

  @override
  String get devExpiryNever => 'أبدًا';

  @override
  String get devExpiry30 => 'بعد 30 يومًا';

  @override
  String get devExpiry90 => 'بعد 90 يومًا';

  @override
  String get devExpiry365 => 'بعد سنة';

  @override
  String get devTokenCreate => 'إنشاء الرمز';

  @override
  String get devTokenCreatedTitle => 'انسخ الرمز الآن';

  @override
  String get devTokenCreatedBody =>
      'هذه هي المرة الوحيدة التي يظهر فيها. احفظه في مكان آمن.';

  @override
  String get devCopy => 'نسخ';

  @override
  String get devCopied => 'تم النسخ';

  @override
  String get devDone => 'تم';

  @override
  String devTokenPrefix(String prefix) {
    return 'يبدأ بـ $prefix';
  }

  @override
  String get devTokenNeverUsed => 'لم يُستخدم أبدًا';

  @override
  String devTokenUsed(String when) {
    return 'آخر استخدام $when';
  }

  @override
  String get devTokenActive => 'نشط';

  @override
  String get devTokenExpired => 'منتهي';

  @override
  String get devTokenRevoked => 'ملغى';

  @override
  String get devTokenRevoke => 'إلغاء';

  @override
  String devTokenRevokeTitle(String name) {
    return 'إلغاء «$name»؟';
  }

  @override
  String get devTokenRevokeBody =>
      'سيتوقف كل ما يستخدم هذا الرمز عن العمل فورًا.';

  @override
  String get devTokensEmpty => 'لا توجد رموز بعد.';

  @override
  String get devTokensHint =>
      'يستطيع الرمز فعل ما تستطيعه أنت، مقيّدًا بالنطاقات التي تختارها. ويعمل في مساحة العمل هذه فقط.';

  @override
  String get devWebhookNew => 'خطاف ويب جديد';

  @override
  String get devWebhookEdit => 'تعديل خطاف الويب';

  @override
  String get devWebhookName => 'الاسم (اختياري)';

  @override
  String get devWebhookUrl => 'العنوان';

  @override
  String get devWebhookEvents => 'الأحداث';

  @override
  String get devWebhookSave => 'حفظ';

  @override
  String get devWebhookActive => 'نشط';

  @override
  String get devWebhookSecret => 'سر التوقيع';

  @override
  String get devWebhookTest => 'إرسال اختبار';

  @override
  String devWebhookTestDone(String status) {
    return 'تم إرسال الاختبار: $status';
  }

  @override
  String get devWebhookDeliveries => 'عمليات التسليم';

  @override
  String get devWebhookDelete => 'حذف';

  @override
  String devWebhookDeleteTitle(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get devWebhookDeleteBody => 'سيُحذف سجل التسليم الخاص به أيضًا.';

  @override
  String get devWebhooksEmpty => 'لا توجد خطافات ويب بعد.';

  @override
  String get devWebhooksDenied => 'لا يراها إلا من يستطيع إدارة خطافات الويب.';

  @override
  String devWebhookOff(String reason) {
    return 'تم إيقافه: $reason';
  }

  @override
  String get devWebhookHint =>
      'يُرسل كل حدث كطلب POST موقّع. يتحقق المستلم من التوقيع بالسر.';

  @override
  String get devDeliveriesTitle => 'عمليات التسليم';

  @override
  String get devDeliveriesEmpty => 'لم يُرسل شيء بعد.';

  @override
  String get devStatusDelivered => 'تم التسليم';

  @override
  String get devStatusPending => 'في الانتظار';

  @override
  String get devStatusFailed => 'فشل، ستتم إعادة المحاولة';

  @override
  String get devStatusGaveUp => 'تم التخلي';

  @override
  String devAttempt(int n) {
    return 'المحاولة $n';
  }

  @override
  String get devRequest => 'الطلب';

  @override
  String get devResponse => 'الاستجابة';

  @override
  String get devHeaders => 'الترويسات';

  @override
  String get devBody => 'المحتوى';

  @override
  String get devResend => 'إعادة الإرسال';

  @override
  String devResent(String status) {
    return 'أُعيد الإرسال: $status';
  }

  @override
  String devNextTry(String when) {
    return 'المحاولة التالية $when';
  }

  @override
  String get devLoadMore => 'تحميل المزيد';

  @override
  String get devRetry => 'حاول مجددًا';

  @override
  String get devDenied => 'لا يمكنك فعل ذلك هنا.';

  @override
  String get devScopeWorkspacesRead => 'عرض مساحة العمل';

  @override
  String get devScopeProjectsRead => 'قراءة المشاريع';

  @override
  String get devScopeProjectsWrite => 'إنشاء المشاريع وتعديلها';

  @override
  String get devScopeTasksRead => 'قراءة المهام';

  @override
  String get devScopeTasksWrite => 'إنشاء المهام وتعديلها وحذفها';

  @override
  String get devScopeCommentsRead => 'قراءة التعليقات';

  @override
  String get devScopeCommentsWrite => 'كتابة التعليقات';

  @override
  String get devEventTaskCreated => 'إنشاء مهمة';

  @override
  String get devEventTaskUpdated => 'تعديل مهمة';

  @override
  String get devEventTaskStatus => 'تغيّر حالة مهمة';

  @override
  String get devEventTaskAssigned => 'تعيين أشخاص لمهمة';

  @override
  String get devEventTaskDeleted => 'حذف مهمة';

  @override
  String get devEventCommentCreated => 'إضافة تعليق';

  @override
  String get devEventCommentUpdated => 'تعديل تعليق';

  @override
  String get devEventCommentDeleted => 'حذف تعليق';

  @override
  String get devEventPing => 'حدث اختبار';

  @override
  String get formsTitle => 'النماذج';

  @override
  String get formsSub => 'نماذج عامة تنشئ مهامًا';

  @override
  String get formsHint =>
      'شارك رابط نموذج ليتمكن من هم خارج مساحة العمل من إرسال طلبات. لا يحتاجون إلى حساب.';

  @override
  String get formsEmpty => 'لا توجد نماذج بعد.';

  @override
  String get formsNew => 'نموذج جديد';

  @override
  String get formsEdit => 'تعديل النموذج';

  @override
  String get formsPickProject => 'أي مشروع يستقبل المهام؟';

  @override
  String formsSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إرسال',
      many: '$count إرسالًا',
      few: '$count إرسالات',
      two: 'إرسالان',
      one: 'إرسال واحد',
      zero: 'لا إرسالات',
    );
    return '$_temp0';
  }

  @override
  String get formsCopyLink => 'نسخ الرابط';

  @override
  String get formsLinkCopied => 'تم نسخ الرابط.';

  @override
  String get formsRotateLink => 'رابط جديد (يتوقف القديم)';

  @override
  String get formsLinkRotated => 'أصبح للنموذج رابط جديد. لم يعد القديم يعمل.';

  @override
  String get formsSubmissions => 'الإرسالات';

  @override
  String get formsNoSubmissions => 'لم يُرسل شيء عبر هذا النموذج بعد.';

  @override
  String get formsTaskGone => 'تم حذف المهمة';

  @override
  String get formsCopyReference => 'نسخ المرجع';

  @override
  String get formsDelete => 'حذف النموذج';

  @override
  String formsDeleteTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get formsDeleteBody =>
      'يتوقف رابطه وتُزال قائمة الإرسالات. تبقى المهام التي أنشأها.';

  @override
  String get formsDenied => 'لا يمكنك إدارة النماذج هنا.';

  @override
  String get formsGone => 'لم يعد هذا النموذج موجودًا.';

  @override
  String get formsGonePage => 'هذا النموذج غير متاح.';

  @override
  String get formsConflict =>
      'تغيّر النموذج منذ فتحته. افتحه من جديد وحاول مرة أخرى.';

  @override
  String get formsTooMany => 'إرسالات كثيرة جدًا. حاول لاحقًا.';

  @override
  String get formsUnavailable =>
      'لا يمكن لهذا النموذج استقبال الإرسالات الآن. حاول لاحقًا.';

  @override
  String get formsCaptchaFailed => 'فشل التحقق. أكمله مرة أخرى ثم أرسل.';

  @override
  String get formsCaptchaRequired => 'أكمل التحقق.';

  @override
  String get formsCaptchaWebOnly =>
      'يحتاج هذا النموذج إلى تحقق لا يعمل إلا في المتصفح. افتح رابطه هناك.';

  @override
  String get formsCaptchaPreview => 'يظهر هنا تحقق.';

  @override
  String get formsRequired => 'هذا الحقل مطلوب.';

  @override
  String get formsRequiredTag => 'مطلوب';

  @override
  String get formsEmailLabel => 'بريدك الإلكتروني (اختياري)';

  @override
  String get formsEmailLabelRequired => 'بريدك الإلكتروني *';

  @override
  String get formsEmailHelp => 'نستخدمه فقط للتأكيد وإبلاغك بشأن هذا الطلب.';

  @override
  String get formsEmailInvalid => 'أدخل عنوان بريد إلكتروني صالحًا.';

  @override
  String get formsSubmit => 'إرسال';

  @override
  String get formsSending => 'جارٍ الإرسال…';

  @override
  String get formsThanksTitle => 'شكرًا، تم الاستلام';

  @override
  String formsThanksBody(String reference) {
    return 'رقمك المرجعي $reference. اذكره عند مراسلتنا.';
  }

  @override
  String get formsAnother => 'إرسال آخر';

  @override
  String formsAddFile(int max) {
    return 'إضافة ملف (حتى $max)';
  }

  @override
  String get formsRemoveFile => 'إزالة الملف';

  @override
  String get formsFileTooBig => 'ملف كبير جدًا.';

  @override
  String get formsNoDate => 'بلا تاريخ';

  @override
  String get formsPickDate => 'اختر تاريخًا';

  @override
  String get formsClearDate => 'مسح التاريخ';

  @override
  String get formsMoneyHint => 'المبلغ والعملة، مثل 12.50 USD';

  @override
  String get formsBuildTab => 'البناء';

  @override
  String get formsPreviewTab => 'معاينة';

  @override
  String get formsNameLabel => 'اسم النموذج';

  @override
  String get formsDescriptionLabel => 'نص أعلى النموذج';

  @override
  String get formsNeedName => 'أعطِ النموذج اسمًا.';

  @override
  String get formsSaved => 'تم حفظ النموذج.';

  @override
  String get formsQuestions => 'الأسئلة';

  @override
  String get formsDefaultTitle => 'الملخص';

  @override
  String get formsDefaultDescription => 'التفاصيل';

  @override
  String get formsDefaultFile => 'مرفق';

  @override
  String get formsAddDescription => 'إضافة تفاصيل';

  @override
  String get formsAddFileQuestion => 'إضافة رفع ملف';

  @override
  String get formsAddField => 'إضافة حقل مشروع';

  @override
  String get formsPickField => 'أي حقل؟';

  @override
  String get formsNoFields =>
      'لا توجد حقول أخرى للإضافة. حقول الأشخاص لا تُعرض أبدًا في نموذج عام.';

  @override
  String get formsRemoveQuestion => 'إزالة السؤال';

  @override
  String get formsKindTitle => 'عنوان المهمة';

  @override
  String get formsKindDescription => 'وصف المهمة';

  @override
  String get formsKindFile => 'رفع ملف';

  @override
  String get formsKindField => 'حقل مشروع';

  @override
  String get formsEditQuestion => 'تعديل السؤال';

  @override
  String get formsQuestionLabel => 'التسمية';

  @override
  String get formsQuestionHelp => 'نص المساعدة';

  @override
  String get formsQuestionRequired => 'مطلوب';

  @override
  String get formsMaxFiles => 'أقصى عدد للملفات';

  @override
  String get formsTarget => 'ما تبدأ به المهمة';

  @override
  String get formsStatusLabel => 'الحالة';

  @override
  String get formsStatusDefault => 'أول حالة في المشروع';

  @override
  String get formsPriorityLabel => 'الأولوية';

  @override
  String get formsPriorityNone => 'بلا';

  @override
  String get formsPriorityLow => 'منخفضة';

  @override
  String get formsPriorityMedium => 'متوسطة';

  @override
  String get formsPriorityHigh => 'عالية';

  @override
  String get formsPriorityUrgent => 'عاجلة';

  @override
  String get formsAssigneesLabel => 'إسناد إلى';

  @override
  String get formsEnabled => 'يستقبل الإرسالات';

  @override
  String get formsRequireEmail => 'طلب عنوان بريد إلكتروني';

  @override
  String get formsSendConfirmation => 'إرسال بريد تأكيد';

  @override
  String get formsNotifyStatus => 'إرسال بريد عند تغيّر الحالة';

  @override
  String get formsNotifyStatusHint =>
      'باتجاه واحد: يصل المرسل الحالة الجديدة وليس رابطًا إلى مساحة العمل.';

  @override
  String get formsBranding => 'المظهر';

  @override
  String get formsColorLabel => 'لون العلامة';

  @override
  String get formsLogoLabel => 'عنوان الشعار (https://…)';

  @override
  String get goalsTitle => 'الأهداف';

  @override
  String get goalsEmpty => 'لا توجد أهداف بعد. أنشئ هدفًا لتتبع ما يهم.';

  @override
  String get goalsNew => 'هدف جديد';

  @override
  String get goalsEdit => 'تعديل الهدف';

  @override
  String get goalsDelete => 'حذف الهدف';

  @override
  String goalsDeleteTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get goalsDeleteBody =>
      'تُحذف نتائجه الرئيسية وتسجيلات تقدمه. تنتقل الأهداف التابعة له مستوى واحدًا للأعلى.';

  @override
  String get goalsSave => 'حفظ';

  @override
  String get goalsName => 'الاسم';

  @override
  String get goalsDescription => 'الوصف';

  @override
  String goalsPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String get goalsOwner => 'المالك';

  @override
  String get goalsContributors => 'المساهمون';

  @override
  String get goalsParent => 'الهدف الأعلى';

  @override
  String get goalsNone => 'بلا';

  @override
  String get goalsFolder => 'المجلد';

  @override
  String get goalsNoFolder => 'بلا مجلد';

  @override
  String get goalsNewFolder => 'مجلد جديد';

  @override
  String get goalsFolderName => 'اسم المجلد';

  @override
  String get goalsRenameFolder => 'إعادة تسمية المجلد';

  @override
  String get goalsDeleteFolder => 'حذف المجلد';

  @override
  String get goalsWeight => 'الوزن';

  @override
  String get goalsPrivate => 'خاص';

  @override
  String get goalsPrivateHint => 'يراه المالك والمساهمون والمسؤولون فقط.';

  @override
  String get goalsStatusLabel => 'الحالة';

  @override
  String get goalsStatusAuto => 'تلقائي';

  @override
  String get goalsStatusOnTrack => 'على المسار';

  @override
  String get goalsStatusAtRisk => 'في خطر';

  @override
  String get goalsStatusOffTrack => 'خارج المسار';

  @override
  String get goalsStatusAutoNote => 'يُحسب من التقدم والوقت.';

  @override
  String goalsStatusSet(String status) {
    return 'حُدد يدويًا. المقترح: $status';
  }

  @override
  String goalsProgressPercent(int percent) {
    return '$percent٪';
  }

  @override
  String get goalsKeyResults => 'النتائج الرئيسية';

  @override
  String get goalsNoKr => 'لا توجد نتائج رئيسية بعد.';

  @override
  String get goalsAddKr => 'إضافة نتيجة رئيسية';

  @override
  String get goalsEditKr => 'تعديل النتيجة الرئيسية';

  @override
  String get goalsDeleteKr => 'حذف النتيجة الرئيسية';

  @override
  String get goalsKrName => 'النتيجة الرئيسية';

  @override
  String get goalsKrType => 'طريقة القياس';

  @override
  String get goalsKrNumber => 'رقم';

  @override
  String get goalsKrPercentage => 'نسبة مئوية';

  @override
  String get goalsKrBoolean => 'منجز أو لا';

  @override
  String get goalsKrLinked => 'مهام مرتبطة';

  @override
  String get goalsKrStart => 'القيمة الابتدائية';

  @override
  String get goalsKrTarget => 'القيمة المستهدفة';

  @override
  String get goalsKrCurrent => 'القيمة الحالية';

  @override
  String get goalsKrDirectionHint =>
      'يمكن أن يكون الهدف أقل من البداية، مثل خفض الأخطاء من 40 إلى 10.';

  @override
  String get goalsKrFilter => 'مرشح المهام (اختياري)';

  @override
  String get goalsKrFilterHint =>
      'مرشح TFQL على مساحة العمل مثل label = launch. تُحتسب المهام التي تضيفها يدويًا أيضًا.';

  @override
  String goalsKrPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة أُضيفت يدويًا',
      many: '$count مهمة أُضيفت يدويًا',
      few: '$count مهام أُضيفت يدويًا',
      two: 'مهمتان أُضيفتا يدويًا',
      one: 'مهمة واحدة أُضيفت يدويًا',
    );
    return '$_temp0';
  }

  @override
  String goalsKrNumberProgress(String current, String target) {
    return '$current من $target';
  }

  @override
  String goalsKrLinkedProgress(int done, int total) {
    return '$done من $total مهام منجزة';
  }

  @override
  String get goalsKrDone => 'منجز';

  @override
  String get goalsKrNotDone => 'غير منجز';

  @override
  String get goalsCheckIn => 'تسجيل تقدم';

  @override
  String goalsCheckInTitle(String name) {
    return 'تسجيل تقدم: $name';
  }

  @override
  String get goalsCheckInValue => 'القيمة الجديدة';

  @override
  String get goalsCheckInDone => 'منجز';

  @override
  String get goalsCheckInNote => 'ملاحظة';

  @override
  String get goalsCheckInLinkedHint =>
      'المهام المرتبطة تحدد القيمة. ما زال بإمكانك ترك ملاحظة.';

  @override
  String get goalsCheckInHistory => 'السجل';

  @override
  String get goalsCheckInEmpty => 'لا توجد تسجيلات بعد.';

  @override
  String get goalsCheckInSystem => 'حُسب من المهام';

  @override
  String goalsCheckInChange(String from, String to) {
    return '$from ← $to';
  }

  @override
  String get goalsContributes => 'يساهم في';

  @override
  String get goalsAddToKr => 'احتسابها في نتيجة رئيسية';

  @override
  String get goalsPickKr => 'أي نتيجة رئيسية تحتسب هذه المهمة؟';

  @override
  String get goalsNoLinkedKr => 'لا توجد نتائج رئيسية مرتبطة يمكنك تعديلها.';

  @override
  String get goalsSubgoals => 'الأهداف الفرعية';

  @override
  String get goalsDenied => 'ليس لديك إذن لهذا الإجراء على الأهداف.';

  @override
  String get goalsGone => 'هذا الهدف لم يعد موجودًا.';

  @override
  String get goalsConflict => 'تغيّر منذ فتحته. أعد التحميل وحاول مجددًا.';

  @override
  String get tplTitle => 'القوالب';

  @override
  String get tplSearch => 'ابحث في القوالب';

  @override
  String get tplAll => 'الكل';

  @override
  String get tplKindProject => 'المشاريع';

  @override
  String get tplKindTask => 'المهام';

  @override
  String get tplEmpty => 'لا توجد قوالب مطابقة.';

  @override
  String get tplBuiltIn => 'مدمج';

  @override
  String get tplPrivate => 'أنا فقط';

  @override
  String get tplShared => 'الجميع في مساحة العمل';

  @override
  String tplTasksN(int count) {
    return '$count مهمة';
  }

  @override
  String tplAutomationsN(int count) {
    return '$count أتمتة';
  }

  @override
  String get tplStatuses => 'الحالات';

  @override
  String get tplFields => 'حقول مخصصة';

  @override
  String get tplFeatures => 'الميزات';

  @override
  String get tplTasks => 'المهام';

  @override
  String get tplNoTasks => 'لا توجد مهام نموذجية.';

  @override
  String get tplApply => 'استخدام القالب';

  @override
  String get tplEdit => 'تعديل';

  @override
  String get tplDelete => 'حذف';

  @override
  String get tplDeleteAsk =>
      'حذف هذا القالب؟ المشاريع التي أُنشئت منه لا تتأثر.';

  @override
  String tplApplyTitle(String name) {
    return 'استخدام $name';
  }

  @override
  String get tplProjectName => 'اسم المشروع';

  @override
  String get tplProjectKey => 'المفتاح';

  @override
  String get tplTargetProject => 'إضافة إلى المشروع';

  @override
  String get tplStartDate => 'تاريخ البدء';

  @override
  String get tplStartHelp => 'تُحسب التواريخ النسبية من هذا اليوم.';

  @override
  String get tplVariables => 'املأ البيانات';

  @override
  String get tplRequired => 'مطلوب.';

  @override
  String get tplCreate => 'إنشاء';

  @override
  String tplApplied(int count) {
    return 'تم إنشاء $count مهمة.';
  }

  @override
  String get tplWarnings => 'تم تخطي بعض الأجزاء';

  @override
  String get tplSaveTitle => 'حفظ كقالب';

  @override
  String get tplName => 'الاسم';

  @override
  String get tplDescription => 'الوصف';

  @override
  String get tplVisibility => 'من يمكنه استخدامه';

  @override
  String get tplInclude => 'تضمين';

  @override
  String get tplPartWorkflow => 'الحالات وسير العمل';

  @override
  String get tplPartFields => 'حقول مخصصة';

  @override
  String get tplPartAutomations => 'الأتمتة';

  @override
  String get tplPartFeatures => 'مفاتيح الميزات';

  @override
  String get tplPartTasks => 'مهام نموذجية';

  @override
  String get tplAssignees => 'الإبقاء على المكلّفين';

  @override
  String get tplSave => 'حفظ';

  @override
  String get tplSaved => 'تم حفظ القالب.';

  @override
  String get tplSaveTask => 'حفظ المهمة كقالب';

  @override
  String get tplSaveProject => 'حفظ المشروع كقالب';

  @override
  String get tplFromTemplate => 'من قالب…';

  @override
  String get tplCmdOpen => 'فتح القوالب';

  @override
  String get tplDenied => 'لا يسمح لك بهذا الإجراء على القوالب.';

  @override
  String get tplGone => 'هذا القالب لم يعد موجودًا.';

  @override
  String get tplConflict => 'تغيّر منذ فتحته. أعد التحميل وحاول مرة أخرى.';

  @override
  String get wlTitle => 'عبء العمل';

  @override
  String get wlSettings => 'السعة والإجازات والعطل';

  @override
  String get wlPrevious => 'السابق';

  @override
  String get wlNext => 'التالي';

  @override
  String get wlToday => 'اليوم';

  @override
  String get wlZoomDay => 'يوم';

  @override
  String get wlZoomWeek => 'أسبوع';

  @override
  String get wlZoomMonth => 'شهر';

  @override
  String get wlProjects => 'المشاريع';

  @override
  String get wlPeople => 'الأشخاص';

  @override
  String get wlClearFilter => 'مسح التصفية';

  @override
  String get wlLegendUnder => 'أقل من نصف السعة';

  @override
  String get wlLegendOk => 'ضمن السعة';

  @override
  String get wlLegendOver => 'فوق السعة';

  @override
  String get wlLegendSevere => 'فوق السعة بكثير (أكثر من 125٪)';

  @override
  String get wlOnlyYours => 'يمكنك رؤية عبء عملك فقط.';

  @override
  String get wlSetCapacityHint =>
      'لم تُحدَّد السعة لبعض الأشخاص بعد. يظهر حملهم دون ألوان تجاوز السعة.';

  @override
  String get wlSetCapacity => 'تحديد السعة';

  @override
  String get wlNoCapacity => 'لم تُحدَّد السعة';

  @override
  String get wlTruncated => 'مهام كثيرة جداً: تعرض الشبكة جزءاً منها فقط.';

  @override
  String get wlNoPeople => 'لا يوجد أشخاص للعرض.';

  @override
  String wlCapacitySummary(String hours, String days) {
    return '$hours ساعة يومياً، $days أيام في الأسبوع';
  }

  @override
  String wlUnestimated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة بلا تقدير',
      many: '$count مهمة بلا تقدير',
      few: '$count مهام بلا تقدير',
      two: 'مهمتان بلا تقدير',
      one: 'مهمة واحدة بلا تقدير',
    );
    return '$_temp0';
  }

  @override
  String wlUndated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة بلا تواريخ',
      many: '$count مهمة بلا تواريخ',
      few: '$count مهام بلا تواريخ',
      two: 'مهمتان بلا تواريخ',
      one: 'مهمة واحدة بلا تواريخ',
    );
    return '$_temp0';
  }

  @override
  String get wlReasonNoEstimate => 'بلا تقدير: لا تُحتسب في الشبكة';

  @override
  String get wlReasonNoDates => 'بلا تواريخ: لا يمكن وضعها على يوم';

  @override
  String wlCellTotal(String load, String capacity) {
    return 'الحمل $load ساعة من $capacity ساعة';
  }

  @override
  String get wlHoursUnit => 'ساعة';

  @override
  String get wlCellEmpty => 'لا شيء مخطط';

  @override
  String get wlHoursInvalid => 'الساعات في اليوم رقم من 0 إلى 24.';

  @override
  String wlCapacityOf(String name) {
    return 'سعة $name';
  }

  @override
  String get wlHoursPerDay => 'ساعات في اليوم';

  @override
  String get wlWorkingDays => 'أيام العمل';

  @override
  String get wlTabCapacity => 'السعة';

  @override
  String get wlTabTimeOff => 'الإجازات';

  @override
  String get wlTabHolidays => 'العطل';

  @override
  String get wlAddTimeOff => 'إضافة إجازة';

  @override
  String get wlNoTimeOff => 'لم تُدخل أي إجازة.';

  @override
  String get wlKindVacation => 'عطلة';

  @override
  String get wlKindSick => 'إجازة مرضية';

  @override
  String get wlKindPersonal => 'شخصية';

  @override
  String get wlKindOther => 'أخرى';

  @override
  String get wlPerson => 'الشخص';

  @override
  String get wlKind => 'النوع';

  @override
  String get wlNote => 'ملاحظة';

  @override
  String get wlAddHoliday => 'إضافة عطلة';

  @override
  String get wlNoHolidays => 'لا توجد عطل بعد.';

  @override
  String get wlHolidayName => 'اسم العطلة';

  @override
  String get wlDelete => 'حذف';

  @override
  String get wlDenied => 'ليس لديك إذن لهذا الإجراء في عبء العمل.';

  @override
  String get wlGone => 'هذا الإدخال لم يعد موجوداً.';

  @override
  String get wlConflict => 'تغيّر منذ فتحته. أعد التحميل وحاول مجدداً.';

  @override
  String get secTitle => 'الأمان';

  @override
  String get secSubtitle => 'التحقق بخطوتين والأجهزة الموثوقة';

  @override
  String get secTwoStep => 'التحقق بخطوتين';

  @override
  String get secOn => 'مفعّل. يطلب تسجيل الدخول رمزًا من تطبيق المصادقة.';

  @override
  String get secOff => 'غير مفعّل. أضف خطوة ثانية لحماية حسابك.';

  @override
  String get secEnable => 'تفعيل';

  @override
  String get secTurnOn => 'تفعيل';

  @override
  String get secDisable => 'إيقاف';

  @override
  String get secDisableTitle => 'إيقاف التحقق بخطوتين';

  @override
  String get secDisabled => 'تم إيقاف التحقق بخطوتين.';

  @override
  String get secEnrollTitle => 'إعداد تطبيق المصادقة';

  @override
  String get secScanQr =>
      'امسح هذا الرمز بتطبيق مصادقة مثل Aegis أو Authy أو Google Authenticator.';

  @override
  String get secOrTypeKey => 'أو اكتب هذا المفتاح:';

  @override
  String get secEnterCode => 'الرمز المكوّن من 6 أرقام من التطبيق';

  @override
  String get secCopied => 'تم النسخ.';

  @override
  String get secRecoveryTitle => 'رموز الاسترداد';

  @override
  String get secRecoveryBody =>
      'احتفظ بهذه الرموز العشرة في مكان آمن. يعمل كل منها مرة واحدة إذا فقدت هاتفك. لن تظهر مرة أخرى.';

  @override
  String get secCodesCopied => 'تم نسخ رموز الاسترداد.';

  @override
  String get secSavedThem => 'لقد حفظتها';

  @override
  String secCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رمز متبقٍ',
      many: '$count رمزًا متبقيًا',
      few: '$count رموز متبقية',
      two: 'رمزان متبقيان',
      one: 'رمز واحد متبقٍ',
      zero: 'لا توجد رموز متبقية',
    );
    return '$_temp0';
  }

  @override
  String get secRegenerate => 'رموز جديدة';

  @override
  String get secRegenerateTitle => 'استبدال رموز الاسترداد';

  @override
  String get secCodeOrRecovery => 'رمز التطبيق أو رمز الاسترداد';

  @override
  String get secDevices => 'الأجهزة الموثوقة';

  @override
  String get secDevicesSub =>
      'تتخطى هذه الأجهزة الرمز عند الدخول حتى تنتهي صلاحيتها.';

  @override
  String get secNoDevices => 'لا يوجد جهاز محفوظ.';

  @override
  String get secForgetAll => 'نسيان الكل';

  @override
  String get secForget => 'نسيان هذا الجهاز';

  @override
  String get secUnnamedDevice => 'جهاز بلا اسم';

  @override
  String secDeviceUntil(String date) {
    return 'موثوق حتى $date';
  }

  @override
  String get secBlocked =>
      'تتطلب مساحة العمل هذه التحقق بخطوتين. فعّله أدناه للمتابعة.';

  @override
  String secGraceUntil(String date) {
    return 'ستتطلب مساحة العمل هذه التحقق بخطوتين اعتبارًا من $date. فعّله قبل ذلك.';
  }

  @override
  String get secPolicyTitle => 'متطلبات مساحة العمل';

  @override
  String get secRequire => 'فرض التحقق بخطوتين';

  @override
  String get secRequireSub =>
      'يُحظر الأعضاء الذين لم يفعّلوه بعد انتهاء المهلة.';

  @override
  String get secGraceDays => 'فترة السماح (أيام)';

  @override
  String get secGraceInvalid => 'أدخل من 0 إلى 90 يومًا.';

  @override
  String get secPolicySaved => 'تم حفظ المتطلب.';

  @override
  String get secVerifyTitle => 'التحقق بخطوتين';

  @override
  String get secEnterAppCode =>
      'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.';

  @override
  String get secEnterRecovery =>
      'أدخل أحد رموز الاسترداد. يعمل كل رمز مرة واحدة.';

  @override
  String get secAppCode => 'الرمز';

  @override
  String get secRecoveryCode => 'رمز الاسترداد';

  @override
  String get secRememberDevice =>
      'لا تسأل مرة أخرى على هذا الجهاز لمدة 30 يومًا';

  @override
  String get secVerify => 'تحقق';

  @override
  String get secUseRecovery => 'استخدم رمز استرداد';

  @override
  String get secUseAppCode => 'استخدم رمز التطبيق';

  @override
  String get secBackToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get secWrongCode => 'هذا الرمز غير صحيح. حاول مرة أخرى.';

  @override
  String get secLocked => 'رموز خاطئة كثيرة. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get secTooManyTries => 'محاولات خاطئة كثيرة. سجّل الدخول من جديد.';

  @override
  String get secSignInExpired =>
      'انتهت مهلة تسجيل الدخول. ابدأ من جديد بكلمة المرور.';

  @override
  String get secConflict => 'تغيّر هذا في الأثناء. أعد التحميل وحاول مرة أخرى.';

  @override
  String get secNotFound => 'غير موجود.';

  @override
  String get ssoTitle => 'تسجيل الدخول الموحّد (SSO)';

  @override
  String get ssoTitleShort => 'تسجيل الدخول الموحّد';

  @override
  String get ssoSub =>
      'اسمح للأشخاص بالدخول عبر مزوّد الهوية لديك (OpenID Connect).';

  @override
  String get ssoContinue => 'المتابعة عبر SSO';

  @override
  String get ssoContinueShort => 'متابعة';

  @override
  String get ssoWorkspaceName => 'اسم عنوان مساحة العمل';

  @override
  String get ssoWorkspaceHelp => 'الاسم القصير في عنوان مساحة العمل، مثل acme';

  @override
  String get ssoOpenFailed => 'تعذّر فتح المتصفح.';

  @override
  String get ssoErrUnverified =>
      'لم يؤكد مزوّد الهوية بريدك الإلكتروني، لذلك لا يمكنك الدخول به.';

  @override
  String get ssoErrDomain =>
      'نطاق بريدك غير مسموح له بالدخول إلى مساحة العمل هذه.';

  @override
  String get ssoErrNoAccount => 'لا يوجد حساب لك هنا والتسجيل عبر SSO متوقف.';

  @override
  String get ssoErrRemoved => 'تمت إزالتك من مساحة العمل هذه. اطلب دعوة.';

  @override
  String get ssoErrDisabled => 'هذا الحساب معطّل.';

  @override
  String get ssoErrGeneric => 'تعذّر إكمال تسجيل الدخول الموحّد. ابدأ من جديد.';

  @override
  String get ssoRedirectHelp =>
      'سجّل عنوان إعادة التوجيه هذا لدى مزوّد الهوية:';

  @override
  String get ssoEnabled => 'تسجيل الدخول الموحّد مفعّل';

  @override
  String get ssoName => 'الاسم المعروض (اختياري)';

  @override
  String get ssoIssuer => 'عنوان المُصدِر (Issuer)';

  @override
  String get ssoIssuerHelp =>
      'حيث يوجد /.well-known/openid-configuration، مثل https://id.example.com/realms/acme';

  @override
  String get ssoClientId => 'معرّف العميل';

  @override
  String get ssoClientSecret => 'سر العميل';

  @override
  String get ssoSecretKept => 'يوجد سر محفوظ. اتركه فارغًا للإبقاء عليه.';

  @override
  String get ssoSecretNeeded => 'مطلوب. يُخزَّن مشفّرًا ولا يُعرض مرة أخرى.';

  @override
  String get ssoScopes => 'النطاقات (Scopes)';

  @override
  String get ssoDomains => 'نطاقات البريد المسموحة';

  @override
  String get ssoDomainsHelp => 'افصل بفواصل، مثل acme.com. الفارغ يسمح للجميع.';

  @override
  String get ssoAutoCreate => 'إنشاء الحسابات عند أول دخول';

  @override
  String get ssoAutoCreateSub => 'ينضم أصحاب النطاقات المسموحة دون دعوة.';

  @override
  String get ssoRoles => 'الأدوار';

  @override
  String get ssoGroupClaim => 'اسم مطالبة المجموعة (claim)';

  @override
  String get ssoDefaultRole =>
      'الدور لمن لا تطابقه أي مجموعة (الافتراضي: عضو).';

  @override
  String get ssoDefaultRoleAuto => 'عضو (افتراضي)';

  @override
  String get ssoGroup => 'المجموعة';

  @override
  String get ssoAddMapping => 'ربط مجموعة بدور';

  @override
  String get ssoEnforce => 'فرض تسجيل الدخول الموحّد';

  @override
  String get ssoEnforceSub =>
      'يوقف الدخول بكلمة المرور للأعضاء. يحتفظ المالكون بها كمنفذ احتياطي.';

  @override
  String get ssoSaved => 'تم حفظ تسجيل الدخول الموحّد.';

  @override
  String get ssoTest => 'اختبار';

  @override
  String ssoTestOk(int keys) {
    return 'استجاب المزوّد (عُثر على $keys مفاتيح توقيع)';
  }

  @override
  String get ssoTestFailed => 'فشل الاختبار';

  @override
  String get ssoRemove => 'إزالة';

  @override
  String get ssoRemoveTitle => 'إزالة تسجيل الدخول الموحّد؟';

  @override
  String get ssoRemoveBody => 'سيضطر من دخلوا عبره إلى تسجيل الدخول من جديد.';

  @override
  String get sysAboutTitle => 'حول';

  @override
  String get sysClientVersion => 'إصدار التطبيق';

  @override
  String get sysServerVersion => 'إصدار الخادم';

  @override
  String get sysUnknown => 'غير معروف (الخادم غير متاح)';

  @override
  String sysUpdateAvailable(String version) {
    return 'يتوفر إصدار أحدث ($version). حدّث هذا التطبيق.';
  }

  @override
  String get sysCheckAgain => 'تحقق مرة أخرى';

  @override
  String get sysUpdateRequiredTitle => 'التحديث مطلوب';

  @override
  String sysUpdateRequiredBody(String current, String minimum) {
    return 'هذا التطبيق ($current) قديم جدًا لهذا الخادم الذي يحتاج إلى الإصدار $minimum أو أحدث. ثبّت أحدث إصدار للمتابعة.';
  }

  @override
  String get sysTitle => 'النظام';

  @override
  String get sysSubtitle => 'الإصدار وحالة قائمة المهام (للمسؤولين)';

  @override
  String get sysDenied => 'يمكن للمسؤولين فقط رؤية حالة النظام.';

  @override
  String get sysLoadFailed => 'تعذّر تحميل حالة النظام.';

  @override
  String get sysMinClient => 'أقدم تطبيق مدعوم';

  @override
  String get sysRedis => 'Redis';

  @override
  String get sysBroker => 'قائمة المهام (Celery)';

  @override
  String get sysWorkers => 'العمال';

  @override
  String get sysOk => 'سليم';

  @override
  String get sysUnavailable => 'غير متاح';

  @override
  String get sysInMemory => 'في الذاكرة (تصحيح)';

  @override
  String get sysNotConfigured => 'غير مهيأ';

  @override
  String get sysInline => 'تُنفَّذ المهام مباشرة (تصحيح)';

  @override
  String get sysNoWorkers => 'لم يرد أي عامل';

  @override
  String get sysBacklog => 'أعمال مستحقة قيد الانتظار';

  @override
  String get sysBacklogNone => 'لا شيء في الانتظار.';

  @override
  String get dpopKeyChanged =>
      'تغيّر مفتاح هذا الجهاز، يُرجى تسجيل الدخول مرة أخرى.';

  @override
  String get dpopSessionBound => 'مرتبطة بمفتاح هذا الجهاز';

  @override
  String get devSessionRename => 'إعادة التسمية';

  @override
  String get devSessionRenameTitle => 'إعادة تسمية هذه الجلسة';

  @override
  String get devSessionNameLabel => 'الاسم';

  @override
  String get devSessionNameInvalid => 'استخدم من 1 إلى 80 حرفًا.';

  @override
  String get devSessionRenameFailed =>
      'تعذّرت إعادة تسمية الجلسة. حاول مرة أخرى.';

  @override
  String get devSessionNew => 'جديد';

  @override
  String get devSessionKeyChanged => 'تغيّر المفتاح';

  @override
  String devSessionLastUsed(String when) {
    return 'آخر استخدام $when';
  }

  @override
  String get devPrivacyTitle => 'معلومات الجهاز';

  @override
  String get devPrivacyBody =>
      'عند تسجيل الدخول أو إنشاء حساب أو تجديد الجلسة، يرسل هذا التطبيق طراز جهازك ونظام التشغيل وإصداره ورقم بناء التطبيق وحجم الشاشة واللغة والمنطقة الزمنية، لتحصل جلساتك على اسم مقروء. قد يتجاهله الخادم، ويمكنك إعادة تسمية أي جلسة.';

  @override
  String get devAdminCollectTitle => 'جمع معلومات الجهاز';

  @override
  String get devAdminCollectSubtitle =>
      'تسمية الجلسات والتنبيه إلى الأجهزة الجديدة بحسب ما يبلّغ عنه التطبيق. معطّل افتراضيًا.';

  @override
  String get devAdminPepperMissing =>
      'اضبط DJANGO_DEVICE_FINGERPRINT_PEPPER على الخادم أولًا.';

  @override
  String get devAdminSaveFailed => 'تعذّر حفظ الإعداد.';

  @override
  String get audTokenCreated => 'أنشأ رمز API';

  @override
  String get audTokenRevoked => 'ألغى رمز API';

  @override
  String get audWebhookCreated => 'أضاف webhook';

  @override
  String get audWebhookUpdated => 'عدّل webhook';

  @override
  String get audWebhookDeleted => 'حذف webhook';

  @override
  String get audWebhookDisabled => 'أُوقف webhook بعد إخفاقات متكررة';

  @override
  String get audFormCreated => 'أنشأ نموذج استقبال';

  @override
  String get audFormUpdated => 'عدّل نموذج استقبال';

  @override
  String get audFormDeleted => 'حذف نموذج استقبال';

  @override
  String get audFormSubmitted => 'أرسل نموذج استقبال';

  @override
  String get audGoalCreated => 'أنشأ هدفاً';

  @override
  String get audGoalUpdated => 'عدّل هدفاً';

  @override
  String get audGoalDeleted => 'حذف هدفاً';

  @override
  String audGoalFolderCreated(String name) {
    return 'أنشأ مجلد الأهداف $name';
  }

  @override
  String audGoalFolderRenamed(String before, String after) {
    return 'أعاد تسمية مجلد الأهداف $before إلى $after';
  }

  @override
  String audGoalFolderDeleted(String name) {
    return 'حذف مجلد الأهداف $name';
  }

  @override
  String audGoalKrCreated(String name) {
    return 'أضاف النتيجة الرئيسية $name';
  }

  @override
  String audGoalKrUpdated(String name) {
    return 'عدّل النتيجة الرئيسية $name';
  }

  @override
  String audGoalKrDeleted(String name) {
    return 'حذف النتيجة الرئيسية $name';
  }

  @override
  String audGoalCheckedIn(String value, String name) {
    return 'سجّل $value لـ $name';
  }

  @override
  String get audTemplateCreated => 'أنشأ قالباً';

  @override
  String get audTemplateUpdated => 'عدّل قالباً';

  @override
  String get audTemplateDeleted => 'حذف قالباً';

  @override
  String get audTemplateApplied => 'استخدم قالباً';

  @override
  String get audWorkloadCapacity => 'حدّد سعة';

  @override
  String get audWorkloadTimeOffCreated => 'أضاف إجازة';

  @override
  String get audWorkloadTimeOffUpdated => 'عدّل إجازة';

  @override
  String get audWorkloadTimeOffDeleted => 'حذف إجازة';

  @override
  String get audWorkloadHolidayCreated => 'أضاف عطلة';

  @override
  String get audWorkloadHolidayUpdated => 'عدّل عطلة';

  @override
  String get audWorkloadHolidayDeleted => 'حذف عطلة';

  @override
  String get audWorkloadEstimateSet => 'حدّد تقديراً';

  @override
  String get audSecuritySsoConfigured => 'أعدّ تسجيل الدخول الموحد';

  @override
  String get audSecuritySsoRemoved => 'أزال تسجيل الدخول الموحد';

  @override
  String get audSecuritySsoMemberJoined => 'انضم عبر تسجيل الدخول الموحد';

  @override
  String get audSecuritySsoRoleChanged => 'تغيّر دوره عبر تسجيل الدخول الموحد';

  @override
  String get audSecurityPolicyChanged => 'غيّر سياسة الأمان';

  @override
  String get devWebhookProject => 'المشروع';

  @override
  String get devWebhookWholeWorkspace => 'مساحة العمل بأكملها';

  @override
  String updNoticeText(String version) {
    return 'الإصدار $version متاح.';
  }

  @override
  String get updNoticeGet => 'تنزيل';

  @override
  String get updNoticeDismiss => 'إغلاق';

  @override
  String get grpMImpClickupApi => 'ClickUp (رمز API)';

  @override
  String get grpCImpCuTokenHint => 'رمز API الشخصي في ClickUp';

  @override
  String get grpCImpCuTokenNote => 'يُستخدم فقط لقراءة قوائمك ولا يتم حفظه.';

  @override
  String get grpCImpCuLoad => 'عرض قوائمي';

  @override
  String get grpCImpCuPick => 'اختر القوائم المراد استيرادها';

  @override
  String get grpCImpCuFetch => 'جلب القوائم المحددة';

  @override
  String get grpCImpCuFetching => 'جارٍ الجلب من ClickUp…';

  @override
  String get chatTitle => 'الدردشة';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد — ستظهر هنا التغييرات والمحادثات';

  @override
  String get chatHideChanges => 'إخفاء التغييرات';

  @override
  String get chatLoadEarlier => 'تحميل الرسائل الأقدم';

  @override
  String chatEvTitle(String from, String to) {
    return 'غيّر عنوان هذه المهمة من «$from» إلى «$to»';
  }

  @override
  String chatEvStatus(String from, String to) {
    return 'غيّر الحالة من $from إلى $to';
  }

  @override
  String chatEvPriority(String from, String to) {
    return 'غيّر الأولوية من $from إلى $to';
  }

  @override
  String chatEvStartDate(String from, String to) {
    return 'غيّر تاريخ البدء من $from إلى $to';
  }

  @override
  String chatEvDueDate(String from, String to) {
    return 'غيّر تاريخ الاستحقاق من $from إلى $to';
  }

  @override
  String chatEvEstimate(String from, String to) {
    return 'غيّر التقدير من $from إلى $to';
  }

  @override
  String chatEvSubtask(String title) {
    return 'أضاف المهمة الفرعية «$title»';
  }

  @override
  String get chatEvOther => 'غيّر حقلًا';

  @override
  String get chatActorAutomation => 'عملية أتمتة';

  @override
  String get chatActorForm => 'نموذج';

  @override
  String get chatActorImport => 'عملية استيراد';

  @override
  String get chatActorSystem => 'النظام';

  @override
  String chatTitleCount(int count) {
    return 'الدردشة ($count)';
  }

  @override
  String get chatSectionChannels => 'القنوات';

  @override
  String get chatSectionGroups => 'المجموعات';

  @override
  String get chatSectionDms => 'الرسائل المباشرة';

  @override
  String get chatSectionTaskChats => 'محادثات المهام';

  @override
  String get chatSearchHint => 'البحث في المحادثات';

  @override
  String get chatNoSpaces => 'لا توجد محادثات بعد. ابدأ واحدة بزر «جديد».';

  @override
  String get chatNoMatches => 'لا شيء يطابق بحثك';

  @override
  String get chatMuted => 'مكتومة';

  @override
  String get chatNew => 'جديد';

  @override
  String get chatNewChannel => 'قناة';

  @override
  String get chatNewGroup => 'مجموعة';

  @override
  String get chatNewMessage => 'رسالة';

  @override
  String get chatNameLabel => 'الاسم';

  @override
  String get chatMembersLabel => 'الأعضاء';

  @override
  String get chatPickPerson => 'اختر شخصًا';

  @override
  String get chatCreate => 'إنشاء';

  @override
  String get chatNameRequired => 'أدخل اسمًا';

  @override
  String get chatGroupNeedsMembers => 'اختر شخصًا آخر على الأقل';

  @override
  String get chatSayHi => 'قل مرحبًا';

  @override
  String get chatSelectSpace => 'اختر محادثة لتبدأ الحديث';

  @override
  String get chatUnreadDivider => 'رسائل جديدة';

  @override
  String get chatJumpLatest => 'انتقل إلى الأحدث';

  @override
  String get chatWriteMessage => 'اكتب رسالة…';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatReply => 'رد';

  @override
  String chatReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رد',
      many: '$count ردًا',
      few: '$count ردود',
      two: 'ردان',
      one: 'رد واحد',
      zero: 'لا ردود',
    );
    return '$_temp0';
  }

  @override
  String get chatThread => 'سلسلة الردود';

  @override
  String get chatBack => 'رجوع';

  @override
  String get chatEdit => 'تعديل';

  @override
  String get chatDelete => 'حذف';

  @override
  String get chatRemoved => 'تمت إزالة الرسالة';

  @override
  String get chatEdited => 'معدّلة';

  @override
  String get chatMessageActions => 'إجراءات الرسالة';

  @override
  String get chatSending => 'جارٍ الإرسال…';

  @override
  String get chatNotSent => 'لم تُرسل';

  @override
  String get chatDiscard => 'تجاهل';

  @override
  String get chatBroadcastTitle => 'إشعار الجميع؟';

  @override
  String chatBroadcastBody(int count) {
    return 'ستُشعر هذه الرسالة $count شخصًا. هل ترسلها على أي حال؟';
  }

  @override
  String get chatBroadcastSend => 'أرسل على أي حال';

  @override
  String get chatSettings => 'إعدادات المحادثة';

  @override
  String get chatUnmute => 'إلغاء الكتم';

  @override
  String get chatMute1h => 'كتم لمدة ساعة';

  @override
  String get chatMute8h => 'كتم لمدة 8 ساعات';

  @override
  String get chatMuteWeek => 'كتم لمدة أسبوع';

  @override
  String get chatMuteForever => 'كتم حتى أعيد تفعيلها';

  @override
  String get chatMuteCompletely => 'كتم كامل حتى إشارات @ إليّ';

  @override
  String get chatNotifyAll => 'أشعرني بكل رسالة';

  @override
  String get chatLeave => 'مغادرة';

  @override
  String get chatJoin => 'انضمام';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
      zero: 'لا أعضاء',
    );
    return '$_temp0';
  }

  @override
  String get chatReadOnlyArchived =>
      'هذه المساحة مؤرشفة. يمكنك قراءتها لكن لا يمكنك الكتابة فيها.';

  @override
  String get chatReadOnlyFormer => 'هذه المحادثة للقراءة فقط.';

  @override
  String get chatNotMember => 'انضم إلى هذه القناة للكتابة فيها.';

  @override
  String get chatFormerMember => 'عضو سابق';

  @override
  String chatUnreadLabel(int count) {
    return '$count غير مقروءة';
  }

  @override
  String chatEntryMessage(String space) {
    return 'رسالة محادثة في $space';
  }
}
