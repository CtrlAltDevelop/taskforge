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
      few: 'جارٍ النسخ… $count مهام',
      two: 'جارٍ النسخ… مهمتان',
      one: 'جارٍ النسخ… مهمة واحدة',
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
      other: '$count يومًا متبقيًا',
      few: '$count أيام متبقية',
      two: 'يومان متبقيان',
      one: 'يوم واحد متبقٍ',
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
    return 'v$version';
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
      other: 'تم التعديل $count مرات: انقر لعرض السجل',
      one: 'تم التعديل مرة واحدة: انقر لعرض السجل',
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
    return 'تم تحديث $count من المهام المفتوحة اللاحقة.';
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
      other: 'لديها $count مهام فرعية. ماذا يجب أن يحدث لها؟',
      one: 'لديها مهمة فرعية واحدة. ماذا يجب أن يحدث لها؟',
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
      other: '$count مهام فرعية لم تنتهِ. هل تنقلها إلى $status أيضًا؟',
      one: 'مهمة فرعية واحدة لم تنتهِ. هل تنقلها إلى $status أيضًا؟',
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
      other: '$count ملاحظات حول هذا الملف',
      one: 'ملاحظة واحدة حول هذا الملف',
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
      other: '$count مشكلات يجب إصلاحها قبل الحفظ',
      one: 'مشكلة واحدة يجب إصلاحها قبل الحفظ',
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
      other: '$count مهام',
      one: 'مهمة واحدة',
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
      other: '$count مهام في هذه الحالة. اختر وجهتها.',
      one: 'مهمة واحدة في هذه الحالة. اختر وجهتها.',
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
      other: 'مهام',
      one: 'مهمة',
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
      other: '$count أيام',
      one: 'يوم واحد',
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
      other: '$count خيارات',
      one: 'خيار واحد',
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
}
