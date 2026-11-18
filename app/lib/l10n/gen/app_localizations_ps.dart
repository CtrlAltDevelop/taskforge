// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pushto Pashto (`ps`).
class AppLocalizationsPs extends AppLocalizations {
  AppLocalizationsPs([String locale = 'ps']) : super(locale);

  @override
  String get appTitle => 'ټاسک فورج';

  @override
  String get retry => 'بیا هڅه وکړئ';

  @override
  String get cancel => 'لغوه';

  @override
  String get save => 'خوندي کړئ';

  @override
  String get close => 'بندول';

  @override
  String get signOut => 'وتل';

  @override
  String get inbox => 'راتلونکي';

  @override
  String get workspaceSettings => 'د کاري ځای تنظیمات';

  @override
  String get homeLoadWorkspacesFailed =>
      'ستاسو کاري ځایونه ونه لوستل شول. بیا هڅه وکړئ';

  @override
  String get homeLoadAccountFailed => 'ستاسو حساب ونه لوستل شو.';

  @override
  String get calendar => 'کلیز';

  @override
  String get calendarSubtitle => 'ستاسو په پروژو کې ټول وروستي مهالونه';

  @override
  String get notificationSettings => 'د خبرتیاوو تنظیمات';

  @override
  String get notificationSettingsSubtitle =>
      'څه تاسو ته خبرتیا درکوي، د چوپتیا ساعتونه او لنډیز';

  @override
  String get offlineAndStorage => 'له شبکې پرته او ذخیره';

  @override
  String get offlineAndStorageSubtitle => 'له شبکې پرته بدلونونه، ځايي کاپي';

  @override
  String get sessions => 'ناستې';

  @override
  String get sessionsSubtitle => 'هغه وسایل چې ستاسو حساب ته ننوتي دي';

  @override
  String get changePassword => 'پټنوم بدل کړئ';

  @override
  String get connectivity => 'اړیکه';

  @override
  String get languageAndRegion => 'ژبه او سیمه';

  @override
  String get languageAndRegionSubtitle => 'ژبه، کلیز، د اونۍ پیل او شمیرې';

  @override
  String get appearance => 'بڼه';

  @override
  String get appearanceSubtitle => 'بڼه، کثافت او توپیر';

  @override
  String get themeLabel => 'بڼه';

  @override
  String get themeSystem => 'د سیسټم پیروي';

  @override
  String get themeLight => 'روښانه';

  @override
  String get themeDark => 'تیاره';

  @override
  String get densityLabel => 'کثافت';

  @override
  String get densityComfortable => 'آرام';

  @override
  String get densityCompact => 'ټینګ';

  @override
  String get contrastLabel => 'لوړ توپیر';

  @override
  String get reduceMotionLabel => 'حرکت کمول';

  @override
  String get reduceMotionHelp => 'انیمیشنونه سمدستي محو کیږي';

  @override
  String get contrastHelp => 'د اسانه لوستلو لپاره پیاوړی متن او کرښې';

  @override
  String get appearancePreview => 'مخکتنه';

  @override
  String get appearancePreviewTask => 'د خپرونې یادښتونه ولیکئ';

  @override
  String get signIn => 'ننوتل';

  @override
  String get createAccount => 'حساب جوړ کړئ';

  @override
  String get forgotPassword => 'پټنوم مو هیر شوی؟';

  @override
  String get createAnAccount => 'یو حساب جوړ کړئ';

  @override
  String get alreadyHaveAccount => 'زه دمخه حساب لرم';

  @override
  String get resetPassword => 'پټنوم بیا تنظیم کړئ';

  @override
  String get sendCode => 'کوډ ولېږئ';

  @override
  String get backToSignIn => 'ننوتلو ته راستنېدل';

  @override
  String get setNewPassword => 'نوی پټنوم وټاکئ';

  @override
  String get updatePassword => 'پټنوم نوي کړئ';

  @override
  String get codeFromEmail => 'له بریښنالیک څخه کوډ';

  @override
  String get email => 'بریښنالیک';

  @override
  String get password => 'پټنوم';

  @override
  String get currentPassword => 'اوسنی پټنوم';

  @override
  String get newPassword => 'نوی پټنوم';

  @override
  String get showPassword => 'پټنوم وښایاست';

  @override
  String get hidePassword => 'پټنوم پټ کړئ';

  @override
  String get passwordChanged => 'پټنوم بدل شو. بیا ننوځئ.';

  @override
  String get passwordUpdated => 'پټنوم نوی شو. په هغه ننوځئ.';

  @override
  String get enterEmail => 'خپل بریښنالیک پته ولیکئ.';

  @override
  String get enterValidEmail => 'یوه سمه بریښنالیک پته ولیکئ.';

  @override
  String get enterPassword => 'یو پټنوم ولیکئ.';

  @override
  String passwordTooShort(int min) {
    return 'لږ تر لږه $min ټکي وکاروئ.';
  }

  @override
  String get enterResetCode => 'هغه کوډ ولیکئ چې بریښنالیک ته درغلی.';

  @override
  String get enterYourPassword => 'خپل پټنوم ولیکئ.';

  @override
  String get errWrongCredentials => 'بریښنالیک یا پټنوم ناسم دی.';

  @override
  String get errTooManyAttempts => 'ډیرې هڅې. څو دقیقې وروسته بیا هڅه وکړئ.';

  @override
  String get errAccountExists => 'په دې بریښنالیک دمخه یو حساب شته.';

  @override
  String get errServerProblem =>
      'په سرور کې ستونزه وه. لږ وروسته بیا هڅه وکړئ.';

  @override
  String get errNoConnection =>
      'سرور ته نه شو رسېدلی. خپله اړیکه وګورئ او بیا هڅه وکړئ.';

  @override
  String get errGeneric => 'یوه ستونزه رامنځته شوه. بیا هڅه وکړئ.';

  @override
  String get languageLabel => 'ژبه';

  @override
  String get calendarSystemLabel => 'کلیز';

  @override
  String get calendarGregorian => 'میلادي';

  @override
  String get calendarJalali => 'جلالي (لمریز هجري)';

  @override
  String get weekStartLabel => 'اونۍ پیلیږي له';

  @override
  String get weekStartDefault => 'د ژبې ډیفالټ';

  @override
  String get weekSaturday => 'شنبه';

  @override
  String get weekSunday => 'یکشنبه';

  @override
  String get weekMonday => 'دوشنبه';

  @override
  String get numeralsLabel => 'شمیرې';

  @override
  String get numeralsLatin => 'لوېدیځې (0123)';

  @override
  String get numeralsNative => 'پښتو (۰۱۲۳)';

  @override
  String get previewLabel => 'مخکتنه';

  @override
  String get prefsSaveFailed =>
      'یوازې پر دې وسیله خوندي شو. سرور ته نه شو رسېدلی.';

