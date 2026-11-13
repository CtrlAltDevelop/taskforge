import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ps.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
    Locale('ps'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TaskForge'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @workspaceSettings.
  ///
  /// In en, this message translates to:
  /// **'Workspace settings'**
  String get workspaceSettings;

  /// No description provided for @homeLoadWorkspacesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your workspaces. Retry'**
  String get homeLoadWorkspacesFailed;

  /// No description provided for @homeLoadAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your account.'**
  String get homeLoadAccountFailed;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything due, across your projects'**
  String get calendarSubtitle;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What pings you, quiet hours and the digest'**
  String get notificationSettingsSubtitle;

  /// No description provided for @offlineAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Offline and storage'**
  String get offlineAndStorage;

  /// No description provided for @offlineAndStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes made offline, the local copy'**
  String get offlineAndStorageSubtitle;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @sessionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Devices signed in to your account'**
  String get sessionsSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @connectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivity;

  /// No description provided for @languageAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Language and region'**
  String get languageAndRegion;

  /// No description provided for @languageAndRegionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, calendar, week start and digits'**
  String get languageAndRegionSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @codeFromEmail.
  ///
  /// In en, this message translates to:
  /// **'Code from your email'**
  String get codeFromEmail;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in again.'**
  String get passwordChanged;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in with it.'**
  String get passwordUpdated;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get enterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String passwordTooShort(int min);

  /// No description provided for @enterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email.'**
  String get enterResetCode;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterYourPassword;

  /// No description provided for @errWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errWrongCredentials;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a few minutes.'**
  String get errTooManyAttempts;

  /// No description provided for @errAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account with that email already exists.'**
  String get errAccountExists;

  /// No description provided for @errServerProblem.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Try again in a moment.'**
  String get errServerProblem;

  /// No description provided for @errNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your connection and try again.'**
  String get errNoConnection;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errGeneric;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @calendarSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarSystemLabel;

  /// No description provided for @calendarGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get calendarGregorian;

  /// No description provided for @calendarJalali.
  ///
  /// In en, this message translates to:
  /// **'Jalali (Solar Hijri)'**
  String get calendarJalali;

  /// No description provided for @weekStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartLabel;

  /// No description provided for @weekStartDefault.
  ///
  /// In en, this message translates to:
  /// **'Language default'**
  String get weekStartDefault;

  /// No description provided for @weekSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekSaturday;

  /// No description provided for @weekSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekSunday;

  /// No description provided for @weekMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekMonday;

  /// No description provided for @numeralsLabel.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get numeralsLabel;

  /// No description provided for @numeralsLatin.
  ///
  /// In en, this message translates to:
  /// **'Western (0123)'**
  String get numeralsLatin;

  /// No description provided for @numeralsNative.
  ///
  /// In en, this message translates to:
  /// **'Native to the language'**
  String get numeralsNative;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @prefsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only. We could not reach the server.'**
  String get prefsSaveFailed;

  /// No description provided for @workspaceDefaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default language for new members'**
  String get workspaceDefaultLanguage;

  /// No description provided for @taskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @jalaliMonth1.
  ///
  /// In en, this message translates to:
  /// **'Farvardin'**
  String get jalaliMonth1;

  /// No description provided for @jalaliMonth2.
  ///
  /// In en, this message translates to:
  /// **'Ordibehesht'**
  String get jalaliMonth2;

  /// No description provided for @jalaliMonth3.
  ///
  /// In en, this message translates to:
  /// **'Khordad'**
  String get jalaliMonth3;

  /// No description provided for @jalaliMonth4.
  ///
  /// In en, this message translates to:
  /// **'Tir'**
  String get jalaliMonth4;

  /// No description provided for @jalaliMonth5.
  ///
  /// In en, this message translates to:
  /// **'Mordad'**
  String get jalaliMonth5;

  /// No description provided for @jalaliMonth6.
  ///
  /// In en, this message translates to:
  /// **'Shahrivar'**
  String get jalaliMonth6;

  /// No description provided for @jalaliMonth7.
  ///
  /// In en, this message translates to:
  /// **'Mehr'**
  String get jalaliMonth7;

  /// No description provided for @jalaliMonth8.
  ///
  /// In en, this message translates to:
  /// **'Aban'**
  String get jalaliMonth8;

  /// No description provided for @jalaliMonth9.
  ///
  /// In en, this message translates to:
  /// **'Azar'**
  String get jalaliMonth9;

  /// No description provided for @jalaliMonth10.
  ///
  /// In en, this message translates to:
  /// **'Dey'**
  String get jalaliMonth10;

  /// No description provided for @jalaliMonth11.
  ///
  /// In en, this message translates to:
  /// **'Bahman'**
  String get jalaliMonth11;

  /// No description provided for @jalaliMonth12.
  ///
  /// In en, this message translates to:
  /// **'Esfand'**
  String get jalaliMonth12;

  /// No description provided for @pickDateOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get pickDateOk;

  /// No description provided for @pickDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get pickDateTitle;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @grpACancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpACancel;

  /// No description provided for @grpASave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpASave;

  /// No description provided for @grpARetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpARetry;

  /// No description provided for @grpADone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get grpADone;

  /// No description provided for @grpAClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get grpAClose;

  /// No description provided for @grpAEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get grpAEdit;

  /// No description provided for @grpADelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpADelete;

  /// No description provided for @grpANote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get grpANote;

  /// No description provided for @grpATotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get grpATotal;

  /// No description provided for @grpATask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get grpATask;

  /// No description provided for @grpAMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get grpAMerge;

  /// No description provided for @grpARemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get grpARemove;

  /// No description provided for @grpAOfflineBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpAOfflineBack;

  /// No description provided for @grpAOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline and storage'**
  String get grpAOfflineTitle;

  /// No description provided for @grpAOfflineChooseWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Choose a workspace first.'**
  String get grpAOfflineChooseWorkspace;

  /// No description provided for @grpAOfflineNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get grpAOfflineNeedsAttention;

  /// No description provided for @grpAOfflineNothingToDecide.
  ///
  /// In en, this message translates to:
  /// **'Nothing. Every change made offline was sent.'**
  String get grpAOfflineNothingToDecide;

  /// No description provided for @grpAOfflineWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be sent ({count})'**
  String grpAOfflineWaiting(int count);

  /// No description provided for @grpASyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get grpASyncNow;

  /// No description provided for @grpAOfflineNothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting.'**
  String get grpAOfflineNothingWaiting;

  /// No description provided for @grpAEntryATask.
  ///
  /// In en, this message translates to:
  /// **'a task'**
  String get grpAEntryATask;

  /// No description provided for @grpAEntryNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task “{title}”'**
  String grpAEntryNewTask(String title);

  /// No description provided for @grpAEntryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}: {fields}'**
  String grpAEntryEdit(String name, String fields);

  /// No description provided for @grpAEntryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String grpAEntryDelete(String name);

  /// No description provided for @grpAEntryComment.
  ///
  /// In en, this message translates to:
  /// **'Comment on {name}'**
  String grpAEntryComment(String name);

  /// No description provided for @grpAEntryUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload “{file}” to {name}'**
  String grpAEntryUpload(String file, String name);

  /// No description provided for @grpAOfflineClash.
  ///
  /// In en, this message translates to:
  /// **'Theirs ({field}): {current}\nYours: {mine}'**
  String grpAOfflineClash(String field, String current, String mine);

  /// No description provided for @grpAKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get grpAKeepMine;

  /// No description provided for @grpATakeTheirs.
  ///
  /// In en, this message translates to:
  /// **'Take theirs'**
  String get grpATakeTheirs;

  /// No description provided for @grpATryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get grpATryAgain;

  /// No description provided for @grpADiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get grpADiscard;

  /// No description provided for @grpAMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Which of your changes to keep?'**
  String get grpAMergeTitle;

  /// No description provided for @grpAStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get grpAStorage;

  /// No description provided for @grpAReading.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get grpAReading;

  /// No description provided for @grpAStorageUsage.
  ///
  /// In en, this message translates to:
  /// **'The copy on this device holds {size} MB of at most {cap} MB.'**
  String grpAStorageUsage(String size, int cap);

  /// No description provided for @grpAMostItMayHold.
  ///
  /// In en, this message translates to:
  /// **'Most it may hold'**
  String get grpAMostItMayHold;

  /// No description provided for @grpAMegabytes.
  ///
  /// In en, this message translates to:
  /// **'{mb} MB'**
  String grpAMegabytes(int mb);

  /// No description provided for @grpAClearCopy.
  ///
  /// In en, this message translates to:
  /// **'Clear the copy on this device'**
  String get grpAClearCopy;

  /// No description provided for @grpAStorageNote.
  ///
  /// In en, this message translates to:
  /// **'Changes still waiting to be sent are kept. The copy is stored unencrypted: use your device\'s disk encryption.'**
  String get grpAStorageNote;

  /// No description provided for @grpAClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the copy on this device?'**
  String get grpAClearTitle;

  /// No description provided for @grpAClearBody.
  ///
  /// In en, this message translates to:
  /// **'What you read is fetched again when you are online. Changes waiting to be sent are not removed.'**
  String get grpAClearBody;

  /// No description provided for @grpAClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get grpAClear;

  /// No description provided for @grpAKeepOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep projects offline'**
  String get grpAKeepOfflineTitle;

  /// No description provided for @grpAKeepOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'A kept project is copied whole, so its tasks, statuses and members are there without a connection. Other projects show what you read last.'**
  String get grpAKeepOfflineBody;

  /// No description provided for @grpACopying.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copying… 1 task} other{Copying… {count} tasks}}'**
  String grpACopying(int count);

  /// No description provided for @grpASprintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sprints'**
  String get grpASprintsTitle;

  /// No description provided for @grpASprintsTitleProject.
  ///
  /// In en, this message translates to:
  /// **'Sprints · {name}'**
  String grpASprintsTitleProject(String name);

  /// No description provided for @grpASprintsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Sprints are switched off for this project. Turn them on in the project settings.'**
  String get grpASprintsDisabled;

  /// No description provided for @grpAProjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found.'**
  String get grpAProjectNotFound;

  /// No description provided for @grpAAddedAfterStart.
  ///
  /// In en, this message translates to:
  /// **'{count} added after the sprint started (shows as a scope change).'**
  String grpAAddedAfterStart(int count);

  /// No description provided for @grpASprintCompleted.
  ///
  /// In en, this message translates to:
  /// **'{name} completed.'**
  String grpASprintCompleted(String name);

  /// No description provided for @grpAPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get grpAPlanning;

  /// No description provided for @grpAReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get grpAReports;

  /// No description provided for @grpANewSprint.
  ///
  /// In en, this message translates to:
  /// **'New sprint'**
  String get grpANewSprint;

  /// No description provided for @grpABacklog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get grpABacklog;

  /// No description provided for @grpABacklogEmpty.
  ///
  /// In en, this message translates to:
  /// **'The backlog is empty.'**
  String get grpABacklogEmpty;

  /// No description provided for @grpAAddToSprint.
  ///
  /// In en, this message translates to:
  /// **'Add to sprint'**
  String get grpAAddToSprint;

  /// No description provided for @grpANoOpenSprint.
  ///
  /// In en, this message translates to:
  /// **'No open sprint. Create one to start planning.'**
  String get grpANoOpenSprint;

  /// No description provided for @grpADragHere.
  ///
  /// In en, this message translates to:
  /// **'Drag tasks here, or select some in the backlog.'**
  String get grpADragHere;

  /// No description provided for @grpADatesRange.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String grpADatesRange(String start, String end);

  /// No description provided for @grpADaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String grpADaysLeft(int count);

  /// No description provided for @grpASprintGoalText.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal}'**
  String grpASprintGoalText(String goal);

  /// No description provided for @grpAShowOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Show on board'**
  String get grpAShowOnBoard;

  /// No description provided for @grpAEditSprint.
  ///
  /// In en, this message translates to:
  /// **'Edit sprint'**
  String get grpAEditSprint;

  /// No description provided for @grpAStartSprint.
  ///
  /// In en, this message translates to:
  /// **'Start sprint'**
  String get grpAStartSprint;

  /// No description provided for @grpACompleteSprint.
  ///
  /// In en, this message translates to:
  /// **'Complete sprint'**
  String get grpACompleteSprint;

  /// No description provided for @grpANoSprintsYet.
  ///
  /// In en, this message translates to:
  /// **'No sprints yet.'**
  String get grpANoSprintsYet;

  /// No description provided for @grpASprintNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the sprint a name.'**
  String get grpASprintNameRequired;

  /// No description provided for @grpASprintDatesFormat.
  ///
  /// In en, this message translates to:
  /// **'Dates are written YYYY-MM-DD.'**
  String get grpASprintDatesFormat;

  /// No description provided for @grpASprintEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The sprint cannot end before it starts.'**
  String get grpASprintEndBeforeStart;

  /// No description provided for @grpASprintCapacityNumber.
  ///
  /// In en, this message translates to:
  /// **'Capacity is a number, or empty for none.'**
  String get grpASprintCapacityNumber;

  /// No description provided for @grpASprintSaved.
  ///
  /// In en, this message translates to:
  /// **'Sprint saved'**
  String get grpASprintSaved;

  /// No description provided for @grpASprintName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpASprintName;

  /// No description provided for @grpASprintGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get grpASprintGoal;

  /// No description provided for @grpASprintStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start (YYYY-MM-DD)'**
  String get grpASprintStartLabel;

  /// No description provided for @grpASprintEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End (YYYY-MM-DD)'**
  String get grpASprintEndLabel;

  /// No description provided for @grpAPickStartDate.
  ///
  /// In en, this message translates to:
  /// **'Pick start date'**
  String get grpAPickStartDate;

  /// No description provided for @grpAPickEndDate.
  ///
  /// In en, this message translates to:
  /// **'Pick end date'**
  String get grpAPickEndDate;

  /// No description provided for @grpACapacityPointsOptional.
  ///
  /// In en, this message translates to:
  /// **'Capacity in points (optional)'**
  String get grpACapacityPointsOptional;

  /// No description provided for @grpACapacityHoursOptional.
  ///
  /// In en, this message translates to:
  /// **'Capacity in hours (optional)'**
  String get grpACapacityHoursOptional;

  /// No description provided for @grpASprintOverlap.
  ///
  /// In en, this message translates to:
  /// **'These dates overlap {names}.'**
  String grpASprintOverlap(String names);

  /// No description provided for @grpACompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete {name}'**
  String grpACompleteTitle(String name);

  /// No description provided for @grpACompleteCounts.
  ///
  /// In en, this message translates to:
  /// **'{done} done, {open} unfinished'**
  String grpACompleteCounts(int done, int open);

  /// No description provided for @grpACompleteWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'What happens to the unfinished tasks?'**
  String get grpACompleteWhatHappens;

  /// No description provided for @grpACompleteMoveNext.
  ///
  /// In en, this message translates to:
  /// **'Move to the next sprint'**
  String get grpACompleteMoveNext;

  /// No description provided for @grpACompleteNoPlanned.
  ///
  /// In en, this message translates to:
  /// **'No planned sprint to move them to'**
  String get grpACompleteNoPlanned;

  /// No description provided for @grpACompleteBackToBacklog.
  ///
  /// In en, this message translates to:
  /// **'Back to the backlog'**
  String get grpACompleteBackToBacklog;

  /// No description provided for @grpAPointsFor.
  ///
  /// In en, this message translates to:
  /// **'Points for {key}'**
  String grpAPointsFor(String key);

  /// No description provided for @grpAPointsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a number, or leave empty to clear.'**
  String get grpAPointsInvalid;

  /// No description provided for @grpAStoryPoints.
  ///
  /// In en, this message translates to:
  /// **'Story points'**
  String get grpAStoryPoints;

  /// No description provided for @grpACapacityInHours.
  ///
  /// In en, this message translates to:
  /// **'Capacity in hours'**
  String get grpACapacityInHours;

  /// No description provided for @grpACapacityInPoints.
  ///
  /// In en, this message translates to:
  /// **'Capacity in points'**
  String get grpACapacityInPoints;

  /// No description provided for @grpABurndownTitle.
  ///
  /// In en, this message translates to:
  /// **'Burndown: {name}'**
  String grpABurndownTitle(String name);

  /// No description provided for @grpAPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get grpAPoints;

  /// No description provided for @grpATasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get grpATasks;

  /// No description provided for @grpABurndownEmpty.
  ///
  /// In en, this message translates to:
  /// **'The burndown starts once the sprint is started.'**
  String get grpABurndownEmpty;

  /// No description provided for @grpABurndownChart.
  ///
  /// In en, this message translates to:
  /// **'Burndown chart, {days} days, {changes} scope changes'**
  String grpABurndownChart(int days, int changes);

  /// No description provided for @grpABurndownBackfilled.
  ///
  /// In en, this message translates to:
  /// **', {count} back-filled days'**
  String grpABurndownBackfilled(int count);

  /// No description provided for @grpALegendRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get grpALegendRemaining;

  /// No description provided for @grpALegendIdeal.
  ///
  /// In en, this message translates to:
  /// **'Ideal'**
  String get grpALegendIdeal;

  /// No description provided for @grpALegendScopeChange.
  ///
  /// In en, this message translates to:
  /// **'Scope change'**
  String get grpALegendScopeChange;

  /// No description provided for @grpALegendBackfilled.
  ///
  /// In en, this message translates to:
  /// **'Back-filled day'**
  String get grpALegendBackfilled;

  /// No description provided for @grpAVelocityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Velocity appears after the first completed sprint.'**
  String get grpAVelocityEmpty;

  /// No description provided for @grpAVelocityTitle.
  ///
  /// In en, this message translates to:
  /// **'Velocity (last {count} sprints): average {average} points'**
  String grpAVelocityTitle(int count, String average);

  /// No description provided for @grpAVelocityChart.
  ///
  /// In en, this message translates to:
  /// **'Velocity chart, {count} sprints'**
  String grpAVelocityChart(int count);

  /// No description provided for @grpALegendCommitted.
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get grpALegendCommitted;

  /// No description provided for @grpALegendCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get grpALegendCompleted;

  /// No description provided for @grpATimesheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Timesheet'**
  String get grpATimesheetTitle;

  /// No description provided for @grpAPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get grpAPreviousWeek;

  /// No description provided for @grpANextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get grpANextWeek;

  /// No description provided for @grpAThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get grpAThisWeek;

  /// No description provided for @grpATimesheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No time logged this week.'**
  String get grpATimesheetEmpty;

  /// No description provided for @grpARunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get grpARunning;

  /// No description provided for @grpAAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get grpAAddTime;

  /// No description provided for @grpAYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get grpAYou;

  /// No description provided for @grpAProjectTotals.
  ///
  /// In en, this message translates to:
  /// **'Project totals'**
  String get grpAProjectTotals;

  /// No description provided for @grpAChooseProject.
  ///
  /// In en, this message translates to:
  /// **'Choose a project'**
  String get grpAChooseProject;

  /// No description provided for @grpATotalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No time logged in this project this week.'**
  String get grpATotalsEmpty;

  /// No description provided for @grpABillableAmount.
  ///
  /// In en, this message translates to:
  /// **'  ({duration} billable)'**
  String grpABillableAmount(String duration);

  /// No description provided for @grpAEditTime.
  ///
  /// In en, this message translates to:
  /// **'Edit time'**
  String get grpAEditTime;

  /// No description provided for @grpATimeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get grpATimeSpent;

  /// No description provided for @grpABillable.
  ///
  /// In en, this message translates to:
  /// **'Billable'**
  String get grpABillable;

  /// No description provided for @grpABadDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a time like 1h 30m, 90m or 1:30.'**
  String get grpABadDuration;

  /// No description provided for @grpAEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get grpAEstimate;

  /// No description provided for @grpAEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get grpAEstimatedTime;

  /// No description provided for @grpAEmptyForNone.
  ///
  /// In en, this message translates to:
  /// **'Empty for none'**
  String get grpAEmptyForNone;

  /// No description provided for @grpADeleteTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this time?'**
  String get grpADeleteTimeTitle;

  /// No description provided for @grpADeleteTimeBody.
  ///
  /// In en, this message translates to:
  /// **'The logged time is removed for good.'**
  String get grpADeleteTimeBody;

  /// No description provided for @grpAKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get grpAKeep;

  /// No description provided for @grpBCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpBCancel;

  /// No description provided for @grpBOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get grpBOk;

  /// No description provided for @grpBClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get grpBClose;

  /// No description provided for @grpBSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpBSave;

  /// No description provided for @grpBRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpBRetry;

  /// No description provided for @grpBRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get grpBRestore;

  /// No description provided for @grpBHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get grpBHistory;

  /// No description provided for @grpBCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get grpBCopy;

  /// No description provided for @grpBSaveAsFile.
  ///
  /// In en, this message translates to:
  /// **'Save as file'**
  String get grpBSaveAsFile;

  /// No description provided for @grpBReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get grpBReply;

  /// No description provided for @grpBEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get grpBEdit;

  /// No description provided for @grpBDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpBDelete;

  /// No description provided for @grpBBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpBBack;

  /// No description provided for @grpBSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get grpBSomeone;

  /// No description provided for @grpBYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get grpBYou;

  /// No description provided for @grpBLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get grpBLoading;

  /// No description provided for @grpBPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get grpBPages;

  /// No description provided for @grpBRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get grpBRestricted;

  /// No description provided for @grpBLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get grpBLinkTitle;

  /// No description provided for @grpBLinkAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (http, https or mailto)'**
  String get grpBLinkAddressLabel;

  /// No description provided for @grpBLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use an http, https or mailto address.'**
  String get grpBLinkInvalid;

  /// No description provided for @grpBIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Page icon'**
  String get grpBIconTitle;

  /// No description provided for @grpBIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Emoji or short text (empty for none)'**
  String get grpBIconLabel;

  /// No description provided for @grpBIconInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use at most four characters.'**
  String get grpBIconInvalid;

  /// No description provided for @grpBImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get grpBImageTitle;

  /// No description provided for @grpBImageAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Image address (http or https)'**
  String get grpBImageAddressLabel;

  /// No description provided for @grpBDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get grpBDescription;

  /// No description provided for @grpBImageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use an http or https address.'**
  String get grpBImageInvalid;

  /// No description provided for @grpBEmbedTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Embed a task'**
  String get grpBEmbedTaskTitle;

  /// No description provided for @grpBTaskSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search tasks or paste a task link'**
  String get grpBTaskSearchLabel;

  /// No description provided for @grpBUsePastedTask.
  ///
  /// In en, this message translates to:
  /// **'Use the pasted task'**
  String get grpBUsePastedTask;

  /// No description provided for @grpBSnippetRemoved.
  ///
  /// In en, this message translates to:
  /// **'(removed)'**
  String get grpBSnippetRemoved;

  /// No description provided for @grpBConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this page'**
  String get grpBConflictTitle;

  /// No description provided for @grpBConflictClean.
  ///
  /// In en, this message translates to:
  /// **'Their changes do not overlap with yours. They will be merged.'**
  String get grpBConflictClean;

  /// No description provided for @grpBConflictOverlap.
  ///
  /// In en, this message translates to:
  /// **'Both of you changed these blocks. Choose which to keep; everything else is merged.'**
  String get grpBConflictOverlap;

  /// No description provided for @grpBConflictBlock.
  ///
  /// In en, this message translates to:
  /// **'Block: {snippet}'**
  String grpBConflictBlock(String snippet);

  /// No description provided for @grpBConflictMine.
  ///
  /// In en, this message translates to:
  /// **'Mine: {snippet}'**
  String grpBConflictMine(String snippet);

  /// No description provided for @grpBConflictTheirs.
  ///
  /// In en, this message translates to:
  /// **'Theirs: {snippet}'**
  String grpBConflictTheirs(String snippet);

  /// No description provided for @grpBDecideLater.
  ///
  /// In en, this message translates to:
  /// **'Decide later'**
  String get grpBDecideLater;

  /// No description provided for @grpBDiscardMine.
  ///
  /// In en, this message translates to:
  /// **'Discard mine'**
  String get grpBDiscardMine;

  /// No description provided for @grpBApplyAndSave.
  ///
  /// In en, this message translates to:
  /// **'Apply and save'**
  String get grpBApplyAndSave;

  /// No description provided for @grpBShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Page access'**
  String get grpBShareTitle;

  /// No description provided for @grpBShareRestrict.
  ///
  /// In en, this message translates to:
  /// **'Restrict this page'**
  String get grpBShareRestrict;

  /// No description provided for @grpBShareRestrictedHint.
  ///
  /// In en, this message translates to:
  /// **'Only the people below, its creator and page managers (also for the pages under it).'**
  String get grpBShareRestrictedHint;

  /// No description provided for @grpBShareOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone who can open the parent can open it.'**
  String get grpBShareOpenHint;

  /// No description provided for @grpBShareNeedPermission.
  ///
  /// In en, this message translates to:
  /// **'You need permission \"doc.manage\" to change this.'**
  String get grpBShareNeedPermission;

  /// No description provided for @grpBEmptyPage.
  ///
  /// In en, this message translates to:
  /// **'(empty page)'**
  String get grpBEmptyPage;

  /// No description provided for @grpBImageBlock.
  ///
  /// In en, this message translates to:
  /// **'[Image {alt}]'**
  String grpBImageBlock(String alt);

  /// No description provided for @grpBTaskCardBlock.
  ///
  /// In en, this message translates to:
  /// **'[Task card]'**
  String get grpBTaskCardBlock;

  /// No description provided for @grpBAllRevisions.
  ///
  /// In en, this message translates to:
  /// **'All revisions'**
  String get grpBAllRevisions;

  /// No description provided for @grpBNoRevisions.
  ///
  /// In en, this message translates to:
  /// **'No revisions yet.'**
  String get grpBNoRevisions;

  /// No description provided for @grpBVersionN.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String grpBVersionN(int version);

  /// No description provided for @grpBVersionShort.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String grpBVersionShort(int version);

  /// No description provided for @grpBRevisionsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load history. Retry'**
  String get grpBRevisionsLoadFailed;

  /// No description provided for @grpBRevisionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this revision.'**
  String get grpBRevisionLoadFailed;

  /// No description provided for @grpBRestoreVersion.
  ///
  /// In en, this message translates to:
  /// **'Restore this version'**
  String get grpBRestoreVersion;

  /// No description provided for @grpBLinkedFrom.
  ///
  /// In en, this message translates to:
  /// **'Linked from ({count})'**
  String grpBLinkedFrom(int count);

  /// No description provided for @grpBNoBacklinks.
  ///
  /// In en, this message translates to:
  /// **'No page mentions this one.'**
  String get grpBNoBacklinks;

  /// No description provided for @grpBMarkdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Markdown: {title}'**
  String grpBMarkdownTitle(String title);

  /// No description provided for @grpBMarkdownCopied.
  ///
  /// In en, this message translates to:
  /// **'Markdown copied.'**
  String get grpBMarkdownCopied;

  /// No description provided for @grpBSaveSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get grpBSaveSaved;

  /// No description provided for @grpBSaveDirty.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get grpBSaveDirty;

  /// No description provided for @grpBSaveSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get grpBSaveSaving;

  /// No description provided for @grpBSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get grpBSaveError;

  /// No description provided for @grpBSaveConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict: choose what to keep'**
  String get grpBSaveConflict;

  /// No description provided for @grpBDocsCrumb.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get grpBDocsCrumb;

  /// No description provided for @grpBDocNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page does not exist, or you cannot open it.'**
  String get grpBDocNotFound;

  /// No description provided for @grpBBackToAllPages.
  ///
  /// In en, this message translates to:
  /// **'Back to all pages'**
  String get grpBBackToAllPages;

  /// No description provided for @grpBArchivedBanner.
  ///
  /// In en, this message translates to:
  /// **'This page is archived. It is read-only.'**
  String get grpBArchivedBanner;

  /// No description provided for @grpBConflictBanner.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this page. Your changes are not saved yet.'**
  String get grpBConflictBanner;

  /// No description provided for @grpBResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get grpBResolve;

  /// No description provided for @grpBRemoteBanner.
  ///
  /// In en, this message translates to:
  /// **'A newer version was saved by someone else. It will be merged when you save.'**
  String get grpBRemoteBanner;

  /// No description provided for @grpBIsEditing.
  ///
  /// In en, this message translates to:
  /// **'{name} is editing'**
  String grpBIsEditing(String name);

  /// No description provided for @grpBAreEditing.
  ///
  /// In en, this message translates to:
  /// **'{names} are editing'**
  String grpBAreEditing(String names);

  /// No description provided for @grpBChangeIcon.
  ///
  /// In en, this message translates to:
  /// **'Change icon'**
  String get grpBChangeIcon;

  /// No description provided for @grpBUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get grpBUntitled;

  /// No description provided for @grpBReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get grpBReadOnly;

  /// No description provided for @grpBAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get grpBAccess;

  /// No description provided for @grpBExportMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Export Markdown'**
  String get grpBExportMarkdown;

  /// No description provided for @grpBMoveUnder.
  ///
  /// In en, this message translates to:
  /// **'Move \"{name}\" under'**
  String grpBMoveUnder(String name);

  /// No description provided for @grpBTopLevel.
  ///
  /// In en, this message translates to:
  /// **'Top level'**
  String get grpBTopLevel;

  /// No description provided for @grpBCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get grpBCollapse;

  /// No description provided for @grpBExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get grpBExpand;

  /// No description provided for @grpBPageOptions.
  ///
  /// In en, this message translates to:
  /// **'Page options'**
  String get grpBPageOptions;

  /// No description provided for @grpBNewSubpage.
  ///
  /// In en, this message translates to:
  /// **'New subpage'**
  String get grpBNewSubpage;

  /// No description provided for @grpBMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get grpBMoveUp;

  /// No description provided for @grpBMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get grpBMoveDown;

  /// No description provided for @grpBMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to...'**
  String get grpBMoveTo;

  /// No description provided for @grpBArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get grpBArchive;

  /// No description provided for @grpBHideArchived.
  ///
  /// In en, this message translates to:
  /// **'Hide archived'**
  String get grpBHideArchived;

  /// No description provided for @grpBShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get grpBShowArchived;

  /// No description provided for @grpBNewPage.
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get grpBNewPage;

  /// No description provided for @grpBNoPagesYet.
  ///
  /// In en, this message translates to:
  /// **'No pages yet.'**
  String get grpBNoPagesYet;

  /// No description provided for @grpBPagesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load pages. Retry'**
  String get grpBPagesLoadFailed;

  /// No description provided for @grpBToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get grpBToday;

  /// No description provided for @grpBYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get grpBYesterday;

  /// No description provided for @grpBSubtaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Subtask created.'**
  String get grpBSubtaskCreated;

  /// No description provided for @grpBComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get grpBComments;

  /// No description provided for @grpBCommentsCount.
  ///
  /// In en, this message translates to:
  /// **'Comments ({count})'**
  String grpBCommentsCount(int count);

  /// No description provided for @grpBNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get grpBNoComments;

  /// No description provided for @grpBLoadEarlier.
  ///
  /// In en, this message translates to:
  /// **'Load earlier comments'**
  String get grpBLoadEarlier;

  /// No description provided for @grpBPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get grpBPinned;

  /// No description provided for @grpBReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Reply…'**
  String get grpBReplyHint;

  /// No description provided for @grpBArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This project is archived: comments are read-only.'**
  String get grpBArchivedReadOnly;

  /// No description provided for @grpBReadOnlyComments.
  ///
  /// In en, this message translates to:
  /// **'You can read comments but not write them.'**
  String get grpBReadOnlyComments;

  /// No description provided for @grpBCommentRemoved.
  ///
  /// In en, this message translates to:
  /// **'Comment removed'**
  String get grpBCommentRemoved;

  /// No description provided for @grpBUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get grpBUnpin;

  /// No description provided for @grpBPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get grpBPin;

  /// No description provided for @grpBMakeSubtask.
  ///
  /// In en, this message translates to:
  /// **'Make a subtask'**
  String get grpBMakeSubtask;

  /// No description provided for @grpBEditHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get grpBEditHistory;

  /// No description provided for @grpBEditedTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Edited once: tap to see the history} other{Edited {count} times: tap to see the history}}'**
  String grpBEditedTooltip(int count);

  /// No description provided for @grpBEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get grpBEdited;

  /// No description provided for @grpBCommentActions.
  ///
  /// In en, this message translates to:
  /// **'Comment actions'**
  String get grpBCommentActions;

  /// No description provided for @grpBWaitingToSend.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be sent'**
  String get grpBWaitingToSend;

  /// No description provided for @grpBSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get grpBSending;

  /// No description provided for @grpBNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get grpBNotSent;

  /// No description provided for @grpBDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get grpBDiscard;

  /// No description provided for @grpBAddReaction.
  ///
  /// In en, this message translates to:
  /// **'Add a reaction'**
  String get grpBAddReaction;

  /// No description provided for @grpBAuditAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get grpBAuditAll;

  /// No description provided for @grpBAuditTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get grpBAuditTasks;

  /// No description provided for @grpBAuditFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get grpBAuditFiles;

  /// No description provided for @grpBAuditProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get grpBAuditProjects;

  /// No description provided for @grpBAuditMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get grpBAuditMembers;

  /// No description provided for @grpBAuditRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get grpBAuditRoles;

  /// No description provided for @grpBAuditInvitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get grpBAuditInvitations;

  /// No description provided for @grpBAuditSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get grpBAuditSignIn;

  /// No description provided for @grpBAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get grpBAuditTitle;

  /// No description provided for @grpBExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get grpBExportCsv;

  /// No description provided for @grpBAuditDenied.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to read the audit log.'**
  String get grpBAuditDenied;

  /// No description provided for @grpBAuditEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded for these filters.'**
  String get grpBAuditEmpty;

  /// No description provided for @grpBShowOlder.
  ///
  /// In en, this message translates to:
  /// **'Show older'**
  String get grpBShowOlder;

  /// No description provided for @grpBAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get grpBAnyone;

  /// No description provided for @grpBAnyProject.
  ///
  /// In en, this message translates to:
  /// **'Any project'**
  String get grpBAnyProject;

  /// No description provided for @grpBAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get grpBAnyTime;

  /// No description provided for @grpBClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get grpBClearFilters;

  /// No description provided for @grpBBulkChange.
  ///
  /// In en, this message translates to:
  /// **'Part of a bulk change'**
  String get grpBBulkChange;

  /// No description provided for @grpBCharacters.
  ///
  /// In en, this message translates to:
  /// **'({size} characters)'**
  String grpBCharacters(String size);

  /// No description provided for @grpBNoFieldChanges.
  ///
  /// In en, this message translates to:
  /// **'No field changes recorded.'**
  String get grpBNoFieldChanges;

  /// No description provided for @grpBAuditExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit log (CSV)'**
  String get grpBAuditExportTitle;

  /// No description provided for @grpBAuditExportNote.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {shown} of {total} lines. Copy or Save has all of them.'**
  String grpBAuditExportNote(int shown, int total);

  /// No description provided for @grpBCsvCopied.
  ///
  /// In en, this message translates to:
  /// **'CSV copied.'**
  String get grpBCsvCopied;

  /// No description provided for @grpCCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpCCancel;

  /// No description provided for @grpCDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpCDelete;

  /// No description provided for @grpCRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpCRetry;

  /// No description provided for @grpCBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpCBack;

  /// No description provided for @grpCUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get grpCUndo;

  /// No description provided for @grpCField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get grpCField;

  /// No description provided for @grpCStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get grpCStatus;

  /// No description provided for @grpCComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get grpCComment;

  /// No description provided for @grpCValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get grpCValue;

  /// No description provided for @grpCDashNew.
  ///
  /// In en, this message translates to:
  /// **'New dashboard'**
  String get grpCDashNew;

  /// No description provided for @grpCDashDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String grpCDashDeleteTitle(String name);

  /// No description provided for @grpCDashDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Its widgets go with it. This cannot be undone.'**
  String get grpCDashDeleteBody;

  /// No description provided for @grpCDashTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboards'**
  String get grpCDashTitle;

  /// No description provided for @grpCDashTitleProject.
  ///
  /// In en, this message translates to:
  /// **'Dashboards · {project}'**
  String grpCDashTitleProject(String project);

  /// No description provided for @grpCDashEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dashboards yet.'**
  String get grpCDashEmpty;

  /// No description provided for @grpCDashBlankDashboard.
  ///
  /// In en, this message translates to:
  /// **'Blank dashboard'**
  String get grpCDashBlankDashboard;

  /// No description provided for @grpCDashProjectOverview.
  ///
  /// In en, this message translates to:
  /// **'Project overview'**
  String get grpCDashProjectOverview;

  /// No description provided for @grpCDashMyWork.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get grpCDashMyWork;

  /// No description provided for @grpCDashBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get grpCDashBlank;

  /// No description provided for @grpCDashEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get grpCDashEdit;

  /// No description provided for @grpCDashRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get grpCDashRefresh;

  /// No description provided for @grpCDashAddWidget.
  ///
  /// In en, this message translates to:
  /// **'Add widget'**
  String get grpCDashAddWidget;

  /// No description provided for @grpCDashSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpCDashSave;

  /// No description provided for @grpCDashDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get grpCDashDialogTitle;

  /// No description provided for @grpCDashName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpCDashName;

  /// No description provided for @grpCDashShareDenied.
  ///
  /// In en, this message translates to:
  /// **'Sharing needs the dashboard.manage permission.'**
  String get grpCDashShareDenied;

  /// No description provided for @grpCDashOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get grpCDashOk;

  /// No description provided for @grpCImpTitle.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get grpCImpTitle;

  /// No description provided for @grpCImpExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get grpCImpExport;

  /// No description provided for @grpCImpDenied.
  ///
  /// In en, this message translates to:
  /// **'Only admins can import and export data.'**
  String get grpCImpDenied;

  /// No description provided for @grpCImpPast.
  ///
  /// In en, this message translates to:
  /// **'Past imports'**
  String get grpCImpPast;

  /// No description provided for @grpCImpNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing imported yet.'**
  String get grpCImpNothing;

  /// No description provided for @grpCImpTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String grpCImpTasksCount(int count);

  /// No description provided for @grpCImpResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get grpCImpResume;

  /// No description provided for @grpCImpContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get grpCImpContinue;

  /// No description provided for @grpCImpForget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get grpCImpForget;

  /// No description provided for @grpCImpUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo this import?'**
  String get grpCImpUndoTitle;

  /// No description provided for @grpCImpUndoBody.
  ///
  /// In en, this message translates to:
  /// **'This removes what it made. Anything you added by hand is kept.'**
  String get grpCImpUndoBody;

  /// No description provided for @grpCImpUndoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Undo import'**
  String get grpCImpUndoConfirm;

  /// No description provided for @grpCImpClaimTitle.
  ///
  /// In en, this message translates to:
  /// **'Give {name}\'s tasks to...'**
  String grpCImpClaimTitle(String name);

  /// No description provided for @grpCImpChooseMember.
  ///
  /// In en, this message translates to:
  /// **'Choose a member'**
  String get grpCImpChooseMember;

  /// No description provided for @grpCImpAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get grpCImpAssign;

  /// No description provided for @grpCImpAssigned.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Assigned {n} task.} other{Assigned {n} tasks.}}'**
  String grpCImpAssigned(int n);

  /// No description provided for @grpCImpWaiting.
  ///
  /// In en, this message translates to:
  /// **'People waiting to join'**
  String get grpCImpWaiting;

  /// No description provided for @grpCImpWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Their tasks are assigned automatically when someone joins with the same email.'**
  String get grpCImpWaitingBody;

  /// No description provided for @grpCImpNoEmail.
  ///
  /// In en, this message translates to:
  /// **'no email'**
  String get grpCImpNoEmail;

  /// No description provided for @grpCImpPersonSub.
  ///
  /// In en, this message translates to:
  /// **'{email} · {count, plural, one{{count} task} other{{count} tasks}}'**
  String grpCImpPersonSub(String email, int count);

  /// No description provided for @grpCImpAssignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to...'**
  String get grpCImpAssignTo;

  /// No description provided for @grpCImpStepSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get grpCImpStepSource;

  /// No description provided for @grpCImpStepUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get grpCImpStepUpload;

  /// No description provided for @grpCImpStepMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get grpCImpStepMap;

  /// No description provided for @grpCImpStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get grpCImpStepReview;

  /// No description provided for @grpCImpStepImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get grpCImpStepImport;

  /// No description provided for @grpCImpWhere.
  ///
  /// In en, this message translates to:
  /// **'Where is your data coming from?'**
  String get grpCImpWhere;

  /// No description provided for @grpCImpAuto.
  ///
  /// In en, this message translates to:
  /// **'I am not sure: work it out from the file'**
  String get grpCImpAuto;

  /// No description provided for @grpCImpNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get grpCImpNext;

  /// No description provided for @grpCImpZipSeveral.
  ///
  /// In en, this message translates to:
  /// **'This zip holds several data files. Which one do you want to import? (A workspace export has one per project.)'**
  String get grpCImpZipSeveral;

  /// No description provided for @grpCImpChooseAFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get grpCImpChooseAFile;

  /// No description provided for @grpCImpChooseGeneric.
  ///
  /// In en, this message translates to:
  /// **'Choose the file to import (.csv, .json, or a .zip of one).'**
  String get grpCImpChooseGeneric;

  /// No description provided for @grpCImpChooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose your {source} file (.csv, .json, or a .zip of one).'**
  String grpCImpChooseSource(String source);

  /// No description provided for @grpCImpSentNote.
  ///
  /// In en, this message translates to:
  /// **'The file is sent to your TaskForge server and read as a stream, so large exports are fine. Nothing is changed until you confirm.'**
  String get grpCImpSentNote;

  /// No description provided for @grpCImpPickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get grpCImpPickFile;

  /// No description provided for @grpCImpResumeThis.
  ///
  /// In en, this message translates to:
  /// **'Resume this import'**
  String get grpCImpResumeThis;

  /// No description provided for @grpCImpWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'This is what will happen'**
  String get grpCImpWhatHappens;

  /// No description provided for @grpCImpCountTasks.
  ///
  /// In en, this message translates to:
  /// **'tasks'**
  String get grpCImpCountTasks;

  /// No description provided for @grpCImpCountSubtasks.
  ///
  /// In en, this message translates to:
  /// **'of them sub-tasks'**
  String get grpCImpCountSubtasks;

  /// No description provided for @grpCImpCountComments.
  ///
  /// In en, this message translates to:
  /// **'comments'**
  String get grpCImpCountComments;

  /// No description provided for @grpCImpCountLinks.
  ///
  /// In en, this message translates to:
  /// **'links'**
  String get grpCImpCountLinks;

  /// No description provided for @grpCImpCountSprints.
  ///
  /// In en, this message translates to:
  /// **'sprints'**
  String get grpCImpCountSprints;

  /// No description provided for @grpCImpCountLabels.
  ///
  /// In en, this message translates to:
  /// **'labels'**
  String get grpCImpCountLabels;

  /// No description provided for @grpCImpCountStatuses.
  ///
  /// In en, this message translates to:
  /// **'new statuses'**
  String get grpCImpCountStatuses;

  /// No description provided for @grpCImpCountPlaceholders.
  ///
  /// In en, this message translates to:
  /// **'people to wait for'**
  String get grpCImpCountPlaceholders;

  /// No description provided for @grpCImpAlready.
  ///
  /// In en, this message translates to:
  /// **'{count} of these were imported before and will be skipped, not duplicated.'**
  String grpCImpAlready(int count);

  /// No description provided for @grpCImpRowErrors.
  ///
  /// In en, this message translates to:
  /// **'{count} row(s) cannot be imported and will be left out.'**
  String grpCImpRowErrors(int count);

  /// No description provided for @grpCImpResumeImport.
  ///
  /// In en, this message translates to:
  /// **'Resume import'**
  String get grpCImpResumeImport;

  /// No description provided for @grpCImpStart.
  ///
  /// In en, this message translates to:
  /// **'Start import'**
  String get grpCImpStart;

  /// No description provided for @grpCImpUndoRunBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the tasks, comments, links, sprints and statuses this import made. Anything you added to them by hand is kept.'**
  String get grpCImpUndoRunBody;

  /// No description provided for @grpCImpWaitingStart.
  ///
  /// In en, this message translates to:
  /// **'Waiting to start...'**
  String get grpCImpWaitingStart;

  /// No description provided for @grpCImpLinking.
  ///
  /// In en, this message translates to:
  /// **'Linking tasks...'**
  String get grpCImpLinking;

  /// No description provided for @grpCImpProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks'**
  String grpCImpProgress(int done, int total);

  /// No description provided for @grpCImpCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel import'**
  String get grpCImpCancel;

  /// No description provided for @grpCImpFinished.
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get grpCImpFinished;

  /// No description provided for @grpCImpUndone.
  ///
  /// In en, this message translates to:
  /// **'Import undone'**
  String get grpCImpUndone;

  /// No description provided for @grpCImpCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled'**
  String get grpCImpCancelled;

  /// No description provided for @grpCImpStopped.
  ///
  /// In en, this message translates to:
  /// **'Import stopped'**
  String get grpCImpStopped;

  /// No description provided for @grpCImpOpenProject.
  ///
  /// In en, this message translates to:
  /// **'Open the project'**
  String get grpCImpOpenProject;

  /// No description provided for @grpCImpAnother.
  ///
  /// In en, this message translates to:
  /// **'Import another file'**
  String get grpCImpAnother;

  /// No description provided for @grpCImpRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {tasks} tasks.'**
  String grpCImpRemoved(num tasks);

  /// No description provided for @grpCImpRemovedKept.
  ///
  /// In en, this message translates to:
  /// **'Removed {tasks} tasks, kept {kept} that have your own sub-tasks.'**
  String grpCImpRemovedKept(num tasks, num kept);

  /// No description provided for @grpCImpTheFile.
  ///
  /// In en, this message translates to:
  /// **'the file'**
  String get grpCImpTheFile;

  /// No description provided for @grpCImpSummary.
  ///
  /// In en, this message translates to:
  /// **'{issues} tasks, {comments} comments, {links} links found in {file}.'**
  String grpCImpSummary(int issues, int comments, int links, String file);

  /// No description provided for @grpCImpSummarySub.
  ///
  /// In en, this message translates to:
  /// **'{issues} tasks ({subtasks} sub-tasks), {comments} comments, {links} links found in {file}.'**
  String grpCImpSummarySub(
    int issues,
    int subtasks,
    int comments,
    int links,
    String file,
  );

  /// No description provided for @grpCImpPriUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get grpCImpPriUrgent;

  /// No description provided for @grpCImpPriHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get grpCImpPriHigh;

  /// No description provided for @grpCImpPriNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get grpCImpPriNormal;

  /// No description provided for @grpCImpPriLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get grpCImpPriLow;

  /// No description provided for @grpCImpPriNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get grpCImpPriNone;

  /// No description provided for @grpCImpFTitle.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get grpCImpFTitle;

  /// No description provided for @grpCImpFDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get grpCImpFDescription;

  /// No description provided for @grpCImpFPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get grpCImpFPriority;

  /// No description provided for @grpCImpFAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get grpCImpFAssignee;

  /// No description provided for @grpCImpFReporter.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get grpCImpFReporter;

  /// No description provided for @grpCImpFCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get grpCImpFCreated;

  /// No description provided for @grpCImpFUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get grpCImpFUpdated;

  /// No description provided for @grpCImpFStart.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get grpCImpFStart;

  /// No description provided for @grpCImpFDue.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get grpCImpFDue;

  /// No description provided for @grpCImpFLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get grpCImpFLabels;

  /// No description provided for @grpCImpFSprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint'**
  String get grpCImpFSprint;

  /// No description provided for @grpCImpFParent.
  ///
  /// In en, this message translates to:
  /// **'Parent (id)'**
  String get grpCImpFParent;

  /// No description provided for @grpCImpFId.
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get grpCImpFId;

  /// No description provided for @grpCImpFKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get grpCImpFKey;

  /// No description provided for @grpCImpFPoints.
  ///
  /// In en, this message translates to:
  /// **'Story points'**
  String get grpCImpFPoints;

  /// No description provided for @grpCImpFEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get grpCImpFEstimate;

  /// No description provided for @grpCImpFType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get grpCImpFType;

  /// No description provided for @grpCImpPriorities.
  ///
  /// In en, this message translates to:
  /// **'Priorities'**
  String get grpCImpPriorities;

  /// No description provided for @grpCImpKeepLabels.
  ///
  /// In en, this message translates to:
  /// **'Keep {count} labels'**
  String grpCImpKeepLabels(int count);

  /// No description provided for @grpCImpKeepLabelsSub.
  ///
  /// In en, this message translates to:
  /// **'As a \"Labels\" field on every task.'**
  String get grpCImpKeepLabelsSub;

  /// No description provided for @grpCImpSprintsCreated.
  ///
  /// In en, this message translates to:
  /// **'Sprints that will be created: {sprints}'**
  String grpCImpSprintsCreated(String sprints);

  /// No description provided for @grpCImpReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get grpCImpReview;

  /// No description provided for @grpCImpReadAs.
  ///
  /// In en, this message translates to:
  /// **'Read as'**
  String get grpCImpReadAs;

  /// No description provided for @grpCImpZipFile.
  ///
  /// In en, this message translates to:
  /// **'File inside the zip'**
  String get grpCImpZipFile;

  /// No description provided for @grpCImpChooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get grpCImpChooseOne;

  /// No description provided for @grpCImpInto.
  ///
  /// In en, this message translates to:
  /// **'Import into'**
  String get grpCImpInto;

  /// No description provided for @grpCImpNewProject.
  ///
  /// In en, this message translates to:
  /// **'A new project'**
  String get grpCImpNewProject;

  /// No description provided for @grpCImpExistingProject.
  ///
  /// In en, this message translates to:
  /// **'An existing project'**
  String get grpCImpExistingProject;

  /// No description provided for @grpCImpProjectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get grpCImpProjectName;

  /// No description provided for @grpCImpColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get grpCImpColumns;

  /// No description provided for @grpCImpNotInFile.
  ///
  /// In en, this message translates to:
  /// **'(not in the file)'**
  String get grpCImpNotInFile;

  /// No description provided for @grpCImpStatuses.
  ///
  /// In en, this message translates to:
  /// **'Statuses'**
  String get grpCImpStatuses;

  /// No description provided for @grpCImpSameName.
  ///
  /// In en, this message translates to:
  /// **'Same name (create if missing)'**
  String get grpCImpSameName;

  /// No description provided for @grpCImpPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get grpCImpPeople;

  /// No description provided for @grpCImpNotMember.
  ///
  /// In en, this message translates to:
  /// **'Not a member yet (assign when they join)'**
  String get grpCImpNotMember;

  /// No description provided for @grpCImpUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Leave unassigned'**
  String get grpCImpUnassigned;

  /// No description provided for @grpCImpFirst200.
  ///
  /// In en, this message translates to:
  /// **'Only the first 200 people are listed; the rest wait as placeholders.'**
  String get grpCImpFirst200;

  /// No description provided for @grpCAutoDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String grpCAutoDeleteTitle(String name);

  /// No description provided for @grpCAutoDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The rule stops for good. Its run history is deleted too.'**
  String get grpCAutoDeleteBody;

  /// No description provided for @grpCAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get grpCAutoTitle;

  /// No description provided for @grpCAutoTitleProject.
  ///
  /// In en, this message translates to:
  /// **'Automations · {project}'**
  String grpCAutoTitleProject(String project);

  /// No description provided for @grpCAutoMissing.
  ///
  /// In en, this message translates to:
  /// **'Project not found.'**
  String get grpCAutoMissing;

  /// No description provided for @grpCAutoRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get grpCAutoRules;

  /// No description provided for @grpCAutoRunHistory.
  ///
  /// In en, this message translates to:
  /// **'Run history'**
  String get grpCAutoRunHistory;

  /// No description provided for @grpCAutoNew.
  ///
  /// In en, this message translates to:
  /// **'New automation'**
  String get grpCAutoNew;

  /// No description provided for @grpCAutoReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get grpCAutoReadOnly;

  /// No description provided for @grpCAutoLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit of {limit} rules reached.'**
  String grpCAutoLimit(int limit);

  /// No description provided for @grpCAutoRuleFilter.
  ///
  /// In en, this message translates to:
  /// **'Rule: {name}'**
  String grpCAutoRuleFilter(String name);

  /// No description provided for @grpCAutoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No automations yet. A rule says: when something happens, and if it matches, then do these things.'**
  String get grpCAutoEmpty;

  /// No description provided for @grpCAutoWhen.
  ///
  /// In en, this message translates to:
  /// **'When {trigger} · {count, plural, one{{count} action} other{{count} actions}}'**
  String grpCAutoWhen(String trigger, int count);

  /// No description provided for @grpCAutoNeverRun.
  ///
  /// In en, this message translates to:
  /// **'Never run'**
  String get grpCAutoNeverRun;

  /// No description provided for @grpCAutoHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get grpCAutoHistory;

  /// No description provided for @grpCAutoDryRun.
  ///
  /// In en, this message translates to:
  /// **'Dry run'**
  String get grpCAutoDryRun;

  /// No description provided for @grpCAutoStatusChanges.
  ///
  /// In en, this message translates to:
  /// **'a status changes'**
  String get grpCAutoStatusChanges;

  /// No description provided for @grpCAutoMovesTo.
  ///
  /// In en, this message translates to:
  /// **'a task moves to {status}'**
  String grpCAutoMovesTo(String status);

  /// No description provided for @grpCAutoFieldChanges.
  ///
  /// In en, this message translates to:
  /// **'{field} changes'**
  String grpCAutoFieldChanges(String field);

  /// No description provided for @grpCAutoSomeoneAssigned.
  ///
  /// In en, this message translates to:
  /// **'someone is assigned'**
  String get grpCAutoSomeoneAssigned;

  /// No description provided for @grpCAutoUserAssigned.
  ///
  /// In en, this message translates to:
  /// **'{user} is assigned'**
  String grpCAutoUserAssigned(String user);

  /// No description provided for @grpCAutoDueReached.
  ///
  /// In en, this message translates to:
  /// **'a due date is reached'**
  String get grpCAutoDueReached;

  /// No description provided for @grpCAutoDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{days} days before a due date'**
  String grpCAutoDaysBefore(int days);

  /// No description provided for @grpCAutoDeletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Deleted status'**
  String get grpCAutoDeletedStatus;

  /// No description provided for @grpCAutoUnknownPerson.
  ///
  /// In en, this message translates to:
  /// **'Unknown person'**
  String get grpCAutoUnknownPerson;

  /// No description provided for @grpCAutoEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get grpCAutoEvent;

  /// No description provided for @grpCAutoMovesToLabel.
  ///
  /// In en, this message translates to:
  /// **'Moves to'**
  String get grpCAutoMovesToLabel;

  /// No description provided for @grpCAutoAnyStatus.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get grpCAutoAnyStatus;

  /// No description provided for @grpCAutoAssignedPerson.
  ///
  /// In en, this message translates to:
  /// **'Assigned person'**
  String get grpCAutoAssignedPerson;

  /// No description provided for @grpCAutoAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get grpCAutoAnyone;

  /// No description provided for @grpCAutoDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days before the due date (0 to {max})'**
  String grpCAutoDaysLabel(int max);

  /// No description provided for @grpCAutoTokensHelp.
  ///
  /// In en, this message translates to:
  /// **'You may use {tokens}'**
  String grpCAutoTokensHelp(String tokens);

  /// No description provided for @grpCAutoDateHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get grpCAutoDateHint;

  /// No description provided for @grpCAutoUseToken.
  ///
  /// In en, this message translates to:
  /// **'Use {token}'**
  String grpCAutoUseToken(String token);

  /// No description provided for @grpCAutoHow.
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get grpCAutoHow;

  /// No description provided for @grpCAutoReplaceAssignees.
  ///
  /// In en, this message translates to:
  /// **'Replace assignees with'**
  String get grpCAutoReplaceAssignees;

  /// No description provided for @grpCAutoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get grpCAutoAdd;

  /// No description provided for @grpCAutoRemoveEveryone.
  ///
  /// In en, this message translates to:
  /// **'Remove everyone'**
  String get grpCAutoRemoveEveryone;

  /// No description provided for @grpCAutoSubtaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtask title'**
  String get grpCAutoSubtaskTitle;

  /// No description provided for @grpCAutoMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get grpCAutoMessage;

  /// No description provided for @grpCAutoAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get grpCAutoAddress;

  /// No description provided for @grpCAutoAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'Public http(s) addresses only; private ones are refused.'**
  String get grpCAutoAddressHelp;

  /// No description provided for @grpCAutoMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get grpCAutoMethod;

  /// No description provided for @grpCAutoDoThis.
  ///
  /// In en, this message translates to:
  /// **'Do this'**
  String get grpCAutoDoThis;

  /// No description provided for @grpDActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not work ({error}).'**
  String grpDActionFailed(String error);

  /// No description provided for @grpDSwitchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch workspace'**
  String get grpDSwitchWorkspace;

  /// No description provided for @grpDWorkspaceHere.
  ///
  /// In en, this message translates to:
  /// **'{name} (here)'**
  String grpDWorkspaceHere(String name);

  /// No description provided for @grpDNewDoc.
  ///
  /// In en, this message translates to:
  /// **'New doc'**
  String get grpDNewDoc;

  /// No description provided for @grpDTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get grpDTitle;

  /// No description provided for @grpDUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get grpDUntitled;

  /// No description provided for @grpDNewDashboard.
  ///
  /// In en, this message translates to:
  /// **'New dashboard'**
  String get grpDNewDashboard;

  /// No description provided for @grpDNewSprint.
  ///
  /// In en, this message translates to:
  /// **'New sprint'**
  String get grpDNewSprint;

  /// No description provided for @grpDStatusOf.
  ///
  /// In en, this message translates to:
  /// **'Status of {id}'**
  String grpDStatusOf(String id);

  /// No description provided for @grpDNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get grpDNewTask;

  /// No description provided for @grpDCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpDCancel;

  /// No description provided for @grpDCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get grpDCreate;

  /// No description provided for @grpDSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get grpDSort;

  /// No description provided for @grpDNoSort.
  ///
  /// In en, this message translates to:
  /// **'No sort'**
  String get grpDNoSort;

  /// No description provided for @grpDSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort: {names}'**
  String grpDSortBy(String names);

  /// No description provided for @grpDGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get grpDGroup;

  /// No description provided for @grpDNoGrouping.
  ///
  /// In en, this message translates to:
  /// **'No grouping'**
  String get grpDNoGrouping;

  /// No description provided for @grpDGroupBy.
  ///
  /// In en, this message translates to:
  /// **'Group: {name}'**
  String grpDGroupBy(String name);

  /// No description provided for @grpDColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get grpDColumns;

  /// No description provided for @grpDRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get grpDRefresh;

  /// No description provided for @grpDLayoutNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your layout could not be saved. It will be tried again on your next change.'**
  String get grpDLayoutNotSaved;

  /// No description provided for @grpDLayouts.
  ///
  /// In en, this message translates to:
  /// **'Layouts'**
  String get grpDLayouts;

  /// No description provided for @grpDResetLayout.
  ///
  /// In en, this message translates to:
  /// **'Reset my layout'**
  String get grpDResetLayout;

  /// No description provided for @grpDShareLayoutMenu.
  ///
  /// In en, this message translates to:
  /// **'Share this layout…'**
  String get grpDShareLayoutMenu;

  /// No description provided for @grpDDeleteShared.
  ///
  /// In en, this message translates to:
  /// **'Delete shared “{name}”'**
  String grpDDeleteShared(String name);

  /// No description provided for @grpDDeleteSharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String grpDDeleteSharedTitle(String name);

  /// No description provided for @grpDDeleteSharedBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears for everyone on this project.'**
  String get grpDDeleteSharedBody;

  /// No description provided for @grpDDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpDDelete;

  /// No description provided for @grpDDeletedNamed.
  ///
  /// In en, this message translates to:
  /// **'Deleted “{name}”'**
  String grpDDeletedNamed(String name);

  /// No description provided for @grpDSharedNamed.
  ///
  /// In en, this message translates to:
  /// **'Shared “{name}”'**
  String grpDSharedNamed(String name);

  /// No description provided for @grpDShareLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Share this layout'**
  String get grpDShareLayoutTitle;

  /// No description provided for @grpDName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpDName;

  /// No description provided for @grpDShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get grpDShare;

  /// No description provided for @grpDTaskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found.'**
  String get grpDTaskNotFound;

  /// No description provided for @grpDDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get grpDDeleteTask;

  /// No description provided for @grpDClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get grpDClose;

  /// No description provided for @grpDPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get grpDPriority;

  /// No description provided for @grpDStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get grpDStart;

  /// No description provided for @grpDDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get grpDDue;

  /// No description provided for @grpDAssignees.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get grpDAssignees;

  /// No description provided for @grpDDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get grpDDescription;

  /// No description provided for @grpDTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'{id} deleted'**
  String grpDTaskDeleted(String id);

  /// No description provided for @grpDUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get grpDUndo;

  /// No description provided for @grpDStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get grpDStatus;

  /// No description provided for @grpDClearField.
  ///
  /// In en, this message translates to:
  /// **'Clear {label}'**
  String grpDClearField(String label);

  /// No description provided for @grpDDueTime.
  ///
  /// In en, this message translates to:
  /// **'Due time (your clock)'**
  String get grpDDueTime;

  /// No description provided for @grpDClearDueTime.
  ///
  /// In en, this message translates to:
  /// **'Clear due time'**
  String get grpDClearDueTime;

  /// No description provided for @grpDAllOf.
  ///
  /// In en, this message translates to:
  /// **'All of'**
  String get grpDAllOf;

  /// No description provided for @grpDAnyOf.
  ///
  /// In en, this message translates to:
  /// **'Any of'**
  String get grpDAnyOf;

  /// No description provided for @grpDNot.
  ///
  /// In en, this message translates to:
  /// **'NOT'**
  String get grpDNot;

  /// No description provided for @grpDRemoveGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove group'**
  String get grpDRemoveGroup;

  /// No description provided for @grpDCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get grpDCondition;

  /// No description provided for @grpDFieldRemoved.
  ///
  /// In en, this message translates to:
  /// **'Field (removed)'**
  String get grpDFieldRemoved;

  /// No description provided for @grpDRemoveCondition.
  ///
  /// In en, this message translates to:
  /// **'Remove condition'**
  String get grpDRemoveCondition;

  /// No description provided for @grpDOpBefore.
  ///
  /// In en, this message translates to:
  /// **'is before'**
  String get grpDOpBefore;

  /// No description provided for @grpDOpOnOrBefore.
  ///
  /// In en, this message translates to:
  /// **'is on or before'**
  String get grpDOpOnOrBefore;

  /// No description provided for @grpDOpAfter.
  ///
  /// In en, this message translates to:
  /// **'is after'**
  String get grpDOpAfter;

  /// No description provided for @grpDOpOnOrAfter.
  ///
  /// In en, this message translates to:
  /// **'is on or after'**
  String get grpDOpOnOrAfter;

  /// No description provided for @grpDOpLessThan.
  ///
  /// In en, this message translates to:
  /// **'is less than'**
  String get grpDOpLessThan;

  /// No description provided for @grpDOpAtMost.
  ///
  /// In en, this message translates to:
  /// **'is at most'**
  String get grpDOpAtMost;

  /// No description provided for @grpDOpMoreThan.
  ///
  /// In en, this message translates to:
  /// **'is more than'**
  String get grpDOpMoreThan;

  /// No description provided for @grpDOpAtLeast.
  ///
  /// In en, this message translates to:
  /// **'is at least'**
  String get grpDOpAtLeast;

  /// No description provided for @grpDYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get grpDYes;

  /// No description provided for @grpDNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get grpDNo;

  /// No description provided for @grpDCurrentSprint.
  ///
  /// In en, this message translates to:
  /// **'the current sprint'**
  String get grpDCurrentSprint;

  /// No description provided for @grpDMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get grpDMe;

  /// No description provided for @grpDChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose…'**
  String get grpDChoose;

  /// No description provided for @grpDValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get grpDValue;

  /// No description provided for @grpDPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get grpDPickDate;

  /// No description provided for @grpDOrderByLabel.
  ///
  /// In en, this message translates to:
  /// **'Order by '**
  String get grpDOrderByLabel;

  /// No description provided for @grpDAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get grpDAscending;

  /// No description provided for @grpDDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get grpDDescending;

  /// No description provided for @grpDRemoveOrdering.
  ///
  /// In en, this message translates to:
  /// **'Remove ordering'**
  String get grpDRemoveOrdering;

  /// No description provided for @grpDOrderBy.
  ///
  /// In en, this message translates to:
  /// **'Order by'**
  String get grpDOrderBy;

  /// No description provided for @grpDRepeatNothingToUpdate.
  ///
  /// In en, this message translates to:
  /// **'New tasks will use this one. No open task needed changing.'**
  String get grpDRepeatNothingToUpdate;

  /// No description provided for @grpDRepeatUpdatedLater.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} open later {count, plural, =1{task} other{tasks}}.'**
  String grpDRepeatUpdatedLater(int count);

  /// No description provided for @grpDRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get grpDRepeat;

  /// No description provided for @grpDRepeatUnsupported.
  ///
  /// In en, this message translates to:
  /// **'\"{summary}\" was set in a way this editor cannot show, so it cannot be changed here. You can still pause or stop it.'**
  String grpDRepeatUnsupported(String summary);

  /// No description provided for @grpDSkipWeekends.
  ///
  /// In en, this message translates to:
  /// **'Skip weekends'**
  String get grpDSkipWeekends;

  /// No description provided for @grpDStopRepeating.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating'**
  String get grpDStopRepeating;

  /// No description provided for @grpDResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get grpDResume;

  /// No description provided for @grpDPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get grpDPause;

  /// No description provided for @grpDUseForFuture.
  ///
  /// In en, this message translates to:
  /// **'Use this task for future ones'**
  String get grpDUseForFuture;

  /// No description provided for @grpDSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpDSave;

  /// No description provided for @grpDEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get grpDEvery;

  /// No description provided for @grpDRepeatByDay.
  ///
  /// In en, this message translates to:
  /// **'On a day of the month'**
  String get grpDRepeatByDay;

  /// No description provided for @grpDRepeatByWeekday.
  ///
  /// In en, this message translates to:
  /// **'On the nth weekday'**
  String get grpDRepeatByWeekday;

  /// No description provided for @grpDDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String grpDDayNumber(int day);

  /// No description provided for @grpDNth1.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get grpDNth1;

  /// No description provided for @grpDNth2.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get grpDNth2;

  /// No description provided for @grpDNth3.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get grpDNth3;

  /// No description provided for @grpDNth4.
  ///
  /// In en, this message translates to:
  /// **'4th'**
  String get grpDNth4;

  /// No description provided for @grpDNthLast.
  ///
  /// In en, this message translates to:
  /// **'last'**
  String get grpDNthLast;

  /// No description provided for @grpDEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get grpDEnds;

  /// No description provided for @grpDEndNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get grpDEndNever;

  /// No description provided for @grpDEndAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get grpDEndAfter;

  /// No description provided for @grpDEndOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get grpDEndOn;

  /// No description provided for @grpDTasksWord.
  ///
  /// In en, this message translates to:
  /// **'tasks'**
  String get grpDTasksWord;

  /// No description provided for @grpDMakeIt.
  ///
  /// In en, this message translates to:
  /// **'Make it'**
  String get grpDMakeIt;

  /// No description provided for @grpDDaysAhead.
  ///
  /// In en, this message translates to:
  /// **'days ahead of its due date'**
  String get grpDDaysAhead;

  /// No description provided for @grpDRepeatAt.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String grpDRepeatAt(String time);

  /// No description provided for @grpDNoFurtherDates.
  ///
  /// In en, this message translates to:
  /// **'No further dates.'**
  String get grpDNoFurtherDates;

  /// No description provided for @grpDNextDates.
  ///
  /// In en, this message translates to:
  /// **'Next: {dates}'**
  String grpDNextDates(String dates);

  /// No description provided for @grpEBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpEBack;

  /// No description provided for @grpECancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpECancel;

  /// No description provided for @grpEName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpEName;

  /// No description provided for @grpERetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpERetry;

  /// No description provided for @grpEWorkspaceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace settings'**
  String get grpEWorkspaceSettingsTitle;

  /// No description provided for @grpEWorkspacesLoadRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load your workspaces. Retry'**
  String get grpEWorkspacesLoadRetry;

  /// No description provided for @grpEMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get grpEMembers;

  /// No description provided for @grpEMembersSub.
  ///
  /// In en, this message translates to:
  /// **'People, invitations and leaving'**
  String get grpEMembersSub;

  /// No description provided for @grpERolesPerms.
  ///
  /// In en, this message translates to:
  /// **'Roles and permissions'**
  String get grpERolesPerms;

  /// No description provided for @grpERolesPermsSub.
  ///
  /// In en, this message translates to:
  /// **'Who can do what'**
  String get grpERolesPermsSub;

  /// No description provided for @grpEAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get grpEAuditLog;

  /// No description provided for @grpEAuditLogSub.
  ///
  /// In en, this message translates to:
  /// **'Who changed what, and when'**
  String get grpEAuditLogSub;

  /// No description provided for @grpEImportExport.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get grpEImportExport;

  /// No description provided for @grpEImportExportSub.
  ///
  /// In en, this message translates to:
  /// **'Bring in Jira, ClickUp or CSV data; take it out'**
  String get grpEImportExportSub;

  /// No description provided for @grpEWorkspaceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Workspace updated.'**
  String get grpEWorkspaceUpdated;

  /// No description provided for @grpEGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get grpEGeneral;

  /// No description provided for @grpEChangeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change logo'**
  String get grpEChangeLogo;

  /// No description provided for @grpEUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get grpEUrl;

  /// No description provided for @grpERefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get grpERefresh;

  /// No description provided for @grpESaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get grpESaveChanges;

  /// No description provided for @grpENotifSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get grpENotifSettings;

  /// No description provided for @grpEPushOffNotice.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for this device. You can allow them in the system settings; the choice is saved.'**
  String get grpEPushOffNotice;

  /// No description provided for @grpEZoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a name like Europe/Paris or UTC.'**
  String get grpEZoneInvalid;

  /// No description provided for @grpEQuietDifferent.
  ///
  /// In en, this message translates to:
  /// **'Start and end must be different times.'**
  String get grpEQuietDifferent;

  /// No description provided for @grpEWhatReachesYou.
  ///
  /// In en, this message translates to:
  /// **'What reaches you'**
  String get grpEWhatReachesYou;

  /// No description provided for @grpEInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get grpEInbox;

  /// No description provided for @grpEPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get grpEPush;

  /// No description provided for @grpEEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get grpEEmail;

  /// No description provided for @grpEQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get grpEQuietHours;

  /// No description provided for @grpEQuietHold.
  ///
  /// In en, this message translates to:
  /// **'Hold push and email during quiet hours'**
  String get grpEQuietHold;

  /// No description provided for @grpEQuietHoldSub.
  ///
  /// In en, this message translates to:
  /// **'The inbox always fills; only pings wait.'**
  String get grpEQuietHoldSub;

  /// No description provided for @grpEFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get grpEFrom;

  /// No description provided for @grpEUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get grpEUntil;

  /// No description provided for @grpETimeZoneDigest.
  ///
  /// In en, this message translates to:
  /// **'Time zone and digest'**
  String get grpETimeZoneDigest;

  /// No description provided for @grpETimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get grpETimeZone;

  /// No description provided for @grpETimeZoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours and the digest follow this zone.'**
  String get grpETimeZoneHelper;

  /// No description provided for @grpEUseDeviceZone.
  ///
  /// In en, this message translates to:
  /// **'Use this device’s time zone'**
  String get grpEUseDeviceZone;

  /// No description provided for @grpETypeZone.
  ///
  /// In en, this message translates to:
  /// **'Type your time zone instead, e.g. Europe/Paris.'**
  String get grpETypeZone;

  /// No description provided for @grpEDigestAt.
  ///
  /// In en, this message translates to:
  /// **'Daily digest is sent at'**
  String get grpEDigestAt;

  /// No description provided for @grpEEditField.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get grpEEditField;

  /// No description provided for @grpENewField.
  ///
  /// In en, this message translates to:
  /// **'New field'**
  String get grpENewField;

  /// No description provided for @grpEType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get grpEType;

  /// No description provided for @grpEOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get grpEOptions;

  /// No description provided for @grpEColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get grpEColour;

  /// No description provided for @grpELabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get grpELabel;

  /// No description provided for @grpERemoveOption.
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get grpERemoveOption;

  /// No description provided for @grpEAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get grpEAddOption;

  /// No description provided for @grpERequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get grpERequired;

  /// No description provided for @grpERequiredSub.
  ///
  /// In en, this message translates to:
  /// **'New tasks must have a value.'**
  String get grpERequiredSub;

  /// No description provided for @grpEDefaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default value'**
  String get grpEDefaultValue;

  /// No description provided for @grpEShowIn.
  ///
  /// In en, this message translates to:
  /// **'Show in'**
  String get grpEShowIn;

  /// No description provided for @grpESave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpESave;

  /// No description provided for @grpEAddField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get grpEAddField;

  /// No description provided for @grpEOptionN.
  ///
  /// In en, this message translates to:
  /// **'Option 1'**
  String get grpEOptionN;

  /// No description provided for @grpEProblemName.
  ///
  /// In en, this message translates to:
  /// **'Give the field a name.'**
  String get grpEProblemName;

  /// No description provided for @grpEProblemOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one option.'**
  String get grpEProblemOne;

  /// No description provided for @grpEProblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Every option needs a label.'**
  String get grpEProblemLabel;

  /// No description provided for @grpEProblemDup.
  ///
  /// In en, this message translates to:
  /// **'Two options have the same label.'**
  String get grpEProblemDup;

  /// No description provided for @grpEOptionsInUse.
  ///
  /// In en, this message translates to:
  /// **'Options are in use'**
  String get grpEOptionsInUse;

  /// No description provided for @grpERemovedOption.
  ///
  /// In en, this message translates to:
  /// **'Removed option'**
  String get grpERemovedOption;

  /// No description provided for @grpERemapLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count, plural, =1{1 value} other{{count} values}}) becomes'**
  String grpERemapLabel(String label, int count);

  /// No description provided for @grpENothingClear.
  ///
  /// In en, this message translates to:
  /// **'Nothing (clear)'**
  String get grpENothingClear;

  /// No description provided for @grpEApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get grpEApply;

  /// No description provided for @grpEPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get grpEPrivate;

  /// No description provided for @grpESprints.
  ///
  /// In en, this message translates to:
  /// **'Sprints'**
  String get grpESprints;

  /// No description provided for @grpEAutomations.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get grpEAutomations;

  /// No description provided for @grpESearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get grpESearch;

  /// No description provided for @grpETimesheet.
  ///
  /// In en, this message translates to:
  /// **'Timesheet'**
  String get grpETimesheet;

  /// No description provided for @grpEDashboards.
  ///
  /// In en, this message translates to:
  /// **'Dashboards'**
  String get grpEDashboards;

  /// No description provided for @grpEDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get grpEDocs;

  /// No description provided for @grpEProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get grpEProjects;

  /// No description provided for @grpENewProject.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get grpENewProject;

  /// No description provided for @grpEFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get grpEFavorites;

  /// No description provided for @grpEProjectsLoadRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load projects. Retry'**
  String get grpEProjectsLoadRetry;

  /// No description provided for @grpEArchivedProjects.
  ///
  /// In en, this message translates to:
  /// **'Archived projects'**
  String get grpEArchivedProjects;

  /// No description provided for @grpEPrivateProjects.
  ///
  /// In en, this message translates to:
  /// **'Private projects'**
  String get grpEPrivateProjects;

  /// No description provided for @grpENoProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get grpENoProjects;

  /// No description provided for @grpECreateFirstProject.
  ///
  /// In en, this message translates to:
  /// **'Create your first project'**
  String get grpECreateFirstProject;

  /// No description provided for @grpEMonth1.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get grpEMonth1;

  /// No description provided for @grpEMonth2.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get grpEMonth2;

  /// No description provided for @grpEMonth3.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get grpEMonth3;

  /// No description provided for @grpEMonth4.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get grpEMonth4;

  /// No description provided for @grpEMonth5.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get grpEMonth5;

  /// No description provided for @grpEMonth6.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get grpEMonth6;

  /// No description provided for @grpEMonth7.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get grpEMonth7;

  /// No description provided for @grpEMonth8.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get grpEMonth8;

  /// No description provided for @grpEMonth9.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get grpEMonth9;

  /// No description provided for @grpEMonth10.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get grpEMonth10;

  /// No description provided for @grpEMonth11.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get grpEMonth11;

  /// No description provided for @grpEMonth12.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get grpEMonth12;

  /// No description provided for @grpEWeekLocale.
  ///
  /// In en, this message translates to:
  /// **'Locale default'**
  String get grpEWeekLocale;

  /// No description provided for @grpEMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get grpEMonday;

  /// No description provided for @grpESaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get grpESaturday;

  /// No description provided for @grpESunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get grpESunday;

  /// No description provided for @grpEPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get grpEPrevious;

  /// No description provided for @grpENext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get grpENext;

  /// No description provided for @grpEToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get grpEToday;

  /// No description provided for @grpEUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get grpEUnscheduled;

  /// No description provided for @grpEMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get grpEMonth;

  /// No description provided for @grpEWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get grpEWeek;

  /// No description provided for @grpEDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get grpEDay;

  /// No description provided for @grpEColourBy.
  ///
  /// In en, this message translates to:
  /// **'Colour by'**
  String get grpEColourBy;

  /// No description provided for @grpEColourByProject.
  ///
  /// In en, this message translates to:
  /// **'Colour by project'**
  String get grpEColourByProject;

  /// No description provided for @grpEColourByStatus.
  ///
  /// In en, this message translates to:
  /// **'Colour by status'**
  String get grpEColourByStatus;

  /// No description provided for @grpEColourByPriority.
  ///
  /// In en, this message translates to:
  /// **'Colour by priority'**
  String get grpEColourByPriority;

  /// No description provided for @grpEColourChip.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get grpEColourChip;

  /// No description provided for @grpEWeekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get grpEWeekStartsOn;

  /// No description provided for @grpEHideDone.
  ///
  /// In en, this message translates to:
  /// **'Hide done'**
  String get grpEHideDone;

  /// No description provided for @grpELayoutNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your calendar layout could not be saved. It will be tried again on your next change.'**
  String get grpELayoutNotSaved;

  /// No description provided for @grpEEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get grpEEnterName;

  /// No description provided for @grpENewRole.
  ///
  /// In en, this message translates to:
  /// **'New role'**
  String get grpENewRole;

  /// No description provided for @grpECreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get grpECreate;

  /// No description provided for @grpERenameRole.
  ///
  /// In en, this message translates to:
  /// **'Rename role'**
  String get grpERenameRole;

  /// No description provided for @grpERename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get grpERename;

  /// No description provided for @grpEDeleteRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String grpEDeleteRoleTitle(String name);

  /// No description provided for @grpERoleNoOne.
  ///
  /// In en, this message translates to:
  /// **'No one has this role.'**
  String get grpERoleNoOne;

  /// No description provided for @grpERoleMoveMembers.
  ///
  /// In en, this message translates to:
  /// **'{count} member(s) have this role. Move them to:'**
  String grpERoleMoveMembers(int count);

  /// No description provided for @grpEChooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose a role'**
  String get grpEChooseRole;

  /// No description provided for @grpEDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpEDelete;

  /// No description provided for @grpFBulkDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks deleted'**
  String grpFBulkDeleted(int count);

  /// No description provided for @grpFBulkUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks updated'**
  String grpFBulkUpdated(int count);

  /// No description provided for @grpFBulkPartialDeleted.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks deleted; {failed} could not be.'**
  String grpFBulkPartialDeleted(int done, int total, int failed);

  /// No description provided for @grpFBulkPartialUpdated.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks updated; {failed} could not be.'**
  String grpFBulkPartialUpdated(int done, int total, int failed);

  /// No description provided for @grpFDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get grpFDetails;

  /// No description provided for @grpFBulkDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} tasks?'**
  String grpFBulkDeleteTitle(int count);

  /// No description provided for @grpFBulkDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Their subtasks go with them. You can restore them from the trash.'**
  String get grpFBulkDeleteBody;

  /// No description provided for @grpFDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpFDelete;

  /// No description provided for @grpFSetStatus.
  ///
  /// In en, this message translates to:
  /// **'Set status'**
  String get grpFSetStatus;

  /// No description provided for @grpFSetPriority.
  ///
  /// In en, this message translates to:
  /// **'Set priority'**
  String get grpFSetPriority;

  /// No description provided for @grpFStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get grpFStatus;

  /// No description provided for @grpFPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get grpFPriority;

  /// No description provided for @grpFAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get grpFAssign;

  /// No description provided for @grpFClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get grpFClear;

  /// No description provided for @grpFBulkUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating {done} of {total}…'**
  String grpFBulkUpdating(int done, int total);

  /// No description provided for @grpFBulkSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String grpFBulkSelected(int count);

  /// No description provided for @grpFBulkNotChanged.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks not changed'**
  String grpFBulkNotChanged(int count);

  /// No description provided for @grpFTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get grpFTask;

  /// No description provided for @grpFLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get grpFLinks;

  /// No description provided for @grpFAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get grpFAddLink;

  /// No description provided for @grpFNoLinks.
  ///
  /// In en, this message translates to:
  /// **'No links yet.'**
  String get grpFNoLinks;

  /// No description provided for @grpFRemoveLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get grpFRemoveLink;

  /// No description provided for @grpFLinkSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks in any project'**
  String get grpFLinkSearchHint;

  /// No description provided for @grpFCloseDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Close the duplicate'**
  String get grpFCloseDuplicate;

  /// No description provided for @grpFLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get grpFLinkAction;

  /// No description provided for @grpFUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get grpFUnassigned;

  /// No description provided for @grpFNoValue.
  ///
  /// In en, this message translates to:
  /// **'No value'**
  String get grpFNoValue;

  /// No description provided for @grpFAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get grpFAssignee;

  /// No description provided for @grpFPresenceEditing.
  ///
  /// In en, this message translates to:
  /// **'{name} is editing'**
  String grpFPresenceEditing(String name);

  /// No description provided for @grpFPresenceViewing.
  ///
  /// In en, this message translates to:
  /// **'{name} is viewing'**
  String grpFPresenceViewing(String name);

  /// No description provided for @grpFEditingOne.
  ///
  /// In en, this message translates to:
  /// **'{name} is editing this'**
  String grpFEditingOne(String name);

  /// No description provided for @grpFEditingMany.
  ///
  /// In en, this message translates to:
  /// **'{count} people are editing this'**
  String grpFEditingMany(int count);

  /// No description provided for @grpFDeleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {id}?'**
  String grpFDeleteTaskTitle(String id);

  /// No description provided for @grpFDeleteSubtasksExplain.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It has 1 subtask. What should happen to it?} other{It has {count} subtasks. What should happen to them?}}'**
  String grpFDeleteSubtasksExplain(int count);

  /// No description provided for @grpFKeepSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Keep them (move up a level)'**
  String get grpFKeepSubtasks;

  /// No description provided for @grpFDeleteThemToo.
  ///
  /// In en, this message translates to:
  /// **'Delete them too'**
  String get grpFDeleteThemToo;

  /// No description provided for @grpFOpenSubtasksTitle.
  ///
  /// In en, this message translates to:
  /// **'{id} has open subtasks'**
  String grpFOpenSubtasksTitle(String id);

  /// No description provided for @grpFOpenSubtasksExplain.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subtask is not finished. Move it to {status} too?} other{{count} subtasks are not finished. Move them to {status} too?}}'**
  String grpFOpenSubtasksExplain(int count, String status);

  /// No description provided for @grpFLeaveOpen.
  ///
  /// In en, this message translates to:
  /// **'Leave them open'**
  String get grpFLeaveOpen;

  /// No description provided for @grpFCompleteAll.
  ///
  /// In en, this message translates to:
  /// **'Complete all'**
  String get grpFCompleteAll;

  /// No description provided for @grpFMoveUnderTitle.
  ///
  /// In en, this message translates to:
  /// **'Move {id} under…'**
  String grpFMoveUnderTitle(String id);

  /// No description provided for @grpFTopLevel.
  ///
  /// In en, this message translates to:
  /// **'Top level (no parent)'**
  String get grpFTopLevel;

  /// No description provided for @grpFNoOtherParent.
  ///
  /// In en, this message translates to:
  /// **'There is no other task to put it under.'**
  String get grpFNoOtherParent;

  /// No description provided for @grpFSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get grpFSubtasks;

  /// No description provided for @grpFAddSubtaskHint.
  ///
  /// In en, this message translates to:
  /// **'Add a subtask and press Enter'**
  String get grpFAddSubtaskHint;

  /// No description provided for @grpFActionAddSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get grpFActionAddSubtask;

  /// No description provided for @grpFActionMoveUnder.
  ///
  /// In en, this message translates to:
  /// **'Move under…'**
  String get grpFActionMoveUnder;

  /// No description provided for @grpFActionMakeTopLevel.
  ///
  /// In en, this message translates to:
  /// **'Make top level'**
  String get grpFActionMakeTopLevel;

  /// No description provided for @grpFBlockedByPending.
  ///
  /// In en, this message translates to:
  /// **'Blocked by tasks that are not done yet'**
  String get grpFBlockedByPending;

  /// No description provided for @grpFBlockedBy.
  ///
  /// In en, this message translates to:
  /// **'Blocked by {names}'**
  String grpFBlockedBy(String names);

  /// No description provided for @grpFBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get grpFBlocked;

  /// No description provided for @grpFBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This task is blocked'**
  String get grpFBlockedTitle;

  /// No description provided for @grpFBlockedTextOne.
  ///
  /// In en, this message translates to:
  /// **'It is blocked by {blockers}, which is not done yet.'**
  String grpFBlockedTextOne(String blockers);

  /// No description provided for @grpFBlockedTextMany.
  ///
  /// In en, this message translates to:
  /// **'It is blocked by {blockers}, which are not done yet.'**
  String grpFBlockedTextMany(String blockers);

  /// No description provided for @grpFOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get grpFOk;

  /// No description provided for @grpFCompleteAnyway.
  ///
  /// In en, this message translates to:
  /// **'Complete anyway'**
  String get grpFCompleteAnyway;

  /// No description provided for @grpFConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Someone changed the {field}'**
  String grpFConflictTitle(String field);

  /// No description provided for @grpFTheirs.
  ///
  /// In en, this message translates to:
  /// **'Theirs'**
  String get grpFTheirs;

  /// No description provided for @grpFYours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get grpFYours;

  /// No description provided for @grpFEmpty.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get grpFEmpty;

  /// No description provided for @grpFTakeTheirs.
  ///
  /// In en, this message translates to:
  /// **'Take theirs'**
  String get grpFTakeTheirs;

  /// No description provided for @grpFKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get grpFKeepMine;

  /// No description provided for @grpFFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get grpFFieldTitle;

  /// No description provided for @grpFFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get grpFFieldDescription;

  /// No description provided for @grpFFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get grpFFieldStatus;

  /// No description provided for @grpFFieldPriority.
  ///
  /// In en, this message translates to:
  /// **'priority'**
  String get grpFFieldPriority;

  /// No description provided for @grpFFieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'start date'**
  String get grpFFieldStartDate;

  /// No description provided for @grpFFieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'due date'**
  String get grpFFieldDueDate;

  /// No description provided for @grpFFieldAssignees.
  ///
  /// In en, this message translates to:
  /// **'assignees'**
  String get grpFFieldAssignees;

  /// No description provided for @grpFFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get grpFFields;

  /// No description provided for @grpFRequiredFieldsIntro.
  ///
  /// In en, this message translates to:
  /// **'These fields need a value before the task is created.'**
  String get grpFRequiredFieldsIntro;

  /// No description provided for @grpFRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get grpFRequired;

  /// No description provided for @grpFCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get grpFCreate;

  /// No description provided for @grpFChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get grpFChangeStatus;

  /// No description provided for @grpFChangePriority.
  ///
  /// In en, this message translates to:
  /// **'Change priority'**
  String get grpFChangePriority;

  /// No description provided for @grpFDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get grpFDate;

  /// No description provided for @grpFPickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day…'**
  String get grpFPickDay;

  /// No description provided for @grpFAssignees.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get grpFAssignees;

  /// No description provided for @grpFViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get grpFViewList;

  /// No description provided for @grpFViewBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get grpFViewBoard;

  /// No description provided for @grpFViewTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get grpFViewTimeline;

  /// No description provided for @grpFErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'{message} Retry'**
  String grpFErrorRetry(String message);

  /// No description provided for @grpFNoTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add the first one above.'**
  String get grpFNoTasksYet;

  /// No description provided for @grpFSwipeComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get grpFSwipeComplete;

  /// No description provided for @grpFUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get grpFUndo;

  /// No description provided for @grpFMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get grpFMore;

  /// No description provided for @grpFAddSubtaskTo.
  ///
  /// In en, this message translates to:
  /// **'Add a subtask to {id}'**
  String grpFAddSubtaskTo(String id);

  /// No description provided for @grpFTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'{id} deleted'**
  String grpFTaskDeleted(String id);

  /// No description provided for @grpFColTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get grpFColTitle;

  /// No description provided for @grpFTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · Trash'**
  String grpFTrashTitle(String name);

  /// No description provided for @grpFTrashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty.'**
  String get grpFTrashEmpty;

  /// No description provided for @grpFTrashedRow.
  ///
  /// In en, this message translates to:
  /// **'{id} · deleted'**
  String grpFTrashedRow(String id);

  /// No description provided for @grpFRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get grpFRestore;

  /// No description provided for @grpFTaskRestored.
  ///
  /// In en, this message translates to:
  /// **'{id} restored'**
  String grpFTaskRestored(String id);

  /// No description provided for @grpFMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get grpFMoveTo;

  /// No description provided for @grpFMoveToColumn.
  ///
  /// In en, this message translates to:
  /// **'Move to {name}'**
  String grpFMoveToColumn(String name);

  /// No description provided for @grpFPlusCount.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String grpFPlusCount(int count);

  /// No description provided for @grpFFoldColumn.
  ///
  /// In en, this message translates to:
  /// **'Fold the column'**
  String get grpFFoldColumn;

  /// No description provided for @grpFColumn.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get grpFColumn;

  /// No description provided for @grpFSetWipLimit.
  ///
  /// In en, this message translates to:
  /// **'Set a work-in-progress limit…'**
  String get grpFSetWipLimit;

  /// No description provided for @grpFChangeLimit.
  ///
  /// In en, this message translates to:
  /// **'Change the limit…'**
  String get grpFChangeLimit;

  /// No description provided for @grpFAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get grpFAddTask;

  /// No description provided for @grpFWipTitle.
  ///
  /// In en, this message translates to:
  /// **'Work-in-progress limit'**
  String get grpFWipTitle;

  /// No description provided for @grpFWipMost.
  ///
  /// In en, this message translates to:
  /// **'Most cards this column should hold'**
  String get grpFWipMost;

  /// No description provided for @grpFColumnsBy.
  ///
  /// In en, this message translates to:
  /// **'Columns by'**
  String get grpFColumnsBy;

  /// No description provided for @grpFColumnsChip.
  ///
  /// In en, this message translates to:
  /// **'Columns: {name}'**
  String grpFColumnsChip(String name);

  /// No description provided for @grpFSwimlanes.
  ///
  /// In en, this message translates to:
  /// **'Swimlanes'**
  String get grpFSwimlanes;

  /// No description provided for @grpFLanesAssignee.
  ///
  /// In en, this message translates to:
  /// **'Lanes: assignee'**
  String get grpFLanesAssignee;

  /// No description provided for @grpFNoSwimlanes.
  ///
  /// In en, this message translates to:
  /// **'No swimlanes'**
  String get grpFNoSwimlanes;

  /// No description provided for @grpFByAssignee.
  ///
  /// In en, this message translates to:
  /// **'By assignee'**
  String get grpFByAssignee;

  /// No description provided for @grpFCardFields.
  ///
  /// In en, this message translates to:
  /// **'Card fields'**
  String get grpFCardFields;

  /// No description provided for @grpFCurrentSprint.
  ///
  /// In en, this message translates to:
  /// **'Current sprint'**
  String get grpFCurrentSprint;

  /// No description provided for @grpFRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get grpFRefresh;

  /// No description provided for @grpFBoardLayoutNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your board layout could not be saved. It will be tried again on your next change.'**
  String get grpFBoardLayoutNotSaved;

  /// No description provided for @grpFReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule…'**
  String get grpFReschedule;

  /// No description provided for @grpFSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule…'**
  String get grpFSchedule;

  /// No description provided for @grpFRepeatsNotMade.
  ///
  /// In en, this message translates to:
  /// **'Repeats: not made yet'**
  String get grpFRepeatsNotMade;

  /// No description provided for @grpFEverythingDated.
  ///
  /// In en, this message translates to:
  /// **'Everything has a date.'**
  String get grpFEverythingDated;

  /// No description provided for @grpFNothingOn.
  ///
  /// In en, this message translates to:
  /// **'Nothing on {day}.'**
  String grpFNothingOn(String day);

  /// No description provided for @grpFKindTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get grpFKindTasks;

  /// No description provided for @grpFKindComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get grpFKindComments;

  /// No description provided for @grpFKindProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get grpFKindProjects;

  /// No description provided for @grpFKindPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get grpFKindPeople;

  /// No description provided for @grpFKindPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get grpFKindPages;

  /// No description provided for @grpFChipAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me'**
  String get grpFChipAssignedToMe;

  /// No description provided for @grpFChipOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get grpFChipOpen;

  /// No description provided for @grpFChipDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get grpFChipDone;

  /// No description provided for @grpFSearchErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get grpFSearchErrGeneric;

  /// No description provided for @grpFSearchErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection.'**
  String get grpFSearchErrNetwork;

  /// No description provided for @grpFSearchErrDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to search here.'**
  String get grpFSearchErrDenied;

  /// No description provided for @grpFSearchErrRate.
  ///
  /// In en, this message translates to:
  /// **'Too many searches. Wait a moment.'**
  String get grpFSearchErrRate;

  /// No description provided for @grpFSearchErrInvalid.
  ///
  /// In en, this message translates to:
  /// **'That search is not valid.'**
  String get grpFSearchErrInvalid;

  /// No description provided for @grpFSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks, comments, projects, people'**
  String get grpFSearchHint;

  /// No description provided for @grpFSearchClose.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get grpFSearchClose;

  /// No description provided for @grpFSearchNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing found. Try fewer words, or an id like WEB-12. Narrow with in:KEY, assignee:me, status:open.'**
  String get grpFSearchNothing;

  /// No description provided for @grpFSearchTips.
  ///
  /// In en, this message translates to:
  /// **'Type to search. Try an id like WEB-12, or operators: in:KEY, assignee:me, status:open.'**
  String get grpFSearchTips;

  /// No description provided for @grpFGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get grpFGoTo;

  /// No description provided for @grpFShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more {kind}'**
  String grpFShowMore(String kind);

  /// No description provided for @grpFRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get grpFRecent;

  /// No description provided for @grpFPlusMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String grpFPlusMore(int count);

  /// No description provided for @grpFSubtaskDepthLimit.
  ///
  /// In en, this message translates to:
  /// **'Subtasks are nested as deep as the app allows here.'**
  String get grpFSubtaskDepthLimit;

  /// No description provided for @grpFUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get grpFUnscheduled;

  /// No description provided for @grpGCloseShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Close the keyboard shortcuts'**
  String get grpGCloseShortcuts;

  /// No description provided for @grpGKeyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get grpGKeyboardShortcuts;

  /// No description provided for @grpGClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get grpGClose;

  /// No description provided for @grpGChangedByYou.
  ///
  /// In en, this message translates to:
  /// **'Changed by you'**
  String get grpGChangedByYou;

  /// No description provided for @grpGNone.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get grpGNone;

  /// No description provided for @grpGChangeKeysFor.
  ///
  /// In en, this message translates to:
  /// **'Change the keys for {title}'**
  String grpGChangeKeysFor(String title);

  /// No description provided for @grpGKeysFor.
  ///
  /// In en, this message translates to:
  /// **'Keys for {title}'**
  String grpGKeysFor(String title);

  /// No description provided for @grpGPressKeys.
  ///
  /// In en, this message translates to:
  /// **'Press the keys you want.'**
  String get grpGPressKeys;

  /// No description provided for @grpGUseDefault.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get grpGUseDefault;

  /// No description provided for @grpGNoKey.
  ///
  /// In en, this message translates to:
  /// **'No key'**
  String get grpGNoKey;

  /// No description provided for @grpGCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpGCancel;

  /// No description provided for @grpGSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpGSave;

  /// No description provided for @grpGBrowserKeeps.
  ///
  /// In en, this message translates to:
  /// **'The browser keeps {keys}.'**
  String grpGBrowserKeeps(String keys);

  /// No description provided for @grpGAlreadyUsedBy.
  ///
  /// In en, this message translates to:
  /// **'Already used by \"{title}\".'**
  String grpGAlreadyUsedBy(String title);

  /// No description provided for @grpGKeysTaken.
  ///
  /// In en, this message translates to:
  /// **'Another action already uses those keys.'**
  String get grpGKeysTaken;

  /// No description provided for @grpGKeysInvalid.
  ///
  /// In en, this message translates to:
  /// **'Those keys cannot be used.'**
  String get grpGKeysInvalid;

  /// No description provided for @grpGSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your connection.'**
  String get grpGSaveFailed;

  /// No description provided for @grpGDefaultUsedBy.
  ///
  /// In en, this message translates to:
  /// **'The default keys are used by \"{title}\".'**
  String grpGDefaultUsedBy(String title);

  /// No description provided for @grpGDefaultUsedByOther.
  ///
  /// In en, this message translates to:
  /// **'The default keys are used by another action.'**
  String get grpGDefaultUsedByOther;

  /// No description provided for @grpGPaletteHint.
  ///
  /// In en, this message translates to:
  /// **'Type a command, or > actions  # projects  @ people'**
  String get grpGPaletteHint;

  /// No description provided for @grpGNothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches.'**
  String get grpGNothingMatches;

  /// No description provided for @grpGSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search is not available right now.'**
  String get grpGSearchUnavailable;

  /// No description provided for @grpGName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpGName;

  /// No description provided for @grpGCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get grpGCreate;

  /// No description provided for @grpGQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get grpGQuickActions;

  /// No description provided for @grpGDryRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Dry run: {name}'**
  String grpGDryRunTitle(String name);

  /// No description provided for @grpGDryRunIntro.
  ///
  /// In en, this message translates to:
  /// **'Shows what would happen on a task. Nothing is changed, sent or notified.'**
  String get grpGDryRunIntro;

  /// No description provided for @grpGTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get grpGTask;

  /// No description provided for @grpGTasksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the tasks.'**
  String get grpGTasksLoadFailed;

  /// No description provided for @grpGWouldRun.
  ///
  /// In en, this message translates to:
  /// **'It would run.'**
  String get grpGWouldRun;

  /// No description provided for @grpGWouldNotRun.
  ///
  /// In en, this message translates to:
  /// **'It would not run on this task.'**
  String get grpGWouldNotRun;

  /// No description provided for @grpGRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get grpGRun;

  /// No description provided for @grpGConditionProblem.
  ///
  /// In en, this message translates to:
  /// **'The condition has a problem: see under the If card.'**
  String get grpGConditionProblem;

  /// No description provided for @grpGRuleGone.
  ///
  /// In en, this message translates to:
  /// **'That rule no longer exists.'**
  String get grpGRuleGone;

  /// No description provided for @grpGRule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get grpGRule;

  /// No description provided for @grpGNewAutomation.
  ///
  /// In en, this message translates to:
  /// **'New automation'**
  String get grpGNewAutomation;

  /// No description provided for @grpGEditAutomation.
  ///
  /// In en, this message translates to:
  /// **'Edit automation'**
  String get grpGEditAutomation;

  /// No description provided for @grpGWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get grpGWhen;

  /// No description provided for @grpGIfOptional.
  ///
  /// In en, this message translates to:
  /// **'If (optional)'**
  String get grpGIfOptional;

  /// No description provided for @grpGThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get grpGThen;

  /// No description provided for @grpGAndThen.
  ///
  /// In en, this message translates to:
  /// **'And then'**
  String get grpGAndThen;

  /// No description provided for @grpGActionLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit of {max} actions reached'**
  String grpGActionLimit(int max);

  /// No description provided for @grpGAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get grpGAddAction;

  /// No description provided for @grpGLoadLatest.
  ///
  /// In en, this message translates to:
  /// **'Load the latest version'**
  String get grpGLoadLatest;

  /// No description provided for @grpGMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get grpGMoveUp;

  /// No description provided for @grpGMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get grpGMoveDown;

  /// No description provided for @grpGRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove action'**
  String get grpGRemoveAction;

  /// No description provided for @grpGSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'Switched off: {reason}\nFix it: open the rule, pick something that still exists in the trigger or actions, save, then switch it on again.'**
  String grpGSwitchedOff(String reason);

  /// No description provided for @grpGUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get grpGUnknown;

  /// No description provided for @grpGEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get grpGEmptyValue;

  /// No description provided for @grpGNothingRunYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing has run yet.'**
  String get grpGNothingRunYet;

  /// No description provided for @grpGLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get grpGLoadMore;

  /// No description provided for @grpGRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpGRetry;

  /// No description provided for @grpGWhyNotRun.
  ///
  /// In en, this message translates to:
  /// **'Why didn\'t this run? {explanation}'**
  String grpGWhyNotRun(String explanation);

  /// No description provided for @grpGChainDepth.
  ///
  /// In en, this message translates to:
  /// **'Chain depth {depth}'**
  String grpGChainDepth(int depth);

  /// No description provided for @grpGFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get grpGFilter;

  /// No description provided for @grpGFilterCount.
  ///
  /// In en, this message translates to:
  /// **'Filter ({count})'**
  String grpGFilterCount(int count);

  /// No description provided for @grpGSavedFilters.
  ///
  /// In en, this message translates to:
  /// **'Saved filters'**
  String get grpGSavedFilters;

  /// No description provided for @grpGNoSavedFilters.
  ///
  /// In en, this message translates to:
  /// **'No saved filters yet'**
  String get grpGNoSavedFilters;

  /// No description provided for @grpGFieldGoneNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} (a field is gone)'**
  String grpGFieldGoneNamed(String name);

  /// No description provided for @grpGManageSaved.
  ///
  /// In en, this message translates to:
  /// **'Manage saved filters…'**
  String get grpGManageSaved;

  /// No description provided for @grpGConditionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} condition(s)'**
  String grpGConditionCount(int count);

  /// No description provided for @grpGClearFilterTip.
  ///
  /// In en, this message translates to:
  /// **'Clear the filter'**
  String get grpGClearFilterTip;

  /// No description provided for @grpGNothingSaved.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet.'**
  String get grpGNothingSaved;

  /// No description provided for @grpGFieldItUsedGone.
  ///
  /// In en, this message translates to:
  /// **'A field it used is gone'**
  String get grpGFieldItUsedGone;

  /// No description provided for @grpGDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpGDelete;

  /// No description provided for @grpGFinishConditions.
  ///
  /// In en, this message translates to:
  /// **'Finish the conditions first.'**
  String get grpGFinishConditions;

  /// No description provided for @grpGEveryoneWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace'**
  String get grpGEveryoneWorkspace;

  /// No description provided for @grpGEveryoneProject.
  ///
  /// In en, this message translates to:
  /// **'Everyone in this project'**
  String get grpGEveryoneProject;

  /// No description provided for @grpGBuilder.
  ///
  /// In en, this message translates to:
  /// **'Builder'**
  String get grpGBuilder;

  /// No description provided for @grpGAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get grpGAdvanced;

  /// No description provided for @grpGClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get grpGClearFilter;

  /// No description provided for @grpGSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as…'**
  String get grpGSaveAs;

  /// No description provided for @grpGApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get grpGApply;

  /// No description provided for @grpGSaveThisFilter.
  ///
  /// In en, this message translates to:
  /// **'Save this filter'**
  String get grpGSaveThisFilter;

  /// No description provided for @grpGOnlyMe.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get grpGOnlyMe;

  /// No description provided for @grpGExportSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be saved. Try again.'**
  String get grpGExportSaveFailed;

  /// No description provided for @grpGExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get grpGExport;

  /// No description provided for @grpGEveryProject.
  ///
  /// In en, this message translates to:
  /// **'Every project I can open'**
  String get grpGEveryProject;

  /// No description provided for @grpGOneProject.
  ///
  /// In en, this message translates to:
  /// **'One project'**
  String get grpGOneProject;

  /// No description provided for @grpGExportInfo.
  ///
  /// In en, this message translates to:
  /// **'A zip with tasks.json (which TaskForge can import again), tasks.csv, comments, an attachments manifest and a README.'**
  String get grpGExportInfo;

  /// No description provided for @grpGExportSavedSized.
  ///
  /// In en, this message translates to:
  /// **'Saved {name} ({size}).'**
  String grpGExportSavedSized(String name, String size);

  /// No description provided for @grpGExportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}.'**
  String grpGExportSaved(String name);

  /// No description provided for @grpGNotesAboutFile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note about this file} other{{count} notes about this file}}'**
  String grpGNotesAboutFile(int count);

  /// No description provided for @grpGRowNumber.
  ///
  /// In en, this message translates to:
  /// **'Row {line}'**
  String grpGRowNumber(int line);

  /// No description provided for @grpGAndMore.
  ///
  /// In en, this message translates to:
  /// **'...and {count} more.'**
  String grpGAndMore(int count);

  /// No description provided for @grpGNotesReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the notes about this import.'**
  String get grpGNotesReadFailed;

  /// No description provided for @grpGDragToOtherList.
  ///
  /// In en, this message translates to:
  /// **'Drag to the other list'**
  String get grpGDragToOtherList;

  /// No description provided for @grpGAddedAfterStart.
  ///
  /// In en, this message translates to:
  /// **'added after start'**
  String get grpGAddedAfterStart;

  /// No description provided for @grpGStoryPoints.
  ///
  /// In en, this message translates to:
  /// **'Story points'**
  String get grpGStoryPoints;

  /// No description provided for @grpGUnitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get grpGUnitHours;

  /// No description provided for @grpGUnitPoints.
  ///
  /// In en, this message translates to:
  /// **' pts'**
  String get grpGUnitPoints;

  /// No description provided for @grpGLoadOf.
  ///
  /// In en, this message translates to:
  /// **'Load {load}{unit} of {cap}{unit}'**
  String grpGLoadOf(String load, String unit, String cap);

  /// No description provided for @grpGLoadNoCapacity.
  ///
  /// In en, this message translates to:
  /// **'Load {load}{unit} (no capacity set)'**
  String grpGLoadNoCapacity(String load, String unit);

  /// No description provided for @grpGSetCapacity.
  ///
  /// In en, this message translates to:
  /// **'Set capacity'**
  String get grpGSetCapacity;

  /// No description provided for @grpGPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get grpGPoints;

  /// No description provided for @grpGHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get grpGHours;

  /// No description provided for @grpGOverCapacity.
  ///
  /// In en, this message translates to:
  /// **'Over capacity by {amount}{unit}'**
  String grpGOverCapacity(String amount, String unit);

  /// No description provided for @grpGTitleWithCount.
  ///
  /// In en, this message translates to:
  /// **'{title} ({count})'**
  String grpGTitleWithCount(String title, int count);

  /// No description provided for @grpHCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpHCancel;

  /// No description provided for @grpHArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get grpHArchive;

  /// No description provided for @grpHRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get grpHRestore;

  /// No description provided for @grpHRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpHRetry;

  /// No description provided for @grpHCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get grpHCreate;

  /// No description provided for @grpHName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpHName;

  /// No description provided for @grpHDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get grpHDescription;

  /// No description provided for @grpHArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive \"{name}\"?'**
  String grpHArchiveTitle(String name);

  /// No description provided for @grpHArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'It becomes read-only and disappears from the sidebar. You can restore it at any time.'**
  String get grpHArchiveBody;

  /// No description provided for @grpHDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get grpHDangerZone;

  /// No description provided for @grpHRestoreProject.
  ///
  /// In en, this message translates to:
  /// **'Restore project'**
  String get grpHRestoreProject;

  /// No description provided for @grpHArchiveProject.
  ///
  /// In en, this message translates to:
  /// **'Archive project'**
  String get grpHArchiveProject;

  /// No description provided for @grpHArchivedBanner.
  ///
  /// In en, this message translates to:
  /// **'This project is archived and read-only.'**
  String get grpHArchivedBanner;

  /// No description provided for @grpHArchivedProjects.
  ///
  /// In en, this message translates to:
  /// **'Archived projects'**
  String get grpHArchivedProjects;

  /// No description provided for @grpHNoArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived projects.'**
  String get grpHNoArchived;

  /// No description provided for @grpHLoadProjectsRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load projects. Retry'**
  String get grpHLoadProjectsRetry;

  /// No description provided for @grpHNewProject.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get grpHNewProject;

  /// No description provided for @grpHKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get grpHKey;

  /// No description provided for @grpHKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Prefix of task numbers, e.g. WEB-12'**
  String get grpHKeyHelp;

  /// No description provided for @grpHFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get grpHFeatures;

  /// No description provided for @grpHFeaturesHint.
  ///
  /// In en, this message translates to:
  /// **'Switching a feature off hides it but keeps its data.'**
  String get grpHFeaturesHint;

  /// No description provided for @grpHProjectUpdated.
  ///
  /// In en, this message translates to:
  /// **'Project updated.'**
  String get grpHProjectUpdated;

  /// No description provided for @grpHGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get grpHGeneral;

  /// No description provided for @grpHKeyFixed.
  ///
  /// In en, this message translates to:
  /// **'The key is fixed because tasks already use it ({taskKey}).'**
  String grpHKeyFixed(String taskKey);

  /// No description provided for @grpHSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get grpHSaveChanges;

  /// No description provided for @grpHAddAMember.
  ///
  /// In en, this message translates to:
  /// **'Add a member'**
  String get grpHAddAMember;

  /// No description provided for @grpHAllAreMembers.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace is already a member.'**
  String get grpHAllAreMembers;

  /// No description provided for @grpHMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get grpHMembers;

  /// No description provided for @grpHAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get grpHAddMember;

  /// No description provided for @grpHRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get grpHRemove;

  /// No description provided for @grpHLoadMembersRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load members. Retry'**
  String get grpHLoadMembersRetry;

  /// No description provided for @grpHPrivateProjects.
  ///
  /// In en, this message translates to:
  /// **'Private projects'**
  String get grpHPrivateProjects;

  /// No description provided for @grpHNoPrivate.
  ///
  /// In en, this message translates to:
  /// **'No private projects.'**
  String get grpHNoPrivate;

  /// No description provided for @grpHKeyAndMembers.
  ///
  /// In en, this message translates to:
  /// **'{key} · {count, plural, one{1 member} other{{count} members}}'**
  String grpHKeyAndMembers(String key, int count);

  /// No description provided for @grpHAddMe.
  ///
  /// In en, this message translates to:
  /// **'Add me'**
  String get grpHAddMe;

  /// No description provided for @grpHColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color {color}'**
  String grpHColorLabel(String color);

  /// No description provided for @grpHVisOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get grpHVisOpen;

  /// No description provided for @grpHVisPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get grpHVisPrivate;

  /// No description provided for @grpHVisOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace can see it.'**
  String get grpHVisOpenHint;

  /// No description provided for @grpHVisPrivateHint.
  ///
  /// In en, this message translates to:
  /// **'Only invited members can see it.'**
  String get grpHVisPrivateHint;

  /// No description provided for @grpHProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get grpHProject;

  /// No description provided for @grpHRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get grpHRemoveFavorite;

  /// No description provided for @grpHAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get grpHAddFavorite;

  /// No description provided for @grpHTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get grpHTrash;

  /// No description provided for @grpHProjectSettings.
  ///
  /// In en, this message translates to:
  /// **'Project settings'**
  String get grpHProjectSettings;

  /// No description provided for @grpHLoadProjectRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load the project. Retry'**
  String get grpHLoadProjectRetry;

  /// No description provided for @grpHProjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found.'**
  String get grpHProjectNotFound;

  /// No description provided for @grpHBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpHBack;

  /// No description provided for @grpHWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get grpHWorkflow;

  /// No description provided for @grpHWorkflowHint.
  ///
  /// In en, this message translates to:
  /// **'Statuses, their categories and which moves are allowed.'**
  String get grpHWorkflowHint;

  /// No description provided for @grpHFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get grpHFields;

  /// No description provided for @grpHFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Custom fields such as Customer, Story points or Environment.'**
  String get grpHFieldsHint;

  /// No description provided for @grpHAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get grpHAdd;

  /// No description provided for @grpHAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach a file'**
  String get grpHAttachFile;

  /// No description provided for @grpHTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get grpHTakePhoto;

  /// No description provided for @grpHChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get grpHChooseGallery;

  /// No description provided for @grpHPasteImage.
  ///
  /// In en, this message translates to:
  /// **'Paste an image'**
  String get grpHPasteImage;

  /// No description provided for @grpHDeleteFileQ.
  ///
  /// In en, this message translates to:
  /// **'Delete this file?'**
  String get grpHDeleteFileQ;

  /// No description provided for @grpHFileWillBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'{filename} will be removed.'**
  String grpHFileWillBeRemoved(String filename);

  /// No description provided for @grpHDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpHDelete;

  /// No description provided for @grpHOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Open {filename}'**
  String grpHOpenFile(String filename);

  /// No description provided for @grpHDeleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete {filename}'**
  String grpHDeleteFile(String filename);

  /// No description provided for @grpHWaitingConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a connection…'**
  String get grpHWaitingConnection;

  /// No description provided for @grpHWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting…'**
  String get grpHWaiting;

  /// No description provided for @grpHUploadDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get grpHUploadDone;

  /// No description provided for @grpHUploadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get grpHUploadCancelled;

  /// No description provided for @grpHPercentUploaded.
  ///
  /// In en, this message translates to:
  /// **'{filename}, {percent} percent uploaded'**
  String grpHPercentUploaded(String filename, int percent);

  /// No description provided for @grpHWaitingToBeSent.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be sent'**
  String get grpHWaitingToBeSent;

  /// No description provided for @grpHCancelFile.
  ///
  /// In en, this message translates to:
  /// **'Cancel {filename}'**
  String grpHCancelFile(String filename);

  /// No description provided for @grpHTryFileAgain.
  ///
  /// In en, this message translates to:
  /// **'Try {filename} again'**
  String grpHTryFileAgain(String filename);

  /// No description provided for @grpHDismissFile.
  ///
  /// In en, this message translates to:
  /// **'Dismiss {filename}'**
  String grpHDismissFile(String filename);

  /// No description provided for @grpHOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get grpHOpen;

  /// No description provided for @grpHDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get grpHDownload;

  /// No description provided for @grpHClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get grpHClose;

  /// No description provided for @grpHCouldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file.'**
  String get grpHCouldNotOpenFile;

  /// No description provided for @grpHCouldNotLoadPicture.
  ///
  /// In en, this message translates to:
  /// **'Could not load the picture.'**
  String get grpHCouldNotLoadPicture;

  /// No description provided for @grpHCouldNotReadFileViewer.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file.'**
  String get grpHCouldNotReadFileViewer;

  /// No description provided for @grpHCouldNotPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Could not play the video.'**
  String get grpHCouldNotPlayVideo;

  /// No description provided for @grpHPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get grpHPause;

  /// No description provided for @grpHPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get grpHPlay;

  /// No description provided for @grpHTextTruncated.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {size}. Download the file to read the rest.'**
  String grpHTextTruncated(String size);

  /// No description provided for @grpHAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get grpHAttachments;

  /// No description provided for @grpHAttachmentsCount.
  ///
  /// In en, this message translates to:
  /// **'Attachments ({count})'**
  String grpHAttachmentsCount(int count);

  /// No description provided for @grpHCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file.'**
  String get grpHCouldNotReadFile;

  /// No description provided for @grpHDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get grpHDismiss;

  /// No description provided for @grpHNoAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments.'**
  String get grpHNoAttachments;

  /// No description provided for @grpHDropZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach files: drop them here or click, then paste an image'**
  String get grpHDropZoneLabel;

  /// No description provided for @grpHDropToAttach.
  ///
  /// In en, this message translates to:
  /// **'Drop to attach'**
  String get grpHDropToAttach;

  /// No description provided for @grpHDropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop files here to attach them'**
  String get grpHDropFilesHere;

  /// No description provided for @grpHSnoozeLaterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get grpHSnoozeLaterToday;

  /// No description provided for @grpHSnoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get grpHSnoozeTomorrow;

  /// No description provided for @grpHSnoozeNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get grpHSnoozeNextWeek;

  /// No description provided for @grpHMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get grpHMarkAllRead;

  /// No description provided for @grpHNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get grpHNotificationSettings;

  /// No description provided for @grpHInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get grpHInbox;

  /// No description provided for @grpHUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String grpHUnreadCount(int count);

  /// No description provided for @grpHLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get grpHLoadMore;

  /// No description provided for @grpHEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'Nothing here. You are all caught up.'**
  String get grpHEmptyAll;

  /// No description provided for @grpHEmptyUnread.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications.'**
  String get grpHEmptyUnread;

  /// No description provided for @grpHEmptyMentions.
  ///
  /// In en, this message translates to:
  /// **'Nobody has mentioned you.'**
  String get grpHEmptyMentions;

  /// No description provided for @grpHEmptyAssigned.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned to you lately.'**
  String get grpHEmptyAssigned;

  /// No description provided for @grpHEmptySnoozed.
  ///
  /// In en, this message translates to:
  /// **'Nothing is snoozed.'**
  String get grpHEmptySnoozed;

  /// No description provided for @grpHEmptyArchived.
  ///
  /// In en, this message translates to:
  /// **'Nothing is archived.'**
  String get grpHEmptyArchived;

  /// No description provided for @grpHDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String grpHDueDate(String date);

  /// No description provided for @grpHUnreadPrefix.
  ///
  /// In en, this message translates to:
  /// **'Unread. {title}'**
  String grpHUnreadPrefix(String title);

  /// No description provided for @grpHMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String grpHMoreCount(int count);

  /// No description provided for @grpHMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get grpHMore;

  /// No description provided for @grpHMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get grpHMarkUnread;

  /// No description provided for @grpHMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get grpHMarkRead;

  /// No description provided for @grpHStopSnoozing.
  ///
  /// In en, this message translates to:
  /// **'Stop snoozing'**
  String get grpHStopSnoozing;

  /// No description provided for @grpHSnoozeEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Snooze…'**
  String get grpHSnoozeEllipsis;

  /// No description provided for @grpHMoveToInbox.
  ///
  /// In en, this message translates to:
  /// **'Move to inbox'**
  String get grpHMoveToInbox;

  /// No description provided for @grpHPushTitle.
  ///
  /// In en, this message translates to:
  /// **'Get a ping when it matters'**
  String get grpHPushTitle;

  /// No description provided for @grpHPushBody.
  ///
  /// In en, this message translates to:
  /// **'TaskForge can show a notification when you are assigned a task, mentioned, or a task is due soon, even when the app is in the background. Next your device will ask for permission. You choose which kinds ping you, and quiet hours keep them from waking you.'**
  String get grpHPushBody;

  /// No description provided for @grpHNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get grpHNotNow;

  /// No description provided for @grpHContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get grpHContinue;

  /// No description provided for @grpHPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date and time'**
  String get grpHPickDateTime;

  /// No description provided for @grpHRepeatReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read how this repeats.'**
  String get grpHRepeatReadError;

  /// No description provided for @grpHRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get grpHRepeat;

  /// No description provided for @grpHFirstOfSeries.
  ///
  /// In en, this message translates to:
  /// **'First of a series'**
  String get grpHFirstOfSeries;

  /// No description provided for @grpHRepeatingTask.
  ///
  /// In en, this message translates to:
  /// **'Repeating task'**
  String get grpHRepeatingTask;

  /// No description provided for @grpHSeriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} task in this series} other{{count} tasks in this series}}'**
  String grpHSeriesCount(int count);

  /// No description provided for @grpHRepeatPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused: no new tasks are made.'**
  String get grpHRepeatPaused;

  /// No description provided for @grpHRepeatPausedBySystem.
  ///
  /// In en, this message translates to:
  /// **'Paused by the system: {reason}'**
  String grpHRepeatPausedBySystem(String reason);

  /// No description provided for @grpHRepeatNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {dates}'**
  String grpHRepeatNext(String dates);

  /// No description provided for @grpHRepeatWaits.
  ///
  /// In en, this message translates to:
  /// **'The next one is made when this is completed.'**
  String get grpHRepeatWaits;

  /// No description provided for @grpHRepeatsTitle.
  ///
  /// In en, this message translates to:
  /// **'This task repeats'**
  String get grpHRepeatsTitle;

  /// No description provided for @grpHRepeatsBody.
  ///
  /// In en, this message translates to:
  /// **'It is the template of \"{summary}\". Deleting it can stop the series, or the series can keep making new tasks.'**
  String grpHRepeatsBody(String summary);

  /// No description provided for @grpHDeleteKeepRepeating.
  ///
  /// In en, this message translates to:
  /// **'Delete, keep repeating'**
  String get grpHDeleteKeepRepeating;

  /// No description provided for @grpHDeleteAndStop.
  ///
  /// In en, this message translates to:
  /// **'Delete and stop'**
  String get grpHDeleteAndStop;

  /// No description provided for @grpHChartGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get grpHChartGroup;

  /// No description provided for @grpHOfflineReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get grpHOfflineReview;

  /// No description provided for @grpHOfflineSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get grpHOfflineSyncing;

  /// No description provided for @grpHOfflineSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get grpHOfflineSyncNow;

  /// No description provided for @grpHOfflineSaved.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Changes are saved on this device.'**
  String get grpHOfflineSaved;

  /// No description provided for @grpHOfflineWaitsOnline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} change waits to be sent.} other{{count} changes wait to be sent.}}'**
  String grpHOfflineWaitsOnline(int count);

  /// No description provided for @grpHOfflineWaitsOffline.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting to be sent.'**
  String grpHOfflineWaitsOffline(int count);

  /// No description provided for @grpHOfflineAttention.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} change needs your attention.} other{{count} changes need your attention.}}'**
  String grpHOfflineAttention(int count);

  /// No description provided for @grpHReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting… what you see will catch up once you are back.'**
  String get grpHReconnecting;

  /// No description provided for @grpICancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get grpICancel;

  /// No description provided for @grpIDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get grpIDone;

  /// No description provided for @grpIRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get grpIRetry;

  /// No description provided for @grpIClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get grpIClose;

  /// No description provided for @grpIBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpIBack;

  /// No description provided for @grpIEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get grpIEdit;

  /// No description provided for @grpISave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get grpISave;

  /// No description provided for @grpISaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get grpISaving;

  /// No description provided for @grpIDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpIDelete;

  /// No description provided for @grpICopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get grpICopy;

  /// No description provided for @grpIUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get grpIUndo;

  /// No description provided for @grpIRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get grpIRestore;

  /// No description provided for @grpIUnnamed.
  ///
  /// In en, this message translates to:
  /// **'(unnamed)'**
  String get grpIUnnamed;

  /// No description provided for @grpIErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'{message} Retry'**
  String grpIErrorRetry(String message);

  /// No description provided for @grpIMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Someone else saved the workflow first'**
  String get grpIMergeTitle;

  /// No description provided for @grpIMergeBody.
  ///
  /// In en, this message translates to:
  /// **'Your edits are kept, and their work was not overwritten. This is what changed in your draft:'**
  String get grpIMergeBody;

  /// No description provided for @grpIMergeKeep.
  ///
  /// In en, this message translates to:
  /// **'I have read this, keep my draft'**
  String get grpIMergeKeep;

  /// No description provided for @grpIMergeReload.
  ///
  /// In en, this message translates to:
  /// **'Throw my draft away'**
  String get grpIMergeReload;

  /// No description provided for @grpINoProblems.
  ///
  /// In en, this message translates to:
  /// **'No problems'**
  String get grpINoProblems;

  /// No description provided for @grpIEveryTaskValid.
  ///
  /// In en, this message translates to:
  /// **'Every task keeps a valid status.'**
  String get grpIEveryTaskValid;

  /// No description provided for @grpIProblemsToFix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 problem to fix before saving} other{{count} problems to fix before saving}}'**
  String grpIProblemsToFix(int count);

  /// No description provided for @grpIAnyStatusMoves.
  ///
  /// In en, this message translates to:
  /// **'Any status can move to any other.'**
  String get grpIAnyStatusMoves;

  /// No description provided for @grpIWorkflowGraphLabel.
  ///
  /// In en, this message translates to:
  /// **'Workflow with {statuses} statuses and {moves} allowed moves'**
  String grpIWorkflowGraphLabel(int statuses, int moves);

  /// No description provided for @grpINeedsAssignee.
  ///
  /// In en, this message translates to:
  /// **'needs an assignee'**
  String get grpINeedsAssignee;

  /// No description provided for @grpINeedsSubtasksDone.
  ///
  /// In en, this message translates to:
  /// **'needs all subtasks done'**
  String get grpINeedsSubtasksDone;

  /// No description provided for @grpIOnlyRoleLower.
  ///
  /// In en, this message translates to:
  /// **'only {role}'**
  String grpIOnlyRoleLower(String role);

  /// No description provided for @grpIOneRole.
  ///
  /// In en, this message translates to:
  /// **'one role'**
  String get grpIOneRole;

  /// No description provided for @grpIDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get grpIDragToReorder;

  /// No description provided for @grpIColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get grpIColour;

  /// No description provided for @grpINewTasksStartHere.
  ///
  /// In en, this message translates to:
  /// **'New tasks start here'**
  String get grpINewTasksStartHere;

  /// No description provided for @grpIMakeDefaultStatus.
  ///
  /// In en, this message translates to:
  /// **'Make this the status new tasks start in'**
  String get grpIMakeDefaultStatus;

  /// No description provided for @grpIDeleteStatus.
  ///
  /// In en, this message translates to:
  /// **'Delete status'**
  String get grpIDeleteStatus;

  /// No description provided for @grpITaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String grpITaskCount(int count);

  /// No description provided for @grpICanMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Can move to'**
  String get grpICanMoveTo;

  /// No description provided for @grpIConditionsForMove.
  ///
  /// In en, this message translates to:
  /// **'Conditions for this move'**
  String get grpIConditionsForMove;

  /// No description provided for @grpIName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpIName;

  /// No description provided for @grpIDeleteStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String grpIDeleteStatusTitle(String name);

  /// No description provided for @grpITasksInStatus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task is in this status. Choose where it goes.} other{{count} tasks are in this status. Choose where they go.}}'**
  String grpITasksInStatus(int count);

  /// No description provided for @grpIMoveTasksTo.
  ///
  /// In en, this message translates to:
  /// **'Move tasks to'**
  String get grpIMoveTasksTo;

  /// No description provided for @grpIMoveTasksAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Move tasks and delete'**
  String get grpIMoveTasksAndDelete;

  /// No description provided for @grpIWhoMayMove.
  ///
  /// In en, this message translates to:
  /// **'Who may make this move'**
  String get grpIWhoMayMove;

  /// No description provided for @grpIAnyRole.
  ///
  /// In en, this message translates to:
  /// **'Any role'**
  String get grpIAnyRole;

  /// No description provided for @grpIOnlyRole.
  ///
  /// In en, this message translates to:
  /// **'Only {name}'**
  String grpIOnlyRole(String name);

  /// No description provided for @grpITaskNeedsAssignee.
  ///
  /// In en, this message translates to:
  /// **'The task needs an assignee'**
  String get grpITaskNeedsAssignee;

  /// No description provided for @grpIAllSubtasksDone.
  ///
  /// In en, this message translates to:
  /// **'All subtasks must be done'**
  String get grpIAllSubtasksDone;

  /// No description provided for @grpIDoneOrCancelledDepth.
  ///
  /// In en, this message translates to:
  /// **'Done or cancelled, at any depth.'**
  String get grpIDoneOrCancelledDepth;

  /// No description provided for @grpIWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get grpIWorkflow;

  /// No description provided for @grpIDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get grpIDiscard;

  /// No description provided for @grpIWorkflowSaved.
  ///
  /// In en, this message translates to:
  /// **'Workflow saved'**
  String get grpIWorkflowSaved;

  /// No description provided for @grpIRestrictTransitions.
  ///
  /// In en, this message translates to:
  /// **'Restrict transitions'**
  String get grpIRestrictTransitions;

  /// No description provided for @grpIRestrictTransitionsHint.
  ///
  /// In en, this message translates to:
  /// **'Off: any status can move to any other. On: only the arrows you allow.'**
  String get grpIRestrictTransitionsHint;

  /// No description provided for @grpIRestrictCreation.
  ///
  /// In en, this message translates to:
  /// **'New tasks start in the default status only'**
  String get grpIRestrictCreation;

  /// No description provided for @grpIRestrictCreationHint.
  ///
  /// In en, this message translates to:
  /// **'Off: a task can be created in any status. On: it starts in the status marked with the star and reaches the others by being moved.'**
  String get grpIRestrictCreationHint;

  /// No description provided for @grpIAddStatus.
  ///
  /// In en, this message translates to:
  /// **'Add status'**
  String get grpIAddStatus;

  /// No description provided for @grpINewStatus.
  ///
  /// In en, this message translates to:
  /// **'New status'**
  String get grpINewStatus;

  /// No description provided for @grpIMigrationNeedsPlace.
  ///
  /// In en, this message translates to:
  /// **'Tasks you chose to move here need a new place.'**
  String get grpIMigrationNeedsPlace;

  /// No description provided for @grpIMoveArrow.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String grpIMoveArrow(String from, String to);

  /// No description provided for @grpIDeletedStillHasTasks.
  ///
  /// In en, this message translates to:
  /// **'{name} was deleted but still has tasks.'**
  String grpIDeletedStillHasTasks(String name);

  /// No description provided for @grpIMoveItsTasksTo.
  ///
  /// In en, this message translates to:
  /// **'Move its tasks to'**
  String get grpIMoveItsTasksTo;

  /// No description provided for @grpIDrillTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} · {count}{more} {count, plural, =1{task} other{tasks}}'**
  String grpIDrillTitle(String title, int count, String more);

  /// No description provided for @grpINoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks.'**
  String get grpINoTasks;

  /// No description provided for @grpIDrillTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the first tasks are listed; narrow the filter to see the rest.'**
  String get grpIDrillTruncated;

  /// No description provided for @grpIDueOn.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String grpIDueOn(String date);

  /// No description provided for @grpINothingToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get grpINothingToShow;

  /// No description provided for @grpIRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get grpIRefresh;

  /// No description provided for @grpIWidgetMenu.
  ///
  /// In en, this message translates to:
  /// **'Widget menu'**
  String get grpIWidgetMenu;

  /// No description provided for @grpIExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get grpIExportCsv;

  /// No description provided for @grpIRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get grpIRemove;

  /// No description provided for @grpISaveToSeeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Save to see numbers.'**
  String get grpISaveToSeeNumbers;

  /// No description provided for @grpICsvTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} (CSV)'**
  String grpICsvTitle(String title);

  /// No description provided for @grpICsvCopied.
  ///
  /// In en, this message translates to:
  /// **'CSV copied.'**
  String get grpICsvCopied;

  /// No description provided for @grpISaveAsFile.
  ///
  /// In en, this message translates to:
  /// **'Save as file'**
  String get grpISaveAsFile;

  /// No description provided for @grpILatestPoints.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest {limit} points; shorten the range to see them all.'**
  String grpILatestPoints(int limit);

  /// No description provided for @grpITopLimit.
  ///
  /// In en, this message translates to:
  /// **'Showing the top {limit}; narrow the filter to see the rest.'**
  String grpITopLimit(int limit);

  /// No description provided for @grpIWidget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get grpIWidget;

  /// No description provided for @grpITitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get grpITitle;

  /// No description provided for @grpIGroupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get grpIGroupBy;

  /// No description provided for @grpIFilterTfqlOptional.
  ///
  /// In en, this message translates to:
  /// **'Filter (TFQL, optional)'**
  String get grpIFilterTfqlOptional;

  /// No description provided for @grpIPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get grpIPreview;

  /// No description provided for @grpIProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get grpIProject;

  /// No description provided for @grpISprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint'**
  String get grpISprint;

  /// No description provided for @grpIDateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} → {end}'**
  String grpIDateRange(String start, String end);

  /// No description provided for @grpIFromDate.
  ///
  /// In en, this message translates to:
  /// **'from {date}'**
  String grpIFromDate(String date);

  /// No description provided for @grpINoDates.
  ///
  /// In en, this message translates to:
  /// **'no dates'**
  String get grpINoDates;

  /// No description provided for @grpIDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String grpIDaysCount(int count);

  /// No description provided for @grpINothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing is scheduled in this range.'**
  String get grpINothingScheduled;

  /// No description provided for @grpIOnCriticalPath.
  ///
  /// In en, this message translates to:
  /// **'on the critical path'**
  String get grpIOnCriticalPath;

  /// No description provided for @grpIBlocked.
  ///
  /// In en, this message translates to:
  /// **'blocked'**
  String get grpIBlocked;

  /// No description provided for @grpIMovingPushes.
  ///
  /// In en, this message translates to:
  /// **'Moving {id} pushes {count}'**
  String grpIMovingPushes(String id, int count);

  /// No description provided for @grpIRangeShift.
  ///
  /// In en, this message translates to:
  /// **'{from}  →  {to}'**
  String grpIRangeShift(String from, String to);

  /// No description provided for @grpIKeepThem.
  ///
  /// In en, this message translates to:
  /// **'Keep them (show conflict)'**
  String get grpIKeepThem;

  /// No description provided for @grpIShiftDependents.
  ///
  /// In en, this message translates to:
  /// **'Shift dependents'**
  String get grpIShiftDependents;

  /// No description provided for @grpIWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get grpIWeekdayMon;

  /// No description provided for @grpIWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get grpIWeekdayTue;

  /// No description provided for @grpIWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get grpIWeekdayWed;

  /// No description provided for @grpIWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get grpIWeekdayThu;

  /// No description provided for @grpIWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get grpIWeekdayFri;

  /// No description provided for @grpIWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get grpIWeekdaySat;

  /// No description provided for @grpIWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get grpIWeekdaySun;

  /// No description provided for @grpIWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'Working days'**
  String get grpIWorkingDays;

  /// No description provided for @grpIWorkingDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Moving a task past another skips the days off.'**
  String get grpIWorkingDaysHint;

  /// No description provided for @grpIHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get grpIHolidays;

  /// No description provided for @grpIHolidaysHint.
  ///
  /// In en, this message translates to:
  /// **'Dates like 2026-12-25, separated by commas'**
  String get grpIHolidaysHint;

  /// No description provided for @grpITimelineChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Timeline chart of {count} tasks. Switch to the list view to read them.'**
  String grpITimelineChartLabel(int count);

  /// No description provided for @grpITimelineDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a bar to move it, an end to resize it. Ctrl + wheel or pinch zooms.'**
  String get grpITimelineDragHint;

  /// No description provided for @grpIUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get grpIUnscheduled;

  /// No description provided for @grpIMovedLinksBreak.
  ///
  /// In en, this message translates to:
  /// **'Moved. The links it breaks show in red.'**
  String get grpIMovedLinksBreak;

  /// No description provided for @grpITimelineSaved.
  ///
  /// In en, this message translates to:
  /// **'Timeline saved.'**
  String get grpITimelineSaved;

  /// No description provided for @grpIDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get grpIDay;

  /// No description provided for @grpIWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get grpIWeek;

  /// No description provided for @grpIMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get grpIMonth;

  /// No description provided for @grpIQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get grpIQuarter;

  /// No description provided for @grpITaskTree.
  ///
  /// In en, this message translates to:
  /// **'Task tree'**
  String get grpITaskTree;

  /// No description provided for @grpIByAssignee.
  ///
  /// In en, this message translates to:
  /// **'By assignee'**
  String get grpIByAssignee;

  /// No description provided for @grpIByStatus.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get grpIByStatus;

  /// No description provided for @grpIEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get grpIEarlier;

  /// No description provided for @grpIToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get grpIToday;

  /// No description provided for @grpILater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get grpILater;

  /// No description provided for @grpICriticalPath.
  ///
  /// In en, this message translates to:
  /// **'Critical path'**
  String get grpICriticalPath;

  /// No description provided for @grpIHideDone.
  ///
  /// In en, this message translates to:
  /// **'Hide done'**
  String get grpIHideDone;

  /// No description provided for @grpIShowChart.
  ///
  /// In en, this message translates to:
  /// **'Show the chart'**
  String get grpIShowChart;

  /// No description provided for @grpIShowList.
  ///
  /// In en, this message translates to:
  /// **'Show as a list'**
  String get grpIShowList;

  /// No description provided for @grpIExportImage.
  ///
  /// In en, this message translates to:
  /// **'Export as an image'**
  String get grpIExportImage;

  /// No description provided for @grpICurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get grpICurrency;

  /// No description provided for @grpIClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get grpIClear;

  /// No description provided for @grpINone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get grpINone;

  /// No description provided for @grpIFieldArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived {name}. Values are kept 30 days.'**
  String grpIFieldArchived(String name);

  /// No description provided for @grpIFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get grpIFields;

  /// No description provided for @grpIAddField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get grpIAddField;

  /// No description provided for @grpINoCustomFields.
  ///
  /// In en, this message translates to:
  /// **'No custom fields yet. Add one for things like Customer or Story points.'**
  String get grpINoCustomFields;

  /// No description provided for @grpIArchivedRestorable.
  ///
  /// In en, this message translates to:
  /// **'Archived (restorable for 30 days)'**
  String get grpIArchivedRestorable;

  /// No description provided for @grpIRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get grpIRequired;

  /// No description provided for @grpIOptionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 options} other{{count} options}}'**
  String grpIOptionsCount(int count);

  /// No description provided for @grpIArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get grpIArchive;

  /// No description provided for @grpIWriteComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment… (@ to mention)'**
  String get grpIWriteComment;

  /// No description provided for @grpIComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get grpIComment;

  /// No description provided for @grpIBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get grpIBulletList;

  /// No description provided for @grpIQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get grpIQuote;

  /// No description provided for @grpICodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code block'**
  String get grpICodeBlock;

  /// No description provided for @grpILink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get grpILink;

  /// No description provided for @grpICouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file.'**
  String get grpICouldNotReadFile;

  /// No description provided for @grpICtrlEnterToSend.
  ///
  /// In en, this message translates to:
  /// **'Ctrl+Enter to send'**
  String get grpICtrlEnterToSend;

  /// No description provided for @grpIDeleteCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get grpIDeleteCommentTitle;

  /// No description provided for @grpIDeleteCommentBody.
  ///
  /// In en, this message translates to:
  /// **'It will show as \"Comment removed\". Its content and edit history are deleted.'**
  String get grpIDeleteCommentBody;

  /// No description provided for @grpICannotSeeTask.
  ///
  /// In en, this message translates to:
  /// **'They cannot see this task'**
  String get grpICannotSeeTask;

  /// No description provided for @grpICannotSeeGrant.
  ///
  /// In en, this message translates to:
  /// **'{names} cannot see this task. Add them to the project and send the comment, or take the mention out.'**
  String grpICannotSeeGrant(String names);

  /// No description provided for @grpICannotSeeRefuse.
  ///
  /// In en, this message translates to:
  /// **'{names} cannot see this task, so they cannot be mentioned. Take the mention out, or ask someone who manages the project to add them.'**
  String grpICannotSeeRefuse(String names);

  /// No description provided for @grpIOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get grpIOk;

  /// No description provided for @grpIAddThemAndSend.
  ///
  /// In en, this message translates to:
  /// **'Add them and send'**
  String get grpIAddThemAndSend;

  /// No description provided for @grpIEditHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit history · {author}'**
  String grpIEditHistory(String author);

  /// No description provided for @grpIRevisionCurrent.
  ///
  /// In en, this message translates to:
  /// **'{stamp} · current'**
  String grpIRevisionCurrent(String stamp);

  /// No description provided for @grpISessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get grpISessions;

  /// No description provided for @grpISignOutOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out other devices'**
  String get grpISignOutOthers;

  /// No description provided for @grpIUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get grpIUnknownDevice;

  /// No description provided for @grpIThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get grpIThisDevice;

  /// No description provided for @grpISignOutThis.
  ///
  /// In en, this message translates to:
  /// **'Sign out this device'**
  String get grpISignOutThis;

  /// No description provided for @grpJLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get grpJLink;

  /// No description provided for @grpJInviteEmails.
  ///
  /// In en, this message translates to:
  /// **'Email addresses'**
  String get grpJInviteEmails;

  /// No description provided for @grpJInviteEmailsHelp.
  ///
  /// In en, this message translates to:
  /// **'Separate several with commas. Up to {max}.'**
  String grpJInviteEmailsHelp(int max);

  /// No description provided for @grpJAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get grpJAdd;

  /// No description provided for @grpJInviteInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'\"{email}\" is not a valid email address.'**
  String grpJInviteInvalidEmail(String email);

  /// No description provided for @grpJInviteTooMany.
  ///
  /// In en, this message translates to:
  /// **'You can invite at most {max} people at once.'**
  String grpJInviteTooMany(int max);

  /// No description provided for @grpJInviteSendAll.
  ///
  /// In en, this message translates to:
  /// **'Send invitations'**
  String get grpJInviteSendAll;

  /// No description provided for @grpJInviteSendCount.
  ///
  /// In en, this message translates to:
  /// **'Send {count}'**
  String grpJInviteSendCount(int count);

  /// No description provided for @grpJInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited {count}.'**
  String grpJInvited(int count);

  /// No description provided for @grpJInviteSkipped.
  ///
  /// In en, this message translates to:
  /// **'Already members, skipped: {emails}'**
  String grpJInviteSkipped(String emails);

  /// No description provided for @grpJExpiresAfter.
  ///
  /// In en, this message translates to:
  /// **'Expires after'**
  String get grpJExpiresAfter;

  /// No description provided for @grpJDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String grpJDays(int count);

  /// No description provided for @grpJMaxUses.
  ///
  /// In en, this message translates to:
  /// **'Max uses'**
  String get grpJMaxUses;

  /// No description provided for @grpJMaxUsesHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for unlimited.'**
  String get grpJMaxUsesHelp;

  /// No description provided for @grpJMaxUsesInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to {max}, or leave empty.'**
  String grpJMaxUsesInvalid(int max);

  /// No description provided for @grpJCreateLink.
  ///
  /// In en, this message translates to:
  /// **'Create link'**
  String get grpJCreateLink;

  /// No description provided for @grpJCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get grpJCopyLink;

  /// No description provided for @grpJRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get grpJRole;

  /// No description provided for @grpJInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get grpJInvitationTitle;

  /// No description provided for @grpJJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get grpJJoin;

  /// No description provided for @grpJDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get grpJDecline;

  /// No description provided for @grpJGoToTaskForge.
  ///
  /// In en, this message translates to:
  /// **'Go to TaskForge'**
  String get grpJGoToTaskForge;

  /// No description provided for @grpJInvitedToJoin.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to join'**
  String get grpJInvitedToJoin;

  /// No description provided for @grpJInviterInvitedYou.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to join'**
  String grpJInviterInvitedYou(String name);

  /// No description provided for @grpJBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get grpJBack;

  /// No description provided for @grpJMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get grpJMembers;

  /// No description provided for @grpJInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get grpJInvite;

  /// No description provided for @grpJPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get grpJPending;

  /// No description provided for @grpJJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String grpJJoined(String date);

  /// No description provided for @grpJRemoveFromWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Remove from workspace'**
  String get grpJRemoveFromWorkspace;

  /// No description provided for @grpJSearchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get grpJSearchMembers;

  /// No description provided for @grpJRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String grpJRemoveMember(String name);

  /// No description provided for @grpJOwnerCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'You own this workspace, so you cannot leave it. Ownership cannot be transferred yet.'**
  String get grpJOwnerCannotLeave;

  /// No description provided for @grpJLeaveWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Leave workspace'**
  String get grpJLeaveWorkspace;

  /// No description provided for @grpJRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String grpJRemoveMemberTitle(String name);

  /// No description provided for @grpJRemoveMemberBody.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this workspace. You can invite them again later.'**
  String get grpJRemoveMemberBody;

  /// No description provided for @grpJRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get grpJRemove;

  /// No description provided for @grpJLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String grpJLeaveTitle(String name);

  /// No description provided for @grpJLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'You will lose access to this workspace until someone invites you again.'**
  String get grpJLeaveBody;

  /// No description provided for @grpJLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get grpJLeave;

  /// No description provided for @grpJErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'{error} Retry'**
  String grpJErrorRetry(String error);

  /// No description provided for @grpJLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get grpJLinkCopied;

  /// No description provided for @grpJNoInvitations.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet.'**
  String get grpJNoInvitations;

  /// No description provided for @grpJInvitationResent.
  ///
  /// In en, this message translates to:
  /// **'Invitation resent.'**
  String get grpJInvitationResent;

  /// No description provided for @grpJResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get grpJResend;

  /// No description provided for @grpJRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get grpJRevoke;

  /// No description provided for @grpJStatePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get grpJStatePending;

  /// No description provided for @grpJStateExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get grpJStateExpired;

  /// No description provided for @grpJStateRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get grpJStateRevoked;

  /// No description provided for @grpJStateUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Used up'**
  String get grpJStateUsedUp;

  /// No description provided for @grpJUsesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} use} other{{count} uses}}'**
  String grpJUsesCount(int count);

  /// No description provided for @grpJUsesOfMax.
  ///
  /// In en, this message translates to:
  /// **'{uses}/{max} uses'**
  String grpJUsesOfMax(int uses, int max);

  /// No description provided for @grpJInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get grpJInviteLink;

  /// No description provided for @grpJInvitationMeta.
  ///
  /// In en, this message translates to:
  /// **'by {name} · expires {date}'**
  String grpJInvitationMeta(String name, String date);

  /// No description provided for @grpJChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get grpJChangeRole;

  /// No description provided for @grpJBlockOptions.
  ///
  /// In en, this message translates to:
  /// **'Block options'**
  String get grpJBlockOptions;

  /// No description provided for @grpJMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get grpJMoveUp;

  /// No description provided for @grpJMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get grpJMoveDown;

  /// No description provided for @grpJAddBlockBelow.
  ///
  /// In en, this message translates to:
  /// **'Add block below'**
  String get grpJAddBlockBelow;

  /// No description provided for @grpJDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get grpJDelete;

  /// No description provided for @grpJTurnInto.
  ///
  /// In en, this message translates to:
  /// **'Turn into {label}'**
  String grpJTurnInto(String label);

  /// No description provided for @grpJClickToWrite.
  ///
  /// In en, this message translates to:
  /// **'Click here to start writing'**
  String get grpJClickToWrite;

  /// No description provided for @grpJAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Add block'**
  String get grpJAddBlock;

  /// No description provided for @grpJDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get grpJDocs;

  /// No description provided for @grpJPickPage.
  ///
  /// In en, this message translates to:
  /// **'Pick a page, or create one.'**
  String get grpJPickPage;

  /// No description provided for @grpJNoMatchingBlocks.
  ///
  /// In en, this message translates to:
  /// **'No matching blocks'**
  String get grpJNoMatchingBlocks;

  /// No description provided for @grpJNoMatchingPages.
  ///
  /// In en, this message translates to:
  /// **'No matching pages'**
  String get grpJNoMatchingPages;

  /// No description provided for @grpJTableRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get grpJTableRow;

  /// No description provided for @grpJTableColumn.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get grpJTableColumn;

  /// No description provided for @grpJNoImageAddress.
  ///
  /// In en, this message translates to:
  /// **'No image address yet'**
  String get grpJNoImageAddress;

  /// No description provided for @grpJImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image could not load'**
  String get grpJImageLoadFailed;

  /// No description provided for @grpJEditImage.
  ///
  /// In en, this message translates to:
  /// **'Edit image'**
  String get grpJEditImage;

  /// No description provided for @grpJLoadingTask.
  ///
  /// In en, this message translates to:
  /// **'Loading task...'**
  String get grpJLoadingTask;

  /// No description provided for @grpJNoAccessTask.
  ///
  /// In en, this message translates to:
  /// **'No access to this task'**
  String get grpJNoAccessTask;

  /// No description provided for @grpJUnknownBlock.
  ///
  /// In en, this message translates to:
  /// **'This block ({type}) needs a newer version of TaskForge. It is kept as it is.'**
  String grpJUnknownBlock(String type);

  /// No description provided for @grpJLinkAPage.
  ///
  /// In en, this message translates to:
  /// **'Link a page'**
  String get grpJLinkAPage;

  /// No description provided for @grpJNoPagesYetLong.
  ///
  /// In en, this message translates to:
  /// **'There are no pages yet.'**
  String get grpJNoPagesYetLong;

  /// No description provided for @grpJRelatedDocs.
  ///
  /// In en, this message translates to:
  /// **'Related docs'**
  String get grpJRelatedDocs;

  /// No description provided for @grpJNoPagesYet.
  ///
  /// In en, this message translates to:
  /// **'No pages yet.'**
  String get grpJNoPagesYet;

  /// No description provided for @grpJLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get grpJLinked;

  /// No description provided for @grpJEmbedded.
  ///
  /// In en, this message translates to:
  /// **'Embedded'**
  String get grpJEmbedded;

  /// No description provided for @grpJUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get grpJUnlink;

  /// No description provided for @grpJChangeTone.
  ///
  /// In en, this message translates to:
  /// **'Change tone ({tone})'**
  String grpJChangeTone(String tone);

  /// No description provided for @grpJBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get grpJBold;

  /// No description provided for @grpJItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get grpJItalic;

  /// No description provided for @grpJStrikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get grpJStrikethrough;

  /// No description provided for @grpJCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get grpJCode;

  /// No description provided for @grpJHintParagraph.
  ///
  /// In en, this message translates to:
  /// **'Type \'/\' for blocks, \'[[\' to mention a page'**
  String get grpJHintParagraph;

  /// No description provided for @grpJHintHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading {level}'**
  String grpJHintHeading(int level);

  /// No description provided for @grpJCodeLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get grpJCodeLanguageHint;

  /// No description provided for @grpJUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get grpJUndo;

  /// No description provided for @grpJRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get grpJRestore;

  /// No description provided for @grpJName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grpJName;

  /// No description provided for @grpJWorkspaceDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted. Restorable for 7 days.'**
  String grpJWorkspaceDeleted(String name);

  /// No description provided for @grpJDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get grpJDangerZone;

  /// No description provided for @grpJDangerZoneBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting a workspace hides it for everyone. You can restore it for 7 days.'**
  String get grpJDangerZoneBody;

  /// No description provided for @grpJDeleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Delete workspace'**
  String get grpJDeleteWorkspace;

  /// No description provided for @grpJDeleteWorkspaceQ.
  ///
  /// In en, this message translates to:
  /// **'Delete workspace?'**
  String get grpJDeleteWorkspaceQ;

  /// No description provided for @grpJTypeNameToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type \"{name}\" to confirm'**
  String grpJTypeNameToConfirm(String name);

  /// No description provided for @grpJNewWorkspace.
  ///
  /// In en, this message translates to:
  /// **'New workspace'**
  String get grpJNewWorkspace;

  /// No description provided for @grpJCreateYourWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create your workspace'**
  String get grpJCreateYourWorkspace;

  /// No description provided for @grpJWorkspaceHolds.
  ///
  /// In en, this message translates to:
  /// **'A workspace holds your team\'s projects and tasks.'**
  String get grpJWorkspaceHolds;

  /// No description provided for @grpJUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get grpJUrl;

  /// No description provided for @grpJCreateWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get grpJCreateWorkspace;

  /// No description provided for @grpJRecentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recently deleted'**
  String get grpJRecentlyDeleted;

  /// No description provided for @grpJSwitchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch workspace'**
  String get grpJSwitchWorkspace;

  /// No description provided for @grpJTimerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timer running'**
  String get grpJTimerRunning;

  /// No description provided for @grpJTimerStoppedOn.
  ///
  /// In en, this message translates to:
  /// **'Stopped the timer on {key} {title}'**
  String grpJTimerStoppedOn(String key, String title);

  /// No description provided for @grpJTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get grpJTime;

  /// No description provided for @grpJStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get grpJStop;

  /// No description provided for @grpJStartTimer.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get grpJStartTimer;

  /// No description provided for @grpJAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get grpJAddTime;

  /// No description provided for @grpJTimeOfEstimate.
  ///
  /// In en, this message translates to:
  /// **'{logged} of {estimate}'**
  String grpJTimeOfEstimate(String logged, String estimate);

  /// No description provided for @grpJTimeLogged.
  ///
  /// In en, this message translates to:
  /// **'{logged} logged'**
  String grpJTimeLogged(String logged);

  /// No description provided for @grpJTimeBillable.
  ///
  /// In en, this message translates to:
  /// **'{duration} billable'**
  String grpJTimeBillable(String duration);

  /// No description provided for @grpJChangeEstimate.
  ///
  /// In en, this message translates to:
  /// **'Change estimate'**
  String get grpJChangeEstimate;

  /// No description provided for @grpJSetEstimate.
  ///
  /// In en, this message translates to:
  /// **'Set estimate'**
  String get grpJSetEstimate;

  /// No description provided for @grpJRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get grpJRunning;

  /// No description provided for @grpJLoggedLabel.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get grpJLoggedLabel;

  /// No description provided for @grpJYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get grpJYou;

  /// No description provided for @grpJBillableSuffix.
  ///
  /// In en, this message translates to:
  /// **'billable'**
  String get grpJBillableSuffix;

  /// No description provided for @grpJOverlapsEntry.
  ///
  /// In en, this message translates to:
  /// **'Overlaps another entry'**
  String get grpJOverlapsEntry;

  /// No description provided for @grpJOver24h.
  ///
  /// In en, this message translates to:
  /// **'Over 24 h: check it'**
  String get grpJOver24h;

  /// No description provided for @grpJEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get grpJEdit;

  /// No description provided for @grpJStopTheTimer.
  ///
  /// In en, this message translates to:
  /// **'Stop the timer'**
  String get grpJStopTheTimer;

  /// No description provided for @grpJRoleActions.
  ///
  /// In en, this message translates to:
  /// **'Role actions'**
  String get grpJRoleActions;

  /// No description provided for @grpJRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get grpJRename;

  /// No description provided for @grpJBuiltInReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Built-in, read-only'**
  String get grpJBuiltInReadOnly;

  /// No description provided for @grpJRolesAndPermissions.
  ///
  /// In en, this message translates to:
  /// **'Roles and permissions'**
  String get grpJRolesAndPermissions;

  /// No description provided for @grpJNewRole.
  ///
  /// In en, this message translates to:
  /// **'New role'**
  String get grpJNewRole;

  /// No description provided for @grpJActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get grpJActivity;

  /// No description provided for @grpJNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get grpJNoActivity;

  /// No description provided for @grpJDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'TaskForge — connectivity'**
  String get grpJDebugTitle;

  /// No description provided for @grpJPingLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} ping'**
  String grpJPingLabel(String label);

  /// No description provided for @grpJPingError.
  ///
  /// In en, this message translates to:
  /// **'error: {error}'**
  String grpJPingError(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa', 'ps'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ps':
      return AppLocalizationsPs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
