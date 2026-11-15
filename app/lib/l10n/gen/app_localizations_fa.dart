// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'تسک‌فورج';

  @override
  String get retry => 'تلاش دوباره';

  @override
  String get cancel => 'لغو';

  @override
  String get save => 'ذخیره';

  @override
  String get close => 'بستن';

  @override
  String get signOut => 'خروج';

  @override
  String get inbox => 'صندوق ورودی';

  @override
  String get workspaceSettings => 'تنظیمات فضای کاری';

  @override
  String get homeLoadWorkspacesFailed =>
      'بارگذاری فضاهای کاری ممکن نشد. تلاش دوباره';

  @override
  String get homeLoadAccountFailed => 'بارگذاری حساب شما ممکن نشد.';

  @override
  String get calendar => 'تقویم';

  @override
  String get calendarSubtitle => 'همهٔ موعدها در پروژه‌های شما';

  @override
  String get notificationSettings => 'تنظیمات اعلان‌ها';

  @override
  String get notificationSettingsSubtitle =>
      'چه چیزی به شما اطلاع می‌دهد، ساعت‌های سکوت و خلاصه';

  @override
  String get offlineAndStorage => 'آفلاین و حافظه';

  @override
  String get offlineAndStorageSubtitle => 'تغییرات آفلاین، نسخهٔ محلی';

  @override
  String get sessions => 'نشست‌ها';

  @override
  String get sessionsSubtitle => 'دستگاه‌هایی که وارد حساب شما شده‌اند';

  @override
  String get changePassword => 'تغییر گذرواژه';

  @override
  String get connectivity => 'اتصال';

  @override
  String get languageAndRegion => 'زبان و منطقه';

  @override
  String get languageAndRegionSubtitle => 'زبان، تقویم، آغاز هفته و ارقام';

  @override
  String get signIn => 'ورود';

  @override
  String get createAccount => 'ایجاد حساب';

  @override
  String get forgotPassword => 'گذرواژه را فراموش کرده‌اید؟';

  @override
  String get createAnAccount => 'ایجاد حساب کاربری';

  @override
  String get alreadyHaveAccount => 'از قبل حساب دارم';

  @override
  String get resetPassword => 'بازنشانی گذرواژه';

  @override
  String get sendCode => 'ارسال کد';

  @override
  String get backToSignIn => 'بازگشت به ورود';

  @override
  String get setNewPassword => 'تعیین گذرواژهٔ جدید';

  @override
  String get updatePassword => 'به‌روزرسانی گذرواژه';

  @override
  String get codeFromEmail => 'کد دریافتی از ایمیل';

  @override
  String get email => 'ایمیل';

  @override
  String get password => 'گذرواژه';

  @override
  String get currentPassword => 'گذرواژهٔ فعلی';

  @override
  String get newPassword => 'گذرواژهٔ جدید';

  @override
  String get showPassword => 'نمایش گذرواژه';

  @override
  String get hidePassword => 'پنهان کردن گذرواژه';

  @override
  String get passwordChanged => 'گذرواژه تغییر کرد. دوباره وارد شوید.';

  @override
  String get passwordUpdated => 'گذرواژه به‌روز شد. با آن وارد شوید.';

  @override
  String get enterEmail => 'نشانی ایمیل خود را وارد کنید.';

  @override
  String get enterValidEmail => 'یک نشانی ایمیل معتبر وارد کنید.';

  @override
  String get enterPassword => 'یک گذرواژه وارد کنید.';

  @override
  String passwordTooShort(int min) {
    return 'دست‌کم $min نویسه استفاده کنید.';
  }

  @override
  String get enterResetCode => 'کدی را که به ایمیل شما آمده وارد کنید.';

  @override
  String get enterYourPassword => 'گذرواژهٔ خود را وارد کنید.';

  @override
  String get errWrongCredentials => 'ایمیل یا گذرواژه نادرست است.';

  @override
  String get errTooManyAttempts =>
      'تلاش‌های بیش از حد. چند دقیقه بعد دوباره امتحان کنید.';

  @override
  String get errAccountExists => 'حسابی با این ایمیل از قبل وجود دارد.';

  @override
  String get errServerProblem => 'سرور مشکل داشت. کمی بعد دوباره امتحان کنید.';

  @override
  String get errNoConnection =>
      'اتصال به سرور برقرار نشد. اتصال خود را بررسی کنید و دوباره امتحان کنید.';

  @override
  String get errGeneric => 'مشکلی پیش آمد. دوباره امتحان کنید.';

  @override
  String get languageLabel => 'زبان';

  @override
  String get calendarSystemLabel => 'تقویم';

  @override
  String get calendarGregorian => 'میلادی';

  @override
  String get calendarJalali => 'جلالی (هجری شمسی)';

  @override
  String get weekStartLabel => 'هفته شروع می‌شود از';

  @override
  String get weekStartDefault => 'پیش‌فرض زبان';

  @override
  String get weekSaturday => 'شنبه';

  @override
  String get weekSunday => 'یکشنبه';

  @override
  String get weekMonday => 'دوشنبه';

  @override
  String get numeralsLabel => 'ارقام';

  @override
  String get numeralsLatin => 'لاتین (0123)';

  @override
  String get numeralsNative => 'ارقام فارسی (۰۱۲۳)';

  @override
  String get previewLabel => 'پیش‌نمایش';

  @override
  String get prefsSaveFailed =>
      'فقط روی این دستگاه ذخیره شد. به سرور دسترسی نداشتیم.';

  @override
  String get workspaceDefaultLanguage => 'زبان پیش‌فرض اعضای جدید';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه',
      one: '۱ وظیفه',
      zero: 'بدون وظیفه',
    );
    return '$_temp0';
  }

  @override
  String get jalaliMonth1 => 'فروردین';

  @override
  String get jalaliMonth2 => 'اردیبهشت';

  @override
  String get jalaliMonth3 => 'خرداد';

  @override
  String get jalaliMonth4 => 'تیر';

  @override
  String get jalaliMonth5 => 'مرداد';

  @override
  String get jalaliMonth6 => 'شهریور';

  @override
  String get jalaliMonth7 => 'مهر';

  @override
  String get jalaliMonth8 => 'آبان';

  @override
  String get jalaliMonth9 => 'آذر';

  @override
  String get jalaliMonth10 => 'دی';

  @override
  String get jalaliMonth11 => 'بهمن';

  @override
  String get jalaliMonth12 => 'اسفند';

  @override
  String get pickDateOk => 'تأیید';

  @override
  String get pickDateTitle => 'انتخاب تاریخ';

  @override
  String get previousMonth => 'ماه قبل';

  @override
  String get nextMonth => 'ماه بعد';

  @override
  String get weekdayShortMon => 'دوشنبه';

  @override
  String get weekdayShortTue => 'سه‌شنبه';

  @override
  String get weekdayShortWed => 'چهارشنبه';

  @override
  String get weekdayShortThu => 'پنجشنبه';

  @override
  String get weekdayShortFri => 'جمعه';

  @override
  String get weekdayShortSat => 'شنبه';

  @override
  String get weekdayShortSun => 'یکشنبه';

  @override
  String get grpACancel => 'انصراف';

  @override
  String get grpASave => 'ذخیره';

  @override
  String get grpARetry => 'تلاش مجدد';

  @override
  String get grpADone => 'انجام شد';

  @override
  String get grpAClose => 'بستن';

  @override
  String get grpAEdit => 'ویرایش';

  @override
  String get grpADelete => 'حذف';

  @override
  String get grpANote => 'یادداشت';

  @override
  String get grpATotal => 'مجموع';

  @override
  String get grpATask => 'وظیفه';

  @override
  String get grpAMerge => 'ادغام';

  @override
  String get grpARemove => 'حذف';

  @override
  String get grpAOfflineBack => 'بازگشت';

  @override
  String get grpAOfflineTitle => 'آفلاین و فضای ذخیره';

  @override
  String get grpAOfflineChooseWorkspace => 'ابتدا یک فضای کار انتخاب کنید.';

  @override
  String get grpAOfflineNeedsAttention => 'نیازمند توجه شما';

  @override
  String get grpAOfflineNothingToDecide =>
      'هیچ. همه تغییرات آفلاین ارسال شدند.';

  @override
  String grpAOfflineWaiting(int count) {
    return 'در انتظار ارسال ($count)';
  }

  @override
  String get grpASyncNow => 'همگام‌سازی اکنون';

  @override
  String get grpAOfflineNothingWaiting => 'چیزی در انتظار نیست.';

  @override
  String get grpAEntryATask => 'یک وظیفه';

  @override
  String grpAEntryNewTask(String title) {
    return 'وظیفه جدید «$title»';
  }

  @override
  String grpAEntryEdit(String name, String fields) {
    return 'ویرایش $name: $fields';
  }

  @override
  String grpAEntryDelete(String name) {
    return 'حذف $name';
  }

  @override
  String grpAEntryComment(String name) {
    return 'نظر درباره $name';
  }

  @override
  String grpAEntryUpload(String file, String name) {
    return 'بارگذاری «$file» در $name';
  }

  @override
  String grpAOfflineClash(String field, String current, String mine) {
    return 'آنها ($field): $current\nشما: $mine';
  }

  @override
  String get grpAKeepMine => 'نگه داشتن مال من';

  @override
  String get grpATakeTheirs => 'گرفتن مال آنها';

  @override
  String get grpATryAgain => 'دوباره تلاش کنید';

  @override
  String get grpADiscard => 'دور انداختن';

  @override
  String get grpAMergeTitle => 'کدام تغییرات شما حفظ شود؟';

  @override
  String get grpAStorage => 'فضای ذخیره';

  @override
  String get grpAReading => 'در حال خواندن…';

  @override
  String grpAStorageUsage(String size, int cap) {
    return 'نسخه روی این دستگاه $size مگابایت از حداکثر $cap مگابایت را اشغال کرده است.';
  }

  @override
  String get grpAMostItMayHold => 'حداکثر مقدار مجاز';

  @override
  String grpAMegabytes(int mb) {
    return '$mb مگابایت';
  }

  @override
  String get grpAClearCopy => 'پاک کردن نسخه روی این دستگاه';

  @override
  String get grpAStorageNote =>
      'تغییراتی که هنوز در انتظار ارسال هستند حفظ می‌شوند. نسخه بدون رمزگذاری ذخیره می‌شود: از رمزگذاری دیسک دستگاه خود استفاده کنید.';

  @override
  String get grpAClearTitle => 'نسخه روی این دستگاه پاک شود؟';

  @override
  String get grpAClearBody =>
      'آنچه خوانده‌اید هنگام آنلاین بودن دوباره دریافت می‌شود. تغییرات در انتظار ارسال حذف نمی‌شوند.';

  @override
  String get grpAClear => 'پاک کردن';

  @override
  String get grpAKeepOfflineTitle => 'نگه داشتن پروژه‌ها به صورت آفلاین';

  @override
  String get grpAKeepOfflineBody =>
      'پروژه نگه‌داشته‌شده کامل کپی می‌شود، پس وظایف، وضعیت‌ها و اعضای آن بدون اتصال در دسترس‌اند. پروژه‌های دیگر آخرین چیزی را که خوانده‌اید نشان می‌دهند.';

  @override
  String grpACopying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'در حال کپی… $count وظیفه',
      one: 'در حال کپی… ۱ وظیفه',
    );
    return '$_temp0';
  }

  @override
  String get grpASprintsTitle => 'اسپرینت‌ها';

  @override
  String grpASprintsTitleProject(String name) {
    return 'اسپرینت‌ها · $name';
  }

  @override
  String get grpASprintsDisabled =>
      'اسپرینت‌ها برای این پروژه خاموش هستند. آن‌ها را در تنظیمات پروژه روشن کنید.';

  @override
  String get grpAProjectNotFound => 'پروژه پیدا نشد.';

  @override
  String grpAAddedAfterStart(int count) {
    return '$count مورد پس از شروع اسپرینت اضافه شد (به‌عنوان تغییر دامنه نمایش داده می‌شود).';
  }

  @override
  String grpASprintCompleted(String name) {
    return '$name تکمیل شد.';
  }

  @override
  String get grpAPlanning => 'برنامه‌ریزی';

  @override
  String get grpAReports => 'گزارش‌ها';

  @override
  String get grpANewSprint => 'اسپرینت جدید';

  @override
  String get grpABacklog => 'بک‌لاگ';

  @override
  String get grpABacklogEmpty => 'بک‌لاگ خالی است.';

  @override
  String get grpAAddToSprint => 'افزودن به اسپرینت';

  @override
  String get grpANoOpenSprint =>
      'اسپرینت بازی وجود ندارد. برای شروع برنامه‌ریزی یکی بسازید.';

  @override
  String get grpADragHere =>
      'وظایف را به اینجا بکشید یا چند مورد را در بک‌لاگ انتخاب کنید.';

  @override
  String grpADatesRange(String start, String end) {
    return '$start تا $end';
  }

  @override
  String grpADaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count روز مانده',
      one: '۱ روز مانده',
    );
    return '$_temp0';
  }

  @override
  String grpASprintGoalText(String goal) {
    return 'هدف: $goal';
  }

  @override
  String get grpAShowOnBoard => 'نمایش روی برد';

  @override
  String get grpAEditSprint => 'ویرایش اسپرینت';

  @override
  String get grpAStartSprint => 'شروع اسپرینت';

  @override
  String get grpACompleteSprint => 'تکمیل اسپرینت';

  @override
  String get grpANoSprintsYet => 'هنوز اسپرینتی وجود ندارد.';

  @override
  String get grpASprintNameRequired => 'برای اسپرینت یک نام بگذارید.';

  @override
  String get grpASprintDatesFormat =>
      'تاریخ‌ها به صورت YYYY-MM-DD نوشته می‌شوند.';

  @override
  String get grpASprintEndBeforeStart =>
      'اسپرینت نمی‌تواند پیش از شروع خود پایان یابد.';

  @override
  String get grpASprintCapacityNumber =>
      'ظرفیت یک عدد است، یا برای نداشتن خالی بگذارید.';

  @override
  String get grpASprintSaved => 'اسپرینت ذخیره شد';

  @override
  String get grpASprintName => 'نام';

  @override
  String get grpASprintGoal => 'هدف';

  @override
  String get grpASprintStartLabel => 'شروع (YYYY-MM-DD)';

  @override
  String get grpASprintEndLabel => 'پایان (YYYY-MM-DD)';

  @override
  String get grpAPickStartDate => 'انتخاب تاریخ شروع';

  @override
  String get grpAPickEndDate => 'انتخاب تاریخ پایان';

  @override
  String get grpACapacityPointsOptional => 'ظرفیت بر حسب امتیاز (اختیاری)';

  @override
  String get grpACapacityHoursOptional => 'ظرفیت بر حسب ساعت (اختیاری)';

  @override
  String grpASprintOverlap(String names) {
    return 'این تاریخ‌ها با $names همپوشانی دارند.';
  }

  @override
  String grpACompleteTitle(String name) {
    return 'تکمیل $name';
  }

  @override
  String grpACompleteCounts(int done, int open) {
    return '$done انجام‌شده، $open ناتمام';
  }

  @override
  String get grpACompleteWhatHappens => 'با وظایف ناتمام چه شود؟';

  @override
  String get grpACompleteMoveNext => 'انتقال به اسپرینت بعدی';

  @override
  String get grpACompleteNoPlanned =>
      'اسپرینت برنامه‌ریزی‌شده‌ای برای انتقال وجود ندارد';

  @override
  String get grpACompleteBackToBacklog => 'بازگشت به بک‌لاگ';

  @override
  String grpAPointsFor(String key) {
    return 'امتیاز برای $key';
  }

  @override
  String get grpAPointsInvalid =>
      'یک عدد وارد کنید یا برای پاک کردن خالی بگذارید.';

  @override
  String get grpAStoryPoints => 'امتیاز داستان';

  @override
  String get grpACapacityInHours => 'ظرفیت بر حسب ساعت';

  @override
  String get grpACapacityInPoints => 'ظرفیت بر حسب امتیاز';

  @override
  String grpABurndownTitle(String name) {
    return 'نمودار سوخت: $name';
  }

  @override
  String get grpAPoints => 'امتیاز';

  @override
  String get grpATasks => 'وظایف';

  @override
  String get grpABurndownEmpty => 'نمودار سوخت پس از شروع اسپرینت آغاز می‌شود.';

  @override
  String grpABurndownChart(int days, int changes) {
    return 'نمودار سوخت، $days روز، $changes تغییر دامنه';
  }

  @override
  String grpABurndownBackfilled(int count) {
    return '، $count روز تکمیل‌شده با تأخیر';
  }

  @override
  String get grpALegendRemaining => 'باقی‌مانده';

  @override
  String get grpALegendIdeal => 'ایده‌آل';

  @override
  String get grpALegendScopeChange => 'تغییر دامنه';

  @override
  String get grpALegendBackfilled => 'روز تکمیل‌شده با تأخیر';

  @override
  String get grpAVelocityEmpty =>
      'سرعت پس از اولین اسپرینت تکمیل‌شده نمایش داده می‌شود.';

  @override
  String grpAVelocityTitle(int count, String average) {
    return 'سرعت ($count اسپرینت اخیر): میانگین $average امتیاز';
  }

  @override
  String grpAVelocityChart(int count) {
    return 'نمودار سرعت، $count اسپرینت';
  }

  @override
  String get grpALegendCommitted => 'متعهد‌شده';

  @override
  String get grpALegendCompleted => 'تکمیل‌شده';

  @override
  String get grpATimesheetTitle => 'برگه زمان';

  @override
  String get grpAPreviousWeek => 'هفته قبل';

  @override
  String get grpANextWeek => 'هفته بعد';

  @override
  String get grpAThisWeek => 'این هفته';

  @override
  String get grpATimesheetEmpty => 'این هفته زمانی ثبت نشده است.';

  @override
  String get grpARunning => 'در حال اجرا';

  @override
  String get grpAAddTime => 'افزودن زمان';

  @override
  String get grpAYou => 'شما';

  @override
  String get grpAProjectTotals => 'مجموع پروژه';

  @override
  String get grpAChooseProject => 'یک پروژه انتخاب کنید';

  @override
  String get grpATotalsEmpty => 'این هفته زمانی در این پروژه ثبت نشده است.';

  @override
  String grpABillableAmount(String duration) {
    return '  ($duration قابل صورتحساب)';
  }

  @override
  String get grpAEditTime => 'ویرایش زمان';

  @override
  String get grpATimeSpent => 'زمان صرف‌شده';

  @override
  String get grpABillable => 'قابل صورتحساب';

  @override
  String get grpABadDuration => 'زمانی مانند 1h 30m، 90m یا 1:30 وارد کنید.';

  @override
  String get grpAEstimate => 'برآورد';

  @override
  String get grpAEstimatedTime => 'زمان برآوردشده';

  @override
  String get grpAEmptyForNone => 'برای نداشتن خالی بگذارید';

  @override
  String get grpADeleteTimeTitle => 'این زمان حذف شود؟';

  @override
  String get grpADeleteTimeBody => 'زمان ثبت‌شده برای همیشه حذف می‌شود.';

  @override
  String get grpAKeep => 'نگه داشتن';

  @override
  String get grpBCancel => 'انصراف';

  @override
  String get grpBOk => 'تأیید';

  @override
  String get grpBClose => 'بستن';

  @override
  String get grpBSave => 'ذخیره';

  @override
  String get grpBRetry => 'تلاش دوباره';

  @override
  String get grpBRestore => 'بازیابی';

  @override
  String get grpBHistory => 'تاریخچه';

  @override
  String get grpBCopy => 'کپی';

  @override
  String get grpBSaveAsFile => 'ذخیره به‌عنوان فایل';

  @override
  String get grpBReply => 'پاسخ';

  @override
  String get grpBEdit => 'ویرایش';

  @override
  String get grpBDelete => 'حذف';

  @override
  String get grpBBack => 'بازگشت';

  @override
  String get grpBSomeone => 'یک نفر';

  @override
  String get grpBYou => 'شما';

  @override
  String get grpBLoading => 'در حال بارگذاری…';

  @override
  String get grpBPages => 'صفحه‌ها';

  @override
  String get grpBRestricted => 'محدود';

  @override
  String get grpBLinkTitle => 'پیوند';

  @override
  String get grpBLinkAddressLabel => 'نشانی (http، https یا mailto)';

  @override
  String get grpBLinkInvalid => 'از نشانی http، https یا mailto استفاده کنید.';

  @override
  String get grpBIconTitle => 'نماد صفحه';

  @override
  String get grpBIconLabel => 'ایموجی یا متن کوتاه (برای هیچ، خالی بگذارید)';

  @override
  String get grpBIconInvalid => 'حداکثر چهار نویسه استفاده کنید.';

  @override
  String get grpBImageTitle => 'تصویر';

  @override
  String get grpBImageAddressLabel => 'نشانی تصویر (http یا https)';

  @override
  String get grpBDescription => 'توضیح';

  @override
  String get grpBImageInvalid => 'از نشانی http یا https استفاده کنید.';

  @override
  String get grpBEmbedTaskTitle => 'جاسازی یک وظیفه';

  @override
  String get grpBTaskSearchLabel => 'جستجوی وظایف یا چسباندن پیوند وظیفه';

  @override
  String get grpBUsePastedTask => 'استفاده از وظیفه چسبانده‌شده';

  @override
  String get grpBSnippetRemoved => '(حذف‌شده)';

  @override
  String get grpBConflictTitle => 'شخص دیگری این صفحه را تغییر داد';

  @override
  String get grpBConflictClean =>
      'تغییرات آن‌ها با تغییرات شما همپوشانی ندارد. ادغام خواهند شد.';

  @override
  String get grpBConflictOverlap =>
      'هر دوی این بلوک‌ها را تغییر داده‌اید. انتخاب کنید کدام بماند؛ بقیه ادغام می‌شود.';

  @override
  String grpBConflictBlock(String snippet) {
    return 'بلوک: $snippet';
  }

  @override
  String grpBConflictMine(String snippet) {
    return 'من: $snippet';
  }

  @override
  String grpBConflictTheirs(String snippet) {
    return 'آن‌ها: $snippet';
  }

  @override
  String get grpBDecideLater => 'بعداً تصمیم می‌گیرم';

  @override
  String get grpBDiscardMine => 'دور انداختن تغییرات من';

  @override
  String get grpBApplyAndSave => 'اعمال و ذخیره';

  @override
  String get grpBShareTitle => 'دسترسی به صفحه';

  @override
  String get grpBShareRestrict => 'محدود کردن این صفحه';

  @override
  String get grpBShareRestrictedHint =>
      'فقط افراد زیر، سازنده و مدیران صفحه (برای صفحه‌های زیرمجموعه نیز).';

  @override
  String get grpBShareOpenHint =>
      'هر کسی که بتواند صفحه والد را باز کند می‌تواند این را هم باز کند.';

  @override
  String get grpBShareNeedPermission =>
      'برای تغییر این مورد به مجوز «doc.manage» نیاز دارید.';

  @override
  String get grpBEmptyPage => '(صفحه خالی)';

  @override
  String grpBImageBlock(String alt) {
    return '[تصویر $alt]';
  }

  @override
  String get grpBTaskCardBlock => '[کارت وظیفه]';

  @override
  String get grpBAllRevisions => 'همه نسخه‌ها';

  @override
  String get grpBNoRevisions => 'هنوز نسخه‌ای وجود ندارد.';

  @override
  String grpBVersionN(int version) {
    return 'نسخه $version';
  }

  @override
  String grpBVersionShort(int version) {
    return 'نسخه $version';
  }

  @override
  String get grpBRevisionsLoadFailed =>
      'بارگذاری تاریخچه ممکن نشد. تلاش دوباره';

  @override
  String get grpBRevisionLoadFailed => 'بارگذاری این نسخه ممکن نشد.';

  @override
  String get grpBRestoreVersion => 'بازیابی این نسخه';

  @override
  String grpBLinkedFrom(int count) {
    return 'پیوند شده از ($count)';
  }

  @override
  String get grpBNoBacklinks => 'هیچ صفحه‌ای به این صفحه اشاره نکرده است.';

  @override
  String grpBMarkdownTitle(String title) {
    return 'مارک‌داون: $title';
  }

  @override
  String get grpBMarkdownCopied => 'مارک‌داون کپی شد.';

  @override
  String get grpBSaveSaved => 'ذخیره شد';

  @override
  String get grpBSaveDirty => 'تغییرات ذخیره‌نشده';

  @override
  String get grpBSaveSaving => 'در حال ذخیره...';

  @override
  String get grpBSaveError => 'ذخیره ممکن نشد';

  @override
  String get grpBSaveConflict => 'تعارض: انتخاب کنید چه چیزی بماند';

  @override
  String get grpBDocsCrumb => 'اسناد';

  @override
  String get grpBDocNotFound =>
      'این صفحه وجود ندارد یا نمی‌توانید آن را باز کنید.';

  @override
  String get grpBBackToAllPages => 'بازگشت به همه صفحه‌ها';

  @override
  String get grpBArchivedBanner =>
      'این صفحه بایگانی شده است و فقط خواندنی است.';

  @override
  String get grpBConflictBanner =>
      'شخص دیگری این صفحه را تغییر داد. تغییرات شما هنوز ذخیره نشده است.';

  @override
  String get grpBResolve => 'حل';

  @override
  String get grpBRemoteBanner =>
      'نسخه جدیدتری توسط شخص دیگری ذخیره شده است. هنگام ذخیره ادغام خواهد شد.';

  @override
  String grpBIsEditing(String name) {
    return '$name در حال ویرایش است';
  }

  @override
  String grpBAreEditing(String names) {
    return '$names در حال ویرایش هستند';
  }

  @override
  String get grpBChangeIcon => 'تغییر نماد';

  @override
  String get grpBUntitled => 'بدون عنوان';

  @override
  String get grpBReadOnly => 'فقط خواندنی';

  @override
  String get grpBAccess => 'دسترسی';

  @override
  String get grpBExportMarkdown => 'صدور مارک‌داون';

  @override
  String grpBMoveUnder(String name) {
    return 'انتقال «$name» به زیر';
  }

  @override
  String get grpBTopLevel => 'سطح بالا';

  @override
  String get grpBCollapse => 'بستن';

  @override
  String get grpBExpand => 'باز کردن';

  @override
  String get grpBPageOptions => 'گزینه‌های صفحه';

  @override
  String get grpBNewSubpage => 'زیرصفحه جدید';

  @override
  String get grpBMoveUp => 'انتقال به بالا';

  @override
  String get grpBMoveDown => 'انتقال به پایین';

  @override
  String get grpBMoveTo => 'انتقال به...';

  @override
  String get grpBArchive => 'بایگانی';

  @override
  String get grpBHideArchived => 'پنهان کردن بایگانی‌شده‌ها';

  @override
  String get grpBShowArchived => 'نمایش بایگانی‌شده‌ها';

  @override
  String get grpBNewPage => 'صفحه جدید';

  @override
  String get grpBNoPagesYet => 'هنوز صفحه‌ای وجود ندارد.';

  @override
  String get grpBPagesLoadFailed => 'بارگذاری صفحه‌ها ممکن نشد. تلاش دوباره';

  @override
  String get grpBToday => 'امروز';

  @override
  String get grpBYesterday => 'دیروز';

  @override
  String get grpBSubtaskCreated => 'زیروظیفه ایجاد شد.';

  @override
  String get grpBComments => 'نظرها';

  @override
  String grpBCommentsCount(int count) {
    return 'نظرها ($count)';
  }

  @override
  String get grpBNoComments => 'هنوز نظری وجود ندارد.';

  @override
  String get grpBLoadEarlier => 'بارگذاری نظرهای قبلی';

  @override
  String get grpBPinned => 'سنجاق‌شده';

  @override
  String get grpBReplyHint => 'پاسخ…';

  @override
  String get grpBArchivedReadOnly =>
      'این پروژه بایگانی شده است: نظرها فقط خواندنی هستند.';

  @override
  String get grpBReadOnlyComments =>
      'می‌توانید نظرها را بخوانید اما نمی‌توانید بنویسید.';

  @override
  String get grpBCommentRemoved => 'نظر حذف شد';

  @override
  String get grpBUnpin => 'برداشتن سنجاق';

  @override
  String get grpBPin => 'سنجاق کردن';

  @override
  String get grpBMakeSubtask => 'تبدیل به زیروظیفه';

  @override
  String get grpBEditHistory => 'تاریخچه ویرایش';

  @override
  String grpBEditedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بار ویرایش شد: برای دیدن تاریخچه ضربه بزنید',
      one: 'یک بار ویرایش شد: برای دیدن تاریخچه ضربه بزنید',
    );
    return '$_temp0';
  }

  @override
  String get grpBEdited => 'ویرایش‌شده';

  @override
  String get grpBCommentActions => 'عملیات نظر';

  @override
  String get grpBWaitingToSend => 'در انتظار ارسال';

  @override
  String get grpBSending => 'در حال ارسال…';

  @override
  String get grpBNotSent => 'ارسال نشد';

  @override
  String get grpBDiscard => 'دور انداختن';

  @override
  String get grpBAddReaction => 'افزودن واکنش';

  @override
  String get grpBAuditAll => 'همه';

  @override
  String get grpBAuditTasks => 'وظایف';

  @override
  String get grpBAuditFiles => 'فایل‌ها';

  @override
  String get grpBAuditProjects => 'پروژه‌ها';

  @override
  String get grpBAuditMembers => 'اعضا';

  @override
  String get grpBAuditRoles => 'نقش‌ها';

  @override
  String get grpBAuditInvitations => 'دعوت‌ها';

  @override
  String get grpBAuditSignIn => 'ورود';

  @override
  String get grpBAuditTitle => 'گزارش ممیزی';

  @override
  String get grpBExportCsv => 'صدور به‌صورت CSV';

  @override
  String get grpBAuditDenied => 'اجازه خواندن گزارش ممیزی را ندارید.';

  @override
  String get grpBAuditEmpty => 'برای این فیلترها چیزی ثبت نشده است.';

  @override
  String get grpBShowOlder => 'نمایش قدیمی‌تر';

  @override
  String get grpBAnyone => 'هر کس';

  @override
  String get grpBAnyProject => 'هر پروژه';

  @override
  String get grpBAnyTime => 'هر زمان';

  @override
  String get grpBClearFilters => 'پاک کردن فیلترها';

  @override
  String get grpBBulkChange => 'بخشی از یک تغییر گروهی';

  @override
  String grpBCharacters(String size) {
    return '($size نویسه)';
  }

  @override
  String get grpBNoFieldChanges => 'هیچ تغییر فیلدی ثبت نشده است.';

  @override
  String get grpBAuditExportTitle => 'گزارش ممیزی (CSV)';

  @override
  String grpBAuditExportNote(int shown, int total) {
    return 'نمایش $shown خط اول از $total خط. کپی یا ذخیره همه را شامل می‌شود.';
  }

  @override
  String get grpBCsvCopied => 'CSV کپی شد.';

  @override
  String get grpCCancel => 'انصراف';

  @override
  String get grpCDelete => 'حذف';

  @override
  String get grpCRetry => 'تلاش مجدد';

  @override
  String get grpCBack => 'بازگشت';

  @override
  String get grpCUndo => 'بازگردانی';

  @override
  String get grpCField => 'فیلد';

  @override
  String get grpCStatus => 'وضعیت';

  @override
  String get grpCComment => 'نظر';

  @override
  String get grpCValue => 'مقدار';

  @override
  String get grpCDashNew => 'داشبورد جدید';

  @override
  String grpCDashDeleteTitle(String name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get grpCDashDeleteBody =>
      'ویجت‌های آن هم حذف می‌شوند. این کار قابل بازگشت نیست.';

  @override
  String get grpCDashTitle => 'داشبوردها';

  @override
  String grpCDashTitleProject(String project) {
    return 'داشبوردها · $project';
  }

  @override
  String get grpCDashEmpty => 'هنوز داشبوردی وجود ندارد.';

  @override
  String get grpCDashBlankDashboard => 'داشبورد خالی';

  @override
  String get grpCDashProjectOverview => 'نمای کلی پروژه';

  @override
  String get grpCDashMyWork => 'کارهای من';

  @override
  String get grpCDashBlank => 'خالی';

  @override
  String get grpCDashEdit => 'ویرایش';

  @override
  String get grpCDashRefresh => 'تازه‌سازی';

  @override
  String get grpCDashAddWidget => 'افزودن ویجت';

  @override
  String get grpCDashSave => 'ذخیره';

  @override
  String get grpCDashDialogTitle => 'داشبورد';

  @override
  String get grpCDashName => 'نام';

  @override
  String get grpCDashShareDenied =>
      'اشتراک‌گذاری به مجوز dashboard.manage نیاز دارد.';

  @override
  String get grpCDashOk => 'تأیید';

  @override
  String get grpCImpTitle => 'درون‌ریزی و برون‌بری';

  @override
  String get grpCImpExport => 'برون‌بری';

  @override
  String get grpCImpDenied =>
      'فقط مدیران می‌توانند داده‌ها را درون‌ریزی و برون‌بری کنند.';

  @override
  String get grpCImpPast => 'درون‌ریزی‌های قبلی';

  @override
  String get grpCImpNothing => 'هنوز چیزی درون‌ریزی نشده است.';

  @override
  String grpCImpTasksCount(int count) {
    return '$count وظیفه';
  }

  @override
  String get grpCImpResume => 'ادامه';

  @override
  String get grpCImpContinue => 'ادامه';

  @override
  String get grpCImpForget => 'فراموش کن';

  @override
  String get grpCImpUndoTitle => 'این درون‌ریزی بازگردانی شود؟';

  @override
  String get grpCImpUndoBody =>
      'آنچه ساخته بود حذف می‌شود. هر چه دستی افزوده‌اید حفظ می‌شود.';

  @override
  String get grpCImpUndoConfirm => 'بازگردانی درون‌ریزی';

  @override
  String grpCImpClaimTitle(String name) {
    return 'وظایف $name را بده به...';
  }

  @override
  String get grpCImpChooseMember => 'یک عضو را انتخاب کنید';

  @override
  String get grpCImpAssign => 'واگذاری';

  @override
  String grpCImpAssigned(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n وظیفه واگذار شد.',
      one: '$n وظیفه واگذار شد.',
    );
    return '$_temp0';
  }

  @override
  String get grpCImpWaiting => 'افراد در انتظار پیوستن';

  @override
  String get grpCImpWaitingBody =>
      'وقتی کسی با همان ایمیل بپیوندد، وظایفش خودکار واگذار می‌شود.';

  @override
  String get grpCImpNoEmail => 'بدون ایمیل';

  @override
  String grpCImpPersonSub(String email, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه',
      one: '$count وظیفه',
    );
    return '$email · $_temp0';
  }

  @override
  String get grpCImpAssignTo => 'واگذاری به...';

  @override
  String get grpCImpStepSource => 'منبع';

  @override
  String get grpCImpStepUpload => 'بارگذاری';

  @override
  String get grpCImpStepMap => 'نگاشت';

  @override
  String get grpCImpStepReview => 'بازبینی';

  @override
  String get grpCImpStepImport => 'درون‌ریزی';

  @override
  String get grpCImpWhere => 'داده‌های شما از کجا می‌آیند؟';

  @override
  String get grpCImpAuto => 'مطمئن نیستم: از روی فایل تشخیص بده';

  @override
  String get grpCImpNext => 'بعدی';

  @override
  String get grpCImpZipSeveral =>
      'این فایل زیپ چند فایل داده دارد. کدام را می‌خواهید درون‌ریزی کنید؟ (خروجی فضای کار برای هر پروژه یک فایل دارد.)';

  @override
  String get grpCImpChooseAFile => 'یک فایل را انتخاب کنید';

  @override
  String get grpCImpChooseGeneric =>
      'فایل مورد نظر برای درون‌ریزی را انتخاب کنید (‎.csv‎، ‎.json‎ یا یک ‎.zip‎ از آن).';

  @override
  String grpCImpChooseSource(String source) {
    return 'فایل $source خود را انتخاب کنید (‎.csv‎، ‎.json‎ یا یک ‎.zip‎ از آن).';
  }

  @override
  String get grpCImpSentNote =>
      'فایل به سرور TaskForge شما ارسال و به‌صورت جریانی خوانده می‌شود، پس خروجی‌های بزرگ مشکلی ندارند. تا تأیید نکنید چیزی تغییر نمی‌کند.';

  @override
  String get grpCImpPickFile => 'انتخاب فایل';

  @override
  String get grpCImpResumeThis => 'ادامه این درون‌ریزی';

  @override
  String get grpCImpWhatHappens => 'این اتفاق خواهد افتاد';

  @override
  String get grpCImpCountTasks => 'وظیفه';

  @override
  String get grpCImpCountSubtasks => 'از آن‌ها زیروظیفه';

  @override
  String get grpCImpCountComments => 'نظر';

  @override
  String get grpCImpCountLinks => 'پیوند';

  @override
  String get grpCImpCountSprints => 'اسپرینت';

  @override
  String get grpCImpCountLabels => 'برچسب';

  @override
  String get grpCImpCountStatuses => 'وضعیت جدید';

  @override
  String get grpCImpCountPlaceholders => 'فرد در انتظار';

  @override
  String grpCImpAlready(int count) {
    return '$count مورد از این‌ها قبلاً درون‌ریزی شده‌اند و تکراری نمی‌شوند و رد می‌شوند.';
  }

  @override
  String grpCImpRowErrors(int count) {
    return '$count ردیف قابل درون‌ریزی نیست و کنار گذاشته می‌شود.';
  }

  @override
  String get grpCImpResumeImport => 'ادامه درون‌ریزی';

  @override
  String get grpCImpStart => 'شروع درون‌ریزی';

  @override
  String get grpCImpUndoRunBody =>
      'وظایف، نظرها، پیوندها، اسپرینت‌ها و وضعیت‌هایی که این درون‌ریزی ساخته حذف می‌شوند. هر چه دستی به آن‌ها افزوده‌اید حفظ می‌شود.';

  @override
  String get grpCImpWaitingStart => 'در انتظار شروع...';

  @override
  String get grpCImpLinking => 'در حال پیوند وظایف...';

  @override
  String grpCImpProgress(int done, int total) {
    return '$done از $total وظیفه';
  }

  @override
  String get grpCImpCancel => 'لغو درون‌ریزی';

  @override
  String get grpCImpFinished => 'درون‌ریزی تمام شد';

  @override
  String get grpCImpUndone => 'درون‌ریزی بازگردانی شد';

  @override
  String get grpCImpCancelled => 'درون‌ریزی لغو شد';

  @override
  String get grpCImpStopped => 'درون‌ریزی متوقف شد';

  @override
  String get grpCImpOpenProject => 'باز کردن پروژه';

  @override
  String get grpCImpAnother => 'درون‌ریزی فایل دیگر';

  @override
  String grpCImpRemoved(num tasks) {
    return '$tasks وظیفه حذف شد.';
  }

  @override
  String grpCImpRemovedKept(num tasks, num kept) {
    return '$tasks وظیفه حذف شد، $kept وظیفه که زیروظایف خودتان را دارند حفظ شد.';
  }

  @override
  String get grpCImpTheFile => 'فایل';

  @override
  String grpCImpSummary(int issues, int comments, int links, String file) {
    return '$issues وظیفه، $comments نظر و $links پیوند در $file یافت شد.';
  }

  @override
  String grpCImpSummarySub(
    int issues,
    int subtasks,
    int comments,
    int links,
    String file,
  ) {
    return '$issues وظیفه ($subtasks زیروظیفه)، $comments نظر و $links پیوند در $file یافت شد.';
  }

  @override
  String get grpCImpPriUrgent => 'فوری';

  @override
  String get grpCImpPriHigh => 'بالا';

  @override
  String get grpCImpPriNormal => 'عادی';

  @override
  String get grpCImpPriLow => 'پایین';

  @override
  String get grpCImpPriNone => 'هیچ';

  @override
  String get grpCImpFTitle => 'عنوان *';

  @override
  String get grpCImpFDescription => 'توضیحات';

  @override
  String get grpCImpFPriority => 'اولویت';

  @override
  String get grpCImpFAssignee => 'مسئول';

  @override
  String get grpCImpFReporter => 'گزارش‌دهنده';

  @override
  String get grpCImpFCreated => 'ایجاد شده';

  @override
  String get grpCImpFUpdated => 'به‌روزرسانی شده';

  @override
  String get grpCImpFStart => 'تاریخ شروع';

  @override
  String get grpCImpFDue => 'سررسید';

  @override
  String get grpCImpFLabels => 'برچسب‌ها';

  @override
  String get grpCImpFSprint => 'اسپرینت';

  @override
  String get grpCImpFParent => 'والد (شناسه)';

  @override
  String get grpCImpFId => 'شناسه';

  @override
  String get grpCImpFKey => 'کلید';

  @override
  String get grpCImpFPoints => 'امتیاز داستان';

  @override
  String get grpCImpFEstimate => 'برآورد';

  @override
  String get grpCImpFType => 'نوع';

  @override
  String get grpCImpPriorities => 'اولویت‌ها';

  @override
  String grpCImpKeepLabels(int count) {
    return 'نگه داشتن $count برچسب';
  }

  @override
  String get grpCImpKeepLabelsSub => 'به‌صورت فیلد «برچسب‌ها» روی هر وظیفه.';

  @override
  String grpCImpSprintsCreated(String sprints) {
    return 'اسپرینت‌هایی که ساخته می‌شوند: $sprints';
  }

  @override
  String get grpCImpReview => 'بازبینی';

  @override
  String get grpCImpReadAs => 'خواندن به‌عنوان';

  @override
  String get grpCImpZipFile => 'فایل داخل زیپ';

  @override
  String get grpCImpChooseOne => 'یکی را انتخاب کنید';

  @override
  String get grpCImpInto => 'درون‌ریزی به';

  @override
  String get grpCImpNewProject => 'یک پروژه جدید';

  @override
  String get grpCImpExistingProject => 'یک پروژه موجود';

  @override
  String get grpCImpProjectName => 'نام پروژه';

  @override
  String get grpCImpColumns => 'ستون‌ها';

  @override
  String get grpCImpNotInFile => '(در فایل نیست)';

  @override
  String get grpCImpStatuses => 'وضعیت‌ها';

  @override
  String get grpCImpSameName => 'همان نام (در صورت نبود ایجاد شود)';

  @override
  String get grpCImpPeople => 'افراد';

  @override
  String get grpCImpNotMember => 'هنوز عضو نیست (هنگام پیوستن واگذار شود)';

  @override
  String get grpCImpUnassigned => 'بدون مسئول بگذار';

  @override
  String get grpCImpFirst200 =>
      'فقط ۲۰۰ نفر اول فهرست شده‌اند؛ بقیه به‌صورت جانشین منتظر می‌مانند.';

  @override
  String grpCAutoDeleteTitle(String name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get grpCAutoDeleteBody =>
      'قانون برای همیشه متوقف می‌شود. تاریخچه اجرای آن هم حذف می‌شود.';

  @override
  String get grpCAutoTitle => 'خودکارسازی‌ها';

  @override
  String grpCAutoTitleProject(String project) {
    return 'خودکارسازی‌ها · $project';
  }

  @override
  String get grpCAutoMissing => 'پروژه یافت نشد.';

  @override
  String get grpCAutoRules => 'قوانین';

  @override
  String get grpCAutoRunHistory => 'تاریخچه اجرا';

  @override
  String get grpCAutoNew => 'خودکارسازی جدید';

  @override
  String get grpCAutoReadOnly => 'فقط خواندنی';

  @override
  String grpCAutoLimit(int limit) {
    return 'به سقف $limit قانون رسیده‌اید.';
  }

  @override
  String grpCAutoRuleFilter(String name) {
    return 'قانون: $name';
  }

  @override
  String get grpCAutoEmpty =>
      'هنوز خودکارسازی‌ای وجود ندارد. یک قانون می‌گوید: وقتی چیزی رخ داد و اگر مطابقت داشت، این کارها را انجام بده.';

  @override
  String grpCAutoWhen(String trigger, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اقدام',
      one: '$count اقدام',
    );
    return 'وقتی $trigger · $_temp0';
  }

  @override
  String get grpCAutoNeverRun => 'هرگز اجرا نشده';

  @override
  String get grpCAutoHistory => 'تاریخچه';

  @override
  String get grpCAutoDryRun => 'اجرای آزمایشی';

  @override
  String get grpCAutoStatusChanges => 'وضعیتی تغییر می‌کند';

  @override
  String grpCAutoMovesTo(String status) {
    return 'وظیفه‌ای به $status منتقل می‌شود';
  }

  @override
  String grpCAutoFieldChanges(String field) {
    return '$field تغییر می‌کند';
  }

  @override
  String get grpCAutoSomeoneAssigned => 'کسی واگذار می‌شود';

  @override
  String grpCAutoUserAssigned(String user) {
    return '$user واگذار می‌شود';
  }

  @override
  String get grpCAutoDueReached => 'سررسید فرا می‌رسد';

  @override
  String grpCAutoDaysBefore(int days) {
    return '$days روز پیش از سررسید';
  }

  @override
  String get grpCAutoDeletedStatus => 'وضعیت حذف‌شده';

  @override
  String get grpCAutoUnknownPerson => 'فرد ناشناس';

  @override
  String get grpCAutoEvent => 'رویداد';

  @override
  String get grpCAutoMovesToLabel => 'منتقل می‌شود به';

  @override
  String get grpCAutoAnyStatus => 'هر وضعیت';

  @override
  String get grpCAutoAssignedPerson => 'فرد واگذارشده';

  @override
  String get grpCAutoAnyone => 'هر کسی';

  @override
  String grpCAutoDaysLabel(int max) {
    return 'روز پیش از سررسید (۰ تا $max)';
  }

  @override
  String grpCAutoTokensHelp(String tokens) {
    return 'می‌توانید از $tokens استفاده کنید';
  }

  @override
  String get grpCAutoDateHint => 'YYYY-MM-DD';

  @override
  String grpCAutoUseToken(String token) {
    return 'استفاده از $token';
  }

  @override
  String get grpCAutoHow => 'چگونه';

  @override
  String get grpCAutoReplaceAssignees => 'جایگزینی مسئولان با';

  @override
  String get grpCAutoAdd => 'افزودن';

  @override
  String get grpCAutoRemoveEveryone => 'حذف همه';

  @override
  String get grpCAutoSubtaskTitle => 'عنوان زیروظیفه';

  @override
  String get grpCAutoMessage => 'پیام';

  @override
  String get grpCAutoAddress => 'نشانی';

  @override
  String get grpCAutoAddressHelp =>
      'فقط نشانی‌های عمومی http(s)؛ نشانی‌های خصوصی رد می‌شوند.';

  @override
  String get grpCAutoMethod => 'روش';

  @override
  String get grpCAutoDoThis => 'این کار را انجام بده';

  @override
  String grpDActionFailed(String error) {
    return 'این کار انجام نشد ($error).';
  }

  @override
  String get grpDSwitchWorkspace => 'تغییر فضای کار';

  @override
  String grpDWorkspaceHere(String name) {
    return '$name (اینجا)';
  }

  @override
  String get grpDNewDoc => 'سند جدید';

  @override
  String get grpDTitle => 'عنوان';

  @override
  String get grpDUntitled => 'بدون عنوان';

  @override
  String get grpDNewDashboard => 'داشبورد جدید';

  @override
  String get grpDNewSprint => 'اسپرینت جدید';

  @override
  String grpDStatusOf(String id) {
    return 'وضعیت $id';
  }

  @override
  String get grpDNewTask => 'وظیفه جدید';

  @override
  String get grpDCancel => 'لغو';

  @override
  String get grpDCreate => 'ایجاد';

  @override
  String get grpDSort => 'مرتب‌سازی';

  @override
  String get grpDNoSort => 'بدون مرتب‌سازی';

  @override
  String grpDSortBy(String names) {
    return 'مرتب‌سازی: $names';
  }

  @override
  String get grpDGroup => 'گروه';

  @override
  String get grpDNoGrouping => 'بدون گروه‌بندی';

  @override
  String grpDGroupBy(String name) {
    return 'گروه: $name';
  }

  @override
  String get grpDColumns => 'ستون‌ها';

  @override
  String get grpDRefresh => 'تازه‌سازی';

  @override
  String get grpDLayoutNotSaved =>
      'چیدمان شما ذخیره نشد. در تغییر بعدی دوباره تلاش می‌شود.';

  @override
  String get grpDLayouts => 'چیدمان‌ها';

  @override
  String get grpDResetLayout => 'بازنشانی چیدمان من';

  @override
  String get grpDShareLayoutMenu => 'اشتراک‌گذاری این چیدمان…';

  @override
  String grpDDeleteShared(String name) {
    return 'حذف «$name» اشتراکی';
  }

  @override
  String grpDDeleteSharedTitle(String name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get grpDDeleteSharedBody => 'برای همه در این پروژه ناپدید می‌شود.';

  @override
  String get grpDDelete => 'حذف';

  @override
  String grpDDeletedNamed(String name) {
    return '«$name» حذف شد';
  }

  @override
  String grpDSharedNamed(String name) {
    return '«$name» به اشتراک گذاشته شد';
  }

  @override
  String get grpDShareLayoutTitle => 'اشتراک‌گذاری این چیدمان';

  @override
  String get grpDName => 'نام';

  @override
  String get grpDShare => 'اشتراک‌گذاری';

  @override
  String get grpDTaskNotFound => 'وظیفه پیدا نشد.';

  @override
  String get grpDDeleteTask => 'حذف وظیفه';

  @override
  String get grpDClose => 'بستن';

  @override
  String get grpDPriority => 'اولویت';

  @override
  String get grpDStart => 'شروع';

  @override
  String get grpDDue => 'سررسید';

  @override
  String get grpDAssignees => 'مسئولان';

  @override
  String get grpDDescription => 'توضیحات';

  @override
  String grpDTaskDeleted(String id) {
    return '$id حذف شد';
  }

  @override
  String get grpDUndo => 'واگرد';

  @override
  String get grpDStatus => 'وضعیت';

  @override
  String grpDClearField(String label) {
    return 'پاک کردن $label';
  }

  @override
  String get grpDDueTime => 'زمان سررسید (ساعت شما)';

  @override
  String get grpDClearDueTime => 'پاک کردن زمان سررسید';

  @override
  String get grpDAllOf => 'همه این‌ها';

  @override
  String get grpDAnyOf => 'هر یک از این‌ها';

  @override
  String get grpDNot => 'نه';

  @override
  String get grpDRemoveGroup => 'حذف گروه';

  @override
  String get grpDCondition => 'شرط';

  @override
  String get grpDFieldRemoved => 'فیلد (حذف شده)';

  @override
  String get grpDRemoveCondition => 'حذف شرط';

  @override
  String get grpDOpBefore => 'قبل از';

  @override
  String get grpDOpOnOrBefore => 'در یا قبل از';

  @override
  String get grpDOpAfter => 'بعد از';

  @override
  String get grpDOpOnOrAfter => 'در یا بعد از';

  @override
  String get grpDOpLessThan => 'کمتر از';

  @override
  String get grpDOpAtMost => 'حداکثر';

  @override
  String get grpDOpMoreThan => 'بیشتر از';

  @override
  String get grpDOpAtLeast => 'حداقل';

  @override
  String get grpDYes => 'بله';

  @override
  String get grpDNo => 'خیر';

  @override
  String get grpDCurrentSprint => 'اسپرینت فعلی';

  @override
  String get grpDMe => 'من';

  @override
  String get grpDChoose => 'انتخاب کنید…';

  @override
  String get grpDValue => 'مقدار';

  @override
  String get grpDPickDate => 'انتخاب تاریخ';

  @override
  String get grpDOrderByLabel => 'مرتب‌سازی بر اساس ';

  @override
  String get grpDAscending => 'صعودی';

  @override
  String get grpDDescending => 'نزولی';

  @override
  String get grpDRemoveOrdering => 'حذف مرتب‌سازی';

  @override
  String get grpDOrderBy => 'مرتب‌سازی بر اساس';

  @override
  String get grpDRepeatNothingToUpdate =>
      'وظایف جدید از این وظیفه استفاده می‌کنند. هیچ وظیفه بازی نیاز به تغییر نداشت.';

  @override
  String grpDRepeatUpdatedLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه باز بعدی به‌روزرسانی شد.',
      one: '$count وظیفه باز بعدی به‌روزرسانی شد.',
    );
    return '$_temp0';
  }

  @override
  String get grpDRepeat => 'تکرار';

  @override
  String grpDRepeatUnsupported(String summary) {
    return '«$summary» به روشی تنظیم شده که این ویرایشگر نمی‌تواند نشان دهد، پس اینجا قابل تغییر نیست. همچنان می‌توانید آن را متوقف یا قطع کنید.';
  }

  @override
  String get grpDSkipWeekends => 'رد شدن از آخر هفته‌ها';

  @override
  String get grpDStopRepeating => 'توقف تکرار';

  @override
  String get grpDResume => 'ادامه';

  @override
  String get grpDPause => 'توقف موقت';

  @override
  String get grpDUseForFuture => 'استفاده از این وظیفه برای وظایف آینده';

  @override
  String get grpDSave => 'ذخیره';

  @override
  String get grpDEvery => 'هر';

  @override
  String get grpDRepeatByDay => 'در یک روز از ماه';

  @override
  String get grpDRepeatByWeekday => 'در n‌امین روز هفته';

  @override
  String grpDDayNumber(int day) {
    return 'روز $day';
  }

  @override
  String get grpDNth1 => 'اول';

  @override
  String get grpDNth2 => 'دوم';

  @override
  String get grpDNth3 => 'سوم';

  @override
  String get grpDNth4 => 'چهارم';

  @override
  String get grpDNthLast => 'آخر';

  @override
  String get grpDEnds => 'پایان';

  @override
  String get grpDEndNever => 'هرگز';

  @override
  String get grpDEndAfter => 'پس از';

  @override
  String get grpDEndOn => 'در';

  @override
  String get grpDTasksWord => 'وظیفه';

  @override
  String get grpDMakeIt => 'ایجاد شود';

  @override
  String get grpDDaysAhead => 'روز پیش از سررسید';

  @override
  String grpDRepeatAt(String time) {
    return 'در ساعت $time';
  }

  @override
  String get grpDNoFurtherDates => 'تاریخ دیگری وجود ندارد.';

  @override
  String grpDNextDates(String dates) {
    return 'بعدی: $dates';
  }

  @override
  String get grpEBack => 'بازگشت';

  @override
  String get grpECancel => 'لغو';

  @override
  String get grpEName => 'نام';

  @override
  String get grpERetry => 'تلاش دوباره';

  @override
  String get grpEWorkspaceSettingsTitle => 'تنظیمات فضای کار';

  @override
  String get grpEWorkspacesLoadRetry =>
      'فضاهای کار شما بارگذاری نشد. تلاش دوباره';

  @override
  String get grpEMembers => 'اعضا';

  @override
  String get grpEMembersSub => 'افراد، دعوت‌ها و ترک کردن';

  @override
  String get grpERolesPerms => 'نقش‌ها و دسترسی‌ها';

  @override
  String get grpERolesPermsSub => 'چه کسی چه کاری می‌تواند بکند';

  @override
  String get grpEAuditLog => 'گزارش ممیزی';

  @override
  String get grpEAuditLogSub => 'چه کسی چه چیزی را و چه زمانی تغییر داد';

  @override
  String get grpEImportExport => 'درون‌ریزی و برون‌بری';

  @override
  String get grpEImportExportSub =>
      'داده‌های Jira، ClickUp یا CSV را وارد کنید؛ و خارج کنید';

  @override
  String get grpEWorkspaceUpdated => 'فضای کار به‌روزرسانی شد.';

  @override
  String get grpEGeneral => 'عمومی';

  @override
  String get grpEChangeLogo => 'تغییر نشان';

  @override
  String get grpEUrl => 'نشانی';

  @override
  String get grpERefresh => 'تازه‌سازی';

  @override
  String get grpESaveChanges => 'ذخیره تغییرات';

  @override
  String get grpENotifSettings => 'تنظیمات اعلان‌ها';

  @override
  String get grpEPushOffNotice =>
      'اعلان‌ها برای این دستگاه خاموش است. می‌توانید آن‌ها را در تنظیمات سیستم مجاز کنید؛ انتخاب شما ذخیره شده است.';

  @override
  String get grpEZoneInvalid =>
      'از نامی مانند Europe/Paris یا UTC استفاده کنید.';

  @override
  String get grpEQuietDifferent => 'زمان شروع و پایان باید متفاوت باشند.';

  @override
  String get grpEWhatReachesYou => 'آنچه به شما می‌رسد';

  @override
  String get grpEInbox => 'صندوق ورودی';

  @override
  String get grpEPush => 'اعلان فوری';

  @override
  String get grpEEmail => 'ایمیل';

  @override
  String get grpEQuietHours => 'ساعات سکوت';

  @override
  String get grpEQuietHold => 'نگه داشتن اعلان فوری و ایمیل در ساعات سکوت';

  @override
  String get grpEQuietHoldSub =>
      'صندوق ورودی همیشه پر می‌شود؛ فقط اعلان‌ها منتظر می‌مانند.';

  @override
  String get grpEFrom => 'از';

  @override
  String get grpEUntil => 'تا';

  @override
  String get grpETimeZoneDigest => 'منطقه زمانی و خلاصه';

  @override
  String get grpETimeZone => 'منطقه زمانی';

  @override
  String get grpETimeZoneHelper =>
      'ساعات سکوت و خلاصه از این منطقه پیروی می‌کنند.';

  @override
  String get grpEUseDeviceZone => 'استفاده از منطقه زمانی این دستگاه';

  @override
  String get grpETypeZone =>
      'به جای آن منطقه زمانی خود را بنویسید، مثلاً Europe/Paris.';

  @override
  String get grpEDigestAt => 'خلاصه روزانه ارسال می‌شود در';

  @override
  String get grpEEditField => 'ویرایش فیلد';

  @override
  String get grpENewField => 'فیلد جدید';

  @override
  String get grpEType => 'نوع';

  @override
  String get grpEOptions => 'گزینه‌ها';

  @override
  String get grpEColour => 'رنگ';

  @override
  String get grpELabel => 'برچسب';

  @override
  String get grpERemoveOption => 'حذف گزینه';

  @override
  String get grpEAddOption => 'افزودن گزینه';

  @override
  String get grpERequired => 'الزامی';

  @override
  String get grpERequiredSub => 'وظایف جدید باید مقدار داشته باشند.';

  @override
  String get grpEDefaultValue => 'مقدار پیش‌فرض';

  @override
  String get grpEShowIn => 'نمایش در';

  @override
  String get grpESave => 'ذخیره';

  @override
  String get grpEAddField => 'افزودن فیلد';

  @override
  String get grpEOptionN => 'گزینه ۱';

  @override
  String get grpEProblemName => 'برای فیلد نامی بگذارید.';

  @override
  String get grpEProblemOne => 'دست‌کم یک گزینه اضافه کنید.';

  @override
  String get grpEProblemLabel => 'هر گزینه به برچسب نیاز دارد.';

  @override
  String get grpEProblemDup => 'دو گزینه برچسب یکسان دارند.';

  @override
  String get grpEOptionsInUse => 'گزینه‌ها در حال استفاده هستند';

  @override
  String get grpERemovedOption => 'گزینه حذف‌شده';

  @override
  String grpERemapLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقدار',
      one: '۱ مقدار',
    );
    return '$label ($_temp0) تبدیل می‌شود به';
  }

  @override
  String get grpENothingClear => 'هیچ (پاک کردن)';

  @override
  String get grpEApply => 'اعمال';

  @override
  String get grpEPrivate => 'خصوصی';

  @override
  String get grpESprints => 'اسپرینت‌ها';

  @override
  String get grpEAutomations => 'خودکارسازی‌ها';

  @override
  String get grpESearch => 'جستجو';

  @override
  String get grpETimesheet => 'جدول زمانی';

  @override
  String get grpEDashboards => 'داشبوردها';

  @override
  String get grpEDocs => 'اسناد';

  @override
  String get grpEProjects => 'پروژه‌ها';

  @override
  String get grpENewProject => 'پروژه جدید';

  @override
  String get grpEFavorites => 'علاقه‌مندی‌ها';

  @override
  String get grpEProjectsLoadRetry => 'پروژه‌ها بارگذاری نشدند. تلاش دوباره';

  @override
  String get grpEArchivedProjects => 'پروژه‌های بایگانی‌شده';

  @override
  String get grpEPrivateProjects => 'پروژه‌های خصوصی';

  @override
  String get grpENoProjects => 'هنوز پروژه‌ای نیست';

  @override
  String get grpECreateFirstProject => 'اولین پروژه خود را بسازید';

  @override
  String get grpEMonth1 => 'ژانویه';

  @override
  String get grpEMonth2 => 'فوریه';

  @override
  String get grpEMonth3 => 'مارس';

  @override
  String get grpEMonth4 => 'آوریل';

  @override
  String get grpEMonth5 => 'مه';

  @override
  String get grpEMonth6 => 'ژوئن';

  @override
  String get grpEMonth7 => 'ژوئیه';

  @override
  String get grpEMonth8 => 'اوت';

  @override
  String get grpEMonth9 => 'سپتامبر';

  @override
  String get grpEMonth10 => 'اکتبر';

  @override
  String get grpEMonth11 => 'نوامبر';

  @override
  String get grpEMonth12 => 'دسامبر';

  @override
  String get grpEWeekLocale => 'پیش‌فرض زبان';

  @override
  String get grpEMonday => 'دوشنبه';

  @override
  String get grpESaturday => 'شنبه';

  @override
  String get grpESunday => 'یکشنبه';

  @override
  String get grpEPrevious => 'قبلی';

  @override
  String get grpENext => 'بعدی';

  @override
  String get grpEToday => 'امروز';

  @override
  String get grpEUnscheduled => 'برنامه‌ریزی‌نشده';

  @override
  String get grpEMonth => 'ماه';

  @override
  String get grpEWeek => 'هفته';

  @override
  String get grpEDay => 'روز';

  @override
  String get grpEColourBy => 'رنگ بر اساس';

  @override
  String get grpEColourByProject => 'رنگ بر اساس پروژه';

  @override
  String get grpEColourByStatus => 'رنگ بر اساس وضعیت';

  @override
  String get grpEColourByPriority => 'رنگ بر اساس اولویت';

  @override
  String get grpEColourChip => 'رنگ';

  @override
  String get grpEWeekStartsOn => 'هفته شروع می‌شود از';

  @override
  String get grpEHideDone => 'پنهان کردن انجام‌شده‌ها';

  @override
  String get grpELayoutNotSaved =>
      'چیدمان تقویم شما ذخیره نشد. در تغییر بعدی دوباره تلاش می‌شود.';

  @override
  String get grpEEnterName => 'یک نام وارد کنید.';

  @override
  String get grpENewRole => 'نقش جدید';

  @override
  String get grpECreate => 'ایجاد';

  @override
  String get grpERenameRole => 'تغییر نام نقش';

  @override
  String get grpERename => 'تغییر نام';

  @override
  String grpEDeleteRoleTitle(String name) {
    return '\"$name\" حذف شود؟';
  }

  @override
  String get grpERoleNoOne => 'هیچ‌کس این نقش را ندارد.';

  @override
  String grpERoleMoveMembers(int count) {
    return '$count عضو این نقش را دارند. آن‌ها را منتقل کنید به:';
  }

  @override
  String get grpEChooseRole => 'یک نقش انتخاب کنید';

  @override
  String get grpEDelete => 'حذف';

  @override
  String grpFBulkDeleted(int count) {
    return '$count وظیفه حذف شد';
  }

  @override
  String grpFBulkUpdated(int count) {
    return '$count وظیفه به‌روزرسانی شد';
  }

  @override
  String grpFBulkPartialDeleted(int done, int total, int failed) {
    return '$done از $total وظیفه حذف شد؛ $failed حذف نشد.';
  }

  @override
  String grpFBulkPartialUpdated(int done, int total, int failed) {
    return '$done از $total وظیفه به‌روزرسانی شد؛ $failed نشد.';
  }

  @override
  String get grpFDetails => 'جزئیات';

  @override
  String grpFBulkDeleteTitle(int count) {
    return '$count وظیفه حذف شود؟';
  }

  @override
  String get grpFBulkDeleteBody =>
      'زیروظیفه‌های آن‌ها هم حذف می‌شود. می‌توانید از سطل زباله بازیابی کنید.';

  @override
  String get grpFDelete => 'حذف';

  @override
  String get grpFSetStatus => 'تنظیم وضعیت';

  @override
  String get grpFSetPriority => 'تنظیم اولویت';

  @override
  String get grpFStatus => 'وضعیت';

  @override
  String get grpFPriority => 'اولویت';

  @override
  String get grpFAssign => 'واگذاری';

  @override
  String get grpFClear => 'پاک کردن';

  @override
  String grpFBulkUpdating(int done, int total) {
    return 'به‌روزرسانی $done از $total…';
  }

  @override
  String grpFBulkSelected(int count) {
    return '$count انتخاب شد';
  }

  @override
  String grpFBulkNotChanged(int count) {
    return '$count وظیفه تغییر نکرد';
  }

  @override
  String get grpFTask => 'وظیفه';

  @override
  String get grpFLinks => 'پیوندها';

  @override
  String get grpFAddLink => 'افزودن پیوند';

  @override
  String get grpFNoLinks => 'هنوز پیوندی نیست.';

  @override
  String get grpFRemoveLink => 'حذف پیوند';

  @override
  String get grpFLinkSearchHint => 'جستجوی وظایف در هر پروژه';

  @override
  String get grpFCloseDuplicate => 'بستن مورد تکراری';

  @override
  String get grpFLinkAction => 'پیوند زدن';

  @override
  String get grpFUnassigned => 'بدون مسئول';

  @override
  String get grpFNoValue => 'بدون مقدار';

  @override
  String get grpFAssignee => 'مسئول';

  @override
  String grpFPresenceEditing(String name) {
    return '$name در حال ویرایش است';
  }

  @override
  String grpFPresenceViewing(String name) {
    return '$name در حال مشاهده است';
  }

  @override
  String grpFEditingOne(String name) {
    return '$name در حال ویرایش این است';
  }

  @override
  String grpFEditingMany(int count) {
    return '$count نفر در حال ویرایش این هستند';
  }

  @override
  String grpFDeleteTaskTitle(String id) {
    return '$id حذف شود؟';
  }

  @override
  String grpFDeleteSubtasksExplain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زیروظیفه دارد. با آن‌ها چه شود؟',
      one: '۱ زیروظیفه دارد. با آن چه شود؟',
    );
    return '$_temp0';
  }

  @override
  String get grpFKeepSubtasks => 'نگه داشتن (یک سطح بالا)';

  @override
  String get grpFDeleteThemToo => 'آن‌ها هم حذف شوند';

  @override
  String grpFOpenSubtasksTitle(String id) {
    return '$id زیروظیفه‌های باز دارد';
  }

  @override
  String grpFOpenSubtasksExplain(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زیروظیفه تمام نشده است. آن‌ها را هم به $status ببریم؟',
      one: '۱ زیروظیفه تمام نشده است. آن را هم به $status ببریم؟',
    );
    return '$_temp0';
  }

  @override
  String get grpFLeaveOpen => 'پرانیستاه بگذار';

  @override
  String get grpFCompleteAll => 'تکمیل همه';

  @override
  String grpFMoveUnderTitle(String id) {
    return 'انتقال $id به زیر…';
  }

  @override
  String get grpFTopLevel => 'سطح بالا (بدون والد)';

  @override
  String get grpFNoOtherParent => 'وظیفهٔ دیگری برای قرار دادن زیر آن نیست.';

  @override
  String get grpFSubtasks => 'زیروظیفه‌ها';

  @override
  String get grpFAddSubtaskHint => 'زیروظیفه‌ای بیفزایید و Enter بزنید';

  @override
  String get grpFActionAddSubtask => 'افزودن زیروظیفه';

  @override
  String get grpFActionMoveUnder => 'انتقال به زیر…';

  @override
  String get grpFActionMakeTopLevel => 'تبدیل به سطح بالا';

  @override
  String get grpFBlockedByPending => 'مسدود با وظایفی که هنوز انجام نشده‌اند';

  @override
  String grpFBlockedBy(String names) {
    return 'مسدود توسط $names';
  }

  @override
  String get grpFBlocked => 'مسدود';

  @override
  String get grpFBlockedTitle => 'این وظیفه مسدود است';

  @override
  String grpFBlockedTextOne(String blockers) {
    return 'با $blockers مسدود شده که هنوز انجام نشده است.';
  }

  @override
  String grpFBlockedTextMany(String blockers) {
    return 'با $blockers مسدود شده که هنوز انجام نشده‌اند.';
  }

  @override
  String get grpFOk => 'تأیید';

  @override
  String get grpFCompleteAnyway => 'به هر حال تکمیل شود';

  @override
  String grpFConflictTitle(String field) {
    return 'کسی $field را تغییر داد';
  }

  @override
  String get grpFTheirs => 'مقدار آن‌ها';

  @override
  String get grpFYours => 'مقدار شما';

  @override
  String get grpFEmpty => '(خالی)';

  @override
  String get grpFTakeTheirs => 'مقدار آن‌ها را بگیر';

  @override
  String get grpFKeepMine => 'مقدار من بماند';

  @override
  String get grpFFieldTitle => 'عنوان';

  @override
  String get grpFFieldDescription => 'توضیحات';

  @override
  String get grpFFieldStatus => 'وضعیت';

  @override
  String get grpFFieldPriority => 'اولویت';

  @override
  String get grpFFieldStartDate => 'تاریخ شروع';

  @override
  String get grpFFieldDueDate => 'تاریخ سررسید';

  @override
  String get grpFFieldAssignees => 'مسئولان';

  @override
  String get grpFFields => 'فیلدها';

  @override
  String get grpFRequiredFieldsIntro =>
      'این فیلدها پیش از ایجاد وظیفه به مقدار نیاز دارند.';

  @override
  String get grpFRequired => 'الزامی';

  @override
  String get grpFCreate => 'ایجاد';

  @override
  String get grpFChangeStatus => 'تغییر وضعیت';

  @override
  String get grpFChangePriority => 'تغییر اولویت';

  @override
  String get grpFDate => 'تاریخ';

  @override
  String get grpFPickDay => 'انتخاب روز…';

  @override
  String get grpFAssignees => 'مسئولان';

  @override
  String get grpFViewList => 'فهرست';

  @override
  String get grpFViewBoard => 'تابلو';

  @override
  String get grpFViewTimeline => 'خط زمانی';

  @override
  String grpFErrorRetry(String message) {
    return '$message تلاش دوباره';
  }

  @override
  String get grpFNoTasksYet => 'هنوز وظیفه‌ای نیست. اولین را بالا اضافه کنید.';

  @override
  String get grpFSwipeComplete => 'تکمیل';

  @override
  String get grpFUndo => 'واگرد';

  @override
  String get grpFMore => 'بیشتر';

  @override
  String grpFAddSubtaskTo(String id) {
    return 'افزودن زیروظیفه به $id';
  }

  @override
  String grpFTaskDeleted(String id) {
    return '$id حذف شد';
  }

  @override
  String get grpFColTitle => 'عنوان';

  @override
  String grpFTrashTitle(String name) {
    return '$name · سطل زباله';
  }

  @override
  String get grpFTrashEmpty => 'سطل زباله خالی است.';

  @override
  String grpFTrashedRow(String id) {
    return '$id · حذف‌شده';
  }

  @override
  String get grpFRestore => 'بازیابی';

  @override
  String grpFTaskRestored(String id) {
    return '$id بازیابی شد';
  }

  @override
  String get grpFMoveTo => 'انتقال به…';

  @override
  String grpFMoveToColumn(String name) {
    return 'انتقال به $name';
  }

  @override
  String grpFPlusCount(int count) {
    return '+$count';
  }

  @override
  String get grpFFoldColumn => 'جمع کردن ستون';

  @override
  String get grpFColumn => 'ستون';

  @override
  String get grpFSetWipLimit => 'تعیین سقف کار در جریان…';

  @override
  String get grpFChangeLimit => 'تغییر سقف…';

  @override
  String get grpFAddTask => 'افزودن وظیفه';

  @override
  String get grpFWipTitle => 'سقف کار در جریان';

  @override
  String get grpFWipMost => 'بیشترین تعداد کارت در این ستون';

  @override
  String get grpFColumnsBy => 'ستون‌ها بر اساس';

  @override
  String grpFColumnsChip(String name) {
    return 'ستون‌ها: $name';
  }

  @override
  String get grpFSwimlanes => 'مسیرها';

  @override
  String get grpFLanesAssignee => 'مسیرها: مسئول';

  @override
  String get grpFNoSwimlanes => 'بدون مسیر';

  @override
  String get grpFByAssignee => 'بر اساس مسئول';

  @override
  String get grpFCardFields => 'فیلدهای کارت';

  @override
  String get grpFCurrentSprint => 'اسپرینت جاری';

  @override
  String get grpFRefresh => 'تازه‌سازی';

  @override
  String get grpFBoardLayoutNotSaved =>
      'چیدمان تابلوی شما ذخیره نشد. در تغییر بعدی دوباره تلاش می‌شود.';

  @override
  String get grpFReschedule => 'زمان‌بندی مجدد…';

  @override
  String get grpFSchedule => 'زمان‌بندی…';

  @override
  String get grpFRepeatsNotMade => 'تکرار: هنوز ساخته نشده';

  @override
  String get grpFEverythingDated => 'همه چیز تاریخ دارد.';

  @override
  String grpFNothingOn(String day) {
    return 'در $day چیزی نیست.';
  }

  @override
  String get grpFKindTasks => 'وظایف';

  @override
  String get grpFKindComments => 'نظرات';

  @override
  String get grpFKindProjects => 'پروژه‌ها';

  @override
  String get grpFKindPeople => 'افراد';

  @override
  String get grpFKindPages => 'صفحات';

  @override
  String get grpFChipAssignedToMe => 'محول‌شده به من';

  @override
  String get grpFChipOpen => 'باز';

  @override
  String get grpFChipDone => 'انجام‌شده';

  @override
  String get grpFSearchErrGeneric => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get grpFSearchErrNetwork =>
      'اتصال به سرور برقرار نشد. اتصال خود را بررسی کنید.';

  @override
  String get grpFSearchErrDenied => 'اجازهٔ جستجو در اینجا را ندارید.';

  @override
  String get grpFSearchErrRate => 'جستجوهای زیاد. لحظه‌ای صبر کنید.';

  @override
  String get grpFSearchErrInvalid => 'این جستجو معتبر نیست.';

  @override
  String get grpFSearchHint => 'جستجوی وظایف، نظرات، پروژه‌ها، افراد';

  @override
  String get grpFSearchClose => 'بستن جستجو';

  @override
  String get grpFSearchNothing =>
      'چیزی پیدا نشد. کلمات کمتری امتحان کنید یا شناسه‌ای مانند WEB-12. با in:KEY، assignee:me، status:open محدود کنید.';

  @override
  String get grpFSearchTips =>
      'برای جستجو تایپ کنید. شناسه‌ای مانند WEB-12 یا عملگرهای in:KEY، assignee:me، status:open را امتحان کنید.';

  @override
  String get grpFGoTo => 'برو به';

  @override
  String grpFShowMore(String kind) {
    return 'نمایش $kind بیشتر';
  }

  @override
  String get grpFRecent => 'اخیر';

  @override
  String grpFPlusMore(int count) {
    return '+$count مورد دیگر';
  }

  @override
  String get grpFSubtaskDepthLimit =>
      'زیروظیفه‌ها تا حد مجاز برنامه در اینجا تو در تو شده‌اند.';

  @override
  String get grpFUnscheduled => 'برنامه‌ریزی‌نشده';

  @override
  String get grpGCloseShortcuts => 'بستن میانبرهای صفحه‌کلید';

  @override
  String get grpGKeyboardShortcuts => 'میانبرهای صفحه‌کلید';

  @override
  String get grpGClose => 'بستن';

  @override
  String get grpGChangedByYou => 'تغییر داده‌شده توسط شما';

  @override
  String get grpGNone => 'هیچ';

  @override
  String grpGChangeKeysFor(String title) {
    return 'تغییر کلیدهای «$title»';
  }

  @override
  String grpGKeysFor(String title) {
    return 'کلیدهای «$title»';
  }

  @override
  String get grpGPressKeys => 'کلیدهای دلخواه را فشار دهید.';

  @override
  String get grpGUseDefault => 'استفاده از پیش‌فرض';

  @override
  String get grpGNoKey => 'بدون کلید';

  @override
  String get grpGCancel => 'لغو';

  @override
  String get grpGSave => 'ذخیره';

  @override
  String grpGBrowserKeeps(String keys) {
    return 'مرورگر $keys را برای خود نگه می‌دارد.';
  }

  @override
  String grpGAlreadyUsedBy(String title) {
    return 'قبلاً توسط «$title» استفاده شده است.';
  }

  @override
  String get grpGKeysTaken => 'عمل دیگری از این کلیدها استفاده می‌کند.';

  @override
  String get grpGKeysInvalid => 'این کلیدها قابل استفاده نیستند.';

  @override
  String get grpGSaveFailed => 'ذخیره نشد. اتصال خود را بررسی کنید.';

  @override
  String grpGDefaultUsedBy(String title) {
    return 'کلیدهای پیش‌فرض توسط «$title» استفاده می‌شوند.';
  }

  @override
  String get grpGDefaultUsedByOther =>
      'کلیدهای پیش‌فرض توسط عمل دیگری استفاده می‌شوند.';

  @override
  String get grpGPaletteHint =>
      'یک فرمان بنویسید، یا > عمل‌ها  # پروژه‌ها  @ افراد';

  @override
  String get grpGNothingMatches => 'موردی مطابقت ندارد.';

  @override
  String get grpGSearchUnavailable => 'جستجو اکنون در دسترس نیست.';

  @override
  String get grpGName => 'نام';

  @override
  String get grpGCreate => 'ایجاد';

  @override
  String get grpGQuickActions => 'عمل‌های سریع';

  @override
  String grpGDryRunTitle(String name) {
    return 'اجرای آزمایشی: $name';
  }

  @override
  String get grpGDryRunIntro =>
      'نشان می‌دهد روی یک وظیفه چه اتفاقی می‌افتد. چیزی تغییر نمی‌کند، ارسال نمی‌شود و اطلاع‌رسانی نمی‌شود.';

  @override
  String get grpGTask => 'وظیفه';

  @override
  String get grpGTasksLoadFailed => 'بارگذاری وظایف ممکن نشد.';

  @override
  String get grpGWouldRun => 'اجرا می‌شود.';

  @override
  String get grpGWouldNotRun => 'روی این وظیفه اجرا نمی‌شود.';

  @override
  String get grpGRun => 'اجرا';

  @override
  String get grpGConditionProblem => 'شرط مشکل دارد: زیر کارت «اگر» را ببینید.';

  @override
  String get grpGRuleGone => 'آن قانون دیگر وجود ندارد.';

  @override
  String get grpGRule => 'قانون';

  @override
  String get grpGNewAutomation => 'خودکارسازی جدید';

  @override
  String get grpGEditAutomation => 'ویرایش خودکارسازی';

  @override
  String get grpGWhen => 'وقتی';

  @override
  String get grpGIfOptional => 'اگر (اختیاری)';

  @override
  String get grpGThen => 'آنگاه';

  @override
  String get grpGAndThen => 'و سپس';

  @override
  String grpGActionLimit(int max) {
    return 'به حد مجاز $max عمل رسیده است';
  }

  @override
  String get grpGAddAction => 'افزودن عمل';

  @override
  String get grpGLoadLatest => 'بارگذاری آخرین نسخه';

  @override
  String get grpGMoveUp => 'انتقال به بالا';

  @override
  String get grpGMoveDown => 'انتقال به پایین';

  @override
  String get grpGRemoveAction => 'حذف عمل';

  @override
  String grpGSwitchedOff(String reason) {
    return 'خاموش شد: $reason\nرفع مشکل: قانون را باز کنید، موردی را که هنوز وجود دارد در محرک یا عمل‌ها انتخاب کنید، ذخیره کنید و دوباره روشن کنید.';
  }

  @override
  String get grpGUnknown => 'نامشخص';

  @override
  String get grpGEmptyValue => '(خالی)';

  @override
  String get grpGNothingRunYet => 'هنوز چیزی اجرا نشده است.';

  @override
  String get grpGLoadMore => 'بارگذاری بیشتر';

  @override
  String get grpGRetry => 'تلاش دوباره';

  @override
  String grpGWhyNotRun(String explanation) {
    return 'چرا اجرا نشد؟ $explanation';
  }

  @override
  String grpGChainDepth(int depth) {
    return 'عمق زنجیره $depth';
  }

  @override
  String get grpGFilter => 'فیلتر';

  @override
  String grpGFilterCount(int count) {
    return 'فیلتر ($count)';
  }

  @override
  String get grpGSavedFilters => 'فیلترهای ذخیره‌شده';

  @override
  String get grpGNoSavedFilters => 'هنوز فیلتر ذخیره‌شده‌ای نیست';

  @override
  String grpGFieldGoneNamed(String name) {
    return '$name (یک فیلد حذف شده است)';
  }

  @override
  String get grpGManageSaved => 'مدیریت فیلترهای ذخیره‌شده…';

  @override
  String grpGConditionCount(int count) {
    return '$count شرط';
  }

  @override
  String get grpGClearFilterTip => 'پاک کردن فیلتر';

  @override
  String get grpGNothingSaved => 'هنوز چیزی ذخیره نشده است.';

  @override
  String get grpGFieldItUsedGone => 'فیلدی که استفاده می‌کرد حذف شده است';

  @override
  String get grpGDelete => 'حذف';

  @override
  String get grpGFinishConditions => 'ابتدا شرط‌ها را کامل کنید.';

  @override
  String get grpGEveryoneWorkspace => 'همه در فضای کار';

  @override
  String get grpGEveryoneProject => 'همه در این پروژه';

  @override
  String get grpGBuilder => 'سازنده';

  @override
  String get grpGAdvanced => 'پیشرفته';

  @override
  String get grpGClearFilter => 'پاک کردن فیلتر';

  @override
  String get grpGSaveAs => 'ذخیره به عنوان…';

  @override
  String get grpGApply => 'اعمال';

  @override
  String get grpGSaveThisFilter => 'ذخیره این فیلتر';

  @override
  String get grpGOnlyMe => 'فقط من';

  @override
  String get grpGExportSaveFailed => 'فایل ذخیره نشد. دوباره تلاش کنید.';

  @override
  String get grpGExport => 'برون‌بری';

  @override
  String get grpGEveryProject => 'همه پروژه‌هایی که می‌توانم باز کنم';

  @override
  String get grpGOneProject => 'یک پروژه';

  @override
  String get grpGExportInfo =>
      'یک فایل zip شامل tasks.json (که TaskForge دوباره می‌تواند وارد کند)، tasks.csv، نظرها، فهرست پیوست‌ها و یک README.';

  @override
  String grpGExportSavedSized(String name, String size) {
    return '$name ذخیره شد ($size).';
  }

  @override
  String grpGExportSaved(String name) {
    return '$name ذخیره شد.';
  }

  @override
  String grpGNotesAboutFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count یادداشت درباره این فایل',
      one: '۱ یادداشت درباره این فایل',
    );
    return '$_temp0';
  }

  @override
  String grpGRowNumber(int line) {
    return 'ردیف $line';
  }

  @override
  String grpGAndMore(int count) {
    return '...و $count مورد دیگر.';
  }

  @override
  String get grpGNotesReadFailed =>
      'خواندن یادداشت‌های این درون‌ریزی ممکن نشد.';

  @override
  String get grpGDragToOtherList => 'به فهرست دیگر بکشید';

  @override
  String get grpGAddedAfterStart => 'پس از شروع افزوده شد';

  @override
  String get grpGStoryPoints => 'امتیاز داستان';

  @override
  String get grpGUnitHours => 'س';

  @override
  String get grpGUnitPoints => ' امتیاز';

  @override
  String grpGLoadOf(String load, String unit, String cap) {
    return 'بار $load$unit از $cap$unit';
  }

  @override
  String grpGLoadNoCapacity(String load, String unit) {
    return 'بار $load$unit (ظرفیت تعیین نشده)';
  }

  @override
  String get grpGSetCapacity => 'تعیین ظرفیت';

  @override
  String get grpGPoints => 'امتیاز';

  @override
  String get grpGHours => 'ساعت';

  @override
  String grpGOverCapacity(String amount, String unit) {
    return 'بیش از ظرفیت به اندازه $amount$unit';
  }

  @override
  String grpGTitleWithCount(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get grpHCancel => 'انصراف';

  @override
  String get grpHArchive => 'بایگانی';

  @override
  String get grpHRestore => 'بازیابی';

  @override
  String get grpHRetry => 'تلاش دوباره';

  @override
  String get grpHCreate => 'ایجاد';

  @override
  String get grpHName => 'نام';

  @override
  String get grpHDescription => 'توضیحات';

  @override
  String grpHArchiveTitle(String name) {
    return '«$name» بایگانی شود؟';
  }

  @override
  String get grpHArchiveBody =>
      'فقط‌خواندنی می‌شود و از نوار کناری ناپدید می‌شود. هر زمان می‌توانید آن را بازیابی کنید.';

  @override
  String get grpHDangerZone => 'ناحیه خطر';

  @override
  String get grpHRestoreProject => 'بازیابی پروژه';

  @override
  String get grpHArchiveProject => 'بایگانی پروژه';

  @override
  String get grpHArchivedBanner => 'این پروژه بایگانی شده و فقط‌خواندنی است.';

  @override
  String get grpHArchivedProjects => 'پروژه‌های بایگانی‌شده';

  @override
  String get grpHNoArchived => 'پروژه بایگانی‌شده‌ای وجود ندارد.';

  @override
  String get grpHLoadProjectsRetry => 'بارگذاری پروژه‌ها ممکن نشد. تلاش دوباره';

  @override
  String get grpHNewProject => 'پروژه جدید';

  @override
  String get grpHKey => 'کلید';

  @override
  String get grpHKeyHelp => 'پیشوند شماره وظایف، مثلاً WEB-12';

  @override
  String get grpHFeatures => 'ویژگی‌ها';

  @override
  String get grpHFeaturesHint =>
      'خاموش کردن یک ویژگی آن را پنهان می‌کند اما داده‌هایش حفظ می‌شود.';

  @override
  String get grpHProjectUpdated => 'پروژه به‌روز شد.';

  @override
  String get grpHGeneral => 'عمومی';

  @override
  String grpHKeyFixed(String taskKey) {
    return 'کلید ثابت است زیرا وظایف از قبل از آن استفاده می‌کنند ($taskKey).';
  }

  @override
  String get grpHSaveChanges => 'ذخیره تغییرات';

  @override
  String get grpHAddAMember => 'افزودن عضو';

  @override
  String get grpHAllAreMembers => 'همه اعضای فضای کاری از قبل عضو هستند.';

  @override
  String get grpHMembers => 'اعضا';

  @override
  String get grpHAddMember => 'افزودن عضو';

  @override
  String get grpHRemove => 'حذف';

  @override
  String get grpHLoadMembersRetry => 'بارگذاری اعضا ممکن نشد. تلاش دوباره';

  @override
  String get grpHPrivateProjects => 'پروژه‌های خصوصی';

  @override
  String get grpHNoPrivate => 'پروژه خصوصی وجود ندارد.';

  @override
  String grpHKeyAndMembers(String key, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      one: '۱ عضو',
    );
    return '$key · $_temp0';
  }

  @override
  String get grpHAddMe => 'مرا اضافه کن';

  @override
  String grpHColorLabel(String color) {
    return 'رنگ $color';
  }

  @override
  String get grpHVisOpen => 'باز';

  @override
  String get grpHVisPrivate => 'خصوصی';

  @override
  String get grpHVisOpenHint => 'همه اعضای فضای کاری آن را می‌بینند.';

  @override
  String get grpHVisPrivateHint => 'فقط اعضای دعوت‌شده آن را می‌بینند.';

  @override
  String get grpHProject => 'پروژه';

  @override
  String get grpHRemoveFavorite => 'حذف از علاقه‌مندی‌ها';

  @override
  String get grpHAddFavorite => 'افزودن به علاقه‌مندی‌ها';

  @override
  String get grpHTrash => 'سطل زباله';

  @override
  String get grpHProjectSettings => 'تنظیمات پروژه';

  @override
  String get grpHLoadProjectRetry => 'بارگذاری پروژه ممکن نشد. تلاش دوباره';

  @override
  String get grpHProjectNotFound => 'پروژه پیدا نشد.';

  @override
  String get grpHBack => 'بازگشت';

  @override
  String get grpHWorkflow => 'گردش کار';

  @override
  String get grpHWorkflowHint =>
      'وضعیت‌ها، دسته‌بندی آن‌ها و جابه‌جایی‌های مجاز.';

  @override
  String get grpHFields => 'فیلدها';

  @override
  String get grpHFieldsHint =>
      'فیلدهای سفارشی مانند مشتری، امتیاز داستان یا محیط.';

  @override
  String get grpHAdd => 'افزودن';

  @override
  String get grpHAttachFile => 'پیوست فایل';

  @override
  String get grpHTakePhoto => 'گرفتن عکس';

  @override
  String get grpHChooseGallery => 'انتخاب از گالری';

  @override
  String get grpHPasteImage => 'چسباندن تصویر';

  @override
  String get grpHDeleteFileQ => 'این فایل حذف شود؟';

  @override
  String grpHFileWillBeRemoved(String filename) {
    return '$filename حذف خواهد شد.';
  }

  @override
  String get grpHDelete => 'حذف';

  @override
  String grpHOpenFile(String filename) {
    return 'باز کردن $filename';
  }

  @override
  String grpHDeleteFile(String filename) {
    return 'حذف $filename';
  }

  @override
  String get grpHWaitingConnection => 'در انتظار اتصال…';

  @override
  String get grpHWaiting => 'در انتظار…';

  @override
  String get grpHUploadDone => 'انجام شد';

  @override
  String get grpHUploadCancelled => 'لغو شد';

  @override
  String grpHPercentUploaded(String filename, int percent) {
    return '$filename، $percent درصد بارگذاری شد';
  }

  @override
  String get grpHWaitingToBeSent => 'در انتظار ارسال';

  @override
  String grpHCancelFile(String filename) {
    return 'لغو $filename';
  }

  @override
  String grpHTryFileAgain(String filename) {
    return 'تلاش دوباره برای $filename';
  }

  @override
  String grpHDismissFile(String filename) {
    return 'بستن $filename';
  }

  @override
  String get grpHOpen => 'باز کردن';

  @override
  String get grpHDownload => 'دانلود';

  @override
  String get grpHClose => 'بستن';

  @override
  String get grpHCouldNotOpenFile => 'فایل باز نشد.';

  @override
  String get grpHCouldNotLoadPicture => 'تصویر بارگذاری نشد.';

  @override
  String get grpHCouldNotReadFileViewer => 'فایل خوانده نشد.';

  @override
  String get grpHCouldNotPlayVideo => 'ویدیو پخش نشد.';

  @override
  String get grpHPause => 'توقف';

  @override
  String get grpHPlay => 'پخش';

  @override
  String grpHTextTruncated(String size) {
    return '$size نخست نمایش داده می‌شود. برای خواندن بقیه فایل را دانلود کنید.';
  }

  @override
  String get grpHAttachments => 'پیوست‌ها';

  @override
  String grpHAttachmentsCount(int count) {
    return 'پیوست‌ها ($count)';
  }

  @override
  String get grpHCouldNotReadFile => 'آن فایل خوانده نشد.';

  @override
  String get grpHDismiss => 'بستن';

  @override
  String get grpHNoAttachments => 'پیوستی وجود ندارد.';

  @override
  String get grpHDropZoneLabel =>
      'پیوست فایل‌ها: آن‌ها را اینجا رها کنید یا کلیک کنید، سپس تصویر را بچسبانید';

  @override
  String get grpHDropToAttach => 'برای پیوست رها کنید';

  @override
  String get grpHDropFilesHere => 'فایل‌ها را برای پیوست اینجا رها کنید';

  @override
  String get grpHSnoozeLaterToday => 'امروز، بعداً';

  @override
  String get grpHSnoozeTomorrow => 'فردا';

  @override
  String get grpHSnoozeNextWeek => 'هفته آینده';

  @override
  String get grpHMarkAllRead => 'علامت‌گذاری همه به‌عنوان خوانده‌شده';

  @override
  String get grpHNotificationSettings => 'تنظیمات اعلان‌ها';

  @override
  String get grpHInbox => 'صندوق ورودی';

  @override
  String grpHUnreadCount(int count) {
    return '$count خوانده‌نشده';
  }

  @override
  String get grpHLoadMore => 'بارگذاری بیشتر';

  @override
  String get grpHEmptyAll => 'اینجا چیزی نیست. همه چیز را دیده‌اید.';

  @override
  String get grpHEmptyUnread => 'اعلان خوانده‌نشده‌ای وجود ندارد.';

  @override
  String get grpHEmptyMentions => 'هیچ‌کس شما را اشاره نکرده است.';

  @override
  String get grpHEmptyAssigned => 'اخیراً چیزی به شما واگذار نشده است.';

  @override
  String get grpHEmptySnoozed => 'چیزی به تعویق نیفتاده است.';

  @override
  String get grpHEmptyArchived => 'چیزی بایگانی نشده است.';

  @override
  String grpHDueDate(String date) {
    return 'سررسید $date';
  }

  @override
  String grpHUnreadPrefix(String title) {
    return 'خوانده‌نشده. $title';
  }

  @override
  String grpHMoreCount(int count) {
    return '+$count مورد دیگر';
  }

  @override
  String get grpHMore => 'بیشتر';

  @override
  String get grpHMarkUnread => 'علامت به‌عنوان خوانده‌نشده';

  @override
  String get grpHMarkRead => 'علامت به‌عنوان خوانده‌شده';

  @override
  String get grpHStopSnoozing => 'پایان تعویق';

  @override
  String get grpHSnoozeEllipsis => 'به تعویق انداختن…';

  @override
  String get grpHMoveToInbox => 'انتقال به صندوق ورودی';

  @override
  String get grpHPushTitle => 'هنگام اهمیت اعلان بگیرید';

  @override
  String get grpHPushBody =>
      'TaskForge می‌تواند هنگامی که وظیفه‌ای به شما واگذار می‌شود، از شما نام برده می‌شود یا سررسید وظیفه‌ای نزدیک است، حتی وقتی برنامه در پس‌زمینه است، اعلان نشان دهد. سپس دستگاه شما اجازه می‌خواهد. شما انتخاب می‌کنید کدام نوع اعلان‌ها برسند و ساعات سکوت مانع بیدار شدن شما می‌شود.';

  @override
  String get grpHNotNow => 'فعلاً نه';

  @override
  String get grpHContinue => 'ادامه';

  @override
  String get grpHPickDateTime => 'انتخاب تاریخ و زمان';

  @override
  String get grpHRepeatReadError => 'نحوه تکرار این مورد خوانده نشد.';

  @override
  String get grpHRepeat => 'تکرار';

  @override
  String get grpHFirstOfSeries => 'نخستین مورد یک سری';

  @override
  String get grpHRepeatingTask => 'وظیفه تکراری';

  @override
  String grpHSeriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه در این سری',
      one: '$count وظیفه در این سری',
    );
    return '$_temp0';
  }

  @override
  String get grpHRepeatPaused => 'متوقف شد: وظیفه جدیدی ساخته نمی‌شود.';

  @override
  String grpHRepeatPausedBySystem(String reason) {
    return 'توسط سیستم متوقف شد: $reason';
  }

  @override
  String grpHRepeatNext(String dates) {
    return 'بعدی: $dates';
  }

  @override
  String get grpHRepeatWaits => 'مورد بعدی پس از تکمیل این مورد ساخته می‌شود.';

  @override
  String get grpHRepeatsTitle => 'این وظیفه تکرار می‌شود';

  @override
  String grpHRepeatsBody(String summary) {
    return 'این الگوی «$summary» است. با حذف آن می‌توان سری را متوقف کرد یا سری می‌تواند به ساخت وظایف جدید ادامه دهد.';
  }

  @override
  String get grpHDeleteKeepRepeating => 'حذف، ادامه تکرار';

  @override
  String get grpHDeleteAndStop => 'حذف و توقف';

  @override
  String get grpHChartGroup => 'گروه';

  @override
  String get grpHOfflineReview => 'بررسی';

  @override
  String get grpHOfflineSyncing => 'در حال همگام‌سازی…';

  @override
  String get grpHOfflineSyncNow => 'همگام‌سازی اکنون';

  @override
  String get grpHOfflineSaved =>
      'شما آفلاین هستید. تغییرات در این دستگاه ذخیره می‌شوند.';

  @override
  String grpHOfflineWaitsOnline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر منتظر ارسال هستند.',
      one: '$count تغییر منتظر ارسال است.',
    );
    return '$_temp0';
  }

  @override
  String grpHOfflineWaitsOffline(int count) {
    return '$count در انتظار ارسال.';
  }

  @override
  String grpHOfflineAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر به توجه شما نیاز دارند.',
      one: '$count تغییر به توجه شما نیاز دارد.',
    );
    return '$_temp0';
  }

  @override
  String get grpHReconnecting =>
      'در حال اتصال مجدد… آنچه می‌بینید پس از بازگشت به‌روز می‌شود.';

  @override
  String get grpICancel => 'لغو';

  @override
  String get grpIDone => 'انجام شد';

  @override
  String get grpIRetry => 'تلاش دوباره';

  @override
  String get grpIClose => 'بستن';

  @override
  String get grpIBack => 'بازگشت';

  @override
  String get grpIEdit => 'ویرایش';

  @override
  String get grpISave => 'ذخیره';

  @override
  String get grpISaving => 'در حال ذخیره…';

  @override
  String get grpIDelete => 'حذف';

  @override
  String get grpICopy => 'کپی';

  @override
  String get grpIUndo => 'واگرد';

  @override
  String get grpIRestore => 'بازیابی';

  @override
  String get grpIUnnamed => '(بدون نام)';

  @override
  String grpIErrorRetry(String message) {
    return '$message تلاش دوباره';
  }

  @override
  String get grpIMergeTitle => 'شخص دیگری ابتدا گردش کار را ذخیره کرد';

  @override
  String get grpIMergeBody =>
      'ویرایش‌های شما حفظ شد و کار آن‌ها بازنویسی نشد. این موارد در پیش‌نویس شما تغییر کرد:';

  @override
  String get grpIMergeKeep => 'این را خواندم، پیش‌نویسم را نگه دار';

  @override
  String get grpIMergeReload => 'پیش‌نویسم را دور بینداز';

  @override
  String get grpINoProblems => 'مشکلی نیست';

  @override
  String get grpIEveryTaskValid => 'هر وظیفه وضعیت معتبر دارد.';

  @override
  String grpIProblemsToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشکل برای رفع پیش از ذخیره',
      one: '۱ مشکل برای رفع پیش از ذخیره',
    );
    return '$_temp0';
  }

  @override
  String get grpIAnyStatusMoves => 'هر وضعیت می‌تواند به هر وضعیت دیگر برود.';

  @override
  String grpIWorkflowGraphLabel(int statuses, int moves) {
    return 'گردش کار با $statuses وضعیت و $moves انتقال مجاز';
  }

  @override
  String get grpINeedsAssignee => 'نیاز به مسئول دارد';

  @override
  String get grpINeedsSubtasksDone => 'نیاز به انجام همه زیروظیفه‌ها دارد';

  @override
  String grpIOnlyRoleLower(String role) {
    return 'فقط $role';
  }

  @override
  String get grpIOneRole => 'یک نقش';

  @override
  String get grpIDragToReorder => 'برای ترتیب‌دهی بکشید';

  @override
  String get grpIColour => 'رنگ';

  @override
  String get grpINewTasksStartHere => 'وظایف جدید از اینجا شروع می‌شوند';

  @override
  String get grpIMakeDefaultStatus => 'این را وضعیت آغازین وظایف جدید کن';

  @override
  String get grpIDeleteStatus => 'حذف وضعیت';

  @override
  String grpITaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه',
      one: '۱ وظیفه',
    );
    return '$_temp0';
  }

  @override
  String get grpICanMoveTo => 'می‌تواند برود به';

  @override
  String get grpIConditionsForMove => 'شرایط این انتقال';

  @override
  String get grpIName => 'نام';

  @override
  String grpIDeleteStatusTitle(String name) {
    return '$name حذف شود؟';
  }

  @override
  String grpITasksInStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه در این وضعیت است. انتخاب کنید به کجا بروند.',
      one: '۱ وظیفه در این وضعیت است. انتخاب کنید به کجا برود.',
    );
    return '$_temp0';
  }

  @override
  String get grpIMoveTasksTo => 'انتقال وظایف به';

  @override
  String get grpIMoveTasksAndDelete => 'انتقال وظایف و حذف';

  @override
  String get grpIWhoMayMove => 'چه کسی می‌تواند این انتقال را انجام دهد';

  @override
  String get grpIAnyRole => 'هر نقش';

  @override
  String grpIOnlyRole(String name) {
    return 'فقط $name';
  }

  @override
  String get grpITaskNeedsAssignee => 'وظیفه نیاز به مسئول دارد';

  @override
  String get grpIAllSubtasksDone => 'همه زیروظیفه‌ها باید انجام شده باشند';

  @override
  String get grpIDoneOrCancelledDepth => 'انجام‌شده یا لغوشده، در هر عمق.';

  @override
  String get grpIWorkflow => 'گردش کار';

  @override
  String get grpIDiscard => 'دور انداختن';

  @override
  String get grpIWorkflowSaved => 'گردش کار ذخیره شد';

  @override
  String get grpIRestrictTransitions => 'محدود کردن انتقال‌ها';

  @override
  String get grpIRestrictTransitionsHint =>
      'خاموش: هر وضعیت می‌تواند به هر وضعیت دیگر برود. روشن: فقط پیکان‌هایی که اجازه می‌دهید.';

  @override
  String get grpIRestrictCreation =>
      'وظایف جدید فقط در وضعیت پیش‌فرض شروع شوند';

  @override
  String get grpIRestrictCreationHint =>
      'خاموش: وظیفه را می‌توان در هر وضعیتی ساخت. روشن: در وضعیت ستاره‌دار شروع می‌شود و با انتقال به بقیه می‌رسد.';

  @override
  String get grpIAddStatus => 'افزودن وضعیت';

  @override
  String get grpINewStatus => 'وضعیت جدید';

  @override
  String get grpIMigrationNeedsPlace =>
      'وظایفی که انتخاب کردید به اینجا منتقل شوند به جای جدید نیاز دارند.';

  @override
  String grpIMoveArrow(String from, String to) {
    return '$from ← $to';
  }

  @override
  String grpIDeletedStillHasTasks(String name) {
    return '$name حذف شد اما هنوز وظیفه دارد.';
  }

  @override
  String get grpIMoveItsTasksTo => 'انتقال وظایف آن به';

  @override
  String grpIDrillTitle(String title, int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'وظیفه',
      one: 'وظیفه',
    );
    return '$title · $count$more $_temp0';
  }

  @override
  String get grpINoTasks => 'وظیفه‌ای نیست.';

  @override
  String get grpIDrillTruncated =>
      'فقط نخستین وظایف فهرست شده‌اند؛ برای دیدن بقیه فیلتر را محدودتر کنید.';

  @override
  String grpIDueOn(String date) {
    return 'سررسید $date';
  }

  @override
  String get grpINothingToShow => 'هنوز چیزی برای نمایش نیست.';

  @override
  String get grpIRefresh => 'تازه‌سازی';

  @override
  String get grpIWidgetMenu => 'منوی ویجت';

  @override
  String get grpIExportCsv => 'خروجی CSV';

  @override
  String get grpIRemove => 'حذف';

  @override
  String get grpISaveToSeeNumbers => 'برای دیدن اعداد ذخیره کنید.';

  @override
  String grpICsvTitle(String title) {
    return '$title (CSV)';
  }

  @override
  String get grpICsvCopied => 'CSV کپی شد.';

  @override
  String get grpISaveAsFile => 'ذخیره به صورت فایل';

  @override
  String grpILatestPoints(int limit) {
    return 'آخرین $limit نقطه نمایش داده می‌شود؛ برای دیدن همه بازه را کوتاه‌تر کنید.';
  }

  @override
  String grpITopLimit(int limit) {
    return '$limit مورد برتر نمایش داده می‌شود؛ برای دیدن بقیه فیلتر را محدودتر کنید.';
  }

  @override
  String get grpIWidget => 'ویجت';

  @override
  String get grpITitle => 'عنوان';

  @override
  String get grpIGroupBy => 'گروه‌بندی بر اساس';

  @override
  String get grpIFilterTfqlOptional => 'فیلتر (TFQL، اختیاری)';

  @override
  String get grpIPreview => 'پیش‌نمایش';

  @override
  String get grpIProject => 'پروژه';

  @override
  String get grpISprint => 'اسپرینت';

  @override
  String grpIDateRange(String start, String end) {
    return '$start ← $end';
  }

  @override
  String grpIFromDate(String date) {
    return 'از $date';
  }

  @override
  String get grpINoDates => 'بدون تاریخ';

  @override
  String grpIDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count روز',
      one: '۱ روز',
    );
    return '$_temp0';
  }

  @override
  String get grpINothingScheduled => 'در این بازه چیزی برنامه‌ریزی نشده است.';

  @override
  String get grpIOnCriticalPath => 'در مسیر بحرانی';

  @override
  String get grpIBlocked => 'مسدود';

  @override
  String grpIMovingPushes(String id, int count) {
    return 'انتقال $id تعداد $count را جابه‌جا می‌کند';
  }

  @override
  String grpIRangeShift(String from, String to) {
    return '$from  ←  $to';
  }

  @override
  String get grpIKeepThem => 'نگه‌دار (نمایش تداخل)';

  @override
  String get grpIShiftDependents => 'جابه‌جایی وابسته‌ها';

  @override
  String get grpIWeekdayMon => 'دوشنبه';

  @override
  String get grpIWeekdayTue => 'سه‌شنبه';

  @override
  String get grpIWeekdayWed => 'چهارشنبه';

  @override
  String get grpIWeekdayThu => 'پنجشنبه';

  @override
  String get grpIWeekdayFri => 'جمعه';

  @override
  String get grpIWeekdaySat => 'شنبه';

  @override
  String get grpIWeekdaySun => 'یکشنبه';

  @override
  String get grpIWorkingDays => 'روزهای کاری';

  @override
  String get grpIWorkingDaysHint =>
      'انتقال یک وظیفه از کنار دیگری روزهای تعطیل را رد می‌کند.';

  @override
  String get grpIHolidays => 'تعطیلات';

  @override
  String get grpIHolidaysHint =>
      'تاریخ‌هایی مانند 2026-12-25، جداشده با ویرگول';

  @override
  String grpITimelineChartLabel(int count) {
    return 'نمودار زمانی $count وظیفه. برای خواندن آن‌ها به نمای فهرست بروید.';
  }

  @override
  String get grpITimelineDragHint =>
      'برای جابه‌جایی یک نوار را بکشید، برای تغییر اندازه یک سر آن را. Ctrl + چرخ یا حرکت دو انگشتی بزرگ‌نمایی می‌کند.';

  @override
  String get grpIUnscheduled => 'برنامه‌ریزی‌نشده';

  @override
  String get grpIMovedLinksBreak =>
      'منتقل شد. پیوندهایی که می‌شکند قرمز نشان داده می‌شوند.';

  @override
  String get grpITimelineSaved => 'خط زمانی ذخیره شد.';

  @override
  String get grpIDay => 'روز';

  @override
  String get grpIWeek => 'هفته';

  @override
  String get grpIMonth => 'ماه';

  @override
  String get grpIQuarter => 'سه‌ماهه';

  @override
  String get grpITaskTree => 'درخت وظایف';

  @override
  String get grpIByAssignee => 'بر اساس مسئول';

  @override
  String get grpIByStatus => 'بر اساس وضعیت';

  @override
  String get grpIEarlier => 'قبلی';

  @override
  String get grpIToday => 'امروز';

  @override
  String get grpILater => 'بعدی';

  @override
  String get grpICriticalPath => 'مسیر بحرانی';

  @override
  String get grpIHideDone => 'پنهان کردن انجام‌شده‌ها';

  @override
  String get grpIShowChart => 'نمایش نمودار';

  @override
  String get grpIShowList => 'نمایش به صورت فهرست';

  @override
  String get grpIExportImage => 'خروجی به صورت تصویر';

  @override
  String get grpICurrency => 'واحد پول';

  @override
  String get grpIClear => 'پاک کردن';

  @override
  String get grpINone => 'هیچ‌کدام';

  @override
  String grpIFieldArchived(String name) {
    return '$name بایگانی شد. مقادیر ۳۰ روز نگه داشته می‌شوند.';
  }

  @override
  String get grpIFields => 'فیلدها';

  @override
  String get grpIAddField => 'افزودن فیلد';

  @override
  String get grpINoCustomFields =>
      'هنوز فیلد سفارشی وجود ندارد. برای مواردی مانند مشتری یا امتیاز داستان یکی اضافه کنید.';

  @override
  String get grpIArchivedRestorable => 'بایگانی‌شده (تا ۳۰ روز قابل بازیابی)';

  @override
  String get grpIRequired => 'الزامی';

  @override
  String grpIOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گزینه',
      one: '۱ گزینه',
    );
    return '$_temp0';
  }

  @override
  String get grpIArchive => 'بایگانی';

  @override
  String get grpIWriteComment => 'نظری بنویسید… (@ برای اشاره)';

  @override
  String get grpIComment => 'نظر';

  @override
  String get grpIBulletList => 'فهرست گلوله‌ای';

  @override
  String get grpIQuote => 'نقل قول';

  @override
  String get grpICodeBlock => 'بلوک کد';

  @override
  String get grpILink => 'پیوند';

  @override
  String get grpICouldNotReadFile => 'خواندن آن فایل ممکن نبود.';

  @override
  String get grpICtrlEnterToSend => 'برای ارسال Ctrl+Enter';

  @override
  String get grpIDeleteCommentTitle => 'این نظر حذف شود؟';

  @override
  String get grpIDeleteCommentBody =>
      'به صورت «نظر حذف شد» نمایش داده می‌شود. محتوا و تاریخچه ویرایش آن حذف می‌شود.';

  @override
  String get grpICannotSeeTask => 'آن‌ها نمی‌توانند این وظیفه را ببینند';

  @override
  String grpICannotSeeGrant(String names) {
    return '$names نمی‌توانند این وظیفه را ببینند. آن‌ها را به پروژه اضافه کنید و نظر را بفرستید، یا اشاره را بردارید.';
  }

  @override
  String grpICannotSeeRefuse(String names) {
    return '$names نمی‌توانند این وظیفه را ببینند، بنابراین نمی‌توان به آن‌ها اشاره کرد. اشاره را بردارید یا از مدیر پروژه بخواهید آن‌ها را اضافه کند.';
  }

  @override
  String get grpIOk => 'تأیید';

  @override
  String get grpIAddThemAndSend => 'افزودن و ارسال';

  @override
  String grpIEditHistory(String author) {
    return 'تاریخچه ویرایش · $author';
  }

  @override
  String grpIRevisionCurrent(String stamp) {
    return '$stamp · فعلی';
  }

  @override
  String get grpISessions => 'نشست‌ها';

  @override
  String get grpISignOutOthers => 'خروج از دستگاه‌های دیگر';

  @override
  String get grpIUnknownDevice => 'دستگاه ناشناس';

  @override
  String get grpIThisDevice => 'این دستگاه';

  @override
  String get grpISignOutThis => 'خروج از این دستگاه';

  @override
  String get grpJLink => 'پیوند';

  @override
  String get grpJInviteEmails => 'نشانی‌های ایمیل';

  @override
  String grpJInviteEmailsHelp(int max) {
    return 'چند مورد را با ویرگول جدا کنید. حداکثر $max.';
  }

  @override
  String get grpJAdd => 'افزودن';

  @override
  String grpJInviteInvalidEmail(String email) {
    return '«$email» نشانی ایمیل معتبری نیست.';
  }

  @override
  String grpJInviteTooMany(int max) {
    return 'هر بار حداکثر $max نفر را می‌توانید دعوت کنید.';
  }

  @override
  String get grpJInviteSendAll => 'ارسال دعوت‌نامه‌ها';

  @override
  String grpJInviteSendCount(int count) {
    return 'ارسال $count';
  }

  @override
  String grpJInvited(int count) {
    return '$count نفر دعوت شد.';
  }

  @override
  String grpJInviteSkipped(String emails) {
    return 'از قبل عضو هستند، رد شد: $emails';
  }

  @override
  String get grpJExpiresAfter => 'انقضا پس از';

  @override
  String grpJDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count روز',
      one: '$count روز',
    );
    return '$_temp0';
  }

  @override
  String get grpJMaxUses => 'حداکثر استفاده';

  @override
  String get grpJMaxUsesHelp => 'برای نامحدود خالی بگذارید.';

  @override
  String grpJMaxUsesInvalid(int max) {
    return 'عددی از ۱ تا $max وارد کنید یا خالی بگذارید.';
  }

  @override
  String get grpJCreateLink => 'ساخت پیوند';

  @override
  String get grpJCopyLink => 'کپی پیوند';

  @override
  String get grpJRole => 'نقش';

  @override
  String get grpJInvitationTitle => 'دعوت‌نامه';

  @override
  String get grpJJoin => 'پیوستن';

  @override
  String get grpJDecline => 'رد کردن';

  @override
  String get grpJGoToTaskForge => 'رفتن به TaskForge';

  @override
  String get grpJInvitedToJoin => 'شما به پیوستن دعوت شده‌اید';

  @override
  String grpJInviterInvitedYou(String name) {
    return '$name شما را به پیوستن دعوت کرد';
  }

  @override
  String get grpJBack => 'بازگشت';

  @override
  String get grpJMembers => 'اعضا';

  @override
  String get grpJInvite => 'دعوت';

  @override
  String get grpJPending => 'در انتظار';

  @override
  String grpJJoined(String date) {
    return 'پیوست در $date';
  }

  @override
  String get grpJRemoveFromWorkspace => 'حذف از فضای کاری';

  @override
  String get grpJSearchMembers => 'جستجوی اعضا';

  @override
  String grpJRemoveMember(String name) {
    return 'حذف $name';
  }

  @override
  String get grpJOwnerCannotLeave =>
      'شما مالک این فضای کاری هستید و نمی‌توانید آن را ترک کنید. انتقال مالکیت هنوز ممکن نیست.';

  @override
  String get grpJLeaveWorkspace => 'ترک فضای کاری';

  @override
  String grpJRemoveMemberTitle(String name) {
    return '$name حذف شود؟';
  }

  @override
  String get grpJRemoveMemberBody =>
      'دسترسی آنها به این فضای کاری قطع می‌شود. بعداً می‌توانید دوباره دعوتشان کنید.';

  @override
  String get grpJRemove => 'حذف';

  @override
  String grpJLeaveTitle(String name) {
    return '$name ترک شود؟';
  }

  @override
  String get grpJLeaveBody =>
      'تا زمانی که کسی دوباره شما را دعوت کند، دسترسی‌تان به این فضای کاری قطع می‌شود.';

  @override
  String get grpJLeave => 'ترک';

  @override
  String grpJErrorRetry(String error) {
    return '$error تلاش دوباره';
  }

  @override
  String get grpJLinkCopied => 'پیوند کپی شد.';

  @override
  String get grpJNoInvitations => 'هنوز دعوت‌نامه‌ای وجود ندارد.';

  @override
  String get grpJInvitationResent => 'دعوت‌نامه دوباره ارسال شد.';

  @override
  String get grpJResend => 'ارسال مجدد';

  @override
  String get grpJRevoke => 'لغو';

  @override
  String get grpJStatePending => 'در انتظار';

  @override
  String get grpJStateExpired => 'منقضی‌شده';

  @override
  String get grpJStateRevoked => 'لغوشده';

  @override
  String get grpJStateUsedUp => 'مصرف‌شده';

  @override
  String grpJUsesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بار استفاده',
      one: '$count بار استفاده',
    );
    return '$_temp0';
  }

  @override
  String grpJUsesOfMax(int uses, int max) {
    return '$uses/$max بار استفاده';
  }

  @override
  String get grpJInviteLink => 'پیوند دعوت';

  @override
  String grpJInvitationMeta(String name, String date) {
    return 'توسط $name · انقضا $date';
  }

  @override
  String get grpJChangeRole => 'تغییر نقش';

  @override
  String get grpJBlockOptions => 'گزینه‌های بلوک';

  @override
  String get grpJMoveUp => 'انتقال به بالا';

  @override
  String get grpJMoveDown => 'انتقال به پایین';

  @override
  String get grpJAddBlockBelow => 'افزودن بلوک در پایین';

  @override
  String get grpJDelete => 'حذف';

  @override
  String grpJTurnInto(String label) {
    return 'تبدیل به $label';
  }

  @override
  String get grpJClickToWrite => 'برای شروع نوشتن اینجا کلیک کنید';

  @override
  String get grpJAddBlock => 'افزودن بلوک';

  @override
  String get grpJDocs => 'اسناد';

  @override
  String get grpJPickPage => 'یک صفحه انتخاب کنید یا صفحه‌ای بسازید.';

  @override
  String get grpJNoMatchingBlocks => 'بلوک مطابقی یافت نشد';

  @override
  String get grpJNoMatchingPages => 'صفحه مطابقی یافت نشد';

  @override
  String get grpJTableRow => 'ردیف';

  @override
  String get grpJTableColumn => 'ستون';

  @override
  String get grpJNoImageAddress => 'هنوز نشانی تصویری وجود ندارد';

  @override
  String get grpJImageLoadFailed => 'بارگذاری تصویر ممکن نشد';

  @override
  String get grpJEditImage => 'ویرایش تصویر';

  @override
  String get grpJLoadingTask => 'در حال بارگیری وظیفه...';

  @override
  String get grpJNoAccessTask => 'دسترسی به این وظیفه ندارید';

  @override
  String grpJUnknownBlock(String type) {
    return 'این بلوک ($type) به نسخه جدیدتر TaskForge نیاز دارد. به همین شکل نگه داشته می‌شود.';
  }

  @override
  String get grpJLinkAPage => 'پیوند یک صفحه';

  @override
  String get grpJNoPagesYetLong => 'هنوز صفحه‌ای وجود ندارد.';

  @override
  String get grpJRelatedDocs => 'اسناد مرتبط';

  @override
  String get grpJNoPagesYet => 'هنوز صفحه‌ای نیست.';

  @override
  String get grpJLinked => 'پیوندشده';

  @override
  String get grpJEmbedded => 'جاسازی‌شده';

  @override
  String get grpJUnlink => 'حذف پیوند';

  @override
  String grpJChangeTone(String tone) {
    return 'تغییر لحن ($tone)';
  }

  @override
  String get grpJBold => 'پررنگ';

  @override
  String get grpJItalic => 'مورب';

  @override
  String get grpJStrikethrough => 'خط‌خورده';

  @override
  String get grpJCode => 'کد';

  @override
  String get grpJHintParagraph =>
      'برای بلوک‌ها «/» و برای اشاره به صفحه «[[» را بنویسید';

  @override
  String grpJHintHeading(int level) {
    return 'عنوان $level';
  }

  @override
  String get grpJCodeLanguageHint => 'زبان';

  @override
  String get grpJUndo => 'بازگردانی';

  @override
  String get grpJRestore => 'بازیابی';

  @override
  String get grpJName => 'نام';

  @override
  String grpJWorkspaceDeleted(String name) {
    return '«$name» حذف شد. تا ۷ روز قابل بازیابی است.';
  }

  @override
  String get grpJDangerZone => 'منطقه خطر';

  @override
  String get grpJDangerZoneBody =>
      'حذف فضای کاری آن را برای همه پنهان می‌کند. تا ۷ روز می‌توانید آن را بازیابی کنید.';

  @override
  String get grpJDeleteWorkspace => 'حذف فضای کاری';

  @override
  String get grpJDeleteWorkspaceQ => 'فضای کاری حذف شود؟';

  @override
  String grpJTypeNameToConfirm(String name) {
    return 'برای تأیید «$name» را بنویسید';
  }

  @override
  String get grpJNewWorkspace => 'فضای کاری جدید';

  @override
  String get grpJCreateYourWorkspace => 'فضای کاری خود را بسازید';

  @override
  String get grpJWorkspaceHolds =>
      'فضای کاری پروژه‌ها و وظایف تیم شما را نگه می‌دارد.';

  @override
  String get grpJUrl => 'نشانی URL';

  @override
  String get grpJCreateWorkspace => 'ساخت فضای کاری';

  @override
  String get grpJRecentlyDeleted => 'به‌تازگی حذف‌شده';

  @override
  String get grpJSwitchWorkspace => 'تغییر فضای کاری';

  @override
  String get grpJTimerRunning => 'زمان‌سنج در حال اجرا';

  @override
  String grpJTimerStoppedOn(String key, String title) {
    return 'زمان‌سنج روی $key $title متوقف شد';
  }

  @override
  String get grpJTime => 'زمان';

  @override
  String get grpJStop => 'توقف';

  @override
  String get grpJStartTimer => 'شروع زمان‌سنج';

  @override
  String get grpJAddTime => 'افزودن زمان';

  @override
  String grpJTimeOfEstimate(String logged, String estimate) {
    return '$logged از $estimate';
  }

  @override
  String grpJTimeLogged(String logged) {
    return '$logged ثبت شده';
  }

  @override
  String grpJTimeBillable(String duration) {
    return '$duration قابل صورتحساب';
  }

  @override
  String get grpJChangeEstimate => 'تغییر برآورد';

  @override
  String get grpJSetEstimate => 'تنظیم برآورد';

  @override
  String get grpJRunning => 'در حال اجرا';

  @override
  String get grpJLoggedLabel => 'ثبت‌شده';

  @override
  String get grpJYou => 'شما';

  @override
  String get grpJBillableSuffix => 'قابل صورتحساب';

  @override
  String get grpJOverlapsEntry => 'با ورودی دیگری همپوشانی دارد';

  @override
  String get grpJOver24h => 'بیش از ۲۴ ساعت: بررسی کنید';

  @override
  String get grpJEdit => 'ویرایش';

  @override
  String get grpJStopTheTimer => 'توقف زمان‌سنج';

  @override
  String get grpJRoleActions => 'اقدامات نقش';

  @override
  String get grpJRename => 'تغییر نام';

  @override
  String get grpJBuiltInReadOnly => 'داخلی، فقط‌خواندنی';

  @override
  String get grpJRolesAndPermissions => 'نقش‌ها و مجوزها';

  @override
  String get grpJNewRole => 'نقش جدید';

  @override
  String get grpJActivity => 'فعالیت';

  @override
  String get grpJNoActivity => 'هنوز فعالیتی ثبت نشده است.';

  @override
  String get grpJDebugTitle => 'TaskForge — اتصال';

  @override
  String grpJPingLabel(String label) {
    return 'پینگ $label';
  }

  @override
  String grpJPingError(String error) {
    return 'خطا: $error';
  }

  @override
  String get grpKClosePalette => 'بستن پالت دستورها';

  @override
  String get grpKGroupGeneral => 'عمومی';

  @override
  String get grpKGroupGoTo => 'رفتن به';

  @override
  String get grpKGroupProjects => 'پروژه‌ها';

  @override
  String get grpKGroupWorkspace => 'فضای کار';

  @override
  String get grpKGroupAccount => 'حساب';

  @override
  String get grpKGroupThisProject => 'این پروژه';

  @override
  String get grpKGroupDocs => 'اسناد';

  @override
  String get grpKGroupDashboards => 'داشبوردها';

  @override
  String get grpKGroupListView => 'نمای فهرست';

  @override
  String get grpKGroupThisTask => 'این وظیفه';

  @override
  String grpKGoTo(String title) {
    return 'رفتن به $title';
  }

  @override
  String grpKProjectPageOf(String title) {
    return '$title این پروژه';
  }

  @override
  String get grpKPaletteOpen => 'باز کردن پالت دستورها';

  @override
  String get grpKSearch => 'جستجو';

  @override
  String get grpKSearchSem => 'جستجوی وظایف، نظرات، پروژه‌ها و افراد';

  @override
  String get grpKShortcuts => 'میانبرهای صفحه‌کلید';

  @override
  String get grpKShortcutsSem => 'نمایش میانبرهای صفحه‌کلید';

  @override
  String get grpKTHome => 'خانه';

  @override
  String get grpKTInbox => 'صندوق ورودی';

  @override
  String get grpKTCalendar => 'تقویم فضای کار';

  @override
  String get grpKTDocs => 'اسناد';

  @override
  String get grpKTDashboards => 'داشبوردها';

  @override
  String get grpKTTimesheet => 'برگه زمان';

  @override
  String get grpKTMembers => 'اعضا';

  @override
  String get grpKTArchivedProjects => 'پروژه‌های بایگانی‌شده';

  @override
  String get grpKTPrivateProjects => 'پروژه‌های خصوصی';

  @override
  String get grpKTWorkspaceSettings => 'تنظیمات فضای کار';

  @override
  String get grpKAuditLog => 'گزارش حسابرسی';

  @override
  String get grpKAuditSem => 'رفتن به گزارش حسابرسی';

  @override
  String get grpKTRoles => 'نقش‌ها و دسترسی‌ها';

  @override
  String get grpKTCreateWorkspace => 'ایجاد فضای کار';

  @override
  String get grpKTNotifPrefs => 'تنظیمات اعلان‌ها';

  @override
  String get grpKTDevices => 'دستگاه‌های واردشده';

  @override
  String get grpKTChangePassword => 'تغییر گذرواژه';

  @override
  String get grpKTTasks => 'وظایف';

  @override
  String get grpKTSprints => 'اسپرینت‌ها';

  @override
  String get grpKTAutomations => 'خودکارسازی‌ها';

  @override
  String get grpKTWorkflow => 'گردش کار';

  @override
  String get grpKTCustomFields => 'فیلدهای سفارشی';

  @override
  String get grpKTProjectSettings => 'تنظیمات پروژه';

  @override
  String get grpKSwitchWs => 'تعویض فضای کار';

  @override
  String get grpKSwitchWsSem => 'رفتن به فضای کار دیگر';

  @override
  String get grpKToggleDark => 'تغییر حالت تیره';

  @override
  String get grpKToggleDarkSem => 'جابجایی بین پوسته روشن و تیره';

  @override
  String get grpKCreateProject => 'ایجاد پروژه';

  @override
  String get grpKCreateDoc => 'ایجاد سند';

  @override
  String get grpKCreateDashboard => 'ایجاد داشبورد';

  @override
  String get grpKCreateSprint => 'ایجاد اسپرینت';

  @override
  String get grpKCreateSprintSem => 'ایجاد اسپرینت در این پروژه';

  @override
  String get grpKInviteMember => 'دعوت عضو';

  @override
  String get grpKInviteMemberSem => 'دعوت کسی به این فضای کار';

  @override
  String get grpKTImportExport => 'درون‌ریزی و برون‌بری';

  @override
  String get grpKTOffline => 'آفلاین و ذخیره‌سازی';

  @override
  String get grpKSignOut => 'خروج';

  @override
  String get grpKSignOutSem => 'خروج از این دستگاه';

  @override
  String get grpKNewTask => 'وظیفه جدید';

  @override
  String get grpKNewTaskSem => 'ایجاد وظیفه در این پروژه';

  @override
  String get grpKRenameTask => 'تغییر نام وظیفه زیر نشانگر';

  @override
  String get grpKRenameTaskSem =>
      'تغییر نام وظیفه‌ای که نشانگر در فهرست روی آن است';

  @override
  String get grpKChangeStatus => 'تغییر وضعیت این وظیفه';

  @override
  String get grpKChangeStatusSem => 'تغییر وضعیت وظیفه باز';

  @override
  String get grpKAssignMe => 'واگذاری این وظیفه به من';

  @override
  String get grpKAssignMeSem => 'واگذاری وظیفه باز به من';

  @override
  String get grpKTimerStart => 'شروع زمان‌سنج برای این وظیفه';

  @override
  String get grpKTimerStartSem => 'شروع زمان‌سنج برای وظیفه باز';

  @override
  String get grpKTimerStop => 'توقف زمان‌سنج';

  @override
  String get grpKTimerStopSem => 'توقف زمان‌سنج در حال اجرا';

  @override
  String get grpKViewList => 'نمای فهرست';

  @override
  String get grpKViewBoard => 'نمای تابلو';

  @override
  String get grpKViewCalendar => 'نمای تقویم';

  @override
  String get grpKViewTimeline => 'نمای خط زمانی';

  @override
  String get grpKShowList => 'نمایش این پروژه به صورت فهرست';

  @override
  String get grpKShowBoard => 'نمایش این پروژه به صورت تابلو';

  @override
  String get grpKShowCalendar => 'نمایش این پروژه به صورت تقویم';

  @override
  String get grpKShowTimeline => 'نمایش این پروژه به صورت خط زمانی';

  @override
  String get grpLGeneric => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get grpLNetCheck =>
      'اتصال به سرور ممکن نیست. اتصال خود را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get grpLNetCheckShort =>
      'اتصال به سرور برقرار نشد. اتصال خود را بررسی کنید.';

  @override
  String get grpLNetTry => 'اتصال به سرور برقرار نشد. دوباره تلاش کنید.';

  @override
  String get grpLNetOffline =>
      'این کار به اتصال با سرور نیاز دارد. پس از بازگشت به حالت آنلاین دوباره کار می‌کند.';

  @override
  String get grpLNoConn =>
      'اتصالی وجود ندارد. آن را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get grpLNoPerm => 'شما اجازه ندارید.';

  @override
  String get grpLNoPermDo => 'شما اجازه انجام این کار را ندارید.';

  @override
  String get grpLNoAccess => 'شما به آن دسترسی ندارید.';

  @override
  String get grpLCheckValues => 'مقادیر را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get grpLNotValid => 'این معتبر نیست.';

  @override
  String get grpLArchived =>
      'این پروژه بایگانی شده است. برای ایجاد تغییر آن را بازیابی کنید.';

  @override
  String get grpLGone => 'این دیگر وجود ندارد.';

  @override
  String get grpLTaskConflict => 'شخص دیگری ابتدا این وظیفه را تغییر داد.';

  @override
  String get grpLTaskTransition => 'گردش‌کار این انتقال را مجاز نمی‌داند.';

  @override
  String get grpLTaskHasSubtasks =>
      'این وظیفه زیروظیفه دارد: انتخاب کنید با آن‌ها چه شود.';

  @override
  String get grpLTaskCycle =>
      'یک وظیفه نمی‌تواند زیروظیفهٔ خودش یا یکی از زیروظیفه‌های خودش شود.';

  @override
  String grpLTaskBlocked(String detail) {
    return 'مسدود شده توسط $detail: ابتدا آن‌ها را تمام کنید.';
  }

  @override
  String grpLTaskLinkCycle(String detail) {
    return 'این وظایف در یک حلقه یکدیگر را مسدود می‌کنند: $detail.';
  }

  @override
  String get grpLTaskLinkExists =>
      'این وظایف از قبل به همین شکل پیوند شده‌اند.';

  @override
  String get grpLFieldRequired => 'یک فیلد ضروری مقدار ندارد.';

  @override
  String get grpLTaskGone => 'این وظیفه دیگر وجود ندارد.';

  @override
  String get grpLCommentConflict => 'شخص دیگری ابتدا این نظر را تغییر داد.';

  @override
  String get grpLCommentLocked => 'این نظر دیگر قابل ویرایش نیست.';

  @override
  String get grpLMentionNoAccess =>
      'کسی که به او اشاره کردید نمی‌تواند این وظیفه را ببیند.';

  @override
  String get grpLCommentCheck => 'نظر را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get grpLCommentGone => 'این نظر دیگر وجود ندارد.';

  @override
  String get grpLSlugTaken => 'این نشانی قبلاً گرفته شده است';

  @override
  String get grpLWsStale =>
      'این فضای کار در جای دیگری تغییر کرده است. برای دیدن آخرین نسخه، تازه‌سازی کنید.';

  @override
  String get grpLWsNotRestorable => 'این فضای کار دیگر قابل بازیابی نیست.';

  @override
  String get grpLOwnerNeeded => 'یک فضای کار دست‌کم به یک مالک نیاز دارد.';

  @override
  String get grpLInvEmailMismatch =>
      'این دعوت‌نامه برای نشانی ایمیل دیگری است.';

  @override
  String get grpLInvExpired =>
      'این دعوت‌نامه منقضی شده است. دعوت‌نامهٔ جدید بخواهید.';

  @override
  String get grpLInvRevoked => 'این دعوت‌نامه لغو شده است.';

  @override
  String get grpLInvBeforeRemoval =>
      'این دعوت‌نامه پیش از حذف شما صادر شده است. دعوت‌نامهٔ جدید بخواهید.';

  @override
  String get grpLInvUsedUp => 'این دعوت‌نامه قبلاً استفاده شده و تمام شده است.';

  @override
  String get grpLInvNotFound => 'این دعوت‌نامه وجود ندارد.';

  @override
  String get grpLInvRate =>
      'در حال حاضر دعوت‌نامه‌های زیادی ارسال شده است. کمی صبر کنید و دوباره تلاش کنید.';

  @override
  String get grpLInvExists => 'این شخص قبلاً دعوت شده یا عضو است.';

  @override
  String get grpLWfInvalid =>
      'گردش‌کار مشکل دارد. برای ذخیره، آن‌ها را برطرف کنید.';

  @override
  String get grpLWfConflict =>
      'شخص دیگری ابتدا گردش‌کار را ذخیره کرد. تغییرات شما هنوز اینجاست: تغییرات را بررسی کنید و دوباره ذخیره کنید.';

  @override
  String get grpLProjectGone => 'این پروژه دیگر وجود ندارد.';

  @override
  String get grpLDashDenied =>
      'شما اجازهٔ انجام این کار در این داشبورد را ندارید.';

  @override
  String get grpLDashNotFound => 'این داشبورد یا ویجت در دسترس نیست.';

  @override
  String get grpLDashHeavy =>
      'محاسبهٔ این ویجت بیش از حد طول می‌کشد. فیلتر آن را محدودتر کنید.';

  @override
  String get grpLDashConflict =>
      'شخص دیگری این داشبورد را تغییر داد. آن را دوباره بارگیری کنید و دوباره تلاش کنید.';

  @override
  String get grpLNotifGone => 'این اعلان دیگر وجود ندارد.';

  @override
  String get grpLViewConflict => 'شخص دیگری ابتدا این چیدمان را تغییر داد.';

  @override
  String get grpLViewInvalid => 'این چیدمان معتبر نیست.';

  @override
  String get grpLViewNameTaken => 'چیدمانی با این نام از قبل وجود دارد.';

  @override
  String get grpLViewLimit =>
      'این بیشترین تعداد چیدمانی است که می‌توانید اینجا نگه دارید.';

  @override
  String get grpLViewGone => 'این چیدمان دیگر وجود ندارد.';

  @override
  String get grpLAutoDenied =>
      'برای این کار به مجوز «مدیریت خودکارسازی‌ها» نیاز دارید.';

  @override
  String get grpLAutoConflict =>
      'شخص دیگری ابتدا این قاعده را تغییر داد. آخرین نسخه را بارگیری و دوباره تلاش کنید.';

  @override
  String get grpLImpCannot => 'اکنون نمی‌توان این کار را انجام داد.';

  @override
  String get grpLImpTooBig => 'این فایل بزرگ‌تر از حد مجاز این سرور است.';

  @override
  String get grpLImpDenied =>
      'فقط مدیران می‌توانند داده‌ها را وارد یا صادر کنند.';

  @override
  String get grpLImpNotFound => 'این وارد‌سازی دیگر وجود ندارد.';

  @override
  String get grpLAuditDenied => 'شما اجازهٔ خواندن گزارش ممیزی را ندارید.';

  @override
  String get grpLAuditTaskNA => 'این وظیفه در دسترس نیست.';

  @override
  String get grpLAuditFilters => 'این فیلترها معتبر نیستند.';

  @override
  String get grpLSprintConflict =>
      'شخص دیگری ابتدا این را تغییر داد. دوباره بارگیری کنید و تلاش کنید.';

  @override
  String get grpLFieldNameTaken => 'فیلدی با این نام از قبل وجود دارد.';

  @override
  String grpLFieldLimit(int count) {
    return 'یک پروژه حداکثر می‌تواند $count فیلد فعال داشته باشد.';
  }

  @override
  String get grpLFieldNeedsRemap =>
      'برخی گزینه‌های حذف‌شده هنوز استفاده می‌شوند: انتخاب کنید مقادیر آن‌ها چه شود.';

  @override
  String get grpLFieldConflict =>
      'شخص دیگری ابتدا این فیلد را تغییر داد؛ دوباره بارگیری کنید و تلاش کنید.';

  @override
  String get grpLFieldGone => 'این فیلد دیگر وجود ندارد.';

  @override
  String get grpLFilterInvalid => 'این فیلتر معتبر نیست.';

  @override
  String get grpLFilterNameTaken => 'فیلتری با این نام از قبل اینجا وجود دارد.';

  @override
  String get grpLFilterLimit =>
      'این بیشترین تعداد فیلتری است که می‌توانید اینجا نگه دارید.';

  @override
  String get grpLFilterGone => 'این فیلتر دیگر وجود ندارد.';

  @override
  String get grpLFilterConflict => 'شخص دیگری ابتدا این فیلتر را تغییر داد.';

  @override
  String get grpLAttTooBig => 'این فایل بزرگ‌تر از حد مجاز پیوست است.';

  @override
  String get grpLAttQuota =>
      'این فضای کار تمام فضای ذخیره‌سازی خود را استفاده کرده است.';

  @override
  String get grpLAttTooMany =>
      'آپلودهای باز بسیار زیاد است. ابتدا برخی را تمام یا لغو کنید.';

  @override
  String get grpLAttUnavailable =>
      'اکنون بررسی فایل ممکن نبود. دوباره تلاش کنید.';

  @override
  String get grpLAttChunk => 'بخشی از فایل پذیرفته نشد. دوباره تلاش کنید.';

  @override
  String get grpLAttRefusedPlain => 'این نوع فایل پذیرفته نمی‌شود.';

  @override
  String grpLAttRefused(String detail) {
    return 'این فایل پذیرفته نمی‌شود: $detail';
  }

  @override
  String get grpLAttIncomplete => 'آپلود کامل نشد. دوباره تلاش کنید.';

  @override
  String get grpLAttExpired => 'این آپلود منقضی شد. دوباره تلاش کنید.';

  @override
  String get grpLAttUnreadable => 'خواندن این فایل ممکن نشد.';

  @override
  String get grpLAttNotAllowed => 'شما اجازهٔ انجام این کار را ندارید.';

  @override
  String get grpLAttArchived =>
      'این پروژه بایگانی شده است: فایل‌ها فقط‌خواندنی هستند.';

  @override
  String get grpLAttGone =>
      'این حذف شده است: فایل، نظر یا وظیفه برداشته شده است.';

  @override
  String get grpLDocNotFound =>
      'این صفحه وجود ندارد یا نمی‌توانید آن را باز کنید.';

  @override
  String get grpLDocConflict => 'شخص دیگری ابتدا این صفحه را تغییر داد.';

  @override
  String get grpLDocArchived => 'این صفحه بایگانی شده است.';

  @override
  String get grpLDocCycle => 'یک صفحه نمی‌تواند زیر خودش قرار بگیرد.';

  @override
  String get grpLKeyTaken =>
      'این کلید قبلاً توسط پروژهٔ دیگری استفاده شده است.';

  @override
  String get grpLKeyLocked =>
      'پس از آنکه پروژه وظیفه داشته باشد، کلید قابل تغییر نیست.';

  @override
  String get grpLLastMember => 'یک پروژهٔ خصوصی دست‌کم به یک عضو نیاز دارد.';

  @override
  String get grpLProjConflict =>
      'این پروژه در این فاصله تغییر کرد. دوباره بارگیری شد — دوباره تلاش کنید.';

  @override
  String get grpLRoleBuiltin => 'نقش‌های داخلی قابل تغییر یا حذف نیستند.';

  @override
  String get grpLRoleNameTaken => 'نقشی با این نام از قبل وجود دارد.';

  @override
  String get grpLRoleGone => 'این نقش دیگر وجود ندارد.';

  @override
  String get grpLRoleConflict =>
      'این نقش در این فاصله تغییر کرد. دوباره بارگیری شد — دوباره تلاش کنید.';

  @override
  String get grpLRepeatInvalid => 'این تکرار معتبر نیست.';

  @override
  String get grpLRepeatDenied => 'شما اجازهٔ تغییر نحوهٔ تکرار این را ندارید.';

  @override
  String get grpMPriUrgent => 'فوری';

  @override
  String get grpMPriHigh => 'بالا';

  @override
  String get grpMPriNormal => 'عادی';

  @override
  String get grpMPriLow => 'پایین';

  @override
  String get grpMPriNone => 'هیچ';

  @override
  String get grpMLinkBlocks => 'مسدود می‌کند';

  @override
  String get grpMLinkBlockedBy => 'مسدود شده توسط';

  @override
  String get grpMLinkRelates => 'مرتبط با';

  @override
  String get grpMLinkDuplicates => 'تکراری است';

  @override
  String get grpMLinkDuplicatedBy => 'تکرار شده توسط';

  @override
  String get grpMCatNotStarted => 'شروع نشده';

  @override
  String get grpMCatActive => 'فعال';

  @override
  String get grpMCatDone => 'انجام شده';

  @override
  String get grpMCatCancelled => 'لغو شده';

  @override
  String get grpMFtypeText => 'متن';

  @override
  String get grpMFtypeNumber => 'عدد';

  @override
  String get grpMFtypeSelect => 'انتخابی';

  @override
  String get grpMFtypeMulti => 'چندانتخابی';

  @override
  String get grpMFtypeDate => 'تاریخ';

  @override
  String get grpMFtypeCheckbox => 'چک‌باکس';

  @override
  String get grpMFtypeUrl => 'پیوند';

  @override
  String get grpMFtypeUser => 'کاربر';

  @override
  String get grpMFtypeMoney => 'پول';

  @override
  String get grpMTrigTaskCreated => 'وظیفه‌ای ایجاد شود';

  @override
  String get grpMTrigStatusChanged => 'وضعیتی تغییر کند';

  @override
  String get grpMTrigFieldChanged => 'فیلدی تغییر کند';

  @override
  String get grpMTrigAssigned => 'کسی واگذار شود';

  @override
  String get grpMTrigDueDateReached => 'موعدی فرا برسد';

  @override
  String get grpMTrigCommentAdded => 'نظری افزوده شود';

  @override
  String get grpMActSetField => 'تنظیم یک فیلد';

  @override
  String get grpMActSetStatus => 'تنظیم وضعیت';

  @override
  String get grpMActSetAssignee => 'تغییر مسئولان';

  @override
  String get grpMActAddComment => 'افزودن نظر';

  @override
  String get grpMActCreateSubtask => 'ایجاد زیروظیفه';

  @override
  String get grpMActNotify => 'اطلاع‌رسانی به افراد';

  @override
  String get grpMActWebhook => 'فراخوانی وب‌هوک';

  @override
  String get grpMRunSucceeded => 'موفق';

  @override
  String get grpMRunFailed => 'ناموفق';

  @override
  String get grpMRunSkippedCondition => 'ردشده: شرط';

  @override
  String get grpMRunSkippedLoop => 'متوقف: حلقه';

  @override
  String get grpMRunSkippedRate => 'متوقف: اجراهای زیاد';

  @override
  String get grpMWkNumber => 'عدد';

  @override
  String get grpMWkBar => 'نمودار میله‌ای';

  @override
  String get grpMWkLine => 'نمودار خطی';

  @override
  String get grpMWkPie => 'نمودار دایره‌ای';

  @override
  String get grpMWkTable => 'جدول';

  @override
  String get grpMWkBurndown => 'بردان';

  @override
  String get grpMWkWorkload => 'حجم کار';

  @override
  String get grpMMeasCount => 'تعداد وظایف';

  @override
  String get grpMMeasPoints => 'امتیاز داستان';

  @override
  String get grpMMeasEstimateHours => 'ساعت‌های برآوردی';

  @override
  String get grpMMeasLoggedHours => 'ساعت‌های ثبت‌شده';

  @override
  String get grpMMeasCycleDays => 'زمان چرخه (روز)';

  @override
  String get grpMScopeAll => 'همه وظایف';

  @override
  String get grpMScopeOpen => 'وظایف باز';

  @override
  String get grpMScopeDone => 'وظایف انجام‌شده';

  @override
  String get grpMVisPersonal => 'فقط من';

  @override
  String get grpMVisProject => 'همه در پروژه';

  @override
  String get grpMVisWorkspace => 'همه در فضای کاری';

  @override
  String get grpMLblStatus => 'وضعیت';

  @override
  String get grpMLblStatusCategory => 'دستهٔ وضعیت';

  @override
  String get grpMLblPerson => 'فرد';

  @override
  String get grpMLblPriority => 'اولویت';

  @override
  String get grpMLblProject => 'پروژه';

  @override
  String get grpMLblSprint => 'اسپرینت';

  @override
  String get grpMLblCreatedDay => 'ایجاد (روز)';

  @override
  String get grpMLblCreatedWeek => 'ایجاد (هفته)';

  @override
  String get grpMLblDueWeek => 'موعد (هفته)';

  @override
  String get grpMImpJiraCsv => 'Jira (خروجی CSV)';

  @override
  String get grpMImpJiraJson => 'Jira (JSON)';

  @override
  String get grpMImpClickupCsv => 'ClickUp (خروجی CSV)';

  @override
  String get grpMImpClickupJson => 'ClickUp (JSON)';

  @override
  String get grpMImpCsv => 'هر فایل CSV';

  @override
  String get grpMImpTaskforge => 'خروجی TaskForge (tasks.json)';

  @override
  String get grpMNkAssigned => 'واگذار شده به شما';

  @override
  String get grpMNkMentioned => 'اشاره‌ها';

  @override
  String get grpMNkCommented => 'نظرها';

  @override
  String get grpMNkStatusChanged => 'تغییرات وضعیت';

  @override
  String get grpMNkDueSoon => 'موعد نزدیک';

  @override
  String get grpMNkTimerLong => 'زمان‌سنج‌های طولانی';

  @override
  String get grpMNkUnknown => 'اعلان';

  @override
  String get grpMIfAll => 'همه';

  @override
  String get grpMIfUnread => 'خوانده‌نشده';

  @override
  String get grpMIfMentions => 'اشاره‌ها';

  @override
  String get grpMIfAssigned => 'واگذار شده';

  @override
  String get grpMIfSnoozed => 'به تعویق افتاده';

  @override
  String get grpMIfArchived => 'بایگانی‌شده';

  @override
  String get grpMEmOff => 'خاموش';

  @override
  String get grpMEmInstant => 'فوری';

  @override
  String get grpMEmDigest => 'خلاصهٔ روزانه';

  @override
  String get grpMRkSchedule => 'طبق برنامه';

  @override
  String get grpMRkAfterCompletion => 'پس از تکمیل';

  @override
  String get grpMLblOpEq => 'است';

  @override
  String get grpMLblOpNe => 'نیست';

  @override
  String get grpMLblOpLt => 'پیش از / کمتر از';

  @override
  String get grpMLblOpLte => 'در یا پیش از / حداکثر';

  @override
  String get grpMLblOpGt => 'پس از / بیشتر از';

  @override
  String get grpMLblOpGte => 'در یا پس از / حداقل';

  @override
  String get grpMLblOpContains => 'شامل است';

  @override
  String get grpMLblOpNotContains => 'شامل نیست';

  @override
  String get grpMLblOpIn => 'یکی از';

  @override
  String get grpMLblOpNotIn => 'هیچ‌کدام از';

  @override
  String get grpMLblOpEmpty => 'خالی است';

  @override
  String get grpMLblOpNotEmpty => 'خالی نیست';

  @override
  String get grpMLblAssignee => 'مسئول';

  @override
  String get grpMLblStart => 'شروع';

  @override
  String get grpMLblDue => 'موعد';

  @override
  String get grpMLblCreated => 'ایجاد';

  @override
  String get grpMLblUpdated => 'به‌روزرسانی';

  @override
  String get grpMLblDueDate => 'تاریخ موعد';

  @override
  String get grpMLblProgress => 'پیشرفت زیروظایف';

  @override
  String get grpMLblViewList => 'فهرست';

  @override
  String get grpMLblViewBoard => 'تخته';

  @override
  String get grpMLblViewCalendar => 'تقویم';

  @override
  String get grpMLblViewTimeline => 'خط زمانی';

  @override
  String get grpMRelNow => 'اکنون';

  @override
  String get grpMRelJustNow => 'همین حالا';

  @override
  String grpMRelMin(int n) {
    return '$n دقیقه پیش';
  }

  @override
  String grpMRelHour(int n) {
    return '$n ساعت پیش';
  }

  @override
  String get grpMRelYesterday => 'دیروز';

  @override
  String grpMRelDay(int n) {
    return '$n روز پیش';
  }

  @override
  String get grpMNotifSomeone => 'کسی';

  @override
  String grpMNotifAssigned(String who) {
    return '$who این را به شما واگذار کرد:';
  }

  @override
  String grpMNotifMentioned(String who) {
    return '$who در این مورد از شما یاد کرد:';
  }

  @override
  String grpMNotifCommented(String who) {
    return '$who نظر داد روی';
  }

  @override
  String grpMNotifStatusChanged(String who) {
    return '$who وضعیت را تغییر داد:';
  }

  @override
  String grpMNotifMoved(String who, String fromStatus, String toStatus) {
    return '$who از $fromStatus به $toStatus منتقل کرد';
  }

  @override
  String get grpMNotifDueSoon => 'موعد نزدیک:';

  @override
  String get grpMNotifTimer => 'زمان‌سنج شما هنوز روشن است:';

  @override
  String get grpMNotifNew => 'فعالیت جدید در';

  @override
  String get grpMUnitDay => 'روز';

  @override
  String get grpMUnitDays => 'روز';

  @override
  String get grpMUnitWeek => 'هفته';

  @override
  String get grpMUnitWeeks => 'هفته';

  @override
  String get grpMUnitMonth => 'ماه';

  @override
  String get grpMUnitMonths => 'ماه';

  @override
  String get grpMUnitYear => 'سال';

  @override
  String get grpMUnitYears => 'سال';

  @override
  String get grpMSlashText => 'متن';

  @override
  String get grpMSlashH1 => 'عنوان ۱';

  @override
  String get grpMSlashH2 => 'عنوان ۲';

  @override
  String get grpMSlashH3 => 'عنوان ۳';

  @override
  String get grpMSlashBullet => 'فهرست نقطه‌ای';

  @override
  String get grpMSlashNumbered => 'فهرست شماره‌دار';

  @override
  String get grpMSlashTodo => 'فهرست بررسی';

  @override
  String get grpMSlashQuote => 'نقل‌قول';

  @override
  String get grpMSlashCode => 'کد';

  @override
  String get grpMSlashTable => 'جدول';

  @override
  String get grpMSlashDivider => 'جداکننده';

  @override
  String get grpMSlashImage => 'تصویر';

  @override
  String get grpMSlashCallout => 'یادداشت برجسته';

  @override
  String get grpMSlashTask => 'کارت وظیفه';

  @override
  String get grpMMeanSucceeded => 'همهٔ کنش‌ها اجرا شدند.';

  @override
  String get grpMMeanFailed =>
      'یک کنش ناموفق بود؛ کنش‌های پیش از آن انجام‌شده باقی می‌مانند.';

  @override
  String get grpMMeanSkippedCondition =>
      'رویداد مطابقت داشت، اما وظیفه شرط را برآورده نکرد.';

  @override
  String get grpMMeanSkippedLoop =>
      'قوانین بیش از ۵ مرحلهٔ پشت‌سرهم قوانین دیگر را فعال کردند، پس این اجرا برای پایان دادن به حلقه متوقف شد.';

  @override
  String get grpMMeanSkippedRate =>
      'این قانون در یک دقیقهٔ گذشته ۳۰ بار اجرا شده بود، پس این اجرا رد شد.';

  @override
  String get grpMStepOk => 'موفق';

  @override
  String get grpMStepFailed => 'ناموفق';

  @override
  String get grpMStepNotRun => 'اجرا نشد';

  @override
  String get grpMStepPlanned => 'برنامه‌ریزی‌شده';

  @override
  String get grpMStepWouldFail => 'ناموفق می‌شد';

  @override
  String get grp1DropCardHere => 'یک کارت را اینجا رها کنید';

  @override
  String get grp1NoCards => 'کارتی نیست';

  @override
  String get grp1StopWatchingTask => 'دنبال نکردن این وظیفه';

  @override
  String get grp1WatchTask => 'دنبال کردن این وظیفه';

  @override
  String get grp1SecondFactorRequired => 'عامل دوم لازم است.';

  @override
  String get grp1AnAutomation => 'یک خودکارسازی';

  @override
  String get grp1TheSystem => 'سامانه';

  @override
  String grp1MemberCount(int count) {
    return '$count عضو';
  }

  @override
  String get grp1SyncLive => 'زنده';

  @override
  String get grp1SyncConnecting => 'در حال اتصال…';

  @override
  String get grp1SyncReconnecting => 'در حال اتصال دوباره…';

  @override
  String get grp1SyncLiveTip => 'تغییرات دیگران همان لحظه نمایش داده می‌شود';

  @override
  String get grp1SyncNotLiveTip =>
      'زنده نیست: تغییرات دیگران پس از اتصال دوباره نمایش داده می‌شود';

  @override
  String get grp1EnterNumber => 'یک عدد وارد کنید.';

  @override
  String get grp1EnterAmount => 'یک مبلغ وارد کنید.';

  @override
  String get grp1EnterCurrency => 'ارز سه‌حرفی وارد کنید، مثلاً USD.';

  @override
  String get grp1EnterUrl => 'نشانی وبی وارد کنید که با http(s):// شروع شود';

  @override
  String get grp1UseIsoDate => 'از قالب YYYY-MM-DD استفاده کنید.';

  @override
  String get taskAddHint => 'یک کار اضافه کنید و Enter بزنید';

  @override
  String grpRMnAdded(String name) {
    return 'توسط شخص دیگری اضافه شد: $name.';
  }

  @override
  String grpRMnKept(String name) {
    return '$name نگه داشته شد: شما آن را حذف کردید، اما شخص دیگری پیش از شما آن را تغییر داد. اگر هنوز می‌خواهید، دوباره حذفش کنید.';
  }

  @override
  String grpRMnDeleted(String name) {
    return 'توسط شخص دیگری حذف شد: $name.';
  }

  @override
  String grpRMnDeletedEdited(String name) {
    return 'توسط شخص دیگری حذف شد: $name. تغییرات شما در آن کنار گذاشته شد.';
  }

  @override
  String grpRMnFieldAdopted(String what, String status, String value) {
    return 'شخص دیگری $what «$status» را به $value تغییر داد.';
  }

  @override
  String grpRMnFieldDropped(
    String what,
    String status,
    String mine,
    String value,
  ) {
    return 'تغییر شما در $what «$status» ($mine) کنار گذاشته شد: شخص دیگری آن را به $value تغییر داد.';
  }

  @override
  String grpRMnSwitchAdopted(String what, String state) {
    return 'شخص دیگری «$what» را $state کرد.';
  }

  @override
  String grpRMnSwitchDropped(String what, String state) {
    return 'تغییر شما در «$what» کنار گذاشته شد: شخص دیگری آن را $state کرد.';
  }

  @override
  String get grpRMnOrderDropped =>
      'ترتیب جدید شما برای وضعیت‌ها کنار گذاشته شد: شخص دیگری هم آن‌ها را مرتب کرد.';

  @override
  String get grpRMnReordered => 'شخص دیگری وضعیت‌ها را دوباره مرتب کرد.';

  @override
  String grpRMnMigrationLost(String name) {
    return 'وضعیتی که برای وظایف «$name» انتخاب کردید توسط شخص دیگری حذف شد: جای دیگری برای آن‌ها انتخاب کنید.';
  }

  @override
  String get grpRMnDeletedStatus => 'یک وضعیت حذف‌شده';

  @override
  String grpRMnMoveAllowed(String name) {
    return 'شخص دیگری انتقال $name را مجاز کرد.';
  }

  @override
  String grpRMnMoveRemoved(String name) {
    return 'شخص دیگری انتقال $name را حذف کرد.';
  }

  @override
  String grpRMnConditionsAdopted(String name) {
    return 'شخص دیگری شرایط انتقال $name را تغییر داد.';
  }

  @override
  String grpRMnConditionsDropped(String name) {
    return 'تغییر شما در شرایط انتقال $name کنار گذاشته شد: شخص دیگری هم آن‌ها را تغییر داد.';
  }

  @override
  String grpRMnMovesDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count انتقال از انتقال‌های شما کنار گذاشته شد زیرا وضعیتی که به کار می‌بردند از بین رفته است.',
      one: 'یکی از انتقال‌های شما کنار گذاشته شد زیرا وضعیتی که به کار می‌برد از بین رفته است.',
    );
    return '$_temp0';
  }

  @override
  String get grpRMnWhatName => 'نام';

  @override
  String get grpRMnWhatColour => 'رنگ';

  @override
  String get grpRMnWhatCategory => 'دسته';

  @override
  String get grpRMnWhatDefault => 'پیش‌فرض';

  @override
  String get grpRMnNone => 'هیچ';

  @override
  String get grpRMnIsDefault => 'پیش‌فرض';

  @override
  String get grpRMnNotDefault => 'غیر پیش‌فرض';

  @override
  String get grpRMnOn => 'روشن';

  @override
  String get grpRMnOff => 'خاموش';

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
  String get grpRKeySpace => 'فاصله';

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
  String get grpRCmForbidden => 'دیگر نمی‌توانید روی این وظیفه نظر بدهید.';

  @override
  String get grpRCmGone => 'وظیفه حذف شد.';

  @override
  String get grpRCmArchived => 'پروژه بایگانی شد.';

  @override
  String get grpRCmInvalid => 'نظر معتبر نیست.';

  @override
  String get grpRCmMention =>
      'شخصی که نام برده شده نمی‌تواند این وظیفه را ببیند.';

  @override
  String get grpRCmRefused => 'سرور نظر را رد کرد.';

  @override
  String grpRDependsRefused(String reason) {
    return 'این به تغییری وابسته است که رد شد: $reason';
  }

  @override
  String get grpRKeepUnreadable => 'خوانده نشد. دوباره تلاش کنید.';

  @override
  String grpRDenyNeed(String permission) {
    return 'به مجوز «$permission» نیاز دارید';
  }

  @override
  String grpRDenyNeedRole(String permission, String role) {
    return 'به مجوز «$permission» نیاز دارید — نقش شما $role است';
  }

  @override
  String get grpRRequestFailed => 'درخواست ناموفق بود.';

  @override
  String get grpRUnitB => 'بایت';

  @override
  String get grpRUnitKB => 'کیلوبایت';

  @override
  String get grpRUnitMB => 'مگابایت';

  @override
  String get grpRUnitGB => 'گیگابایت';

  @override
  String get grpRUnitTB => 'ترابایت';

  @override
  String grpRStorageOf(String used, String quota) {
    return '$used از $quota استفاده شده';
  }

  @override
  String grpRStorageUsed(String used) {
    return '$used استفاده شده';
  }

  @override
  String grpRChartBars(String label, int count) {
    return '$label، $count ستون';
  }

  @override
  String grpRChartSlices(String label, int count) {
    return '$label، $count برش';
  }

  @override
  String grpRChartLines(String label, int lines, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines خط',
      one: '۱ خط',
    );
    return '$label، $_temp0، $points نقطه';
  }

  @override
  String grpRChartPercent(String label, String shown, int percent) {
    return '$label، $shown، $percent درصد';
  }

  @override
  String get grpRAuCreated => 'این وظیفه را ایجاد کرد';

  @override
  String get grpRAuTrashed => 'این وظیفه را به سطل زباله برد';

  @override
  String get grpRAuRestored => 'این وظیفه را بازیابی کرد';

  @override
  String grpRAuStatus(String from, String to) {
    return 'وضعیت را از $from به $to تغییر داد';
  }

  @override
  String grpRAuAssigned(String names) {
    return '$names را اختصاص داد';
  }

  @override
  String grpRAuUnassigned(String names) {
    return 'اختصاص $names را لغو کرد';
  }

  @override
  String grpRAuAnd(String a, String b) {
    return '$a و $b';
  }

  @override
  String get grpRAuCommented => 'نظر داد';

  @override
  String get grpRAuCommentEdited => 'یک نظر را ویرایش کرد';

  @override
  String get grpRAuCommentDeleted => 'یک نظر را حذف کرد';

  @override
  String grpRAuReacted(String emoji) {
    return 'به یک نظر با $emoji واکنش نشان داد';
  }

  @override
  String grpRAuUnreacted(String emoji) {
    return 'واکنش $emoji را از یک نظر پس گرفت';
  }

  @override
  String grpRAuAttached(String file) {
    return '$file را پیوست کرد';
  }

  @override
  String grpRAuFileRemoved(String file) {
    return 'فایل $file را حذف کرد';
  }

  @override
  String get grpRAuTimeLogged => 'زمان ثبت کرد';

  @override
  String get grpRAuTimeUpdated => 'یک ورودی زمان را به‌روزرسانی کرد';

  @override
  String get grpRAuTimeDeleted => 'یک ورودی زمان را حذف کرد';

  @override
  String grpRAuLinked(String type, String task) {
    return '$type $task را پیوند داد';
  }

  @override
  String get grpRAuLinkRemoved => 'یک پیوند را حذف کرد';

  @override
  String get grpRAuFieldSet => 'یک فیلد سفارشی را تنظیم کرد';

  @override
  String get grpRAuDocLinked => 'یک صفحه را پیوند داد';

  @override
  String get grpRAuDocUnlinked => 'پیوند یک صفحه را برداشت';

  @override
  String get grpRAuEdited => 'این وظیفه را ویرایش کرد';

  @override
  String grpRAuChanged(String parts) {
    return '$parts را تغییر داد';
  }

  @override
  String grpRAuPart(String label, String from, String to) {
    return '$label $from ← $to';
  }

  @override
  String get grpRAuSomething => 'کاری انجام داد';

  @override
  String get grpRAuFStatus => 'وضعیت';

  @override
  String get grpRAuFSprint => 'اسپرینت';

  @override
  String get grpRAuFParent => 'وظیفه مادر';

  @override
  String get grpRAuFDueDate => 'موعد';

  @override
  String get grpRAuFDueTime => 'زمان موعد';

  @override
  String get grpRAuFStartDate => 'تاریخ شروع';

  @override
  String get grpRAuFEstimate => 'برآورد';

  @override
  String get devTitle => 'توسعه‌دهنده';

  @override
  String get devSub => 'توکن‌های API و وب‌هوک‌ها';

  @override
  String get devTokensTab => 'توکن‌های API';

  @override
  String get devWebhooksTab => 'وب‌هوک‌ها';

  @override
  String get devTokenNew => 'توکن جدید';

  @override
  String get devTokenName => 'نام';

  @override
  String get devTokenScopes => 'اجازه‌های توکن';

  @override
  String get devTokenExpiry => 'انقضا';

  @override
  String get devExpiryNever => 'هرگز';

  @override
  String get devExpiry30 => '۳۰ روز دیگر';

  @override
  String get devExpiry90 => '۹۰ روز دیگر';

  @override
  String get devExpiry365 => 'یک سال دیگر';

  @override
  String get devTokenCreate => 'ساخت توکن';

  @override
  String get devTokenCreatedTitle => 'توکن را همین حالا کپی کنید';

  @override
  String get devTokenCreatedBody =>
      'این تنها باری است که نمایش داده می‌شود. آن را جای امنی نگه دارید.';

  @override
  String get devCopy => 'کپی';

  @override
  String get devCopied => 'کپی شد';

  @override
  String get devDone => 'تمام';

  @override
  String devTokenPrefix(String prefix) {
    return 'با $prefix شروع می‌شود';
  }

  @override
  String get devTokenNeverUsed => 'هرگز استفاده نشده';

  @override
  String devTokenUsed(String when) {
    return 'آخرین استفاده $when';
  }

  @override
  String get devTokenActive => 'فعال';

  @override
  String get devTokenExpired => 'منقضی‌شده';

  @override
  String get devTokenRevoked => 'لغوشده';

  @override
  String get devTokenRevoke => 'لغو';

  @override
  String devTokenRevokeTitle(String name) {
    return '«$name» لغو شود؟';
  }

  @override
  String get devTokenRevokeBody =>
      'هر چیزی که از این توکن استفاده می‌کند بلافاصله از کار می‌افتد.';

  @override
  String get devTokensEmpty => 'هنوز توکنی نیست.';

  @override
  String get devTokensHint =>
      'یک توکن همان کارهایی را می‌کند که شما می‌توانید، محدود به اجازه‌هایی که انتخاب می‌کنید. فقط در همین فضای کار معتبر است.';

  @override
  String get devWebhookNew => 'وب‌هوک جدید';

  @override
  String get devWebhookEdit => 'ویرایش وب‌هوک';

  @override
  String get devWebhookName => 'نام (اختیاری)';

  @override
  String get devWebhookUrl => 'نشانی';

  @override
  String get devWebhookEvents => 'رویدادها';

  @override
  String get devWebhookSave => 'ذخیره';

  @override
  String get devWebhookActive => 'فعال';

  @override
  String get devWebhookSecret => 'رمز امضا';

  @override
  String get devWebhookTest => 'ارسال آزمایشی';

  @override
  String devWebhookTestDone(String status) {
    return 'آزمایش ارسال شد: $status';
  }

  @override
  String get devWebhookDeliveries => 'ارسال‌ها';

  @override
  String get devWebhookDelete => 'حذف';

  @override
  String devWebhookDeleteTitle(String name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get devWebhookDeleteBody => 'گزارش ارسال‌های آن هم حذف می‌شود.';

  @override
  String get devWebhooksEmpty => 'هنوز وب‌هوکی نیست.';

  @override
  String get devWebhooksDenied =>
      'فقط کسانی که می‌توانند وب‌هوک‌ها را مدیریت کنند این‌ها را می‌بینند.';

  @override
  String devWebhookOff(String reason) {
    return 'خاموش شد: $reason';
  }

  @override
  String get devWebhookHint =>
      'هر رویداد به‌صورت یک POST امضاشده ارسال می‌شود. گیرنده امضا را با رمز بررسی می‌کند.';

  @override
  String get devDeliveriesTitle => 'ارسال‌ها';

  @override
  String get devDeliveriesEmpty => 'هنوز چیزی ارسال نشده است.';

  @override
  String get devStatusDelivered => 'تحویل شد';

  @override
  String get devStatusPending => 'در انتظار';

  @override
  String get devStatusFailed => 'ناموفق، دوباره تلاش می‌شود';

  @override
  String get devStatusGaveUp => 'منصرف شد';

  @override
  String devAttempt(int n) {
    return 'تلاش $n';
  }

  @override
  String get devRequest => 'درخواست';

  @override
  String get devResponse => 'پاسخ';

  @override
  String get devHeaders => 'سرایندها';

  @override
  String get devBody => 'بدنه';

  @override
  String get devResend => 'ارسال دوباره';

  @override
  String devResent(String status) {
    return 'دوباره ارسال شد: $status';
  }

  @override
  String devNextTry(String when) {
    return 'تلاش بعدی $when';
  }

  @override
  String get devLoadMore => 'بارگذاری بیشتر';

  @override
  String get devRetry => 'تلاش دوباره';

  @override
  String get devDenied => 'شما اینجا اجازه این کار را ندارید.';

  @override
  String get devScopeWorkspacesRead => 'دیدن فضای کار';

  @override
  String get devScopeProjectsRead => 'خواندن پروژه‌ها';

  @override
  String get devScopeProjectsWrite => 'ساخت و تغییر پروژه‌ها';

  @override
  String get devScopeTasksRead => 'خواندن وظیفه‌ها';

  @override
  String get devScopeTasksWrite => 'ساخت، تغییر و حذف وظیفه‌ها';

  @override
  String get devScopeCommentsRead => 'خواندن دیدگاه‌ها';

  @override
  String get devScopeCommentsWrite => 'نوشتن دیدگاه';

  @override
  String get devEventTaskCreated => 'وظیفه‌ای ساخته شد';

  @override
  String get devEventTaskUpdated => 'وظیفه‌ای ویرایش شد';

  @override
  String get devEventTaskStatus => 'وضعیت وظیفه‌ای تغییر کرد';

  @override
  String get devEventTaskAssigned => 'کسانی به وظیفه‌ای واگذار شدند';

  @override
  String get devEventTaskDeleted => 'وظیفه‌ای حذف شد';

  @override
  String get devEventCommentCreated => 'دیدگاهی افزوده شد';

  @override
  String get devEventCommentUpdated => 'دیدگاهی ویرایش شد';

  @override
  String get devEventCommentDeleted => 'دیدگاهی حذف شد';

  @override
  String get devEventPing => 'رویداد آزمایشی';

  @override
  String get formsTitle => 'فرم‌ها';

  @override
  String get formsSub => 'فرم‌های عمومی که کار می‌سازند';

  @override
  String get formsHint =>
      'پیوند یک فرم را بدهید تا افراد بیرون از فضای کار بتوانند کار بفرستند. حساب لازم ندارند.';

  @override
  String get formsEmpty => 'هنوز فرمی نیست.';

  @override
  String get formsNew => 'فرم تازه';

  @override
  String get formsEdit => 'ویرایش فرم';

  @override
  String get formsPickProject => 'کارها به کدام پروژه برود؟';

  @override
  String formsSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ارسال',
    );
    return '$_temp0';
  }

  @override
  String get formsCopyLink => 'رونوشت پیوند';

  @override
  String get formsLinkCopied => 'پیوند رونویسی شد.';

  @override
  String get formsRotateLink => 'پیوند تازه (پیوند قبلی کار نمی‌کند)';

  @override
  String get formsLinkRotated =>
      'فرم پیوند تازه‌ای دارد. پیوند قبلی دیگر کار نمی‌کند.';

  @override
  String get formsSubmissions => 'ارسال‌ها';

  @override
  String get formsNoSubmissions => 'هنوز چیزی از این فرم ارسال نشده است.';

  @override
  String get formsTaskGone => 'کار حذف شده است';

  @override
  String get formsCopyReference => 'رونوشت شمارهٔ پیگیری';

  @override
  String get formsDelete => 'حذف فرم';

  @override
  String formsDeleteTitle(String name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get formsDeleteBody =>
      'پیوند آن از کار می‌افتد و فهرست ارسال‌ها پاک می‌شود. کارهای ساخته‌شده می‌مانند.';

  @override
  String get formsDenied => 'اجازهٔ مدیریت فرم‌ها را ندارید.';

  @override
  String get formsGone => 'این فرم دیگر وجود ندارد.';

  @override
  String get formsGonePage => 'این فرم در دسترس نیست.';

  @override
  String get formsConflict =>
      'فرم پس از باز کردن شما تغییر کرد. دوباره باز کنید و تلاش کنید.';

  @override
  String get formsTooMany => 'ارسال‌های بسیار زیاد. بعداً دوباره تلاش کنید.';

  @override
  String get formsUnavailable =>
      'این فرم اکنون ارسال نمی‌پذیرد. بعداً دوباره تلاش کنید.';

  @override
  String get formsCaptchaFailed =>
      'تأیید ناموفق بود. دوباره انجام دهید و ارسال کنید.';

  @override
  String get formsCaptchaRequired => 'تأیید را کامل کنید.';

  @override
  String get formsCaptchaWebOnly =>
      'این فرم به تأییدی نیاز دارد که فقط در مرورگر کار می‌کند. پیوند آن را آنجا باز کنید.';

  @override
  String get formsCaptchaPreview => 'یک تأیید اینجا نمایش داده می‌شود.';

  @override
  String get formsRequired => 'این مورد الزامی است.';

  @override
  String get formsRequiredTag => 'الزامی';

  @override
  String get formsEmailLabel => 'ایمیل شما (اختیاری)';

  @override
  String get formsEmailLabelRequired => 'ایمیل شما *';

  @override
  String get formsEmailHelp =>
      'فقط برای تأیید و اطلاع‌رسانی دربارهٔ همین درخواست استفاده می‌شود.';

  @override
  String get formsEmailInvalid => 'یک نشانی ایمیل معتبر وارد کنید.';

  @override
  String get formsSubmit => 'ارسال';

  @override
  String get formsSending => 'در حال ارسال…';

  @override
  String get formsThanksTitle => 'سپاسگزاریم، دریافت شد';

  @override
  String formsThanksBody(String reference) {
    return 'شمارهٔ پیگیری شما $reference است. هنگام تماس آن را ذکر کنید.';
  }

  @override
  String get formsAnother => 'ارسال دیگر';

  @override
  String formsAddFile(int max) {
    return 'افزودن فایل (تا $max)';
  }

  @override
  String get formsRemoveFile => 'حذف فایل';

  @override
  String get formsFileTooBig => 'یک فایل بسیار بزرگ است.';

  @override
  String get formsNoDate => 'بدون تاریخ';

  @override
  String get formsPickDate => 'انتخاب تاریخ';

  @override
  String get formsClearDate => 'پاک کردن تاریخ';

  @override
  String get formsMoneyHint => 'مبلغ و واحد پول، مانند 12.50 USD';

  @override
  String get formsBuildTab => 'ساخت';

  @override
  String get formsPreviewTab => 'پیش‌نمایش';

  @override
  String get formsNameLabel => 'نام فرم';

  @override
  String get formsDescriptionLabel => 'متن بالای فرم';

  @override
  String get formsNeedName => 'برای فرم نامی بگذارید.';

  @override
  String get formsSaved => 'فرم ذخیره شد.';

  @override
  String get formsQuestions => 'پرسش‌ها';

  @override
  String get formsDefaultTitle => 'خلاصه';

  @override
  String get formsDefaultDescription => 'جزئیات';

  @override
  String get formsDefaultFile => 'پیوست';

  @override
  String get formsAddDescription => 'افزودن جزئیات';

  @override
  String get formsAddFileQuestion => 'افزودن بارگذاری فایل';

  @override
  String get formsAddField => 'افزودن فیلد پروژه';

  @override
  String get formsPickField => 'کدام فیلد؟';

  @override
  String get formsNoFields =>
      'فیلد دیگری برای افزودن نیست. فیلدهای شخص هرگز در فرم عمومی ارائه نمی‌شوند.';

  @override
  String get formsRemoveQuestion => 'حذف پرسش';

  @override
  String get formsKindTitle => 'عنوان کار';

  @override
  String get formsKindDescription => 'توضیح کار';

  @override
  String get formsKindFile => 'بارگذاری فایل';

  @override
  String get formsKindField => 'فیلد پروژه';

  @override
  String get formsEditQuestion => 'ویرایش پرسش';

  @override
  String get formsQuestionLabel => 'برچسب';

  @override
  String get formsQuestionHelp => 'متن راهنما';

  @override
  String get formsQuestionRequired => 'الزامی';

  @override
  String get formsMaxFiles => 'بیشترین تعداد فایل';

  @override
  String get formsTarget => 'کار با چه چیزی آغاز می‌شود';

  @override
  String get formsStatusLabel => 'وضعیت';

  @override
  String get formsStatusDefault => 'وضعیت نخست پروژه';

  @override
  String get formsPriorityLabel => 'اولویت';

  @override
  String get formsPriorityNone => 'هیچ';

  @override
  String get formsPriorityLow => 'کم';

  @override
  String get formsPriorityMedium => 'متوسط';

  @override
  String get formsPriorityHigh => 'زیاد';

  @override
  String get formsPriorityUrgent => 'فوری';

  @override
  String get formsAssigneesLabel => 'واگذار به';

  @override
  String get formsEnabled => 'پذیرش ارسال';

  @override
  String get formsRequireEmail => 'درخواست نشانی ایمیل';

  @override
  String get formsSendConfirmation => 'ارسال ایمیل تأیید';

  @override
  String get formsNotifyStatus => 'ایمیل تغییر وضعیت';

  @override
  String get formsNotifyStatusHint =>
      'یک‌طرفه: فرستنده وضعیت تازه را می‌گیرد، نه پیوندی به فضای کار.';

  @override
  String get formsBranding => 'ظاهر';

  @override
  String get formsColorLabel => 'رنگ برند';

  @override
  String get formsLogoLabel => 'نشانی لوگو (https://…)';

  @override
  String get goalsTitle => 'اهداف';

  @override
  String get goalsEmpty =>
      'هنوز هدفی نیست. یکی بسازید تا آنچه مهم است را پیگیری کنید.';

  @override
  String get goalsNew => 'هدف جدید';

  @override
  String get goalsEdit => 'ویرایش هدف';

  @override
  String get goalsDelete => 'حذف هدف';

  @override
  String goalsDeleteTitle(String name) {
    return '«$name» حذف شود؟';
  }

  @override
  String get goalsDeleteBody =>
      'نتایج کلیدی و ثبت‌های پیشرفت آن حذف می‌شوند. اهداف زیرمجموعه یک سطح بالا می‌روند.';

  @override
  String get goalsSave => 'ذخیره';

  @override
  String get goalsName => 'نام';

  @override
  String get goalsDescription => 'توضیحات';

  @override
  String goalsPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String get goalsOwner => 'مسئول';

  @override
  String get goalsContributors => 'مشارکت‌کنندگان';

  @override
  String get goalsParent => 'هدف بالاتر';

  @override
  String get goalsNone => 'هیچ‌کدام';

  @override
  String get goalsFolder => 'پوشه';

  @override
  String get goalsNoFolder => 'بدون پوشه';

  @override
  String get goalsNewFolder => 'پوشه جدید';

  @override
  String get goalsFolderName => 'نام پوشه';

  @override
  String get goalsRenameFolder => 'تغییر نام پوشه';

  @override
  String get goalsDeleteFolder => 'حذف پوشه';

  @override
  String get goalsWeight => 'وزن';

  @override
  String get goalsPrivate => 'خصوصی';

  @override
  String get goalsPrivateHint =>
      'فقط مسئول، مشارکت‌کنندگان و مدیران آن را می‌بینند.';

  @override
  String get goalsStatusLabel => 'وضعیت';

  @override
  String get goalsStatusAuto => 'خودکار';

  @override
  String get goalsStatusOnTrack => 'طبق برنامه';

  @override
  String get goalsStatusAtRisk => 'در خطر';

  @override
  String get goalsStatusOffTrack => 'عقب‌تر از برنامه';

  @override
  String get goalsStatusAutoNote => 'از روی پیشرفت و زمان محاسبه می‌شود.';

  @override
  String goalsStatusSet(String status) {
    return 'دستی تنظیم شده. پیشنهاد: $status';
  }

  @override
  String goalsProgressPercent(int percent) {
    return '$percent٪';
  }

  @override
  String get goalsKeyResults => 'نتایج کلیدی';

  @override
  String get goalsNoKr => 'هنوز نتیجه کلیدی‌ای نیست.';

  @override
  String get goalsAddKr => 'افزودن نتیجه کلیدی';

  @override
  String get goalsEditKr => 'ویرایش نتیجه کلیدی';

  @override
  String get goalsDeleteKr => 'حذف نتیجه کلیدی';

  @override
  String get goalsKrName => 'نتیجه کلیدی';

  @override
  String get goalsKrType => 'نوع اندازه‌گیری';

  @override
  String get goalsKrNumber => 'عدد';

  @override
  String get goalsKrPercentage => 'درصد';

  @override
  String get goalsKrBoolean => 'انجام شد / نشد';

  @override
  String get goalsKrLinked => 'وظایف پیوندی';

  @override
  String get goalsKrStart => 'مقدار شروع';

  @override
  String get goalsKrTarget => 'مقدار هدف';

  @override
  String get goalsKrCurrent => 'مقدار فعلی';

  @override
  String get goalsKrDirectionHint =>
      'هدف کمتر از شروع هم ممکن است، مثلاً کاهش باگ‌ها از ۴۰ به ۱۰.';

  @override
  String get goalsKrFilter => 'فیلتر وظایف (اختیاری)';

  @override
  String get goalsKrFilterHint =>
      'یک فیلتر TFQL روی فضای کار، مثل label = launch. وظایفی که دستی اضافه می‌کنید هم شمرده می‌شوند.';

  @override
  String goalsKrPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه دستی اضافه شده',
      one: '۱ وظیفه دستی اضافه شده',
    );
    return '$_temp0';
  }

  @override
  String goalsKrNumberProgress(String current, String target) {
    return '$current از $target';
  }

  @override
  String goalsKrLinkedProgress(int done, int total) {
    return '$done از $total وظیفه انجام شده';
  }

  @override
  String get goalsKrDone => 'انجام شد';

  @override
  String get goalsKrNotDone => 'انجام نشده';

  @override
  String get goalsCheckIn => 'ثبت پیشرفت';

  @override
  String goalsCheckInTitle(String name) {
    return 'ثبت پیشرفت: $name';
  }

  @override
  String get goalsCheckInValue => 'مقدار جدید';

  @override
  String get goalsCheckInDone => 'انجام شد';

  @override
  String get goalsCheckInNote => 'یادداشت';

  @override
  String get goalsCheckInLinkedHint =>
      'وظایف پیوندی مقدار را تعیین می‌کنند. می‌توانید یادداشتی بگذارید.';

  @override
  String get goalsCheckInHistory => 'تاریخچه';

  @override
  String get goalsCheckInEmpty => 'هنوز ثبتی نیست.';

  @override
  String get goalsCheckInSystem => 'از وظایف شمرده شد';

  @override
  String goalsCheckInChange(String from, String to) {
    return '$from ← $to';
  }

  @override
  String get goalsContributes => 'مشارکت در';

  @override
  String get goalsAddToKr => 'شمردن در یک نتیجه کلیدی';

  @override
  String get goalsPickKr => 'کدام نتیجه کلیدی این وظیفه را بشمارد؟';

  @override
  String get goalsNoLinkedKr => 'نتیجه کلیدی پیوندی قابل ویرایشی ندارید.';

  @override
  String get goalsSubgoals => 'زیرهدف‌ها';

  @override
  String get goalsDenied => 'اجازه این کار را روی اهداف ندارید.';

  @override
  String get goalsGone => 'این هدف دیگر وجود ندارد.';

  @override
  String get goalsConflict =>
      'از زمان باز کردن تغییر کرده است. دوباره بارگیری کنید و تلاش کنید.';

  @override
  String get tplTitle => 'قالب‌ها';

  @override
  String get tplSearch => 'جستجوی قالب‌ها';

  @override
  String get tplAll => 'همه';

  @override
  String get tplKindProject => 'پروژه‌ها';

  @override
  String get tplKindTask => 'کارها';

  @override
  String get tplEmpty => 'قالبی پیدا نشد.';

  @override
  String get tplBuiltIn => 'داخلی';

  @override
  String get tplPrivate => 'فقط من';

  @override
  String get tplShared => 'همه اعضای فضای کاری';

  @override
  String tplTasksN(int count) {
    return '$count کار';
  }

  @override
  String tplAutomationsN(int count) {
    return '$count خودکارسازی';
  }

  @override
  String get tplStatuses => 'وضعیت‌ها';

  @override
  String get tplFields => 'فیلدهای سفارشی';

  @override
  String get tplFeatures => 'قابلیت‌ها';

  @override
  String get tplTasks => 'کارها';

  @override
  String get tplNoTasks => 'کار نمونه‌ای نیست.';

  @override
  String get tplApply => 'استفاده از قالب';

  @override
  String get tplEdit => 'ویرایش';

  @override
  String get tplDelete => 'حذف';

  @override
  String get tplDeleteAsk =>
      'این قالب حذف شود؟ پروژه‌هایی که از آن ساخته شده‌اند تغییری نمی‌کنند.';

  @override
  String tplApplyTitle(String name) {
    return 'استفاده از $name';
  }

  @override
  String get tplProjectName => 'نام پروژه';

  @override
  String get tplProjectKey => 'کلید';

  @override
  String get tplTargetProject => 'افزودن به پروژه';

  @override
  String get tplStartDate => 'تاریخ شروع';

  @override
  String get tplStartHelp => 'تاریخ‌های نسبی از این روز شمرده می‌شوند.';

  @override
  String get tplVariables => 'تکمیل کنید';

  @override
  String get tplRequired => 'الزامی است.';

  @override
  String get tplCreate => 'ایجاد';

  @override
  String tplApplied(int count) {
    return '$count کار ایجاد شد.';
  }

  @override
  String get tplWarnings => 'برخی بخش‌ها رد شدند';

  @override
  String get tplSaveTitle => 'ذخیره به‌عنوان قالب';

  @override
  String get tplName => 'نام';

  @override
  String get tplDescription => 'توضیحات';

  @override
  String get tplVisibility => 'چه کسی می‌تواند استفاده کند';

  @override
  String get tplInclude => 'شامل';

  @override
  String get tplPartWorkflow => 'وضعیت‌ها و گردش کار';

  @override
  String get tplPartFields => 'فیلدهای سفارشی';

  @override
  String get tplPartAutomations => 'خودکارسازی‌ها';

  @override
  String get tplPartFeatures => 'کلیدهای قابلیت';

  @override
  String get tplPartTasks => 'کارهای نمونه';

  @override
  String get tplAssignees => 'نگه داشتن مسئولان';

  @override
  String get tplSave => 'ذخیره';

  @override
  String get tplSaved => 'قالب ذخیره شد.';

  @override
  String get tplSaveTask => 'ذخیره کار به‌عنوان قالب';

  @override
  String get tplSaveProject => 'ذخیره پروژه به‌عنوان قالب';

  @override
  String get tplFromTemplate => 'از روی قالب…';

  @override
  String get tplCmdOpen => 'باز کردن قالب‌ها';

  @override
  String get tplDenied => 'اجازه این کار را روی قالب‌ها ندارید.';

  @override
  String get tplGone => 'این قالب دیگر وجود ندارد.';

  @override
  String get tplConflict =>
      'از زمان باز کردن تغییر کرده است. دوباره بارگذاری کنید و تلاش کنید.';

  @override
  String get wlTitle => 'حجم کار';

  @override
  String get wlSettings => 'ظرفیت، مرخصی و تعطیلات';

  @override
  String get wlPrevious => 'قبلی';

  @override
  String get wlNext => 'بعدی';

  @override
  String get wlToday => 'امروز';

  @override
  String get wlZoomDay => 'روز';

  @override
  String get wlZoomWeek => 'هفته';

  @override
  String get wlZoomMonth => 'ماه';

  @override
  String get wlProjects => 'پروژه‌ها';

  @override
  String get wlPeople => 'افراد';

  @override
  String get wlClearFilter => 'پاک کردن فیلتر';

  @override
  String get wlLegendUnder => 'کمتر از نیمی از ظرفیت';

  @override
  String get wlLegendOk => 'در حد ظرفیت';

  @override
  String get wlLegendOver => 'بیش از ظرفیت';

  @override
  String get wlLegendSevere => 'بسیار بیش از ظرفیت (بالای ۱۲۵٪)';

  @override
  String get wlOnlyYours => 'فقط حجم کار خودتان را می‌بینید.';

  @override
  String get wlSetCapacityHint =>
      'برای بعضی افراد هنوز ظرفیت تعیین نشده است. بار آنها بدون رنگ بیش‌ازحد نشان داده می‌شود.';

  @override
  String get wlSetCapacity => 'تعیین ظرفیت';

  @override
  String get wlNoCapacity => 'ظرفیت تعیین نشده';

  @override
  String get wlTruncated =>
      'وظایف بسیار زیاد است: جدول فقط بخشی از آنها را نشان می‌دهد.';

  @override
  String get wlNoPeople => 'فردی برای نمایش نیست.';

  @override
  String wlCapacitySummary(String hours, String days) {
    return '$hours ساعت در روز، $days روز در هفته';
  }

  @override
  String wlUnestimated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه بدون برآورد',
      one: '۱ وظیفه بدون برآورد',
    );
    return '$_temp0';
  }

  @override
  String wlUndated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وظیفه بدون تاریخ',
      one: '۱ وظیفه بدون تاریخ',
    );
    return '$_temp0';
  }

  @override
  String get wlReasonNoEstimate => 'بدون برآورد: در جدول شمرده نمی‌شود';

  @override
  String get wlReasonNoDates => 'بدون تاریخ: روی هیچ روزی قرار نمی‌گیرد';

  @override
  String wlCellTotal(String load, String capacity) {
    return 'بار $load ساعت از $capacity ساعت';
  }

  @override
  String get wlHoursUnit => 'ساعت';

  @override
  String get wlCellEmpty => 'چیزی برنامه‌ریزی نشده';

  @override
  String get wlHoursInvalid => 'ساعت در روز عددی از ۰ تا ۲۴ است.';

  @override
  String wlCapacityOf(String name) {
    return 'ظرفیت $name';
  }

  @override
  String get wlHoursPerDay => 'ساعت در روز';

  @override
  String get wlWorkingDays => 'روزهای کاری';

  @override
  String get wlTabCapacity => 'ظرفیت';

  @override
  String get wlTabTimeOff => 'مرخصی';

  @override
  String get wlTabHolidays => 'تعطیلات';

  @override
  String get wlAddTimeOff => 'افزودن مرخصی';

  @override
  String get wlNoTimeOff => 'مرخصی‌ای ثبت نشده است.';

  @override
  String get wlKindVacation => 'تعطیلات';

  @override
  String get wlKindSick => 'مرخصی استعلاجی';

  @override
  String get wlKindPersonal => 'شخصی';

  @override
  String get wlKindOther => 'دیگر';

  @override
  String get wlPerson => 'فرد';

  @override
  String get wlKind => 'نوع';

  @override
  String get wlNote => 'یادداشت';

  @override
  String get wlAddHoliday => 'افزودن تعطیلی';

  @override
  String get wlNoHolidays => 'هنوز تعطیلی‌ای نیست.';

  @override
  String get wlHolidayName => 'نام تعطیلی';

  @override
  String get wlDelete => 'حذف';

  @override
  String get wlDenied => 'اجازه این کار را در حجم کار ندارید.';

  @override
  String get wlGone => 'این مورد دیگر وجود ندارد.';

  @override
  String get wlConflict =>
      'از زمان باز کردن تغییر کرده است. بارگذاری مجدد کنید و دوباره تلاش کنید.';

  @override
  String get secTitle => 'امنیت';

  @override
  String get secSubtitle => 'تأیید دومرحله‌ای و دستگاه‌های مورد اعتماد';

  @override
  String get secTwoStep => 'تأیید دومرحله‌ای';

  @override
  String get secOn => 'روشن است. ورود کد برنامهٔ احراز هویت شما را می‌خواهد.';

  @override
  String get secOff =>
      'خاموش است. برای محافظت از حساب خود مرحلهٔ دوم اضافه کنید.';

  @override
  String get secEnable => 'روشن کردن';

  @override
  String get secTurnOn => 'روشن کردن';

  @override
  String get secDisable => 'خاموش کردن';

  @override
  String get secDisableTitle => 'خاموش کردن تأیید دومرحله‌ای';

  @override
  String get secDisabled => 'تأیید دومرحله‌ای خاموش شد.';

  @override
  String get secEnrollTitle => 'راه‌اندازی برنامهٔ احراز هویت';

  @override
  String get secScanQr =>
      'این کد را با برنامهٔ احراز هویت مانند Aegis، Authy یا Google Authenticator اسکن کنید.';

  @override
  String get secOrTypeKey => 'یا این کلید را وارد کنید:';

  @override
  String get secEnterCode => 'کد ۶ رقمی از برنامه';

  @override
  String get secCopied => 'کپی شد.';

  @override
  String get secRecoveryTitle => 'کدهای بازیابی';

  @override
  String get secRecoveryBody =>
      'این ده کد را در جای امنی نگه دارید. اگر گوشی خود را گم کنید هر کدام فقط یک بار کار می‌کند. دوباره نمایش داده نمی‌شوند.';

  @override
  String get secCodesCopied => 'کدهای بازیابی کپی شد.';

  @override
  String get secSavedThem => 'ذخیره کردم';

  @override
  String secCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کد باقی مانده',
      one: '۱ کد باقی مانده',
      zero: 'کدی باقی نمانده',
    );
    return '$_temp0';
  }

  @override
  String get secRegenerate => 'کدهای جدید';

  @override
  String get secRegenerateTitle => 'جایگزینی کدهای بازیابی';

  @override
  String get secCodeOrRecovery => 'کد برنامه یا کد بازیابی';

  @override
  String get secDevices => 'دستگاه‌های مورد اعتماد';

  @override
  String get secDevicesSub =>
      'این دستگاه‌ها تا پایان اعتبار، هنگام ورود کد نمی‌خواهند.';

  @override
  String get secNoDevices => 'هیچ دستگاهی به خاطر سپرده نشده است.';

  @override
  String get secForgetAll => 'فراموش کردن همه';

  @override
  String get secForget => 'فراموش کردن این دستگاه';

  @override
  String get secUnnamedDevice => 'دستگاه بی‌نام';

  @override
  String secDeviceUntil(String date) {
    return 'مورد اعتماد تا $date';
  }

  @override
  String get secBlocked =>
      'این فضای کار تأیید دومرحله‌ای را الزامی کرده است. برای ادامه آن را در پایین روشن کنید.';

  @override
  String secGraceUntil(String date) {
    return 'این فضای کار از $date تأیید دومرحله‌ای را الزامی می‌کند. پیش از آن روشنش کنید.';
  }

  @override
  String get secPolicyTitle => 'الزام فضای کار';

  @override
  String get secRequire => 'الزامی کردن تأیید دومرحله‌ای';

  @override
  String get secRequireSub =>
      'اعضایی که آن را روشن نکرده باشند پس از پایان مهلت مسدود می‌شوند.';

  @override
  String get secGraceDays => 'مهلت (روز)';

  @override
  String get secGraceInvalid => 'عددی بین ۰ تا ۹۰ وارد کنید.';

  @override
  String get secPolicySaved => 'الزام ذخیره شد.';

  @override
  String get secVerifyTitle => 'تأیید دومرحله‌ای';

  @override
  String get secEnterAppCode =>
      'کد ۶ رقمی برنامهٔ احراز هویت خود را وارد کنید.';

  @override
  String get secEnterRecovery =>
      'یکی از کدهای بازیابی خود را وارد کنید. هر کد یک بار کار می‌کند.';

  @override
  String get secAppCode => 'کد';

  @override
  String get secRecoveryCode => 'کد بازیابی';

  @override
  String get secRememberDevice => 'تا ۳۰ روز در این دستگاه دوباره نپرس';

  @override
  String get secVerify => 'تأیید';

  @override
  String get secUseRecovery => 'استفاده از کد بازیابی';

  @override
  String get secUseAppCode => 'استفاده از کد برنامه';

  @override
  String get secBackToSignIn => 'بازگشت به ورود';

  @override
  String get secWrongCode => 'این کد درست نیست. دوباره تلاش کنید.';

  @override
  String get secLocked =>
      'کدهای نادرست زیاد بود. کمی صبر کنید و دوباره تلاش کنید.';

  @override
  String get secTooManyTries => 'تلاش‌های نادرست زیاد بود. دوباره وارد شوید.';

  @override
  String get secSignInExpired =>
      'زمان این ورود تمام شد. دوباره از رمز عبور شروع کنید.';

  @override
  String get secConflict =>
      'در این میان تغییر کرده است. بارگذاری مجدد کنید و دوباره تلاش کنید.';

  @override
  String get secNotFound => 'پیدا نشد.';

  @override
  String get ssoTitle => 'ورود یکپارچه (SSO)';

  @override
  String get ssoTitleShort => 'ورود یکپارچه';

  @override
  String get ssoSub =>
      'اجازه دهید افراد با ارائه‌دهندهٔ هویت شما (OpenID Connect) وارد شوند.';

  @override
  String get ssoContinue => 'ادامه با SSO';

  @override
  String get ssoContinueShort => 'ادامه';

  @override
  String get ssoWorkspaceName => 'نام نشانی فضای کار';

  @override
  String get ssoWorkspaceHelp => 'نام کوتاه در نشانی فضای کار، مثلاً acme';

  @override
  String get ssoOpenFailed => 'مرورگر باز نشد.';

  @override
  String get ssoErrUnverified =>
      'ارائه‌دهندهٔ هویت نشانی ایمیل شما را تأیید نکرد، پس نمی‌توانید با آن وارد شوید.';

  @override
  String get ssoErrDomain =>
      'دامنهٔ ایمیل شما اجازهٔ ورود به این فضای کار را ندارد.';

  @override
  String get ssoErrNoAccount =>
      'حسابی برای شما اینجا وجود ندارد و ثبت‌نام با SSO خاموش است.';

  @override
  String get ssoErrRemoved =>
      'شما از این فضای کار حذف شده‌اید. دعوت‌نامه بخواهید.';

  @override
  String get ssoErrDisabled => 'این حساب غیرفعال است.';

  @override
  String get ssoErrGeneric => 'ورود یکپارچه کامل نشد. دوباره شروع کنید.';

  @override
  String get ssoRedirectHelp =>
      'این نشانی بازگشت را در ارائه‌دهندهٔ هویت خود ثبت کنید:';

  @override
  String get ssoEnabled => 'ورود یکپارچه روشن است';

  @override
  String get ssoName => 'نام نمایشی (اختیاری)';

  @override
  String get ssoIssuer => 'نشانی صادرکننده (Issuer)';

  @override
  String get ssoIssuerHelp =>
      'جایی که /.well-known/openid-configuration قرار دارد، مثلاً https://id.example.com/realms/acme';

  @override
  String get ssoClientId => 'شناسهٔ کلاینت';

  @override
  String get ssoClientSecret => 'رمز کلاینت';

  @override
  String get ssoSecretKept => 'یک رمز ذخیره شده است. برای حفظ آن خالی بگذارید.';

  @override
  String get ssoSecretNeeded =>
      'الزامی است. رمزگذاری‌شده ذخیره می‌شود و دیگر نمایش داده نمی‌شود.';

  @override
  String get ssoScopes => 'دامنه‌ها (Scopes)';

  @override
  String get ssoDomains => 'دامنه‌های ایمیل مجاز';

  @override
  String get ssoDomainsHelp =>
      'با ویرگول جدا کنید، مثلاً acme.com. خالی یعنی همه.';

  @override
  String get ssoAutoCreate => 'ساخت حساب در اولین ورود';

  @override
  String get ssoAutoCreateSub =>
      'افراد از دامنه‌های مجاز بدون دعوت‌نامه عضو می‌شوند.';

  @override
  String get ssoRoles => 'نقش‌ها';

  @override
  String get ssoGroupClaim => 'نام ادعای گروه (claim)';

  @override
  String get ssoDefaultRole =>
      'نقش افرادی که با هیچ گروهی نمی‌خوانند (پیش‌فرض: عضو).';

  @override
  String get ssoDefaultRoleAuto => 'عضو (پیش‌فرض)';

  @override
  String get ssoGroup => 'گروه';

  @override
  String get ssoAddMapping => 'نگاشت گروه به نقش';

  @override
  String get ssoEnforce => 'الزامی کردن ورود یکپارچه';

  @override
  String get ssoEnforceSub =>
      'ورود با رمز عبور را برای اعضا خاموش می‌کند. مالکان آن را به‌عنوان راه بازگشت نگه می‌دارند.';

  @override
  String get ssoSaved => 'ورود یکپارچه ذخیره شد.';

  @override
  String get ssoTest => 'آزمایش';

  @override
  String ssoTestOk(int keys) {
    return 'ارائه‌دهنده پاسخ داد ($keys کلید امضا یافت شد)';
  }

  @override
  String get ssoTestFailed => 'آزمایش ناموفق بود';

  @override
  String get ssoRemove => 'حذف';

  @override
  String get ssoRemoveTitle => 'ورود یکپارچه حذف شود؟';

  @override
  String get ssoRemoveBody =>
      'افرادی که از طریق آن وارد شده‌اند باید دوباره وارد شوند.';

  @override
  String get sysAboutTitle => 'درباره';

  @override
  String get sysClientVersion => 'نسخه برنامه';

  @override
  String get sysServerVersion => 'نسخه سرور';

  @override
  String get sysUnknown => 'نامشخص (سرور در دسترس نیست)';

  @override
  String sysUpdateAvailable(String version) {
    return 'نسخه جدیدتری ($version) موجود است. برنامه را به‌روز کنید.';
  }

  @override
  String get sysCheckAgain => 'بررسی دوباره';

  @override
  String get sysUpdateRequiredTitle => 'به‌روزرسانی لازم است';

  @override
  String sysUpdateRequiredBody(String current, String minimum) {
    return 'این برنامه ($current) برای این سرور بیش از حد قدیمی است؛ سرور به نسخه $minimum یا جدیدتر نیاز دارد. برای ادامه آخرین نسخه را نصب کنید.';
  }

  @override
  String get sysTitle => 'سیستم';

  @override
  String get sysSubtitle => 'نسخه و سلامت صف (مدیران)';

  @override
  String get sysDenied => 'فقط مدیران می‌توانند وضعیت سیستم را ببینند.';

  @override
  String get sysLoadFailed => 'وضعیت سیستم بارگذاری نشد.';

  @override
  String get sysMinClient => 'قدیمی‌ترین برنامهٔ پشتیبانی‌شده';

  @override
  String get sysRedis => 'Redis';

  @override
  String get sysBroker => 'صف وظایف (Celery)';

  @override
  String get sysWorkers => 'کارگرها';

  @override
  String get sysOk => 'سالم';

  @override
  String get sysUnavailable => 'در دسترس نیست';

  @override
  String get sysInMemory => 'در حافظه (اشکال‌زدایی)';

  @override
  String get sysNotConfigured => 'پیکربندی نشده';

  @override
  String get sysInline => 'وظایف درجا اجرا می‌شوند (اشکال‌زدایی)';

  @override
  String get sysNoWorkers => 'هیچ کارگری پاسخ نداد';

  @override
  String get sysBacklog => 'کارهای موعددار در انتظار';

  @override
  String get sysBacklogNone => 'چیزی در انتظار نیست.';

  @override
  String get dpopKeyChanged =>
      'کلید این دستگاه تغییر کرده است؛ لطفاً دوباره وارد شوید.';

  @override
  String get dpopSessionBound => 'وابسته به کلید این دستگاه';

  @override
  String get devSessionRename => 'تغییر نام';

  @override
  String get devSessionRenameTitle => 'تغییر نام این نشست';

  @override
  String get devSessionNameLabel => 'نام';

  @override
  String get devSessionNameInvalid => 'بین ۱ تا ۸۰ نویسه وارد کنید.';

  @override
  String get devSessionRenameFailed => 'نام نشست تغییر نکرد. دوباره تلاش کنید.';

  @override
  String get devSessionNew => 'جدید';

  @override
  String get devSessionKeyChanged => 'کلید تغییر کرد';

  @override
  String devSessionLastUsed(String when) {
    return 'آخرین استفاده $when';
  }

  @override
  String get devPrivacyTitle => 'اطلاعات دستگاه';

  @override
  String get devPrivacyBody =>
      'هنگام ورود، ثبت‌نام یا تازه‌سازی نشست، این برنامه مدل دستگاه، سیستم‌عامل و نسخهٔ آن، شمارهٔ ساخت برنامه، اندازهٔ صفحه، زبان و منطقهٔ زمانی را می‌فرستد تا نشست‌های شما نامی خوانا بگیرند. ممکن است سرور آن را نادیده بگیرد و می‌توانید نام هر نشست را تغییر دهید.';

  @override
  String get devAdminCollectTitle => 'جمع‌آوری اطلاعات دستگاه';

  @override
  String get devAdminCollectSubtitle =>
      'نام‌گذاری نشست‌ها و نشانه‌گذاری دستگاه‌های جدید بر پایهٔ آنچه برنامه گزارش می‌دهد. به‌طور پیش‌فرض خاموش است.';

  @override
  String get devAdminPepperMissing =>
      'ابتدا DJANGO_DEVICE_FINGERPRINT_PEPPER را روی سرور تنظیم کنید.';

  @override
  String get devAdminSaveFailed => 'تنظیم ذخیره نشد.';

  @override
  String get audTokenCreated => 'یک توکن API ساخت';

  @override
  String get audTokenRevoked => 'یک توکن API را باطل کرد';

  @override
  String get audWebhookCreated => 'یک وب‌هوک افزود';

  @override
  String get audWebhookUpdated => 'یک وب‌هوک را تغییر داد';

  @override
  String get audWebhookDeleted => 'یک وب‌هوک را حذف کرد';

  @override
  String get audWebhookDisabled => 'یک وب‌هوک پس از شکست‌های مکرر خاموش شد';

  @override
  String get audFormCreated => 'یک فرم دریافت ساخت';

  @override
  String get audFormUpdated => 'یک فرم دریافت را تغییر داد';

  @override
  String get audFormDeleted => 'یک فرم دریافت را حذف کرد';

  @override
  String get audFormSubmitted => 'یک فرم دریافت را ارسال کرد';

  @override
  String get audGoalCreated => 'یک هدف ساخت';

  @override
  String get audGoalUpdated => 'یک هدف را تغییر داد';

  @override
  String get audGoalDeleted => 'یک هدف را حذف کرد';

  @override
  String audGoalFolderCreated(String name) {
    return 'پوشه هدف $name را ساخت';
  }

  @override
  String audGoalFolderRenamed(String before, String after) {
    return 'پوشه هدف $before را به $after تغییر نام داد';
  }

  @override
  String audGoalFolderDeleted(String name) {
    return 'پوشه هدف $name را حذف کرد';
  }

  @override
  String audGoalKrCreated(String name) {
    return 'نتیجه کلیدی $name را افزود';
  }

  @override
  String audGoalKrUpdated(String name) {
    return 'نتیجه کلیدی $name را تغییر داد';
  }

  @override
  String audGoalKrDeleted(String name) {
    return 'نتیجه کلیدی $name را حذف کرد';
  }

  @override
  String audGoalCheckedIn(String value, String name) {
    return 'مقدار $value را برای $name ثبت کرد';
  }

  @override
  String get audTemplateCreated => 'یک الگو ساخت';

  @override
  String get audTemplateUpdated => 'یک الگو را تغییر داد';

  @override
  String get audTemplateDeleted => 'یک الگو را حذف کرد';

  @override
  String get audTemplateApplied => 'از یک الگو استفاده کرد';

  @override
  String get audWorkloadCapacity => 'ظرفیت تعیین کرد';

  @override
  String get audWorkloadTimeOffCreated => 'مرخصی افزود';

  @override
  String get audWorkloadTimeOffUpdated => 'مرخصی را تغییر داد';

  @override
  String get audWorkloadTimeOffDeleted => 'مرخصی را حذف کرد';

  @override
  String get audWorkloadHolidayCreated => 'یک تعطیلی افزود';

  @override
  String get audWorkloadHolidayUpdated => 'یک تعطیلی را تغییر داد';

  @override
  String get audWorkloadHolidayDeleted => 'یک تعطیلی را حذف کرد';

  @override
  String get audWorkloadEstimateSet => 'برآورد تعیین کرد';

  @override
  String get audSecuritySsoConfigured => 'ورود یکپارچه را تنظیم کرد';

  @override
  String get audSecuritySsoRemoved => 'ورود یکپارچه را حذف کرد';

  @override
  String get audSecuritySsoMemberJoined => 'از طریق ورود یکپارچه پیوست';

  @override
  String get audSecuritySsoRoleChanged => 'نقش‌شان توسط ورود یکپارچه تغییر کرد';

  @override
  String get audSecurityPolicyChanged => 'سیاست امنیتی را تغییر داد';

  @override
  String get devWebhookProject => 'پروژه';

  @override
  String get devWebhookWholeWorkspace => 'کل فضای کار';

  @override
  String updNoticeText(String version) {
    return 'نسخه $version در دسترس است.';
  }

  @override
  String get updNoticeGet => 'دریافت';

  @override
  String get updNoticeDismiss => 'بستن';

  @override
  String get grpMImpClickupApi => 'ClickUp (توکن API)';

  @override
  String get grpCImpCuTokenHint => 'توکن شخصی API در ClickUp';

  @override
  String get grpCImpCuTokenNote =>
      'فقط برای خواندن فهرست‌های شما استفاده می‌شود و ذخیره نمی‌شود.';

  @override
  String get grpCImpCuLoad => 'نمایش فهرست‌های من';

  @override
  String get grpCImpCuPick =>
      'فهرست‌هایی را که می‌خواهید وارد کنید انتخاب کنید';

  @override
  String get grpCImpCuFetch => 'دریافت فهرست‌های انتخاب‌شده';

  @override
  String get grpCImpCuFetching => 'در حال دریافت از ClickUp…';

  @override
  String get chatTitle => 'گفتگو';

  @override
  String get chatEmpty =>
      'هنوز پیامی نیست — تغییرها و گفتگوها اینجا نشان داده می‌شوند';

  @override
  String get chatHideChanges => 'پنهان کردن تغییرها';

  @override
  String get chatLoadEarlier => 'بارگذاری پیام‌های قبلی';

  @override
  String chatEvTitle(String from, String to) {
    return 'عنوان این وظیفه را از «$from» به «$to» تغییر داد';
  }

  @override
  String chatEvStatus(String from, String to) {
    return 'وضعیت را از $from به $to تغییر داد';
  }

  @override
  String chatEvPriority(String from, String to) {
    return 'اولویت را از $from به $to تغییر داد';
  }

  @override
  String chatEvStartDate(String from, String to) {
    return 'تاریخ شروع را از $from به $to تغییر داد';
  }

  @override
  String chatEvDueDate(String from, String to) {
    return 'تاریخ سررسید را از $from به $to تغییر داد';
  }

  @override
  String chatEvEstimate(String from, String to) {
    return 'برآورد را از $from به $to تغییر داد';
  }

  @override
  String chatEvSubtask(String title) {
    return 'زیروظیفه «$title» را اضافه کرد';
  }

  @override
  String get chatEvOther => 'یک فیلد را تغییر داد';

  @override
  String get chatActorAutomation => 'یک اتوماسیون';

  @override
  String get chatActorForm => 'یک فرم';

  @override
  String get chatActorImport => 'یک درون‌ریزی';

  @override
  String get chatActorSystem => 'سیستم';

  @override
  String chatTitleCount(int count) {
    return 'گفتگو ($count)';
  }

  @override
  String get chatSectionChannels => 'کانال‌ها';

  @override
  String get chatSectionGroups => 'گروه‌ها';

  @override
  String get chatSectionDms => 'پیام‌های مستقیم';

  @override
  String get chatSectionTaskChats => 'گفتگوهای وظیفه';

  @override
  String get chatSearchHint => 'جستجوی گفتگوها';

  @override
  String get chatNoSpaces => 'هنوز گفتگویی نیست. با «جدید» یکی را شروع کنید.';

  @override
  String get chatNoMatches => 'چیزی با جستجوی شما مطابقت ندارد';

  @override
  String get chatMuted => 'بی‌صدا';

  @override
  String get chatNew => 'جدید';

  @override
  String get chatNewChannel => 'کانال';

  @override
  String get chatNewGroup => 'گروه';

  @override
  String get chatNewMessage => 'پیام';

  @override
  String get chatNameLabel => 'نام';

  @override
  String get chatMembersLabel => 'اعضا';

  @override
  String get chatPickPerson => 'یک نفر را انتخاب کنید';

  @override
  String get chatCreate => 'ایجاد';

  @override
  String get chatNameRequired => 'یک نام وارد کنید';

  @override
  String get chatGroupNeedsMembers => 'دست‌کم یک نفر دیگر را انتخاب کنید';

  @override
  String get chatSayHi => 'سلام کنید';

  @override
  String get chatSelectSpace => 'برای شروع، یک گفتگو را انتخاب کنید';

  @override
  String get chatUnreadDivider => 'پیام‌های جدید';

  @override
  String get chatJumpLatest => 'رفتن به آخرین پیام';

  @override
  String get chatWriteMessage => 'پیامی بنویسید…';

  @override
  String get chatSend => 'ارسال';

  @override
  String get chatReply => 'پاسخ';

  @override
  String chatReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پاسخ',
      one: '۱ پاسخ',
    );
    return '$_temp0';
  }

  @override
  String get chatThread => 'رشته گفتگو';

  @override
  String get chatBack => 'بازگشت';

  @override
  String get chatEdit => 'ویرایش';

  @override
  String get chatDelete => 'حذف';

  @override
  String get chatRemoved => 'پیام حذف شد';

  @override
  String get chatEdited => 'ویرایش‌شده';

  @override
  String get chatMessageActions => 'کارهای پیام';

  @override
  String get chatSending => 'در حال ارسال…';

  @override
  String get chatNotSent => 'ارسال نشد';

  @override
  String get chatDiscard => 'دور انداختن';

  @override
  String get chatBroadcastTitle => 'همه را مطلع کنیم؟';

  @override
  String chatBroadcastBody(int count) {
    return 'این پیام به $count نفر اطلاع می‌دهد. با این حال ارسال شود؟';
  }

  @override
  String get chatBroadcastSend => 'به هر حال ارسال شود';

  @override
  String get chatSettings => 'تنظیمات گفتگو';

  @override
  String get chatUnmute => 'پایان بی‌صدایی';

  @override
  String get chatMute1h => 'بی‌صدا برای ۱ ساعت';

  @override
  String get chatMute8h => 'بی‌صدا برای ۸ ساعت';

  @override
  String get chatMuteWeek => 'بی‌صدا برای ۱ هفته';

  @override
  String get chatMuteForever => 'بی‌صدا تا زمانی که دوباره روشن کنم';

  @override
  String get chatMuteCompletely => 'بی‌صدای کامل، حتی @اشاره‌ها به من';

  @override
  String get chatNotifyAll => 'برای هر پیام به من اطلاع بده';

  @override
  String get chatLeave => 'ترک کردن';

  @override
  String get chatJoin => 'پیوستن';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      one: '۱ عضو',
    );
    return '$_temp0';
  }

  @override
  String get chatReadOnlyArchived =>
      'این فضا بایگانی شده است. می‌توانید بخوانید اما نمی‌توانید بنویسید.';

  @override
  String get chatReadOnlyFormer => 'این گفتگو فقط‌خواندنی است.';

  @override
  String get chatNotMember => 'برای نوشتن در این کانال به آن بپیوندید.';

  @override
  String get chatFormerMember => 'عضو سابق';

  @override
  String chatUnreadLabel(int count) {
    return '$count نخوانده';
  }

  @override
  String chatEntryMessage(String space) {
    return 'پیام گفتگو در $space';
  }
}