  @override
  String get workspaceDefaultLanguage => 'د نویو غړو ډیفالټ ژبه';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دندې',
      one: '۱ دنده',
      zero: 'هیڅ دنده نشته',
    );
    return '$_temp0';
  }

  @override
  String get jalaliMonth1 => 'وری';

  @override
  String get jalaliMonth2 => 'غويی';

  @override
  String get jalaliMonth3 => 'غبرګولی';

  @override
  String get jalaliMonth4 => 'چنګاښ';

  @override
  String get jalaliMonth5 => 'زمری';

  @override
  String get jalaliMonth6 => 'وږی';

  @override
  String get jalaliMonth7 => 'تله';

  @override
  String get jalaliMonth8 => 'لړم';

  @override
  String get jalaliMonth9 => 'ليندۍ';

  @override
  String get jalaliMonth10 => 'مرغومی';

  @override
  String get jalaliMonth11 => 'سلواغه';

  @override
  String get jalaliMonth12 => 'کب';

  @override
  String get pickDateOk => 'سمه ده';

  @override
  String get pickDateTitle => 'نیټه وټاکئ';

  @override
  String get previousMonth => 'تیره میاشت';

  @override
  String get nextMonth => 'راتلونکې میاشت';

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
  String get grpACancel => 'لغوه';

  @override
  String get grpASave => 'خوندي کړه';

  @override
  String get grpARetry => 'بیا هڅه وکړه';

  @override
  String get grpADone => 'ترسره شو';

  @override
  String get grpAClose => 'بندول';

  @override
  String get grpAEdit => 'سمول';

  @override
  String get grpADelete => 'ړنګول';

  @override
  String get grpANote => 'یادښت';

  @override
  String get grpATotal => 'ټولیز';

  @override
  String get grpATask => 'دنده';

  @override
  String get grpAMerge => 'یوځای کول';

  @override
  String get grpARemove => 'لیرې کول';

  @override
  String get grpAOfflineBack => 'شاته';

  @override
  String get grpAOfflineTitle => 'آفلاین او ذخیره';

  @override
  String get grpAOfflineChooseWorkspace => 'لومړی یو کاري ځای وټاکئ.';

  @override
  String get grpAOfflineNeedsAttention => 'ستاسو پام ته اړتیا لري';

  @override
  String get grpAOfflineNothingToDecide =>
      'هیڅ نشته. ټول آفلاین بدلونونه واستول شول.';

  @override
  String grpAOfflineWaiting(int count) {
    return 'د لیږلو په تمه ($count)';
  }

  @override
  String get grpASyncNow => 'همدا اوس همغږي کړه';

  @override
  String get grpAOfflineNothingWaiting => 'هیڅ شی په تمه نه دی.';

  @override
  String get grpAEntryATask => 'یوه دنده';

  @override
  String grpAEntryNewTask(String title) {
    return 'نوې دنده «$title»';
  }

  @override
  String grpAEntryEdit(String name, String fields) {
    return 'د $name سمون: $fields';
  }

  @override
  String grpAEntryDelete(String name) {
    return 'د $name ړنګول';
  }

  @override
  String grpAEntryComment(String name) {
    return 'په $name نظر';
  }

  @override
  String grpAEntryUpload(String file, String name) {
    return '«$file» د $name ته پورته کول';
  }

  @override
  String grpAOfflineClash(String field, String current, String mine) {
    return 'د هغوی ($field): $current\nستاسو: $mine';
  }

  @override
  String get grpAKeepMine => 'زما وساتل';

  @override
  String get grpATakeTheirs => 'د هغوی ومنل';

  @override
  String get grpATryAgain => 'بیا هڅه وکړئ';

  @override
  String get grpADiscard => 'ردول';

  @override
  String get grpAMergeTitle => 'ستاسو کوم بدلونونه وساتل شي؟';

  @override
  String get grpAStorage => 'ذخیره';

  @override
  String get grpAReading => 'لوستل کیږي…';

  @override
  String grpAStorageUsage(String size, int cap) {
    return 'پر دې وسیله کاپي $size MB نیولي، له اعظمي $cap MB څخه.';
  }

  @override
  String get grpAMostItMayHold => 'اعظمي اندازه';

  @override
  String grpAMegabytes(int mb) {
    return '$mb MB';
  }

  @override
  String get grpAClearCopy => 'پر دې وسیله کاپي پاکول';

  @override
  String get grpAStorageNote =>
      'هغه بدلونونه چې لا د لیږلو په تمه دي ساتل کیږي. کاپي بې کوډ کولو ذخیره کیږي: د خپل وسیلې د ډیسک کوډ کول وکاروئ.';

  @override
  String get grpAClearTitle => 'پر دې وسیله کاپي پاکه شي؟';

  @override
  String get grpAClearBody =>
      'هغه څه چې تاسو لوستلي کله چې آنلاین شئ بیا راوړل کیږي. د لیږلو په تمه بدلونونه نه لیرې کیږي.';

  @override
  String get grpAClear => 'پاکول';

  @override
  String get grpAKeepOfflineTitle => 'پروژې آفلاین ساتل';

  @override
  String get grpAKeepOfflineBody =>
      'ساتل شوې پروژه بشپړه کاپي کیږي، نو دندې، حالتونه او غړي یې پرته له اړیکې شتون لري. نورې پروژې هغه څه ښیي چې تاسو وروستی ځل لوستي.';

  @override
  String grpACopying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'کاپي کیږي… $count دندې',
      one: 'کاپي کیږي… 1 دنده',
    );
    return '$_temp0';
  }

  @override
  String get grpASprintsTitle => 'سپرنټونه';

  @override
  String grpASprintsTitleProject(String name) {
    return 'سپرنټونه · $name';
  }

  @override
  String get grpASprintsDisabled =>
      'سپرنټونه د دې پروژې لپاره بند دي. د پروژې په تنظیماتو کې یې فعال کړئ.';

  @override
  String get grpAProjectNotFound => 'پروژه ونه موندل شوه.';

  @override
  String grpAAddedAfterStart(int count) {
    return '$count د سپرنټ له پیل وروسته زیات شول (د حد بدلون په توګه ښودل کیږي).';
  }

  @override
  String grpASprintCompleted(String name) {
    return '$name بشپړ شو.';
  }

  @override
  String get grpAPlanning => 'پلان جوړونه';

  @override
  String get grpAReports => 'راپورونه';

  @override
  String get grpANewSprint => 'نوی سپرنټ';

  @override
  String get grpABacklog => 'بیکلاګ';

  @override
  String get grpABacklogEmpty => 'بیکلاګ تش دی.';

  @override
  String get grpAAddToSprint => 'سپرنټ ته اضافه کول';

  @override
  String get grpANoOpenSprint =>
      'هېڅ پرانیستی سپرنټ نشته. د پلان جوړولو لپاره یو جوړ کړئ.';

  @override
  String get grpADragHere => 'دندې دلته راکش کړئ، یا په بیکلاګ کې یو څو وټاکئ.';

  @override
  String grpADatesRange(String start, String end) {
    return '$start تر $end';
  }

  @override
  String grpADaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ورځې پاتې',
      one: '1 ورځ پاتې',
    );
    return '$_temp0';
  }

  @override
  String grpASprintGoalText(String goal) {
    return 'موخه: $goal';
  }

  @override
  String get grpAShowOnBoard => 'په بورډ کې ښودل';

  @override
  String get grpAEditSprint => 'سپرنټ سمول';

  @override
  String get grpAStartSprint => 'سپرنټ پیلول';

  @override
  String get grpACompleteSprint => 'سپرنټ بشپړول';

  @override
  String get grpANoSprintsYet => 'تر اوسه سپرنټ نشته.';

  @override
  String get grpASprintNameRequired => 'سپرنټ ته یو نوم ورکړئ.';

  @override
  String get grpASprintDatesFormat => 'نېټې د YYYY-MM-DD په بڼه لیکل کیږي.';

  @override
  String get grpASprintEndBeforeStart =>
      'سپرنټ نشي کولی له پیل مخکې پای ته ورسیږي.';

  @override
  String get grpASprintCapacityNumber =>
      'ظرفیت یو شمېر دی، یا د نه شتون لپاره تش پریږدئ.';

  @override
  String get grpASprintSaved => 'سپرنټ خوندي شو';

  @override
  String get grpASprintName => 'نوم';

  @override
  String get grpASprintGoal => 'موخه';

  @override
  String get grpASprintStartLabel => 'پیل (YYYY-MM-DD)';

  @override
  String get grpASprintEndLabel => 'پای (YYYY-MM-DD)';

  @override
  String get grpAPickStartDate => 'د پیل نېټه وټاکئ';

  @override
  String get grpAPickEndDate => 'د پای نېټه وټاکئ';

  @override
  String get grpACapacityPointsOptional => 'ظرفیت په نمرو (اختیاري)';

  @override
  String get grpACapacityHoursOptional => 'ظرفیت په ساعتونو (اختیاري)';

  @override
  String grpASprintOverlap(String names) {
    return 'دا نېټې له $names سره ټکر لري.';
  }

  @override
  String grpACompleteTitle(String name) {
    return '$name بشپړول';
  }

  @override
  String grpACompleteCounts(int done, int open) {
    return '$done ترسره شوې، $open نیمګړې';
  }

  @override
  String get grpACompleteWhatHappens => 'له نیمګړو دندو سره څه وشي؟';

  @override
  String get grpACompleteMoveNext => 'بل سپرنټ ته لیږدول';

  @override
  String get grpACompleteNoPlanned => 'د لیږدولو لپاره هېڅ پلان شوی سپرنټ نشته';

  @override
  String get grpACompleteBackToBacklog => 'بیکلاګ ته ستنول';

  @override
  String grpAPointsFor(String key) {
    return 'د $key نمرې';
  }

  @override
  String get grpAPointsInvalid =>
      'یو شمېر وکاروئ، یا د پاکولو لپاره تش پریږدئ.';

  @override
  String get grpAStoryPoints => 'د کیسې نمرې';

  @override
  String get grpACapacityInHours => 'ظرفیت په ساعتونو';

  @override
  String get grpACapacityInPoints => 'ظرفیت په نمرو';

  @override
  String grpABurndownTitle(String name) {
    return 'د کار کمیدو چارټ: $name';
  }

  @override
  String get grpAPoints => 'نمرې';

  @override
  String get grpATasks => 'دندې';

  @override
  String get grpABurndownEmpty =>
      'د کار کمیدو چارټ د سپرنټ له پیل وروسته پیلیږي.';

  @override
  String grpABurndownChart(int days, int changes) {
    return 'د کار کمیدو چارټ، $days ورځې، $changes د حد بدلونونه';
  }

  @override
  String grpABurndownBackfilled(int count) {
    return '، $count ورځې وروسته ډکې شوې';
  }

  @override
  String get grpALegendRemaining => 'پاتې';

  @override
  String get grpALegendIdeal => 'ایډیال';

  @override
  String get grpALegendScopeChange => 'د حد بدلون';

  @override
  String get grpALegendBackfilled => 'وروسته ډکه شوې ورځ';

  @override
  String get grpAVelocityEmpty => 'چټکتیا د لومړي بشپړ شوي سپرنټ وروسته ښکاري.';

  @override
  String grpAVelocityTitle(int count, String average) {
    return 'چټکتیا (وروستي $count سپرنټونه): منځنی $average نمرې';
  }

  @override
  String grpAVelocityChart(int count) {
    return 'د چټکتیا چارټ، $count سپرنټونه';
  }

  @override
  String get grpALegendCommitted => 'ژمنه شوی';

  @override
  String get grpALegendCompleted => 'بشپړ شوی';

  @override
  String get grpATimesheetTitle => 'د وخت پاڼه';

  @override
  String get grpAPreviousWeek => 'تیره اونۍ';

  @override
  String get grpANextWeek => 'راتلونکې اونۍ';

  @override
  String get grpAThisWeek => 'دا اونۍ';

  @override
  String get grpATimesheetEmpty => 'پدې اونۍ کې هېڅ وخت نه دی ثبت شوی.';

  @override
  String get grpARunning => 'روان';

  @override
  String get grpAAddTime => 'وخت زیاتول';

  @override
  String get grpAYou => 'تاسو';

  @override
  String get grpAProjectTotals => 'د پروژې ټولټال';

  @override
  String get grpAChooseProject => 'یوه پروژه وټاکئ';

  @override
  String get grpATotalsEmpty =>
      'پدې اونۍ کې په دې پروژه کې هېڅ وخت نه دی ثبت شوی.';

  @override
  String grpABillableAmount(String duration) {
    return '  ($duration د بلونې وړ)';
  }

  @override
  String get grpAEditTime => 'وخت سمول';

  @override
  String get grpATimeSpent => 'تیر شوی وخت';

  @override
  String get grpABillable => 'د بلونې وړ';

  @override
  String get grpABadDuration => 'داسې وخت ولیکئ لکه 1h 30m، 90m یا 1:30.';

  @override
  String get grpAEstimate => 'اټکل';

  @override
  String get grpAEstimatedTime => 'اټکل شوی وخت';

  @override
  String get grpAEmptyForNone => 'د نشتوالي لپاره تش پریږدئ';

  @override
  String get grpADeleteTimeTitle => 'دا وخت ړنګ شي؟';

  @override
  String get grpADeleteTimeBody => 'ثبت شوی وخت د تل لپاره لیرې کیږي.';

  @override
  String get grpAKeep => 'ساتل';

  @override
  String get grpBCancel => 'لغوه';

  @override
  String get grpBOk => 'سمه ده';

  @override
  String get grpBClose => 'بندول';

  @override
  String get grpBSave => 'خوندي کول';

  @override
  String get grpBRetry => 'بیا هڅه';

  @override
  String get grpBRestore => 'بیرته راوستل';

  @override
  String get grpBHistory => 'تاریخچه';

  @override
  String get grpBCopy => 'کاپي';

  @override
  String get grpBSaveAsFile => 'د فایل په توګه خوندي کړه';

  @override
  String get grpBReply => 'ځواب';

  @override
  String get grpBEdit => 'سمون';

  @override
  String get grpBDelete => 'ړنګول';

  @override
  String get grpBBack => 'شاته';

  @override
  String get grpBSomeone => 'یو څوک';

  @override
  String get grpBYou => 'تاسو';

  @override
  String get grpBLoading => 'بارېږي…';

  @override
  String get grpBPages => 'پاڼې';

  @override
  String get grpBRestricted => 'محدود';

  @override
  String get grpBLinkTitle => 'تړنه';

  @override
  String get grpBLinkAddressLabel => 'پته (http، https یا mailto)';

  @override
  String get grpBLinkInvalid => 'د http، https یا mailto پته وکاروئ.';

  @override
  String get grpBIconTitle => 'د پاڼې انځورک';

  @override
  String get grpBIconLabel => 'ایموجي یا لنډ متن (د هېڅ لپاره تش پرېږدئ)';

  @override
  String get grpBIconInvalid => 'تر څلورو توکو زیات مه کاروئ.';

  @override
  String get grpBImageTitle => 'انځور';

  @override
  String get grpBImageAddressLabel => 'د انځور پته (http یا https)';

  @override
  String get grpBDescription => 'تشریح';

  @override
  String get grpBImageInvalid => 'د http یا https پته وکاروئ.';

  @override
  String get grpBEmbedTaskTitle => 'یو کار ځای پر ځای کړئ';

  @override
  String get grpBTaskSearchLabel => 'کارونه ولټوئ یا د کار تړنه پیسټ کړئ';

  @override
  String get grpBUsePastedTask => 'پیسټ شوی کار وکاروئ';

  @override
  String get grpBSnippetRemoved => '(لرې شوی)';

  @override
  String get grpBConflictTitle => 'یو بل کس دا پاڼه بدله کړه';

  @override
  String get grpBConflictClean =>
      'د دوی بدلونونه ستاسو له بدلونونو سره نه ټکرېږي. یوځای به شي.';

  @override
  String get grpBConflictOverlap =>
      'تاسو دواړو دا بلاکونه بدل کړي. وټاکئ کوم وساتئ؛ پاتې ټول یوځای کېږي.';

  @override
  String grpBConflictBlock(String snippet) {
    return 'بلاک: $snippet';
  }

  @override
  String grpBConflictMine(String snippet) {
    return 'زما: $snippet';
  }

  @override
  String grpBConflictTheirs(String snippet) {
    return 'د دوی: $snippet';
  }

  @override
  String get grpBDecideLater => 'وروسته پرېکړه کوم';

  @override
  String get grpBDiscardMine => 'زما بدلونونه لرې کړه';

  @override
  String get grpBApplyAndSave => 'پلي کړه او خوندي کړه';

  @override
  String get grpBShareTitle => 'د پاڼې لاسرسی';

  @override
  String get grpBShareRestrict => 'دا پاڼه محدوده کړئ';

  @override
  String get grpBShareRestrictedHint =>
      'یوازې لاندې کسان، جوړونکی یې او د پاڼې مدیران (د هغې لاندې پاڼو لپاره هم).';

  @override
  String get grpBShareOpenHint =>
      'هر څوک چې مورنۍ پاڼه خلاصولی شي، دا هم خلاصولی شي.';

  @override
  String get grpBShareNeedPermission =>
      'د دې بدلولو لپاره تاسو ته د \"doc.manage\" اجازه پکار ده.';

  @override
  String get grpBEmptyPage => '(تشه پاڼه)';

  @override
  String grpBImageBlock(String alt) {
    return '[انځور $alt]';
  }

  @override
  String get grpBTaskCardBlock => '[د کار کارت]';

  @override
  String get grpBAllRevisions => 'ټول بیاکتنې';

  @override
  String get grpBNoRevisions => 'تر اوسه هیڅ بیاکتنه نشته.';

  @override
  String grpBVersionN(int version) {
    return 'نسخه $version';
  }

  @override
  String grpBVersionShort(int version) {
    return 'نسخه $version';
  }

  @override
  String get grpBRevisionsLoadFailed => 'تاریخچه نه شي بارېدلی. بیا هڅه وکړئ';

  @override
  String get grpBRevisionLoadFailed => 'دا بیاکتنه نه شي بارېدلی.';

  @override
  String get grpBRestoreVersion => 'دا نسخه بیرته راوړه';

  @override
  String grpBLinkedFrom(int count) {
    return 'تړل شوی له ($count)';
  }

  @override
  String get grpBNoBacklinks => 'هیڅ پاڼه دې ته اشاره نه کوي.';

  @override
  String grpBMarkdownTitle(String title) {
    return 'مارک‌ډاون: $title';
  }

  @override
  String get grpBMarkdownCopied => 'مارک‌ډاون کاپي شو.';

  @override
  String get grpBSaveSaved => 'خوندي شو';

  @override
  String get grpBSaveDirty => 'نه خوندي شوي بدلونونه';

  @override
  String get grpBSaveSaving => 'خوندي کېږي...';

  @override
  String get grpBSaveError => 'خوندي نه شو';

  @override
  String get grpBSaveConflict => 'ټکر: وټاکئ څه وساتئ';

  @override
  String get grpBDocsCrumb => 'اسناد';

  @override
  String get grpBDocNotFound => 'دا پاڼه نشته، یا تاسو یې نه شئ خلاصولی.';

  @override
  String get grpBBackToAllPages => 'ټولو پاڼو ته ستنېدل';

  @override
  String get grpBArchivedBanner =>
      'دا پاڼه آرشیف شوې ده. یوازې د لوستلو وړ ده.';

  @override
  String get grpBConflictBanner =>
      'یو بل کس دا پاڼه بدله کړه. ستاسو بدلونونه تر اوسه نه دي خوندي شوي.';

  @override
  String get grpBResolve => 'حل کړه';

  @override
  String get grpBRemoteBanner =>
      'یوې نوې نسخې یو بل کس خوندي کړې ده. کله چې خوندي کړئ یوځای به شي.';

  @override
  String grpBIsEditing(String name) {
    return '$name سمونه کوي';
  }

  @override
  String grpBAreEditing(String names) {
    return '$names سمونه کوي';
  }

  @override
  String get grpBChangeIcon => 'انځورک بدل کړئ';

  @override
  String get grpBUntitled => 'بې سرلیکه';

  @override
  String get grpBReadOnly => 'یوازې لوستل';

  @override
  String get grpBAccess => 'لاسرسی';

  @override
  String get grpBExportMarkdown => 'مارک‌ډاون صادرول';

  @override
  String grpBMoveUnder(String name) {
    return '\"$name\" لاندې ته ولېږدوئ';
  }

  @override
  String get grpBTopLevel => 'پورتنی کچه';

  @override
  String get grpBCollapse => 'راټولول';

  @override
  String get grpBExpand => 'غځول';

  @override
  String get grpBPageOptions => 'د پاڼې اختیارونه';

  @override
  String get grpBNewSubpage => 'نوې فرعي پاڼه';

  @override
  String get grpBMoveUp => 'پورته کول';

  @override
  String get grpBMoveDown => 'ښکته کول';

  @override
  String get grpBMoveTo => 'ولېږدوئ...';

  @override
  String get grpBArchive => 'آرشیف';

  @override
  String get grpBHideArchived => 'آرشیف شوي پټ کړئ';

  @override
  String get grpBShowArchived => 'آرشیف شوي ښکاره کړئ';

  @override
  String get grpBNewPage => 'نوې پاڼه';

  @override
  String get grpBNoPagesYet => 'تر اوسه هیڅ پاڼه نشته.';

  @override
  String get grpBPagesLoadFailed => 'پاڼې نه شي بارېدلی. بیا هڅه وکړئ';

  @override
  String get grpBToday => 'نن';

  @override
  String get grpBYesterday => 'پرون';

  @override
  String get grpBSubtaskCreated => 'فرعي کار جوړ شو.';

  @override
  String get grpBComments => 'نظرونه';

  @override
  String grpBCommentsCount(int count) {
    return 'نظرونه ($count)';
  }

  @override
  String get grpBNoComments => 'تر اوسه هیڅ نظر نشته.';

  @override
  String get grpBLoadEarlier => 'پخواني نظرونه راوړئ';

  @override
  String get grpBPinned => 'ملګری شوي';

  @override
  String get grpBReplyHint => 'ځواب…';

  @override
  String get grpBArchivedReadOnly =>
      'دا پروژه آرشیف شوې ده: نظرونه یوازې د لوستلو وړ دي.';

  @override
  String get grpBReadOnlyComments => 'تاسو نظرونه لوستلی شئ خو لیکلی یې نه شئ.';

  @override
  String get grpBCommentRemoved => 'نظر لرې شو';

  @override
  String get grpBUnpin => 'ملګری لرې کړه';

  @override
  String get grpBPin => 'ملګری کړه';

  @override
  String get grpBMakeSubtask => 'فرعي کار جوړ کړه';

  @override
  String get grpBEditHistory => 'د سمون تاریخچه';

  @override
  String grpBEditedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ځله سمون شو: د تاریخچې لیدو لپاره ټک وکړئ',
      one: 'یو ځل سمون شو: د تاریخچې لیدو لپاره ټک وکړئ',
    );
    return '$_temp0';
  }

  @override
  String get grpBEdited => 'سمون شوی';

  @override
  String get grpBCommentActions => 'د نظر کړنې';

  @override
  String get grpBWaitingToSend => 'د لېږلو په تمه';

  @override
  String get grpBSending => 'لیږل کېږي…';

  @override
  String get grpBNotSent => 'نه دی لیږل شوی';

  @override
  String get grpBDiscard => 'لرې کړه';

  @override
  String get grpBAddReaction => 'غبرګون اضافه کړئ';

  @override
  String get grpBAuditAll => 'ټول';

  @override
  String get grpBAuditTasks => 'کارونه';

  @override
  String get grpBAuditFiles => 'فایلونه';

  @override
  String get grpBAuditProjects => 'پروژې';

  @override
  String get grpBAuditMembers => 'غړي';

  @override
  String get grpBAuditRoles => 'رولونه';

  @override
  String get grpBAuditInvitations => 'بلنې';

  @override
  String get grpBAuditSignIn => 'ننوتل';

  @override
  String get grpBAuditTitle => 'د پلټنې ثبت';

  @override
  String get grpBExportCsv => 'د CSV په توګه صادرول';

  @override
  String get grpBAuditDenied => 'تاسو ته د پلټنې ثبت لوستلو اجازه نشته.';

  @override
  String get grpBAuditEmpty => 'د دې فلټرونو لپاره هیڅ نه دي ثبت شوي.';

  @override
  String get grpBShowOlder => 'زاړه ښکاره کړئ';

  @override
  String get grpBAnyone => 'هر څوک';

  @override
  String get grpBAnyProject => 'هره پروژه';

  @override
  String get grpBAnyTime => 'هر وخت';

  @override
  String get grpBClearFilters => 'فلټرونه پاک کړئ';

  @override
  String get grpBBulkChange => 'د یو ډله ییز بدلون برخه';

  @override
  String grpBCharacters(String size) {
    return '($size توري)';
  }

  @override
  String get grpBNoFieldChanges => 'د ساحو هیڅ بدلون نه دی ثبت شوی.';

  @override
  String get grpBAuditExportTitle => 'د پلټنې ثبت (CSV)';

  @override
  String grpBAuditExportNote(int shown, int total) {
    return 'د $total کربنو لومړي $shown ښودل کېږي. کاپي یا خوندي کول ټول لري.';
  }

  @override
  String get grpBCsvCopied => 'CSV کاپي شو.';

  @override
  String get grpCCancel => 'لغوه کول';

  @override
  String get grpCDelete => 'ړنګول';

  @override
  String get grpCRetry => 'بیا هڅه';

  @override
  String get grpCBack => 'شاته';

  @override
  String get grpCUndo => 'بیرته کول';

  @override
  String get grpCField => 'ساحه';

  @override
  String get grpCStatus => 'حالت';

  @override
  String get grpCComment => 'نظر';

  @override
  String get grpCValue => 'ارزښت';

  @override
  String get grpCDashNew => 'نوی ډشبورډ';

  @override
  String grpCDashDeleteTitle(String name) {
    return '«$name» ړنګ شي؟';
  }

  @override
  String get grpCDashDeleteBody =>
      'ویجټونه یې هم ورسره ځي. دا کار بیرته نه کېږي.';

  @override
  String get grpCDashTitle => 'ډشبورډونه';

  @override
  String grpCDashTitleProject(String project) {
    return 'ډشبورډونه · $project';
  }

  @override
  String get grpCDashEmpty => 'تر اوسه ډشبورډ نشته.';

  @override
  String get grpCDashBlankDashboard => 'تش ډشبورډ';

  @override
  String get grpCDashProjectOverview => 'د پروژې کتنه';

  @override
  String get grpCDashMyWork => 'زما کار';

  @override
  String get grpCDashBlank => 'تش';

  @override
  String get grpCDashEdit => 'سمول';

  @override
  String get grpCDashRefresh => 'تازه کول';

  @override
  String get grpCDashAddWidget => 'ویجټ زیاتول';

  @override
  String get grpCDashSave => 'ساتل';

  @override
  String get grpCDashDialogTitle => 'ډشبورډ';

  @override
  String get grpCDashName => 'نوم';

  @override
  String get grpCDashShareDenied => 'شریکول د dashboard.manage اجازه غواړي.';

  @override
  String get grpCDashOk => 'سمه ده';

  @override
  String get grpCImpTitle => 'واردول او صادرول';

  @override
  String get grpCImpExport => 'صادرول';

  @override
  String get grpCImpDenied => 'یوازې مدیران کولی شي معلومات وارد او صادر کړي.';

  @override
  String get grpCImpPast => 'پخواني واردونه';

  @override
  String get grpCImpNothing => 'تر اوسه هیڅ نه دي وارد شوي.';

  @override
  String grpCImpTasksCount(int count) {
    return '$count دندې';
  }

  @override
  String get grpCImpResume => 'بیا پیلول';

  @override
  String get grpCImpContinue => 'دوام ورکول';

  @override
  String get grpCImpForget => 'هېرول';

  @override
  String get grpCImpUndoTitle => 'دا واردول بیرته شي؟';

  @override
  String get grpCImpUndoBody =>
      'هغه څه چې جوړ کړي لرې کېږي. هغه څه چې تاسو په لاس زیات کړي ساتل کېږي.';

  @override
  String get grpCImpUndoConfirm => 'واردول بیرته کول';

  @override
  String grpCImpClaimTitle(String name) {
    return 'د $name دندې ورکړه...';
  }

  @override
  String get grpCImpChooseMember => 'یو غړی وټاکئ';

  @override
  String get grpCImpAssign => 'ګمارل';

  @override
  String grpCImpAssigned(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n دندې وګمارل شوې.',
      one: '$n دنده وګمارل شوه.',
    );
    return '$_temp0';
  }

  @override
  String get grpCImpWaiting => 'هغه خلک چې د یوځای کېدو په تمه دي';

  @override
  String get grpCImpWaitingBody =>
      'کله چې یو څوک د همدې بریښنالیک سره یوځای شي، دندې یې په اتوماتيک ډول ورکول کېږي.';

  @override
  String get grpCImpNoEmail => 'بریښنالیک نشته';

  @override
  String grpCImpPersonSub(String email, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دندې',
      one: '$count دنده',
    );
    return '$email · $_temp0';
  }

  @override
  String get grpCImpAssignTo => 'ګمارل...';

  @override
  String get grpCImpStepSource => 'سرچینه';

  @override
  String get grpCImpStepUpload => 'پورته کول';

  @override
  String get grpCImpStepMap => 'نقشه';

  @override
  String get grpCImpStepReview => 'کتنه';

  @override
  String get grpCImpStepImport => 'واردول';

  @override
  String get grpCImpWhere => 'ستاسو معلومات له کومې راځي؟';

  @override
  String get grpCImpAuto => 'ډاډه نه یم: له فایل څخه یې معلوم کړه';

  @override
  String get grpCImpNext => 'بل';

  @override
  String get grpCImpZipSeveral =>
      'دا زپ څو د معلوماتو فایلونه لري. کوم یو غواړئ وارد کړئ؟ (د کاري ځای صادرات د هرې پروژې لپاره یو فایل لري.)';

  @override
  String get grpCImpChooseAFile => 'یو فایل وټاکئ';

  @override
  String get grpCImpChooseGeneric =>
      'د واردولو فایل وټاکئ (‎.csv‎، ‎.json‎ یا د هغه ‎.zip‎).';

  @override
  String grpCImpChooseSource(String source) {
    return 'خپل د $source فایل وټاکئ (‎.csv‎، ‎.json‎ یا د هغه ‎.zip‎).';
  }

  @override
  String get grpCImpSentNote =>
      'فایل ستاسو د TaskForge سرور ته لېږل کېږي او د جریان په توګه لوستل کېږي، نو لوی فایلونه ستونزه نه لري. تر هغه چې تاسو تایید نه کړئ هیڅ نه بدلېږي.';

  @override
  String get grpCImpPickFile => 'فایل وټاکئ';

  @override
  String get grpCImpResumeThis => 'دا واردول بیا پیل کړئ';

  @override
  String get grpCImpWhatHappens => 'دا هغه څه دي چې به پېښ شي';

  @override
  String get grpCImpCountTasks => 'دندې';

  @override
  String get grpCImpCountSubtasks => 'له دې جملې فرعي دندې';

  @override
  String get grpCImpCountComments => 'نظرونه';

  @override
  String get grpCImpCountLinks => 'اړیکې';

  @override
  String get grpCImpCountSprints => 'سپرېنټونه';

  @override
  String get grpCImpCountLabels => 'نښې';

  @override
  String get grpCImpCountStatuses => 'نوې حالتونه';

  @override
  String get grpCImpCountPlaceholders => 'خلک چې انتظار ورته کېږي';

  @override
  String grpCImpAlready(int count) {
    return '$count له دې جملې مخکې وارد شوي او پرېښودل کېږي، تکرار نه کېږي.';
  }

  @override
  String grpCImpRowErrors(int count) {
    return '$count قطار(ونه) نه شي وارد کېدای او پرېښودل کېږي.';
  }

  @override
  String get grpCImpResumeImport => 'واردول بیا پیل کړئ';

  @override
  String get grpCImpStart => 'واردول پیل کړئ';

  @override
  String get grpCImpUndoRunBody =>
      'دا به هغه دندې، نظرونه، اړیکې، سپرېنټونه او حالتونه لرې کړي چې دې واردولو جوړ کړي. هر هغه څه چې تاسو په لاس ورسره زیات کړي ساتل کېږي.';

  @override
  String get grpCImpWaitingStart => 'د پیل په تمه...';

  @override
  String get grpCImpLinking => 'دندې تړل کېږي...';

  @override
  String grpCImpProgress(int done, int total) {
    return '$done له $total دندو';
  }

  @override
  String get grpCImpCancel => 'واردول لغوه کړئ';

  @override
  String get grpCImpFinished => 'واردول پای ته ورسېد';

  @override
  String get grpCImpUndone => 'واردول بیرته شو';

  @override
  String get grpCImpCancelled => 'واردول لغوه شو';

  @override
  String get grpCImpStopped => 'واردول ودرېد';

  @override
  String get grpCImpOpenProject => 'پروژه خلاص کړئ';

  @override
  String get grpCImpAnother => 'بل فایل وارد کړئ';

  @override
  String grpCImpRemoved(num tasks) {
    return '$tasks دندې لرې شوې.';
  }

  @override
  String grpCImpRemovedKept(num tasks, num kept) {
    return '$tasks دندې لرې شوې، $kept هغه ساتل شوې چې ستاسو خپلې فرعي دندې لري.';
  }

  @override
  String get grpCImpTheFile => 'فایل';

  @override
  String grpCImpSummary(int issues, int comments, int links, String file) {
    return 'په $file کې $issues دندې، $comments نظرونه او $links اړیکې وموندل شوې.';
  }

  @override
  String grpCImpSummarySub(
    int issues,
    int subtasks,
    int comments,
    int links,
    String file,
  ) {
    return 'په $file کې $issues دندې ($subtasks فرعي دندې)، $comments نظرونه او $links اړیکې وموندل شوې.';
  }

  @override
  String get grpCImpPriUrgent => 'بېړنی';

  @override
  String get grpCImpPriHigh => 'لوړ';

  @override
  String get grpCImpPriNormal => 'عادي';

  @override
  String get grpCImpPriLow => 'ټیټ';

  @override
  String get grpCImpPriNone => 'هیڅ';

  @override
  String get grpCImpFTitle => 'سرلیک *';

  @override
  String get grpCImpFDescription => 'تشریح';

  @override
  String get grpCImpFPriority => 'لومړیتوب';

  @override
  String get grpCImpFAssignee => 'ګمارل شوی';

  @override
  String get grpCImpFReporter => 'راپور ورکوونکی';

  @override
  String get grpCImpFCreated => 'جوړ شوی';

  @override
  String get grpCImpFUpdated => 'تازه شوی';

  @override
  String get grpCImpFStart => 'د پیل نېټه';

  @override
  String get grpCImpFDue => 'د پای نېټه';

  @override
  String get grpCImpFLabels => 'نښې';

  @override
  String get grpCImpFSprint => 'سپرېنټ';

  @override
  String get grpCImpFParent => 'مور (پېژند)';

  @override
  String get grpCImpFId => 'پېژند';

  @override
  String get grpCImpFKey => 'کلیدي';

  @override
  String get grpCImpFPoints => 'د کیسې ټکي';

  @override
  String get grpCImpFEstimate => 'اټکل';

  @override
  String get grpCImpFType => 'ډول';

  @override
  String get grpCImpPriorities => 'لومړیتوبونه';

  @override
  String grpCImpKeepLabels(int count) {
    return '$count نښې وساتئ';
  }

  @override
  String get grpCImpKeepLabelsSub => 'په هره دنده کې د «نښې» ساحې په توګه.';

  @override
  String grpCImpSprintsCreated(String sprints) {
    return 'هغه سپرېنټونه چې جوړېږي: $sprints';
  }

  @override
  String get grpCImpReview => 'کتنه';

  @override
  String get grpCImpReadAs => 'لوستل د';

  @override
  String get grpCImpZipFile => 'په زپ کې فایل';

  @override
  String get grpCImpChooseOne => 'یو وټاکئ';

  @override
  String get grpCImpInto => 'واردول ته';

  @override
  String get grpCImpNewProject => 'نوې پروژه';

  @override
  String get grpCImpExistingProject => 'موجوده پروژه';

  @override
  String get grpCImpProjectName => 'د پروژې نوم';

  @override
  String get grpCImpColumns => 'ستونونه';

  @override
  String get grpCImpNotInFile => '(په فایل کې نشته)';

  @override
  String get grpCImpStatuses => 'حالتونه';

  @override
  String get grpCImpSameName => 'ورته نوم (که نه وي جوړ شي)';

  @override
  String get grpCImpPeople => 'خلک';

  @override
  String get grpCImpNotMember => 'لا غړی نه دی (کله چې یوځای شي وګمارل شي)';

  @override
  String get grpCImpUnassigned => 'ناګمارل شوی پرېږده';

  @override
  String get grpCImpFirst200 =>
      'یوازې لومړي ۲۰۰ تنه لیست شوي؛ پاتې د ځایناستو په توګه تمه کوي.';

  @override
  String grpCAutoDeleteTitle(String name) {
    return '«$name» ړنګ شي؟';
  }

  @override
  String get grpCAutoDeleteBody =>
      'قاعده د تل لپاره درېږي. د چلېدو تاریخچه یې هم ړنګېږي.';

  @override
  String get grpCAutoTitle => 'اتومات کارونه';

  @override
  String grpCAutoTitleProject(String project) {
    return 'اتومات کارونه · $project';
  }

  @override
  String get grpCAutoMissing => 'پروژه ونه موندل شوه.';

  @override
  String get grpCAutoRules => 'قاعدې';

  @override
  String get grpCAutoRunHistory => 'د چلېدو تاریخچه';

  @override
  String get grpCAutoNew => 'نوی اتومات کار';

  @override
  String get grpCAutoReadOnly => 'یوازې لوستل';

  @override
  String grpCAutoLimit(int limit) {
    return 'د $limit قاعدو حد ته ورسېدئ.';
  }

  @override
  String grpCAutoRuleFilter(String name) {
    return 'قاعده: $name';
  }

  @override
  String get grpCAutoEmpty =>
      'تر اوسه اتومات کار نشته. یوه قاعده وايي: کله چې یو څه پېښ شي، او که سمون ولري، نو دا کارونه وکړه.';

  @override
  String grpCAutoWhen(String trigger, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملونه',
      one: '$count عمل',
    );
    return 'کله چې $trigger · $_temp0';
  }

  @override
  String get grpCAutoNeverRun => 'هیڅکله نه دی چلېدلی';

  @override
  String get grpCAutoHistory => 'تاریخچه';

  @override
  String get grpCAutoDryRun => 'آزموینی چلول';

  @override
  String get grpCAutoStatusChanges => 'یوه حالت بدلېږي';

  @override
  String grpCAutoMovesTo(String status) {
    return 'یوه دنده $status ته ځي';
  }

  @override
  String grpCAutoFieldChanges(String field) {
    return '$field بدلېږي';
  }

  @override
  String get grpCAutoSomeoneAssigned => 'یو څوک ګمارل کېږي';

  @override
  String grpCAutoUserAssigned(String user) {
    return '$user ګمارل کېږي';
  }

  @override
  String get grpCAutoDueReached => 'د پای نېټه راورسېږي';

  @override
  String grpCAutoDaysBefore(int days) {
    return 'د پای نېټې څخه $days ورځې مخکې';
  }

  @override
  String get grpCAutoDeletedStatus => 'ړنګه شوې حالت';

  @override
  String get grpCAutoUnknownPerson => 'نامعلوم کس';

  @override
  String get grpCAutoEvent => 'پېښه';

  @override
  String get grpCAutoMovesToLabel => 'ځي ته';

  @override
  String get grpCAutoAnyStatus => 'هر حالت';

  @override
  String get grpCAutoAssignedPerson => 'ګمارل شوی کس';

  @override
  String get grpCAutoAnyone => 'هر څوک';

  @override
  String grpCAutoDaysLabel(int max) {
    return 'د پای نېټې څخه مخکې ورځې (۰ تر $max)';
  }

  @override
  String grpCAutoTokensHelp(String tokens) {
    return 'تاسو کولی شئ $tokens وکاروئ';
  }

  @override
  String get grpCAutoDateHint => 'YYYY-MM-DD';

  @override
  String grpCAutoUseToken(String token) {
    return '$token وکاروئ';
  }

  @override
  String get grpCAutoHow => 'څنګه';

  @override
  String get grpCAutoReplaceAssignees => 'ګمارل شوي بدل کړه په';

  @override
  String get grpCAutoAdd => 'زیاتول';

  @override
  String get grpCAutoRemoveEveryone => 'ټول لرې کړه';

  @override
  String get grpCAutoSubtaskTitle => 'د فرعي دندې سرلیک';

  @override
  String get grpCAutoMessage => 'پیغام';

  @override
  String get grpCAutoAddress => 'پته';

  @override
  String get grpCAutoAddressHelp => 'یوازې عامې http(s) پتې؛ شخصي پتې رد کېږي.';

  @override
  String get grpCAutoMethod => 'طریقه';

  @override
  String get grpCAutoDoThis => 'دا وکړه';

  @override
  String grpDActionFailed(String error) {
    return 'دا کار ونه شو ($error).';
  }

  @override
  String get grpDSwitchWorkspace => 'د کارځای بدلول';

  @override
  String grpDWorkspaceHere(String name) {
    return '$name (دلته)';
  }

  @override
  String get grpDNewDoc => 'نوی سند';

  @override
  String get grpDTitle => 'سرلیک';

  @override
  String get grpDUntitled => 'بې سرلیکه';

  @override
  String get grpDNewDashboard => 'نوی ډشبورډ';

  @override
  String get grpDNewSprint => 'نوی سپرنټ';

  @override
  String grpDStatusOf(String id) {
    return 'د $id حالت';
  }

  @override
  String get grpDNewTask => 'نوې دنده';

  @override
  String get grpDCancel => 'لغوه';

  @override
  String get grpDCreate => 'جوړول';

  @override
  String get grpDSort => 'ترتیب';

  @override
  String get grpDNoSort => 'ترتیب نشته';

  @override
  String grpDSortBy(String names) {
    return 'ترتیب: $names';
  }

  @override
  String get grpDGroup => 'ډله';

  @override
  String get grpDNoGrouping => 'ډله‌بندي نشته';

  @override
  String grpDGroupBy(String name) {
    return 'ډله: $name';
  }

  @override
  String get grpDColumns => 'ستونونه';

  @override
  String get grpDRefresh => 'تازه کول';

  @override
  String get grpDLayoutNotSaved =>
      'ستاسو ترتیب خوندي نشو. په راتلونکي بدلون کې به بیا هڅه وشي.';

  @override
  String get grpDLayouts => 'ترتیبونه';

  @override
  String get grpDResetLayout => 'زما ترتیب بیرته تنظیمول';

  @override
  String get grpDShareLayoutMenu => 'دا ترتیب شریکول…';

  @override
  String grpDDeleteShared(String name) {
    return 'شریک شوی «$name» ړنګول';
  }

  @override
  String grpDDeleteSharedTitle(String name) {
    return '«$name» ړنګ شي؟';
  }

  @override
  String get grpDDeleteSharedBody => 'دا به د دې پروژې د ټولو لپاره ورک شي.';

  @override
  String get grpDDelete => 'ړنګول';

  @override
  String grpDDeletedNamed(String name) {
    return '«$name» ړنګ شو';
  }

  @override
  String grpDSharedNamed(String name) {
    return '«$name» شریک شو';
  }

  @override
  String get grpDShareLayoutTitle => 'دا ترتیب شریکول';

  @override
  String get grpDName => 'نوم';

  @override
  String get grpDShare => 'شریکول';

  @override
  String get grpDTaskNotFound => 'دنده ونه موندل شوه.';

  @override
  String get grpDDeleteTask => 'دنده ړنګول';

  @override
  String get grpDClose => 'تړل';

  @override
  String get grpDPriority => 'لومړیتوب';

  @override
  String get grpDStart => 'پیل';

  @override
  String get grpDDue => 'وروستۍ نیټه';

  @override
  String get grpDAssignees => 'مسؤلین';

  @override
  String get grpDDescription => 'تشریح';

  @override
  String grpDTaskDeleted(String id) {
    return '$id ړنګ شو';
  }

  @override
  String get grpDUndo => 'بیرته کول';

  @override
  String get grpDStatus => 'حالت';

  @override
  String grpDClearField(String label) {
    return '$label پاکول';
  }

  @override
  String get grpDDueTime => 'د پای وخت (ستاسو ساعت)';

  @override
  String get grpDClearDueTime => 'د پای وخت پاکول';

  @override
  String get grpDAllOf => 'دا ټول';

  @override
  String get grpDAnyOf => 'له دې څخه هر یو';

  @override
  String get grpDNot => 'نه';

  @override
  String get grpDRemoveGroup => 'ډله لرې کول';

  @override
  String get grpDCondition => 'شرط';

  @override
  String get grpDFieldRemoved => 'ساحه (لرې شوې)';

  @override
  String get grpDRemoveCondition => 'شرط لرې کول';

  @override
  String get grpDOpBefore => 'مخکې دی له';

  @override
  String get grpDOpOnOrBefore => 'په یا مخکې له';

  @override
  String get grpDOpAfter => 'وروسته دی له';

  @override
  String get grpDOpOnOrAfter => 'په یا وروسته له';

  @override
  String get grpDOpLessThan => 'له … کم دی';

  @override
  String get grpDOpAtMost => 'زیات تر زیاته';

  @override
  String get grpDOpMoreThan => 'له … ډیر دی';

  @override
  String get grpDOpAtLeast => 'لږ تر لږه';

  @override
  String get grpDYes => 'هو';

  @override
  String get grpDNo => 'نه';

  @override
  String get grpDCurrentSprint => 'اوسنی سپرنټ';

  @override
  String get grpDMe => 'زه';

  @override
  String get grpDChoose => 'وټاکئ…';

  @override
  String get grpDValue => 'ارزښت';

  @override
  String get grpDPickDate => 'نیټه وټاکئ';

  @override
  String get grpDOrderByLabel => 'ترتیب د مخې ';

  @override
  String get grpDAscending => 'پورته';

  @override
  String get grpDDescending => 'ښکته';

  @override
  String get grpDRemoveOrdering => 'ترتیب لرې کول';

  @override
  String get grpDOrderBy => 'ترتیب د مخې';

  @override
  String get grpDRepeatNothingToUpdate =>
      'نوې دندې به دا وکاروي. هېڅ پرانیستې دندې بدلون ته اړتیا نه درلوده.';

  @override
  String grpDRepeatUpdatedLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وروسته پرانیستې دندې تازه شوې.',
      one: '$count وروسته پرانیستې دنده تازه شوه.',
    );
    return '$_temp0';
  }

  @override
  String get grpDRepeat => 'تکرار';

  @override
  String grpDRepeatUnsupported(String summary) {
    return '«$summary» په داسې ډول تنظیم شوی چې دا مدیر یې نه شي ښودلی، نو دلته نه شي بدلېدلی. بیا هم کولی شئ یې ځنډوئ یا ودروئ.';
  }

  @override
  String get grpDSkipWeekends => 'د اونۍ پای تېرول';

  @override
  String get grpDStopRepeating => 'تکرار ودرول';

  @override
  String get grpDResume => 'دوام ورکول';

  @override
  String get grpDPause => 'ځنډول';

  @override
  String get grpDUseForFuture => 'دا دنده د راتلونکو لپاره کارول';

  @override
  String get grpDSave => 'خوندي کول';

  @override
  String get grpDEvery => 'هر';

  @override
  String get grpDRepeatByDay => 'د میاشتې په یوه ورځ';

  @override
  String get grpDRepeatByWeekday => 'د اونۍ په n‌مه ورځ';

  @override
  String grpDDayNumber(int day) {
    return 'ورځ $day';
  }

  @override
  String get grpDNth1 => 'لومړی';

  @override
  String get grpDNth2 => 'دوهم';

  @override
  String get grpDNth3 => 'درېیم';

  @override
  String get grpDNth4 => 'څلورم';

  @override
  String get grpDNthLast => 'وروستی';

  @override
  String get grpDEnds => 'پای';

  @override
  String get grpDEndNever => 'هېڅکله';

  @override
  String get grpDEndAfter => 'وروسته';

  @override
  String get grpDEndOn => 'په';

  @override
  String get grpDTasksWord => 'دندې';

  @override
  String get grpDMakeIt => 'جوړه یې کړه';

  @override
  String get grpDDaysAhead => 'ورځې د پای نیټې څخه مخکې';

  @override
  String grpDRepeatAt(String time) {
    return 'په $time';
  }

  @override
  String get grpDNoFurtherDates => 'نور نیټې نشته.';

  @override
  String grpDNextDates(String dates) {
    return 'راتلونکي: $dates';
  }

  @override
  String get grpEBack => 'شاته';

  @override
  String get grpECancel => 'لغوه';

  @override
  String get grpEName => 'نوم';

  @override
  String get grpERetry => 'بیا هڅه';

  @override
  String get grpEWorkspaceSettingsTitle => 'د کاري space تنظیمات';

  @override
  String get grpEWorkspacesLoadRetry =>
      'ستاسو کاري space نه شو پورته کېدی. بیا هڅه';

  @override
  String get grpEMembers => 'غړي';

  @override
  String get grpEMembersSub => 'خلک، بلنې او پرېښودل';

  @override
  String get grpERolesPerms => 'رولونه او اجازې';

  @override
  String get grpERolesPermsSub => 'څوک څه کولی شي';

  @override
  String get grpEAuditLog => 'د پلټنې لاګ';

  @override
  String get grpEAuditLogSub => 'چا څه او کله بدل کړل';

  @override
  String get grpEImportExport => 'واردول او صادرول';

  @override
  String get grpEImportExportSub =>
      'د Jira، ClickUp یا CSV معلومات راوړئ او وباسئ';

  @override
  String get grpEWorkspaceUpdated => 'کاري space تازه شو.';

  @override
  String get grpEGeneral => 'عمومي';

  @override
  String get grpEChangeLogo => 'لوګو بدل کړئ';

  @override
  String get grpEUrl => 'URL';

  @override
  String get grpERefresh => 'تازه کړئ';

  @override
  String get grpESaveChanges => 'بدلونونه خوندي کړئ';

  @override
  String get grpENotifSettings => 'د خبرتیاوو تنظیمات';

  @override
  String get grpEPushOffNotice =>
      'د دې وسیلې لپاره خبرتیاوې بندې دي. تاسو کولی شئ په سیسټم تنظیماتو کې یې اجازه ورکړئ؛ ستاسو انتخاب خوندي دی.';

  @override
  String get grpEZoneInvalid => 'داسې نوم وکاروئ لکه Europe/Paris یا UTC.';

  @override
  String get grpEQuietDifferent => 'د پیل او پای وختونه باید توپیر ولري.';

  @override
  String get grpEWhatReachesYou => 'څه درته رسېږي';

  @override
  String get grpEInbox => 'ان‌باکس';

  @override
  String get grpEPush => 'پُش';

  @override
  String get grpEEmail => 'ایمیل';

  @override
  String get grpEQuietHours => 'آرام ساعتونه';

  @override
  String get grpEQuietHold => 'د آرام ساعتونو په جریان کې پُش او ایمیل ودروئ';

  @override
  String get grpEQuietHoldSub => 'ان‌باکس تل ډکېږي؛ یوازې خبرتیاوې انتظار کوي.';

  @override
  String get grpEFrom => 'له';

  @override
  String get grpEUntil => 'تر';

  @override
  String get grpETimeZoneDigest => 'وخت سیمه او لنډیز';

  @override
  String get grpETimeZone => 'وخت سیمه';

  @override
  String get grpETimeZoneHelper => 'آرام ساعتونه او لنډیز د دې سیمې تابع دي.';

  @override
  String get grpEUseDeviceZone => 'د دې وسیلې وخت سیمه وکاروئ';

  @override
  String get grpETypeZone => 'پر ځای یې خپله وخت سیمه ولیکئ، لکه Europe/Paris.';

  @override
  String get grpEDigestAt => 'ورځنی لنډیز لیږل کېږي په';

  @override
  String get grpEEditField => 'ساحه سمه کړئ';

  @override
  String get grpENewField => 'نوې ساحه';

  @override
  String get grpEType => 'ډول';

  @override
  String get grpEOptions => 'اختیارونه';

  @override
  String get grpEColour => 'رنګ';

  @override
  String get grpELabel => 'لیبل';

  @override
  String get grpERemoveOption => 'اختیار لرې کړئ';

  @override
  String get grpEAddOption => 'اختیار زیات کړئ';

  @override
  String get grpERequired => 'اړین';

  @override
  String get grpERequiredSub => 'نوي دندې باید ارزښت ولري.';

  @override
  String get grpEDefaultValue => 'تلواله ارزښت';

  @override
  String get grpEShowIn => 'ښودل په';

  @override
  String get grpESave => 'خوندي کړئ';

  @override
  String get grpEAddField => 'ساحه زیاته کړئ';

  @override
  String get grpEOptionN => 'اختیار ۱';

  @override
  String get grpEProblemName => 'ساحې ته نوم ورکړئ.';

  @override
  String get grpEProblemOne => 'لږ تر لږه یو اختیار زیات کړئ.';

  @override
  String get grpEProblemLabel => 'هر اختیار لیبل ته اړتیا لري.';

  @override
  String get grpEProblemDup => 'دوه اختیارونه یو شان لیبل لري.';

  @override
  String get grpEOptionsInUse => 'اختیارونه کارول کېږي';

  @override
  String get grpERemovedOption => 'لرې شوی اختیار';

  @override
  String grpERemapLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ارزښتونه',
      one: '۱ ارزښت',
    );
    return '$label ($_temp0) بدلېږي';
  }

  @override
  String get grpENothingClear => 'هېڅ (پاک کړئ)';

  @override
  String get grpEApply => 'پلي کړئ';

  @override
  String get grpEPrivate => 'خصوصي';

  @override
  String get grpESprints => 'سپرنټونه';

  @override
  String get grpEAutomations => 'اتومات کارونه';

  @override
  String get grpESearch => 'لټون';

  @override
  String get grpETimesheet => 'د وخت جدول';

  @override
  String get grpEDashboards => 'ډشبورډونه';

  @override
  String get grpEDocs => 'اسناد';

  @override
  String get grpEProjects => 'پروژې';

  @override
  String get grpENewProject => 'نوې پروژه';

  @override
  String get grpEFavorites => 'خوښې';

  @override
  String get grpEProjectsLoadRetry => 'پروژې نه شوې پورته کېدی. بیا هڅه';

  @override
  String get grpEArchivedProjects => 'آرشیف شوې پروژې';

  @override
  String get grpEPrivateProjects => 'خصوصي پروژې';

  @override
  String get grpENoProjects => 'تر اوسه پروژه نشته';

  @override
  String get grpECreateFirstProject => 'خپله لومړۍ پروژه جوړه کړئ';

  @override
  String get grpEMonth1 => 'جنوري';

  @override
  String get grpEMonth2 => 'فبروري';

  @override
  String get grpEMonth3 => 'مارچ';

  @override
  String get grpEMonth4 => 'اپریل';

  @override
  String get grpEMonth5 => 'می';

  @override
  String get grpEMonth6 => 'جون';

  @override
  String get grpEMonth7 => 'جولای';

  @override
  String get grpEMonth8 => 'اګست';

  @override
  String get grpEMonth9 => 'سپتمبر';

  @override
  String get grpEMonth10 => 'اکتوبر';

  @override
  String get grpEMonth11 => 'نومبر';

  @override
  String get grpEMonth12 => 'دسمبر';

  @override
  String get grpEWeekLocale => 'د ژبې تلواله';

  @override
  String get grpEMonday => 'دوشنبه';

  @override
  String get grpESaturday => 'شنبه';

  @override
  String get grpESunday => 'یکشنبه';

  @override
  String get grpEPrevious => 'تېر';

  @override
  String get grpENext => 'راتلونکی';

  @override
  String get grpEToday => 'نن';

  @override
  String get grpEUnscheduled => 'نه مهالویش شوی';

  @override
  String get grpEMonth => 'میاشت';

  @override
  String get grpEWeek => 'اونۍ';

  @override
  String get grpEDay => 'ورځ';

  @override
  String get grpEColourBy => 'رنګ په اساس';

  @override
  String get grpEColourByProject => 'د پروژې په اساس رنګ';

  @override
  String get grpEColourByStatus => 'د حالت په اساس رنګ';

  @override
  String get grpEColourByPriority => 'د لومړیتوب په اساس رنګ';

  @override
  String get grpEColourChip => 'رنګ';

  @override
  String get grpEWeekStartsOn => 'اونۍ پیلېږي له';

  @override
  String get grpEHideDone => 'بشپړ شوي پټ کړئ';

  @override
  String get grpELayoutNotSaved =>
      'ستاسو د کلیزې ترتیب خوندي نه شو. په راتلونکي بدلون کې به بیا هڅه وشي.';

  @override
  String get grpEEnterName => 'یو نوم ولیکئ.';

  @override
  String get grpENewRole => 'نوی رول';

  @override
  String get grpECreate => 'جوړ کړئ';

  @override
  String get grpERenameRole => 'د رول نوم بدل کړئ';

  @override
  String get grpERename => 'نوم بدل کړئ';

  @override
  String grpEDeleteRoleTitle(String name) {
    return '\"$name\" ړنګ شي؟';
  }

  @override
  String get grpERoleNoOne => 'هیڅوک دا رول نه لري.';

  @override
  String grpERoleMoveMembers(int count) {
    return '$count غړي دا رول لري. دوی ولېږدوئ ته:';
  }

  @override
  String get grpEChooseRole => 'یو رول وټاکئ';

  @override
  String get grpEDelete => 'ړنګ کړئ';

  @override
  String grpFBulkDeleted(int count) {
    return '$count دندې ړنګې شوې';
  }

  @override
  String grpFBulkUpdated(int count) {
    return '$count دندې تازه شوې';
  }

  @override
  String grpFBulkPartialDeleted(int done, int total, int failed) {
    return '$done له $total دندو ړنګې شوې؛ $failed ونه شوای شوې.';
  }

  @override
  String grpFBulkPartialUpdated(int done, int total, int failed) {
    return '$done له $total دندو تازه شوې؛ $failed ونه شوای شوې.';
  }

  @override
  String get grpFDetails => 'جزئیات';

  @override
  String grpFBulkDeleteTitle(int count) {
    return '$count دندې ړنګې شي؟';
  }

  @override
  String get grpFBulkDeleteBody =>
      'فرعي دندې یې ورسره ځي. تاسو کولی شئ دوی له ډبې بیرته راوګرځوئ.';

  @override
  String get grpFDelete => 'ړنګول';

  @override
  String get grpFSetStatus => 'حالت ټاکل';

  @override
  String get grpFSetPriority => 'لومړیتوب ټاکل';

  @override
  String get grpFStatus => 'حالت';

  @override
  String get grpFPriority => 'لومړیتوب';

  @override
  String get grpFAssign => 'ټاکل';

  @override
  String get grpFClear => 'پاکول';

  @override
  String grpFBulkUpdating(int done, int total) {
    return 'د $total له $done تازه کول…';
  }

  @override
  String grpFBulkSelected(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String grpFBulkNotChanged(int count) {
    return '$count دندې بدلې نشوې';
  }

  @override
  String get grpFTask => 'دنده';

  @override
  String get grpFLinks => 'لینکونه';

  @override
  String get grpFAddLink => 'لینک زیاتول';

  @override
  String get grpFNoLinks => 'تر اوسه لینک نشته.';

  @override
  String get grpFRemoveLink => 'لینک لرې کړئ';

  @override
  String get grpFLinkSearchHint => 'په هر پروژه کې دندې ولټوئ';

  @override
  String get grpFCloseDuplicate => 'تکراري وتړئ';

  @override
  String get grpFLinkAction => 'لینک کول';

  @override
  String get grpFUnassigned => 'نه ټاکل شوی';

  @override
  String get grpFNoValue => 'ارزښت نشته';

  @override
  String get grpFAssignee => 'ټاکل شوی';

  @override
  String grpFPresenceEditing(String name) {
    return '$name سمبالوي';
  }

  @override
  String grpFPresenceViewing(String name) {
    return '$name ګوري';
  }

  @override
  String grpFEditingOne(String name) {
    return '$name دا سمبالوي';
  }

  @override
  String grpFEditingMany(int count) {
    return '$count کسان دا سمبالوي';
  }

  @override
  String grpFDeleteTaskTitle(String id) {
    return '$id ړنګ شي؟';
  }

  @override
  String grpFDeleteSubtasksExplain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرعي دندې لري. څه به ورسره کيږي؟',
      one: '۱ فرعي دنده لري. څه به ورسره کيږي؟',
    );
    return '$_temp0';
  }

  @override
  String get grpFKeepSubtasks => 'وساتل شي (یو کچه پورته)';

  @override
  String get grpFDeleteThemToo => 'دوی هم ړنګ کړئ';

  @override
  String grpFOpenSubtasksTitle(String id) {
    return '$id پرانیستې فرعي دندې لري';
  }

  @override
  String grpFOpenSubtasksExplain(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرعي دندې نه دي بشپړې شوې. دا هم $status ته یوسو؟',
      one: '۱ فرعي دنده نه ده بشپړه شوې. دا هم $status ته یوسو؟',
    );
    return '$_temp0';
  }

  @override
  String get grpFLeaveOpen => 'پرانیستې پرېږدئ';

  @override
  String get grpFCompleteAll => 'ټول بشپړ کړئ';

  @override
  String grpFMoveUnderTitle(String id) {
    return '$id لاندې ته ولېږدوئ…';
  }

  @override
  String get grpFTopLevel => 'لوړه کچه (پلار نشته)';

  @override
  String get grpFNoOtherParent => 'بله دنده نشته چې لاندې یې کېږدو.';

  @override
  String get grpFSubtasks => 'فرعي دندې';

  @override
  String get grpFAddSubtaskHint => 'یوه فرعي دنده زیاته کړئ او Enter ټک کړئ';

  @override
  String get grpFActionAddSubtask => 'فرعي دنده زیاتول';

  @override
  String get grpFActionMoveUnder => 'لاندې ته لېږدول…';

  @override
  String get grpFActionMakeTopLevel => 'لوړې کچې ته اړول';

  @override
  String get grpFBlockedByPending => 'د هغو دندو له خوا بند چې لا نه دي بشپړې';

  @override
  String grpFBlockedBy(String names) {
    return 'د $names له خوا بند';
  }

  @override
  String get grpFBlocked => 'بند';

  @override
  String get grpFBlockedTitle => 'دا دنده بنده ده';

  @override
  String grpFBlockedTextOne(String blockers) {
    return 'د $blockers له خوا بنده ده، چې لا نه ده بشپړه شوې.';
  }

  @override
  String grpFBlockedTextMany(String blockers) {
    return 'د $blockers له خوا بنده ده، چې لا نه دي بشپړې شوې.';
  }

  @override
  String get grpFOk => 'سمه ده';

  @override
  String get grpFCompleteAnyway => 'بیا هم بشپړول';

  @override
  String grpFConflictTitle(String field) {
    return 'یو چا $field بدل کړ';
  }

  @override
  String get grpFTheirs => 'د هغوی';

  @override
  String get grpFYours => 'ستاسو';

  @override
  String get grpFEmpty => '(تش)';

  @override
  String get grpFTakeTheirs => 'د هغوی واخلئ';

  @override
  String get grpFKeepMine => 'زما وساتئ';

  @override
  String get grpFFieldTitle => 'سرلیک';

  @override
  String get grpFFieldDescription => 'تشریح';

  @override
  String get grpFFieldStatus => 'حالت';

  @override
  String get grpFFieldPriority => 'لومړیتوب';

  @override
  String get grpFFieldStartDate => 'د پیل نیټه';

  @override
  String get grpFFieldDueDate => 'د پای نیټه';

  @override
  String get grpFFieldAssignees => 'ټاکل شوي کسان';

  @override
  String get grpFFields => 'ساحې';

  @override
  String get grpFRequiredFieldsIntro =>
      'دا ساحې د دندې له جوړولو مخکې ارزښت ته اړتیا لري.';

  @override
  String get grpFRequired => 'اړین';

  @override
  String get grpFCreate => 'جوړول';

  @override
  String get grpFChangeStatus => 'حالت بدلول';

  @override
  String get grpFChangePriority => 'لومړیتوب بدلول';

  @override
  String get grpFDate => 'نیټه';

  @override
  String get grpFPickDay => 'ورځ وټاکئ…';

  @override
  String get grpFAssignees => 'ټاکل شوي کسان';

  @override
  String get grpFViewList => 'لیست';

  @override
  String get grpFViewBoard => 'تخته';

  @override
  String get grpFViewTimeline => 'مهالویش';

  @override
  String grpFErrorRetry(String message) {
    return '$message بیا هڅه وکړئ';
  }

  @override
  String get grpFNoTasksYet => 'تر اوسه دنده نشته. لومړۍ پورته زیاته کړئ.';

  @override
  String get grpFSwipeComplete => 'بشپړول';

  @override
  String get grpFUndo => 'بیرته کول';

  @override
  String get grpFMore => 'نور';

  @override
  String grpFAddSubtaskTo(String id) {
    return '$id ته فرعي دنده زیاتول';
  }

  @override
  String grpFTaskDeleted(String id) {
    return '$id ړنګ شو';
  }

  @override
  String get grpFColTitle => 'سرلیک';

  @override
  String get tblSelectAll => 'ټول کارونه وټاکئ';

  @override
  String grpFTrashTitle(String name) {
    return '$name · ډبه';
  }

  @override
  String get grpFTrashEmpty => 'ډبه تشه ده.';

  @override
  String grpFTrashedRow(String id) {
    return '$id · ړنګ شوې';
  }

  @override
  String get grpFRestore => 'بیرته راوستل';

  @override
  String grpFTaskRestored(String id) {
    return '$id بیرته راوړل شو';
  }

  @override
  String get grpFMoveTo => '…ته لېږدول';

  @override
  String grpFMoveToColumn(String name) {
    return '$name ته لېږدول';
  }

  @override
  String grpFPlusCount(int count) {
    return '+$count';
  }

  @override
  String get grpFFoldColumn => 'ستون پټول';

  @override
  String get grpFColumn => 'ستون';

  @override
  String get grpFSetWipLimit => 'د روان کار حد ټاکل…';

  @override
  String get grpFChangeLimit => 'حد بدلول…';

  @override
  String get grpFAddTask => 'دنده زیاتول';

  @override
  String get grpFWipTitle => 'د روان کار حد';

  @override
  String get grpFWipMost => 'په دې ستون کې تر ټولو ډیر کارتونه';

  @override
  String get grpFColumnsBy => 'ستونونه د مخې';

  @override
  String grpFColumnsChip(String name) {
    return 'ستونونه: $name';
  }

  @override
  String get grpFSwimlanes => 'لینونه';

  @override
  String get grpFLanesAssignee => 'لینونه: ټاکل شوی';

  @override
  String get grpFNoSwimlanes => 'لینونه نشته';

  @override
  String get grpFByAssignee => 'د ټاکل شوي له مخې';

  @override
  String get grpFCardFields => 'د کارت ساحې';

  @override
  String get grpFCurrentSprint => 'اوسنی سپرنټ';

  @override
  String get grpFRefresh => 'تازه کول';

  @override
  String get grpFBoardLayoutNotSaved =>
      'ستاسو د تخته ترتیب خوندي نشو. په راتلونکي بدلون کې به بیا هڅه وشي.';

  @override
  String get grpFReschedule => 'بیا مهالویش…';

  @override
  String get grpFSchedule => 'مهالویش…';

  @override
  String get grpFRepeatsNotMade => 'تکرار: لا نه دی جوړ شوی';

  @override
  String get grpFEverythingDated => 'هر څه نیټه لري.';

  @override
  String grpFNothingOn(String day) {
    return 'په $day کې هیڅ نشته.';
  }

  @override
  String get grpFKindTasks => 'دندې';

  @override
  String get grpFKindComments => 'تبصرې';

  @override
  String get grpFKindProjects => 'پروژې';

  @override
  String get grpFKindPeople => 'خلک';

  @override
  String get grpFKindPages => 'پاڼې';

  @override
  String get grpFChipAssignedToMe => 'ماته ټاکل شوې';

  @override
  String get grpFChipOpen => 'پرانیستې';

  @override
  String get grpFChipDone => 'بشپړې';

  @override
  String get grpFSearchErrGeneric => 'یوه ستونزه رامنځته شوه. بیا هڅه وکړئ.';

  @override
  String get grpFSearchErrNetwork => 'سرور ته نه شو رسېدلی. خپل اتصال وګورئ.';

  @override
  String get grpFSearchErrDenied => 'تاسو دلته د لټون اجازه نه لرئ.';

  @override
  String get grpFSearchErrRate => 'ډیر لټونونه. یوه شېبه صبر وکړئ.';

  @override
  String get grpFSearchErrInvalid => 'دا لټون سم نه دی.';

  @override
  String get grpFSearchHint => 'دندې، تبصرې، پروژې، خلک ولټوئ';

  @override
  String get grpFSearchClose => 'لټون بندول';

  @override
  String get grpFSearchNothing =>
      'څه ونه موندل شول. لږ کلمې هڅه وکړئ یا یو id لکه WEB-12. په in:KEY، assignee:me، status:open ورته محدود کړئ.';

  @override
  String get grpFSearchTips =>
      'د لټون لپاره ټایپ کړئ. یو id لکه WEB-12 یا عملګرې in:KEY، assignee:me، status:open هڅه وکړئ.';

  @override
  String get grpFGoTo => 'ورتګ';

  @override
  String grpFShowMore(String kind) {
    return 'نور $kind وښایاست';
  }

  @override
  String get grpFRecent => 'وروستي';

  @override
  String grpFPlusMore(int count) {
    return '+$count نور';
  }

  @override
  String get grpFSubtaskDepthLimit =>
      'فرعي دندې دلته تر هغه حده چې اپلیکېشن اجازه ورکوي ځای پر ځای شوې دي.';

  @override
  String get grpFUnscheduled => 'نه مهالویش شوې';

  @override
  String get grpGCloseShortcuts => 'د کیبورډ شارټکټونه تړل';

  @override
  String get grpGKeyboardShortcuts => 'د کیبورډ شارټکټونه';

  @override
  String get grpGClose => 'تړل';

  @override
  String get grpGChangedByYou => 'ستاسو له خوا بدل شوی';

  @override
  String get grpGNone => 'هېڅ';

  @override
  String grpGChangeKeysFor(String title) {
    return 'د «$title» کیلي بدلول';
  }

  @override
  String grpGKeysFor(String title) {
    return 'د «$title» کیلي';
  }

  @override
  String get grpGPressKeys => 'هغه کیلي کېکاږئ چې غواړئ.';

  @override
  String get grpGUseDefault => 'تلواله کارول';

  @override
  String get grpGNoKey => 'بې کیلي';

  @override
  String get grpGCancel => 'لغوه';

  @override
  String get grpGSave => 'خوندي کول';

  @override
  String grpGBrowserKeeps(String keys) {
    return 'براوزر $keys ځان ته ساتي.';
  }

  @override
  String grpGAlreadyUsedBy(String title) {
    return 'مخکې د «$title» له خوا کارول شوی.';
  }

  @override
  String get grpGKeysTaken => 'بل عمل دا کیلي کاروي.';

  @override
  String get grpGKeysInvalid => 'دا کیلي نه شي کارول کېدای.';

  @override
  String get grpGSaveFailed => 'خوندي نه شو. خپل ارتباط وګورئ.';

  @override
  String grpGDefaultUsedBy(String title) {
    return 'تلوالې کیلي د «$title» له خوا کارول کېږي.';
  }

  @override
  String get grpGDefaultUsedByOther =>
      'تلوالې کیلي د بل عمل له خوا کارول کېږي.';

  @override
  String get grpGPaletteHint => 'یو امر ولیکئ، یا > عملونه  # پروژې  @ خلک';

  @override
  String get grpGNothingMatches => 'هېڅ برابر نه دی.';

  @override
  String get grpGSearchUnavailable => 'لټون همدا اوس نشته.';

  @override
  String get grpGName => 'نوم';

  @override
  String get grpGCreate => 'جوړول';

  @override
  String get grpGQuickActions => 'چټک عملونه';

  @override
  String grpGDryRunTitle(String name) {
    return 'آزمایښتي چلول: $name';
  }

  @override
  String get grpGDryRunIntro =>
      'ښيي چې په یوه دنده څه پېښېږي. هېڅ نه بدلېږي، نه لېږل کېږي او نه خبرتیا ورکول کېږي.';

  @override
  String get grpGTask => 'دنده';

  @override
  String get grpGTasksLoadFailed => 'دندې پورته نه شوې.';

  @override
  String get grpGWouldRun => 'به چلېږي.';

  @override
  String get grpGWouldNotRun => 'په دې دنده به ونه چلېږي.';

  @override
  String get grpGRun => 'چلول';

  @override
  String get grpGConditionProblem =>
      'په شرط کې ستونزه ده: د «که» کارت لاندې وګورئ.';

  @override
  String get grpGRuleGone => 'دا قاعده نور نشته.';

  @override
  String get grpGRule => 'قاعده';

  @override
  String get grpGNewAutomation => 'نوې اتومات';

  @override
  String get grpGEditAutomation => 'اتومات سمول';

  @override
  String get grpGWhen => 'کله';

  @override
  String get grpGIfOptional => 'که (اختیاري)';

  @override
  String get grpGThen => 'نو';

  @override
  String get grpGAndThen => 'او بیا';

  @override
  String grpGActionLimit(int max) {
    return 'د $max عملونو حد ته ورسېدلی';
  }

  @override
  String get grpGAddAction => 'عمل زیاتول';

  @override
  String get grpGLoadLatest => 'وروستی نسخه پورته کول';

  @override
  String get grpGMoveUp => 'پورته کول';

  @override
  String get grpGMoveDown => 'ښکته کول';

  @override
  String get grpGRemoveAction => 'عمل لرې کول';

  @override
  String grpGSwitchedOff(String reason) {
    return 'بند شو: $reason\nجوړول: قاعده خلاصه کړئ، په پیل یا عملونو کې یو شی وټاکئ چې لا شتون لري، خوندي یې کړئ او بیا یې چالان کړئ.';
  }

  @override
  String get grpGUnknown => 'نامعلوم';

  @override
  String get grpGEmptyValue => '(تش)';

  @override
  String get grpGNothingRunYet => 'تر اوسه هېڅ نه دي چلېدلي.';

  @override
  String get grpGLoadMore => 'نور پورته کول';

  @override
  String get grpGRetry => 'بیا هڅه';

  @override
  String grpGWhyNotRun(String explanation) {
    return 'ولې دا ونه چلېد؟ $explanation';
  }

  @override
  String grpGChainDepth(int depth) {
    return 'د زنځیر ژوروالی $depth';
  }

  @override
  String get grpGFilter => 'فلټر';

  @override
  String grpGFilterCount(int count) {
    return 'فلټر ($count)';
  }

  @override
  String get grpGSavedFilters => 'خوندي شوي فلټرونه';

  @override
  String get grpGNoSavedFilters => 'تر اوسه خوندي فلټر نشته';

  @override
  String grpGFieldGoneNamed(String name) {
    return '$name (یو ساحه ورکه ده)';
  }

  @override
  String get grpGManageSaved => 'خوندي فلټرونه سمبالول…';

  @override
  String grpGConditionCount(int count) {
    return '$count شرط/شرطونه';
  }

  @override
  String get grpGClearFilterTip => 'فلټر پاکول';

  @override
  String get grpGNothingSaved => 'تر اوسه هېڅ نه دي خوندي شوي.';

  @override
  String get grpGFieldItUsedGone => 'هغه ساحه چې کارولې یې وه ورکه ده';

  @override
  String get grpGDelete => 'ړنګول';

  @override
  String get grpGFinishConditions => 'لومړی شرطونه بشپړ کړئ.';

  @override
  String get grpGEveryoneWorkspace => 'په کاري ځای کې ټول';

  @override
  String get grpGEveryoneProject => 'په دې پروژه کې ټول';

  @override
  String get grpGBuilder => 'جوړوونکی';

  @override
  String get grpGAdvanced => 'پرمختللی';

  @override
  String get grpGClearFilter => 'فلټر پاکول';

  @override
  String get grpGSaveAs => 'د بل نوم سره خوندي کول…';

  @override
  String get grpGApply => 'پلي کول';

  @override
  String get grpGSaveThisFilter => 'دا فلټر خوندي کړئ';

  @override
  String get grpGOnlyMe => 'یوازې زه';

  @override
  String get grpGExportSaveFailed => 'فایل خوندي نه شو. بیا هڅه وکړئ.';

  @override
  String get grpGExport => 'صادرول';

  @override
  String get grpGEveryProject => 'هره پروژه چې خلاصولای شم';

  @override
  String get grpGOneProject => 'یوه پروژه';

  @override
  String get grpGExportInfo =>
      'یو zip چې tasks.json (چې TaskForge یې بیا واردولای شي)، tasks.csv، نظرونه، د ضمیمو لېست او README لري.';

  @override
  String grpGExportSavedSized(String name, String size) {
    return '$name خوندي شو ($size).';
  }

  @override
  String grpGExportSaved(String name) {
    return '$name خوندي شو.';
  }

  @override
  String grpGNotesAboutFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'د دې فایل په اړه $count یادښتونه',
      one: 'د دې فایل په اړه ۱ یادښت',
    );
    return '$_temp0';
  }

  @override
  String grpGRowNumber(int line) {
    return 'قطار $line';
  }

  @override
  String grpGAndMore(int count) {
    return '...او $count نور.';
  }

  @override
  String get grpGNotesReadFailed => 'د دې واردولو یادښتونه ونه لوستل شول.';

  @override
  String get grpGDragToOtherList => 'بل لېست ته ورکش کړئ';

  @override
  String get grpGAddedAfterStart => 'د پیل وروسته زیاته شوې';

  @override
  String get grpGStoryPoints => 'د کیسې ټکي';

  @override
  String get grpGUnitHours => 'ساعت';

  @override
  String get grpGUnitPoints => ' ټکي';

  @override
  String grpGLoadOf(String load, String unit, String cap) {
    return 'بار $load$unit له $cap$unit څخه';
  }

  @override
  String grpGLoadNoCapacity(String load, String unit) {
    return 'بار $load$unit (ظرفیت نه دی ټاکل شوی)';
  }

  @override
  String get grpGSetCapacity => 'ظرفیت ټاکل';

  @override
  String get grpGPoints => 'ټکي';

  @override
  String get grpGHours => 'ساعتونه';

  @override
  String grpGOverCapacity(String amount, String unit) {
    return 'له ظرفیت څخه $amount$unit ډېر';
  }

  @override
  String grpGTitleWithCount(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get grpHCancel => 'لغوه';

  @override
  String get grpHArchive => 'آرشیف';

  @override
  String get grpHRestore => 'بیرته راګرځول';

  @override
  String get grpHRetry => 'بیا هڅه';

  @override
  String get grpHCreate => 'جوړول';

  @override
  String get grpHName => 'نوم';

  @override
  String get grpHDescription => 'تشریح';

  @override
  String grpHArchiveTitle(String name) {
    return '\"$name\" آرشیف شي؟';
  }

  @override
  String get grpHArchiveBody =>
      'یوازې د لوستلو وړ کیږي او له څنګ پټې څخه ورکیږي. تاسو کولای شئ هر وخت یې بیرته راولئ.';

  @override
  String get grpHDangerZone => 'د خطر سیمه';

  @override
  String get grpHRestoreProject => 'پروژه بیرته راګرځول';

  @override
  String get grpHArchiveProject => 'پروژه آرشیف کول';

  @override
  String get grpHArchivedBanner =>
      'دا پروژه آرشیف شوې او یوازې د لوستلو وړ ده.';

  @override
  String get grpHArchivedProjects => 'آرشیف شوې پروژې';

  @override
  String get grpHNoArchived => 'هیڅ آرشیف شوې پروژه نشته.';

  @override
  String get grpHLoadProjectsRetry => 'پروژې نه شوې پورته کېدای. بیا هڅه';

  @override
  String get grpHNewProject => 'نوې پروژه';

  @override
  String get grpHKey => 'کیلي';

  @override
  String get grpHKeyHelp => 'د دندو د شمېرو مختاړی، لکه WEB-12';

  @override
  String get grpHFeatures => 'ځانګړتیاوې';

  @override
  String get grpHFeaturesHint =>
      'د یوې ځانګړتیا بندول یې پټوي خو معلومات یې ساتي.';

  @override
  String get grpHProjectUpdated => 'پروژه تازه شوه.';

  @override
  String get grpHGeneral => 'عمومي';

  @override
  String grpHKeyFixed(String taskKey) {
    return 'کیلي ټاکل شوې ده ځکه چې دندې لا دمخه کاروي ($taskKey).';
  }

  @override
  String get grpHSaveChanges => 'بدلونونه خوندي کړئ';

  @override
  String get grpHAddAMember => 'غړی اضافه کړئ';

  @override
  String get grpHAllAreMembers => 'د کار ځای ټول کسان لا دمخه غړي دي.';

  @override
  String get grpHMembers => 'غړي';

  @override
  String get grpHAddMember => 'غړی اضافه کړئ';

  @override
  String get grpHRemove => 'لرې کول';

  @override
  String get grpHLoadMembersRetry => 'غړي نه شول پورته کېدای. بیا هڅه';

  @override
  String get grpHPrivateProjects => 'خصوصي پروژې';

  @override
  String get grpHNoPrivate => 'هیڅ خصوصي پروژه نشته.';

  @override
  String grpHKeyAndMembers(String key, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غړي',
      one: '۱ غړی',
    );
    return '$key · $_temp0';
  }

  @override
  String get grpHAddMe => 'ما اضافه کړئ';

  @override
  String grpHColorLabel(String color) {
    return 'رنگ $color';
  }

  @override
  String get grpHVisOpen => 'خلاص';

  @override
  String get grpHVisPrivate => 'خصوصي';

  @override
  String get grpHVisOpenHint => 'د کار ځای ټول کسان یې لیدلای شي.';

  @override
  String get grpHVisPrivateHint => 'یوازې بلل شوي غړي یې لیدلای شي.';

  @override
  String get grpHProject => 'پروژه';

  @override
  String get grpHRemoveFavorite => 'له خوښو لرې کړئ';

  @override
  String get grpHAddFavorite => 'خوښو ته اضافه کړئ';

  @override
  String get grpHTrash => 'کثافات';

  @override
  String get grpHProjectSettings => 'د پروژې تنظیمات';

  @override
  String get grpHLoadProjectRetry => 'پروژه نه شوه پورته کېدای. بیا هڅه';

  @override
  String get grpHProjectNotFound => 'پروژه ونه موندل شوه.';

  @override
  String get grpHBack => 'شاته';

  @override
  String get grpHWorkflow => 'کاري بهیر';

  @override
  String get grpHWorkflowHint =>
      'حالتونه، د هغوی کټګورۍ او کوم لیږدونه اجازه لري.';

  @override
  String get grpHFields => 'ساحې';

  @override
  String get grpHFieldsHint =>
      'دودیز ساحې لکه پیرودونکی، د کیسې ټکي یا چاپیریال.';

  @override
  String get grpHAdd => 'اضافه کول';

  @override
  String get grpHAttachFile => 'فایل ضمیمه کړئ';

  @override
  String get grpHTakePhoto => 'انځور واخلئ';

  @override
  String get grpHChooseGallery => 'له ګالرۍ وټاکئ';

  @override
  String get grpHPasteImage => 'انځور پیسټ کړئ';

  @override
  String get grpHDeleteFileQ => 'دا فایل ړنګ شي؟';

  @override
  String grpHFileWillBeRemoved(String filename) {
    return '$filename لرې کیږي.';
  }

  @override
  String get grpHDelete => 'ړنګول';

  @override
  String grpHOpenFile(String filename) {
    return '$filename پرانیزئ';
  }

  @override
  String grpHDeleteFile(String filename) {
    return '$filename ړنګ کړئ';
  }

  @override
  String get grpHWaitingConnection => 'د اړیکې په تمه…';

  @override
  String get grpHWaiting => 'په تمه…';

  @override
  String get grpHUploadDone => 'بشپړ شو';

  @override
  String get grpHUploadCancelled => 'لغوه شو';

  @override
  String grpHPercentUploaded(String filename, int percent) {
    return '$filename، $percent سلنه پورته شوه';
  }

  @override
  String get grpHWaitingToBeSent => 'د لیږلو په تمه';

  @override
  String grpHCancelFile(String filename) {
    return '$filename لغوه کړئ';
  }

  @override
  String grpHTryFileAgain(String filename) {
    return '$filename بیا هڅه وکړئ';
  }

  @override
  String grpHDismissFile(String filename) {
    return '$filename پټ کړئ';
  }

  @override
  String get grpHOpen => 'پرانیستل';

  @override
  String get grpHDownload => 'ډاونلوډ';

  @override
  String get grpHClose => 'تړل';

  @override
  String get grpHCouldNotOpenFile => 'فایل ونه پرانیستل شو.';

  @override
  String get grpHCouldNotLoadPicture => 'انځور نه شو پورته کېدای.';

  @override
  String get grpHCouldNotReadFileViewer => 'فایل ونه لوستل شو.';

  @override
  String get grpHCouldNotPlayVideo => 'ویډیو ونه غږول شوه.';

  @override
  String get grpHPause => 'ځنډول';

  @override
  String get grpHPlay => 'غږول';

  @override
  String grpHTextTruncated(String size) {
    return 'لومړی $size ښودل کیږي. پاتې برخه د لوستلو لپاره فایل ډاونلوډ کړئ.';
  }

  @override
  String get grpHAttachments => 'ضمیمې';

  @override
  String grpHAttachmentsCount(int count) {
    return 'ضمیمې ($count)';
  }

  @override
  String get grpHCouldNotReadFile => 'دا فایل ونه لوستل شو.';

  @override
  String get grpHDismiss => 'پټول';

  @override
  String get grpHNoAttachments => 'هیڅ ضمیمه نشته.';

  @override
  String get grpHDropZoneLabel =>
      'فایلونه ضمیمه کړئ: دلته یې پرېږدئ یا کلیک وکړئ، بیا انځور پیسټ کړئ';

  @override
  String get grpHDropToAttach => 'د ضمیمې لپاره پرېږدئ';

  @override
  String get grpHDropFilesHere => 'فایلونه دلته پرېږدئ ترڅو ضمیمه شي';

  @override
  String get grpHSnoozeLaterToday => 'نن وروسته';

  @override
  String get grpHSnoozeTomorrow => 'سبا';

  @override
  String get grpHSnoozeNextWeek => 'راتلونکې اوونۍ';

  @override
  String get grpHMarkAllRead => 'ټول لوستل شوي وټاکئ';

  @override
  String get grpHNotificationSettings => 'د خبرتیاوو تنظیمات';

  @override
  String get grpHInbox => 'ان‌باکس';

  @override
  String grpHUnreadCount(int count) {
    return '$count نالوستل شوي';
  }

  @override
  String get grpHLoadMore => 'نور پورته کړئ';

  @override
  String get grpHEmptyAll => 'دلته هیڅ نشته. تاسو ټول کتلي دي.';

  @override
  String get grpHEmptyUnread => 'هیڅ نالوستل شوې خبرتیا نشته.';

  @override
  String get grpHEmptyMentions => 'هیچا تاسو نه دي یاد کړي.';

  @override
  String get grpHEmptyAssigned => 'دا وروستیو کې تاسو ته هیڅ نه دي سپارل شوي.';

  @override
  String get grpHEmptySnoozed => 'هیڅ نه دي ځنډول شوي.';

  @override
  String get grpHEmptyArchived => 'هیڅ نه دي آرشیف شوي.';

  @override
  String grpHDueDate(String date) {
    return 'وروستی نیټه $date';
  }

  @override
  String grpHUnreadPrefix(String title) {
    return 'نالوستل شوی. $title';
  }

  @override
  String grpHMoreCount(int count) {
    return '+$count نور';
  }

  @override
  String get grpHMore => 'نور';

  @override
  String get grpHMarkUnread => 'نالوستل وټاکئ';

  @override
  String get grpHMarkRead => 'لوستل شوی وټاکئ';

  @override
  String get grpHStopSnoozing => 'ځنډول ودروئ';

  @override
  String get grpHSnoozeEllipsis => 'ځنډول…';

  @override
  String get grpHMoveToInbox => 'ان‌باکس ته یې ولېږئ';

  @override
  String get grpHPushTitle => 'کله چې مهمه وي خبرتیا ترلاسه کړئ';

  @override
  String get grpHPushBody =>
      'TaskForge کولای شي کله چې تاسو ته دنده سپارل کیږي، تاسو یادیږئ، یا د دندې وروستۍ نیټه نږدې وي، حتی کله چې اپ په شالید کې وي، خبرتیا وښيي. بیا ستاسو وسیله اجازه غواړي. تاسو غوره کوئ کومې ډولونه خبرتیا درکړي او د خاموشۍ ساعتونه مو له ویښېدو ساتي.';

  @override
  String get grpHNotNow => 'اوس نه';

  @override
  String get grpHContinue => 'دوام ورکړئ';

  @override
  String get grpHPickDateTime => 'نیټه او وخت وټاکئ';

  @override
  String get grpHRepeatReadError => 'دا نه شو لوستل چې څنګه تکرارېږي.';

  @override
  String get grpHRepeat => 'تکرار';

  @override
  String get grpHFirstOfSeries => 'د لړۍ لومړی';

  @override
  String get grpHRepeatingTask => 'تکراري دنده';

  @override
  String grpHSeriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دندې په دې لړۍ کې',
      one: '$count دنده په دې لړۍ کې',
    );
    return '$_temp0';
  }

  @override
  String get grpHRepeatPaused => 'ځنډول شوی: نوې دندې نه جوړیږي.';

  @override
  String grpHRepeatPausedBySystem(String reason) {
    return 'سیستم ځنډولی: $reason';
  }

  @override
  String grpHRepeatNext(String dates) {
    return 'راتلونکی: $dates';
  }

  @override
  String get grpHRepeatWaits => 'راتلونکې به کله جوړ شي چې دا بشپړه شي.';

  @override
  String get grpHRepeatsTitle => 'دا دنده تکرارېږي';

  @override
  String grpHRepeatsBody(String summary) {
    return 'دا د \"$summary\" کینه ده. ړنګول یې کولای شي لړۍ ودروي، یا لړۍ کولای شي نوې دندې جوړولو ته دوام ورکړي.';
  }

  @override
  String get grpHDeleteKeepRepeating => 'ړنګول، تکرار دوام ورکړي';

  @override
  String get grpHDeleteAndStop => 'ړنګول او درول';

  @override
  String get grpHChartGroup => 'ډله';

  @override
  String get grpHOfflineReview => 'کتنه';

  @override
  String get grpHOfflineSyncing => 'همغږي کیږي…';

  @override
  String get grpHOfflineSyncNow => 'اوس همغږي کړئ';

  @override
  String get grpHOfflineSaved =>
      'تاسو آفلاین یاست. بدلونونه په دې وسیله کې خوندي کیږي.';

  @override
  String grpHOfflineWaitsOnline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدلونونه د لیږلو په تمه دي.',
      one: '$count بدلون د لیږلو په تمه دی.',
    );
    return '$_temp0';
  }

  @override
  String grpHOfflineWaitsOffline(int count) {
    return '$count د لیږلو په تمه.';
  }

  @override
  String grpHOfflineAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدلونونه ستاسو پاملرنې ته اړتیا لري.',
      one: '$count بدلون ستاسو پاملرنې ته اړتیا لري.',
    );
    return '$_temp0';
  }

  @override
  String get grpHReconnecting =>
      'بیا نښلول کیږي… هغه څه چې تاسو یې وینئ به له بیرته راستنېدو وروسته تازه شي.';

  @override
  String get grpICancel => 'لغوه کړه';

  @override
  String get grpIDone => 'بشپړ شو';

  @override
  String get grpIRetry => 'بیا هڅه وکړه';

  @override
  String get grpIClose => 'تړل';

  @override
  String get grpIBack => 'شاته';

  @override
  String get grpIEdit => 'سمول';

  @override
  String get grpISave => 'خوندي کړه';

  @override
  String get grpISaving => 'خوندي کیږي…';

  @override
  String get grpIDelete => 'ړنګول';

  @override
  String get grpICopy => 'کاپي';

  @override
  String get grpIUndo => 'بیرته کول';

  @override
  String get grpIRestore => 'بیرته راوستل';

  @override
  String get grpIUnnamed => '(بې نومه)';

  @override
  String grpIErrorRetry(String message) {
    return '$message بیا هڅه وکړه';
  }

  @override
  String get grpIMergeTitle => 'بل چا لومړی کاري بهیر خوندي کړ';

  @override
  String get grpIMergeBody =>
      'ستاسو سمونونه وساتل شول او د هغوی کار نه دی بدل شوی. دا هغه دي چې ستاسو په مسوده کې بدل شول:';

  @override
  String get grpIMergeKeep => 'ما دا ولوستل، زما مسوده وساته';

  @override
  String get grpIMergeReload => 'زما مسوده لرې کړه';

  @override
  String get grpINoProblems => 'هیڅ ستونزه نشته';

  @override
  String get grpIEveryTaskValid => 'هر کار یو معتبر حالت لري.';

  @override
  String grpIProblemsToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ستونزې د خوندي کولو دمخه حل کړئ',
      one: '۱ ستونزه د خوندي کولو دمخه حل کړئ',
    );
    return '$_temp0';
  }

  @override
  String get grpIAnyStatusMoves => 'هر حالت کولی شي بل هر حالت ته ولاړ شي.';

  @override
  String grpIWorkflowGraphLabel(int statuses, int moves) {
    return 'کاري بهیر د $statuses حالتونو او $moves اجازه شوو لیږدونو سره';
  }

  @override
  String get grpINeedsAssignee => 'مسئول ته اړتیا لري';

  @override
  String get grpINeedsSubtasksDone => 'د ټولو فرعي کارونو بشپړیدو ته اړتیا لري';

  @override
  String grpIOnlyRoleLower(String role) {
    return 'یوازې $role';
  }

  @override
  String get grpIOneRole => 'یو رول';

  @override
  String get grpIDragToReorder => 'د ترتیب لپاره کش کړئ';

  @override
  String get grpIColour => 'رنګ';

  @override
  String get grpINewTasksStartHere => 'نوي کارونه دلته پیل کیږي';

  @override
  String get grpIMakeDefaultStatus => 'دا د نوو کارونو د پیل حالت کړئ';

  @override
  String get grpIDeleteStatus => 'حالت ړنګ کړئ';

  @override
  String grpITaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارونه',
      one: '۱ کار',
    );
    return '$_temp0';
  }

  @override
  String get grpICanMoveTo => 'کولی شي ولاړ شي';

  @override
  String get grpIConditionsForMove => 'د دې لیږد شرطونه';

  @override
  String get grpIName => 'نوم';

  @override
  String grpIDeleteStatusTitle(String name) {
    return '$name ړنګ شي؟';
  }

  @override
  String grpITasksInStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارونه په دې حالت کې دي. غوره کړئ چیرې ولاړ شي.',
      one: '۱ کار په دې حالت کې دی. غوره کړئ چیرې ولاړ شي.',
    );
    return '$_temp0';
  }

  @override
  String get grpIMoveTasksTo => 'کارونه ولېږدوئ';

  @override
  String get grpIMoveTasksAndDelete => 'کارونه ولېږدوئ او ړنګ کړئ';

  @override
  String get grpIWhoMayMove => 'څوک کولی شي دا لیږد وکړي';

  @override
  String get grpIAnyRole => 'هر رول';

  @override
  String grpIOnlyRole(String name) {
    return 'یوازې $name';
  }

  @override
  String get grpITaskNeedsAssignee => 'کار مسئول ته اړتیا لري';

  @override
  String get grpIAllSubtasksDone => 'ټول فرعي کارونه باید بشپړ وي';

  @override
  String get grpIDoneOrCancelledDepth => 'بشپړ یا لغوه شوي، په هر ژوروالي کې.';

  @override
  String get grpIWorkflow => 'کاري بهیر';

  @override
  String get grpIDiscard => 'لرې کول';

  @override
  String get grpIWorkflowSaved => 'کاري بهیر خوندي شو';

  @override
  String get grpIRestrictTransitions => 'لیږدونه محدودول';

  @override
  String get grpIRestrictTransitionsHint =>
      'بند: هر حالت کولی شي بل هر حالت ته ولاړ شي. چالان: یوازې هغه غشي چې تاسو اجازه ورکوئ.';

  @override
  String get grpIRestrictCreation =>
      'نوي کارونه یوازې په ډیفالټ حالت کې پیل شي';

  @override
  String get grpIRestrictCreationHint =>
      'بند: کار په هر حالت کې جوړیدای شي. چالان: دا په ستوری لرونکي حالت کې پیل کیږي او نورو ته په لیږدولو رسیږي.';

  @override
  String get grpIAddStatus => 'حالت اضافه کړئ';

  @override
  String get grpINewStatus => 'نوی حالت';

  @override
  String get grpIMigrationNeedsPlace =>
      'هغه کارونه چې تاسو دلته د لیږدولو لپاره غوره کړي نوې ځای ته اړتیا لري.';

  @override
  String grpIMoveArrow(String from, String to) {
    return '$from ← $to';
  }

  @override
  String grpIDeletedStillHasTasks(String name) {
    return '$name ړنګ شو خو لا هم کارونه لري.';
  }

  @override
  String get grpIMoveItsTasksTo => 'د دې کارونه ولېږدوئ';

  @override
  String grpIDrillTitle(String title, int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'کارونه',
      one: 'کار',
    );
    return '$title · $count$more $_temp0';
  }

  @override
  String get grpINoTasks => 'کار نشته.';

  @override
  String get grpIDrillTruncated =>
      'یوازې لومړني کارونه لیست شوي؛ د پاتې لیدلو لپاره فلټر محدود کړئ.';

  @override
  String grpIDueOn(String date) {
    return 'سرچېن $date';
  }

  @override
  String get grpINothingToShow => 'تر اوسه د ښودلو لپاره څه نشته.';

  @override
  String get grpIRefresh => 'تازه کول';

  @override
  String get grpIWidgetMenu => 'د ویجټ مینو';

  @override
  String get grpIExportCsv => 'CSV صادرول';

  @override
  String get grpIRemove => 'لرې کول';

  @override
  String get grpISaveToSeeNumbers => 'د شمیرو لیدلو لپاره خوندي کړئ.';

  @override
  String grpICsvTitle(String title) {
    return '$title (CSV)';
  }

  @override
  String get grpICsvCopied => 'CSV کاپي شو.';

  @override
  String get grpISaveAsFile => 'د فایل په توګه خوندي کړئ';

  @override
  String grpILatestPoints(int limit) {
    return 'وروستي $limit ټکي ښودل کیږي؛ د ټولو لیدلو لپاره حد لنډ کړئ.';
  }

  @override
  String grpITopLimit(int limit) {
    return 'پورتنی $limit ښودل کیږي؛ د پاتې لیدلو لپاره فلټر محدود کړئ.';
  }

  @override
  String get grpIWidget => 'ویجټ';

  @override
  String get grpITitle => 'سرلیک';

  @override
  String get grpIGroupBy => 'ډلبندي د مخې';

  @override
  String get grpIFilterTfqlOptional => 'فلټر (TFQL، اختیاري)';

  @override
  String get grpIPreview => 'مخکتنه';

  @override
  String get grpIProject => 'پروژه';

  @override
  String get grpISprint => 'سپرنټ';

  @override
  String grpIDateRange(String start, String end) {
    return '$start ← $end';
  }

  @override
  String grpIFromDate(String date) {
    return 'له $date';
  }

  @override
  String get grpINoDates => 'نیټې نشته';

  @override
  String grpIDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ورځې',
      one: '۱ ورځ',
    );
    return '$_temp0';
  }

  @override
  String get grpINothingScheduled => 'په دې حد کې هیڅ شی مهالویش شوی نه دی.';

  @override
  String get grpIOnCriticalPath => 'په انتقادي لار کې';

  @override
  String get grpIBlocked => 'بند شوی';

  @override
  String grpIMovingPushes(String id, int count) {
    return 'د $id لیږدول $count وړاندې کوي';
  }

  @override
  String grpIRangeShift(String from, String to) {
    return '$from  ←  $to';
  }

  @override
  String get grpIKeepThem => 'وساتل شي (تضاد وښایاست)';

  @override
  String get grpIShiftDependents => 'تابع کارونه وښوروئ';

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
  String get grpIWorkingDays => 'کاري ورځې';

  @override
  String get grpIWorkingDaysHint => 'یو کار د بل څخه تېرول رخصتۍ ورځې پرېږدي.';

  @override
  String get grpIHolidays => 'رخصتۍ';

  @override
  String get grpIHolidaysHint => 'نیټې لکه 2026-12-25، د کومو په واسطه جلا شوې';

  @override
  String grpITimelineChartLabel(int count) {
    return 'د $count کارونو مهالویش چارټ. د لوستلو لپاره لیست لید ته لاړ شئ.';
  }

  @override
  String get grpITimelineDragHint =>
      'د خوځولو لپاره یو بار کش کړئ، د اندازې بدلولو لپاره یو سر. Ctrl + ویل یا پنچ زوم کوي.';

  @override
  String get grpIUnscheduled => 'بې مهالویشه';

  @override
  String get grpIMovedLinksBreak =>
      'ولېږدول شو. هغه لینکونه چې ماتیږي په سور ښودل کیږي.';

  @override
  String get grpITimelineSaved => 'مهالویش خوندي شو.';

  @override
  String get grpIDay => 'ورځ';

  @override
  String get grpIWeek => 'اونۍ';

  @override
  String get grpIMonth => 'میاشت';

  @override
  String get grpIQuarter => 'ربع';

  @override
  String get grpITaskTree => 'د کارونو ونه';

  @override
  String get grpIByAssignee => 'د مسئول له مخې';

  @override
  String get grpIByStatus => 'د حالت له مخې';

  @override
  String get grpIEarlier => 'مخکینی';

  @override
  String get grpIToday => 'نن';

  @override
  String get grpILater => 'وروسته';

  @override
  String get grpICriticalPath => 'انتقادي لار';

  @override
  String get grpIHideDone => 'بشپړ شوي پټ کړئ';

  @override
  String get grpIShowChart => 'چارټ وښایاست';

  @override
  String get grpIShowList => 'د لیست په توګه وښایاست';

  @override
  String get grpIExportImage => 'د انځور په توګه صادرول';

  @override
  String get grpICurrency => 'اسعار';

  @override
  String get grpIClear => 'پاکول';

  @override
  String get grpINone => 'هیڅ';

  @override
  String grpIFieldArchived(String name) {
    return '$name آرشیف شو. ارزښتونه ۳۰ ورځې ساتل کیږي.';
  }

  @override
  String get grpIFields => 'ساحې';

  @override
  String get grpIAddField => 'ساحه اضافه کړئ';

  @override
  String get grpINoCustomFields =>
      'تر اوسه دودیز ساحې نشته. د مشتري یا د کیسې ټکو په څیر شیانو لپاره یوه اضافه کړئ.';

  @override
  String get grpIArchivedRestorable =>
      'آرشیف شوي (د ۳۰ ورځو لپاره د بیرته راوستلو وړ)';

  @override
  String get grpIRequired => 'اړین';

  @override
  String grpIOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count انتخابونه',
      one: '۱ انتخاب',
    );
    return '$_temp0';
  }

  @override
  String get grpIArchive => 'آرشیف';

  @override
  String get grpIWriteComment => 'یو نظر ولیکئ… (@ د یادولو لپاره)';

  @override
  String get grpIComment => 'نظر';

  @override
  String get grpIBulletList => 'د ټکو لیست';

  @override
  String get grpIQuote => 'نقل قول';

  @override
  String get grpICodeBlock => 'د کوډ بلاک';

  @override
  String get grpILink => 'لینک';

  @override
  String get grpICouldNotReadFile => 'دا فایل ولوستل نشو.';

  @override
  String get grpICtrlEnterToSend => 'د لیږلو لپاره Ctrl+Enter';

  @override
  String get grpIDeleteCommentTitle => 'دا نظر ړنګ شي؟';

  @override
  String get grpIDeleteCommentBody =>
      'دا به د «نظر لرې شو» په توګه وښودل شي. د دې منځپانګه او د سمون تاریخ ړنګیږي.';

  @override
  String get grpICannotSeeTask => 'دوی دا کار نشي لیدلی';

  @override
  String grpICannotSeeGrant(String names) {
    return '$names دا کار نشي لیدلی. دوی پروژې ته اضافه کړئ او نظر ولیږئ، یا یادونه لرې کړئ.';
  }

  @override
  String grpICannotSeeRefuse(String names) {
    return '$names دا کار نشي لیدلی، نو یادونه یې نشي کیدلی. یادونه لرې کړئ، یا له هغه چا وغواړئ چې پروژه اداره کوي چې دوی اضافه کړي.';
  }

  @override
  String get grpIOk => 'سمه ده';

  @override
  String get grpIAddThemAndSend => 'اضافه یې کړئ او ولیږئ';

  @override
  String grpIEditHistory(String author) {
    return 'د سمون تاریخ · $author';
  }

  @override
  String grpIRevisionCurrent(String stamp) {
    return '$stamp · اوسنی';
  }

  @override
  String get grpISessions => 'ناستې';

  @override
  String get grpISignOutOthers => 'له نورو وسایلو وزئ';

  @override
  String get grpIUnknownDevice => 'نامعلوم وسیله';

  @override
  String get grpIThisDevice => 'دا وسیله';

  @override
  String get grpISignOutThis => 'له دې وسیلې وزئ';

  @override
  String get grpJLink => 'لینک';

  @override
  String get grpJInviteEmails => 'د بريښنالیک پتې';

  @override
  String grpJInviteEmailsHelp(int max) {
    return 'څو پتې په کوما سره جلا کړئ. تر $max پورې.';
  }

  @override
  String get grpJAdd => 'زیاتول';

  @override
  String grpJInviteInvalidEmail(String email) {
    return '«$email» د بريښنالیک سمه پته نه ده.';
  }

  @override
  String grpJInviteTooMany(int max) {
    return 'تاسو په یوه وخت کې تر $max کسانو پورې بلنه ورکولی شئ.';
  }

  @override
  String get grpJInviteSendAll => 'بلنې ولېږئ';

  @override
  String grpJInviteSendCount(int count) {
    return '$count ولېږئ';
  }

  @override
  String grpJInvited(int count) {
    return '$count کسان وبلل شول.';
  }

  @override
  String grpJInviteSkipped(String emails) {
    return 'لا دمخه غړي دي، پریښودل شول: $emails';
  }

  @override
  String get grpJExpiresAfter => 'د پای ته رسېدو وروسته';

  @override
  String grpJDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ورځې',
      one: '$count ورځ',
    );
    return '$_temp0';
  }

  @override
  String get grpJMaxUses => 'تر ټولو ډېر کارونه';

  @override
  String get grpJMaxUsesHelp => 'د بې حدودو لپاره خالي پرېږدئ.';

  @override
  String grpJMaxUsesInvalid(int max) {
    return 'له ۱ څخه تر $max پورې شمېره ولیکئ یا خالي یې پرېږدئ.';
  }

  @override
  String get grpJCreateLink => 'لینک جوړ کړئ';

  @override
  String get grpJCopyLink => 'لینک کاپي کړئ';

  @override
  String get grpJRole => 'رول';

  @override
  String get grpJInvitationTitle => 'بلنه';

  @override
  String get grpJJoin => 'یوځای شئ';

  @override
  String get grpJDecline => 'ردول';

  @override
  String get grpJGoToTaskForge => 'TaskForge ته لاړ شئ';

  @override
  String get grpJInvitedToJoin => 'تاسو یوځای کېدو ته بلل شوي یاست';

  @override
  String grpJInviterInvitedYou(String name) {
    return '$name تاسو یوځای کېدو ته وبلئ';
  }

  @override
  String get grpJBack => 'شاته';

  @override
  String get grpJMembers => 'غړي';

  @override
  String get grpJInvite => 'بلنه';

  @override
  String get grpJPending => 'په تمه';

  @override
  String grpJJoined(String date) {
    return '$date یوځای شو';
  }

  @override
  String get grpJRemoveFromWorkspace => 'له کاري ځای څخه لرې کړئ';

  @override
  String get grpJSearchMembers => 'غړي ولټوئ';

  @override
  String grpJRemoveMember(String name) {
    return '$name لرې کړئ';
  }

  @override
  String get grpJOwnerCannotLeave =>
      'تاسو د دې کاري ځای مالک یاست، نو نه شئ کولی ترې ووځئ. مالکیت لا نه شي لېږدول کېدای.';

  @override
  String get grpJLeaveWorkspace => 'کاري ځای پرېږدئ';

  @override
  String grpJRemoveMemberTitle(String name) {
    return '$name لرې شي؟';
  }

  @override
  String get grpJRemoveMemberBody =>
      'دوی به د دې کاري ځای لاسرسی له لاسه ورکړي. تاسو وروسته بیا بلنه ورکولی شئ.';

  @override
  String get grpJRemove => 'لرې کړئ';

  @override
  String grpJLeaveTitle(String name) {
    return '$name پرېښودل شي؟';
  }

  @override
  String get grpJLeaveBody =>
      'تر هغه چې څوک بیا تاسو ته بلنه ورکړي، به د دې کاري ځای لاسرسی له لاسه ورکړئ.';

  @override
  String get grpJLeave => 'پرېښودل';

  @override
  String grpJErrorRetry(String error) {
    return '$error بیا هڅه وکړئ';
  }

  @override
  String get grpJLinkCopied => 'لینک کاپي شو.';

  @override
  String get grpJNoInvitations => 'تر اوسه هېڅ بلنه نشته.';

  @override
  String get grpJInvitationResent => 'بلنه بیا ولېږل شوه.';

  @override
  String get grpJResend => 'بیا ولېږئ';

  @override
  String get grpJRevoke => 'لغوه کړئ';

  @override
  String get grpJStatePending => 'په تمه';

  @override
  String get grpJStateExpired => 'پای ته رسېدلی';

  @override
  String get grpJStateRevoked => 'لغوه شوی';

  @override
  String get grpJStateUsedUp => 'کارول شوی';

  @override
  String grpJUsesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ځله کارول شو',
      one: '$count ځل کارول شو',
    );
    return '$_temp0';
  }

  @override
  String grpJUsesOfMax(int uses, int max) {
    return '$uses/$max ځله کارول';
  }

  @override
  String get grpJInviteLink => 'د بلنې لینک';

  @override
  String grpJInvitationMeta(String name, String date) {
    return 'د $name لخوا · $date پای ته رسېږي';
  }

  @override
  String get grpJChangeRole => 'رول بدل کړئ';

  @override
  String get grpJBlockOptions => 'د بلاک اختیارونه';

  @override
  String get grpJMoveUp => 'پورته یې کړئ';

  @override
  String get grpJMoveDown => 'ښکته یې کړئ';

  @override
  String get grpJAddBlockBelow => 'لاندې بلاک زیات کړئ';

  @override
  String get grpJDelete => 'ړنګ کړئ';

  @override
  String grpJTurnInto(String label) {
    return 'په $label واړوئ';
  }

  @override
  String get grpJClickToWrite => 'د لیکلو پیلولو لپاره دلته کلیک وکړئ';

  @override
  String get grpJAddBlock => 'بلاک زیات کړئ';

  @override
  String get grpJDocs => 'اسناد';

  @override
  String get grpJPickPage => 'یو پاڼه وټاکئ یا نوې جوړه کړئ.';

  @override
  String get grpJNoMatchingBlocks => 'هېڅ برابر بلاک ونه موندل شو';

  @override
  String get grpJNoMatchingPages => 'هېڅ برابره پاڼه ونه موندل شوه';

  @override
  String get grpJTableRow => 'قطار';

  @override
  String get grpJTableColumn => 'ستون';

  @override
  String get grpJNoImageAddress => 'تر اوسه د انځور پته نشته';

  @override
  String get grpJImageLoadFailed => 'انځور نه شو پورته کېدای';

  @override
  String get grpJEditImage => 'انځور سم کړئ';

  @override
  String get grpJLoadingTask => 'دنده بارېږي...';

  @override
  String get grpJNoAccessTask => 'دې دندې ته لاسرسی نشته';

  @override
  String grpJUnknownBlock(String type) {
    return 'دا بلاک ($type) د TaskForge نوې نسخې ته اړتیا لري. لکه څنګه چې دی همداسې ساتل کېږي.';
  }

  @override
  String get grpJLinkAPage => 'یوه پاڼه وتړئ';

  @override
  String get grpJNoPagesYetLong => 'تر اوسه هېڅ پاڼه نشته.';

  @override
  String get grpJRelatedDocs => 'اړوند اسناد';

  @override
  String get grpJNoPagesYet => 'تر اوسه پاڼې نشته.';

  @override
  String get grpJLinked => 'تړل شوی';

  @override
  String get grpJEmbedded => 'ځای پر ځای شوی';

  @override
  String get grpJUnlink => 'جدا کړئ';

  @override
  String grpJChangeTone(String tone) {
    return 'لهجه بدله کړئ ($tone)';
  }

  @override
  String get grpJBold => 'پنډ';

  @override
  String get grpJItalic => 'سوی';

  @override
  String get grpJStrikethrough => 'کرښه پرې';

  @override
  String get grpJCode => 'کوډ';

  @override
  String get grpJHintParagraph =>
      'د بلاکونو لپاره \'/\' او د پاڼې یادولو لپاره \'[[\' ولیکئ';

  @override
  String grpJHintHeading(int level) {
    return 'سرلیک $level';
  }

  @override
  String get grpJCodeLanguageHint => 'ژبه';

  @override
  String get grpJUndo => 'بیرته';

  @override
  String get grpJRestore => 'بیا ځای پر ځای کړئ';

  @override
  String get grpJName => 'نوم';

  @override
  String grpJWorkspaceDeleted(String name) {
    return '«$name» ړنګ شو. تر ۷ ورځو پورې بیا ځای پر ځای کېدای شي.';
  }

  @override
  String get grpJDangerZone => 'د خطر سیمه';

  @override
  String get grpJDangerZoneBody =>
      'د کاري ځای ړنګول یې له ټولو پټوي. تاسو یې تر ۷ ورځو پورې بیا ځای پر ځای کولی شئ.';

  @override
  String get grpJDeleteWorkspace => 'کاري ځای ړنګ کړئ';

  @override
  String get grpJDeleteWorkspaceQ => 'کاري ځای ړنګ شي؟';

  @override
  String grpJTypeNameToConfirm(String name) {
    return 'د تایید لپاره «$name» ولیکئ';
  }

  @override
  String get grpJNewWorkspace => 'نوی کاري ځای';

  @override
  String get grpJCreateYourWorkspace => 'خپل کاري ځای جوړ کړئ';

  @override
  String get grpJWorkspaceHolds =>
      'کاري ځای ستاسو د ټیم پروژې او دندې ځان کې ساتي.';

  @override
  String get grpJUrl => 'URL';

  @override
  String get grpJCreateWorkspace => 'کاري ځای جوړ کړئ';

  @override
  String get grpJRecentlyDeleted => 'وروستی ړنګ شوي';

  @override
  String get grpJSwitchWorkspace => 'کاري ځای بدل کړئ';

  @override
  String get grpJTimerRunning => 'ټایمر روان دی';

  @override
  String grpJTimerStoppedOn(String key, String title) {
    return 'په $key $title ټایمر ودرول شو';
  }

  @override
  String get grpJTime => 'وخت';

  @override
  String get grpJStop => 'ودروئ';

  @override
  String get grpJStartTimer => 'ټایمر پیل کړئ';

  @override
  String get grpJAddTime => 'وخت زیات کړئ';

  @override
  String grpJTimeOfEstimate(String logged, String estimate) {
    return '$logged له $estimate څخه';
  }

  @override
  String grpJTimeLogged(String logged) {
    return '$logged ثبت شو';
  }

  @override
  String grpJTimeBillable(String duration) {
    return '$duration د بل وړ';
  }

  @override
  String get grpJChangeEstimate => 'اټکل بدل کړئ';

  @override
  String get grpJSetEstimate => 'اټکل وټاکئ';

  @override
  String get grpJRunning => 'روان';

  @override
  String get grpJLoggedLabel => 'ثبت شوی';

  @override
  String get grpJYou => 'تاسو';

  @override
  String get grpJBillableSuffix => 'د بل وړ';

  @override
  String get grpJOverlapsEntry => 'له بل ثبت سره سمون لري';

  @override
  String get grpJOver24h => 'له ۲۴ ساعتو ډېر: وګورئ';

  @override
  String get grpJEdit => 'سمول';

  @override
  String get grpJStopTheTimer => 'ټایمر ودروئ';

  @override
  String get grpJRoleActions => 'د رول کړنې';

  @override
  String get grpJRename => 'نوم بدل کړئ';

  @override
  String get grpJBuiltInReadOnly => 'جوړ شوی، یوازې د لوستلو';

  @override
  String get grpJRolesAndPermissions => 'رولونه او اجازې';

  @override
  String get grpJNewRole => 'نوی رول';

  @override
  String get grpJActivity => 'فعالیت';

  @override
  String get grpJNoActivity => 'تر اوسه هېڅ فعالیت نشته.';

  @override
  String get grpJDebugTitle => 'TaskForge — اړیکه';

  @override
  String grpJPingLabel(String label) {
    return '$label پینګ';
  }

  @override
  String grpJPingError(String error) {
    return 'تېروتنه: $error';
  }

  @override
  String get grpKClosePalette => 'د قوماندو پالټ تړل';

  @override
  String get grpKGroupGeneral => 'عمومي';

  @override
  String get grpKGroupGoTo => 'ورتلل';

  @override
  String get grpKGroupProjects => 'پروژې';

  @override
  String get grpKGroupWorkspace => 'کاري ځای';

  @override
  String get grpKGroupAccount => 'حساب';

  @override
  String get grpKGroupThisProject => 'دا پروژه';

  @override
  String get grpKGroupDocs => 'اسناد';

  @override
  String get grpKGroupDashboards => 'ډیشبورډونه';

  @override
  String get grpKGroupListView => 'د لیست لید';

  @override
  String get grpKGroupThisTask => 'دا دنده';

  @override
  String grpKGoTo(String title) {
    return '$title ته ورتلل';
  }

  @override
  String grpKProjectPageOf(String title) {
    return 'د دې پروژې $title';
  }

  @override
  String get grpKPaletteOpen => 'د قوماندو پالټ خلاصول';

  @override
  String get grpKSearch => 'لټون';

  @override
  String get grpKSearchSem => 'دندې، نظرونه، پروژې او خلک ولټوئ';

  @override
  String get grpKShortcuts => 'د کیبورډ شارټکټونه';

  @override
  String get grpKShortcutsSem => 'د کیبورډ شارټکټونه ښکاره کړئ';

  @override
  String get grpKTHome => 'کور';

  @override
  String get grpKTInbox => 'ان‌باکس';

  @override
  String get grpKTCalendar => 'د کاري ځای کلیز';

  @override
  String get grpKTDocs => 'اسناد';

  @override
  String get grpKTDashboards => 'ډیشبورډونه';

  @override
  String get grpKTTimesheet => 'د وخت پاڼه';

  @override
  String get grpKTMembers => 'غړي';

  @override
  String get grpKTArchivedProjects => 'آرشیف شوې پروژې';

  @override
  String get grpKTPrivateProjects => 'شخصي پروژې';

  @override
  String get grpKTWorkspaceSettings => 'د کاري ځای تنظیمات';

  @override
  String get grpKAuditLog => 'د پلټنې لاګ';

  @override
  String get grpKAuditSem => 'د پلټنې لاګ ته ورتلل';

  @override
  String get grpKTRoles => 'رولونه او اجازې';

  @override
  String get grpKTCreateWorkspace => 'کاري ځای جوړول';

  @override
  String get grpKTNotifPrefs => 'د خبرتیاوو غوره توبونه';

  @override
  String get grpKTDevices => 'ننوتي وسایل';

  @override
  String get grpKTChangePassword => 'پټنوم بدلول';

  @override
  String get grpKTTasks => 'دندې';

  @override
  String get grpKTSprints => 'سپرنټونه';

  @override
  String get grpKTAutomations => 'اتومات کارونه';

  @override
  String get grpKTWorkflow => 'د کار بهیر';

  @override
  String get grpKTCustomFields => 'ګمارل شوې ساحې';

  @override
  String get grpKTProjectSettings => 'د پروژې تنظیمات';

  @override
  String get grpKSwitchWs => 'کاري ځای بدلول';

  @override
  String get grpKSwitchWsSem => 'بل کاري ځای ته تلل';

  @override
  String get grpKToggleDark => 'تیاره حالت بدلول';

  @override
  String get grpKToggleDarkSem => 'د روښانه او تیاره بڼې ترمنځ بدلول';

  @override
  String get grpKCreateProject => 'پروژه جوړول';

  @override
  String get grpKCreateDoc => 'سند جوړول';

  @override
  String get grpKCreateDashboard => 'ډیشبورډ جوړول';

  @override
  String get grpKCreateSprint => 'سپرنټ جوړول';

  @override
  String get grpKCreateSprintSem => 'په دې پروژه کې سپرنټ جوړول';

  @override
  String get grpKInviteMember => 'غړی بلل';

  @override
  String get grpKInviteMemberSem => 'یو څوک دې کاري ځای ته بلل';

  @override
  String get grpKTImportExport => 'واردول او صادرول';

  @override
  String get grpKTOffline => 'آفلاین او ذخیره';

  @override
  String get grpKSignOut => 'وتل';

  @override
  String get grpKSignOutSem => 'له دې وسیلې وتل';

  @override
  String get grpKNewTask => 'نوې دنده';

  @override
  String get grpKNewTaskSem => 'په دې پروژه کې دنده جوړول';

  @override
  String get grpKRenameTask => 'د کرسر لاندې دنده نوم بدلول';

  @override
  String get grpKRenameTaskSem => 'په لیست کې د کرسر دنده نوم بدلول';

  @override
  String get grpKChangeStatus => 'د دې دندې حالت بدلول';

  @override
  String get grpKChangeStatusSem => 'د پرانیستې دندې حالت بدلول';

  @override
  String get grpKAssignMe => 'دا دنده ماته سپارل';

  @override
  String get grpKAssignMeSem => 'پرانیستې دنده ماته سپارل';

  @override
  String get grpKTimerStart => 'د دې دندې لپاره ټایمر پیلول';

  @override
  String get grpKTimerStartSem => 'د پرانیستې دندې ټایمر پیلول';

  @override
  String get grpKTimerStop => 'ټایمر ودرول';

  @override
  String get grpKTimerStopSem => 'روان ټایمر ودرول';

  @override
  String get grpKViewList => 'د لیست لید';

  @override
  String get grpKViewBoard => 'د تختې لید';

  @override
  String get grpKViewCalendar => 'د کلیز لید';

  @override
  String get grpKViewTimeline => 'د مهال ویش لید';

  @override
  String get grpKShowList => 'دا پروژه د لیست په توګه ښکاره کړئ';

  @override
  String get grpKShowBoard => 'دا پروژه د تختې په توګه ښکاره کړئ';

  @override
  String get grpKShowCalendar => 'دا پروژه د کلیز په توګه ښکاره کړئ';

  @override
  String get grpKShowTimeline => 'دا پروژه د مهال ویش په توګه ښکاره کړئ';

  @override
  String get grpLGeneric => 'یوه ستونزه رامنځته شوه. بیا هڅه وکړئ.';

  @override
  String get grpLNetCheck =>
      'سرور ته نه شي رسیدلی. خپل اتصال وګورئ او بیا هڅه وکړئ.';

  @override
  String get grpLNetCheckShort => 'سرور ته نه شو رسیدلی. خپل اتصال وګورئ.';

  @override
  String get grpLNetTry => 'سرور ته نه شو رسیدلی. بیا هڅه وکړئ.';

  @override
  String get grpLNetOffline =>
      'دا د سرور سره اتصال ته اړتیا لري. کله چې بیا آنلاین شئ، بیا به کار وکړي.';

  @override
  String get grpLNoConn => 'اتصال نشته. وګورئ او بیا هڅه وکړئ.';

  @override
  String get grpLNoPerm => 'تاسو اجازه نلرئ.';

  @override
  String get grpLNoPermDo => 'تاسو د دې کار اجازه نلرئ.';

  @override
  String get grpLNoAccess => 'تاسو ورته لاسرسی نلرئ.';

  @override
  String get grpLCheckValues => 'ارزښتونه وګورئ او بیا هڅه وکړئ.';

  @override
  String get grpLNotValid => 'دا اعتبار نلري.';

  @override
  String get grpLArchived =>
      'دا پروژه آرشیف شوې ده. د بدلونونو لپاره یې بیا فعاله کړئ.';

  @override
  String get grpLGone => 'دا نور شتون نلري.';

  @override
  String get grpLTaskConflict => 'بل چا لومړی دا دنده بدله کړې.';

  @override
  String get grpLTaskTransition => 'کاري جریان دا لیږد نه منی.';

  @override
  String get grpLTaskHasSubtasks =>
      'دې دندې فرعي دندې لري: وټاکئ چې څه به پرې کیږي.';

  @override
  String get grpLTaskCycle =>
      'یوه دنده نشي کولی د ځان یا د خپلو فرعي دندو فرعي دنده شي.';

  @override
  String grpLTaskBlocked(String detail) {
    return 'د $detail له امله بنده ده: لومړی هغه بشپړ کړئ.';
  }

  @override
  String grpLTaskLinkCycle(String detail) {
    return 'دا دندې به په یوه کړۍ کې یو بل بندې کړي: $detail.';
  }

  @override
  String get grpLTaskLinkExists =>
      'دا دندې مخکې له مخکې په همدې ډول تړل شوې دي.';

  @override
  String get grpLFieldRequired => 'یوه اړینه ساحه ارزښت نلري.';

  @override
  String get grpLTaskGone => 'دا دنده نور شتون نلري.';

  @override
  String get grpLCommentConflict => 'یو چا لومړی دا تبصره بدله کړې.';

  @override
  String get grpLCommentLocked => 'دا تبصره نور د سمون وړ نه ده.';

  @override
  String get grpLMentionNoAccess =>
      'یو څوک چې تاسو یادونه کړې دا دنده نشي لیدلی.';

  @override
  String get grpLCannotSeeSpace => 'دوی دا خبرې اتری نشي لیدلی';

  @override
  String grpLCannotSeeGrant(String names) {
    return '$names دا خبرې اتری نشي لیدلی. دوی اضافه کړئ او پیغام ولیږئ، یا یادونه لرې کړئ.';
  }

  @override
  String grpLCannotSeeRefuse(String names) {
    return '$names دا خبرې اتری نشي لیدلی، نو یادونه یې نشي کیدلی. یادونه لرې کړئ، یا له هغه چا وغواړئ چې یې اداره کوي چې دوی اضافه کړي.';
  }

  @override
  String get grpLCommentCheck => 'تبصره وګورئ او بیا هڅه وکړئ.';

  @override
  String get grpLCommentGone => 'دا تبصره نور شتون نلري.';

  @override
  String get grpLSlugTaken => 'دا یو آر ایل نیول شوی';

  @override
  String get grpLWsStale =>
      'دا کاري ځای بل ځای کې بدل شوی. وروستی نسخه لیدلو لپاره تازه کړئ.';

  @override
  String get grpLWsNotRestorable => 'دا کاري ځای نور بیا نشي رغول کېدی.';

  @override
  String get grpLOwnerNeeded => 'یو کاري ځای لږ تر لږه یو مالک ته اړتیا لري.';

  @override
  String get grpLInvEmailMismatch => 'دا بلنه د بل بریښنالیک پتې لپاره ده.';

  @override
  String get grpLInvExpired => 'دا بلنه پای ته رسیدلې. نوې بلنه وغواړئ.';

  @override
  String get grpLInvRevoked => 'دا بلنه لغوه شوې.';

  @override
  String get grpLInvBeforeRemoval =>
      'دا بلنه ستاسو له لرې کېدو دمخه ده. نوې بلنه وغواړئ.';

  @override
  String get grpLInvUsedUp => 'دا بلنه مخکې کارول شوې او ختمه شوې.';

  @override
  String get grpLInvNotFound => 'دا بلنه شتون نلري.';

  @override
  String get grpLInvRate =>
      'همدا اوس ډیرې بلنې دي. لږ انتظار وکړئ او بیا هڅه وکړئ.';

  @override
  String get grpLInvExists => 'دا کس مخکې بلل شوی یا غړی دی.';

  @override
  String get grpLWfInvalid =>
      'کاري جریان ستونزې لري. د خوندي کولو لپاره یې حل کړئ.';

  @override
  String get grpLWfConflict =>
      'بل چا لومړی کاري جریان خوندي کړ. ستاسو بدلونونه لا دلته دي: بدلونونه وګورئ او بیا خوندي کړئ.';

  @override
  String get grpLProjectGone => 'دا پروژه نور شتون نلري.';

  @override
  String get grpLDashDenied => 'تاسو په دې ډشبورډ کې د دې کار اجازه نلرئ.';

  @override
  String get grpLDashNotFound => 'دا ډشبورډ یا ویجټ شتون نلري.';

  @override
  String get grpLDashHeavy =>
      'د دې ویجټ محاسبه ډیر وخت نیسي. فلټر یې محدود کړئ.';

  @override
  String get grpLDashConflict =>
      'بل چا دا ډشبورډ بدل کړ. بیا یې بار کړئ او بیا هڅه وکړئ.';

  @override
  String get grpLNotifGone => 'دا خبرتیا نور شتون نلري.';

  @override
  String get grpLViewConflict => 'بل چا لومړی دا ترتیب بدل کړ.';

  @override
  String get grpLViewInvalid => 'دا ترتیب اعتبار نلري.';

  @override
  String get grpLViewNameTaken => 'د دې نوم ترتیب مخکې شتون لري.';

  @override
  String get grpLViewLimit => 'دا ډیر ترتیبونه دي چې دلته یې ساتلی شئ.';

  @override
  String get grpLViewGone => 'دا ترتیب نور شتون نلري.';

  @override
  String get grpLAutoDenied =>
      'د دې لپاره تاسو ته د «د اتومات کارونو مدیریت» اجازه پکار ده.';

  @override
  String get grpLAutoConflict =>
      'بل چا لومړی دا قاعده بدله کړه. وروستۍ نسخه بار کړئ او بیا هڅه وکړئ.';

  @override
  String get grpLImpCannot => 'دا همدا اوس نشي کېدی.';

  @override
  String get grpLImpTooBig => 'دا فایل له هغه څخه لوی دی چې دا سرور یې مني.';

  @override
  String get grpLImpDenied => 'یوازې مدیران کولی شي معلومات واردوي او صادروي.';

  @override
  String get grpLImpNotFound => 'دا واردول نور شتون نلري.';

  @override
  String get grpLAuditDenied => 'تاسو د پلټنې ثبت لوستلو اجازه نلرئ.';

  @override
  String get grpLAuditTaskNA => 'دا دنده شتون نلري.';

  @override
  String get grpLAuditFilters => 'دا فلټرونه اعتبار نلري.';

  @override
  String get grpLSprintConflict =>
      'بل چا لومړی دا بدل کړ. بیا بار کړئ او بیا هڅه وکړئ.';

  @override
  String get grpLFieldNameTaken => 'د دې نوم ساحه مخکې شتون لري.';

  @override
  String grpLFieldLimit(int count) {
    return 'یوه پروژه ډیر تر ډیره $count فعالې ساحې لرلی شي.';
  }

  @override
  String get grpLFieldNeedsRemap =>
      'ځینې لرې شوي انتخابونه لا کارول کیږي: وټاکئ چې ارزښتونه یې څه شي.';

  @override
  String get grpLFieldConflict =>
      'بل چا لومړی دا ساحه بدله کړه؛ بیا بار کړئ او بیا هڅه وکړئ.';

  @override
  String get grpLFieldGone => 'دا ساحه نور شتون نلري.';

  @override
  String get grpLFilterInvalid => 'دا فلټر اعتبار نلري.';

  @override
  String get grpLFilterNameTaken => 'دلته د دې نوم فلټر مخکې شتون لري.';

  @override
  String get grpLFilterLimit => 'دا ډیر فلټرونه دي چې دلته یې ساتلی شئ.';

  @override
  String get grpLFilterGone => 'دا فلټر نور شتون نلري.';

  @override
  String get grpLFilterConflict => 'بل چا لومړی دا فلټر بدل کړ.';

  @override
  String get grpLAttTooBig => 'دا فایل له هغه څخه لوی دی چې ضمیمه یې کېدی شي.';

  @override
  String get grpLAttQuota => 'دا کاري ځای خپل ټول ذخیره کارولی.';

  @override
  String get grpLAttTooMany =>
      'ډیر پورته کولو پرانیستل شوي دي. لومړی ځینې بشپړ یا لغوه کړئ.';

  @override
  String get grpLAttUnavailable =>
      'فایل همدا اوس نه شو کتل کېدی. بیا هڅه وکړئ.';

  @override
  String get grpLAttChunk => 'د فایل یوه برخه ونه منل شوه. بیا هڅه وکړئ.';

  @override
  String get grpLAttRefusedPlain => 'دا ډول فایل نه منل کیږي.';

  @override
  String grpLAttRefused(String detail) {
    return 'دا فایل نه منل کیږي: $detail';
  }

  @override
  String get grpLAttIncomplete => 'پورته کول بشپړ نشول. بیا هڅه وکړئ.';

  @override
  String get grpLAttExpired => 'دا پورته کول پای ته ورسیدل. بیا هڅه وکړئ.';

  @override
  String get grpLAttUnreadable => 'دا فایل ونه لوستل شو.';

  @override
  String get grpLAttNotAllowed => 'تاسو د دې کار اجازه نلرئ.';

  @override
  String get grpLAttArchived =>
      'دا پروژه آرشیف شوې ده: فایلونه یوازې د لوستلو دي.';

  @override
  String get grpLAttGone => 'دا لرې شوی: فایل، تبصره یا دنده لرې شوې ده.';

  @override
  String get grpLDocNotFound => 'دا پاڼه شتون نلري یا تاسو یې نشئ خلاصولی.';

  @override
  String get grpLDocConflict => 'بل چا لومړی دا پاڼه بدله کړه.';

  @override
  String get grpLDocArchived => 'دا پاڼه آرشیف شوې ده.';

  @override
  String get grpLDocCycle => 'یوه پاڼه نشي کولی د ځان لاندې شي.';

  @override
  String get grpLKeyTaken => 'دا کیلي مخکې د بلې پروژې له خوا کارول شوې.';

  @override
  String get grpLKeyLocked => 'کله چې پروژه دندې ولري، کیلي نشي بدلېدی.';

  @override
  String get grpLLastMember => 'یوه خصوصي پروژه لږ تر لږه یو غړي ته اړتیا لري.';

  @override
  String get grpLProjConflict =>
      'دا پروژه په دې موده کې بدله شوه. بیا بار شوه — بیا هڅه وکړئ.';

  @override
  String get grpLRoleBuiltin => 'جوړ شوي رولونه نشي بدلېدی یا ړنګېدی.';

  @override
  String get grpLRoleNameTaken => 'د دې نوم رول مخکې شتون لري.';

  @override
  String get grpLRoleGone => 'دا رول نور شتون نلري.';

  @override
  String get grpLRoleConflict =>
      'دا رول په دې موده کې بدل شو. بیا بار شو — بیا هڅه وکړئ.';

  @override
  String get grpLRepeatInvalid => 'دا تکرار اعتبار نلري.';

  @override
  String get grpLRepeatDenied => 'تاسو د دې د تکرار د بدلولو اجازه نلرئ.';

  @override
  String get grpMPriUrgent => 'بيړني';

  @override
  String get grpMPriHigh => 'لوړ';

  @override
  String get grpMPriNormal => 'عادي';

  @override
  String get grpMPriLow => 'ټیټ';

  @override
  String get grpMPriNone => 'هیڅ';

  @override
  String get grpMLinkBlocks => 'بندوي';

  @override
  String get grpMLinkBlockedBy => 'بندیږي د خوا';

  @override
  String get grpMLinkRelates => 'اړوند له';

  @override
  String get grpMLinkDuplicates => 'تکرار دی';

  @override
  String get grpMLinkDuplicatedBy => 'تکرار شوی د خوا';

  @override
  String get grpMCatNotStarted => 'نه دی پیل شوی';

  @override
  String get grpMCatActive => 'فعال';

  @override
  String get grpMCatDone => 'سرته رسېدلی';

  @override
  String get grpMCatCancelled => 'لغوه شوی';

  @override
  String get grpMFtypeText => 'متن';

  @override
  String get grpMFtypeNumber => 'شمېره';

  @override
  String get grpMFtypeSelect => 'غوراوی';

  @override
  String get grpMFtypeMulti => 'څو غوراوی';

  @override
  String get grpMFtypeDate => 'نېټه';

  @override
  String get grpMFtypeCheckbox => 'چک‌بکس';

  @override
  String get grpMFtypeUrl => 'لینک';

  @override
  String get grpMFtypeUser => 'کارن';

  @override
  String get grpMFtypeMoney => 'پیسې';

  @override
  String get grpMTrigTaskCreated => 'یو کار جوړ شي';

  @override
  String get grpMTrigStatusChanged => 'حالت بدل شي';

  @override
  String get grpMTrigFieldChanged => 'ساحه بدله شي';

  @override
  String get grpMTrigAssigned => 'یو څوک وګمارل شي';

  @override
  String get grpMTrigDueDateReached => 'د پای نېټه ورسیږي';

  @override
  String get grpMTrigCommentAdded => 'یو نظر زیات شي';

  @override
  String get grpMActSetField => 'یوه ساحه تنظیمول';

  @override
  String get grpMActSetStatus => 'حالت تنظیمول';

  @override
  String get grpMActSetAssignee => 'ګمارل شوي بدلول';

  @override
  String get grpMActAddComment => 'نظر زیاتول';

  @override
  String get grpMActCreateSubtask => 'فرعي کار جوړول';

  @override
  String get grpMActNotify => 'خلکو ته خبرتیا ورکول';

  @override
  String get grpMActWebhook => 'ویب‌هوک کالول';

  @override
  String get grpMRunSucceeded => 'بریالی';

  @override
  String get grpMRunFailed => 'ناکام';

  @override
  String get grpMRunSkippedCondition => 'پرېښودل شو: شرط';

  @override
  String get grpMRunSkippedLoop => 'ودرول شو: ګرځنده';

  @override
  String get grpMRunSkippedRate => 'ځنډول شو: ډېر اجراات';

  @override
  String get grpMWkNumber => 'شمېره';

  @override
  String get grpMWkBar => 'میلې چارټ';

  @override
  String get grpMWkLine => 'کرښنی چارټ';

  @override
  String get grpMWkPie => 'دایروي چارټ';

  @override
  String get grpMWkTable => 'جدول';

  @override
  String get grpMWkBurndown => 'برن‌ډاون';

  @override
  String get grpMWkWorkload => 'د کار بار';

  @override
  String get grpMMeasCount => 'د کارونو شمېر';

  @override
  String get grpMMeasPoints => 'د کیسې نقطې';

  @override
  String get grpMMeasEstimateHours => 'اټکل شوي ساعتونه';

  @override
  String get grpMMeasLoggedHours => 'ثبت شوي ساعتونه';

  @override
  String get grpMMeasCycleDays => 'د دورې وخت (ورځې)';

  @override
  String get grpMScopeAll => 'ټول کارونه';

  @override
  String get grpMScopeOpen => 'پرانیستي کارونه';

  @override
  String get grpMScopeDone => 'سرته رسېدلي کارونه';

  @override
  String get grpMVisPersonal => 'یوازې زه';

  @override
  String get grpMVisProject => 'په پروژه کې ټول';

  @override
  String get grpMVisWorkspace => 'په کارځای کې ټول';

  @override
  String get grpMLblStatus => 'حالت';

  @override
  String get grpMLblStatusCategory => 'د حالت کټه‌ګورۍ';

  @override
  String get grpMLblPerson => 'کس';

  @override
  String get grpMLblPriority => 'لومړیتوب';

  @override
  String get grpMLblProject => 'پروژه';

  @override
  String get grpMLblSprint => 'سپرنټ';

  @override
  String get grpMLblCreatedDay => 'جوړ شوی (ورځ)';

  @override
  String get grpMLblCreatedWeek => 'جوړ شوی (اونۍ)';

  @override
  String get grpMLblDueWeek => 'پای نېټه (اونۍ)';

  @override
  String get grpMImpJiraCsv => 'Jira (د CSV صادرول)';

  @override
  String get grpMImpJiraJson => 'Jira (JSON)';

  @override
  String get grpMImpClickupCsv => 'ClickUp (د CSV صادرول)';

  @override
  String get grpMImpClickupJson => 'ClickUp (JSON)';

  @override
  String get grpMImpCsv => 'هر CSV فایل';

  @override
  String get grpMImpTaskforge => 'د TaskForge صادرول (tasks.json)';

  @override
  String get grpMNkAssigned => 'تاسو ته ګمارل شوی';

  @override
  String get grpMNkMentioned => 'یادونې';

  @override
  String get grpMNkCommented => 'نظرونه';

  @override
  String get grpMNkStatusChanged => 'د حالت بدلونونه';

  @override
  String get grpMNkDueSoon => 'ژر پای نېټه';

  @override
  String get grpMNkTimerLong => 'اوږده ټایمرونه';

  @override
  String get grpMNkUnknown => 'خبرتیا';

  @override
  String get grpMIfAll => 'ټول';

  @override
  String get grpMIfUnread => 'ناسترګې شوي';

  @override
  String get grpMIfMentions => 'یادونې';

  @override
  String get grpMIfAssigned => 'ګمارل شوي';

  @override
  String get grpMIfSnoozed => 'ځنډول شوي';

  @override
  String get grpMIfArchived => 'آرشیف شوي';

  @override
  String get grpMEmOff => 'بند';

  @override
  String get grpMEmInstant => 'سمدستي';

  @override
  String get grpMEmDigest => 'ورځنی لنډیز';

  @override
  String get grpMRkSchedule => 'د مهال‌ویش له مخې';

  @override
  String get grpMRkAfterCompletion => 'وروسته له بشپړېدو';

  @override
  String get grpMLblOpEq => 'دی';

  @override
  String get grpMLblOpNe => 'نه دی';

  @override
  String get grpMLblOpLt => 'مخکې / له ... لږ';

  @override
  String get grpMLblOpLte => 'په یا مخکې / تر ټولو ډېر';

  @override
  String get grpMLblOpGt => 'وروسته / له ... ډېر';

  @override
  String get grpMLblOpGte => 'په یا وروسته / لږ تر لږه';

  @override
  String get grpMLblOpContains => 'لري';

  @override
  String get grpMLblOpNotContains => 'نه لري';

  @override
  String get grpMLblOpIn => 'یو له';

  @override
  String get grpMLblOpNotIn => 'هیڅ یو له';

  @override
  String get grpMLblOpEmpty => 'تش دی';

  @override
  String get grpMLblOpNotEmpty => 'تش نه دی';

  @override
  String get grpMLblAssignee => 'ګمارل شوی';

  @override
  String get grpMLblStart => 'پیل';

  @override
  String get grpMLblDue => 'پای نېټه';

  @override
  String get grpMLblCreated => 'جوړ شوی';

  @override
  String get grpMLblUpdated => 'تازه شوی';

  @override
  String get grpMLblDueDate => 'د پای نېټه';

  @override
  String get grpMLblProgress => 'د فرعي کارونو پرمختګ';

  @override
  String get grpMLblViewList => 'لیست';

  @override
  String get grpMLblViewBoard => 'تخته';

  @override
  String get grpMLblViewCalendar => 'کلیز';

  @override
  String get grpMLblViewTimeline => 'مهال کرښه';

  @override
  String get grpMRelNow => 'اوس';

  @override
  String get grpMRelJustNow => 'همدا اوس';

  @override
  String grpMRelMin(int n) {
    return '$n دقیقې مخکې';
  }

  @override
  String grpMRelHour(int n) {
    return '$n ساعته مخکې';
  }

  @override
  String get grpMRelYesterday => 'پرون';

  @override
  String grpMRelDay(int n) {
    return '$n ورځې مخکې';
  }

  @override
  String get grpMNotifSomeone => 'یو څوک';

  @override
  String grpMNotifAssigned(String who) {
    return '$who تاسو ته وګمارل:';
  }

  @override
  String grpMNotifMentioned(String who) {
    return '$who تاسو په دې کې یاد کړل:';
  }

  @override
  String grpMNotifCommented(String who) {
    return '$who په دې نظر ورکړ:';
  }

  @override
  String grpMNotifStatusChanged(String who) {
    return '$who د حالت بدلون وکړ:';
  }

  @override
  String grpMNotifMoved(String who, String fromStatus, String toStatus) {
    return '$who له $fromStatus څخه $toStatus ته واړاوه';
  }

  @override
  String get grpMNotifDueSoon => 'ژر پای نېټه:';

  @override
  String get grpMNotifTimer => 'ستاسو ټایمر لا هم روان دی:';

  @override
  String get grpMNotifNew => 'نوې فعالیت په:';

  @override
  String get grpMUnitDay => 'ورځ';

  @override
  String get grpMUnitDays => 'ورځې';

  @override
  String get grpMUnitWeek => 'اونۍ';

  @override
  String get grpMUnitWeeks => 'اونۍ';

  @override
  String get grpMUnitMonth => 'میاشت';

  @override
  String get grpMUnitMonths => 'میاشتې';

  @override
  String get grpMUnitYear => 'کال';

  @override
  String get grpMUnitYears => 'کلونه';

  @override
  String get grpMSlashText => 'متن';

  @override
  String get grpMSlashH1 => 'سرلیک ۱';

  @override
  String get grpMSlashH2 => 'سرلیک ۲';

  @override
  String get grpMSlashH3 => 'سرلیک ۳';

  @override
  String get grpMSlashBullet => 'نقطه‌ایز لیست';

  @override
  String get grpMSlashNumbered => 'شمېرلړ لیست';

  @override
  String get grpMSlashTodo => 'د کتنې لیست';

  @override
  String get grpMSlashQuote => 'نقل قول';

  @override
  String get grpMSlashCode => 'کوډ';

  @override
  String get grpMSlashTable => 'جدول';

  @override
  String get grpMSlashDivider => 'جلا کوونکی';

  @override
  String get grpMSlashImage => 'انځور';

  @override
  String get grpMSlashCallout => 'یادونه';

  @override
  String get grpMSlashTask => 'د کار کارت';

  @override
  String get grpMMeanSucceeded => 'ټول عملونه اجرا شول.';

  @override
  String get grpMMeanFailed =>
      'یو عمل ناکام شو؛ مخکني عملونه سرته رسېدلي پاتې کېږي.';

  @override
  String get grpMMeanSkippedCondition =>
      'پېښه برابره وه، خو کار شرط نه پوره کړ.';

  @override
  String get grpMMeanSkippedLoop =>
      'قاعدو له ۵ زیاتو پړاوونو پورې نورې قاعدې فعالې کړې، نو دا اجرا د ګرځنده ختمولو لپاره ودرول شوه.';

  @override
  String get grpMMeanSkippedRate =>
      'دا قاعده په تېرې دقیقې کې ۳۰ ځله اجرا شوې وه، نو دا اجرا پرېښودل شوه.';

  @override
  String get grpMStepOk => 'بریالی';

  @override
  String get grpMStepFailed => 'ناکام';

  @override
  String get grpMStepNotRun => 'نه دی اجرا شوی';

  @override
  String get grpMStepPlanned => 'پلان شوی';

  @override
  String get grpMStepWouldFail => 'ناکامېده';

  @override
  String get grp1DropCardHere => 'یو کارت دلته پرېږدئ';

  @override
  String get grp1NoCards => 'کارتونه نشته';

  @override
  String get grp1StopWatchingTask => 'د دې دندې تعقیب بند کړئ';

  @override
  String get grp1WatchTask => 'دا دنده تعقیب کړئ';

  @override
  String get grp1SecondFactorRequired => 'دویم فکتور اړین دی.';

  @override
  String get grp1AnAutomation => 'یوه اتومات';

  @override
  String get grp1TheSystem => 'سیسټم';

  @override
  String grp1MemberCount(int count) {
    return '$count غړی';
  }

  @override
  String get grp1SyncLive => 'ژوندی';

  @override
  String get grp1SyncConnecting => 'نښلول کیږي…';

  @override
  String get grp1SyncReconnecting => 'بیا نښلول کیږي…';

  @override
  String get grp1SyncLiveTip => 'د نورو بدلونونه هماغه وخت ښکاري';

  @override
  String get grp1SyncNotLiveTip =>
      'ژوندی نه: د نورو بدلونونه د بیا نښلولو وروسته ښکاري';

  @override
  String get grp1EnterNumber => 'یو شمېره ولیکئ.';

  @override
  String get grp1EnterAmount => 'یوه اندازه ولیکئ.';

  @override
  String get grp1EnterCurrency => 'د ۳ توریو اسعار ولیکئ، لکه USD.';

  @override
  String get grp1EnterUrl => 'یوه ویب پته ولیکئ چې په http(s):// پیل شي';

  @override
  String get grp1UseIsoDate => 'د YYYY-MM-DD بڼه وکاروئ.';

  @override
  String get taskAddHint => 'یو کار اضافه کړئ او Enter کېکاږئ';

  @override
  String grpRMnAdded(String name) {
    return 'د بل چا لخوا ورزیاته شو: $name.';
  }

  @override
  String grpRMnKept(String name) {
    return '$name وساتل شو: تاسو حذف کړ، خو بل چا مخکې بدل کړ. که لا هم غواړئ، بیا یې حذف کړئ.';
  }

  @override
  String grpRMnDeleted(String name) {
    return 'د بل چا لخوا حذف شو: $name.';
  }

  @override
  String grpRMnDeletedEdited(String name) {
    return 'د بل چا لخوا حذف شو: $name. ستاسو بدلونونه پرېښودل شول.';
  }

  @override
  String grpRMnFieldAdopted(String what, String status, String value) {
    return 'بل چا د «$status» $what په $value بدل کړ.';
  }

  @override
  String grpRMnFieldDropped(
    String what,
    String status,
    String mine,
    String value,
  ) {
    return 'ستاسو د «$status» د $what بدلون ($mine) پرېښودل شو: بل چا هغه په $value بدل کړ.';
  }

  @override
  String grpRMnSwitchAdopted(String what, String state) {
    return 'بل چا «$what» $state کړ.';
  }

  @override
  String grpRMnSwitchDropped(String what, String state) {
    return 'ستاسو د «$what» بدلون پرېښودل شو: بل چا هغه $state کړ.';
  }

  @override
  String get grpRMnOrderDropped =>
      'ستاسو د حالتونو نوی ترتیب پرېښودل شو: بل چا هم هغوی بیا ترتیب کړل.';

  @override
  String get grpRMnReordered => 'بل چا حالتونه بیا ترتیب کړل.';

  @override
  String grpRMnMigrationLost(String name) {
    return 'هغه حالت چې تاسو د «$name» دندو لپاره غوره کړ د بل چا لخوا حذف شو: د هغو لپاره بل ځای غوره کړئ.';
  }

  @override
  String get grpRMnDeletedStatus => 'یوه حذف شوې حالت';

  @override
  String grpRMnMoveAllowed(String name) {
    return 'بل چا د $name لېږدول اجازه کړل.';
  }

  @override
  String grpRMnMoveRemoved(String name) {
    return 'بل چا د $name لېږدول لرې کړل.';
  }

  @override
  String grpRMnConditionsAdopted(String name) {
    return 'بل چا د $name د لېږدولو شرطونه بدل کړل.';
  }

  @override
  String grpRMnConditionsDropped(String name) {
    return 'ستاسو د $name د لېږدولو د شرطونو بدلون پرېښودل شو: بل چا هم هغه بدل کړل.';
  }

  @override
  String grpRMnMovesDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ستاسو $count لېږدولونه پرېښودل شول ځکه چې هغه حالت چې کارولو یې له منځه تللی دی.',
      one: 'ستاسو یو لېږدول پرېښودل شو ځکه چې هغه حالت چې کارولو یې له منځه تللی دی.',
    );
    return '$_temp0';
  }

  @override
  String get grpRMnWhatName => 'نوم';

  @override
  String get grpRMnWhatColour => 'رنګ';

  @override
  String get grpRMnWhatCategory => 'کټګوري';

  @override
  String get grpRMnWhatDefault => 'تلواله';

  @override
  String get grpRMnNone => 'هیڅ';

  @override
  String get grpRMnIsDefault => 'تلواله';

  @override
  String get grpRMnNotDefault => 'نه تلواله';

  @override
  String get grpRMnOn => 'چالان';

  @override
  String get grpRMnOff => 'بند';

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
  String get grpRKeySpace => 'تشه';

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
  String get grpRCmForbidden => 'تاسو نور پر دې دنده نظر نشئ ورکولی.';

  @override
  String get grpRCmGone => 'دنده حذف شوه.';

  @override
  String get grpRCmArchived => 'پروژه ارشیف شوه.';

  @override
  String get grpRCmInvalid => 'نظر معتبر نه دی.';

  @override
  String get grpRCmMention => 'یو یادشوی کس دا دنده نشي لیدلی.';

  @override
  String get grpRCmRefused => 'سرور نظر رد کړ.';

  @override
  String grpRDependsRefused(String reason) {
    return 'دا په یو بدلون پورې اړه لري چې رد شو: $reason';
  }

  @override
  String get grpRKeepUnreadable => 'ولوستل نشو. بیا هڅه وکړئ.';

  @override
  String grpRDenyNeed(String permission) {
    return 'تاسو ته د «$permission» اجازه ضروري ده';
  }

  @override
  String grpRDenyNeedRole(String permission, String role) {
    return 'تاسو ته د «$permission» اجازه ضروري ده — ستاسو رول $role دی';
  }

  @override
  String get grpRRequestFailed => 'غوښتنه ناکامه شوه.';

  @override
  String get grpRUnitB => 'بایټ';

  @override
  String get grpRUnitKB => 'کیلوبایټ';

  @override
  String get grpRUnitMB => 'میګابایټ';

  @override
  String get grpRUnitGB => 'ګیګابایټ';

  @override
  String get grpRUnitTB => 'ترابایټ';

  @override
  String grpRStorageOf(String used, String quota) {
    return '$used له $quota څخه کارول شوي';
  }

  @override
  String grpRStorageUsed(String used) {
    return '$used کارول شوي';
  }

  @override
  String grpRChartBars(String label, int count) {
    return '$label، $count ستنې';
  }

  @override
  String grpRChartSlices(String label, int count) {
    return '$label، $count ټوټې';
  }

  @override
  String grpRChartLines(String label, int lines, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines کربې',
      one: '۱ کربه',
    );
    return '$label، $_temp0، $points نقطې';
  }

  @override
  String grpRChartPercent(String label, String shown, int percent) {
    return '$label، $shown، $percent سلنه';
  }

  @override
  String get grpRAuCreated => 'دا دنده یې جوړه کړه';

  @override
  String get grpRAuTrashed => 'دا دنده یې کثافاتو ته واړوله';

  @override
  String get grpRAuRestored => 'دا دنده یې بیرته راوستله';

  @override
  String grpRAuStatus(String from, String to) {
    return 'حالت یې له $from څخه $to ته بدل کړ';
  }

  @override
  String grpRAuAssigned(String names) {
    return '$names ته یې وسپارله';
  }

  @override
  String grpRAuUnassigned(String names) {
    return 'د $names سپارنه یې لغوه کړه';
  }

  @override
  String grpRAuAnd(String a, String b) {
    return '$a او $b';
  }

  @override
  String get grpRAuCommented => 'نظر یې ورکړ';

  @override
  String get grpRAuCommentEdited => 'یو نظر یې سم کړ';

  @override
  String get grpRAuCommentDeleted => 'یو نظر یې حذف کړ';

  @override
  String grpRAuReacted(String emoji) {
    return 'پر یو نظر یې د $emoji غبرګون وښود';
  }

  @override
  String grpRAuUnreacted(String emoji) {
    return 'له یو نظر څخه یې $emoji بیرته واخیست';
  }

  @override
  String grpRAuAttached(String file) {
    return '$file یې ضمیمه کړ';
  }

  @override
  String grpRAuFileRemoved(String file) {
    return 'فایل $file یې لرې کړ';
  }

  @override
  String get grpRAuTimeLogged => 'وخت یې ثبت کړ';

  @override
  String get grpRAuTimeUpdated => 'د وخت یو ننوتنه یې تازه کړه';

  @override
  String get grpRAuTimeDeleted => 'د وخت یو ننوتنه یې حذف کړه';

  @override
  String grpRAuLinked(String type, String task) {
    return '$type $task یې وتاره';
  }

  @override
  String get grpRAuLinkRemoved => 'یو لینک یې لرې کړ';

  @override
  String get grpRAuFieldSet => 'یوه دودیزه ساحه یې تنظیم کړه';

  @override
  String get grpRAuDocLinked => 'یوه پاڼه یې وتړله';

  @override
  String get grpRAuDocUnlinked => 'د یوې پاڼې تړاو یې لرې کړ';

  @override
  String get grpRAuEdited => 'دا دنده یې سمه کړه';

  @override
  String grpRAuChanged(String parts) {
    return '$parts یې بدل کړل';
  }

  @override
  String grpRAuPart(String label, String from, String to) {
    return '$label $from ← $to';
  }

  @override
  String get grpRAuSomething => 'یو کار یې وکړ';

  @override
  String get grpRAuFStatus => 'حالت';

  @override
  String get grpRAuFSprint => 'سپرینټ';

  @override
  String get grpRAuFParent => 'مورنۍ دنده';

  @override
  String get grpRAuFDueDate => 'د پای نیټه';

  @override
  String get grpRAuFDueTime => 'د پای وخت';

  @override
  String get grpRAuFStartDate => 'د پیل نیټه';

  @override
  String get grpRAuFEstimate => 'اټکل';

  @override
  String get devTitle => 'پراختیاګر';

  @override
  String get devSub => 'د API ټوکنونه او ویب‌هوکونه';

  @override
  String get devTokensTab => 'د API ټوکنونه';

  @override
  String get devWebhooksTab => 'ویب‌هوکونه';

  @override
  String get devTokenNew => 'نوی ټوکن';

  @override
  String get devTokenName => 'نوم';

  @override
  String get devTokenScopes => 'څه کولی شي';

  @override
  String get devTokenExpiry => 'پای ته رسېږي';

  @override
  String get devExpiryNever => 'هېڅکله';

  @override
  String get devExpiry30 => 'په ۳۰ ورځو کې';

  @override
  String get devExpiry90 => 'په ۹۰ ورځو کې';

  @override
  String get devExpiry365 => 'په یو کال کې';

  @override
  String get devTokenCreate => 'ټوکن جوړ کړئ';

  @override
  String get devTokenCreatedTitle => 'ټوکن همدا اوس کاپي کړئ';

  @override
  String get devTokenCreatedBody =>
      'دا یوازینی ځل دی چې ښودل کېږي. په خوندي ځای کې یې وساتئ.';

  @override
  String get devCopy => 'کاپي';

  @override
  String get devCopied => 'کاپي شو';

  @override
  String get devDone => 'بشپړ';

  @override
  String devTokenPrefix(String prefix) {
    return 'په $prefix پیلېږي';
  }

  @override
  String get devTokenNeverUsed => 'هېڅکله نه دی کارول شوی';

  @override
  String devTokenUsed(String when) {
    return 'وروستی کارونه $when';
  }

  @override
  String get devTokenActive => 'فعال';

  @override
  String get devTokenExpired => 'پای ته رسېدلی';

  @override
  String get devTokenRevoked => 'لغوه شوی';

  @override
  String get devTokenRevoke => 'لغوه کړئ';

  @override
  String devTokenRevokeTitle(String name) {
    return '«$name» لغوه شي؟';
  }

  @override
  String get devTokenRevokeBody => 'هر څه چې دا ټوکن کاروي سمدستي کار بندوي.';

  @override
  String get devTokensEmpty => 'تر اوسه ټوکن نشته.';

  @override
  String get devTokensHint =>
      'ټوکن هغه څه کولی شي چې تاسو یې کولی شئ، د ټاکل شویو اجازو پورې محدود. یوازې پدې کاري ځای کې کار کوي.';

  @override
  String get devWebhookNew => 'نوی ویب‌هوک';

  @override
  String get devWebhookEdit => 'ویب‌هوک سمول';

  @override
  String get devWebhookName => 'نوم (اختیاري)';

  @override
  String get devWebhookUrl => 'پته';

  @override
  String get devWebhookEvents => 'پیښې';

  @override
  String get devWebhookSave => 'خوندي کړئ';

  @override
  String get devWebhookActive => 'فعال';

  @override
  String get devWebhookSecret => 'د لاسلیک راز';

  @override
  String get devWebhookTest => 'ازموینه ولېږئ';

  @override
  String devWebhookTestDone(String status) {
    return 'ازموینه ولېږل شوه: $status';
  }

  @override
  String get devWebhookDeliveries => 'لېږدونه';

  @override
  String get devWebhookDelete => 'ړنګ کړئ';

  @override
  String devWebhookDeleteTitle(String name) {
    return '«$name» ړنګ شي؟';
  }

  @override
  String get devWebhookDeleteBody => 'د لېږدونو لاګ به هم ړنګ شي.';

  @override
  String get devWebhooksEmpty => 'تر اوسه ویب‌هوک نشته.';

  @override
  String get devWebhooksDenied =>
      'دا یوازې هغه کسان ګوري چې ویب‌هوکونه اداره کولی شي.';

  @override
  String devWebhookOff(String reason) {
    return 'بند شو: $reason';
  }

  @override
  String get devWebhookHint =>
      'هره پیښه د لاسلیک شوي POST په توګه لېږل کېږي. اخیستونکی لاسلیک د رازه سره تاییدوي.';

  @override
  String get devDeliveriesTitle => 'لېږدونه';

  @override
  String get devDeliveriesEmpty => 'تر اوسه هېڅ نه دي لېږل شوي.';

  @override
  String get devStatusDelivered => 'وسپارل شو';

  @override
  String get devStatusPending => 'په تمه';

  @override
  String get devStatusFailed => 'ناکام، بیا به هڅه وشي';

  @override
  String get devStatusGaveUp => 'پرېښودل شو';

  @override
  String devAttempt(int n) {
    return 'هڅه $n';
  }

  @override
  String get devRequest => 'غوښتنه';

  @override
  String get devResponse => 'ځواب';

  @override
  String get devHeaders => 'سرلیکونه';

  @override
  String get devBody => 'منځپانګه';

  @override
  String get devResend => 'بیا ولېږئ';

  @override
  String devResent(String status) {
    return 'بیا ولېږل شو: $status';
  }

  @override
  String devNextTry(String when) {
    return 'بله هڅه $when';
  }

  @override
  String get devLoadMore => 'نور پورته کړئ';

  @override
  String get devRetry => 'بیا هڅه وکړئ';

  @override
  String get devDenied => 'تاسو دلته دا نشئ کولی.';

  @override
  String get devScopeWorkspacesRead => 'کاري ځای کتل';

  @override
  String get devScopeProjectsRead => 'پروژې لوستل';

  @override
  String get devScopeProjectsWrite => 'پروژې جوړول او بدلول';

  @override
  String get devScopeTasksRead => 'دندې لوستل';

  @override
  String get devScopeTasksWrite => 'دندې جوړول، بدلول او ړنګول';

  @override
  String get devScopeCommentsRead => 'نظرونه لوستل';

  @override
  String get devScopeCommentsWrite => 'نظرونه لیکل';

  @override
  String get devEventTaskCreated => 'دنده جوړه شي';

  @override
  String get devEventTaskUpdated => 'دنده سمه شي';

  @override
  String get devEventTaskStatus => 'د دندې حالت بدل شي';

  @override
  String get devEventTaskAssigned => 'کسان دندې ته وټاکل شي';

  @override
  String get devEventTaskDeleted => 'دنده ړنګه شي';

  @override
  String get devEventCommentCreated => 'نظر اضافه شي';

  @override
  String get devEventCommentUpdated => 'نظر سم شي';

  @override
  String get devEventCommentDeleted => 'نظر ړنګ شي';

  @override
  String get devEventPing => 'د ازموینې پیښه';

  @override
  String get formsTitle => 'فورمې';

  @override
  String get formsSub => 'عامې فورمې چې کارونه جوړوي';

  @override
  String get formsHint =>
      'د فورمې لینک ورکړئ چې د کاري ځای بهر خلک کار درولېږي. حساب ته اړتیا نشته.';

  @override
  String get formsEmpty => 'تر اوسه فورمه نشته.';

  @override
  String get formsNew => 'نوې فورمه';

  @override
  String get formsEdit => 'فورمه سمول';

  @override
  String get formsPickProject => 'کارونه کوم پروژې ته لاړ شي؟';

  @override
  String formsSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لیږنې',
    );
    return '$_temp0';
  }

  @override
  String get formsCopyLink => 'لینک کاپي کړئ';

  @override
  String get formsLinkCopied => 'لینک کاپي شو.';

  @override
  String get formsRotateLink => 'نوی لینک (زوړ به کار ونکړي)';

  @override
  String get formsLinkRotated => 'فورمې نوی لینک لري. زوړ لینک نور کار نه کوي.';

  @override
  String get formsSubmissions => 'لیږنې';

  @override
  String get formsNoSubmissions =>
      'تر اوسه د دې فورمې له لارې څه نه دي لېږل شوي.';

  @override
  String get formsTaskGone => 'کار ړنګ شوی';

  @override
  String get formsCopyReference => 'ریفرنس کاپي کړئ';

  @override
  String get formsDelete => 'فورمه ړنګول';

  @override
  String formsDeleteTitle(String name) {
    return '«$name» ړنګ شي؟';
  }

  @override
  String get formsDeleteBody =>
      'لینک یې کار نه کوي او د لیږنو لیست لرې کېږي. جوړ شوي کارونه پاتې کېږي.';

  @override
  String get formsDenied => 'تاسو دلته فورمې نشئ مدیریت کولی.';

  @override
  String get formsGone => 'دا فورمه نور شتون نلري.';

  @override
  String get formsGonePage => 'دا فورمه شتون نلري.';

  @override
  String get formsConflict =>
      'فورمه وروسته له خلاصولو بدله شوه. بیا یې پرانیزئ او هڅه وکړئ.';

  @override
  String get formsTooMany => 'ډېرې لیږنې. وروسته بیا هڅه وکړئ.';

  @override
  String get formsUnavailable =>
      'دا فورمه همدا اوس لیږنې نه مني. وروسته بیا هڅه وکړئ.';

  @override
  String get formsCaptchaFailed => 'تایید ناکام شو. بیا یې بشپړ کړئ او ولېږئ.';

  @override
  String get formsCaptchaRequired => 'تایید بشپړ کړئ.';

  @override
  String get formsCaptchaWebOnly =>
      'دا فورمه داسې تایید غواړي چې یوازې په براوزر کې کار کوي. لینک هلته پرانیزئ.';

  @override
  String get formsCaptchaPreview => 'دلته یو تایید ښکاري.';

  @override
  String get formsRequired => 'دا اړین دی.';

  @override
  String get formsRequiredTag => 'اړین';

  @override
  String get formsEmailLabel => 'ستاسو بریښنالیک (اختیاري)';

  @override
  String get formsEmailLabelRequired => 'ستاسو بریښنالیک *';

  @override
  String get formsEmailHelp =>
      'یوازې د همدې غوښتنې د تایید او خبرولو لپاره کارول کېږي.';

  @override
  String get formsEmailInvalid => 'یو سم بریښنالیک ولیکئ.';

  @override
  String get formsSubmit => 'لیږل';

  @override
  String get formsSending => 'لیږل کېږي…';

  @override
  String get formsThanksTitle => 'مننه، ترلاسه شو';

  @override
  String formsThanksBody(String reference) {
    return 'ستاسو ریفرنس $reference دی. کله چې موږ ته لیکئ یې یاد کړئ.';
  }

  @override
  String get formsAnother => 'بل ولېږئ';

  @override
  String formsAddFile(int max) {
    return 'فایل زیات کړئ (تر $max)';
  }

  @override
  String get formsRemoveFile => 'فایل لرې کړئ';

  @override
  String get formsFileTooBig => 'یو فایل ډېر لوی دی.';

  @override
  String get formsNoDate => 'نیټه نشته';

  @override
  String get formsPickDate => 'نیټه وټاکئ';

  @override
  String get formsClearDate => 'نیټه پاکه کړئ';

  @override
  String get formsMoneyHint => 'اندازه او اسعار، لکه 12.50 USD';

  @override
  String get formsBuildTab => 'جوړول';

  @override
  String get formsPreviewTab => 'مخکتنه';

  @override
  String get formsNameLabel => 'د فورمې نوم';

  @override
  String get formsDescriptionLabel => 'د فورمې پر سر متن';

  @override
  String get formsNeedName => 'فورمې ته نوم ورکړئ.';

  @override
  String get formsSaved => 'فورمه خوندي شوه.';

  @override
  String get formsQuestions => 'پوښتنې';

  @override
  String get formsDefaultTitle => 'لنډیز';

  @override
  String get formsDefaultDescription => 'جزئیات';

  @override
  String get formsDefaultFile => 'ضمیمه';

  @override
  String get formsAddDescription => 'جزئیات زیات کړئ';

  @override
  String get formsAddFileQuestion => 'د فایل پورته کول زیات کړئ';

  @override
  String get formsAddField => 'د پروژې ځای زیات کړئ';

  @override
  String get formsPickField => 'کوم ځای؟';

  @override
  String get formsNoFields =>
      'نور ځایونه نشته. د کس ځایونه هیڅکله په عامه فورمه کې نه ښودل کېږي.';

  @override
  String get formsRemoveQuestion => 'پوښتنه لرې کړئ';

  @override
  String get formsKindTitle => 'د کار سرلیک';

  @override
  String get formsKindDescription => 'د کار تشریح';

  @override
  String get formsKindFile => 'د فایل پورته کول';

  @override
  String get formsKindField => 'د پروژې ځای';

  @override
  String get formsEditQuestion => 'پوښتنه سمول';

  @override
  String get formsQuestionLabel => 'لیبل';

  @override
  String get formsQuestionHelp => 'د مرستې متن';

  @override
  String get formsQuestionRequired => 'اړین';

  @override
  String get formsMaxFiles => 'ډېر فایلونه';

  @override
  String get formsTarget => 'کار په څه پیلېږي';

  @override
  String get formsStatusLabel => 'حالت';

  @override
  String get formsStatusDefault => 'د پروژې لومړی حالت';

  @override
  String get formsPriorityLabel => 'لومړیتوب';

  @override
  String get formsPriorityNone => 'هیڅ';

  @override
  String get formsPriorityLow => 'ټيټ';

  @override
  String get formsPriorityMedium => 'منځنی';

  @override
  String get formsPriorityHigh => 'لوړ';

  @override
  String get formsPriorityUrgent => 'بیړنی';

  @override
  String get formsAssigneesLabel => 'ور وسپارئ';

  @override
  String get formsEnabled => 'لیږنې مني';

  @override
  String get formsRequireEmail => 'بریښنالیک غوښتل';

  @override
  String get formsSendConfirmation => 'د تایید بریښنالیک لیږل';

  @override
  String get formsNotifyStatus => 'د حالت بدلون بریښنالیک';

  @override
  String get formsNotifyStatusHint =>
      'یو اړخیز: لیږونکی نوی حالت ترلاسه کوي، د کاري ځای لینک نه.';

  @override
  String get formsBranding => 'بڼه';

  @override
  String get formsColorLabel => 'د برانډ رنګ';

  @override
  String get formsLogoLabel => 'د لوګو پته (https://…)';

  @override
  String get goalsTitle => 'موخې';

  @override
  String get goalsEmpty =>
      'تر اوسه موخه نشته. یوه جوړه کړئ چې مهم کارونه تعقیب کړئ.';

  @override
  String get goalsNew => 'نوې موخه';

  @override
  String get goalsEdit => 'موخه سمول';

  @override
  String get goalsDelete => 'موخه ړنګول';

  @override
  String goalsDeleteTitle(String name) {
    return '«$name» ړنګ شي؟';
  }

  @override
  String get goalsDeleteBody =>
      'کلیدي پایلې او د پرمختګ ثبتونه یې ړنګیږي. لاندې موخې یو کچه پورته کیږي.';

  @override
  String get goalsSave => 'ساتل';

  @override
  String get goalsName => 'نوم';

  @override
  String get goalsDescription => 'تشریح';

  @override
  String goalsPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String get goalsOwner => 'مسؤل';

  @override
  String get goalsContributors => 'ګډونوالا';

  @override
  String get goalsParent => 'پورتنۍ موخه';

  @override
  String get goalsNone => 'هیڅ';

  @override
  String get goalsFolder => 'پوښۍ';

  @override
  String get goalsNoFolder => 'پرته له پوښۍ';

  @override
  String get goalsNewFolder => 'نوې پوښۍ';

  @override
  String get goalsFolderName => 'د پوښۍ نوم';

  @override
  String get goalsRenameFolder => 'د پوښۍ نوم بدلول';

  @override
  String get goalsDeleteFolder => 'پوښۍ ړنګول';

  @override
  String get goalsWeight => 'وزن';

  @override
  String get goalsPrivate => 'شخصي';

  @override
  String get goalsPrivateHint => 'یوازې مسؤل، ګډونوالا او مدیران یې ګوري.';

  @override
  String get goalsStatusLabel => 'حالت';

  @override
  String get goalsStatusAuto => 'اتومات';

  @override
  String get goalsStatusOnTrack => 'په پټلۍ';

  @override
  String get goalsStatusAtRisk => 'په خطر کې';

  @override
  String get goalsStatusOffTrack => 'له پټلۍ وتلی';

  @override
  String get goalsStatusAutoNote => 'له پرمختګ او وخت څخه حسابیږي.';

  @override
  String goalsStatusSet(String status) {
    return 'په لاس ټاکل شوی. وړاندیز: $status';
  }

  @override
  String goalsProgressPercent(int percent) {
    return '$percent٪';
  }

  @override
  String get goalsKeyResults => 'کلیدي پایلې';

  @override
  String get goalsNoKr => 'تر اوسه کلیدي پایلې نشته.';

  @override
  String get goalsAddKr => 'کلیدي پایله زیاتول';

  @override
  String get goalsEditKr => 'کلیدي پایله سمول';

  @override
  String get goalsDeleteKr => 'کلیدي پایله ړنګول';

  @override
  String get goalsKrName => 'کلیدي پایله';

  @override
  String get goalsKrType => 'د اندازې ډول';

  @override
  String get goalsKrNumber => 'شمیره';

  @override
  String get goalsKrPercentage => 'سلنه';

  @override
  String get goalsKrBoolean => 'ترسره شو یا نه';

  @override
  String get goalsKrLinked => 'تړلي کارونه';

  @override
  String get goalsKrStart => 'پیل ارزښت';

  @override
  String get goalsKrTarget => 'موخیز ارزښت';

  @override
  String get goalsKrCurrent => 'اوسنی ارزښت';

  @override
  String get goalsKrDirectionHint =>
      'موخه له پیل څخه کمه هم کیدی شي، لکه د ستونزو کمول له ۴۰ څخه ۱۰ ته.';

  @override
  String get goalsKrFilter => 'د کارونو فلټر (اختیاري)';

  @override
  String get goalsKrFilterHint =>
      'د کاري ځای پر سر د TFQL فلټر، لکه label = launch. هغه کارونه چې په لاس یې زیاتوئ هم شمیرل کیږي.';

  @override
  String goalsKrPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارونه په لاس زیات شوي',
      one: '۱ کار په لاس زیات شوی',
    );
    return '$_temp0';
  }

  @override
  String goalsKrNumberProgress(String current, String target) {
    return '$current له $target څخه';
  }

  @override
  String goalsKrLinkedProgress(int done, int total) {
    return '$done له $total کارونو ترسره شوي';
  }

  @override
  String get goalsKrDone => 'ترسره شو';

  @override
  String get goalsKrNotDone => 'نه دی ترسره';

  @override
  String get goalsCheckIn => 'پرمختګ ثبتول';

  @override
  String goalsCheckInTitle(String name) {
    return 'پرمختګ ثبتول: $name';
  }

  @override
  String get goalsCheckInValue => 'نوی ارزښت';

  @override
  String get goalsCheckInDone => 'ترسره شو';

  @override
  String get goalsCheckInNote => 'یادښت';

  @override
  String get goalsCheckInLinkedHint =>
      'تړلي کارونه ارزښت ټاکي. بیا هم یادښت پریښودی شئ.';

  @override
  String get goalsCheckInHistory => 'پخوانی';

  @override
  String get goalsCheckInEmpty => 'تر اوسه ثبت نشته.';

  @override
  String get goalsCheckInSystem => 'له کارونو شمیرل شوی';

  @override
  String goalsCheckInChange(String from, String to) {
    return '$from ← $to';
  }

  @override
  String get goalsContributes => 'ګډون کوي په';

  @override
  String get goalsAddToKr => 'په یوه کلیدي پایله کې شمیرل';

  @override
  String get goalsPickKr => 'کومه کلیدي پایله دا کار وشمیري؟';

  @override
  String get goalsNoLinkedKr => 'داسې تړلې کلیدي پایلې نشته چې سمولی یې شئ.';

  @override
  String get goalsSubgoals => 'فرعي موخې';

  @override
  String get goalsDenied => 'تاسو د موخو سره د دې کار اجازه نه لرئ.';

  @override
  String get goalsGone => 'دا موخه نور شتون نلري.';

  @override
  String get goalsConflict =>
      'له خلاصولو راهیسې بدل شوی. بیا یې پرانیزئ او هڅه وکړئ.';

  @override
  String get tplTitle => 'کالبونه';

  @override
  String get tplSearch => 'په کالبونو کې لټون';

  @override
  String get tplAll => 'ټول';

  @override
  String get tplKindProject => 'پروژې';

  @override
  String get tplKindTask => 'کارونه';

  @override
  String get tplEmpty => 'هېڅ کالب ونه موندل شو.';

  @override
  String get tplBuiltIn => 'دننه جوړ';

  @override
  String get tplPrivate => 'یوازې زه';

  @override
  String get tplShared => 'د کاري ځای ټول غړي';

  @override
  String tplTasksN(int count) {
    return '$count کارونه';
  }

  @override
  String tplAutomationsN(int count) {
    return '$count اتومات کارونه';
  }

  @override
  String get tplStatuses => 'حالتونه';

  @override
  String get tplFields => 'دودیز ساحې';

  @override
  String get tplFeatures => 'ځانګړتیاوې';

  @override
  String get tplTasks => 'کارونه';

  @override
  String get tplNoTasks => 'بېلګه کارونه نشته.';

  @override
  String get tplApply => 'کالب وکاروئ';

  @override
  String get tplEdit => 'سمول';

  @override
  String get tplDelete => 'ړنګول';

  @override
  String get tplDeleteAsk =>
      'دا کالب ړنګ شي؟ هغه پروژې چې له دې جوړې شوې اغېز نه ورباندې کیږي.';

  @override
  String tplApplyTitle(String name) {
    return '$name وکاروئ';
  }

  @override
  String get tplProjectName => 'د پروژې نوم';

  @override
  String get tplProjectKey => 'کلیډ';

  @override
  String get tplTargetProject => 'پروژې ته زیاتول';

  @override
  String get tplStartDate => 'د پیل نېټه';

  @override
  String get tplStartHelp => 'نسبي نېټې له دې ورځې شمېرل کیږي.';

  @override
  String get tplVariables => 'ډک کړئ';

  @override
  String get tplRequired => 'اړین دی.';

  @override
  String get tplCreate => 'جوړول';

  @override
  String tplApplied(int count) {
    return '$count کارونه جوړ شول.';
  }

  @override
  String get tplWarnings => 'ځینې برخې پرېښودل شوې';

  @override
  String get tplSaveTitle => 'د کالب په توګه خوندي کول';

  @override
  String get tplName => 'نوم';

  @override
  String get tplDescription => 'تشریح';

  @override
  String get tplVisibility => 'څوک یې کارولی شي';

  @override
  String get tplInclude => 'شاملول';

  @override
  String get tplPartWorkflow => 'حالتونه او کاري بهیر';

  @override
  String get tplPartFields => 'دودیز ساحې';

  @override
  String get tplPartAutomations => 'اتومات کارونه';

  @override
  String get tplPartFeatures => 'د ځانګړتیاوو سویچونه';

  @override
  String get tplPartTasks => 'بېلګه کارونه';

  @override
  String get tplAssignees => 'مسؤلین وساتئ';

  @override
  String get tplSave => 'خوندي کول';

  @override
  String get tplSaved => 'کالب خوندي شو.';

  @override
  String get tplSaveTask => 'کار د کالب په توګه خوندي کړئ';

  @override
  String get tplSaveProject => 'پروژه د کالب په توګه خوندي کړئ';

  @override
  String get tplFromTemplate => 'له کالب څخه…';

  @override
  String get tplCmdOpen => 'کالبونه پرانیزئ';

  @override
  String get tplDenied => 'تاسو د کالبونو سره د دې کار اجازه نه لرئ.';

  @override
  String get tplGone => 'دا کالب نور شتون نلري.';

  @override
  String get tplConflict =>
      'له خلاصولو راهیسې بدل شوی. بیا یې پرانیزئ او هڅه وکړئ.';

  @override
  String get wlTitle => 'د کار پرېکړه';

  @override
  String get wlSettings => 'ظرفیت، رخصتۍ او رخصتي ورځې';

  @override
  String get wlPrevious => 'تیر';

  @override
  String get wlNext => 'راتلونکی';

  @override
  String get wlToday => 'نن';

  @override
  String get wlZoomDay => 'ورځ';

  @override
  String get wlZoomWeek => 'اونۍ';

  @override
  String get wlZoomMonth => 'میاشت';

  @override
  String get wlProjects => 'پروژې';

  @override
  String get wlPeople => 'خلک';

  @override
  String get wlClearFilter => 'فلټر پاکول';

  @override
  String get wlLegendUnder => 'د ظرفیت له نیمایي کم';

  @override
  String get wlLegendOk => 'د ظرفیت په کچه';

  @override
  String get wlLegendOver => 'له ظرفیت زیات';

  @override
  String get wlLegendSevere => 'له ظرفیت ډېر زیات (له ۱۲۵٪ پورته)';

  @override
  String get wlOnlyYours => 'تاسو یوازې خپل د کار پرېکړه لیدلی شئ.';

  @override
  String get wlSetCapacityHint =>
      'د ځينو کسانو ظرفیت لا نه دی ټاکل شوی. بار یې د زیاتوالي رنګونو پرته ښودل کېږي.';

  @override
  String get wlSetCapacity => 'ظرفیت ټاکل';

  @override
  String get wlNoCapacity => 'ظرفیت نه دی ټاکل شوی';

  @override
  String get wlTruncated => 'ډېر کارونه: جدول یوازې یوه برخه ښيي.';

  @override
  String get wlNoPeople => 'د ښودلو لپاره څوک نشته.';

  @override
  String wlCapacitySummary(String hours, String days) {
    return '$hours ساعته په ورځ کې، $days ورځې په اونۍ کې';
  }

  @override
  String wlUnestimated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارونه پرته له اټکل',
      one: '۱ کار پرته له اټکل',
    );
    return '$_temp0';
  }

  @override
  String wlUndated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارونه پرته له نیټو',
      one: '۱ کار پرته له نیټو',
    );
    return '$_temp0';
  }

  @override
  String get wlReasonNoEstimate => 'پرته له اټکل: په جدول کې نه شمېرل کېږي';

  @override
  String get wlReasonNoDates => 'پرته له نیټو: په هیڅ ورځ کې نه ځای کېږي';

  @override
  String wlCellTotal(String load, String capacity) {
    return 'بار $load ساعته له $capacity ساعتو';
  }

  @override
  String get wlHoursUnit => 'ساعته';

  @override
  String get wlCellEmpty => 'هیڅ نه دي پلان شوي';

  @override
  String get wlHoursInvalid => 'په ورځ کې ساعتونه له ۰ تر ۲۴ پورې شمېره ده.';

  @override
  String wlCapacityOf(String name) {
    return 'د $name ظرفیت';
  }

  @override
  String get wlHoursPerDay => 'په ورځ کې ساعتونه';

  @override
  String get wlWorkingDays => 'د کار ورځې';

  @override
  String get wlTabCapacity => 'ظرفیت';

  @override
  String get wlTabTimeOff => 'رخصتۍ';

  @override
  String get wlTabHolidays => 'رخصتي ورځې';

  @override
  String get wlAddTimeOff => 'رخصتي ورزیاتول';

  @override
  String get wlNoTimeOff => 'هیڅ رخصتي نه ده ثبت شوې.';

  @override
  String get wlKindVacation => 'رخصتي';

  @override
  String get wlKindSick => 'ناروغي رخصتي';

  @override
  String get wlKindPersonal => 'شخصي';

  @override
  String get wlKindOther => 'نور';

  @override
  String get wlPerson => 'کس';

  @override
  String get wlKind => 'ډول';

  @override
  String get wlNote => 'یادښت';

  @override
  String get wlAddHoliday => 'رخصتي ورځ ورزیاتول';

  @override
  String get wlNoHolidays => 'تر اوسه رخصتي ورځې نشته.';

  @override
  String get wlHolidayName => 'د رخصتۍ نوم';

  @override
  String get wlDelete => 'ړنګول';

  @override
  String get wlDenied => 'تاسو د کار په پرېکړه کې د دې کار اجازه نه لرئ.';

  @override
  String get wlGone => 'دا ننوتنه نور نشته.';

  @override
  String get wlConflict =>
      'له پرانیستلو راهیسې بدل شوی. بیا یې پورته کړئ او بیا هڅه وکړئ.';

  @override
  String get secTitle => 'امنیت';

  @override
  String get secSubtitle => 'دوه‌پړاویز تایید او باوري وسایل';

  @override
  String get secTwoStep => 'دوه‌پړاویز تایید';

  @override
  String get secOn => 'فعال دی. ننوتل ستاسو د تایید اپ کوډ غواړي.';

  @override
  String get secOff => 'بند دی. د خپل حساب د ساتنې لپاره دویم پړاو اضافه کړئ.';

  @override
  String get secEnable => 'فعالول';

  @override
  String get secTurnOn => 'فعالول';

  @override
  String get secDisable => 'بندول';

  @override
  String get secDisableTitle => 'دوه‌پړاویز تایید بندول';

  @override
  String get secDisabled => 'دوه‌پړاویز تایید بند شو.';

  @override
  String get secEnrollTitle => 'د تایید اپ تنظیمول';

  @override
  String get secScanQr =>
      'دا کوډ د تایید په اپ لکه Aegis، Authy یا Google Authenticator سکین کړئ.';

  @override
  String get secOrTypeKey => 'یا دا کیلي ولیکئ:';

  @override
  String get secEnterCode => 'له اپ څخه ۶ رقمي کوډ';

  @override
  String get secCopied => 'کاپي شو.';

  @override
  String get secRecoveryTitle => 'د بیا ترلاسه کولو کوډونه';

  @override
  String get secRecoveryBody =>
      'دا لس کوډونه په خوندي ځای کې وساتئ. که ګرځنده مو ورک شي هر یو یو ځل کار کوي. بیا نه ښودل کېږي.';

  @override
  String get secCodesCopied => 'د بیا ترلاسه کولو کوډونه کاپي شول.';

  @override
  String get secSavedThem => 'ما خوندي کړل';

  @override
  String secCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کوډونه پاتې دي',
      one: '۱ کوډ پاتې دی',
      zero: 'کوم کوډ نه دی پاتې',
    );
    return '$_temp0';
  }

  @override
  String get secRegenerate => 'نوي کوډونه';

  @override
  String get secRegenerateTitle => 'د بیا ترلاسه کولو کوډونه بدلول';

  @override
  String get secCodeOrRecovery => 'د اپ یا بیا ترلاسه کولو کوډ';

  @override
  String get secDevices => 'باوري وسایل';

  @override
  String get secDevicesSub =>
      'دا وسایل تر پای ته رسېدو پورې په ننوتلو کې کوډ نه غواړي.';

  @override
  String get secNoDevices => 'هیڅ وسیله په یاد نه ده ساتل شوې.';

  @override
  String get secForgetAll => 'ټول هېرول';

  @override
  String get secForget => 'دا وسیله هېرول';

  @override
  String get secUnnamedDevice => 'بې نومه وسیله';

  @override
  String secDeviceUntil(String date) {
    return 'تر $date پورې باوري';
  }

  @override
  String get secBlocked =>
      'دا کاري ځای دوه‌پړاویز تایید غواړي. د دوام لپاره یې لاندې فعال کړئ.';

  @override
  String secGraceUntil(String date) {
    return 'دا کاري ځای له $date راهیسې دوه‌پړاویز تایید غواړي. تر هغه مخکې یې فعال کړئ.';
  }

  @override
  String get secPolicyTitle => 'د کاري ځای اړتیا';

  @override
  String get secRequire => 'دوه‌پړاویز تایید اړین کول';

  @override
  String get secRequireSub =>
      'هغه غړي چې نه وي فعال کړی د مهلت تر پای وروسته بندېږي.';

  @override
  String get secGraceDays => 'مهلت (ورځې)';

  @override
  String get secGraceInvalid => '۰ تر ۹۰ ورځې ولیکئ.';

  @override
  String get secPolicySaved => 'اړتیا خوندي شوه.';

  @override
  String get secVerifyTitle => 'دوه‌پړاویز تایید';

  @override
  String get secEnterAppCode => 'د خپل تایید اپ ۶ رقمي کوډ ولیکئ.';

  @override
  String get secEnterRecovery =>
      'یو د بیا ترلاسه کولو کوډ ولیکئ. هر یو یو ځل کار کوي.';

  @override
  String get secAppCode => 'کوډ';

  @override
  String get secRecoveryCode => 'د بیا ترلاسه کولو کوډ';

  @override
  String get secRememberDevice => 'په دې وسیله کې ۳۰ ورځې بیا مه پوښتئ';

  @override
  String get secVerify => 'تایید';

  @override
  String get secUseRecovery => 'د بیا ترلاسه کولو کوډ کارول';

  @override
  String get secUseAppCode => 'د اپ کوډ کارول';

  @override
  String get secBackToSignIn => 'ننوتلو ته بیرته';

  @override
  String get secWrongCode => 'دا کوډ سم نه دی. بیا هڅه وکړئ.';

  @override
  String get secLocked => 'ډېر ناسم کوډونه. لږ صبر وکړئ او بیا هڅه وکړئ.';

  @override
  String get secTooManyTries => 'ډېرې ناسمې هڅې. بیا ننوځئ.';

  @override
  String get secSignInExpired => 'دا ننوتل پای ته ورسېد. له پټنوم بیا پیل کړئ.';

  @override
  String get secConflict => 'دا په دې منځ کې بدل شو. بیا پرانیزئ او هڅه وکړئ.';

  @override
  String get secNotFound => 'ونه موندل شو.';

  @override
  String get ssoTitle => 'یو ځلي ننوتل (SSO)';

  @override
  String get ssoTitleShort => 'یو ځلي ننوتل';

  @override
  String get ssoSub =>
      'اجازه ورکړئ چې خلک ستاسو د هویت چمتو کوونکي (OpenID Connect) سره ننوځي.';

  @override
  String get ssoContinue => 'د SSO سره دوام';

  @override
  String get ssoContinueShort => 'دوام';

  @override
  String get ssoWorkspaceName => 'د کاري ځای د پتې نوم';

  @override
  String get ssoWorkspaceHelp => 'د کاري ځای په پته کې لنډ نوم، لکه acme';

  @override
  String get ssoOpenFailed => 'برازر خلاص نه شو.';

  @override
  String get ssoErrUnverified =>
      'ستاسو د هویت چمتو کوونکي ستاسو بریښنالیک نه دی تایید کړی، نو په هغه نه شئ ننوتلی.';

  @override
  String get ssoErrDomain =>
      'ستاسو د بریښنالیک ډومین ته په دې کاري ځای کې د ننوتلو اجازه نشته.';

  @override
  String get ssoErrNoAccount =>
      'دلته ستاسو حساب نشته او د SSO له لارې نوملیکنه بنده ده.';

  @override
  String get ssoErrRemoved =>
      'تاسو له دې کاري ځای څخه لرې شوي یاست. بلنه وغواړئ.';

  @override
  String get ssoErrDisabled => 'دا حساب بند دی.';

  @override
  String get ssoErrGeneric => 'یو ځلي ننوتل بشپړ نه شو. بیا پیل کړئ.';

  @override
  String get ssoRedirectHelp =>
      'دا د بیرته لارښوونې پته خپل د هویت چمتو کوونکي سره ثبت کړئ:';

  @override
  String get ssoEnabled => 'یو ځلي ننوتل فعال دی';

  @override
  String get ssoName => 'ښودل کېدونکی نوم (اختیاري)';

  @override
  String get ssoIssuer => 'د صادرونکي پته (Issuer)';

  @override
  String get ssoIssuerHelp =>
      'چېرې چې /.well-known/openid-configuration دی، لکه https://id.example.com/realms/acme';

  @override
  String get ssoClientId => 'د پیرودونکي پېژندنه';

  @override
  String get ssoClientSecret => 'د پیرودونکي راز';

  @override
  String get ssoSecretKept => 'یو راز خوندي دی. د ساتلو لپاره یې خالي پریږدئ.';

  @override
  String get ssoSecretNeeded =>
      'اړین دی. کوډ شوی خوندي کېږي او بیا نه ښودل کېږي.';

  @override
  String get ssoScopes => 'ساحې (Scopes)';

  @override
  String get ssoDomains => 'اجازه شوي د بریښنالیک ډومینونه';

  @override
  String get ssoDomainsHelp =>
      'په کوما جلا کړئ، لکه acme.com. خالي هر یو ته اجازه ورکوي.';

  @override
  String get ssoAutoCreate => 'په لومړي ننوتلو کې حسابونه جوړول';

  @override
  String get ssoAutoCreateSub =>
      'د اجازه شویو ډومینونو خلک پرته له بلنې یوځای کېږي.';

  @override
  String get ssoRoles => 'رولونه';

  @override
  String get ssoGroupClaim => 'د ډلې ادعا نوم (claim)';

  @override
  String get ssoDefaultRole =>
      'د هغو خلکو رول چې هیڅ ډله ورسره نه برابرېږي (اصلي: غړی).';

  @override
  String get ssoDefaultRoleAuto => 'غړی (اصلي)';

  @override
  String get ssoGroup => 'ډله';

  @override
  String get ssoAddMapping => 'ډله له رول سره تړل';

  @override
  String get ssoEnforce => 'یو ځلي ننوتل اړین کول';

  @override
  String get ssoEnforceSub =>
      'د غړو لپاره د پټنوم ننوتل بندوي. مالکان یې د بېرته راتګ لپاره ساتي.';

  @override
  String get ssoSaved => 'یو ځلي ننوتل خوندي شو.';

  @override
  String get ssoTest => 'ازموینه';

  @override
  String ssoTestOk(int keys) {
    return 'چمتو کوونکي ځواب ورکړ ($keys د لاسلیک کیلي وموندل شوې)';
  }

  @override
  String get ssoTestFailed => 'ازموینه ناکامه شوه';

  @override
  String get ssoRemove => 'لرې کول';

  @override
  String get ssoRemoveTitle => 'یو ځلي ننوتل لرې شي؟';

  @override
  String get ssoRemoveBody => 'هغه خلک چې له دې لارې ننوتي، باید بیا ننوځي.';

  @override
  String get sysAboutTitle => 'په اړه';

  @override
  String get sysClientVersion => 'د اپ نسخه';

  @override
  String get sysServerVersion => 'د سرور نسخه';

  @override
  String get sysUnknown => 'نامعلوم (سرور نه ترلاسه کېږي)';

  @override
  String sysUpdateAvailable(String version) {
    return 'نوې نسخه ($version) شته. دا اپ تازه کړئ.';
  }

  @override
  String get sysCheckAgain => 'بیا وګورئ';

  @override
  String get sysUpdateRequiredTitle => 'تازه کول اړین دي';

  @override
  String sysUpdateRequiredBody(String current, String minimum) {
    return 'دا اپ ($current) د دې سرور لپاره ډېر زوړ دی؛ سرور $minimum یا نوې نسخې ته اړتیا لري. د دوام لپاره وروستۍ نسخه نصب کړئ.';
  }

  @override
  String get sysTitle => 'سیستم';

  @override
  String get sysSubtitle => 'نسخه او د کتار روغتیا (مدیران)';

  @override
  String get sysDenied => 'یوازې مدیران کولی شي د سیستم حالت وګوري.';

  @override
  String get sysLoadFailed => 'د سیستم حالت نه شو پورته کېدای.';

  @override
  String get sysMinClient => 'تر ټولو زوړ ملاتړ شوی اپ';

  @override
  String get sysRedis => 'Redis';

  @override
  String get sysBroker => 'د دندو کتار (Celery)';

  @override
  String get sysWorkers => 'کارکوونکي';

  @override
  String get sysOk => 'سم';

  @override
  String get sysUnavailable => 'نه ترلاسه کېږي';

  @override
  String get sysInMemory => 'په حافظه کې (ډیبګ)';

  @override
  String get sysNotConfigured => 'تنظیم شوی نه دی';

  @override
  String get sysInline => 'دندې په ځای اجرا کېږي (ډیبګ)';

  @override
  String get sysNoWorkers => 'هیڅ کارکوونکي ځواب نه ورکړ';

  @override
  String get sysBacklog => 'د ټاکلي وخت کارونه په انتظار کې';

  @override
  String get sysBacklogNone => 'هیڅ شی په انتظار کې نه دی.';

  @override
  String get dpopKeyChanged =>
      'د دې وسیلې کیلي بدله شوې، مهرباني وکړئ بیا ننوځئ.';

  @override
  String get dpopSessionBound => 'د دې وسیلې له کیلي سره تړلې';

  @override
  String get devSessionRename => 'نوم بدل کړئ';

  @override
  String get devSessionRenameTitle => 'د دې ناستې نوم بدل کړئ';

  @override
  String get devSessionNameLabel => 'نوم';

  @override
  String get devSessionNameInvalid => 'له ۱ تر ۸۰ پورې توري وکاروئ.';

  @override
  String get devSessionRenameFailed => 'د ناستې نوم بدل نه شو. بیا هڅه وکړئ.';

  @override
  String get devSessionNew => 'نوی';

  @override
  String get devSessionKeyChanged => 'کیلي بدله شوه';

  @override
  String devSessionLastUsed(String when) {
    return 'وروستی کارول $when';
  }

  @override
  String get devPrivacyTitle => 'د وسیلې معلومات';

  @override
  String get devPrivacyBody =>
      'کله چې ننوځئ، نوم لیکنه کوئ یا ناسته نوې کوئ، دا اپلیکیشن ستاسو د وسیلې ماډل، عملیاتي سیستم او نسخه، د اپلیکیشن جوړښت، د پردې اندازه، ژبه او وخت سیمه لیږي، څو ستاسو ناستې لوستلی نوم ومومي. سرور شاید پرې توجه ونکړي، او تاسو کولی شئ د هرې ناستې نوم بدل کړئ.';

  @override
  String get devAdminCollectTitle => 'د وسیلې معلومات راټولول';

  @override
  String get devAdminCollectSubtitle =>
      'د هغه څه پر بنسټ چې اپلیکیشن یې راپور ورکوي، ناستې نومول او نوې وسیلې نښه کول. په ډیفالټ بند دی.';

  @override
  String get devAdminPepperMissing =>
      'لومړی په سرور کې DJANGO_DEVICE_FINGERPRINT_PEPPER تنظیم کړئ.';

  @override
  String get devAdminSaveFailed => 'تنظیم خوندي نه شو.';

  @override
  String get audTokenCreated => 'یو API توکن جوړ کړ';

  @override
  String get audTokenRevoked => 'یو API توکن لغوه کړ';

  @override
  String get audWebhookCreated => 'یو ویب‌هوک اضافه کړ';

  @override
  String get audWebhookUpdated => 'یو ویب‌هوک بدل کړ';

  @override
  String get audWebhookDeleted => 'یو ویب‌هوک ړنګ کړ';

  @override
  String get audWebhookDisabled => 'یو ویب‌هوک د تکرارو ناکامیو وروسته بند شو';

  @override
  String get audFormCreated => 'یو د ترلاسه فورمه جوړه کړه';

  @override
  String get audFormUpdated => 'یوه د ترلاسه فورمه بدله کړه';

  @override
  String get audFormDeleted => 'یوه د ترلاسه فورمه ړنګه کړه';

  @override
  String get audFormSubmitted => 'یوه د ترلاسه فورمه ولېږله';

  @override
  String get audGoalCreated => 'یو هدف جوړ کړ';

  @override
  String get audGoalUpdated => 'یو هدف بدل کړ';

  @override
  String get audGoalDeleted => 'یو هدف ړنګ کړ';

  @override
  String audGoalFolderCreated(String name) {
    return 'د هدفونو پوښۍ $name جوړه کړه';
  }

  @override
  String audGoalFolderRenamed(String before, String after) {
    return 'د هدفونو پوښۍ $before په $after بدله کړه';
  }

  @override
  String audGoalFolderDeleted(String name) {
    return 'د هدفونو پوښۍ $name ړنګه کړه';
  }

  @override
  String audGoalKrCreated(String name) {
    return 'کلیدي پایله $name یې اضافه کړه';
  }

  @override
  String audGoalKrUpdated(String name) {
    return 'کلیدي پایله $name یې بدله کړه';
  }

  @override
  String audGoalKrDeleted(String name) {
    return 'کلیدي پایله $name یې ړنګه کړه';
  }

  @override
  String audGoalCheckedIn(String value, String name) {
    return 'د $name لپاره $value ثبت کړ';
  }

  @override
  String get audTemplateCreated => 'یو کیڼۍ جوړ کړ';

  @override
  String get audTemplateUpdated => 'یو کیڼۍ بدل کړ';

  @override
  String get audTemplateDeleted => 'یو کیڼۍ ړنګ کړ';

  @override
  String get audTemplateApplied => 'یو کیڼۍ وکاروه';

  @override
  String get audWorkloadCapacity => 'ظرفیت وټاکه';

  @override
  String get audWorkloadTimeOffCreated => 'رخصتي اضافه کړه';

  @override
  String get audWorkloadTimeOffUpdated => 'رخصتي بدله کړه';

  @override
  String get audWorkloadTimeOffDeleted => 'رخصتي ړنګه کړه';

  @override
  String get audWorkloadHolidayCreated => 'یوه رخصتي اضافه کړه';

  @override
  String get audWorkloadHolidayUpdated => 'یوه رخصتي بدله کړه';

  @override
  String get audWorkloadHolidayDeleted => 'یوه رخصتي ړنګه کړه';

  @override
  String get audWorkloadEstimateSet => 'اټکل یې وټاکه';

  @override
  String get audSecuritySsoConfigured => 'یو ځلې ننوتل یې تنظیم کړ';

  @override
  String get audSecuritySsoRemoved => 'یو ځلې ننوتل یې لرې کړ';

  @override
  String get audSecuritySsoMemberJoined => 'د یو ځلې ننوتلو له لارې یوځای شو';

  @override
  String get audSecuritySsoRoleChanged =>
      'رول یې د یو ځلې ننوتلو له لارې بدل شو';

  @override
  String get audSecurityPolicyChanged => 'امنیتي پالیسي یې بدله کړه';

  @override
  String get devWebhookProject => 'پروژه';

  @override
  String get devWebhookWholeWorkspace => 'ټوله کاري ځای';

  @override
  String updNoticeText(String version) {
    return '$version نسخه شتون لري.';
  }

  @override
  String get updNoticeGet => 'ډاونلوډ';

  @override
  String get updNoticeDismiss => 'بندول';

  @override
  String get grpMImpClickupApi => 'ClickUp (د API ټوکن)';

  @override
  String get grpCImpCuTokenHint => 'په ClickUp کې ستاسو شخصي API ټوکن';

  @override
  String get grpCImpCuTokenNote =>
      'یوازې ستاسو د لیستونو لوستلو لپاره کارول کیږي او ساتل کیږي نه.';

  @override
  String get grpCImpCuLoad => 'زما لیستونه وښیه';

  @override
  String get grpCImpCuPick => 'هغه لیستونه وټاکئ چې واردول یې غواړئ';

  @override
  String get grpCImpCuFetch => 'ټاکل شوي لیستونه راوړه';

  @override
  String get grpCImpCuFetching => 'له ClickUp څخه راوړل کیږي…';

  @override
  String get chatTitle => 'چت';

  @override
  String get chatEmpty =>
      'تر اوسه هیڅ پیغام نشته — بدلونونه او خبرې به دلته ښکاره شي';

  @override
  String get chatHideChanges => 'بدلونونه پټ کړه';

  @override
  String get chatLoadEarlier => 'پخواني پیغامونه راوړه';

  @override
  String chatEvTitle(String from, String to) {
    return 'د دې دندې سرلیک یې له «$from» څخه «$to» ته بدل کړ';
  }

  @override
  String chatEvStatus(String from, String to) {
    return 'حالت یې له $from څخه $to ته بدل کړ';
  }

  @override
  String chatEvPriority(String from, String to) {
    return 'لومړیتوب یې له $from څخه $to ته بدل کړ';
  }

  @override
  String chatEvStartDate(String from, String to) {
    return 'د پیل نېټه یې له $from څخه $to ته بدله کړه';
  }

  @override
  String chatEvDueDate(String from, String to) {
    return 'د پای نېټه یې له $from څخه $to ته بدله کړه';
  }

  @override
  String chatEvEstimate(String from, String to) {
    return 'اټکل یې له $from څخه $to ته بدل کړ';
  }

  @override
  String chatEvSubtask(String title) {
    return 'فرعي دنده «$title» یې اضافه کړه';
  }

  @override
  String get chatEvOther => 'یو ډګر یې بدل کړ';

  @override
  String get chatActorAutomation => 'یو اتومات عمل';

  @override
  String get chatActorForm => 'یو فورمه';

  @override
  String get chatActorImport => 'یو واردول';

  @override
  String get chatActorSystem => 'سیستم';

  @override
  String chatTitleCount(int count) {
    return 'چت ($count)';
  }

  @override
  String get chatSectionChannels => 'چینلونه';

  @override
  String get chatSectionGroups => 'ډلې';

  @override
  String get chatSectionDms => 'مستقیم پیغامونه';

  @override
  String get chatSectionTaskChats => 'د دندو بحثونه';

  @override
  String get chatSearchHint => 'په بحثونو کې لټون';

  @override
  String get chatNoSpaces => 'تر اوسه بحث نشته. د «نوی» په مټ یو پیل کړئ.';

  @override
  String get chatNoMatches => 'ستاسو له لټون سره هېڅ نه برابرېږي';

  @override
  String get chatMuted => 'غلی شوی';

  @override
  String get chatNew => 'نوی';

  @override
  String get chatNewChannel => 'چینل';

  @override
  String get chatNewGroup => 'ډله';

  @override
  String get chatNewMessage => 'پیغام';

  @override
  String get chatNameLabel => 'نوم';

  @override
  String get chatMembersLabel => 'غړي';

  @override
  String get chatPickPerson => 'یو کس وټاکئ';

  @override
  String get chatCreate => 'جوړول';

  @override
  String get chatNameRequired => 'یو نوم ولیکئ';

  @override
  String get chatGroupNeedsMembers => 'لږ تر لږه یو بل کس وټاکئ';

  @override
  String get chatSayHi => 'سلام ووایئ';

  @override
  String get chatSelectSpace => 'د خبرو پیل لپاره یو بحث وټاکئ';

  @override
  String get chatUnreadDivider => 'نوي پیغامونه';

  @override
  String get chatJumpLatest => 'وروستي ته لاړ شئ';

  @override
  String get chatWriteMessage => 'یو پیغام ولیکئ…';

  @override
  String get chatSend => 'لېږل';

  @override
  String get chatReply => 'ځواب';

  @override
  String chatReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ځوابونه',
      one: '۱ ځواب',
    );
    return '$_temp0';
  }

  @override
  String get chatThread => 'د بحث لړۍ';

  @override
  String get chatBack => 'شاته';

  @override
  String get chatEdit => 'سمون';

  @override
  String get chatDelete => 'ړنګول';

  @override
  String get chatRemoved => 'پیغام لرې شو';

  @override
  String get chatEdited => 'سمون شوی';

  @override
  String get chatMessageActions => 'د پیغام کړنې';

  @override
  String get chatSending => 'لېږل کېږي…';

  @override
  String get chatNotSent => 'ونه لېږل شو';

  @override
  String get chatDiscard => 'ردول';

  @override
  String get chatBroadcastTitle => 'ټول خبر کړو؟';

  @override
  String chatBroadcastBody(int count) {
    return 'دا پیغام به $count کسانو ته خبر ورکړي. بیا هم یې ولېږو؟';
  }

  @override
  String get chatBroadcastSend => 'بیا هم ولېږه';

  @override
  String get chatSettings => 'د بحث امستنې';

  @override
  String get chatUnmute => 'غږ پرانیستل';

  @override
  String get chatMute1h => 'د ۱ ساعت لپاره غلی کول';

  @override
  String get chatMute8h => 'د ۸ ساعتونو لپاره غلی کول';

  @override
  String get chatMuteWeek => 'د ۱ اونۍ لپاره غلی کول';

  @override
  String get chatMuteForever => 'تر هغه وخته غلی چې بیرته یې پرانیزم';

  @override
  String get chatMuteCompletely => 'بشپړ غلی، حتی زما @یادونې هم';

  @override
  String get chatNotifyAll => 'د هر پیغام لپاره ما ته خبر راکړه';

  @override
  String get chatLeave => 'پرېښودل';

  @override
  String get chatJoin => 'یوځای کېدل';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غړي',
      one: '۱ غړی',
    );
    return '$_temp0';
  }

  @override
  String get chatReadOnlyArchived =>
      'دا ځای ارشیف شوی. تاسو یې لوستلی شئ خو پکې لیکلی نشئ.';

  @override
  String get chatReadOnlyFormer => 'دا بحث یوازې د لوستلو دی.';

  @override
  String get chatNotMember => 'په دې چینل کې د لیکلو لپاره ورسره یوځای شئ.';

  @override
  String get chatFormerMember => 'پخوانی غړی';

  @override
  String chatUnreadLabel(int count) {
    return '$count نالوستل شوي';
  }

  @override
  String chatEntryMessage(String space) {
    return 'په $space کې د بحث پیغام';
  }

  @override
  String get shellRecent => 'وروستي';

  @override
  String get shellRename => 'نوم بدلول';

  @override
  String get shellRenameProject => 'د پروژې نوم بدلول';

  @override
  String get shellGallery => 'د برخو ګالري';

  @override
  String get shellCrumbTask => 'دنده';

  @override
  String get shellCrumbDoc => 'سند';

  @override
  String get shellCrumbGoal => 'موخه';

  @override
  String get shellCrumbSpace => 'ځای';

  @override
  String get shellToggleSidebar => 'څنګ بار ښودل یا پټول';

  @override
  String get shellThen => 'بیا';

  @override
  String get shellWorkspaceGroup => 'کاري ځای';

  @override
  String get shellAdminGroup => 'مدیریت';

  @override
  String get shellExpandSidebar => 'څنګ بار پراخول';

  @override
  String get shellCollapseSidebar => 'څنګ بار راټولول';

  @override
  String get shellCreate => 'جوړول';

  @override
  String get shellMore => 'نور';

  @override
  String get shellFindProject => 'پروژه موندل';

  @override
  String get shellNoProjectMatch => 'هیڅ پروژه ونه موندل شوه';

  @override
  String get grpENavMenu => 'د نیویګیشن مینو پرانیستل';

  @override
  String shellMoreFor(String name) {
    return 'د $name لپاره نور عملونه';
  }

  @override
  String get wvClearAll => 'ټول پاکول';

  @override
  String get wvOverdue => 'ځنډېدلی';

  @override
  String get wvSearchHint => 'په دې لید کې لټون';

  @override
  String get wvSearchClear => 'لټون پاک کړه';

  @override
  String get wvAddTask => 'دنده';

  @override
  String get wvAddView => 'لید';

  @override
  String get wvNoSavedViews =>
      'تر اوسه هیڅ ساتل شوی ترتیب نشته. له ترتیبونو یو وساتئ.';

  @override
  String get wvPinTab => 'د ټب په توګه ور وتړه';

  @override
  String get wvUnpinTab => 'ټب خلاص کړه';

  @override
  String get wvMoveEarlier => 'مخکې کړه';

  @override
  String get wvMoveLater => 'وروسته کړه';

  @override
  String get wvViewTabs => 'لیدونه';

  @override
  String get wvShare => 'شریکول';

  @override
  String get wvCopyLink => 'لینک کاپي کړه';

  @override
  String get wvLinkCopied => 'لینک کاپي شو';

  @override
  String get wvProjectMenu => 'د پروژې مینو';

  @override
  String get wvResetColumns => 'ستونونه بیا تنظیم کړه';

  @override
  String wvMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غړي',
      one: '۱ غړی',
    );
    return '$_temp0';
  }

  @override
  String get wvNoMatch => 'دا فلټرونه هیڅ دنده نه لري';

  @override
  String get wvClearFilters => 'فلټرونه پاکول';

  @override
  String get wvNoTasks => 'تر اوسه هیڅ دنده نشته';

  @override
  String get wvNoTasksHint => 'لومړۍ دنده اضافه کړئ چې دا پروژه پیل شي.';

  @override
  String get wvAddFirstTask => 'خپله لومړۍ دنده اضافه کړئ';

  @override
  String get wvLoadFailed => 'دندې نه شي پورته کېدای';

  @override
  String get tdActClose => 'پرانیستل شوې دنده تړل';

  @override
  String get tdActCloseSem => 'هغه دنده وتړه چې پرانیستل شوې';

  @override
  String get tdActPrev => 'مخکینۍ دنده';

  @override
  String get tdActPrevSem => 'په لیست کې مخکینۍ دنده پرانیزه';

  @override
  String get tdActNext => 'راتلونکې دنده';

  @override
  String get tdActNextSem => 'په لیست کې راتلونکې دنده پرانیزه';

  @override
  String get tdActSend => 'تبصره ولېږه';

  @override
  String get tdActSendSem => 'هغه تبصره ولېږه چې په پرانیستې دنده کې لیکل شوې';

  @override
  String get tdArchivedReadOnly =>
      'دا پروژه آرشیف شوې، نو دندې یې یوازې د لوستلو دي.';

  @override
  String get tdComposerOffline =>
      'آفلاین: پیغامونه ساتل کېږي او د بیا وصل کېدو وروسته لېږل کېږي';

  @override
  String get tdCopyLink => 'لینک کاپي کړه';

  @override
  String get tdDescriptionHint => 'یو تشریح اضافه کړه';

  @override
  String get tdDetails => 'توضیحات';

  @override
  String get tdDueTimeShort => 'د پای وخت';

  @override
  String get tdJumpToLatest => 'وروستی';

  @override
  String get tdKindModal => 'کړکۍ';

  @override
  String get tdKindPeek => 'اړخ پینل';

  @override
  String get tdKindPage => 'بشپړه پاڼه';

  @override
  String get tdLinkCopied => 'لینک کاپي شو';

  @override
  String get tdNeedsAssignee => 'ځینې لیږدونه لومړی د مسؤل اړتیا لري.';

  @override
  String get tdNextTask => 'راتلونکې دنده';

  @override
  String get tdNoPermission => 'تاسو د دندو د سمولو اجازه نه لرئ.';

  @override
  String get tdNotFoundHint =>
      'ښايي ړنګه یا لېږدول شوې وي، یا تاسو لاسرسی ونه لرئ.';

  @override
  String get tdNotSet => 'نه دی ټاکل شوی';

  @override
  String tdOpenAs(String kind) {
    return 'د $kind په توګه پرانیزه';
  }

  @override
  String get tdPreviousTask => 'مخکینۍ دنده';

  @override
  String get tdQueuedOffline => 'په کتار کې، کله چې بیا آنلاین شئ لېږل کېږي';

  @override
  String tdTabNeedsInput(String label) {
    return '$label !';
  }

  @override
  String get tdTabTime => 'وخت';

  @override
  String tdTabWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get tdTrashedBanner => 'دا دنده په ډنګر کې ده.';

  @override
  String get tdUnassigned => 'نه ټاکل شوی';

  @override
  String get tdUnsavedDraft => 'نه خوندي شوی مسوده';

  @override
  String get illusTasks => 'د دندو لیست';

  @override
  String get illusBoard => 'درې ستونونو سره د کارتونو تخته';

  @override
  String get illusCalendar => 'یوه ورځ نخښه شوې تقویم';

  @override
  String get illusTimeline => 'د مهالویش پر کرښه پټۍ';

  @override
  String get illusDocs => 'یوه لیکل شوې پاڼه';

  @override
  String get illusChat => 'دوه د خبرو بلبلې';

  @override
  String get illusInbox => 'د ان‌باکس پیالې سره یو پیغام';

  @override
  String get illusSearch => 'لوپه';

  @override
  String get illusGoals => 'نښه د غشي سره';

  @override
  String get illusTime => 'یوه ساعت';

  @override
  String get illusNoAccess => 'تړل شوی قفل';

  @override
  String get illusOffline => 'یوه ورېځ چې کرښه پرې ایستل شوې';

  @override
  String get illusNotFound => 'یوه پاڼه د لوپې سره';

  @override
  String get illusMaintenance => 'پر سرور یو غاښ‌چرخ';

  @override
  String get illusGeneric => 'یو کارت او یادښت';

  @override
  String get errTitle => 'یوه ستونزه رامنځته شوه';

  @override
  String get errRetry => 'بیا هڅه وکړئ';

  @override
  String get errCopyDetails => 'توضیحات کاپي کړئ';

  @override
  String get errCopied => 'توضیحات کاپي شول';

  @override
  String get sysGoHome => 'کور ته لاړ شئ';

  @override
  String get sysNotFoundTitle => 'دا پاڼه ونه موندل شوه';

  @override
  String get sysNotFoundBody =>
      'ښایي لینک زوړ وي، یا پاڼه ځای پر ځای شوې یا ړنګه شوې وي.';

  @override
  String get sysNoAccessTitle => 'تاسو لاسرسی نه لرئ';

  @override
  String get sysNoAccessBody =>
      'د کاري ځای له مدیر وغواړئ چې لاسرسی درکړي، یا بل کاري ځای ته لاړ شئ.';

  @override
  String get sysOfflineTitle => 'تاسو آفلاین یاست';

  @override
  String get sysOfflineBody =>
      'خپل اړیکه وګورئ. ستاسو بدلونونه دلته ساتل کیږي او کله چې بیرته وصل شئ لیږل کیږي.';

  @override
  String get sysMaintenanceTitle => 'ژر بیرته راځو';

  @override
  String get sysMaintenanceBody =>
      'TaskForge تازه کیږي. ستاسو کار خوندي دی. څو دقیقې وروسته بیا هڅه وکړئ.';

  @override
  String homeGreetMorning(String name) {
    return 'سهار مو پخیر، $name';
  }

  @override
  String homeGreetAfternoon(String name) {
    return 'ماسپښین مو پخیر، $name';
  }

  @override
  String homeGreetEvening(String name) {
    return 'ماښام مو پخیر، $name';
  }

  @override
  String get homeGreetMorningAnon => 'سهار مو پخیر';

  @override
  String get homeGreetAfternoonAnon => 'ماسپښین مو پخیر';

  @override
  String get homeGreetEveningAnon => 'ماښام مو پخیر';

  @override
  String get homeCustomize => 'دودیز کړئ';

  @override
  String get homeCustomizeTitle => 'کورپاڼه دودیز کړئ';

  @override
  String get homeCustomizeHint =>
      'کارتونه ښکاره کړئ، پټ کړئ یا یې ترتیب بدل کړئ. دا په همدې وسیله کې خوندي کیږي.';

  @override
  String get homeReset => 'بیا تنظیم';

  @override
  String get homeAllHidden => 'ټول کارتونه پټ دي';

  @override
  String get homeCardHide => 'کارت پټ کړئ';

  @override
  String get homeCardMenu => 'د کارت اختیارونه';

  @override
  String get homeCardMoveUp => 'پورته یې کړئ';

  @override
  String get homeCardMoveDown => 'ښکته یې کړئ';

  @override
  String get homeCardChecklist => 'پیل';

  @override
  String get homeCardToday => 'نن';

  @override
  String get homeCardAssigned => 'ماته سپارل شوي';

  @override
  String get homeCardMentions => 'یادونې او نالوستل شوې خبرې';

  @override
  String get homeCardRecent => 'وروستي';

  @override
  String get homeCardTime => 'د دې اونۍ وخت';

  @override
  String get homeCardPinned => 'ځوړند شوي ډشبوردونه';

  @override
  String get homeCardFailed => 'دا کارت پورته نه شو.';

  @override
  String homeStale(String time) {
    return 'آفلاین: له $time خوندي شوې کاپي ښودل کیږي';
  }

  @override
  String get homeStaleNoTime => 'آفلاین: خوندي شوې کاپي ښودل کیږي';

  @override
  String get homeTodayEmpty => 'نن هیڅ ټاکلی وخت نشته';

  @override
  String get homeTodayEmptyHint => 'نن یا ځنډیدلې دندې دلته ښکاري.';

  @override
  String get homeStatToday => 'نن ټاکلی';

  @override
  String get homeStatOverdue => 'ځنډیدلې';

  @override
  String get homeStatInProgress => 'روانې';

  @override
  String homeOverdueOn(String date) {
    return 'ځنډیدلې · $date';
  }

  @override
  String get homeAssignedEmpty => 'تاسو ته هیڅ نه دي سپارل شوي';

  @override
  String get homeAssignedEmptyHint =>
      'تاسو ته سپارل شوې دندې دلته د پروژې له مخې ښکاري.';

  @override
  String get homeSeeAll => 'ټول وګورئ';

  @override
  String get homeStatusFailed => 'حالت بدل نه شو.';

  @override
  String get homeRecentEmpty => 'تر اوسه څه نه دي پرانیستل شوي';

  @override
  String get homeRecentEmptyHint => 'هغه دندې چې پرانیزئ دلته ښکاري.';

  @override
  String get homeMentionsEmpty => 'هېڅ یادونه یا نالوستل شوې خبرې نشته';

  @override
  String get homeMentionsEmptyHint => 'تاسو ټول وګورل.';

  @override
  String get homeUnreadNotifications => 'نالوستل شوې خبرتیاوې';

  @override
  String get homeUnreadChat => 'نالوستل شوې خبرې';

  @override
  String get homeOpenInbox => 'ان‌باکس پرانیزئ';

  @override
  String get homeMentionRow => 'ستاسو یادونه وکړه';

  @override
  String get homeTimeEmpty => 'پدې اونۍ کې هېڅ وخت نه دی ثبت شوی';

  @override
  String get homeTimeEmptyHint =>
      'په یوه دنده وخت‌شمیر پیل کړئ ترڅو خپله اونۍ دلته وګورئ.';

  @override
  String get homeTimeOpen => 'د وخت جدول پرانیزئ';

  @override
  String homeTimeTotal(String total) {
    return 'په تېرو ۷ ورځو کې $total ثبت شوی';
  }

  @override
  String homeTimeBar(String day, String time) {
    return '$day: $time';
  }

  @override
  String get homePinnedEmpty => 'هېڅ ځوړند شوي ډشبورډ نشته';

  @override
  String get homePinnedEmptyHint =>
      'یو ډشبورډ ځوړند کړئ ترڅو تل ستاسو په لاس کې وي.';

  @override
  String get homePinnedOpen => 'ډشبوردونه پرانیزئ';

  @override
  String get homeCheckDismiss => 'لرې کول';

  @override
  String homeCheckProgress(String done, String total) {
    return '$done له $total څخه بشپړ شوي';
  }

  @override
  String get homeStepCreateTask => 'یوه دنده جوړه کړئ';

  @override
  String get homeStepInvite => 'یو څوک ور وغواړئ';

  @override
  String get homeStepBoard => 'تخته ازمایئ';

  @override
  String get homeStepPalette => 'د قوماندو پالټ پرانیزئ (Cmd یا Ctrl + K)';

  @override
  String get mwTitle => 'زما کار';

  @override
  String get mwRelationBoth => 'سپارل شوي او تعقیب شوي';

  @override
  String get mwRelationAssigned => 'ماته سپارل شوي';

  @override
  String get mwRelationWatching => 'تعقیب شوي';

  @override
  String get mwIncludeDone => 'بشپړ شوي هم ولري';

  @override
  String get mwEmpty => 'هېڅ نه دي سپارل شوي یا تعقیب شوي';

  @override
  String get mwEmptyHint =>
      'هغه دندې چې تاسو ته سپارل شوې یا تعقیبوئ یې دلته ښکاري.';

  @override
  String get mwNoMatch => 'ستاسو فلټر سره هېڅ دنده نه جوړیږي';

  @override
  String get mwClearFilter => 'فلټر پاک کړئ';

  @override
  String get mwLoadMore => 'نور پورته کړئ';

  @override
  String get mwAssigned => 'سپارل شوې';

  @override
  String get mwWatching => 'تعقیب';

  @override
  String get mwFailed => 'زما کار پورته نه شو.';

  @override
  String obStepOf(String n, String total) {
    return '$n ګام له $total څخه';
  }

  @override
  String get obStarterTitle => 'یو پیل انتخاب کړئ';

  @override
  String get obStarterHint =>
      'د یو چمتو پروژې سره پیل وکړئ. تاسو کولی شئ ټول څه وروسته بدل کړئ.';

  @override
  String get obStarterContinue => 'پروژه جوړه کړئ';

  @override
  String get obStarterCreating => 'ستاسو پروژه جوړیږي…';

  @override
  String get obStarterBlank => 'تش پروژه';

  @override
  String get obStarterBlankDesc => 'د ډیفالټ کاري بهیر سره یوه تشه پروژه.';

  @override
  String get obStarterSoftware => 'د سافټویر ټیم';

  @override
  String get obStarterSoftwareDesc =>
      'بیکلاګ، تخته او د خپرولو بهیر، د نمونې دندو سره.';

  @override
  String get obStarterMarketing => 'بازارموندنه';

  @override
  String get obStarterMarketingDesc =>
      'کمپاینونه، د منځپانګې کلیز او د بیاکتنې پړاوونه، د نمونې دندو سره.';

  @override
  String get obStarterBugs => 'د بګ تعقیبوونکی';

  @override
  String get obStarterBugsDesc =>
      'د راپور، ترتیبولو او سمولو بهیر، د نمونې دندو سره.';

  @override
  String get obInviteTitle => 'خپل ټیم وغواړئ';

  @override
  String get obInviteHint =>
      'اوس ډله‌ییز غړي اضافه کړئ، یا یې پریږدئ او هر وخت له غړو څخه یې وکړئ.';

  @override
  String get obInviteButton => 'ډله‌ییز غړي وغواړئ';

  @override
  String get obInviteSkip => 'همدا اوس پریږدئ';

  @override
  String get obInviteDone => 'خپلې پروژې ته لاړ شئ';

  @override
  String get sampleBadge => 'نمونه';

  @override
  String get sampleBanner =>
      'دا کاري ځای د نمونې دندې لري. دا د «نمونه» په نښه شوې او په راپورونو کې نه شاملیږي.';

  @override
  String get sampleDelete => 'د نمونې دندې ړنګې کړئ';

  @override
  String get sampleDeleted => 'د نمونې دندې ړنګې شوې';

  @override
  String get sampleDeleteFailed => 'د نمونې دندې ړنګې نه شوې.';

  @override
  String wnTitle(String version) {
    return 'په $version کې نوي څه شته';
  }

  @override
  String get wnClose => 'پوه شوم';

  @override
  String get wnHome =>
      'نوې کورپاڼه: ستاسو ورځ، دندې او هغه څه چې ستاسو اړتیا لري، په یو نظر.';

  @override
  String get wnMyWork =>
      '«زما کار» هر هغه څه لیست کوي چې تاسو ته سپارل شوي یا تعقیبوئ یې.';

  @override
  String get wnStarters =>
      'یو کاري ځای د چمتو پروژې او نمونې دندو سره پیل کړئ.';

  @override
  String get wnStates =>
      'په هر ځای کې د تشو، خطا، آفلاین او نه موندل شویو پاڼو روښانه کول.';

  @override
  String get dashPinToHome => 'کورپاڼې ته ځوړند کړئ';

  @override
  String get dashUnpinFromHome => 'له کورپاڼې څخه یې لرې کړئ';

  @override
  String get dashPinned => 'کورپاڼې ته ځوړند شو';

  @override
  String get dashUnpinned => 'له کورپاڼې لرې شو';

  @override
  String get dashPinFailed => 'ځوړندول بدل نه شو.';
}
