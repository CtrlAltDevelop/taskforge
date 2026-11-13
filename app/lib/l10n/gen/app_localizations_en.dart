// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TaskForge';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get signOut => 'Sign out';

  @override
  String get inbox => 'Inbox';

  @override
  String get workspaceSettings => 'Workspace settings';

  @override
  String get homeLoadWorkspacesFailed =>
      'Could not load your workspaces. Retry';

  @override
  String get homeLoadAccountFailed => 'Could not load your account.';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarSubtitle => 'Everything due, across your projects';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get notificationSettingsSubtitle =>
      'What pings you, quiet hours and the digest';

  @override
  String get offlineAndStorage => 'Offline and storage';

  @override
  String get offlineAndStorageSubtitle =>
      'Changes made offline, the local copy';

  @override
  String get sessions => 'Sessions';

  @override
  String get sessionsSubtitle => 'Devices signed in to your account';

  @override
  String get changePassword => 'Change password';

  @override
  String get connectivity => 'Connectivity';

  @override
  String get languageAndRegion => 'Language and region';

  @override
  String get languageAndRegionSubtitle =>
      'Language, calendar, week start and digits';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get sendCode => 'Send code';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get setNewPassword => 'Set a new password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get codeFromEmail => 'Code from your email';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordChanged => 'Password changed. Sign in again.';

  @override
  String get passwordUpdated => 'Password updated. Sign in with it.';

  @override
  String get enterEmail => 'Enter your email address.';

  @override
  String get enterValidEmail => 'Enter a valid email address.';

  @override
  String get enterPassword => 'Enter a password.';

  @override
  String passwordTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get enterResetCode => 'Enter the code from your email.';

  @override
  String get enterYourPassword => 'Enter your password.';

  @override
  String get errWrongCredentials => 'Wrong email or password.';

  @override
  String get errTooManyAttempts =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get errAccountExists => 'An account with that email already exists.';

  @override
  String get errServerProblem =>
      'The server had a problem. Try again in a moment.';

  @override
  String get errNoConnection =>
      'Cannot reach the server. Check your connection and try again.';

  @override
  String get errGeneric => 'Something went wrong. Try again.';

  @override
  String get languageLabel => 'Language';

  @override
  String get calendarSystemLabel => 'Calendar';

  @override
  String get calendarGregorian => 'Gregorian';

  @override
  String get calendarJalali => 'Jalali (Solar Hijri)';

  @override
  String get weekStartLabel => 'Week starts on';

  @override
  String get weekStartDefault => 'Language default';

  @override
  String get weekSaturday => 'Saturday';

  @override
  String get weekSunday => 'Sunday';

  @override
  String get weekMonday => 'Monday';

  @override
  String get numeralsLabel => 'Digits';

  @override
  String get numeralsLatin => 'Western (0123)';

  @override
  String get numeralsNative => 'Native to the language';

  @override
  String get previewLabel => 'Preview';

  @override
  String get prefsSaveFailed =>
      'Saved on this device only. We could not reach the server.';

  @override
  String get workspaceDefaultLanguage => 'Default language for new members';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get jalaliMonth1 => 'Farvardin';

  @override
  String get jalaliMonth2 => 'Ordibehesht';

  @override
  String get jalaliMonth3 => 'Khordad';

  @override
  String get jalaliMonth4 => 'Tir';

  @override
  String get jalaliMonth5 => 'Mordad';

  @override
  String get jalaliMonth6 => 'Shahrivar';

  @override
  String get jalaliMonth7 => 'Mehr';

  @override
  String get jalaliMonth8 => 'Aban';

  @override
  String get jalaliMonth9 => 'Azar';

  @override
  String get jalaliMonth10 => 'Dey';

  @override
  String get jalaliMonth11 => 'Bahman';

  @override
  String get jalaliMonth12 => 'Esfand';

  @override
  String get pickDateOk => 'OK';

  @override
  String get pickDateTitle => 'Select date';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get grpACancel => 'Cancel';

  @override
  String get grpASave => 'Save';

  @override
  String get grpARetry => 'Retry';

  @override
  String get grpADone => 'Done';

  @override
  String get grpAClose => 'Close';

  @override
  String get grpAEdit => 'Edit';

  @override
  String get grpADelete => 'Delete';

  @override
  String get grpANote => 'Note';

  @override
  String get grpATotal => 'Total';

  @override
  String get grpATask => 'Task';

  @override
  String get grpAMerge => 'Merge';

  @override
  String get grpARemove => 'Remove';

  @override
  String get grpAOfflineBack => 'Back';

  @override
  String get grpAOfflineTitle => 'Offline and storage';

  @override
  String get grpAOfflineChooseWorkspace => 'Choose a workspace first.';

  @override
  String get grpAOfflineNeedsAttention => 'Needs your attention';

  @override
  String get grpAOfflineNothingToDecide =>
      'Nothing. Every change made offline was sent.';

  @override
  String grpAOfflineWaiting(int count) {
    return 'Waiting to be sent ($count)';
  }

  @override
  String get grpASyncNow => 'Sync now';

  @override
  String get grpAOfflineNothingWaiting => 'Nothing is waiting.';

  @override
  String get grpAEntryATask => 'a task';

  @override
  String grpAEntryNewTask(String title) {
    return 'New task “$title”';
  }

  @override
  String grpAEntryEdit(String name, String fields) {
    return 'Edit $name: $fields';
  }

  @override
  String grpAEntryDelete(String name) {
    return 'Delete $name';
  }

  @override
  String grpAEntryComment(String name) {
    return 'Comment on $name';
  }

  @override
  String grpAEntryUpload(String file, String name) {
    return 'Upload “$file” to $name';
  }

  @override
  String grpAOfflineClash(String field, String current, String mine) {
    return 'Theirs ($field): $current\nYours: $mine';
  }

  @override
  String get grpAKeepMine => 'Keep mine';

  @override
  String get grpATakeTheirs => 'Take theirs';

  @override
  String get grpATryAgain => 'Try again';

  @override
  String get grpADiscard => 'Discard';

  @override
  String get grpAMergeTitle => 'Which of your changes to keep?';

  @override
  String get grpAStorage => 'Storage';

  @override
  String get grpAReading => 'Reading…';

  @override
  String grpAStorageUsage(String size, int cap) {
    return 'The copy on this device holds $size MB of at most $cap MB.';
  }

  @override
  String get grpAMostItMayHold => 'Most it may hold';

  @override
  String grpAMegabytes(int mb) {
    return '$mb MB';
  }

  @override
  String get grpAClearCopy => 'Clear the copy on this device';

  @override
  String get grpAStorageNote =>
      'Changes still waiting to be sent are kept. The copy is stored unencrypted: use your device\'s disk encryption.';

  @override
  String get grpAClearTitle => 'Clear the copy on this device?';

  @override
  String get grpAClearBody =>
      'What you read is fetched again when you are online. Changes waiting to be sent are not removed.';

  @override
  String get grpAClear => 'Clear';

  @override
  String get grpAKeepOfflineTitle => 'Keep projects offline';

  @override
  String get grpAKeepOfflineBody =>
      'A kept project is copied whole, so its tasks, statuses and members are there without a connection. Other projects show what you read last.';

  @override
  String grpACopying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copying… $count tasks',
      one: 'Copying… 1 task',
    );
    return '$_temp0';
  }

  @override
  String get grpASprintsTitle => 'Sprints';

  @override
  String grpASprintsTitleProject(String name) {
    return 'Sprints · $name';
  }

  @override
  String get grpASprintsDisabled =>
      'Sprints are switched off for this project. Turn them on in the project settings.';

  @override
  String get grpAProjectNotFound => 'Project not found.';

  @override
  String grpAAddedAfterStart(int count) {
    return '$count added after the sprint started (shows as a scope change).';
  }

  @override
  String grpASprintCompleted(String name) {
    return '$name completed.';
  }

  @override
  String get grpAPlanning => 'Planning';

  @override
  String get grpAReports => 'Reports';

  @override
  String get grpANewSprint => 'New sprint';

  @override
  String get grpABacklog => 'Backlog';

  @override
  String get grpABacklogEmpty => 'The backlog is empty.';

  @override
  String get grpAAddToSprint => 'Add to sprint';

  @override
  String get grpANoOpenSprint =>
      'No open sprint. Create one to start planning.';

  @override
  String get grpADragHere => 'Drag tasks here, or select some in the backlog.';

  @override
  String grpADatesRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String grpADaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String grpASprintGoalText(String goal) {
    return 'Goal: $goal';
  }

  @override
  String get grpAShowOnBoard => 'Show on board';

  @override
  String get grpAEditSprint => 'Edit sprint';

  @override
  String get grpAStartSprint => 'Start sprint';

  @override
  String get grpACompleteSprint => 'Complete sprint';

  @override
  String get grpANoSprintsYet => 'No sprints yet.';

  @override
  String get grpASprintNameRequired => 'Give the sprint a name.';

  @override
  String get grpASprintDatesFormat => 'Dates are written YYYY-MM-DD.';

  @override
  String get grpASprintEndBeforeStart =>
      'The sprint cannot end before it starts.';

  @override
  String get grpASprintCapacityNumber =>
      'Capacity is a number, or empty for none.';

  @override
  String get grpASprintSaved => 'Sprint saved';

  @override
  String get grpASprintName => 'Name';

  @override
  String get grpASprintGoal => 'Goal';

  @override
  String get grpASprintStartLabel => 'Start (YYYY-MM-DD)';

  @override
  String get grpASprintEndLabel => 'End (YYYY-MM-DD)';

  @override
  String get grpAPickStartDate => 'Pick start date';

  @override
  String get grpAPickEndDate => 'Pick end date';

  @override
  String get grpACapacityPointsOptional => 'Capacity in points (optional)';

  @override
  String get grpACapacityHoursOptional => 'Capacity in hours (optional)';

  @override
  String grpASprintOverlap(String names) {
    return 'These dates overlap $names.';
  }

  @override
  String grpACompleteTitle(String name) {
    return 'Complete $name';
  }

  @override
  String grpACompleteCounts(int done, int open) {
    return '$done done, $open unfinished';
  }

  @override
  String get grpACompleteWhatHappens => 'What happens to the unfinished tasks?';

  @override
  String get grpACompleteMoveNext => 'Move to the next sprint';

  @override
  String get grpACompleteNoPlanned => 'No planned sprint to move them to';

  @override
  String get grpACompleteBackToBacklog => 'Back to the backlog';

  @override
  String grpAPointsFor(String key) {
    return 'Points for $key';
  }

  @override
  String get grpAPointsInvalid => 'Use a number, or leave empty to clear.';

  @override
  String get grpAStoryPoints => 'Story points';

  @override
  String get grpACapacityInHours => 'Capacity in hours';

  @override
  String get grpACapacityInPoints => 'Capacity in points';

  @override
  String grpABurndownTitle(String name) {
    return 'Burndown: $name';
  }

  @override
  String get grpAPoints => 'Points';

  @override
  String get grpATasks => 'Tasks';

  @override
  String get grpABurndownEmpty =>
      'The burndown starts once the sprint is started.';

  @override
  String grpABurndownChart(int days, int changes) {
    return 'Burndown chart, $days days, $changes scope changes';
  }

  @override
  String grpABurndownBackfilled(int count) {
    return ', $count back-filled days';
  }

  @override
  String get grpALegendRemaining => 'Remaining';

  @override
  String get grpALegendIdeal => 'Ideal';

  @override
  String get grpALegendScopeChange => 'Scope change';

  @override
  String get grpALegendBackfilled => 'Back-filled day';

  @override
  String get grpAVelocityEmpty =>
      'Velocity appears after the first completed sprint.';

  @override
  String grpAVelocityTitle(int count, String average) {
    return 'Velocity (last $count sprints): average $average points';
  }

  @override
  String grpAVelocityChart(int count) {
    return 'Velocity chart, $count sprints';
  }

  @override
  String get grpALegendCommitted => 'Committed';

  @override
  String get grpALegendCompleted => 'Completed';

  @override
  String get grpATimesheetTitle => 'Timesheet';

  @override
  String get grpAPreviousWeek => 'Previous week';

  @override
  String get grpANextWeek => 'Next week';

  @override
  String get grpAThisWeek => 'This week';

  @override
  String get grpATimesheetEmpty => 'No time logged this week.';

  @override
  String get grpARunning => 'Running';

  @override
  String get grpAAddTime => 'Add time';

  @override
  String get grpAYou => 'You';

  @override
  String get grpAProjectTotals => 'Project totals';

  @override
  String get grpAChooseProject => 'Choose a project';

  @override
  String get grpATotalsEmpty => 'No time logged in this project this week.';

  @override
  String grpABillableAmount(String duration) {
    return '  ($duration billable)';
  }

  @override
  String get grpAEditTime => 'Edit time';

  @override
  String get grpATimeSpent => 'Time spent';

  @override
  String get grpABillable => 'Billable';

  @override
  String get grpABadDuration => 'Enter a time like 1h 30m, 90m or 1:30.';

  @override
  String get grpAEstimate => 'Estimate';

  @override
  String get grpAEstimatedTime => 'Estimated time';

  @override
  String get grpAEmptyForNone => 'Empty for none';

  @override
  String get grpADeleteTimeTitle => 'Delete this time?';

  @override
  String get grpADeleteTimeBody => 'The logged time is removed for good.';

  @override
  String get grpAKeep => 'Keep';

  @override
  String get grpBCancel => 'Cancel';

  @override
  String get grpBOk => 'OK';

  @override
  String get grpBClose => 'Close';

  @override
  String get grpBSave => 'Save';

  @override
  String get grpBRetry => 'Retry';

  @override
  String get grpBRestore => 'Restore';

  @override
  String get grpBHistory => 'History';

  @override
  String get grpBCopy => 'Copy';

  @override
  String get grpBSaveAsFile => 'Save as file';

  @override
  String get grpBReply => 'Reply';

  @override
  String get grpBEdit => 'Edit';

  @override
  String get grpBDelete => 'Delete';

  @override
  String get grpBBack => 'Back';

  @override
  String get grpBSomeone => 'Someone';

  @override
  String get grpBYou => 'You';

  @override
  String get grpBLoading => 'Loading…';

  @override
  String get grpBPages => 'Pages';

  @override
  String get grpBRestricted => 'Restricted';

  @override
  String get grpBLinkTitle => 'Link';

  @override
  String get grpBLinkAddressLabel => 'Address (http, https or mailto)';

  @override
  String get grpBLinkInvalid => 'Use an http, https or mailto address.';

  @override
  String get grpBIconTitle => 'Page icon';

  @override
  String get grpBIconLabel => 'Emoji or short text (empty for none)';

  @override
  String get grpBIconInvalid => 'Use at most four characters.';

  @override
  String get grpBImageTitle => 'Image';

  @override
  String get grpBImageAddressLabel => 'Image address (http or https)';

  @override
  String get grpBDescription => 'Description';

  @override
  String get grpBImageInvalid => 'Use an http or https address.';

  @override
  String get grpBEmbedTaskTitle => 'Embed a task';

  @override
  String get grpBTaskSearchLabel => 'Search tasks or paste a task link';

  @override
  String get grpBUsePastedTask => 'Use the pasted task';

  @override
  String get grpBSnippetRemoved => '(removed)';

  @override
  String get grpBConflictTitle => 'Someone else changed this page';

  @override
  String get grpBConflictClean =>
      'Their changes do not overlap with yours. They will be merged.';

  @override
  String get grpBConflictOverlap =>
      'Both of you changed these blocks. Choose which to keep; everything else is merged.';

  @override
  String grpBConflictBlock(String snippet) {
    return 'Block: $snippet';
  }

  @override
  String grpBConflictMine(String snippet) {
    return 'Mine: $snippet';
  }

  @override
  String grpBConflictTheirs(String snippet) {
    return 'Theirs: $snippet';
  }

  @override
  String get grpBDecideLater => 'Decide later';

  @override
  String get grpBDiscardMine => 'Discard mine';

  @override
  String get grpBApplyAndSave => 'Apply and save';

  @override
  String get grpBShareTitle => 'Page access';

  @override
  String get grpBShareRestrict => 'Restrict this page';

  @override
  String get grpBShareRestrictedHint =>
      'Only the people below, its creator and page managers (also for the pages under it).';

  @override
  String get grpBShareOpenHint =>
      'Everyone who can open the parent can open it.';

  @override
  String get grpBShareNeedPermission =>
      'You need permission \"doc.manage\" to change this.';

  @override
  String get grpBEmptyPage => '(empty page)';

  @override
  String grpBImageBlock(String alt) {
    return '[Image $alt]';
  }

  @override
  String get grpBTaskCardBlock => '[Task card]';

  @override
  String get grpBAllRevisions => 'All revisions';

  @override
  String get grpBNoRevisions => 'No revisions yet.';

  @override
  String grpBVersionN(int version) {
    return 'Version $version';
  }

  @override
  String grpBVersionShort(int version) {
    return 'v$version';
  }

  @override
  String get grpBRevisionsLoadFailed => 'Could not load history. Retry';

  @override
  String get grpBRevisionLoadFailed => 'Could not load this revision.';

  @override
  String get grpBRestoreVersion => 'Restore this version';

  @override
  String grpBLinkedFrom(int count) {
    return 'Linked from ($count)';
  }

  @override
  String get grpBNoBacklinks => 'No page mentions this one.';

  @override
  String grpBMarkdownTitle(String title) {
    return 'Markdown: $title';
  }

  @override
  String get grpBMarkdownCopied => 'Markdown copied.';

  @override
  String get grpBSaveSaved => 'Saved';

  @override
  String get grpBSaveDirty => 'Unsaved changes';

  @override
  String get grpBSaveSaving => 'Saving...';

  @override
  String get grpBSaveError => 'Could not save';

  @override
  String get grpBSaveConflict => 'Conflict: choose what to keep';

  @override
  String get grpBDocsCrumb => 'Docs';

  @override
  String get grpBDocNotFound =>
      'This page does not exist, or you cannot open it.';

  @override
  String get grpBBackToAllPages => 'Back to all pages';

  @override
  String get grpBArchivedBanner => 'This page is archived. It is read-only.';

  @override
  String get grpBConflictBanner =>
      'Someone else changed this page. Your changes are not saved yet.';

  @override
  String get grpBResolve => 'Resolve';

  @override
  String get grpBRemoteBanner =>
      'A newer version was saved by someone else. It will be merged when you save.';

  @override
  String grpBIsEditing(String name) {
    return '$name is editing';
  }

  @override
  String grpBAreEditing(String names) {
    return '$names are editing';
  }

  @override
  String get grpBChangeIcon => 'Change icon';

  @override
  String get grpBUntitled => 'Untitled';

  @override
  String get grpBReadOnly => 'Read only';

  @override
  String get grpBAccess => 'Access';

  @override
  String get grpBExportMarkdown => 'Export Markdown';

  @override
  String grpBMoveUnder(String name) {
    return 'Move \"$name\" under';
  }

  @override
  String get grpBTopLevel => 'Top level';

  @override
  String get grpBCollapse => 'Collapse';

  @override
  String get grpBExpand => 'Expand';

  @override
  String get grpBPageOptions => 'Page options';

  @override
  String get grpBNewSubpage => 'New subpage';

  @override
  String get grpBMoveUp => 'Move up';

  @override
  String get grpBMoveDown => 'Move down';

  @override
  String get grpBMoveTo => 'Move to...';

  @override
  String get grpBArchive => 'Archive';

  @override
  String get grpBHideArchived => 'Hide archived';

  @override
  String get grpBShowArchived => 'Show archived';

  @override
  String get grpBNewPage => 'New page';

  @override
  String get grpBNoPagesYet => 'No pages yet.';

  @override
  String get grpBPagesLoadFailed => 'Could not load pages. Retry';

  @override
  String get grpBToday => 'Today';

  @override
  String get grpBYesterday => 'Yesterday';

  @override
  String get grpBSubtaskCreated => 'Subtask created.';

  @override
  String get grpBComments => 'Comments';

  @override
  String grpBCommentsCount(int count) {
    return 'Comments ($count)';
  }

  @override
  String get grpBNoComments => 'No comments yet.';

  @override
  String get grpBLoadEarlier => 'Load earlier comments';

  @override
  String get grpBPinned => 'Pinned';

  @override
  String get grpBReplyHint => 'Reply…';

  @override
  String get grpBArchivedReadOnly =>
      'This project is archived: comments are read-only.';

  @override
  String get grpBReadOnlyComments =>
      'You can read comments but not write them.';

  @override
  String get grpBCommentRemoved => 'Comment removed';

  @override
  String get grpBUnpin => 'Unpin';

  @override
  String get grpBPin => 'Pin';

  @override
  String get grpBMakeSubtask => 'Make a subtask';

  @override
  String get grpBEditHistory => 'Edit history';

  @override
  String grpBEditedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Edited $count times: tap to see the history',
      one: 'Edited once: tap to see the history',
    );
    return '$_temp0';
  }

  @override
  String get grpBEdited => 'edited';

  @override
  String get grpBCommentActions => 'Comment actions';

  @override
  String get grpBWaitingToSend => 'Waiting to be sent';

  @override
  String get grpBSending => 'Sending…';

  @override
  String get grpBNotSent => 'Not sent';

  @override
  String get grpBDiscard => 'Discard';

  @override
  String get grpBAddReaction => 'Add a reaction';

  @override
  String get grpBAuditAll => 'All';

  @override
  String get grpBAuditTasks => 'Tasks';

  @override
  String get grpBAuditFiles => 'Files';

  @override
  String get grpBAuditProjects => 'Projects';

  @override
  String get grpBAuditMembers => 'Members';

  @override
  String get grpBAuditRoles => 'Roles';

  @override
  String get grpBAuditInvitations => 'Invitations';

  @override
  String get grpBAuditSignIn => 'Sign-in';

  @override
  String get grpBAuditTitle => 'Audit log';

  @override
  String get grpBExportCsv => 'Export as CSV';

  @override
  String get grpBAuditDenied => 'You are not allowed to read the audit log.';

  @override
  String get grpBAuditEmpty => 'Nothing recorded for these filters.';

  @override
  String get grpBShowOlder => 'Show older';

  @override
  String get grpBAnyone => 'Anyone';

  @override
  String get grpBAnyProject => 'Any project';

  @override
  String get grpBAnyTime => 'Any time';

  @override
  String get grpBClearFilters => 'Clear filters';

  @override
  String get grpBBulkChange => 'Part of a bulk change';

  @override
  String grpBCharacters(String size) {
    return '($size characters)';
  }

  @override
  String get grpBNoFieldChanges => 'No field changes recorded.';

  @override
  String get grpBAuditExportTitle => 'Audit log (CSV)';

  @override
  String grpBAuditExportNote(int shown, int total) {
    return 'Showing the first $shown of $total lines. Copy or Save has all of them.';
  }

  @override
  String get grpBCsvCopied => 'CSV copied.';

  @override
  String get grpCCancel => 'Cancel';

  @override
  String get grpCDelete => 'Delete';

  @override
  String get grpCRetry => 'Retry';

  @override
  String get grpCBack => 'Back';

  @override
  String get grpCUndo => 'Undo';

  @override
  String get grpCField => 'Field';

  @override
  String get grpCStatus => 'Status';

  @override
  String get grpCComment => 'Comment';

  @override
  String get grpCValue => 'Value';

  @override
  String get grpCDashNew => 'New dashboard';

  @override
  String grpCDashDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get grpCDashDeleteBody =>
      'Its widgets go with it. This cannot be undone.';

  @override
  String get grpCDashTitle => 'Dashboards';

  @override
  String grpCDashTitleProject(String project) {
    return 'Dashboards · $project';
  }

  @override
  String get grpCDashEmpty => 'No dashboards yet.';

  @override
  String get grpCDashBlankDashboard => 'Blank dashboard';

  @override
  String get grpCDashProjectOverview => 'Project overview';

  @override
  String get grpCDashMyWork => 'My work';

  @override
  String get grpCDashBlank => 'Blank';

  @override
  String get grpCDashEdit => 'Edit';

  @override
  String get grpCDashRefresh => 'Refresh';

  @override
  String get grpCDashAddWidget => 'Add widget';

  @override
  String get grpCDashSave => 'Save';

  @override
  String get grpCDashDialogTitle => 'Dashboard';

  @override
  String get grpCDashName => 'Name';

  @override
  String get grpCDashShareDenied =>
      'Sharing needs the dashboard.manage permission.';

  @override
  String get grpCDashOk => 'OK';

  @override
  String get grpCImpTitle => 'Import and export';

  @override
  String get grpCImpExport => 'Export';

  @override
  String get grpCImpDenied => 'Only admins can import and export data.';

  @override
  String get grpCImpPast => 'Past imports';

  @override
  String get grpCImpNothing => 'Nothing imported yet.';

  @override
  String grpCImpTasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get grpCImpResume => 'Resume';

  @override
  String get grpCImpContinue => 'Continue';

  @override
  String get grpCImpForget => 'Forget';

  @override
  String get grpCImpUndoTitle => 'Undo this import?';

  @override
  String get grpCImpUndoBody =>
      'This removes what it made. Anything you added by hand is kept.';

  @override
  String get grpCImpUndoConfirm => 'Undo import';

  @override
  String grpCImpClaimTitle(String name) {
    return 'Give $name\'s tasks to...';
  }

  @override
  String get grpCImpChooseMember => 'Choose a member';

  @override
  String get grpCImpAssign => 'Assign';

  @override
  String grpCImpAssigned(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Assigned $n tasks.',
      one: 'Assigned $n task.',
    );
    return '$_temp0';
  }

  @override
  String get grpCImpWaiting => 'People waiting to join';

  @override
  String get grpCImpWaitingBody =>
      'Their tasks are assigned automatically when someone joins with the same email.';

  @override
  String get grpCImpNoEmail => 'no email';

  @override
  String grpCImpPersonSub(String email, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '$count task',
    );
    return '$email · $_temp0';
  }

  @override
  String get grpCImpAssignTo => 'Assign to...';

  @override
  String get grpCImpStepSource => 'Source';

  @override
  String get grpCImpStepUpload => 'Upload';

  @override
  String get grpCImpStepMap => 'Map';

  @override
  String get grpCImpStepReview => 'Review';

  @override
  String get grpCImpStepImport => 'Import';

  @override
  String get grpCImpWhere => 'Where is your data coming from?';

  @override
  String get grpCImpAuto => 'I am not sure: work it out from the file';

  @override
  String get grpCImpNext => 'Next';

  @override
  String get grpCImpZipSeveral =>
      'This zip holds several data files. Which one do you want to import? (A workspace export has one per project.)';

  @override
  String get grpCImpChooseAFile => 'Choose a file';

  @override
  String get grpCImpChooseGeneric =>
      'Choose the file to import (.csv, .json, or a .zip of one).';

  @override
  String grpCImpChooseSource(String source) {
    return 'Choose your $source file (.csv, .json, or a .zip of one).';
  }

  @override
  String get grpCImpSentNote =>
      'The file is sent to your TaskForge server and read as a stream, so large exports are fine. Nothing is changed until you confirm.';

  @override
  String get grpCImpPickFile => 'Choose file';

  @override
  String get grpCImpResumeThis => 'Resume this import';

  @override
  String get grpCImpWhatHappens => 'This is what will happen';

  @override
  String get grpCImpCountTasks => 'tasks';

  @override
  String get grpCImpCountSubtasks => 'of them sub-tasks';

  @override
  String get grpCImpCountComments => 'comments';

  @override
  String get grpCImpCountLinks => 'links';

  @override
  String get grpCImpCountSprints => 'sprints';

  @override
  String get grpCImpCountLabels => 'labels';

  @override
  String get grpCImpCountStatuses => 'new statuses';

  @override
  String get grpCImpCountPlaceholders => 'people to wait for';

  @override
  String grpCImpAlready(int count) {
    return '$count of these were imported before and will be skipped, not duplicated.';
  }

  @override
  String grpCImpRowErrors(int count) {
    return '$count row(s) cannot be imported and will be left out.';
  }

  @override
  String get grpCImpResumeImport => 'Resume import';

  @override
  String get grpCImpStart => 'Start import';

  @override
  String get grpCImpUndoRunBody =>
      'This removes the tasks, comments, links, sprints and statuses this import made. Anything you added to them by hand is kept.';

  @override
  String get grpCImpWaitingStart => 'Waiting to start...';

  @override
  String get grpCImpLinking => 'Linking tasks...';

  @override
  String grpCImpProgress(int done, int total) {
    return '$done of $total tasks';
  }

  @override
  String get grpCImpCancel => 'Cancel import';

  @override
  String get grpCImpFinished => 'Import finished';

  @override
  String get grpCImpUndone => 'Import undone';

  @override
  String get grpCImpCancelled => 'Import cancelled';

  @override
  String get grpCImpStopped => 'Import stopped';

  @override
  String get grpCImpOpenProject => 'Open the project';

  @override
  String get grpCImpAnother => 'Import another file';

  @override
  String grpCImpRemoved(num tasks) {
    return 'Removed $tasks tasks.';
  }

  @override
  String grpCImpRemovedKept(num tasks, num kept) {
    return 'Removed $tasks tasks, kept $kept that have your own sub-tasks.';
  }

  @override
  String get grpCImpTheFile => 'the file';

  @override
  String grpCImpSummary(int issues, int comments, int links, String file) {
    return '$issues tasks, $comments comments, $links links found in $file.';
  }

  @override
  String grpCImpSummarySub(
    int issues,
    int subtasks,
    int comments,
    int links,
    String file,
  ) {
    return '$issues tasks ($subtasks sub-tasks), $comments comments, $links links found in $file.';
  }

  @override
  String get grpCImpPriUrgent => 'Urgent';

  @override
  String get grpCImpPriHigh => 'High';

  @override
  String get grpCImpPriNormal => 'Normal';

  @override
  String get grpCImpPriLow => 'Low';

  @override
  String get grpCImpPriNone => 'None';

  @override
  String get grpCImpFTitle => 'Title *';

  @override
  String get grpCImpFDescription => 'Description';

  @override
  String get grpCImpFPriority => 'Priority';

  @override
  String get grpCImpFAssignee => 'Assignee';

  @override
  String get grpCImpFReporter => 'Reporter';

  @override
  String get grpCImpFCreated => 'Created';

  @override
  String get grpCImpFUpdated => 'Updated';

  @override
  String get grpCImpFStart => 'Start date';

  @override
  String get grpCImpFDue => 'Due date';

  @override
  String get grpCImpFLabels => 'Labels';

  @override
  String get grpCImpFSprint => 'Sprint';

  @override
  String get grpCImpFParent => 'Parent (id)';

  @override
  String get grpCImpFId => 'Id';

  @override
  String get grpCImpFKey => 'Key';

  @override
  String get grpCImpFPoints => 'Story points';

  @override
  String get grpCImpFEstimate => 'Estimate';

  @override
  String get grpCImpFType => 'Type';

  @override
  String get grpCImpPriorities => 'Priorities';

  @override
  String grpCImpKeepLabels(int count) {
    return 'Keep $count labels';
  }

  @override
  String get grpCImpKeepLabelsSub => 'As a \"Labels\" field on every task.';

  @override
  String grpCImpSprintsCreated(String sprints) {
    return 'Sprints that will be created: $sprints';
  }

  @override
  String get grpCImpReview => 'Review';

  @override
  String get grpCImpReadAs => 'Read as';

  @override
  String get grpCImpZipFile => 'File inside the zip';

  @override
  String get grpCImpChooseOne => 'Choose one';

  @override
  String get grpCImpInto => 'Import into';

  @override
  String get grpCImpNewProject => 'A new project';

  @override
  String get grpCImpExistingProject => 'An existing project';

  @override
  String get grpCImpProjectName => 'Project name';

  @override
  String get grpCImpColumns => 'Columns';

  @override
  String get grpCImpNotInFile => '(not in the file)';

  @override
  String get grpCImpStatuses => 'Statuses';

  @override
  String get grpCImpSameName => 'Same name (create if missing)';

  @override
  String get grpCImpPeople => 'People';

  @override
  String get grpCImpNotMember => 'Not a member yet (assign when they join)';

  @override
  String get grpCImpUnassigned => 'Leave unassigned';

  @override
  String get grpCImpFirst200 =>
      'Only the first 200 people are listed; the rest wait as placeholders.';

  @override
  String grpCAutoDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get grpCAutoDeleteBody =>
      'The rule stops for good. Its run history is deleted too.';

  @override
  String get grpCAutoTitle => 'Automations';

  @override
  String grpCAutoTitleProject(String project) {
    return 'Automations · $project';
  }

  @override
  String get grpCAutoMissing => 'Project not found.';

  @override
  String get grpCAutoRules => 'Rules';

  @override
  String get grpCAutoRunHistory => 'Run history';

  @override
  String get grpCAutoNew => 'New automation';

  @override
  String get grpCAutoReadOnly => 'Read only';

  @override
  String grpCAutoLimit(int limit) {
    return 'Limit of $limit rules reached.';
  }

  @override
  String grpCAutoRuleFilter(String name) {
    return 'Rule: $name';
  }

  @override
  String get grpCAutoEmpty =>
      'No automations yet. A rule says: when something happens, and if it matches, then do these things.';

  @override
  String grpCAutoWhen(String trigger, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '$count action',
    );
    return 'When $trigger · $_temp0';
  }

  @override
  String get grpCAutoNeverRun => 'Never run';

  @override
  String get grpCAutoHistory => 'History';

  @override
  String get grpCAutoDryRun => 'Dry run';

  @override
  String get grpCAutoStatusChanges => 'a status changes';

  @override
  String grpCAutoMovesTo(String status) {
    return 'a task moves to $status';
  }

  @override
  String grpCAutoFieldChanges(String field) {
    return '$field changes';
  }

  @override
  String get grpCAutoSomeoneAssigned => 'someone is assigned';

  @override
  String grpCAutoUserAssigned(String user) {
    return '$user is assigned';
  }

  @override
  String get grpCAutoDueReached => 'a due date is reached';

  @override
  String grpCAutoDaysBefore(int days) {
    return '$days days before a due date';
  }

  @override
  String get grpCAutoDeletedStatus => 'Deleted status';

  @override
  String get grpCAutoUnknownPerson => 'Unknown person';

  @override
  String get grpCAutoEvent => 'Event';

  @override
  String get grpCAutoMovesToLabel => 'Moves to';

  @override
  String get grpCAutoAnyStatus => 'Any status';

  @override
  String get grpCAutoAssignedPerson => 'Assigned person';

  @override
  String get grpCAutoAnyone => 'Anyone';

  @override
  String grpCAutoDaysLabel(int max) {
    return 'Days before the due date (0 to $max)';
  }

  @override
  String grpCAutoTokensHelp(String tokens) {
    return 'You may use $tokens';
  }

  @override
  String get grpCAutoDateHint => 'YYYY-MM-DD';

  @override
  String grpCAutoUseToken(String token) {
    return 'Use $token';
  }

  @override
  String get grpCAutoHow => 'How';

  @override
  String get grpCAutoReplaceAssignees => 'Replace assignees with';

  @override
  String get grpCAutoAdd => 'Add';

  @override
  String get grpCAutoRemoveEveryone => 'Remove everyone';

  @override
  String get grpCAutoSubtaskTitle => 'Subtask title';

  @override
  String get grpCAutoMessage => 'Message';

  @override
  String get grpCAutoAddress => 'Address';

  @override
  String get grpCAutoAddressHelp =>
      'Public http(s) addresses only; private ones are refused.';

  @override
  String get grpCAutoMethod => 'Method';

  @override
  String get grpCAutoDoThis => 'Do this';

  @override
  String grpDActionFailed(String error) {
    return 'That did not work ($error).';
  }

  @override
  String get grpDSwitchWorkspace => 'Switch workspace';

  @override
  String grpDWorkspaceHere(String name) {
    return '$name (here)';
  }

  @override
  String get grpDNewDoc => 'New doc';

  @override
  String get grpDTitle => 'Title';

  @override
  String get grpDUntitled => 'Untitled';

  @override
  String get grpDNewDashboard => 'New dashboard';

  @override
  String get grpDNewSprint => 'New sprint';

  @override
  String grpDStatusOf(String id) {
    return 'Status of $id';
  }

  @override
  String get grpDNewTask => 'New task';

  @override
  String get grpDCancel => 'Cancel';

  @override
  String get grpDCreate => 'Create';

  @override
  String get grpDSort => 'Sort';

  @override
  String get grpDNoSort => 'No sort';

  @override
  String grpDSortBy(String names) {
    return 'Sort: $names';
  }

  @override
  String get grpDGroup => 'Group';

  @override
  String get grpDNoGrouping => 'No grouping';

  @override
  String grpDGroupBy(String name) {
    return 'Group: $name';
  }

  @override
  String get grpDColumns => 'Columns';

  @override
  String get grpDRefresh => 'Refresh';

  @override
  String get grpDLayoutNotSaved =>
      'Your layout could not be saved. It will be tried again on your next change.';

  @override
  String get grpDLayouts => 'Layouts';

  @override
  String get grpDResetLayout => 'Reset my layout';

  @override
  String get grpDShareLayoutMenu => 'Share this layout…';

  @override
  String grpDDeleteShared(String name) {
    return 'Delete shared “$name”';
  }

  @override
  String grpDDeleteSharedTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get grpDDeleteSharedBody =>
      'It disappears for everyone on this project.';

  @override
  String get grpDDelete => 'Delete';

  @override
  String grpDDeletedNamed(String name) {
    return 'Deleted “$name”';
  }

  @override
  String grpDSharedNamed(String name) {
    return 'Shared “$name”';
  }

  @override
  String get grpDShareLayoutTitle => 'Share this layout';

  @override
  String get grpDName => 'Name';

  @override
  String get grpDShare => 'Share';

  @override
  String get grpDTaskNotFound => 'Task not found.';

  @override
  String get grpDDeleteTask => 'Delete task';

  @override
  String get grpDClose => 'Close';

  @override
  String get grpDPriority => 'Priority';

  @override
  String get grpDStart => 'Start';

  @override
  String get grpDDue => 'Due';

  @override
  String get grpDAssignees => 'Assignees';

  @override
  String get grpDDescription => 'Description';

  @override
  String grpDTaskDeleted(String id) {
    return '$id deleted';
  }

  @override
  String get grpDUndo => 'Undo';

  @override
  String get grpDStatus => 'Status';

  @override
  String grpDClearField(String label) {
    return 'Clear $label';
  }

  @override
  String get grpDDueTime => 'Due time (your clock)';

  @override
  String get grpDClearDueTime => 'Clear due time';

  @override
  String get grpDAllOf => 'All of';

  @override
  String get grpDAnyOf => 'Any of';

  @override
  String get grpDNot => 'NOT';

  @override
  String get grpDRemoveGroup => 'Remove group';

  @override
  String get grpDCondition => 'Condition';

  @override
  String get grpDFieldRemoved => 'Field (removed)';

  @override
  String get grpDRemoveCondition => 'Remove condition';

  @override
  String get grpDOpBefore => 'is before';

  @override
  String get grpDOpOnOrBefore => 'is on or before';

  @override
  String get grpDOpAfter => 'is after';

  @override
  String get grpDOpOnOrAfter => 'is on or after';

  @override
  String get grpDOpLessThan => 'is less than';

  @override
  String get grpDOpAtMost => 'is at most';

  @override
  String get grpDOpMoreThan => 'is more than';

  @override
  String get grpDOpAtLeast => 'is at least';

  @override
  String get grpDYes => 'Yes';

  @override
  String get grpDNo => 'No';

  @override
  String get grpDCurrentSprint => 'the current sprint';

  @override
  String get grpDMe => 'Me';

  @override
  String get grpDChoose => 'Choose…';

  @override
  String get grpDValue => 'Value';

  @override
  String get grpDPickDate => 'Pick a date';

  @override
  String get grpDOrderByLabel => 'Order by ';

  @override
  String get grpDAscending => 'Ascending';

  @override
  String get grpDDescending => 'Descending';

  @override
  String get grpDRemoveOrdering => 'Remove ordering';

  @override
  String get grpDOrderBy => 'Order by';

  @override
  String get grpDRepeatNothingToUpdate =>
      'New tasks will use this one. No open task needed changing.';

  @override
  String grpDRepeatUpdatedLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks',
      one: 'task',
    );
    return 'Updated $count open later $_temp0.';
  }

  @override
  String get grpDRepeat => 'Repeat';

  @override
  String grpDRepeatUnsupported(String summary) {
    return '\"$summary\" was set in a way this editor cannot show, so it cannot be changed here. You can still pause or stop it.';
  }

  @override
  String get grpDSkipWeekends => 'Skip weekends';

  @override
  String get grpDStopRepeating => 'Stop repeating';

  @override
  String get grpDResume => 'Resume';

  @override
  String get grpDPause => 'Pause';

  @override
  String get grpDUseForFuture => 'Use this task for future ones';

  @override
  String get grpDSave => 'Save';

  @override
  String get grpDEvery => 'Every';

  @override
  String get grpDRepeatByDay => 'On a day of the month';

  @override
  String get grpDRepeatByWeekday => 'On the nth weekday';

  @override
  String grpDDayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get grpDNth1 => '1st';

  @override
  String get grpDNth2 => '2nd';

  @override
  String get grpDNth3 => '3rd';

  @override
  String get grpDNth4 => '4th';

  @override
  String get grpDNthLast => 'last';

  @override
  String get grpDEnds => 'Ends';

  @override
  String get grpDEndNever => 'Never';

  @override
  String get grpDEndAfter => 'After';

  @override
  String get grpDEndOn => 'On';

  @override
  String get grpDTasksWord => 'tasks';

  @override
  String get grpDMakeIt => 'Make it';

  @override
  String get grpDDaysAhead => 'days ahead of its due date';

  @override
  String grpDRepeatAt(String time) {
    return 'At $time';
  }

  @override
  String get grpDNoFurtherDates => 'No further dates.';

  @override
  String grpDNextDates(String dates) {
    return 'Next: $dates';
  }

  @override
  String get grpEBack => 'Back';

  @override
  String get grpECancel => 'Cancel';

  @override
  String get grpEName => 'Name';

  @override
  String get grpERetry => 'Retry';

  @override
  String get grpEWorkspaceSettingsTitle => 'Workspace settings';

  @override
  String get grpEWorkspacesLoadRetry => 'Could not load your workspaces. Retry';

  @override
  String get grpEMembers => 'Members';

  @override
  String get grpEMembersSub => 'People, invitations and leaving';

  @override
  String get grpERolesPerms => 'Roles and permissions';

  @override
  String get grpERolesPermsSub => 'Who can do what';

  @override
  String get grpEAuditLog => 'Audit log';

  @override
  String get grpEAuditLogSub => 'Who changed what, and when';

  @override
  String get grpEImportExport => 'Import and export';

  @override
  String get grpEImportExportSub =>
      'Bring in Jira, ClickUp or CSV data; take it out';

  @override
  String get grpEWorkspaceUpdated => 'Workspace updated.';

  @override
  String get grpEGeneral => 'General';

  @override
  String get grpEChangeLogo => 'Change logo';

  @override
  String get grpEUrl => 'URL';

  @override
  String get grpERefresh => 'Refresh';

  @override
  String get grpESaveChanges => 'Save changes';

  @override
  String get grpENotifSettings => 'Notification settings';

  @override
  String get grpEPushOffNotice =>
      'Notifications are off for this device. You can allow them in the system settings; the choice is saved.';

  @override
  String get grpEZoneInvalid => 'Use a name like Europe/Paris or UTC.';

  @override
  String get grpEQuietDifferent => 'Start and end must be different times.';

  @override
  String get grpEWhatReachesYou => 'What reaches you';

  @override
  String get grpEInbox => 'Inbox';

  @override
  String get grpEPush => 'Push';

  @override
  String get grpEEmail => 'Email';

  @override
  String get grpEQuietHours => 'Quiet hours';

  @override
  String get grpEQuietHold => 'Hold push and email during quiet hours';

  @override
  String get grpEQuietHoldSub => 'The inbox always fills; only pings wait.';

  @override
  String get grpEFrom => 'From';

  @override
  String get grpEUntil => 'Until';

  @override
  String get grpETimeZoneDigest => 'Time zone and digest';

  @override
  String get grpETimeZone => 'Time zone';

  @override
  String get grpETimeZoneHelper =>
      'Quiet hours and the digest follow this zone.';

  @override
  String get grpEUseDeviceZone => 'Use this device’s time zone';

  @override
  String get grpETypeZone => 'Type your time zone instead, e.g. Europe/Paris.';

  @override
  String get grpEDigestAt => 'Daily digest is sent at';

  @override
  String get grpEEditField => 'Edit field';

  @override
  String get grpENewField => 'New field';

  @override
  String get grpEType => 'Type';

  @override
  String get grpEOptions => 'Options';

  @override
  String get grpEColour => 'Colour';

  @override
  String get grpELabel => 'Label';

  @override
  String get grpERemoveOption => 'Remove option';

  @override
  String get grpEAddOption => 'Add option';

  @override
  String get grpERequired => 'Required';

  @override
  String get grpERequiredSub => 'New tasks must have a value.';

  @override
  String get grpEDefaultValue => 'Default value';

  @override
  String get grpEShowIn => 'Show in';

  @override
  String get grpESave => 'Save';

  @override
  String get grpEAddField => 'Add field';

  @override
  String get grpEOptionN => 'Option 1';

  @override
  String get grpEProblemName => 'Give the field a name.';

  @override
  String get grpEProblemOne => 'Add at least one option.';

  @override
  String get grpEProblemLabel => 'Every option needs a label.';

  @override
  String get grpEProblemDup => 'Two options have the same label.';

  @override
  String get grpEOptionsInUse => 'Options are in use';

  @override
  String get grpERemovedOption => 'Removed option';

  @override
  String grpERemapLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values',
      one: '1 value',
    );
    return '$label ($_temp0) becomes';
  }

  @override
  String get grpENothingClear => 'Nothing (clear)';

  @override
  String get grpEApply => 'Apply';

  @override
  String get grpEPrivate => 'Private';

  @override
  String get grpESprints => 'Sprints';

  @override
  String get grpEAutomations => 'Automations';

  @override
  String get grpESearch => 'Search';

  @override
  String get grpETimesheet => 'Timesheet';

  @override
  String get grpEDashboards => 'Dashboards';

  @override
  String get grpEDocs => 'Docs';

  @override
  String get grpEProjects => 'Projects';

  @override
  String get grpENewProject => 'New project';

  @override
  String get grpEFavorites => 'Favorites';

  @override
  String get grpEProjectsLoadRetry => 'Could not load projects. Retry';

  @override
  String get grpEArchivedProjects => 'Archived projects';

  @override
  String get grpEPrivateProjects => 'Private projects';

  @override
  String get grpENoProjects => 'No projects yet';

  @override
  String get grpECreateFirstProject => 'Create your first project';

  @override
  String get grpEMonth1 => 'January';

  @override
  String get grpEMonth2 => 'February';

  @override
  String get grpEMonth3 => 'March';

  @override
  String get grpEMonth4 => 'April';

  @override
  String get grpEMonth5 => 'May';

  @override
  String get grpEMonth6 => 'June';

  @override
  String get grpEMonth7 => 'July';

  @override
  String get grpEMonth8 => 'August';

  @override
  String get grpEMonth9 => 'September';

  @override
  String get grpEMonth10 => 'October';

  @override
  String get grpEMonth11 => 'November';

  @override
  String get grpEMonth12 => 'December';

  @override
  String get grpEWeekLocale => 'Locale default';

  @override
  String get grpEMonday => 'Monday';

  @override
  String get grpESaturday => 'Saturday';

  @override
  String get grpESunday => 'Sunday';

  @override
  String get grpEPrevious => 'Previous';

  @override
  String get grpENext => 'Next';

  @override
  String get grpEToday => 'Today';

  @override
  String get grpEUnscheduled => 'Unscheduled';

  @override
  String get grpEMonth => 'Month';

  @override
  String get grpEWeek => 'Week';

  @override
  String get grpEDay => 'Day';

  @override
  String get grpEColourBy => 'Colour by';

  @override
  String get grpEColourByProject => 'Colour by project';

  @override
  String get grpEColourByStatus => 'Colour by status';

  @override
  String get grpEColourByPriority => 'Colour by priority';

  @override
  String get grpEColourChip => 'Colour';

  @override
  String get grpEWeekStartsOn => 'Week starts on';

  @override
  String get grpEHideDone => 'Hide done';

  @override
  String get grpELayoutNotSaved =>
      'Your calendar layout could not be saved. It will be tried again on your next change.';

  @override
  String get grpEEnterName => 'Enter a name.';

  @override
  String get grpENewRole => 'New role';

  @override
  String get grpECreate => 'Create';

  @override
  String get grpERenameRole => 'Rename role';

  @override
  String get grpERename => 'Rename';

  @override
  String grpEDeleteRoleTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get grpERoleNoOne => 'No one has this role.';

  @override
  String grpERoleMoveMembers(int count) {
    return '$count member(s) have this role. Move them to:';
  }

  @override
  String get grpEChooseRole => 'Choose a role';

  @override
  String get grpEDelete => 'Delete';

  @override
  String grpFBulkDeleted(int count) {
    return '$count tasks deleted';
  }

  @override
  String grpFBulkUpdated(int count) {
    return '$count tasks updated';
  }

  @override
  String grpFBulkPartialDeleted(int done, int total, int failed) {
    return '$done of $total tasks deleted; $failed could not be.';
  }

  @override
  String grpFBulkPartialUpdated(int done, int total, int failed) {
    return '$done of $total tasks updated; $failed could not be.';
  }

  @override
  String get grpFDetails => 'Details';

  @override
  String grpFBulkDeleteTitle(int count) {
    return 'Delete $count tasks?';
  }

  @override
  String get grpFBulkDeleteBody =>
      'Their subtasks go with them. You can restore them from the trash.';

  @override
  String get grpFDelete => 'Delete';

  @override
  String get grpFSetStatus => 'Set status';

  @override
  String get grpFSetPriority => 'Set priority';

  @override
  String get grpFStatus => 'Status';

  @override
  String get grpFPriority => 'Priority';

  @override
  String get grpFAssign => 'Assign';

  @override
  String get grpFClear => 'Clear';

  @override
  String grpFBulkUpdating(int done, int total) {
    return 'Updating $done of $total…';
  }

  @override
  String grpFBulkSelected(int count) {
    return '$count selected';
  }

  @override
  String grpFBulkNotChanged(int count) {
    return '$count tasks not changed';
  }

  @override
  String get grpFTask => 'Task';

  @override
  String get grpFLinks => 'Links';

  @override
  String get grpFAddLink => 'Add a link';

  @override
  String get grpFNoLinks => 'No links yet.';

  @override
  String get grpFRemoveLink => 'Remove link';

  @override
  String get grpFLinkSearchHint => 'Search tasks in any project';

  @override
  String get grpFCloseDuplicate => 'Close the duplicate';

  @override
  String get grpFLinkAction => 'Link';

  @override
  String get grpFUnassigned => 'Unassigned';

  @override
  String get grpFNoValue => 'No value';

  @override
  String get grpFAssignee => 'Assignee';

  @override
  String grpFPresenceEditing(String name) {
    return '$name is editing';
  }

  @override
  String grpFPresenceViewing(String name) {
    return '$name is viewing';
  }

  @override
  String grpFEditingOne(String name) {
    return '$name is editing this';
  }

  @override
  String grpFEditingMany(int count) {
    return '$count people are editing this';
  }

  @override
  String grpFDeleteTaskTitle(String id) {
    return 'Delete $id?';
  }

  @override
  String grpFDeleteSubtasksExplain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It has $count subtasks. What should happen to them?',
      one: 'It has 1 subtask. What should happen to it?',
    );
    return '$_temp0';
  }

  @override
  String get grpFKeepSubtasks => 'Keep them (move up a level)';

  @override
  String get grpFDeleteThemToo => 'Delete them too';

  @override
  String grpFOpenSubtasksTitle(String id) {
    return '$id has open subtasks';
  }

  @override
  String grpFOpenSubtasksExplain(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtasks are not finished. Move them to $status too?',
      one: '1 subtask is not finished. Move it to $status too?',
    );
    return '$_temp0';
  }

  @override
  String get grpFLeaveOpen => 'Leave them open';

  @override
  String get grpFCompleteAll => 'Complete all';

  @override
  String grpFMoveUnderTitle(String id) {
    return 'Move $id under…';
  }

  @override
  String get grpFTopLevel => 'Top level (no parent)';

  @override
  String get grpFNoOtherParent => 'There is no other task to put it under.';

  @override
  String get grpFSubtasks => 'Subtasks';

  @override
  String get grpFAddSubtaskHint => 'Add a subtask and press Enter';

  @override
  String get grpFActionAddSubtask => 'Add subtask';

  @override
  String get grpFActionMoveUnder => 'Move under…';

  @override
  String get grpFActionMakeTopLevel => 'Make top level';

  @override
  String get grpFBlockedByPending => 'Blocked by tasks that are not done yet';

  @override
  String grpFBlockedBy(String names) {
    return 'Blocked by $names';
  }

  @override
  String get grpFBlocked => 'Blocked';

  @override
  String get grpFBlockedTitle => 'This task is blocked';

  @override
  String grpFBlockedTextOne(String blockers) {
    return 'It is blocked by $blockers, which is not done yet.';
  }

  @override
  String grpFBlockedTextMany(String blockers) {
    return 'It is blocked by $blockers, which are not done yet.';
  }

  @override
  String get grpFOk => 'OK';

  @override
  String get grpFCompleteAnyway => 'Complete anyway';

  @override
  String grpFConflictTitle(String field) {
    return 'Someone changed the $field';
  }

  @override
  String get grpFTheirs => 'Theirs';

  @override
  String get grpFYours => 'Yours';

  @override
  String get grpFEmpty => '(empty)';

  @override
  String get grpFTakeTheirs => 'Take theirs';

  @override
  String get grpFKeepMine => 'Keep mine';

  @override
  String get grpFFieldTitle => 'title';

  @override
  String get grpFFieldDescription => 'description';

  @override
  String get grpFFieldStatus => 'status';

  @override
  String get grpFFieldPriority => 'priority';

  @override
  String get grpFFieldStartDate => 'start date';

  @override
  String get grpFFieldDueDate => 'due date';

  @override
  String get grpFFieldAssignees => 'assignees';

  @override
  String get grpFFields => 'Fields';

  @override
  String get grpFRequiredFieldsIntro =>
      'These fields need a value before the task is created.';

  @override
  String get grpFRequired => 'Required';

  @override
  String get grpFCreate => 'Create';

  @override
  String get grpFChangeStatus => 'Change status';

  @override
  String get grpFChangePriority => 'Change priority';

  @override
  String get grpFDate => 'Date';

  @override
  String get grpFPickDay => 'Pick a day…';

  @override
  String get grpFAssignees => 'Assignees';

  @override
  String get grpFViewList => 'List';

  @override
  String get grpFViewBoard => 'Board';

  @override
  String get grpFViewTimeline => 'Timeline';

  @override
  String grpFErrorRetry(String message) {
    return '$message Retry';
  }

  @override
  String get grpFNoTasksYet => 'No tasks yet. Add the first one above.';

  @override
  String get grpFSwipeComplete => 'Complete';

  @override
  String get grpFUndo => 'Undo';

  @override
  String get grpFMore => 'More';

  @override
  String grpFAddSubtaskTo(String id) {
    return 'Add a subtask to $id';
  }

  @override
  String grpFTaskDeleted(String id) {
    return '$id deleted';
  }

  @override
  String get grpFColTitle => 'Title';

  @override
  String grpFTrashTitle(String name) {
    return '$name · Trash';
  }

  @override
  String get grpFTrashEmpty => 'The trash is empty.';

  @override
  String grpFTrashedRow(String id) {
    return '$id · deleted';
  }

  @override
  String get grpFRestore => 'Restore';

  @override
  String grpFTaskRestored(String id) {
    return '$id restored';
  }

  @override
  String get grpFMoveTo => 'Move to…';

  @override
  String grpFMoveToColumn(String name) {
    return 'Move to $name';
  }

  @override
  String grpFPlusCount(int count) {
    return '+$count';
  }

  @override
  String get grpFFoldColumn => 'Fold the column';

  @override
  String get grpFColumn => 'Column';

  @override
  String get grpFSetWipLimit => 'Set a work-in-progress limit…';

  @override
  String get grpFChangeLimit => 'Change the limit…';

  @override
  String get grpFAddTask => 'Add a task';

  @override
  String get grpFWipTitle => 'Work-in-progress limit';

  @override
  String get grpFWipMost => 'Most cards this column should hold';

  @override
  String get grpFColumnsBy => 'Columns by';

  @override
  String grpFColumnsChip(String name) {
    return 'Columns: $name';
  }

  @override
  String get grpFSwimlanes => 'Swimlanes';

  @override
  String get grpFLanesAssignee => 'Lanes: assignee';

  @override
  String get grpFNoSwimlanes => 'No swimlanes';

  @override
  String get grpFByAssignee => 'By assignee';

  @override
  String get grpFCardFields => 'Card fields';

  @override
  String get grpFCurrentSprint => 'Current sprint';

  @override
  String get grpFRefresh => 'Refresh';

  @override
  String get grpFBoardLayoutNotSaved =>
      'Your board layout could not be saved. It will be tried again on your next change.';

  @override
  String get grpFReschedule => 'Reschedule…';

  @override
  String get grpFSchedule => 'Schedule…';

  @override
  String get grpFRepeatsNotMade => 'Repeats: not made yet';

  @override
  String get grpFEverythingDated => 'Everything has a date.';

  @override
  String grpFNothingOn(String day) {
    return 'Nothing on $day.';
  }

  @override
  String get grpFKindTasks => 'Tasks';

  @override
  String get grpFKindComments => 'Comments';

  @override
  String get grpFKindProjects => 'Projects';

  @override
  String get grpFKindPeople => 'People';

  @override
  String get grpFKindPages => 'Pages';

  @override
  String get grpFChipAssignedToMe => 'Assigned to me';

  @override
  String get grpFChipOpen => 'Open';

  @override
  String get grpFChipDone => 'Done';

  @override
  String get grpFSearchErrGeneric => 'Something went wrong. Try again.';

  @override
  String get grpFSearchErrNetwork =>
      'Could not reach the server. Check your connection.';

  @override
  String get grpFSearchErrDenied => 'You do not have access to search here.';

  @override
  String get grpFSearchErrRate => 'Too many searches. Wait a moment.';

  @override
  String get grpFSearchErrInvalid => 'That search is not valid.';

  @override
  String get grpFSearchHint => 'Search tasks, comments, projects, people';

  @override
  String get grpFSearchClose => 'Close search';

  @override
  String get grpFSearchNothing =>
      'Nothing found. Try fewer words, or an id like WEB-12. Narrow with in:KEY, assignee:me, status:open.';

  @override
  String get grpFSearchTips =>
      'Type to search. Try an id like WEB-12, or operators: in:KEY, assignee:me, status:open.';

  @override
  String get grpFGoTo => 'Go to';

  @override
  String grpFShowMore(String kind) {
    return 'Show more $kind';
  }

  @override
  String get grpFRecent => 'Recent';

  @override
  String grpFPlusMore(int count) {
    return '+$count more';
  }

  @override
  String get grpFSubtaskDepthLimit =>
      'Subtasks are nested as deep as the app allows here.';

  @override
  String get grpFUnscheduled => 'Unscheduled';

  @override
  String get grpGCloseShortcuts => 'Close the keyboard shortcuts';

  @override
  String get grpGKeyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get grpGClose => 'Close';

  @override
  String get grpGChangedByYou => 'Changed by you';

  @override
  String get grpGNone => 'none';

  @override
  String grpGChangeKeysFor(String title) {
    return 'Change the keys for $title';
  }

  @override
  String grpGKeysFor(String title) {
    return 'Keys for $title';
  }

  @override
  String get grpGPressKeys => 'Press the keys you want.';

  @override
  String get grpGUseDefault => 'Use default';

  @override
  String get grpGNoKey => 'No key';

  @override
  String get grpGCancel => 'Cancel';

  @override
  String get grpGSave => 'Save';

  @override
  String grpGBrowserKeeps(String keys) {
    return 'The browser keeps $keys.';
  }

  @override
  String grpGAlreadyUsedBy(String title) {
    return 'Already used by \"$title\".';
  }

  @override
  String get grpGKeysTaken => 'Another action already uses those keys.';

  @override
  String get grpGKeysInvalid => 'Those keys cannot be used.';

  @override
  String get grpGSaveFailed => 'Could not save. Check your connection.';

  @override
  String grpGDefaultUsedBy(String title) {
    return 'The default keys are used by \"$title\".';
  }

  @override
  String get grpGDefaultUsedByOther =>
      'The default keys are used by another action.';

  @override
  String get grpGPaletteHint =>
      'Type a command, or > actions  # projects  @ people';

  @override
  String get grpGNothingMatches => 'Nothing matches.';

  @override
  String get grpGSearchUnavailable => 'Search is not available right now.';

  @override
  String get grpGName => 'Name';

  @override
  String get grpGCreate => 'Create';

  @override
  String get grpGQuickActions => 'Quick actions';

  @override
  String grpGDryRunTitle(String name) {
    return 'Dry run: $name';
  }

  @override
  String get grpGDryRunIntro =>
      'Shows what would happen on a task. Nothing is changed, sent or notified.';

  @override
  String get grpGTask => 'Task';

  @override
  String get grpGTasksLoadFailed => 'Could not load the tasks.';

  @override
  String get grpGWouldRun => 'It would run.';

  @override
  String get grpGWouldNotRun => 'It would not run on this task.';

  @override
  String get grpGRun => 'Run';

  @override
  String get grpGConditionProblem =>
      'The condition has a problem: see under the If card.';

  @override
  String get grpGRuleGone => 'That rule no longer exists.';

  @override
  String get grpGRule => 'Rule';

  @override
  String get grpGNewAutomation => 'New automation';

  @override
  String get grpGEditAutomation => 'Edit automation';

  @override
  String get grpGWhen => 'When';

  @override
  String get grpGIfOptional => 'If (optional)';

  @override
  String get grpGThen => 'Then';

  @override
  String get grpGAndThen => 'And then';

  @override
  String grpGActionLimit(int max) {
    return 'Limit of $max actions reached';
  }

  @override
  String get grpGAddAction => 'Add action';

  @override
  String get grpGLoadLatest => 'Load the latest version';

  @override
  String get grpGMoveUp => 'Move up';

  @override
  String get grpGMoveDown => 'Move down';

  @override
  String get grpGRemoveAction => 'Remove action';

  @override
  String grpGSwitchedOff(String reason) {
    return 'Switched off: $reason\nFix it: open the rule, pick something that still exists in the trigger or actions, save, then switch it on again.';
  }

  @override
  String get grpGUnknown => 'Unknown';

  @override
  String get grpGEmptyValue => '(empty)';

  @override
  String get grpGNothingRunYet => 'Nothing has run yet.';

  @override
  String get grpGLoadMore => 'Load more';

  @override
  String get grpGRetry => 'Retry';

  @override
  String grpGWhyNotRun(String explanation) {
    return 'Why didn\'t this run? $explanation';
  }

  @override
  String grpGChainDepth(int depth) {
    return 'Chain depth $depth';
  }

  @override
  String get grpGFilter => 'Filter';

  @override
  String grpGFilterCount(int count) {
    return 'Filter ($count)';
  }

  @override
  String get grpGSavedFilters => 'Saved filters';

  @override
  String get grpGNoSavedFilters => 'No saved filters yet';

  @override
  String grpGFieldGoneNamed(String name) {
    return '$name (a field is gone)';
  }

  @override
  String get grpGManageSaved => 'Manage saved filters…';

  @override
  String grpGConditionCount(int count) {
    return '$count condition(s)';
  }

  @override
  String get grpGClearFilterTip => 'Clear the filter';

  @override
  String get grpGNothingSaved => 'Nothing saved yet.';

  @override
  String get grpGFieldItUsedGone => 'A field it used is gone';

  @override
  String get grpGDelete => 'Delete';

  @override
  String get grpGFinishConditions => 'Finish the conditions first.';

  @override
  String get grpGEveryoneWorkspace => 'Everyone in the workspace';

  @override
  String get grpGEveryoneProject => 'Everyone in this project';

  @override
  String get grpGBuilder => 'Builder';

  @override
  String get grpGAdvanced => 'Advanced';

  @override
  String get grpGClearFilter => 'Clear filter';

  @override
  String get grpGSaveAs => 'Save as…';

  @override
  String get grpGApply => 'Apply';

  @override
  String get grpGSaveThisFilter => 'Save this filter';

  @override
  String get grpGOnlyMe => 'Only me';

  @override
  String get grpGExportSaveFailed => 'The file could not be saved. Try again.';

  @override
  String get grpGExport => 'Export';

  @override
  String get grpGEveryProject => 'Every project I can open';

  @override
  String get grpGOneProject => 'One project';

  @override
  String get grpGExportInfo =>
      'A zip with tasks.json (which TaskForge can import again), tasks.csv, comments, an attachments manifest and a README.';

  @override
  String grpGExportSavedSized(String name, String size) {
    return 'Saved $name ($size).';
  }

  @override
  String grpGExportSaved(String name) {
    return 'Saved $name.';
  }

  @override
  String grpGNotesAboutFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes about this file',
      one: '1 note about this file',
    );
    return '$_temp0';
  }

  @override
  String grpGRowNumber(int line) {
    return 'Row $line';
  }

  @override
  String grpGAndMore(int count) {
    return '...and $count more.';
  }

  @override
  String get grpGNotesReadFailed =>
      'Could not read the notes about this import.';

  @override
  String get grpGDragToOtherList => 'Drag to the other list';

  @override
  String get grpGAddedAfterStart => 'added after start';

  @override
  String get grpGStoryPoints => 'Story points';

  @override
  String get grpGUnitHours => 'h';

  @override
  String get grpGUnitPoints => ' pts';

  @override
  String grpGLoadOf(String load, String unit, String cap) {
    return 'Load $load$unit of $cap$unit';
  }

  @override
  String grpGLoadNoCapacity(String load, String unit) {
    return 'Load $load$unit (no capacity set)';
  }

  @override
  String get grpGSetCapacity => 'Set capacity';

  @override
  String get grpGPoints => 'Points';

  @override
  String get grpGHours => 'Hours';

  @override
  String grpGOverCapacity(String amount, String unit) {
    return 'Over capacity by $amount$unit';
  }

  @override
  String grpGTitleWithCount(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get grpHCancel => 'Cancel';

  @override
  String get grpHArchive => 'Archive';

  @override
  String get grpHRestore => 'Restore';

  @override
  String get grpHRetry => 'Retry';

  @override
  String get grpHCreate => 'Create';

  @override
  String get grpHName => 'Name';

  @override
  String get grpHDescription => 'Description';

  @override
  String grpHArchiveTitle(String name) {
    return 'Archive \"$name\"?';
  }

  @override
  String get grpHArchiveBody =>
      'It becomes read-only and disappears from the sidebar. You can restore it at any time.';

  @override
  String get grpHDangerZone => 'Danger zone';

  @override
  String get grpHRestoreProject => 'Restore project';

  @override
  String get grpHArchiveProject => 'Archive project';

  @override
  String get grpHArchivedBanner => 'This project is archived and read-only.';

  @override
  String get grpHArchivedProjects => 'Archived projects';

  @override
  String get grpHNoArchived => 'No archived projects.';

  @override
  String get grpHLoadProjectsRetry => 'Could not load projects. Retry';

  @override
  String get grpHNewProject => 'New project';

  @override
  String get grpHKey => 'Key';

  @override
  String get grpHKeyHelp => 'Prefix of task numbers, e.g. WEB-12';

  @override
  String get grpHFeatures => 'Features';

  @override
  String get grpHFeaturesHint =>
      'Switching a feature off hides it but keeps its data.';

  @override
  String get grpHProjectUpdated => 'Project updated.';

  @override
  String get grpHGeneral => 'General';

  @override
  String grpHKeyFixed(String taskKey) {
    return 'The key is fixed because tasks already use it ($taskKey).';
  }

  @override
  String get grpHSaveChanges => 'Save changes';

  @override
  String get grpHAddAMember => 'Add a member';

  @override
  String get grpHAllAreMembers =>
      'Everyone in the workspace is already a member.';

  @override
  String get grpHMembers => 'Members';

  @override
  String get grpHAddMember => 'Add member';

  @override
  String get grpHRemove => 'Remove';

  @override
  String get grpHLoadMembersRetry => 'Could not load members. Retry';

  @override
  String get grpHPrivateProjects => 'Private projects';

  @override
  String get grpHNoPrivate => 'No private projects.';

  @override
  String grpHKeyAndMembers(String key, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$key · $_temp0';
  }

  @override
  String get grpHAddMe => 'Add me';

  @override
  String grpHColorLabel(String color) {
    return 'Color $color';
  }

  @override
  String get grpHVisOpen => 'Open';

  @override
  String get grpHVisPrivate => 'Private';

  @override
  String get grpHVisOpenHint => 'Everyone in the workspace can see it.';

  @override
  String get grpHVisPrivateHint => 'Only invited members can see it.';

  @override
  String get grpHProject => 'Project';

  @override
  String get grpHRemoveFavorite => 'Remove favorite';

  @override
  String get grpHAddFavorite => 'Add favorite';

  @override
  String get grpHTrash => 'Trash';

  @override
  String get grpHProjectSettings => 'Project settings';

  @override
  String get grpHLoadProjectRetry => 'Could not load the project. Retry';

  @override
  String get grpHProjectNotFound => 'Project not found.';

  @override
  String get grpHBack => 'Back';

  @override
  String get grpHWorkflow => 'Workflow';

  @override
  String get grpHWorkflowHint =>
      'Statuses, their categories and which moves are allowed.';

  @override
  String get grpHFields => 'Fields';

  @override
  String get grpHFieldsHint =>
      'Custom fields such as Customer, Story points or Environment.';

  @override
  String get grpHAdd => 'Add';

  @override
  String get grpHAttachFile => 'Attach a file';

  @override
  String get grpHTakePhoto => 'Take a photo';

  @override
  String get grpHChooseGallery => 'Choose from gallery';

  @override
  String get grpHPasteImage => 'Paste an image';

  @override
  String get grpHDeleteFileQ => 'Delete this file?';

  @override
  String grpHFileWillBeRemoved(String filename) {
    return '$filename will be removed.';
  }

  @override
  String get grpHDelete => 'Delete';

  @override
  String grpHOpenFile(String filename) {
    return 'Open $filename';
  }

  @override
  String grpHDeleteFile(String filename) {
    return 'Delete $filename';
  }

  @override
  String get grpHWaitingConnection => 'Waiting for a connection…';

  @override
  String get grpHWaiting => 'Waiting…';

  @override
  String get grpHUploadDone => 'Done';

  @override
  String get grpHUploadCancelled => 'Cancelled';

  @override
  String grpHPercentUploaded(String filename, int percent) {
    return '$filename, $percent percent uploaded';
  }

  @override
  String get grpHWaitingToBeSent => 'Waiting to be sent';

  @override
  String grpHCancelFile(String filename) {
    return 'Cancel $filename';
  }

  @override
  String grpHTryFileAgain(String filename) {
    return 'Try $filename again';
  }

  @override
  String grpHDismissFile(String filename) {
    return 'Dismiss $filename';
  }

  @override
  String get grpHOpen => 'Open';

  @override
  String get grpHDownload => 'Download';

  @override
  String get grpHClose => 'Close';

  @override
  String get grpHCouldNotOpenFile => 'Could not open the file.';

  @override
  String get grpHCouldNotLoadPicture => 'Could not load the picture.';

  @override
  String get grpHCouldNotReadFileViewer => 'Could not read the file.';

  @override
  String get grpHCouldNotPlayVideo => 'Could not play the video.';

  @override
  String get grpHPause => 'Pause';

  @override
  String get grpHPlay => 'Play';

  @override
  String grpHTextTruncated(String size) {
    return 'Showing the first $size. Download the file to read the rest.';
  }

  @override
  String get grpHAttachments => 'Attachments';

  @override
  String grpHAttachmentsCount(int count) {
    return 'Attachments ($count)';
  }

  @override
  String get grpHCouldNotReadFile => 'Could not read that file.';

  @override
  String get grpHDismiss => 'Dismiss';

  @override
  String get grpHNoAttachments => 'No attachments.';

  @override
  String get grpHDropZoneLabel =>
      'Attach files: drop them here or click, then paste an image';

  @override
  String get grpHDropToAttach => 'Drop to attach';

  @override
  String get grpHDropFilesHere => 'Drop files here to attach them';

  @override
  String get grpHSnoozeLaterToday => 'Later today';

  @override
  String get grpHSnoozeTomorrow => 'Tomorrow';

  @override
  String get grpHSnoozeNextWeek => 'Next week';

  @override
  String get grpHMarkAllRead => 'Mark all read';

  @override
  String get grpHNotificationSettings => 'Notification settings';

  @override
  String get grpHInbox => 'Inbox';

  @override
  String grpHUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get grpHLoadMore => 'Load more';

  @override
  String get grpHEmptyAll => 'Nothing here. You are all caught up.';

  @override
  String get grpHEmptyUnread => 'No unread notifications.';

  @override
  String get grpHEmptyMentions => 'Nobody has mentioned you.';

  @override
  String get grpHEmptyAssigned => 'Nothing assigned to you lately.';

  @override
  String get grpHEmptySnoozed => 'Nothing is snoozed.';

  @override
  String get grpHEmptyArchived => 'Nothing is archived.';

  @override
  String grpHDueDate(String date) {
    return 'Due $date';
  }

  @override
  String grpHUnreadPrefix(String title) {
    return 'Unread. $title';
  }

  @override
  String grpHMoreCount(int count) {
    return '+$count more';
  }

  @override
  String get grpHMore => 'More';

  @override
  String get grpHMarkUnread => 'Mark unread';

  @override
  String get grpHMarkRead => 'Mark read';

  @override
  String get grpHStopSnoozing => 'Stop snoozing';

  @override
  String get grpHSnoozeEllipsis => 'Snooze…';

  @override
  String get grpHMoveToInbox => 'Move to inbox';

  @override
  String get grpHPushTitle => 'Get a ping when it matters';

  @override
  String get grpHPushBody =>
      'TaskForge can show a notification when you are assigned a task, mentioned, or a task is due soon, even when the app is in the background. Next your device will ask for permission. You choose which kinds ping you, and quiet hours keep them from waking you.';

  @override
  String get grpHNotNow => 'Not now';

  @override
  String get grpHContinue => 'Continue';

  @override
  String get grpHPickDateTime => 'Pick date and time';

  @override
  String get grpHRepeatReadError => 'Could not read how this repeats.';

  @override
  String get grpHRepeat => 'Repeat';

  @override
  String get grpHFirstOfSeries => 'First of a series';

  @override
  String get grpHRepeatingTask => 'Repeating task';

  @override
  String grpHSeriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks in this series',
      one: '$count task in this series',
    );
    return '$_temp0';
  }

  @override
  String get grpHRepeatPaused => 'Paused: no new tasks are made.';

  @override
  String grpHRepeatPausedBySystem(String reason) {
    return 'Paused by the system: $reason';
  }

  @override
  String grpHRepeatNext(String dates) {
    return 'Next: $dates';
  }

  @override
  String get grpHRepeatWaits => 'The next one is made when this is completed.';

  @override
  String get grpHRepeatsTitle => 'This task repeats';

  @override
  String grpHRepeatsBody(String summary) {
    return 'It is the template of \"$summary\". Deleting it can stop the series, or the series can keep making new tasks.';
  }

  @override
  String get grpHDeleteKeepRepeating => 'Delete, keep repeating';

  @override
  String get grpHDeleteAndStop => 'Delete and stop';

  @override
  String get grpHChartGroup => 'Group';

  @override
  String get grpHOfflineReview => 'Review';

  @override
  String get grpHOfflineSyncing => 'Syncing…';

  @override
  String get grpHOfflineSyncNow => 'Sync now';

  @override
  String get grpHOfflineSaved =>
      'You are offline. Changes are saved on this device.';

  @override
  String grpHOfflineWaitsOnline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes wait to be sent.',
      one: '$count change waits to be sent.',
    );
    return '$_temp0';
  }

  @override
  String grpHOfflineWaitsOffline(int count) {
    return '$count waiting to be sent.';
  }

  @override
  String grpHOfflineAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes need your attention.',
      one: '$count change needs your attention.',
    );
    return '$_temp0';
  }

  @override
  String get grpHReconnecting =>
      'Reconnecting… what you see will catch up once you are back.';

  @override
  String get grpICancel => 'Cancel';

  @override
  String get grpIDone => 'Done';

  @override
  String get grpIRetry => 'Retry';

  @override
  String get grpIClose => 'Close';

  @override
  String get grpIBack => 'Back';

  @override
  String get grpIEdit => 'Edit';

  @override
  String get grpISave => 'Save';

  @override
  String get grpISaving => 'Saving…';

  @override
  String get grpIDelete => 'Delete';

  @override
  String get grpICopy => 'Copy';

  @override
  String get grpIUndo => 'Undo';

  @override
  String get grpIRestore => 'Restore';

  @override
  String get grpIUnnamed => '(unnamed)';

  @override
  String grpIErrorRetry(String message) {
    return '$message Retry';
  }

  @override
  String get grpIMergeTitle => 'Someone else saved the workflow first';

  @override
  String get grpIMergeBody =>
      'Your edits are kept, and their work was not overwritten. This is what changed in your draft:';

  @override
  String get grpIMergeKeep => 'I have read this, keep my draft';

  @override
  String get grpIMergeReload => 'Throw my draft away';

  @override
  String get grpINoProblems => 'No problems';

  @override
  String get grpIEveryTaskValid => 'Every task keeps a valid status.';

  @override
  String grpIProblemsToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems to fix before saving',
      one: '1 problem to fix before saving',
    );
    return '$_temp0';
  }

  @override
  String get grpIAnyStatusMoves => 'Any status can move to any other.';

  @override
  String grpIWorkflowGraphLabel(int statuses, int moves) {
    return 'Workflow with $statuses statuses and $moves allowed moves';
  }

  @override
  String get grpINeedsAssignee => 'needs an assignee';

  @override
  String get grpINeedsSubtasksDone => 'needs all subtasks done';

  @override
  String grpIOnlyRoleLower(String role) {
    return 'only $role';
  }

  @override
  String get grpIOneRole => 'one role';

  @override
  String get grpIDragToReorder => 'Drag to reorder';

  @override
  String get grpIColour => 'Colour';

  @override
  String get grpINewTasksStartHere => 'New tasks start here';

  @override
  String get grpIMakeDefaultStatus => 'Make this the status new tasks start in';

  @override
  String get grpIDeleteStatus => 'Delete status';

  @override
  String grpITaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get grpICanMoveTo => 'Can move to';

  @override
  String get grpIConditionsForMove => 'Conditions for this move';

  @override
  String get grpIName => 'Name';

  @override
  String grpIDeleteStatusTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String grpITasksInStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks are in this status. Choose where they go.',
      one: '1 task is in this status. Choose where it goes.',
    );
    return '$_temp0';
  }

  @override
  String get grpIMoveTasksTo => 'Move tasks to';

  @override
  String get grpIMoveTasksAndDelete => 'Move tasks and delete';

  @override
  String get grpIWhoMayMove => 'Who may make this move';

  @override
  String get grpIAnyRole => 'Any role';

  @override
  String grpIOnlyRole(String name) {
    return 'Only $name';
  }

  @override
  String get grpITaskNeedsAssignee => 'The task needs an assignee';

  @override
  String get grpIAllSubtasksDone => 'All subtasks must be done';

  @override
  String get grpIDoneOrCancelledDepth => 'Done or cancelled, at any depth.';

  @override
  String get grpIWorkflow => 'Workflow';

  @override
  String get grpIDiscard => 'Discard';

  @override
  String get grpIWorkflowSaved => 'Workflow saved';

  @override
  String get grpIRestrictTransitions => 'Restrict transitions';

  @override
  String get grpIRestrictTransitionsHint =>
      'Off: any status can move to any other. On: only the arrows you allow.';

  @override
  String get grpIRestrictCreation =>
      'New tasks start in the default status only';

  @override
  String get grpIRestrictCreationHint =>
      'Off: a task can be created in any status. On: it starts in the status marked with the star and reaches the others by being moved.';

  @override
  String get grpIAddStatus => 'Add status';

  @override
  String get grpINewStatus => 'New status';

  @override
  String get grpIMigrationNeedsPlace =>
      'Tasks you chose to move here need a new place.';

  @override
  String grpIMoveArrow(String from, String to) {
    return '$from → $to';
  }

  @override
  String grpIDeletedStillHasTasks(String name) {
    return '$name was deleted but still has tasks.';
  }

  @override
  String get grpIMoveItsTasksTo => 'Move its tasks to';

  @override
  String grpIDrillTitle(String title, int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks',
      one: 'task',
    );
    return '$title · $count$more $_temp0';
  }

  @override
  String get grpINoTasks => 'No tasks.';

  @override
  String get grpIDrillTruncated =>
      'Only the first tasks are listed; narrow the filter to see the rest.';

  @override
  String grpIDueOn(String date) {
    return 'due $date';
  }

  @override
  String get grpINothingToShow => 'Nothing to show yet.';

  @override
  String get grpIRefresh => 'Refresh';

  @override
  String get grpIWidgetMenu => 'Widget menu';

  @override
  String get grpIExportCsv => 'Export CSV';

  @override
  String get grpIRemove => 'Remove';

  @override
  String get grpISaveToSeeNumbers => 'Save to see numbers.';

  @override
  String grpICsvTitle(String title) {
    return '$title (CSV)';
  }

  @override
  String get grpICsvCopied => 'CSV copied.';

  @override
  String get grpISaveAsFile => 'Save as file';

  @override
  String grpILatestPoints(int limit) {
    return 'Showing the latest $limit points; shorten the range to see them all.';
  }

  @override
  String grpITopLimit(int limit) {
    return 'Showing the top $limit; narrow the filter to see the rest.';
  }

  @override
  String get grpIWidget => 'Widget';

  @override
  String get grpITitle => 'Title';

  @override
  String get grpIGroupBy => 'Group by';

  @override
  String get grpIFilterTfqlOptional => 'Filter (TFQL, optional)';

  @override
  String get grpIPreview => 'Preview';

  @override
  String get grpIProject => 'Project';

  @override
  String get grpISprint => 'Sprint';

  @override
  String grpIDateRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String grpIFromDate(String date) {
    return 'from $date';
  }

  @override
  String get grpINoDates => 'no dates';

  @override
  String grpIDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get grpINothingScheduled => 'Nothing is scheduled in this range.';

  @override
  String get grpIOnCriticalPath => 'on the critical path';

  @override
  String get grpIBlocked => 'blocked';

  @override
  String grpIMovingPushes(String id, int count) {
    return 'Moving $id pushes $count';
  }

  @override
  String grpIRangeShift(String from, String to) {
    return '$from  →  $to';
  }

  @override
  String get grpIKeepThem => 'Keep them (show conflict)';

  @override
  String get grpIShiftDependents => 'Shift dependents';

  @override
  String get grpIWeekdayMon => 'Mon';

  @override
  String get grpIWeekdayTue => 'Tue';

  @override
  String get grpIWeekdayWed => 'Wed';

  @override
  String get grpIWeekdayThu => 'Thu';

  @override
  String get grpIWeekdayFri => 'Fri';

  @override
  String get grpIWeekdaySat => 'Sat';

  @override
  String get grpIWeekdaySun => 'Sun';

  @override
  String get grpIWorkingDays => 'Working days';

  @override
  String get grpIWorkingDaysHint =>
      'Moving a task past another skips the days off.';

  @override
  String get grpIHolidays => 'Holidays';

  @override
  String get grpIHolidaysHint => 'Dates like 2026-12-25, separated by commas';

  @override
  String grpITimelineChartLabel(int count) {
    return 'Timeline chart of $count tasks. Switch to the list view to read them.';
  }

  @override
  String get grpITimelineDragHint =>
      'Drag a bar to move it, an end to resize it. Ctrl + wheel or pinch zooms.';

  @override
  String get grpIUnscheduled => 'Unscheduled';

  @override
  String get grpIMovedLinksBreak => 'Moved. The links it breaks show in red.';

  @override
  String get grpITimelineSaved => 'Timeline saved.';

  @override
  String get grpIDay => 'Day';

  @override
  String get grpIWeek => 'Week';

  @override
  String get grpIMonth => 'Month';

  @override
  String get grpIQuarter => 'Quarter';

  @override
  String get grpITaskTree => 'Task tree';

  @override
  String get grpIByAssignee => 'By assignee';

  @override
  String get grpIByStatus => 'By status';

  @override
  String get grpIEarlier => 'Earlier';

  @override
  String get grpIToday => 'Today';

  @override
  String get grpILater => 'Later';

  @override
  String get grpICriticalPath => 'Critical path';

  @override
  String get grpIHideDone => 'Hide done';

  @override
  String get grpIShowChart => 'Show the chart';

  @override
  String get grpIShowList => 'Show as a list';

  @override
  String get grpIExportImage => 'Export as an image';

  @override
  String get grpICurrency => 'Currency';

  @override
  String get grpIClear => 'Clear';

  @override
  String get grpINone => 'None';

  @override
  String grpIFieldArchived(String name) {
    return 'Archived $name. Values are kept 30 days.';
  }

  @override
  String get grpIFields => 'Fields';

  @override
  String get grpIAddField => 'Add field';

  @override
  String get grpINoCustomFields =>
      'No custom fields yet. Add one for things like Customer or Story points.';

  @override
  String get grpIArchivedRestorable => 'Archived (restorable for 30 days)';

  @override
  String get grpIRequired => 'Required';

  @override
  String grpIOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options',
      one: '1 options',
    );
    return '$_temp0';
  }

  @override
  String get grpIArchive => 'Archive';

  @override
  String get grpIWriteComment => 'Write a comment… (@ to mention)';

  @override
  String get grpIComment => 'Comment';

  @override
  String get grpIBulletList => 'Bullet list';

  @override
  String get grpIQuote => 'Quote';

  @override
  String get grpICodeBlock => 'Code block';

  @override
  String get grpILink => 'Link';

  @override
  String get grpICouldNotReadFile => 'Could not read that file.';

  @override
  String get grpICtrlEnterToSend => 'Ctrl+Enter to send';

  @override
  String get grpIDeleteCommentTitle => 'Delete this comment?';

  @override
  String get grpIDeleteCommentBody =>
      'It will show as \"Comment removed\". Its content and edit history are deleted.';

  @override
  String get grpICannotSeeTask => 'They cannot see this task';

  @override
  String grpICannotSeeGrant(String names) {
    return '$names cannot see this task. Add them to the project and send the comment, or take the mention out.';
  }

  @override
  String grpICannotSeeRefuse(String names) {
    return '$names cannot see this task, so they cannot be mentioned. Take the mention out, or ask someone who manages the project to add them.';
  }

  @override
  String get grpIOk => 'OK';

  @override
  String get grpIAddThemAndSend => 'Add them and send';

  @override
  String grpIEditHistory(String author) {
    return 'Edit history · $author';
  }

  @override
  String grpIRevisionCurrent(String stamp) {
    return '$stamp · current';
  }

  @override
  String get grpISessions => 'Sessions';

  @override
  String get grpISignOutOthers => 'Sign out other devices';

  @override
  String get grpIUnknownDevice => 'Unknown device';

  @override
  String get grpIThisDevice => 'This device';

  @override
  String get grpISignOutThis => 'Sign out this device';

  @override
  String get grpJLink => 'Link';

  @override
  String get grpJInviteEmails => 'Email addresses';

  @override
  String grpJInviteEmailsHelp(int max) {
    return 'Separate several with commas. Up to $max.';
  }

  @override
  String get grpJAdd => 'Add';

  @override
  String grpJInviteInvalidEmail(String email) {
    return '\"$email\" is not a valid email address.';
  }

  @override
  String grpJInviteTooMany(int max) {
    return 'You can invite at most $max people at once.';
  }

  @override
  String get grpJInviteSendAll => 'Send invitations';

  @override
  String grpJInviteSendCount(int count) {
    return 'Send $count';
  }

  @override
  String grpJInvited(int count) {
    return 'Invited $count.';
  }

  @override
  String grpJInviteSkipped(String emails) {
    return 'Already members, skipped: $emails';
  }

  @override
  String get grpJExpiresAfter => 'Expires after';

  @override
  String grpJDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get grpJMaxUses => 'Max uses';

  @override
  String get grpJMaxUsesHelp => 'Leave empty for unlimited.';

  @override
  String grpJMaxUsesInvalid(int max) {
    return 'Enter a number from 1 to $max, or leave empty.';
  }

  @override
  String get grpJCreateLink => 'Create link';

  @override
  String get grpJCopyLink => 'Copy link';

  @override
  String get grpJRole => 'Role';

  @override
  String get grpJInvitationTitle => 'Invitation';

  @override
  String get grpJJoin => 'Join';

  @override
  String get grpJDecline => 'Decline';

  @override
  String get grpJGoToTaskForge => 'Go to TaskForge';

  @override
  String get grpJInvitedToJoin => 'You have been invited to join';

  @override
  String grpJInviterInvitedYou(String name) {
    return '$name invited you to join';
  }

  @override
  String get grpJBack => 'Back';

  @override
  String get grpJMembers => 'Members';

  @override
  String get grpJInvite => 'Invite';

  @override
  String get grpJPending => 'Pending';

  @override
  String grpJJoined(String date) {
    return 'Joined $date';
  }

  @override
  String get grpJRemoveFromWorkspace => 'Remove from workspace';

  @override
  String get grpJSearchMembers => 'Search members';

  @override
  String grpJRemoveMember(String name) {
    return 'Remove $name';
  }

  @override
  String get grpJOwnerCannotLeave =>
      'You own this workspace, so you cannot leave it. Ownership cannot be transferred yet.';

  @override
  String get grpJLeaveWorkspace => 'Leave workspace';

  @override
  String grpJRemoveMemberTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get grpJRemoveMemberBody =>
      'They lose access to this workspace. You can invite them again later.';

  @override
  String get grpJRemove => 'Remove';

  @override
  String grpJLeaveTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get grpJLeaveBody =>
      'You will lose access to this workspace until someone invites you again.';

  @override
  String get grpJLeave => 'Leave';

  @override
  String grpJErrorRetry(String error) {
    return '$error Retry';
  }

  @override
  String get grpJLinkCopied => 'Link copied.';

  @override
  String get grpJNoInvitations => 'No invitations yet.';

  @override
  String get grpJInvitationResent => 'Invitation resent.';

  @override
  String get grpJResend => 'Resend';

  @override
  String get grpJRevoke => 'Revoke';

  @override
  String get grpJStatePending => 'Pending';

  @override
  String get grpJStateExpired => 'Expired';

  @override
  String get grpJStateRevoked => 'Revoked';

  @override
  String get grpJStateUsedUp => 'Used up';

  @override
  String grpJUsesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uses',
      one: '$count use',
    );
    return '$_temp0';
  }

  @override
  String grpJUsesOfMax(int uses, int max) {
    return '$uses/$max uses';
  }

  @override
  String get grpJInviteLink => 'Invite link';

  @override
  String grpJInvitationMeta(String name, String date) {
    return 'by $name · expires $date';
  }

  @override
  String get grpJChangeRole => 'Change role';

  @override
  String get grpJBlockOptions => 'Block options';

  @override
  String get grpJMoveUp => 'Move up';

  @override
  String get grpJMoveDown => 'Move down';

  @override
  String get grpJAddBlockBelow => 'Add block below';

  @override
  String get grpJDelete => 'Delete';

  @override
  String grpJTurnInto(String label) {
    return 'Turn into $label';
  }

  @override
  String get grpJClickToWrite => 'Click here to start writing';

  @override
  String get grpJAddBlock => 'Add block';

  @override
  String get grpJDocs => 'Docs';

  @override
  String get grpJPickPage => 'Pick a page, or create one.';

  @override
  String get grpJNoMatchingBlocks => 'No matching blocks';

  @override
  String get grpJNoMatchingPages => 'No matching pages';

  @override
  String get grpJTableRow => 'Row';

  @override
  String get grpJTableColumn => 'Column';

  @override
  String get grpJNoImageAddress => 'No image address yet';

  @override
  String get grpJImageLoadFailed => 'Image could not load';

  @override
  String get grpJEditImage => 'Edit image';

  @override
  String get grpJLoadingTask => 'Loading task...';

  @override
  String get grpJNoAccessTask => 'No access to this task';

  @override
  String grpJUnknownBlock(String type) {
    return 'This block ($type) needs a newer version of TaskForge. It is kept as it is.';
  }

  @override
  String get grpJLinkAPage => 'Link a page';

  @override
  String get grpJNoPagesYetLong => 'There are no pages yet.';

  @override
  String get grpJRelatedDocs => 'Related docs';

  @override
  String get grpJNoPagesYet => 'No pages yet.';

  @override
  String get grpJLinked => 'Linked';

  @override
  String get grpJEmbedded => 'Embedded';

  @override
  String get grpJUnlink => 'Unlink';

  @override
  String grpJChangeTone(String tone) {
    return 'Change tone ($tone)';
  }

  @override
  String get grpJBold => 'Bold';

  @override
  String get grpJItalic => 'Italic';

  @override
  String get grpJStrikethrough => 'Strikethrough';

  @override
  String get grpJCode => 'Code';

  @override
  String get grpJHintParagraph =>
      'Type \'/\' for blocks, \'[[\' to mention a page';

  @override
  String grpJHintHeading(int level) {
    return 'Heading $level';
  }

  @override
  String get grpJCodeLanguageHint => 'language';

  @override
  String get grpJUndo => 'Undo';

  @override
  String get grpJRestore => 'Restore';

  @override
  String get grpJName => 'Name';

  @override
  String grpJWorkspaceDeleted(String name) {
    return '\"$name\" deleted. Restorable for 7 days.';
  }

  @override
  String get grpJDangerZone => 'Danger zone';

  @override
  String get grpJDangerZoneBody =>
      'Deleting a workspace hides it for everyone. You can restore it for 7 days.';

  @override
  String get grpJDeleteWorkspace => 'Delete workspace';

  @override
  String get grpJDeleteWorkspaceQ => 'Delete workspace?';

  @override
  String grpJTypeNameToConfirm(String name) {
    return 'Type \"$name\" to confirm';
  }

  @override
  String get grpJNewWorkspace => 'New workspace';

  @override
  String get grpJCreateYourWorkspace => 'Create your workspace';

  @override
  String get grpJWorkspaceHolds =>
      'A workspace holds your team\'s projects and tasks.';

  @override
  String get grpJUrl => 'URL';

  @override
  String get grpJCreateWorkspace => 'Create workspace';

  @override
  String get grpJRecentlyDeleted => 'Recently deleted';

  @override
  String get grpJSwitchWorkspace => 'Switch workspace';

  @override
  String get grpJTimerRunning => 'Timer running';

  @override
  String grpJTimerStoppedOn(String key, String title) {
    return 'Stopped the timer on $key $title';
  }

  @override
  String get grpJTime => 'Time';

  @override
  String get grpJStop => 'Stop';

  @override
  String get grpJStartTimer => 'Start timer';

  @override
  String get grpJAddTime => 'Add time';

  @override
  String grpJTimeOfEstimate(String logged, String estimate) {
    return '$logged of $estimate';
  }

  @override
  String grpJTimeLogged(String logged) {
    return '$logged logged';
  }

  @override
  String grpJTimeBillable(String duration) {
    return '$duration billable';
  }

  @override
  String get grpJChangeEstimate => 'Change estimate';

  @override
  String get grpJSetEstimate => 'Set estimate';

  @override
  String get grpJRunning => 'Running';

  @override
  String get grpJLoggedLabel => 'Logged';

  @override
  String get grpJYou => 'you';

  @override
  String get grpJBillableSuffix => 'billable';

  @override
  String get grpJOverlapsEntry => 'Overlaps another entry';

  @override
  String get grpJOver24h => 'Over 24 h: check it';

  @override
  String get grpJEdit => 'Edit';

  @override
  String get grpJStopTheTimer => 'Stop the timer';

  @override
  String get grpJRoleActions => 'Role actions';

  @override
  String get grpJRename => 'Rename';

  @override
  String get grpJBuiltInReadOnly => 'Built-in, read-only';

  @override
  String get grpJRolesAndPermissions => 'Roles and permissions';

  @override
  String get grpJNewRole => 'New role';

  @override
  String get grpJActivity => 'Activity';

  @override
  String get grpJNoActivity => 'No activity yet.';

  @override
  String get grpJDebugTitle => 'TaskForge — connectivity';

  @override
  String grpJPingLabel(String label) {
    return '$label ping';
  }

  @override
  String grpJPingError(String error) {
    return 'error: $error';
  }

  @override
  String get grpKClosePalette => 'Close the command palette';

  @override
  String get grpKGroupGeneral => 'General';

  @override
  String get grpKGroupGoTo => 'Go to';

  @override
  String get grpKGroupProjects => 'Projects';

  @override
  String get grpKGroupWorkspace => 'Workspace';

  @override
  String get grpKGroupAccount => 'Account';

  @override
  String get grpKGroupThisProject => 'This project';

  @override
  String get grpKGroupDocs => 'Docs';

  @override
  String get grpKGroupDashboards => 'Dashboards';

  @override
  String get grpKGroupListView => 'List view';

  @override
  String get grpKGroupThisTask => 'This task';

  @override
  String grpKGoTo(String title) {
    return 'Go to $title';
  }

  @override
  String grpKProjectPageOf(String title) {
    return '$title of this project';
  }

  @override
  String get grpKPaletteOpen => 'Open the command palette';

  @override
  String get grpKSearch => 'Search';

  @override
  String get grpKSearchSem => 'Search tasks, comments, projects and people';

  @override
  String get grpKShortcuts => 'Keyboard shortcuts';

  @override
  String get grpKShortcutsSem => 'Show the keyboard shortcuts';

  @override
  String get grpKTHome => 'Home';

  @override
  String get grpKTInbox => 'Inbox';

  @override
  String get grpKTCalendar => 'Workspace calendar';

  @override
  String get grpKTDocs => 'Docs';

  @override
  String get grpKTDashboards => 'Dashboards';

  @override
  String get grpKTTimesheet => 'Timesheet';

  @override
  String get grpKTMembers => 'Members';

  @override
  String get grpKTArchivedProjects => 'Archived projects';

  @override
  String get grpKTPrivateProjects => 'Private projects';

  @override
  String get grpKTWorkspaceSettings => 'Workspace settings';

  @override
  String get grpKAuditLog => 'Audit log';

  @override
  String get grpKAuditSem => 'Go to the audit log';

  @override
  String get grpKTRoles => 'Roles and permissions';

  @override
  String get grpKTCreateWorkspace => 'Create a workspace';

  @override
  String get grpKTNotifPrefs => 'Notification preferences';

  @override
  String get grpKTDevices => 'Signed-in devices';

  @override
  String get grpKTChangePassword => 'Change password';

  @override
  String get grpKTTasks => 'Tasks';

  @override
  String get grpKTSprints => 'Sprints';

  @override
  String get grpKTAutomations => 'Automations';

  @override
  String get grpKTWorkflow => 'Workflow';

  @override
  String get grpKTCustomFields => 'Custom fields';

  @override
  String get grpKTProjectSettings => 'Project settings';

  @override
  String get grpKSwitchWs => 'Switch workspace';

  @override
  String get grpKSwitchWsSem => 'Switch to another workspace';

  @override
  String get grpKToggleDark => 'Toggle dark mode';

  @override
  String get grpKToggleDarkSem => 'Switch between the light and the dark theme';

  @override
  String get grpKCreateProject => 'Create a project';

  @override
  String get grpKCreateDoc => 'Create a doc';

  @override
  String get grpKCreateDashboard => 'Create a dashboard';

  @override
  String get grpKCreateSprint => 'Create a sprint';

  @override
  String get grpKCreateSprintSem => 'Create a sprint in this project';

  @override
  String get grpKInviteMember => 'Invite a member';

  @override
  String get grpKInviteMemberSem => 'Invite someone to this workspace';

  @override
  String get grpKTImportExport => 'Import and export';

  @override
  String get grpKTOffline => 'Offline and storage';

  @override
  String get grpKSignOut => 'Sign out';

  @override
  String get grpKSignOutSem => 'Sign out of this device';

  @override
  String get grpKNewTask => 'New task';

  @override
  String get grpKNewTaskSem => 'Create a task in this project';

  @override
  String get grpKRenameTask => 'Rename the task under the cursor';

  @override
  String get grpKRenameTaskSem =>
      'Rename the task the cursor is on in the list';

  @override
  String get grpKChangeStatus => 'Change status of this task';

  @override
  String get grpKChangeStatusSem => 'Change the status of the open task';

  @override
  String get grpKAssignMe => 'Assign this task to me';

  @override
  String get grpKAssignMeSem => 'Assign the open task to me';

  @override
  String get grpKTimerStart => 'Start the timer on this task';

  @override
  String get grpKTimerStartSem => 'Start the timer on the open task';

  @override
  String get grpKTimerStop => 'Stop the timer';

  @override
  String get grpKTimerStopSem => 'Stop the running timer';

  @override
  String get grpKViewList => 'List view';

  @override
  String get grpKViewBoard => 'Board view';

  @override
  String get grpKViewCalendar => 'Calendar view';

  @override
  String get grpKViewTimeline => 'Timeline view';

  @override
  String get grpKShowList => 'Show this project as a list';

  @override
  String get grpKShowBoard => 'Show this project as a board';

  @override
  String get grpKShowCalendar => 'Show this project as a calendar';

  @override
  String get grpKShowTimeline => 'Show this project as a timeline';

  @override
  String get grpLGeneric => 'Something went wrong. Try again.';

  @override
  String get grpLNetCheck =>
      'Cannot reach the server. Check your connection and try again.';

  @override
  String get grpLNetCheckShort =>
      'Could not reach the server. Check your connection.';

  @override
  String get grpLNetTry => 'Could not reach the server. Try again.';

  @override
  String get grpLNetOffline =>
      'This needs a connection to the server. It works again once you are back online.';

  @override
  String get grpLNoConn => 'No connection. Check it and try again.';

  @override
  String get grpLNoPerm => 'You do not have permission.';

  @override
  String get grpLNoPermDo => 'You do not have permission to do that.';

  @override
  String get grpLNoAccess => 'You do not have access to that.';

  @override
  String get grpLCheckValues => 'Check the values and try again.';

  @override
  String get grpLNotValid => 'That is not valid.';

  @override
  String get grpLArchived =>
      'This project is archived. Restore it to make changes.';

  @override
  String get grpLGone => 'That no longer exists.';

  @override
  String get grpLTaskConflict => 'Someone else changed this task first.';

  @override
  String get grpLTaskTransition => 'The workflow does not allow that move.';

  @override
  String get grpLTaskHasSubtasks =>
      'This task has subtasks: choose what happens to them.';

  @override
  String get grpLTaskCycle =>
      'A task cannot become a subtask of itself or of one of its own subtasks.';

  @override
  String grpLTaskBlocked(String detail) {
    return 'Blocked by $detail: finish those first.';
  }

  @override
  String grpLTaskLinkCycle(String detail) {
    return 'Those tasks would block each other in a loop: $detail.';
  }

  @override
  String get grpLTaskLinkExists => 'These tasks are already linked that way.';

  @override
  String get grpLFieldRequired => 'A required field has no value.';

  @override
  String get grpLTaskGone => 'That task no longer exists.';

  @override
  String get grpLCommentConflict => 'Someone changed this comment first.';

  @override
  String get grpLCommentLocked => 'That comment can no longer be edited.';

  @override
  String get grpLMentionNoAccess =>
      'Somebody you mentioned cannot see this task.';

  @override
  String get grpLCommentCheck => 'Check the comment and try again.';

  @override
  String get grpLCommentGone => 'That comment no longer exists.';

  @override
  String get grpLSlugTaken => 'That URL is taken';

  @override
  String get grpLWsStale =>
      'This workspace was changed elsewhere. Refresh to see the latest version.';

  @override
  String get grpLWsNotRestorable => 'This workspace can no longer be restored.';

  @override
  String get grpLOwnerNeeded => 'A workspace needs at least one owner.';

  @override
  String get grpLInvEmailMismatch =>
      'This invitation is for another email address.';

  @override
  String get grpLInvExpired =>
      'This invitation has expired. Ask for a new one.';

  @override
  String get grpLInvRevoked => 'This invitation was revoked.';

  @override
  String get grpLInvBeforeRemoval =>
      'This invitation predates your removal. Ask for a new one.';

  @override
  String get grpLInvUsedUp => 'This invitation has already been used up.';

  @override
  String get grpLInvNotFound => 'This invitation does not exist.';

  @override
  String get grpLInvRate =>
      'Too many invitations just now. Wait a while and try again.';

  @override
  String get grpLInvExists => 'That person is already invited or a member.';

  @override
  String get grpLWfInvalid => 'The workflow has problems. Fix them to save.';

  @override
  String get grpLWfConflict =>
      'Someone else saved the workflow first. Your changes are still here: review what changed and save again.';

  @override
  String get grpLProjectGone => 'That project no longer exists.';

  @override
  String get grpLDashDenied =>
      'You are not allowed to do that on this dashboard.';

  @override
  String get grpLDashNotFound => 'That dashboard or widget is not available.';

  @override
  String get grpLDashHeavy =>
      'This widget takes too long to compute. Narrow its filter.';

  @override
  String get grpLDashConflict =>
      'Someone else changed this dashboard. Reload it and try again.';

  @override
  String get grpLNotifGone => 'That notification no longer exists.';

  @override
  String get grpLViewConflict => 'Someone else changed this layout first.';

  @override
  String get grpLViewInvalid => 'That layout is not valid.';

  @override
  String get grpLViewNameTaken => 'A layout with that name already exists.';

  @override
  String get grpLViewLimit => 'That is the most layouts you can keep here.';

  @override
  String get grpLViewGone => 'That layout no longer exists.';

  @override
  String get grpLAutoDenied =>
      'You need the \"manage automations\" permission for that.';

  @override
  String get grpLAutoConflict =>
      'Someone else changed this rule first. Load the latest and retry.';

  @override
  String get grpLImpCannot => 'That cannot be done now.';

  @override
  String get grpLImpTooBig => 'That file is larger than this server accepts.';

  @override
  String get grpLImpDenied => 'Only admins can import and export data.';

  @override
  String get grpLImpNotFound => 'That import no longer exists.';

  @override
  String get grpLAuditDenied => 'You are not allowed to read the audit log.';

  @override
  String get grpLAuditTaskNA => 'That task is not available.';

  @override
  String get grpLAuditFilters => 'Those filters are not valid.';

  @override
  String get grpLSprintConflict =>
      'Someone else changed this first. Reload and retry.';

  @override
  String get grpLFieldNameTaken => 'A field with that name already exists.';

  @override
  String grpLFieldLimit(int count) {
    return 'A project can have at most $count active fields.';
  }

  @override
  String get grpLFieldNeedsRemap =>
      'Some removed options are still used: choose what their values become.';

  @override
  String get grpLFieldConflict =>
      'Someone else changed this field first; reload and try again.';

  @override
  String get grpLFieldGone => 'That field no longer exists.';

  @override
  String get grpLFilterInvalid => 'That filter is not valid.';

  @override
  String get grpLFilterNameTaken =>
      'A filter with that name already exists here.';

  @override
  String get grpLFilterLimit => 'That is the most filters you can keep here.';

  @override
  String get grpLFilterGone => 'That filter no longer exists.';

  @override
  String get grpLFilterConflict => 'Someone else changed this filter first.';

  @override
  String get grpLAttTooBig => 'That file is larger than an attachment may be.';

  @override
  String get grpLAttQuota => 'This workspace has used all its storage.';

  @override
  String get grpLAttTooMany =>
      'Too many uploads are open. Finish or cancel some first.';

  @override
  String get grpLAttUnavailable =>
      'The file could not be checked right now. Try again.';

  @override
  String get grpLAttChunk => 'Part of the file was not taken. Try again.';

  @override
  String get grpLAttRefusedPlain => 'That kind of file is not accepted.';

  @override
  String grpLAttRefused(String detail) {
    return 'That file is not accepted: $detail';
  }

  @override
  String get grpLAttIncomplete => 'The upload did not finish. Try again.';

  @override
  String get grpLAttExpired => 'That upload expired. Try again.';

  @override
  String get grpLAttUnreadable => 'Could not read that file.';

  @override
  String get grpLAttNotAllowed => 'You are not allowed to do that.';

  @override
  String get grpLAttArchived =>
      'This project is archived: files are read-only.';

  @override
  String get grpLAttGone =>
      'That is gone: the file, comment or task was removed.';

  @override
  String get grpLDocNotFound =>
      'That page does not exist or you cannot open it.';

  @override
  String get grpLDocConflict => 'Someone else changed this page first.';

  @override
  String get grpLDocArchived => 'That page is archived.';

  @override
  String get grpLDocCycle => 'A page cannot go under itself.';

  @override
  String get grpLKeyTaken => 'That key is already used by another project.';

  @override
  String get grpLKeyLocked =>
      'The key cannot change once the project has tasks.';

  @override
  String get grpLLastMember => 'A private project needs at least one member.';

  @override
  String get grpLProjConflict =>
      'This project changed in the meantime. Reloaded — try again.';

  @override
  String get grpLRoleBuiltin => 'Built-in roles cannot be changed or deleted.';

  @override
  String get grpLRoleNameTaken => 'A role with that name already exists.';

  @override
  String get grpLRoleGone => 'That role no longer exists.';

  @override
  String get grpLRoleConflict =>
      'This role changed in the meantime. Reloaded — try again.';

  @override
  String get grpLRepeatInvalid => 'That repeat is not valid.';

  @override
  String get grpLRepeatDenied =>
      'You are not allowed to change how this repeats.';

  @override
  String get grpMPriUrgent => 'Urgent';

  @override
  String get grpMPriHigh => 'High';

  @override
  String get grpMPriNormal => 'Normal';

  @override
  String get grpMPriLow => 'Low';

  @override
  String get grpMPriNone => 'None';

  @override
  String get grpMLinkBlocks => 'Blocks';

  @override
  String get grpMLinkBlockedBy => 'Is blocked by';

  @override
  String get grpMLinkRelates => 'Relates to';

  @override
  String get grpMLinkDuplicates => 'Duplicates';

  @override
  String get grpMLinkDuplicatedBy => 'Is duplicated by';

  @override
  String get grpMCatNotStarted => 'Not started';

  @override
  String get grpMCatActive => 'Active';

  @override
  String get grpMCatDone => 'Done';

  @override
  String get grpMCatCancelled => 'Cancelled';

  @override
  String get grpMFtypeText => 'Text';

  @override
  String get grpMFtypeNumber => 'Number';

  @override
  String get grpMFtypeSelect => 'Select';

  @override
  String get grpMFtypeMulti => 'Multi-select';

  @override
  String get grpMFtypeDate => 'Date';

  @override
  String get grpMFtypeCheckbox => 'Checkbox';

  @override
  String get grpMFtypeUrl => 'URL';

  @override
  String get grpMFtypeUser => 'User';

  @override
  String get grpMFtypeMoney => 'Money';

  @override
  String get grpMTrigTaskCreated => 'A task is created';

  @override
  String get grpMTrigStatusChanged => 'A status changes';

  @override
  String get grpMTrigFieldChanged => 'A field changes';

  @override
  String get grpMTrigAssigned => 'Someone is assigned';

  @override
  String get grpMTrigDueDateReached => 'A due date is reached';

  @override
  String get grpMTrigCommentAdded => 'A comment is added';

  @override
  String get grpMActSetField => 'Set a field';

  @override
  String get grpMActSetStatus => 'Set the status';

  @override
  String get grpMActSetAssignee => 'Change assignees';

  @override
  String get grpMActAddComment => 'Add a comment';

  @override
  String get grpMActCreateSubtask => 'Create a subtask';

  @override
  String get grpMActNotify => 'Notify people';

  @override
  String get grpMActWebhook => 'Call a webhook';

  @override
  String get grpMRunSucceeded => 'Succeeded';

  @override
  String get grpMRunFailed => 'Failed';

  @override
  String get grpMRunSkippedCondition => 'Skipped: condition';

  @override
  String get grpMRunSkippedLoop => 'Stopped: loop';

  @override
  String get grpMRunSkippedRate => 'Paused: too many runs';

  @override
  String get grpMWkNumber => 'Number';

  @override
  String get grpMWkBar => 'Bar chart';

  @override
  String get grpMWkLine => 'Line chart';

  @override
  String get grpMWkPie => 'Pie chart';

  @override
  String get grpMWkTable => 'Table';

  @override
  String get grpMWkBurndown => 'Burndown';

  @override
  String get grpMWkWorkload => 'Workload';

  @override
  String get grpMMeasCount => 'Task count';

  @override
  String get grpMMeasPoints => 'Story points';

  @override
  String get grpMMeasEstimateHours => 'Estimated hours';

  @override
  String get grpMMeasLoggedHours => 'Logged hours';

  @override
  String get grpMMeasCycleDays => 'Cycle time (days)';

  @override
  String get grpMScopeAll => 'All tasks';

  @override
  String get grpMScopeOpen => 'Open tasks';

  @override
  String get grpMScopeDone => 'Done tasks';

  @override
  String get grpMVisPersonal => 'Only me';

  @override
  String get grpMVisProject => 'Everyone in the project';

  @override
  String get grpMVisWorkspace => 'Everyone in the workspace';

  @override
  String get grpMLblStatus => 'Status';

  @override
  String get grpMLblStatusCategory => 'Status category';

  @override
  String get grpMLblPerson => 'Person';

  @override
  String get grpMLblPriority => 'Priority';

  @override
  String get grpMLblProject => 'Project';

  @override
  String get grpMLblSprint => 'Sprint';

  @override
  String get grpMLblCreatedDay => 'Created (day)';

  @override
  String get grpMLblCreatedWeek => 'Created (week)';

  @override
  String get grpMLblDueWeek => 'Due (week)';

  @override
  String get grpMImpJiraCsv => 'Jira (CSV export)';

  @override
  String get grpMImpJiraJson => 'Jira (JSON)';

  @override
  String get grpMImpClickupCsv => 'ClickUp (CSV export)';

  @override
  String get grpMImpClickupJson => 'ClickUp (JSON)';

  @override
  String get grpMImpCsv => 'Any CSV file';

  @override
  String get grpMImpTaskforge => 'TaskForge export (tasks.json)';

  @override
  String get grpMNkAssigned => 'Assigned to you';

  @override
  String get grpMNkMentioned => 'Mentions';

  @override
  String get grpMNkCommented => 'Comments';

  @override
  String get grpMNkStatusChanged => 'Status changes';

  @override
  String get grpMNkDueSoon => 'Due soon';

  @override
  String get grpMNkTimerLong => 'Long timers';

  @override
  String get grpMNkUnknown => 'Notification';

  @override
  String get grpMIfAll => 'All';

  @override
  String get grpMIfUnread => 'Unread';

  @override
  String get grpMIfMentions => 'Mentions';

  @override
  String get grpMIfAssigned => 'Assigned';

  @override
  String get grpMIfSnoozed => 'Snoozed';

  @override
  String get grpMIfArchived => 'Archived';

  @override
  String get grpMEmOff => 'Off';

  @override
  String get grpMEmInstant => 'Instant';

  @override
  String get grpMEmDigest => 'Daily digest';

  @override
  String get grpMRkSchedule => 'On a schedule';

  @override
  String get grpMRkAfterCompletion => 'After it is completed';

  @override
  String get grpMLblOpEq => 'is';

  @override
  String get grpMLblOpNe => 'is not';

  @override
  String get grpMLblOpLt => 'before / less than';

  @override
  String get grpMLblOpLte => 'on or before / at most';

  @override
  String get grpMLblOpGt => 'after / more than';

  @override
  String get grpMLblOpGte => 'on or after / at least';

  @override
  String get grpMLblOpContains => 'contains';

  @override
  String get grpMLblOpNotContains => 'does not contain';

  @override
  String get grpMLblOpIn => 'is any of';

  @override
  String get grpMLblOpNotIn => 'is none of';

  @override
  String get grpMLblOpEmpty => 'is empty';

  @override
  String get grpMLblOpNotEmpty => 'is not empty';

  @override
  String get grpMLblAssignee => 'Assignee';

  @override
  String get grpMLblStart => 'Start';

  @override
  String get grpMLblDue => 'Due';

  @override
  String get grpMLblCreated => 'Created';

  @override
  String get grpMLblUpdated => 'Updated';

  @override
  String get grpMLblDueDate => 'Due date';

  @override
  String get grpMLblProgress => 'Subtask progress';

  @override
  String get grpMLblViewList => 'List';

  @override
  String get grpMLblViewBoard => 'Board';

  @override
  String get grpMLblViewCalendar => 'Calendar';

  @override
  String get grpMLblViewTimeline => 'Timeline';

  @override
  String get grpMRelNow => 'now';

  @override
  String get grpMRelJustNow => 'just now';

  @override
  String grpMRelMin(int n) {
    return '$n min ago';
  }

  @override
  String grpMRelHour(int n) {
    return '$n h ago';
  }

  @override
  String get grpMRelYesterday => 'yesterday';

  @override
  String grpMRelDay(int n) {
    return '$n d ago';
  }

  @override
  String get grpMNotifSomeone => 'Someone';

  @override
  String grpMNotifAssigned(String who) {
    return '$who assigned you';
  }

  @override
  String grpMNotifMentioned(String who) {
    return '$who mentioned you in';
  }

  @override
  String grpMNotifCommented(String who) {
    return '$who commented on';
  }

  @override
  String grpMNotifStatusChanged(String who) {
    return '$who changed the status of';
  }

  @override
  String grpMNotifMoved(String who, String fromStatus, String toStatus) {
    return '$who moved from $fromStatus to $toStatus';
  }

  @override
  String get grpMNotifDueSoon => 'Due soon:';

  @override
  String get grpMNotifTimer => 'Your timer is still running on';

  @override
  String get grpMNotifNew => 'New activity on';

  @override
  String get grpMUnitDay => 'day';

  @override
  String get grpMUnitDays => 'days';

  @override
  String get grpMUnitWeek => 'week';

  @override
  String get grpMUnitWeeks => 'weeks';

  @override
  String get grpMUnitMonth => 'month';

  @override
  String get grpMUnitMonths => 'months';

  @override
  String get grpMUnitYear => 'year';

  @override
  String get grpMUnitYears => 'years';

  @override
  String get grpMSlashText => 'Text';

  @override
  String get grpMSlashH1 => 'Heading 1';

  @override
  String get grpMSlashH2 => 'Heading 2';

  @override
  String get grpMSlashH3 => 'Heading 3';

  @override
  String get grpMSlashBullet => 'Bulleted list';

  @override
  String get grpMSlashNumbered => 'Numbered list';

  @override
  String get grpMSlashTodo => 'Checklist';

  @override
  String get grpMSlashQuote => 'Quote';

  @override
  String get grpMSlashCode => 'Code';

  @override
  String get grpMSlashTable => 'Table';

  @override
  String get grpMSlashDivider => 'Divider';

  @override
  String get grpMSlashImage => 'Image';

  @override
  String get grpMSlashCallout => 'Callout';

  @override
  String get grpMSlashTask => 'Task card';

  @override
  String get grpMMeanSucceeded => 'Every action ran.';

  @override
  String get grpMMeanFailed =>
      'An action failed; the ones before it stay done.';

  @override
  String get grpMMeanSkippedCondition =>
      'The event matched, but the task did not meet the condition.';

  @override
  String get grpMMeanSkippedLoop =>
      'Rules triggered rules more than 5 hops deep, so this run was stopped to end a loop.';

  @override
  String get grpMMeanSkippedRate =>
      'This rule already ran 30 times in the last minute, so this run was skipped.';

  @override
  String get grpMStepOk => 'ok';

  @override
  String get grpMStepFailed => 'failed';

  @override
  String get grpMStepNotRun => 'not run';

  @override
  String get grpMStepPlanned => 'planned';

  @override
  String get grpMStepWouldFail => 'would fail';

  @override
  String get grp1DropCardHere => 'Drop a card here';

  @override
  String get grp1NoCards => 'No cards';

  @override
  String get grp1StopWatchingTask => 'Stop watching this task';

  @override
  String get grp1WatchTask => 'Watch this task';

  @override
  String get grp1SecondFactorRequired => 'Second factor required.';

  @override
  String get grp1AnAutomation => 'An automation';

  @override
  String get grp1TheSystem => 'The system';

  @override
  String grp1MemberCount(int count) {
    return '$count member(s)';
  }

  @override
  String get grp1SyncLive => 'Live';

  @override
  String get grp1SyncConnecting => 'Connecting…';

  @override
  String get grp1SyncReconnecting => 'Reconnecting…';

  @override
  String get grp1SyncLiveTip => 'Changes by others appear as they happen';

  @override
  String get grp1SyncNotLiveTip =>
      'Not live: changes by others will appear once reconnected';

  @override
  String get grp1EnterNumber => 'Enter a number.';

  @override
  String get grp1EnterAmount => 'Enter an amount.';

  @override
  String get grp1EnterCurrency => 'Enter a 3-letter currency, e.g. USD.';

  @override
  String get grp1EnterUrl => 'Enter a web address starting with http(s)://';

  @override
  String get grp1UseIsoDate => 'Use YYYY-MM-DD.';

  @override
  String get devTitle => 'Developer';

  @override
  String get devSub => 'API tokens and webhooks';

  @override
  String get devTokensTab => 'API tokens';

  @override
  String get devWebhooksTab => 'Webhooks';

  @override
  String get devTokenNew => 'New token';

  @override
  String get devTokenName => 'Name';

  @override
  String get devTokenScopes => 'What it may do';

  @override
  String get devTokenExpiry => 'Expires';

  @override
  String get devExpiryNever => 'Never';

  @override
  String get devExpiry30 => 'In 30 days';

  @override
  String get devExpiry90 => 'In 90 days';

  @override
  String get devExpiry365 => 'In a year';

  @override
  String get devTokenCreate => 'Create token';

  @override
  String get devTokenCreatedTitle => 'Copy your token now';

  @override
  String get devTokenCreatedBody =>
      'This is the only time it is shown. Store it somewhere safe.';

  @override
  String get devCopy => 'Copy';

  @override
  String get devCopied => 'Copied';

  @override
  String get devDone => 'Done';

  @override
  String devTokenPrefix(String prefix) {
    return 'Starts with $prefix';
  }

  @override
  String get devTokenNeverUsed => 'Never used';

  @override
  String devTokenUsed(String when) {
    return 'Last used $when';
  }

  @override
  String get devTokenActive => 'Active';

  @override
  String get devTokenExpired => 'Expired';

  @override
  String get devTokenRevoked => 'Revoked';

  @override
  String get devTokenRevoke => 'Revoke';

  @override
  String devTokenRevokeTitle(String name) {
    return 'Revoke \"$name\"?';
  }

  @override
  String get devTokenRevokeBody =>
      'Anything using this token stops working at once.';

  @override
  String get devTokensEmpty => 'No tokens yet.';

  @override
  String get devTokensHint =>
      'A token can do what you can do, narrowed to the scopes you pick. It works in this workspace only.';

  @override
  String get devWebhookNew => 'New webhook';

  @override
  String get devWebhookEdit => 'Edit webhook';

  @override
  String get devWebhookName => 'Name (optional)';

  @override
  String get devWebhookUrl => 'URL';

  @override
  String get devWebhookEvents => 'Events';

  @override
  String get devWebhookSave => 'Save';

  @override
  String get devWebhookActive => 'Active';

  @override
  String get devWebhookSecret => 'Signing secret';

  @override
  String get devWebhookTest => 'Send test';

  @override
  String devWebhookTestDone(String status) {
    return 'The test was sent: $status';
  }

  @override
  String get devWebhookDeliveries => 'Deliveries';

  @override
  String get devWebhookDelete => 'Delete';

  @override
  String devWebhookDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get devWebhookDeleteBody => 'Its delivery log is deleted too.';

  @override
  String get devWebhooksEmpty => 'No webhooks yet.';

  @override
  String get devWebhooksDenied =>
      'Only people who can manage webhooks see these.';

  @override
  String devWebhookOff(String reason) {
    return 'Switched off: $reason';
  }

  @override
  String get devWebhookHint =>
      'Each event is sent as a signed POST. The receiver checks the signature with the secret.';

  @override
  String get devDeliveriesTitle => 'Deliveries';

  @override
  String get devDeliveriesEmpty => 'Nothing has been sent yet.';

  @override
  String get devStatusDelivered => 'Delivered';

  @override
  String get devStatusPending => 'Waiting';

  @override
  String get devStatusFailed => 'Failed, will retry';

  @override
  String get devStatusGaveUp => 'Gave up';

  @override
  String devAttempt(int n) {
    return 'Attempt $n';
  }

  @override
  String get devRequest => 'Request';

  @override
  String get devResponse => 'Response';

  @override
  String get devHeaders => 'Headers';

  @override
  String get devBody => 'Body';

  @override
  String get devResend => 'Resend';

  @override
  String devResent(String status) {
    return 'Sent again: $status';
  }

  @override
  String devNextTry(String when) {
    return 'Next try $when';
  }

  @override
  String get devLoadMore => 'Load more';

  @override
  String get devRetry => 'Try again';

  @override
  String get devDenied => 'You cannot do that here.';

  @override
  String get devScopeWorkspacesRead => 'See the workspace';

  @override
  String get devScopeProjectsRead => 'Read projects';

  @override
  String get devScopeProjectsWrite => 'Create and change projects';

  @override
  String get devScopeTasksRead => 'Read tasks';

  @override
  String get devScopeTasksWrite => 'Create, change and delete tasks';

  @override
  String get devScopeCommentsRead => 'Read comments';

  @override
  String get devScopeCommentsWrite => 'Write comments';

  @override
  String get devEventTaskCreated => 'A task is created';

  @override
  String get devEventTaskUpdated => 'A task is edited';

  @override
  String get devEventTaskStatus => 'A task changes status';

  @override
  String get devEventTaskAssigned => 'People are assigned to a task';

  @override
  String get devEventTaskDeleted => 'A task is deleted';

  @override
  String get devEventCommentCreated => 'A comment is added';

  @override
  String get devEventCommentUpdated => 'A comment is edited';

  @override
  String get devEventCommentDeleted => 'A comment is deleted';

  @override
  String get devEventPing => 'Test event';
}

/// The translations for English (`en_XA`).
class AppLocalizationsEnXa extends AppLocalizationsEn {
  AppLocalizationsEnXa() : super('en_XA');

  @override
  String get appTitle => '[ŢåšķFöŕĝé ~~~]';

  @override
  String get retry => '[Ŕéţŕý ~]';

  @override
  String get cancel => '[Çåñçéł ~~]';

  @override
  String get save => '[Šåṽé ~]';

  @override
  String get close => '[Çłöšé ~]';

  @override
  String get signOut => '[Šíĝñ öûţ ~~]';

  @override
  String get inbox => '[Íñƀöx ~]';

  @override
  String get workspaceSettings => '[Ŵöŕķšþåçé šéţţíñĝš ~~~~~~]';

  @override
  String get homeLoadWorkspacesFailed =>
      '[Çöûłð ñöţ łöåð ýöûŕ ŵöŕķšþåçéš. Ŕéţŕý ~~~~~~~~~~~~]';

  @override
  String get homeLoadAccountFailed =>
      '[Çöûłð ñöţ łöåð ýöûŕ åççöûñţ. ~~~~~~~~~]';

  @override
  String get calendar => '[Çåłéñðåŕ ~~]';

  @override
  String get calendarSubtitle =>
      '[Éṽéŕýţĥíñĝ ðûé, åçŕöšš ýöûŕ þŕöĵéçţš ~~~~~~~~~~~~]';

  @override
  String get notificationSettings => '[Ñöţíƒíçåţíöñ šéţţíñĝš ~~~~~~~]';

  @override
  String get notificationSettingsSubtitle =>
      '[Ŵĥåţ þíñĝš ýöû, qûíéţ ĥöûŕš åñð ţĥé ðíĝéšţ ~~~~~~~~~~~~~~]';

  @override
  String get offlineAndStorage => '[Öƒƒłíñé åñð šţöŕåĝé ~~~~~~]';

  @override
  String get offlineAndStorageSubtitle =>
      '[Çĥåñĝéš ɱåðé öƒƒłíñé, ţĥé łöçåł çöþý ~~~~~~~~~~~~]';

  @override
  String get sessions => '[Šéššíöñš ~~]';

  @override
  String get sessionsSubtitle =>
      '[Ðéṽíçéš šíĝñéð íñ ţö ýöûŕ åççöûñţ ~~~~~~~~~~~]';

  @override
  String get changePassword => '[Çĥåñĝé þåššŵöŕð ~~~~~]';

  @override
  String get connectivity => '[Çöññéçţíṽíţý ~~~~]';

  @override
  String get languageAndRegion => '[Łåñĝûåĝé åñð ŕéĝíöñ ~~~~~~]';

  @override
  String get languageAndRegionSubtitle =>
      '[Łåñĝûåĝé, çåłéñðåŕ, ŵééķ šţåŕţ åñð ðíĝíţš ~~~~~~~~~~~~~]';

  @override
  String get signIn => '[Šíĝñ íñ ~~]';

  @override
  String get createAccount => '[Çŕéåţé åççöûñţ ~~~~]';

  @override
  String get forgotPassword => '[Föŕĝöţ ýöûŕ þåššŵöŕð? ~~~~~~~]';

  @override
  String get createAnAccount => '[Çŕéåţé åñ åççöûñţ ~~~~~]';

  @override
  String get alreadyHaveAccount => '[Í åłŕéåðý ĥåṽé åñ åççöûñţ ~~~~~~~~]';

  @override
  String get resetPassword => '[Ŕéšéţ þåššŵöŕð ~~~~]';

  @override
  String get sendCode => '[Šéñð çöðé ~~~]';

  @override
  String get backToSignIn => '[ßåçķ ţö šíĝñ íñ ~~~~~]';

  @override
  String get setNewPassword => '[Šéţ å ñéŵ þåššŵöŕð ~~~~~~]';

  @override
  String get updatePassword => '[Ûþðåţé þåššŵöŕð ~~~~~]';

  @override
  String get codeFromEmail => '[Çöðé ƒŕöɱ ýöûŕ éɱåíł ~~~~~~]';

  @override
  String get email => '[Éɱåíł ~]';

  @override
  String get password => '[Þåššŵöŕð ~~]';

  @override
  String get currentPassword => '[Çûŕŕéñţ þåššŵöŕð ~~~~~]';

  @override
  String get newPassword => '[Ñéŵ þåššŵöŕð ~~~~]';

  @override
  String get showPassword => '[Šĥöŵ þåššŵöŕð ~~~~]';

  @override
  String get hidePassword => '[Ĥíðé þåššŵöŕð ~~~~]';

  @override
  String get passwordChanged => '[Þåššŵöŕð çĥåñĝéð. Šíĝñ íñ åĝåíñ. ~~~~~~~~~~]';

  @override
  String get passwordUpdated =>
      '[Þåššŵöŕð ûþðåţéð. Šíĝñ íñ ŵíţĥ íţ. ~~~~~~~~~~~]';

  @override
  String get enterEmail => '[Éñţéŕ ýöûŕ éɱåíł åððŕéšš. ~~~~~~~~]';

  @override
  String get enterValidEmail => '[Éñţéŕ å ṽåłíð éɱåíł åððŕéšš. ~~~~~~~~~]';

  @override
  String get enterPassword => '[Éñţéŕ å þåššŵöŕð. ~~~~~]';

  @override
  String passwordTooShort(int min) {
    return '[Ûšé åţ łéåšţ $min çĥåŕåçţéŕš. ~~~~~~~~~~]';
  }

  @override
  String get enterResetCode => '[Éñţéŕ ţĥé çöðé ƒŕöɱ ýöûŕ éɱåíł. ~~~~~~~~~~]';

  @override
  String get enterYourPassword => '[Éñţéŕ ýöûŕ þåššŵöŕð. ~~~~~~]';

  @override
  String get errWrongCredentials => '[Ŵŕöñĝ éɱåíł öŕ þåššŵöŕð. ~~~~~~~~]';

  @override
  String get errTooManyAttempts =>
      '[Ţöö ɱåñý åţţéɱþţš. Ţŕý åĝåíñ íñ å ƒéŵ ɱíñûţéš. ~~~~~~~~~~~~~~~]';

  @override
  String get errAccountExists =>
      '[Åñ åççöûñţ ŵíţĥ ţĥåţ éɱåíł åłŕéåðý éxíšţš. ~~~~~~~~~~~~~~]';

  @override
  String get errServerProblem =>
      '[Ţĥé šéŕṽéŕ ĥåð å þŕöƀłéɱ. Ţŕý åĝåíñ íñ å ɱöɱéñţ. ~~~~~~~~~~~~~~~~]';

  @override
  String get errNoConnection =>
      '[Çåññöţ ŕéåçĥ ţĥé šéŕṽéŕ. Çĥéçķ ýöûŕ çöññéçţíöñ åñð ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get errGeneric => '[Šöɱéţĥíñĝ ŵéñţ ŵŕöñĝ. Ţŕý åĝåíñ. ~~~~~~~~~~]';

  @override
  String get languageLabel => '[Łåñĝûåĝé ~~]';

  @override
  String get calendarSystemLabel => '[Çåłéñðåŕ ~~]';

  @override
  String get calendarGregorian => '[Ĝŕéĝöŕíåñ ~~~]';

  @override
  String get calendarJalali => '[Ĵåłåłí (Šöłåŕ Ĥíĵŕí) ~~~~~~]';

  @override
  String get weekStartLabel => '[Ŵééķ šţåŕţš öñ ~~~~]';

  @override
  String get weekStartDefault => '[Łåñĝûåĝé ðéƒåûłţ ~~~~~]';

  @override
  String get weekSaturday => '[Šåţûŕðåý ~~]';

  @override
  String get weekSunday => '[Šûñðåý ~~]';

  @override
  String get weekMonday => '[Möñðåý ~~]';

  @override
  String get numeralsLabel => '[Ðíĝíţš ~~]';

  @override
  String get numeralsLatin => '[Ŵéšţéŕñ (0123) ~~~~]';

  @override
  String get numeralsNative => '[Ñåţíṽé ţö ţĥé łåñĝûåĝé ~~~~~~~]';

  @override
  String get previewLabel => '[Þŕéṽíéŵ ~~]';

  @override
  String get prefsSaveFailed =>
      '[Šåṽéð öñ ţĥíš ðéṽíçé öñłý. Ŵé çöûłð ñöţ ŕéåçĥ ţĥé šéŕṽéŕ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get workspaceDefaultLanguage =>
      '[Ðéƒåûłţ łåñĝûåĝé ƒöŕ ñéŵ ɱéɱƀéŕš ~~~~~~~~~~]';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ţåšķš',
      one: '1 ţåšķ',
      zero: 'Ñö ţåšķš',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get jalaliMonth1 => '[Fåŕṽåŕðíñ ~~~]';

  @override
  String get jalaliMonth2 => '[Öŕðíƀéĥéšĥţ ~~~]';

  @override
  String get jalaliMonth3 => '[Ķĥöŕðåð ~~]';

  @override
  String get jalaliMonth4 => '[Ţíŕ ~]';

  @override
  String get jalaliMonth5 => '[Möŕðåð ~~]';

  @override
  String get jalaliMonth6 => '[Šĥåĥŕíṽåŕ ~~~]';

  @override
  String get jalaliMonth7 => '[Méĥŕ ~]';

  @override
  String get jalaliMonth8 => '[Åƀåñ ~]';

  @override
  String get jalaliMonth9 => '[Åžåŕ ~]';

  @override
  String get jalaliMonth10 => '[Ðéý ~]';

  @override
  String get jalaliMonth11 => '[ßåĥɱåñ ~~]';

  @override
  String get jalaliMonth12 => '[Éšƒåñð ~~]';

  @override
  String get pickDateOk => '[ÖĶ ]';

  @override
  String get pickDateTitle => '[Šéłéçţ ðåţé ~~~]';

  @override
  String get previousMonth => '[Þŕéṽíöûš ɱöñţĥ ~~~~]';

  @override
  String get nextMonth => '[Ñéxţ ɱöñţĥ ~~~]';

  @override
  String get weekdayShortMon => '[Möñ ~]';

  @override
  String get weekdayShortTue => '[Ţûé ~]';

  @override
  String get weekdayShortWed => '[Ŵéð ~]';

  @override
  String get weekdayShortThu => '[Ţĥû ~]';

  @override
  String get weekdayShortFri => '[Fŕí ~]';

  @override
  String get weekdayShortSat => '[Šåţ ~]';

  @override
  String get weekdayShortSun => '[Šûñ ~]';

  @override
  String get grpACancel => '[Çåñçéł ~~]';

  @override
  String get grpASave => '[Šåṽé ~]';

  @override
  String get grpARetry => '[Ŕéţŕý ~]';

  @override
  String get grpADone => '[Ðöñé ~]';

  @override
  String get grpAClose => '[Çłöšé ~]';

  @override
  String get grpAEdit => '[Éðíţ ~]';

  @override
  String get grpADelete => '[Ðéłéţé ~~]';

  @override
  String get grpANote => '[Ñöţé ~]';

  @override
  String get grpATotal => '[Ţöţåł ~]';

  @override
  String get grpATask => '[Ţåšķ ~]';

  @override
  String get grpAMerge => '[Méŕĝé ~]';

  @override
  String get grpARemove => '[Ŕéɱöṽé ~~]';

  @override
  String get grpAOfflineBack => '[ßåçķ ~]';

  @override
  String get grpAOfflineTitle => '[Öƒƒłíñé åñð šţöŕåĝé ~~~~~~]';

  @override
  String get grpAOfflineChooseWorkspace =>
      '[Çĥööšé å ŵöŕķšþåçé ƒíŕšţ. ~~~~~~~~]';

  @override
  String get grpAOfflineNeedsAttention => '[Ñééðš ýöûŕ åţţéñţíöñ ~~~~~~]';

  @override
  String get grpAOfflineNothingToDecide =>
      '[Ñöţĥíñĝ. Éṽéŕý çĥåñĝé ɱåðé öƒƒłíñé ŵåš šéñţ. ~~~~~~~~~~~~~~]';

  @override
  String grpAOfflineWaiting(int count) {
    return '[Ŵåíţíñĝ ţö ƀé šéñţ ($count) ~~~~~~~~~]';
  }

  @override
  String get grpASyncNow => '[Šýñç ñöŵ ~~]';

  @override
  String get grpAOfflineNothingWaiting => '[Ñöţĥíñĝ íš ŵåíţíñĝ. ~~~~~~]';

  @override
  String get grpAEntryATask => '[å ţåšķ ~~]';

  @override
  String grpAEntryNewTask(String title) {
    return '[Ñéŵ ţåšķ “$title” ~~~~~~]';
  }

  @override
  String grpAEntryEdit(String name, String fields) {
    return '[Éðíţ $name: $fields ~~~~~~~]';
  }

  @override
  String grpAEntryDelete(String name) {
    return '[Ðéłéţé $name ~~~~]';
  }

  @override
  String grpAEntryComment(String name) {
    return '[Çöɱɱéñţ öñ $name ~~~~~]';
  }

  @override
  String grpAEntryUpload(String file, String name) {
    return '[Ûþłöåð “$file” ţö $name ~~~~~~~~]';
  }

  @override
  String grpAOfflineClash(String field, String current, String mine) {
    return '[Ţĥéíŕš ($field): $current\nÝöûŕš: $mine ~~~~~~~~~~~~~]';
  }

  @override
  String get grpAKeepMine => '[Ķééþ ɱíñé ~~~]';

  @override
  String get grpATakeTheirs => '[Ţåķé ţĥéíŕš ~~~]';

  @override
  String get grpATryAgain => '[Ţŕý åĝåíñ ~~~]';

  @override
  String get grpADiscard => '[Ðíšçåŕð ~~]';

  @override
  String get grpAMergeTitle => '[Ŵĥíçĥ öƒ ýöûŕ çĥåñĝéš ţö ķééþ? ~~~~~~~~~~]';

  @override
  String get grpAStorage => '[Šţöŕåĝé ~~]';

  @override
  String get grpAReading => '[Ŕéåðíñĝ… ~~]';

  @override
  String grpAStorageUsage(String size, int cap) {
    return '[Ţĥé çöþý öñ ţĥíš ðéṽíçé ĥöłðš $size Mß öƒ åţ ɱöšţ $cap Mß. ~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpAMostItMayHold => '[Möšţ íţ ɱåý ĥöłð ~~~~~]';

  @override
  String grpAMegabytes(int mb) {
    return '[$mb Mß ~~]';
  }

  @override
  String get grpAClearCopy => '[Çłéåŕ ţĥé çöþý öñ ţĥíš ðéṽíçé ~~~~~~~~~]';

  @override
  String get grpAStorageNote =>
      '[Çĥåñĝéš šţíłł ŵåíţíñĝ ţö ƀé šéñţ åŕé ķéþţ. Ţĥé çöþý íš šţöŕéð ûñéñçŕýþţéð: ûšé ýöûŕ ðéṽíçé\'š ðíšķ éñçŕýþţíöñ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpAClearTitle => '[Çłéåŕ ţĥé çöþý öñ ţĥíš ðéṽíçé? ~~~~~~~~~~]';

  @override
  String get grpAClearBody =>
      '[Ŵĥåţ ýöû ŕéåð íš ƒéţçĥéð åĝåíñ ŵĥéñ ýöû åŕé öñłíñé. Çĥåñĝéš ŵåíţíñĝ ţö ƀé šéñţ åŕé ñöţ ŕéɱöṽéð. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpAClear => '[Çłéåŕ ~]';

  @override
  String get grpAKeepOfflineTitle => '[Ķééþ þŕöĵéçţš öƒƒłíñé ~~~~~~~]';

  @override
  String get grpAKeepOfflineBody =>
      '[Å ķéþţ þŕöĵéçţ íš çöþíéð ŵĥöłé, šö íţš ţåšķš, šţåţûšéš åñð ɱéɱƀéŕš åŕé ţĥéŕé ŵíţĥöûţ å çöññéçţíöñ. Öţĥéŕ þŕöĵéçţš šĥöŵ ŵĥåţ ýöû ŕéåð łåšţ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpACopying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Çöþýíñĝ… $count ţåšķš',
      one: 'Çöþýíñĝ… 1 ţåšķ',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpASprintsTitle => '[Šþŕíñţš ~~]';

  @override
  String grpASprintsTitleProject(String name) {
    return '[Šþŕíñţš · $name ~~~~~]';
  }

  @override
  String get grpASprintsDisabled =>
      '[Šþŕíñţš åŕé šŵíţçĥéð öƒƒ ƒöŕ ţĥíš þŕöĵéçţ. Ţûŕñ ţĥéɱ öñ íñ ţĥé þŕöĵéçţ šéţţíñĝš. ~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpAProjectNotFound => '[Þŕöĵéçţ ñöţ ƒöûñð. ~~~~~~]';

  @override
  String grpAAddedAfterStart(int count) {
    return '[$count åððéð åƒţéŕ ţĥé šþŕíñţ šţåŕţéð (šĥöŵš åš å šçöþé çĥåñĝé). ~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpASprintCompleted(String name) {
    return '[$name çöɱþłéţéð. ~~~~~]';
  }

  @override
  String get grpAPlanning => '[Þłåññíñĝ ~~]';

  @override
  String get grpAReports => '[Ŕéþöŕţš ~~]';

  @override
  String get grpANewSprint => '[Ñéŵ šþŕíñţ ~~~]';

  @override
  String get grpABacklog => '[ßåçķłöĝ ~~]';

  @override
  String get grpABacklogEmpty => '[Ţĥé ƀåçķłöĝ íš éɱþţý. ~~~~~~~]';

  @override
  String get grpAAddToSprint => '[Åðð ţö šþŕíñţ ~~~~]';

  @override
  String get grpANoOpenSprint =>
      '[Ñö öþéñ šþŕíñţ. Çŕéåţé öñé ţö šţåŕţ þłåññíñĝ. ~~~~~~~~~~~~~~~]';

  @override
  String get grpADragHere =>
      '[Ðŕåĝ ţåšķš ĥéŕé, öŕ šéłéçţ šöɱé íñ ţĥé ƀåçķłöĝ. ~~~~~~~~~~~~~~~]';

  @override
  String grpADatesRange(String start, String end) {
    return '[$start ţö $end ~~~~~]';
  }

  @override
  String grpADaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ðåýš łéƒţ',
      one: '1 ðåý łéƒţ',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpASprintGoalText(String goal) {
    return '[Ĝöåł: $goal ~~~~]';
  }

  @override
  String get grpAShowOnBoard => '[Šĥöŵ öñ ƀöåŕð ~~~~]';

  @override
  String get grpAEditSprint => '[Éðíţ šþŕíñţ ~~~]';

  @override
  String get grpAStartSprint => '[Šţåŕţ šþŕíñţ ~~~~]';

  @override
  String get grpACompleteSprint => '[Çöɱþłéţé šþŕíñţ ~~~~~]';

  @override
  String get grpANoSprintsYet => '[Ñö šþŕíñţš ýéţ. ~~~~~]';

  @override
  String get grpASprintNameRequired => '[Ĝíṽé ţĥé šþŕíñţ å ñåɱé. ~~~~~~~]';

  @override
  String get grpASprintDatesFormat =>
      '[Ðåţéš åŕé ŵŕíţţéñ ÝÝÝÝ-MM-ÐÐ. ~~~~~~~~~]';

  @override
  String get grpASprintEndBeforeStart =>
      '[Ţĥé šþŕíñţ çåññöţ éñð ƀéƒöŕé íţ šţåŕţš. ~~~~~~~~~~~~~]';

  @override
  String get grpASprintCapacityNumber =>
      '[Çåþåçíţý íš å ñûɱƀéŕ, öŕ éɱþţý ƒöŕ ñöñé. ~~~~~~~~~~~~~]';

  @override
  String get grpASprintSaved => '[Šþŕíñţ šåṽéð ~~~~]';

  @override
  String get grpASprintName => '[Ñåɱé ~]';

  @override
  String get grpASprintGoal => '[Ĝöåł ~]';

  @override
  String get grpASprintStartLabel => '[Šţåŕţ (ÝÝÝÝ-MM-ÐÐ) ~~~~~~]';

  @override
  String get grpASprintEndLabel => '[Éñð (ÝÝÝÝ-MM-ÐÐ) ~~~~~]';

  @override
  String get grpAPickStartDate => '[Þíçķ šţåŕţ ðåţé ~~~~~]';

  @override
  String get grpAPickEndDate => '[Þíçķ éñð ðåţé ~~~~]';

  @override
  String get grpACapacityPointsOptional =>
      '[Çåþåçíţý íñ þöíñţš (öþţíöñåł) ~~~~~~~~~]';

  @override
  String get grpACapacityHoursOptional =>
      '[Çåþåçíţý íñ ĥöûŕš (öþţíöñåł) ~~~~~~~~~]';

  @override
  String grpASprintOverlap(String names) {
    return '[Ţĥéšé ðåţéš öṽéŕłåþ $names. ~~~~~~~~~]';
  }

  @override
  String grpACompleteTitle(String name) {
    return '[Çöɱþłéţé $name ~~~~~]';
  }

  @override
  String grpACompleteCounts(int done, int open) {
    return '[$done ðöñé, $open ûñƒíñíšĥéð ~~~~~~~~~~]';
  }

  @override
  String get grpACompleteWhatHappens =>
      '[Ŵĥåţ ĥåþþéñš ţö ţĥé ûñƒíñíšĥéð ţåšķš? ~~~~~~~~~~~~]';

  @override
  String get grpACompleteMoveNext => '[Möṽé ţö ţĥé ñéxţ šþŕíñţ ~~~~~~~]';

  @override
  String get grpACompleteNoPlanned =>
      '[Ñö þłåññéð šþŕíñţ ţö ɱöṽé ţĥéɱ ţö ~~~~~~~~~~~]';

  @override
  String get grpACompleteBackToBacklog => '[ßåçķ ţö ţĥé ƀåçķłöĝ ~~~~~~]';

  @override
  String grpAPointsFor(String key) {
    return '[Þöíñţš ƒöŕ $key ~~~~~]';
  }

  @override
  String get grpAPointsInvalid =>
      '[Ûšé å ñûɱƀéŕ, öŕ łéåṽé éɱþţý ţö çłéåŕ. ~~~~~~~~~~~~]';

  @override
  String get grpAStoryPoints => '[Šţöŕý þöíñţš ~~~~]';

  @override
  String get grpACapacityInHours => '[Çåþåçíţý íñ ĥöûŕš ~~~~~]';

  @override
  String get grpACapacityInPoints => '[Çåþåçíţý íñ þöíñţš ~~~~~~]';

  @override
  String grpABurndownTitle(String name) {
    return '[ßûŕñðöŵñ: $name ~~~~~]';
  }

  @override
  String get grpAPoints => '[Þöíñţš ~~]';

  @override
  String get grpATasks => '[Ţåšķš ~]';

  @override
  String get grpABurndownEmpty =>
      '[Ţĥé ƀûŕñðöŵñ šţåŕţš öñçé ţĥé šþŕíñţ íš šţåŕţéð. ~~~~~~~~~~~~~~~]';

  @override
  String grpABurndownChart(int days, int changes) {
    return '[ßûŕñðöŵñ çĥåŕţ, $days ðåýš, $changes šçöþé çĥåñĝéš ~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpABurndownBackfilled(int count) {
    return '[, $count ƀåçķ-ƒíłłéð ðåýš ~~~~~~~~]';
  }

  @override
  String get grpALegendRemaining => '[Ŕéɱåíñíñĝ ~~~]';

  @override
  String get grpALegendIdeal => '[Íðéåł ~]';

  @override
  String get grpALegendScopeChange => '[Šçöþé çĥåñĝé ~~~~]';

  @override
  String get grpALegendBackfilled => '[ßåçķ-ƒíłłéð ðåý ~~~~~]';

  @override
  String get grpAVelocityEmpty =>
      '[Ṽéłöçíţý åþþéåŕš åƒţéŕ ţĥé ƒíŕšţ çöɱþłéţéð šþŕíñţ. ~~~~~~~~~~~~~~~~]';

  @override
  String grpAVelocityTitle(int count, String average) {
    return '[Ṽéłöçíţý (łåšţ $count šþŕíñţš): åṽéŕåĝé $average þöíñţš ~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpAVelocityChart(int count) {
    return '[Ṽéłöçíţý çĥåŕţ, $count šþŕíñţš ~~~~~~~~~~]';
  }

  @override
  String get grpALegendCommitted => '[Çöɱɱíţţéð ~~~]';

  @override
  String get grpALegendCompleted => '[Çöɱþłéţéð ~~~]';

  @override
  String get grpATimesheetTitle => '[Ţíɱéšĥééţ ~~~]';

  @override
  String get grpAPreviousWeek => '[Þŕéṽíöûš ŵééķ ~~~~]';

  @override
  String get grpANextWeek => '[Ñéxţ ŵééķ ~~~]';

  @override
  String get grpAThisWeek => '[Ţĥíš ŵééķ ~~~]';

  @override
  String get grpATimesheetEmpty => '[Ñö ţíɱé łöĝĝéð ţĥíš ŵééķ. ~~~~~~~~]';

  @override
  String get grpARunning => '[Ŕûññíñĝ ~~]';

  @override
  String get grpAAddTime => '[Åðð ţíɱé ~~]';

  @override
  String get grpAYou => '[Ýöû ~]';

  @override
  String get grpAProjectTotals => '[Þŕöĵéçţ ţöţåłš ~~~~]';

  @override
  String get grpAChooseProject => '[Çĥööšé å þŕöĵéçţ ~~~~~]';

  @override
  String get grpATotalsEmpty =>
      '[Ñö ţíɱé łöĝĝéð íñ ţĥíš þŕöĵéçţ ţĥíš ŵééķ. ~~~~~~~~~~~~~]';

  @override
  String grpABillableAmount(String duration) {
    return '[  ($duration ƀíłłåƀłé) ~~~~~~~]';
  }

  @override
  String get grpAEditTime => '[Éðíţ ţíɱé ~~~]';

  @override
  String get grpATimeSpent => '[Ţíɱé šþéñţ ~~~]';

  @override
  String get grpABillable => '[ßíłłåƀłé ~~]';

  @override
  String get grpABadDuration =>
      '[Éñţéŕ å ţíɱé łíķé 1ĥ 30ɱ, 90ɱ öŕ 1:30. ~~~~~~~~~~~~]';

  @override
  String get grpAEstimate => '[Éšţíɱåţé ~~]';

  @override
  String get grpAEstimatedTime => '[Éšţíɱåţéð ţíɱé ~~~~]';

  @override
  String get grpAEmptyForNone => '[Éɱþţý ƒöŕ ñöñé ~~~~]';

  @override
  String get grpADeleteTimeTitle => '[Ðéłéţé ţĥíš ţíɱé? ~~~~~]';

  @override
  String get grpADeleteTimeBody =>
      '[Ţĥé łöĝĝéð ţíɱé íš ŕéɱöṽéð ƒöŕ ĝööð. ~~~~~~~~~~~~]';

  @override
  String get grpAKeep => '[Ķééþ ~]';

  @override
  String get grpBCancel => '[Çåñçéł ~~]';

  @override
  String get grpBOk => '[ÖĶ ]';

  @override
  String get grpBClose => '[Çłöšé ~]';

  @override
  String get grpBSave => '[Šåṽé ~]';

  @override
  String get grpBRetry => '[Ŕéţŕý ~]';

  @override
  String get grpBRestore => '[Ŕéšţöŕé ~~]';

  @override
  String get grpBHistory => '[Ĥíšţöŕý ~~]';

  @override
  String get grpBCopy => '[Çöþý ~]';

  @override
  String get grpBSaveAsFile => '[Šåṽé åš ƒíłé ~~~~]';

  @override
  String get grpBReply => '[Ŕéþłý ~]';

  @override
  String get grpBEdit => '[Éðíţ ~]';

  @override
  String get grpBDelete => '[Ðéłéţé ~~]';

  @override
  String get grpBBack => '[ßåçķ ~]';

  @override
  String get grpBSomeone => '[Šöɱéöñé ~~]';

  @override
  String get grpBYou => '[Ýöû ~]';

  @override
  String get grpBLoading => '[Łöåðíñĝ… ~~]';

  @override
  String get grpBPages => '[Þåĝéš ~]';

  @override
  String get grpBRestricted => '[Ŕéšţŕíçţéð ~~~]';

  @override
  String get grpBLinkTitle => '[Łíñķ ~]';

  @override
  String get grpBLinkAddressLabel =>
      '[Åððŕéšš (ĥţţþ, ĥţţþš öŕ ɱåíłţö) ~~~~~~~~~~]';

  @override
  String get grpBLinkInvalid =>
      '[Ûšé åñ ĥţţþ, ĥţţþš öŕ ɱåíłţö åððŕéšš. ~~~~~~~~~~~~]';

  @override
  String get grpBIconTitle => '[Þåĝé íçöñ ~~~]';

  @override
  String get grpBIconLabel =>
      '[Éɱöĵí öŕ šĥöŕţ ţéxţ (éɱþţý ƒöŕ ñöñé) ~~~~~~~~~~~~]';

  @override
  String get grpBIconInvalid => '[Ûšé åţ ɱöšţ ƒöûŕ çĥåŕåçţéŕš. ~~~~~~~~~]';

  @override
  String get grpBImageTitle => '[Íɱåĝé ~]';

  @override
  String get grpBImageAddressLabel =>
      '[Íɱåĝé åððŕéšš (ĥţţþ öŕ ĥţţþš) ~~~~~~~~~]';

  @override
  String get grpBDescription => '[Ðéšçŕíþţíöñ ~~~]';

  @override
  String get grpBImageInvalid => '[Ûšé åñ ĥţţþ öŕ ĥţţþš åððŕéšš. ~~~~~~~~~]';

  @override
  String get grpBEmbedTaskTitle => '[Éɱƀéð å ţåšķ ~~~~]';

  @override
  String get grpBTaskSearchLabel =>
      '[Šéåŕçĥ ţåšķš öŕ þåšţé å ţåšķ łíñķ ~~~~~~~~~~~]';

  @override
  String get grpBUsePastedTask => '[Ûšé ţĥé þåšţéð ţåšķ ~~~~~~]';

  @override
  String get grpBSnippetRemoved => '[(ŕéɱöṽéð) ~~~]';

  @override
  String get grpBConflictTitle => '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš þåĝé ~~~~~~~~~~]';

  @override
  String get grpBConflictClean =>
      '[Ţĥéíŕ çĥåñĝéš ðö ñöţ öṽéŕłåþ ŵíţĥ ýöûŕš. Ţĥéý ŵíłł ƀé ɱéŕĝéð. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpBConflictOverlap =>
      '[ßöţĥ öƒ ýöû çĥåñĝéð ţĥéšé ƀłöçķš. Çĥööšé ŵĥíçĥ ţö ķééþ; éṽéŕýţĥíñĝ éłšé íš ɱéŕĝéð. ~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpBConflictBlock(String snippet) {
    return '[ßłöçķ: $snippet ~~~~~]';
  }

  @override
  String grpBConflictMine(String snippet) {
    return '[Míñé: $snippet ~~~~~]';
  }

  @override
  String grpBConflictTheirs(String snippet) {
    return '[Ţĥéíŕš: $snippet ~~~~~]';
  }

  @override
  String get grpBDecideLater => '[Ðéçíðé łåţéŕ ~~~~]';

  @override
  String get grpBDiscardMine => '[Ðíšçåŕð ɱíñé ~~~~]';

  @override
  String get grpBApplyAndSave => '[Åþþłý åñð šåṽé ~~~~]';

  @override
  String get grpBShareTitle => '[Þåĝé åççéšš ~~~]';

  @override
  String get grpBShareRestrict => '[Ŕéšţŕíçţ ţĥíš þåĝé ~~~~~~]';

  @override
  String get grpBShareRestrictedHint =>
      '[Öñłý ţĥé þéöþłé ƀéłöŵ, íţš çŕéåţöŕ åñð þåĝé ɱåñåĝéŕš (åłšö ƒöŕ ţĥé þåĝéš ûñðéŕ íţ). ~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpBShareOpenHint =>
      '[Éṽéŕýöñé ŵĥö çåñ öþéñ ţĥé þåŕéñţ çåñ öþéñ íţ. ~~~~~~~~~~~~~~~]';

  @override
  String get grpBShareNeedPermission =>
      '[Ýöû ñééð þéŕɱíššíöñ \"ðöç.ɱåñåĝé\" ţö çĥåñĝé ţĥíš. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpBEmptyPage => '[(éɱþţý þåĝé) ~~~~]';

  @override
  String grpBImageBlock(String alt) {
    return '[[Íɱåĝé $alt] ~~~~]';
  }

  @override
  String get grpBTaskCardBlock => '[[Ţåšķ çåŕð] ~~~]';

  @override
  String get grpBAllRevisions => '[Åłł ŕéṽíšíöñš ~~~~]';

  @override
  String get grpBNoRevisions => '[Ñö ŕéṽíšíöñš ýéţ. ~~~~~]';

  @override
  String grpBVersionN(int version) {
    return '[Ṽéŕšíöñ $version ~~~~~]';
  }

  @override
  String grpBVersionShort(int version) {
    return '[ṽ$version ~~~]';
  }

  @override
  String get grpBRevisionsLoadFailed =>
      '[Çöûłð ñöţ łöåð ĥíšţöŕý. Ŕéţŕý ~~~~~~~~~]';

  @override
  String get grpBRevisionLoadFailed =>
      '[Çöûłð ñöţ łöåð ţĥíš ŕéṽíšíöñ. ~~~~~~~~~]';

  @override
  String get grpBRestoreVersion => '[Ŕéšţöŕé ţĥíš ṽéŕšíöñ ~~~~~~]';

  @override
  String grpBLinkedFrom(int count) {
    return '[Łíñķéð ƒŕöɱ ($count) ~~~~~~~]';
  }

  @override
  String get grpBNoBacklinks => '[Ñö þåĝé ɱéñţíöñš ţĥíš öñé. ~~~~~~~~]';

  @override
  String grpBMarkdownTitle(String title) {
    return '[Måŕķðöŵñ: $title ~~~~~]';
  }

  @override
  String get grpBMarkdownCopied => '[Måŕķðöŵñ çöþíéð. ~~~~~]';

  @override
  String get grpBSaveSaved => '[Šåṽéð ~]';

  @override
  String get grpBSaveDirty => '[Ûñšåṽéð çĥåñĝéš ~~~~~]';

  @override
  String get grpBSaveSaving => '[Šåṽíñĝ... ~~~]';

  @override
  String get grpBSaveError => '[Çöûłð ñöţ šåṽé ~~~~]';

  @override
  String get grpBSaveConflict => '[Çöñƒłíçţ: çĥööšé ŵĥåţ ţö ķééþ ~~~~~~~~~]';

  @override
  String get grpBDocsCrumb => '[Ðöçš ~]';

  @override
  String get grpBDocNotFound =>
      '[Ţĥíš þåĝé ðöéš ñöţ éxíšţ, öŕ ýöû çåññöţ öþéñ íţ. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpBBackToAllPages => '[ßåçķ ţö åłł þåĝéš ~~~~~]';

  @override
  String get grpBArchivedBanner =>
      '[Ţĥíš þåĝé íš åŕçĥíṽéð. Íţ íš ŕéåð-öñłý. ~~~~~~~~~~~~~]';

  @override
  String get grpBConflictBanner =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš þåĝé. Ýöûŕ çĥåñĝéš åŕé ñöţ šåṽéð ýéţ. ~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpBResolve => '[Ŕéšöłṽé ~~]';

  @override
  String get grpBRemoteBanner =>
      '[Å ñéŵéŕ ṽéŕšíöñ ŵåš šåṽéð ƀý šöɱéöñé éłšé. Íţ ŵíłł ƀé ɱéŕĝéð ŵĥéñ ýöû šåṽé. ~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpBIsEditing(String name) {
    return '[$name íš éðíţíñĝ ~~~~~]';
  }

  @override
  String grpBAreEditing(String names) {
    return '[$names åŕé éðíţíñĝ ~~~~~~]';
  }

  @override
  String get grpBChangeIcon => '[Çĥåñĝé íçöñ ~~~]';

  @override
  String get grpBUntitled => '[Ûñţíţłéð ~~]';

  @override
  String get grpBReadOnly => '[Ŕéåð öñłý ~~~]';

  @override
  String get grpBAccess => '[Åççéšš ~~]';

  @override
  String get grpBExportMarkdown => '[Éxþöŕţ Måŕķðöŵñ ~~~~~]';

  @override
  String grpBMoveUnder(String name) {
    return '[Möṽé \"$name\" ûñðéŕ ~~~~~~]';
  }

  @override
  String get grpBTopLevel => '[Ţöþ łéṽéł ~~~]';

  @override
  String get grpBCollapse => '[Çöłłåþšé ~~]';

  @override
  String get grpBExpand => '[Éxþåñð ~~]';

  @override
  String get grpBPageOptions => '[Þåĝé öþţíöñš ~~~~]';

  @override
  String get grpBNewSubpage => '[Ñéŵ šûƀþåĝé ~~~]';

  @override
  String get grpBMoveUp => '[Möṽé ûþ ~~]';

  @override
  String get grpBMoveDown => '[Möṽé ðöŵñ ~~~]';

  @override
  String get grpBMoveTo => '[Möṽé ţö... ~~~]';

  @override
  String get grpBArchive => '[Åŕçĥíṽé ~~]';

  @override
  String get grpBHideArchived => '[Ĥíðé åŕçĥíṽéð ~~~~]';

  @override
  String get grpBShowArchived => '[Šĥöŵ åŕçĥíṽéð ~~~~]';

  @override
  String get grpBNewPage => '[Ñéŵ þåĝé ~~]';

  @override
  String get grpBNoPagesYet => '[Ñö þåĝéš ýéţ. ~~~~]';

  @override
  String get grpBPagesLoadFailed => '[Çöûłð ñöţ łöåð þåĝéš. Ŕéţŕý ~~~~~~~~~]';

  @override
  String get grpBToday => '[Ţöðåý ~]';

  @override
  String get grpBYesterday => '[Ýéšţéŕðåý ~~~]';

  @override
  String get grpBSubtaskCreated => '[Šûƀţåšķ çŕéåţéð. ~~~~~]';

  @override
  String get grpBComments => '[Çöɱɱéñţš ~~]';

  @override
  String grpBCommentsCount(int count) {
    return '[Çöɱɱéñţš ($count) ~~~~~~]';
  }

  @override
  String get grpBNoComments => '[Ñö çöɱɱéñţš ýéţ. ~~~~~]';

  @override
  String get grpBLoadEarlier => '[Łöåð éåŕłíéŕ çöɱɱéñţš ~~~~~~~]';

  @override
  String get grpBPinned => '[Þíññéð ~~]';

  @override
  String get grpBReplyHint => '[Ŕéþłý… ~~]';

  @override
  String get grpBArchivedReadOnly =>
      '[Ţĥíš þŕöĵéçţ íš åŕçĥíṽéð: çöɱɱéñţš åŕé ŕéåð-öñłý. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpBReadOnlyComments =>
      '[Ýöû çåñ ŕéåð çöɱɱéñţš ƀûţ ñöţ ŵŕíţé ţĥéɱ. ~~~~~~~~~~~~~]';

  @override
  String get grpBCommentRemoved => '[Çöɱɱéñţ ŕéɱöṽéð ~~~~~]';

  @override
  String get grpBUnpin => '[Ûñþíñ ~]';

  @override
  String get grpBPin => '[Þíñ ~]';

  @override
  String get grpBMakeSubtask => '[Måķé å šûƀţåšķ ~~~~]';

  @override
  String get grpBEditHistory => '[Éðíţ ĥíšţöŕý ~~~~]';

  @override
  String grpBEditedTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Éðíţéð $count ţíɱéš: ţåþ ţö šéé ţĥé ĥíšţöŕý',
      one: 'Éðíţéð öñçé: ţåþ ţö šéé ţĥé ĥíšţöŕý',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpBEdited => '[éðíţéð ~~]';

  @override
  String get grpBCommentActions => '[Çöɱɱéñţ åçţíöñš ~~~~~]';

  @override
  String get grpBWaitingToSend => '[Ŵåíţíñĝ ţö ƀé šéñţ ~~~~~~]';

  @override
  String get grpBSending => '[Šéñðíñĝ… ~~]';

  @override
  String get grpBNotSent => '[Ñöţ šéñţ ~~]';

  @override
  String get grpBDiscard => '[Ðíšçåŕð ~~]';

  @override
  String get grpBAddReaction => '[Åðð å ŕéåçţíöñ ~~~~]';

  @override
  String get grpBAuditAll => '[Åłł ~]';

  @override
  String get grpBAuditTasks => '[Ţåšķš ~]';

  @override
  String get grpBAuditFiles => '[Fíłéš ~]';

  @override
  String get grpBAuditProjects => '[Þŕöĵéçţš ~~]';

  @override
  String get grpBAuditMembers => '[Méɱƀéŕš ~~]';

  @override
  String get grpBAuditRoles => '[Ŕöłéš ~]';

  @override
  String get grpBAuditInvitations => '[Íñṽíţåţíöñš ~~~]';

  @override
  String get grpBAuditSignIn => '[Šíĝñ-íñ ~~]';

  @override
  String get grpBAuditTitle => '[Åûðíţ łöĝ ~~~]';

  @override
  String get grpBExportCsv => '[Éxþöŕţ åš ÇŠṼ ~~~~]';

  @override
  String get grpBAuditDenied =>
      '[Ýöû åŕé ñöţ åłłöŵéð ţö ŕéåð ţĥé åûðíţ łöĝ. ~~~~~~~~~~~~~~]';

  @override
  String get grpBAuditEmpty =>
      '[Ñöţĥíñĝ ŕéçöŕðéð ƒöŕ ţĥéšé ƒíłţéŕš. ~~~~~~~~~~~]';

  @override
  String get grpBShowOlder => '[Šĥöŵ öłðéŕ ~~~]';

  @override
  String get grpBAnyone => '[Åñýöñé ~~]';

  @override
  String get grpBAnyProject => '[Åñý þŕöĵéçţ ~~~]';

  @override
  String get grpBAnyTime => '[Åñý ţíɱé ~~]';

  @override
  String get grpBClearFilters => '[Çłéåŕ ƒíłţéŕš ~~~~]';

  @override
  String get grpBBulkChange => '[Þåŕţ öƒ å ƀûłķ çĥåñĝé ~~~~~~~]';

  @override
  String grpBCharacters(String size) {
    return '[($size çĥåŕåçţéŕš) ~~~~~~]';
  }

  @override
  String get grpBNoFieldChanges => '[Ñö ƒíéłð çĥåñĝéš ŕéçöŕðéð. ~~~~~~~~]';

  @override
  String get grpBAuditExportTitle => '[Åûðíţ łöĝ (ÇŠṼ) ~~~~~]';

  @override
  String grpBAuditExportNote(int shown, int total) {
    return '[Šĥöŵíñĝ ţĥé ƒíŕšţ $shown öƒ $total łíñéš. Çöþý öŕ Šåṽé ĥåš åłł öƒ ţĥéɱ. ~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpBCsvCopied => '[ÇŠṼ çöþíéð. ~~~]';

  @override
  String get grpCCancel => '[Çåñçéł ~~]';

  @override
  String get grpCDelete => '[Ðéłéţé ~~]';

  @override
  String get grpCRetry => '[Ŕéţŕý ~]';

  @override
  String get grpCBack => '[ßåçķ ~]';

  @override
  String get grpCUndo => '[Ûñðö ~]';

  @override
  String get grpCField => '[Fíéłð ~]';

  @override
  String get grpCStatus => '[Šţåţûš ~~]';

  @override
  String get grpCComment => '[Çöɱɱéñţ ~~]';

  @override
  String get grpCValue => '[Ṽåłûé ~]';

  @override
  String get grpCDashNew => '[Ñéŵ ðåšĥƀöåŕð ~~~~]';

  @override
  String grpCDashDeleteTitle(String name) {
    return '[Ðéłéţé “$name”? ~~~~~]';
  }

  @override
  String get grpCDashDeleteBody =>
      '[Íţš ŵíðĝéţš ĝö ŵíţĥ íţ. Ţĥíš çåññöţ ƀé ûñðöñé. ~~~~~~~~~~~~~~~]';

  @override
  String get grpCDashTitle => '[Ðåšĥƀöåŕðš ~~~]';

  @override
  String grpCDashTitleProject(String project) {
    return '[Ðåšĥƀöåŕðš · $project ~~~~~~~]';
  }

  @override
  String get grpCDashEmpty => '[Ñö ðåšĥƀöåŕðš ýéţ. ~~~~~~]';

  @override
  String get grpCDashBlankDashboard => '[ßłåñķ ðåšĥƀöåŕð ~~~~~]';

  @override
  String get grpCDashProjectOverview => '[Þŕöĵéçţ öṽéŕṽíéŵ ~~~~~]';

  @override
  String get grpCDashMyWork => '[Mý ŵöŕķ ~~]';

  @override
  String get grpCDashBlank => '[ßłåñķ ~]';

  @override
  String get grpCDashEdit => '[Éðíţ ~]';

  @override
  String get grpCDashRefresh => '[Ŕéƒŕéšĥ ~~]';

  @override
  String get grpCDashAddWidget => '[Åðð ŵíðĝéţ ~~~]';

  @override
  String get grpCDashSave => '[Šåṽé ~]';

  @override
  String get grpCDashDialogTitle => '[Ðåšĥƀöåŕð ~~~]';

  @override
  String get grpCDashName => '[Ñåɱé ~]';

  @override
  String get grpCDashShareDenied =>
      '[Šĥåŕíñĝ ñééðš ţĥé ðåšĥƀöåŕð.ɱåñåĝé þéŕɱíššíöñ. ~~~~~~~~~~~~~~~]';

  @override
  String get grpCDashOk => '[ÖĶ ]';

  @override
  String get grpCImpTitle => '[Íɱþöŕţ åñð éxþöŕţ ~~~~~]';

  @override
  String get grpCImpExport => '[Éxþöŕţ ~~]';

  @override
  String get grpCImpDenied =>
      '[Öñłý åðɱíñš çåñ íɱþöŕţ åñð éxþöŕţ ðåţå. ~~~~~~~~~~~~~]';

  @override
  String get grpCImpPast => '[Þåšţ íɱþöŕţš ~~~~]';

  @override
  String get grpCImpNothing => '[Ñöţĥíñĝ íɱþöŕţéð ýéţ. ~~~~~~~]';

  @override
  String grpCImpTasksCount(int count) {
    return '[$count ţåšķš ~~~~]';
  }

  @override
  String get grpCImpResume => '[Ŕéšûɱé ~~]';

  @override
  String get grpCImpContinue => '[Çöñţíñûé ~~]';

  @override
  String get grpCImpForget => '[Föŕĝéţ ~~]';

  @override
  String get grpCImpUndoTitle => '[Ûñðö ţĥíš íɱþöŕţ? ~~~~~]';

  @override
  String get grpCImpUndoBody =>
      '[Ţĥíš ŕéɱöṽéš ŵĥåţ íţ ɱåðé. Åñýţĥíñĝ ýöû åððéð ƀý ĥåñð íš ķéþţ. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCImpUndoConfirm => '[Ûñðö íɱþöŕţ ~~~]';

  @override
  String grpCImpClaimTitle(String name) {
    return '[Ĝíṽé $name\'š ţåšķš ţö... ~~~~~~~~]';
  }

  @override
  String get grpCImpChooseMember => '[Çĥööšé å ɱéɱƀéŕ ~~~~~]';

  @override
  String get grpCImpAssign => '[Åššíĝñ ~~]';

  @override
  String grpCImpAssigned(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Åššíĝñéð $n ţåšķš.',
      one: 'Åššíĝñéð $n ţåšķ.',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpWaiting => '[Þéöþłé ŵåíţíñĝ ţö ĵöíñ ~~~~~~~]';

  @override
  String get grpCImpWaitingBody =>
      '[Ţĥéíŕ ţåšķš åŕé åššíĝñéð åûţöɱåţíçåłłý ŵĥéñ šöɱéöñé ĵöíñš ŵíţĥ ţĥé šåɱé éɱåíł. ~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCImpNoEmail => '[ñö éɱåíł ~~]';

  @override
  String grpCImpPersonSub(String email, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ţåšķš',
      one: '$count ţåšķ',
    );
    return '[$email · $_temp0 ~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpAssignTo => '[Åššíĝñ ţö... ~~~~]';

  @override
  String get grpCImpStepSource => '[Šöûŕçé ~~]';

  @override
  String get grpCImpStepUpload => '[Ûþłöåð ~~]';

  @override
  String get grpCImpStepMap => '[Måþ ~]';

  @override
  String get grpCImpStepReview => '[Ŕéṽíéŵ ~~]';

  @override
  String get grpCImpStepImport => '[Íɱþöŕţ ~~]';

  @override
  String get grpCImpWhere => '[Ŵĥéŕé íš ýöûŕ ðåţå çöɱíñĝ ƒŕöɱ? ~~~~~~~~~~]';

  @override
  String get grpCImpAuto =>
      '[Í åɱ ñöţ šûŕé: ŵöŕķ íţ öûţ ƒŕöɱ ţĥé ƒíłé ~~~~~~~~~~~~~]';

  @override
  String get grpCImpNext => '[Ñéxţ ~]';

  @override
  String get grpCImpZipSeveral =>
      '[Ţĥíš žíþ ĥöłðš šéṽéŕåł ðåţå ƒíłéš. Ŵĥíçĥ öñé ðö ýöû ŵåñţ ţö íɱþöŕţ? (Å ŵöŕķšþåçé éxþöŕţ ĥåš öñé þéŕ þŕöĵéçţ.) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCImpChooseAFile => '[Çĥööšé å ƒíłé ~~~~]';

  @override
  String get grpCImpChooseGeneric =>
      '[Çĥööšé ţĥé ƒíłé ţö íɱþöŕţ (.çšṽ, .ĵšöñ, öŕ å .žíþ öƒ öñé). ~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpCImpChooseSource(String source) {
    return '[Çĥööšé ýöûŕ $source ƒíłé (.çšṽ, .ĵšöñ, öŕ å .žíþ öƒ öñé). ~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpSentNote =>
      '[Ţĥé ƒíłé íš šéñţ ţö ýöûŕ ŢåšķFöŕĝé šéŕṽéŕ åñð ŕéåð åš å šţŕéåɱ, šö łåŕĝé éxþöŕţš åŕé ƒíñé. Ñöţĥíñĝ íš çĥåñĝéð ûñţíł ýöû çöñƒíŕɱ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCImpPickFile => '[Çĥööšé ƒíłé ~~~]';

  @override
  String get grpCImpResumeThis => '[Ŕéšûɱé ţĥíš íɱþöŕţ ~~~~~~]';

  @override
  String get grpCImpWhatHappens => '[Ţĥíš íš ŵĥåţ ŵíłł ĥåþþéñ ~~~~~~~~]';

  @override
  String get grpCImpCountTasks => '[ţåšķš ~]';

  @override
  String get grpCImpCountSubtasks => '[öƒ ţĥéɱ šûƀ-ţåšķš ~~~~~]';

  @override
  String get grpCImpCountComments => '[çöɱɱéñţš ~~]';

  @override
  String get grpCImpCountLinks => '[łíñķš ~]';

  @override
  String get grpCImpCountSprints => '[šþŕíñţš ~~]';

  @override
  String get grpCImpCountLabels => '[łåƀéłš ~~]';

  @override
  String get grpCImpCountStatuses => '[ñéŵ šţåţûšéš ~~~~]';

  @override
  String get grpCImpCountPlaceholders => '[þéöþłé ţö ŵåíţ ƒöŕ ~~~~~~]';

  @override
  String grpCImpAlready(int count) {
    return '[$count öƒ ţĥéšé ŵéŕé íɱþöŕţéð ƀéƒöŕé åñð ŵíłł ƀé šķíþþéð, ñöţ ðûþłíçåţéð. ~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpCImpRowErrors(int count) {
    return '[$count ŕöŵ(š) çåññöţ ƀé íɱþöŕţéð åñð ŵíłł ƀé łéƒţ öûţ. ~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpResumeImport => '[Ŕéšûɱé íɱþöŕţ ~~~~]';

  @override
  String get grpCImpStart => '[Šţåŕţ íɱþöŕţ ~~~~]';

  @override
  String get grpCImpUndoRunBody =>
      '[Ţĥíš ŕéɱöṽéš ţĥé ţåšķš, çöɱɱéñţš, łíñķš, šþŕíñţš åñð šţåţûšéš ţĥíš íɱþöŕţ ɱåðé. Åñýţĥíñĝ ýöû åððéð ţö ţĥéɱ ƀý ĥåñð íš ķéþţ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCImpWaitingStart => '[Ŵåíţíñĝ ţö šţåŕţ... ~~~~~~]';

  @override
  String get grpCImpLinking => '[Łíñķíñĝ ţåšķš... ~~~~~]';

  @override
  String grpCImpProgress(int done, int total) {
    return '[$done öƒ $total ţåšķš ~~~~~~~]';
  }

  @override
  String get grpCImpCancel => '[Çåñçéł íɱþöŕţ ~~~~]';

  @override
  String get grpCImpFinished => '[Íɱþöŕţ ƒíñíšĥéð ~~~~~]';

  @override
  String get grpCImpUndone => '[Íɱþöŕţ ûñðöñé ~~~~]';

  @override
  String get grpCImpCancelled => '[Íɱþöŕţ çåñçéłłéð ~~~~~]';

  @override
  String get grpCImpStopped => '[Íɱþöŕţ šţöþþéð ~~~~]';

  @override
  String get grpCImpOpenProject => '[Öþéñ ţĥé þŕöĵéçţ ~~~~~]';

  @override
  String get grpCImpAnother => '[Íɱþöŕţ åñöţĥéŕ ƒíłé ~~~~~~]';

  @override
  String grpCImpRemoved(num tasks) {
    return '[Ŕéɱöṽéð $tasks ţåšķš. ~~~~~~~]';
  }

  @override
  String grpCImpRemovedKept(num tasks, num kept) {
    return '[Ŕéɱöṽéð $tasks ţåšķš, ķéþţ $kept ţĥåţ ĥåṽé ýöûŕ öŵñ šûƀ-ţåšķš. ~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpTheFile => '[ţĥé ƒíłé ~~]';

  @override
  String grpCImpSummary(int issues, int comments, int links, String file) {
    return '[$issues ţåšķš, $comments çöɱɱéñţš, $links łíñķš ƒöûñð íñ $file. ~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpCImpSummarySub(
    int issues,
    int subtasks,
    int comments,
    int links,
    String file,
  ) {
    return '[$issues ţåšķš ($subtasks šûƀ-ţåšķš), $comments çöɱɱéñţš, $links łíñķš ƒöûñð íñ $file. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpPriUrgent => '[Ûŕĝéñţ ~~]';

  @override
  String get grpCImpPriHigh => '[Ĥíĝĥ ~]';

  @override
  String get grpCImpPriNormal => '[Ñöŕɱåł ~~]';

  @override
  String get grpCImpPriLow => '[Łöŵ ~]';

  @override
  String get grpCImpPriNone => '[Ñöñé ~]';

  @override
  String get grpCImpFTitle => '[Ţíţłé * ~~]';

  @override
  String get grpCImpFDescription => '[Ðéšçŕíþţíöñ ~~~]';

  @override
  String get grpCImpFPriority => '[Þŕíöŕíţý ~~]';

  @override
  String get grpCImpFAssignee => '[Åššíĝñéé ~~]';

  @override
  String get grpCImpFReporter => '[Ŕéþöŕţéŕ ~~]';

  @override
  String get grpCImpFCreated => '[Çŕéåţéð ~~]';

  @override
  String get grpCImpFUpdated => '[Ûþðåţéð ~~]';

  @override
  String get grpCImpFStart => '[Šţåŕţ ðåţé ~~~]';

  @override
  String get grpCImpFDue => '[Ðûé ðåţé ~~]';

  @override
  String get grpCImpFLabels => '[Łåƀéłš ~~]';

  @override
  String get grpCImpFSprint => '[Šþŕíñţ ~~]';

  @override
  String get grpCImpFParent => '[Þåŕéñţ (íð) ~~~]';

  @override
  String get grpCImpFId => '[Íð ]';

  @override
  String get grpCImpFKey => '[Ķéý ~]';

  @override
  String get grpCImpFPoints => '[Šţöŕý þöíñţš ~~~~]';

  @override
  String get grpCImpFEstimate => '[Éšţíɱåţé ~~]';

  @override
  String get grpCImpFType => '[Ţýþé ~]';

  @override
  String get grpCImpPriorities => '[Þŕíöŕíţíéš ~~~]';

  @override
  String grpCImpKeepLabels(int count) {
    return '[Ķééþ $count łåƀéłš ~~~~~~]';
  }

  @override
  String get grpCImpKeepLabelsSub =>
      '[Åš å \"Łåƀéłš\" ƒíéłð öñ éṽéŕý ţåšķ. ~~~~~~~~~~~]';

  @override
  String grpCImpSprintsCreated(String sprints) {
    return '[Šþŕíñţš ţĥåţ ŵíłł ƀé çŕéåţéð: $sprints ~~~~~~~~~~~~~]';
  }

  @override
  String get grpCImpReview => '[Ŕéṽíéŵ ~~]';

  @override
  String get grpCImpReadAs => '[Ŕéåð åš ~~]';

  @override
  String get grpCImpZipFile => '[Fíłé íñšíðé ţĥé žíþ ~~~~~~]';

  @override
  String get grpCImpChooseOne => '[Çĥööšé öñé ~~~]';

  @override
  String get grpCImpInto => '[Íɱþöŕţ íñţö ~~~]';

  @override
  String get grpCImpNewProject => '[Å ñéŵ þŕöĵéçţ ~~~~]';

  @override
  String get grpCImpExistingProject => '[Åñ éxíšţíñĝ þŕöĵéçţ ~~~~~~]';

  @override
  String get grpCImpProjectName => '[Þŕöĵéçţ ñåɱé ~~~~]';

  @override
  String get grpCImpColumns => '[Çöłûɱñš ~~]';

  @override
  String get grpCImpNotInFile => '[(ñöţ íñ ţĥé ƒíłé) ~~~~~]';

  @override
  String get grpCImpStatuses => '[Šţåţûšéš ~~]';

  @override
  String get grpCImpSameName => '[Šåɱé ñåɱé (çŕéåţé íƒ ɱíššíñĝ) ~~~~~~~~~]';

  @override
  String get grpCImpPeople => '[Þéöþłé ~~]';

  @override
  String get grpCImpNotMember =>
      '[Ñöţ å ɱéɱƀéŕ ýéţ (åššíĝñ ŵĥéñ ţĥéý ĵöíñ) ~~~~~~~~~~~~~]';

  @override
  String get grpCImpUnassigned => '[Łéåṽé ûñåššíĝñéð ~~~~~]';

  @override
  String get grpCImpFirst200 =>
      '[Öñłý ţĥé ƒíŕšţ 200 þéöþłé åŕé łíšţéð; ţĥé ŕéšţ ŵåíţ åš þłåçéĥöłðéŕš. ~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpCAutoDeleteTitle(String name) {
    return '[Ðéłéţé \"$name\"? ~~~~~]';
  }

  @override
  String get grpCAutoDeleteBody =>
      '[Ţĥé ŕûłé šţöþš ƒöŕ ĝööð. Íţš ŕûñ ĥíšţöŕý íš ðéłéţéð ţöö. ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCAutoTitle => '[Åûţöɱåţíöñš ~~~]';

  @override
  String grpCAutoTitleProject(String project) {
    return '[Åûţöɱåţíöñš · $project ~~~~~~~]';
  }

  @override
  String get grpCAutoMissing => '[Þŕöĵéçţ ñöţ ƒöûñð. ~~~~~~]';

  @override
  String get grpCAutoRules => '[Ŕûłéš ~]';

  @override
  String get grpCAutoRunHistory => '[Ŕûñ ĥíšţöŕý ~~~]';

  @override
  String get grpCAutoNew => '[Ñéŵ åûţöɱåţíöñ ~~~~]';

  @override
  String get grpCAutoReadOnly => '[Ŕéåð öñłý ~~~]';

  @override
  String grpCAutoLimit(int limit) {
    return '[Łíɱíţ öƒ $limit ŕûłéš ŕéåçĥéð. ~~~~~~~~~~]';
  }

  @override
  String grpCAutoRuleFilter(String name) {
    return '[Ŕûłé: $name ~~~~]';
  }

  @override
  String get grpCAutoEmpty =>
      '[Ñö åûţöɱåţíöñš ýéţ. Å ŕûłé šåýš: ŵĥéñ šöɱéţĥíñĝ ĥåþþéñš, åñð íƒ íţ ɱåţçĥéš, ţĥéñ ðö ţĥéšé ţĥíñĝš. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpCAutoWhen(String trigger, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count åçţíöñš',
      one: '$count åçţíöñ',
    );
    return '[Ŵĥéñ $trigger · $_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpCAutoNeverRun => '[Ñéṽéŕ ŕûñ ~~~]';

  @override
  String get grpCAutoHistory => '[Ĥíšţöŕý ~~]';

  @override
  String get grpCAutoDryRun => '[Ðŕý ŕûñ ~~]';

  @override
  String get grpCAutoStatusChanges => '[å šţåţûš çĥåñĝéš ~~~~~]';

  @override
  String grpCAutoMovesTo(String status) {
    return '[å ţåšķ ɱöṽéš ţö $status ~~~~~~~~]';
  }

  @override
  String grpCAutoFieldChanges(String field) {
    return '[$field çĥåñĝéš ~~~~~]';
  }

  @override
  String get grpCAutoSomeoneAssigned => '[šöɱéöñé íš åššíĝñéð ~~~~~~]';

  @override
  String grpCAutoUserAssigned(String user) {
    return '[$user íš åššíĝñéð ~~~~~~]';
  }

  @override
  String get grpCAutoDueReached => '[å ðûé ðåţé íš ŕéåçĥéð ~~~~~~~]';

  @override
  String grpCAutoDaysBefore(int days) {
    return '[$days ðåýš ƀéƒöŕé å ðûé ðåţé ~~~~~~~~~]';
  }

  @override
  String get grpCAutoDeletedStatus => '[Ðéłéţéð šţåţûš ~~~~]';

  @override
  String get grpCAutoUnknownPerson => '[Ûñķñöŵñ þéŕšöñ ~~~~]';

  @override
  String get grpCAutoEvent => '[Éṽéñţ ~]';

  @override
  String get grpCAutoMovesToLabel => '[Möṽéš ţö ~~]';

  @override
  String get grpCAutoAnyStatus => '[Åñý šţåţûš ~~~]';

  @override
  String get grpCAutoAssignedPerson => '[Åššíĝñéð þéŕšöñ ~~~~~]';

  @override
  String get grpCAutoAnyone => '[Åñýöñé ~~]';

  @override
  String grpCAutoDaysLabel(int max) {
    return '[Ðåýš ƀéƒöŕé ţĥé ðûé ðåţé (0 ţö $max) ~~~~~~~~~~~~]';
  }

  @override
  String grpCAutoTokensHelp(String tokens) {
    return '[Ýöû ɱåý ûšé $tokens ~~~~~~]';
  }

  @override
  String get grpCAutoDateHint => '[ÝÝÝÝ-MM-ÐÐ ~~~]';

  @override
  String grpCAutoUseToken(String token) {
    return '[Ûšé $token ~~~]';
  }

  @override
  String get grpCAutoHow => '[Ĥöŵ ~]';

  @override
  String get grpCAutoReplaceAssignees => '[Ŕéþłåçé åššíĝñééš ŵíţĥ ~~~~~~~]';

  @override
  String get grpCAutoAdd => '[Åðð ~]';

  @override
  String get grpCAutoRemoveEveryone => '[Ŕéɱöṽé éṽéŕýöñé ~~~~~]';

  @override
  String get grpCAutoSubtaskTitle => '[Šûƀţåšķ ţíţłé ~~~~]';

  @override
  String get grpCAutoMessage => '[Méššåĝé ~~]';

  @override
  String get grpCAutoAddress => '[Åððŕéšš ~~]';

  @override
  String get grpCAutoAddressHelp =>
      '[Þûƀłíç ĥţţþ(š) åððŕéššéš öñłý; þŕíṽåţé öñéš åŕé ŕéƒûšéð. ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpCAutoMethod => '[Méţĥöð ~~]';

  @override
  String get grpCAutoDoThis => '[Ðö ţĥíš ~~]';

  @override
  String grpDActionFailed(String error) {
    return '[Ţĥåţ ðíð ñöţ ŵöŕķ ($error). ~~~~~~~~~]';
  }

  @override
  String get grpDSwitchWorkspace => '[Šŵíţçĥ ŵöŕķšþåçé ~~~~~]';

  @override
  String grpDWorkspaceHere(String name) {
    return '[$name (ĥéŕé) ~~~~]';
  }

  @override
  String get grpDNewDoc => '[Ñéŵ ðöç ~~]';

  @override
  String get grpDTitle => '[Ţíţłé ~]';

  @override
  String get grpDUntitled => '[Ûñţíţłéð ~~]';

  @override
  String get grpDNewDashboard => '[Ñéŵ ðåšĥƀöåŕð ~~~~]';

  @override
  String get grpDNewSprint => '[Ñéŵ šþŕíñţ ~~~]';

  @override
  String grpDStatusOf(String id) {
    return '[Šţåţûš öƒ $id ~~~~]';
  }

  @override
  String get grpDNewTask => '[Ñéŵ ţåšķ ~~]';

  @override
  String get grpDCancel => '[Çåñçéł ~~]';

  @override
  String get grpDCreate => '[Çŕéåţé ~~]';

  @override
  String get grpDSort => '[Šöŕţ ~]';

  @override
  String get grpDNoSort => '[Ñö šöŕţ ~~]';

  @override
  String grpDSortBy(String names) {
    return '[Šöŕţ: $names ~~~~]';
  }

  @override
  String get grpDGroup => '[Ĝŕöûþ ~]';

  @override
  String get grpDNoGrouping => '[Ñö ĝŕöûþíñĝ ~~~]';

  @override
  String grpDGroupBy(String name) {
    return '[Ĝŕöûþ: $name ~~~~]';
  }

  @override
  String get grpDColumns => '[Çöłûɱñš ~~]';

  @override
  String get grpDRefresh => '[Ŕéƒŕéšĥ ~~]';

  @override
  String get grpDLayoutNotSaved =>
      '[Ýöûŕ łåýöûţ çöûłð ñöţ ƀé šåṽéð. Íţ ŵíłł ƀé ţŕíéð åĝåíñ öñ ýöûŕ ñéxţ çĥåñĝé. ~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpDLayouts => '[Łåýöûţš ~~]';

  @override
  String get grpDResetLayout => '[Ŕéšéţ ɱý łåýöûţ ~~~~~]';

  @override
  String get grpDShareLayoutMenu => '[Šĥåŕé ţĥíš łåýöûţ… ~~~~~~]';

  @override
  String grpDDeleteShared(String name) {
    return '[Ðéłéţé šĥåŕéð “$name” ~~~~~~~]';
  }

  @override
  String grpDDeleteSharedTitle(String name) {
    return '[Ðéłéţé “$name”? ~~~~~]';
  }

  @override
  String get grpDDeleteSharedBody =>
      '[Íţ ðíšåþþéåŕš ƒöŕ éṽéŕýöñé öñ ţĥíš þŕöĵéçţ. ~~~~~~~~~~~~~~]';

  @override
  String get grpDDelete => '[Ðéłéţé ~~]';

  @override
  String grpDDeletedNamed(String name) {
    return '[Ðéłéţéð “$name” ~~~~~]';
  }

  @override
  String grpDSharedNamed(String name) {
    return '[Šĥåŕéð “$name” ~~~~~]';
  }

  @override
  String get grpDShareLayoutTitle => '[Šĥåŕé ţĥíš łåýöûţ ~~~~~]';

  @override
  String get grpDName => '[Ñåɱé ~]';

  @override
  String get grpDShare => '[Šĥåŕé ~]';

  @override
  String get grpDTaskNotFound => '[Ţåšķ ñöţ ƒöûñð. ~~~~~]';

  @override
  String get grpDDeleteTask => '[Ðéłéţé ţåšķ ~~~]';

  @override
  String get grpDClose => '[Çłöšé ~]';

  @override
  String get grpDPriority => '[Þŕíöŕíţý ~~]';

  @override
  String get grpDStart => '[Šţåŕţ ~]';

  @override
  String get grpDDue => '[Ðûé ~]';

  @override
  String get grpDAssignees => '[Åššíĝñééš ~~~]';

  @override
  String get grpDDescription => '[Ðéšçŕíþţíöñ ~~~]';

  @override
  String grpDTaskDeleted(String id) {
    return '[$id ðéłéţéð ~~~~]';
  }

  @override
  String get grpDUndo => '[Ûñðö ~]';

  @override
  String get grpDStatus => '[Šţåţûš ~~]';

  @override
  String grpDClearField(String label) {
    return '[Çłéåŕ $label ~~~~]';
  }

  @override
  String get grpDDueTime => '[Ðûé ţíɱé (ýöûŕ çłöçķ) ~~~~~~~]';

  @override
  String get grpDClearDueTime => '[Çłéåŕ ðûé ţíɱé ~~~~]';

  @override
  String get grpDAllOf => '[Åłł öƒ ~~]';

  @override
  String get grpDAnyOf => '[Åñý öƒ ~~]';

  @override
  String get grpDNot => '[ÑÖŢ ~]';

  @override
  String get grpDRemoveGroup => '[Ŕéɱöṽé ĝŕöûþ ~~~~]';

  @override
  String get grpDCondition => '[Çöñðíţíöñ ~~~]';

  @override
  String get grpDFieldRemoved => '[Fíéłð (ŕéɱöṽéð) ~~~~~]';

  @override
  String get grpDRemoveCondition => '[Ŕéɱöṽé çöñðíţíöñ ~~~~~]';

  @override
  String get grpDOpBefore => '[íš ƀéƒöŕé ~~~]';

  @override
  String get grpDOpOnOrBefore => '[íš öñ öŕ ƀéƒöŕé ~~~~~]';

  @override
  String get grpDOpAfter => '[íš åƒţéŕ ~~]';

  @override
  String get grpDOpOnOrAfter => '[íš öñ öŕ åƒţéŕ ~~~~]';

  @override
  String get grpDOpLessThan => '[íš łéšš ţĥåñ ~~~~]';

  @override
  String get grpDOpAtMost => '[íš åţ ɱöšţ ~~~]';

  @override
  String get grpDOpMoreThan => '[íš ɱöŕé ţĥåñ ~~~~]';

  @override
  String get grpDOpAtLeast => '[íš åţ łéåšţ ~~~]';

  @override
  String get grpDYes => '[Ýéš ~]';

  @override
  String get grpDNo => '[Ñö ]';

  @override
  String get grpDCurrentSprint => '[ţĥé çûŕŕéñţ šþŕíñţ ~~~~~~]';

  @override
  String get grpDMe => '[Mé ]';

  @override
  String get grpDChoose => '[Çĥööšé… ~~]';

  @override
  String get grpDValue => '[Ṽåłûé ~]';

  @override
  String get grpDPickDate => '[Þíçķ å ðåţé ~~~]';

  @override
  String get grpDOrderByLabel => '[Öŕðéŕ ƀý  ~~~]';

  @override
  String get grpDAscending => '[Åšçéñðíñĝ ~~~]';

  @override
  String get grpDDescending => '[Ðéšçéñðíñĝ ~~~]';

  @override
  String get grpDRemoveOrdering => '[Ŕéɱöṽé öŕðéŕíñĝ ~~~~~]';

  @override
  String get grpDOrderBy => '[Öŕðéŕ ƀý ~~]';

  @override
  String get grpDRepeatNothingToUpdate =>
      '[Ñéŵ ţåšķš ŵíłł ûšé ţĥíš öñé. Ñö öþéñ ţåšķ ñééðéð çĥåñĝíñĝ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpDRepeatUpdatedLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ţåšķš',
      one: 'ţåšķ',
    );
    return '[Ûþðåţéð $count öþéñ łåţéŕ $_temp0. ~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpDRepeat => '[Ŕéþéåţ ~~]';

  @override
  String grpDRepeatUnsupported(String summary) {
    return '[\"$summary\" ŵåš šéţ íñ å ŵåý ţĥíš éðíţöŕ çåññöţ šĥöŵ, šö íţ çåññöţ ƀé çĥåñĝéð ĥéŕé. Ýöû çåñ šţíłł þåûšé öŕ šţöþ íţ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpDSkipWeekends => '[Šķíþ ŵééķéñðš ~~~~]';

  @override
  String get grpDStopRepeating => '[Šţöþ ŕéþéåţíñĝ ~~~~]';

  @override
  String get grpDResume => '[Ŕéšûɱé ~~]';

  @override
  String get grpDPause => '[Þåûšé ~]';

  @override
  String get grpDUseForFuture => '[Ûšé ţĥíš ţåšķ ƒöŕ ƒûţûŕé öñéš ~~~~~~~~~]';

  @override
  String get grpDSave => '[Šåṽé ~]';

  @override
  String get grpDEvery => '[Éṽéŕý ~]';

  @override
  String get grpDRepeatByDay => '[Öñ å ðåý öƒ ţĥé ɱöñţĥ ~~~~~~~]';

  @override
  String get grpDRepeatByWeekday => '[Öñ ţĥé ñţĥ ŵééķðåý ~~~~~~]';

  @override
  String grpDDayNumber(int day) {
    return '[Ðåý $day ~~~]';
  }

  @override
  String get grpDNth1 => '[1šţ ~]';

  @override
  String get grpDNth2 => '[2ñð ~]';

  @override
  String get grpDNth3 => '[3ŕð ~]';

  @override
  String get grpDNth4 => '[4ţĥ ~]';

  @override
  String get grpDNthLast => '[łåšţ ~]';

  @override
  String get grpDEnds => '[Éñðš ~]';

  @override
  String get grpDEndNever => '[Ñéṽéŕ ~]';

  @override
  String get grpDEndAfter => '[Åƒţéŕ ~]';

  @override
  String get grpDEndOn => '[Öñ ]';

  @override
  String get grpDTasksWord => '[ţåšķš ~]';

  @override
  String get grpDMakeIt => '[Måķé íţ ~~]';

  @override
  String get grpDDaysAhead => '[ðåýš åĥéåð öƒ íţš ðûé ðåţé ~~~~~~~~]';

  @override
  String grpDRepeatAt(String time) {
    return '[Åţ $time ~~~]';
  }

  @override
  String get grpDNoFurtherDates => '[Ñö ƒûŕţĥéŕ ðåţéš. ~~~~~]';

  @override
  String grpDNextDates(String dates) {
    return '[Ñéxţ: $dates ~~~~]';
  }

  @override
  String get grpEBack => '[ßåçķ ~]';

  @override
  String get grpECancel => '[Çåñçéł ~~]';

  @override
  String get grpEName => '[Ñåɱé ~]';

  @override
  String get grpERetry => '[Ŕéţŕý ~]';

  @override
  String get grpEWorkspaceSettingsTitle => '[Ŵöŕķšþåçé šéţţíñĝš ~~~~~~]';

  @override
  String get grpEWorkspacesLoadRetry =>
      '[Çöûłð ñöţ łöåð ýöûŕ ŵöŕķšþåçéš. Ŕéţŕý ~~~~~~~~~~~~]';

  @override
  String get grpEMembers => '[Méɱƀéŕš ~~]';

  @override
  String get grpEMembersSub => '[Þéöþłé, íñṽíţåţíöñš åñð łéåṽíñĝ ~~~~~~~~~~]';

  @override
  String get grpERolesPerms => '[Ŕöłéš åñð þéŕɱíššíöñš ~~~~~~~]';

  @override
  String get grpERolesPermsSub => '[Ŵĥö çåñ ðö ŵĥåţ ~~~~~]';

  @override
  String get grpEAuditLog => '[Åûðíţ łöĝ ~~~]';

  @override
  String get grpEAuditLogSub => '[Ŵĥö çĥåñĝéð ŵĥåţ, åñð ŵĥéñ ~~~~~~~~]';

  @override
  String get grpEImportExport => '[Íɱþöŕţ åñð éxþöŕţ ~~~~~]';

  @override
  String get grpEImportExportSub =>
      '[ßŕíñĝ íñ Ĵíŕå, ÇłíçķÛþ öŕ ÇŠṼ ðåţå; ţåķé íţ öûţ ~~~~~~~~~~~~~~~]';

  @override
  String get grpEWorkspaceUpdated => '[Ŵöŕķšþåçé ûþðåţéð. ~~~~~~]';

  @override
  String get grpEGeneral => '[Ĝéñéŕåł ~~]';

  @override
  String get grpEChangeLogo => '[Çĥåñĝé łöĝö ~~~]';

  @override
  String get grpEUrl => '[ÛŔŁ ~]';

  @override
  String get grpERefresh => '[Ŕéƒŕéšĥ ~~]';

  @override
  String get grpESaveChanges => '[Šåṽé çĥåñĝéš ~~~~]';

  @override
  String get grpENotifSettings => '[Ñöţíƒíçåţíöñ šéţţíñĝš ~~~~~~~]';

  @override
  String get grpEPushOffNotice =>
      '[Ñöţíƒíçåţíöñš åŕé öƒƒ ƒöŕ ţĥíš ðéṽíçé. Ýöû çåñ åłłöŵ ţĥéɱ íñ ţĥé šýšţéɱ šéţţíñĝš; ţĥé çĥöíçé íš šåṽéð. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpEZoneInvalid =>
      '[Ûšé å ñåɱé łíķé Éûŕöþé/Þåŕíš öŕ ÛŢÇ. ~~~~~~~~~~~~]';

  @override
  String get grpEQuietDifferent =>
      '[Šţåŕţ åñð éñð ɱûšţ ƀé ðíƒƒéŕéñţ ţíɱéš. ~~~~~~~~~~~~]';

  @override
  String get grpEWhatReachesYou => '[Ŵĥåţ ŕéåçĥéš ýöû ~~~~~]';

  @override
  String get grpEInbox => '[Íñƀöx ~]';

  @override
  String get grpEPush => '[Þûšĥ ~]';

  @override
  String get grpEEmail => '[Éɱåíł ~]';

  @override
  String get grpEQuietHours => '[Qûíéţ ĥöûŕš ~~~]';

  @override
  String get grpEQuietHold =>
      '[Ĥöłð þûšĥ åñð éɱåíł ðûŕíñĝ qûíéţ ĥöûŕš ~~~~~~~~~~~~]';

  @override
  String get grpEQuietHoldSub =>
      '[Ţĥé íñƀöx åłŵåýš ƒíłłš; öñłý þíñĝš ŵåíţ. ~~~~~~~~~~~~~]';

  @override
  String get grpEFrom => '[Fŕöɱ ~]';

  @override
  String get grpEUntil => '[Ûñţíł ~]';

  @override
  String get grpETimeZoneDigest => '[Ţíɱé žöñé åñð ðíĝéšţ ~~~~~~]';

  @override
  String get grpETimeZone => '[Ţíɱé žöñé ~~~]';

  @override
  String get grpETimeZoneHelper =>
      '[Qûíéţ ĥöûŕš åñð ţĥé ðíĝéšţ ƒöłłöŵ ţĥíš žöñé. ~~~~~~~~~~~~~~]';

  @override
  String get grpEUseDeviceZone => '[Ûšé ţĥíš ðéṽíçé’š ţíɱé žöñé ~~~~~~~~~]';

  @override
  String get grpETypeZone =>
      '[Ţýþé ýöûŕ ţíɱé žöñé íñšţéåð, é.ĝ. Éûŕöþé/Þåŕíš. ~~~~~~~~~~~~~~~]';

  @override
  String get grpEDigestAt => '[Ðåíłý ðíĝéšţ íš šéñţ åţ ~~~~~~~]';

  @override
  String get grpEEditField => '[Éðíţ ƒíéłð ~~~]';

  @override
  String get grpENewField => '[Ñéŵ ƒíéłð ~~~]';

  @override
  String get grpEType => '[Ţýþé ~]';

  @override
  String get grpEOptions => '[Öþţíöñš ~~]';

  @override
  String get grpEColour => '[Çöłöûŕ ~~]';

  @override
  String get grpELabel => '[Łåƀéł ~]';

  @override
  String get grpERemoveOption => '[Ŕéɱöṽé öþţíöñ ~~~~]';

  @override
  String get grpEAddOption => '[Åðð öþţíöñ ~~~]';

  @override
  String get grpERequired => '[Ŕéqûíŕéð ~~]';

  @override
  String get grpERequiredSub => '[Ñéŵ ţåšķš ɱûšţ ĥåṽé å ṽåłûé. ~~~~~~~~~]';

  @override
  String get grpEDefaultValue => '[Ðéƒåûłţ ṽåłûé ~~~~]';

  @override
  String get grpEShowIn => '[Šĥöŵ íñ ~~]';

  @override
  String get grpESave => '[Šåṽé ~]';

  @override
  String get grpEAddField => '[Åðð ƒíéłð ~~~]';

  @override
  String get grpEOptionN => '[Öþţíöñ 1 ~~]';

  @override
  String get grpEProblemName => '[Ĝíṽé ţĥé ƒíéłð å ñåɱé. ~~~~~~~]';

  @override
  String get grpEProblemOne => '[Åðð åţ łéåšţ öñé öþţíöñ. ~~~~~~~~]';

  @override
  String get grpEProblemLabel => '[Éṽéŕý öþţíöñ ñééðš å łåƀéł. ~~~~~~~~~]';

  @override
  String get grpEProblemDup => '[Ţŵö öþţíöñš ĥåṽé ţĥé šåɱé łåƀéł. ~~~~~~~~~~]';

  @override
  String get grpEOptionsInUse => '[Öþţíöñš åŕé íñ ûšé ~~~~~~]';

  @override
  String get grpERemovedOption => '[Ŕéɱöṽéð öþţíöñ ~~~~]';

  @override
  String grpERemapLabel(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ṽåłûéš',
      one: '1 ṽåłûé',
    );
    return '[$label ($_temp0) ƀéçöɱéš ~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpENothingClear => '[Ñöţĥíñĝ (çłéåŕ) ~~~~~]';

  @override
  String get grpEApply => '[Åþþłý ~]';

  @override
  String get grpEPrivate => '[Þŕíṽåţé ~~]';

  @override
  String get grpESprints => '[Šþŕíñţš ~~]';

  @override
  String get grpEAutomations => '[Åûţöɱåţíöñš ~~~]';

  @override
  String get grpESearch => '[Šéåŕçĥ ~~]';

  @override
  String get grpETimesheet => '[Ţíɱéšĥééţ ~~~]';

  @override
  String get grpEDashboards => '[Ðåšĥƀöåŕðš ~~~]';

  @override
  String get grpEDocs => '[Ðöçš ~]';

  @override
  String get grpEProjects => '[Þŕöĵéçţš ~~]';

  @override
  String get grpENewProject => '[Ñéŵ þŕöĵéçţ ~~~]';

  @override
  String get grpEFavorites => '[Fåṽöŕíţéš ~~~]';

  @override
  String get grpEProjectsLoadRetry =>
      '[Çöûłð ñöţ łöåð þŕöĵéçţš. Ŕéţŕý ~~~~~~~~~~]';

  @override
  String get grpEArchivedProjects => '[Åŕçĥíṽéð þŕöĵéçţš ~~~~~]';

  @override
  String get grpEPrivateProjects => '[Þŕíṽåţé þŕöĵéçţš ~~~~~]';

  @override
  String get grpENoProjects => '[Ñö þŕöĵéçţš ýéţ ~~~~~]';

  @override
  String get grpECreateFirstProject => '[Çŕéåţé ýöûŕ ƒíŕšţ þŕöĵéçţ ~~~~~~~~]';

  @override
  String get grpEMonth1 => '[Ĵåñûåŕý ~~]';

  @override
  String get grpEMonth2 => '[Féƀŕûåŕý ~~]';

  @override
  String get grpEMonth3 => '[Måŕçĥ ~]';

  @override
  String get grpEMonth4 => '[Åþŕíł ~]';

  @override
  String get grpEMonth5 => '[Måý ~]';

  @override
  String get grpEMonth6 => '[Ĵûñé ~]';

  @override
  String get grpEMonth7 => '[Ĵûłý ~]';

  @override
  String get grpEMonth8 => '[Åûĝûšţ ~~]';

  @override
  String get grpEMonth9 => '[Šéþţéɱƀéŕ ~~~]';

  @override
  String get grpEMonth10 => '[Öçţöƀéŕ ~~]';

  @override
  String get grpEMonth11 => '[Ñöṽéɱƀéŕ ~~]';

  @override
  String get grpEMonth12 => '[Ðéçéɱƀéŕ ~~]';

  @override
  String get grpEWeekLocale => '[Łöçåłé ðéƒåûłţ ~~~~]';

  @override
  String get grpEMonday => '[Möñðåý ~~]';

  @override
  String get grpESaturday => '[Šåţûŕðåý ~~]';

  @override
  String get grpESunday => '[Šûñðåý ~~]';

  @override
  String get grpEPrevious => '[Þŕéṽíöûš ~~]';

  @override
  String get grpENext => '[Ñéxţ ~]';

  @override
  String get grpEToday => '[Ţöðåý ~]';

  @override
  String get grpEUnscheduled => '[Ûñšçĥéðûłéð ~~~]';

  @override
  String get grpEMonth => '[Möñţĥ ~]';

  @override
  String get grpEWeek => '[Ŵééķ ~]';

  @override
  String get grpEDay => '[Ðåý ~]';

  @override
  String get grpEColourBy => '[Çöłöûŕ ƀý ~~~]';

  @override
  String get grpEColourByProject => '[Çöłöûŕ ƀý þŕöĵéçţ ~~~~~]';

  @override
  String get grpEColourByStatus => '[Çöłöûŕ ƀý šţåţûš ~~~~~]';

  @override
  String get grpEColourByPriority => '[Çöłöûŕ ƀý þŕíöŕíţý ~~~~~~]';

  @override
  String get grpEColourChip => '[Çöłöûŕ ~~]';

  @override
  String get grpEWeekStartsOn => '[Ŵééķ šţåŕţš öñ ~~~~]';

  @override
  String get grpEHideDone => '[Ĥíðé ðöñé ~~~]';

  @override
  String get grpELayoutNotSaved =>
      '[Ýöûŕ çåłéñðåŕ łåýöûţ çöûłð ñöţ ƀé šåṽéð. Íţ ŵíłł ƀé ţŕíéð åĝåíñ öñ ýöûŕ ñéxţ çĥåñĝé. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpEEnterName => '[Éñţéŕ å ñåɱé. ~~~~]';

  @override
  String get grpENewRole => '[Ñéŵ ŕöłé ~~]';

  @override
  String get grpECreate => '[Çŕéåţé ~~]';

  @override
  String get grpERenameRole => '[Ŕéñåɱé ŕöłé ~~~]';

  @override
  String get grpERename => '[Ŕéñåɱé ~~]';

  @override
  String grpEDeleteRoleTitle(String name) {
    return '[Ðéłéţé \"$name\"? ~~~~~]';
  }

  @override
  String get grpERoleNoOne => '[Ñö öñé ĥåš ţĥíš ŕöłé. ~~~~~~~]';

  @override
  String grpERoleMoveMembers(int count) {
    return '[$count ɱéɱƀéŕ(š) ĥåṽé ţĥíš ŕöłé. Möṽé ţĥéɱ ţö: ~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpEChooseRole => '[Çĥööšé å ŕöłé ~~~~]';

  @override
  String get grpEDelete => '[Ðéłéţé ~~]';

  @override
  String grpFBulkDeleted(int count) {
    return '[$count ţåšķš ðéłéţéð ~~~~~~~]';
  }

  @override
  String grpFBulkUpdated(int count) {
    return '[$count ţåšķš ûþðåţéð ~~~~~~~]';
  }

  @override
  String grpFBulkPartialDeleted(int done, int total, int failed) {
    return '[$done öƒ $total ţåšķš ðéłéţéð; $failed çöûłð ñöţ ƀé. ~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpFBulkPartialUpdated(int done, int total, int failed) {
    return '[$done öƒ $total ţåšķš ûþðåţéð; $failed çöûłð ñöţ ƀé. ~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpFDetails => '[Ðéţåíłš ~~]';

  @override
  String grpFBulkDeleteTitle(int count) {
    return '[Ðéłéţé $count ţåšķš? ~~~~~~~]';
  }

  @override
  String get grpFBulkDeleteBody =>
      '[Ţĥéíŕ šûƀţåšķš ĝö ŵíţĥ ţĥéɱ. Ýöû çåñ ŕéšţöŕé ţĥéɱ ƒŕöɱ ţĥé ţŕåšĥ. ~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpFDelete => '[Ðéłéţé ~~]';

  @override
  String get grpFSetStatus => '[Šéţ šţåţûš ~~~]';

  @override
  String get grpFSetPriority => '[Šéţ þŕíöŕíţý ~~~~]';

  @override
  String get grpFStatus => '[Šţåţûš ~~]';

  @override
  String get grpFPriority => '[Þŕíöŕíţý ~~]';

  @override
  String get grpFAssign => '[Åššíĝñ ~~]';

  @override
  String get grpFClear => '[Çłéåŕ ~]';

  @override
  String grpFBulkUpdating(int done, int total) {
    return '[Ûþðåţíñĝ $done öƒ $total… ~~~~~~~~~]';
  }

  @override
  String grpFBulkSelected(int count) {
    return '[$count šéłéçţéð ~~~~~]';
  }

  @override
  String grpFBulkNotChanged(int count) {
    return '[$count ţåšķš ñöţ çĥåñĝéð ~~~~~~~~]';
  }

  @override
  String get grpFTask => '[Ţåšķ ~]';

  @override
  String get grpFLinks => '[Łíñķš ~]';

  @override
  String get grpFAddLink => '[Åðð å łíñķ ~~~]';

  @override
  String get grpFNoLinks => '[Ñö łíñķš ýéţ. ~~~~]';

  @override
  String get grpFRemoveLink => '[Ŕéɱöṽé łíñķ ~~~]';

  @override
  String get grpFLinkSearchHint => '[Šéåŕçĥ ţåšķš íñ åñý þŕöĵéçţ ~~~~~~~~~]';

  @override
  String get grpFCloseDuplicate => '[Çłöšé ţĥé ðûþłíçåţé ~~~~~~]';

  @override
  String get grpFLinkAction => '[Łíñķ ~]';

  @override
  String get grpFUnassigned => '[Ûñåššíĝñéð ~~~]';

  @override
  String get grpFNoValue => '[Ñö ṽåłûé ~~]';

  @override
  String get grpFAssignee => '[Åššíĝñéé ~~]';

  @override
  String grpFPresenceEditing(String name) {
    return '[$name íš éðíţíñĝ ~~~~~]';
  }

  @override
  String grpFPresenceViewing(String name) {
    return '[$name íš ṽíéŵíñĝ ~~~~~]';
  }

  @override
  String grpFEditingOne(String name) {
    return '[$name íš éðíţíñĝ ţĥíš ~~~~~~~]';
  }

  @override
  String grpFEditingMany(int count) {
    return '[$count þéöþłé åŕé éðíţíñĝ ţĥíš ~~~~~~~~~~]';
  }

  @override
  String grpFDeleteTaskTitle(String id) {
    return '[Ðéłéţé $id? ~~~~]';
  }

  @override
  String grpFDeleteSubtasksExplain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Íţ ĥåš $count šûƀţåšķš. Ŵĥåţ šĥöûłð ĥåþþéñ ţö ţĥéɱ?',
      one: 'Íţ ĥåš 1 šûƀţåšķ. Ŵĥåţ šĥöûłð ĥåþþéñ ţö íţ?',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpFKeepSubtasks => '[Ķééþ ţĥéɱ (ɱöṽé ûþ å łéṽéł) ~~~~~~~~~]';

  @override
  String get grpFDeleteThemToo => '[Ðéłéţé ţĥéɱ ţöö ~~~~~]';

  @override
  String grpFOpenSubtasksTitle(String id) {
    return '[$id ĥåš öþéñ šûƀţåšķš ~~~~~~~]';
  }

  @override
  String grpFOpenSubtasksExplain(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count šûƀţåšķš åŕé ñöţ ƒíñíšĥéð. Möṽé ţĥéɱ ţö $status ţöö?',
      one: '1 šûƀţåšķ íš ñöţ ƒíñíšĥéð. Möṽé íţ ţö $status ţöö?',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpFLeaveOpen => '[Łéåṽé ţĥéɱ öþéñ ~~~~~]';

  @override
  String get grpFCompleteAll => '[Çöɱþłéţé åłł ~~~~]';

  @override
  String grpFMoveUnderTitle(String id) {
    return '[Möṽé $id ûñðéŕ… ~~~~~]';
  }

  @override
  String get grpFTopLevel => '[Ţöþ łéṽéł (ñö þåŕéñţ) ~~~~~~~]';

  @override
  String get grpFNoOtherParent =>
      '[Ţĥéŕé íš ñö öţĥéŕ ţåšķ ţö þûţ íţ ûñðéŕ. ~~~~~~~~~~~~~]';

  @override
  String get grpFSubtasks => '[Šûƀţåšķš ~~]';

  @override
  String get grpFAddSubtaskHint => '[Åðð å šûƀţåšķ åñð þŕéšš Éñţéŕ ~~~~~~~~~]';

  @override
  String get grpFActionAddSubtask => '[Åðð šûƀţåšķ ~~~]';

  @override
  String get grpFActionMoveUnder => '[Möṽé ûñðéŕ… ~~~]';

  @override
  String get grpFActionMakeTopLevel => '[Måķé ţöþ łéṽéł ~~~~]';

  @override
  String get grpFBlockedByPending =>
      '[ßłöçķéð ƀý ţåšķš ţĥåţ åŕé ñöţ ðöñé ýéţ ~~~~~~~~~~~~]';

  @override
  String grpFBlockedBy(String names) {
    return '[ßłöçķéð ƀý $names ~~~~~~]';
  }

  @override
  String get grpFBlocked => '[ßłöçķéð ~~]';

  @override
  String get grpFBlockedTitle => '[Ţĥíš ţåšķ íš ƀłöçķéð ~~~~~~]';

  @override
  String grpFBlockedTextOne(String blockers) {
    return '[Íţ íš ƀłöçķéð ƀý $blockers, ŵĥíçĥ íš ñöţ ðöñé ýéţ. ~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpFBlockedTextMany(String blockers) {
    return '[Íţ íš ƀłöçķéð ƀý $blockers, ŵĥíçĥ åŕé ñöţ ðöñé ýéţ. ~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpFOk => '[ÖĶ ]';

  @override
  String get grpFCompleteAnyway => '[Çöɱþłéţé åñýŵåý ~~~~~]';

  @override
  String grpFConflictTitle(String field) {
    return '[Šöɱéöñé çĥåñĝéð ţĥé $field ~~~~~~~~~]';
  }

  @override
  String get grpFTheirs => '[Ţĥéíŕš ~~]';

  @override
  String get grpFYours => '[Ýöûŕš ~]';

  @override
  String get grpFEmpty => '[(éɱþţý) ~~]';

  @override
  String get grpFTakeTheirs => '[Ţåķé ţĥéíŕš ~~~]';

  @override
  String get grpFKeepMine => '[Ķééþ ɱíñé ~~~]';

  @override
  String get grpFFieldTitle => '[ţíţłé ~]';

  @override
  String get grpFFieldDescription => '[ðéšçŕíþţíöñ ~~~]';

  @override
  String get grpFFieldStatus => '[šţåţûš ~~]';

  @override
  String get grpFFieldPriority => '[þŕíöŕíţý ~~]';

  @override
  String get grpFFieldStartDate => '[šţåŕţ ðåţé ~~~]';

  @override
  String get grpFFieldDueDate => '[ðûé ðåţé ~~]';

  @override
  String get grpFFieldAssignees => '[åššíĝñééš ~~~]';

  @override
  String get grpFFields => '[Fíéłðš ~~]';

  @override
  String get grpFRequiredFieldsIntro =>
      '[Ţĥéšé ƒíéłðš ñééð å ṽåłûé ƀéƒöŕé ţĥé ţåšķ íš çŕéåţéð. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpFRequired => '[Ŕéqûíŕéð ~~]';

  @override
  String get grpFCreate => '[Çŕéåţé ~~]';

  @override
  String get grpFChangeStatus => '[Çĥåñĝé šţåţûš ~~~~]';

  @override
  String get grpFChangePriority => '[Çĥåñĝé þŕíöŕíţý ~~~~~]';

  @override
  String get grpFDate => '[Ðåţé ~]';

  @override
  String get grpFPickDay => '[Þíçķ å ðåý… ~~~]';

  @override
  String get grpFAssignees => '[Åššíĝñééš ~~~]';

  @override
  String get grpFViewList => '[Łíšţ ~]';

  @override
  String get grpFViewBoard => '[ßöåŕð ~]';

  @override
  String get grpFViewTimeline => '[Ţíɱéłíñé ~~]';

  @override
  String grpFErrorRetry(String message) {
    return '[$message Ŕéţŕý ~~~~~]';
  }

  @override
  String get grpFNoTasksYet =>
      '[Ñö ţåšķš ýéţ. Åðð ţĥé ƒíŕšţ öñé åƀöṽé. ~~~~~~~~~~~~]';

  @override
  String get grpFSwipeComplete => '[Çöɱþłéţé ~~]';

  @override
  String get grpFUndo => '[Ûñðö ~]';

  @override
  String get grpFMore => '[Möŕé ~]';

  @override
  String grpFAddSubtaskTo(String id) {
    return '[Åðð å šûƀţåšķ ţö $id ~~~~~~~]';
  }

  @override
  String grpFTaskDeleted(String id) {
    return '[$id ðéłéţéð ~~~~]';
  }

  @override
  String get grpFColTitle => '[Ţíţłé ~]';

  @override
  String grpFTrashTitle(String name) {
    return '[$name · Ţŕåšĥ ~~~~]';
  }

  @override
  String get grpFTrashEmpty => '[Ţĥé ţŕåšĥ íš éɱþţý. ~~~~~~]';

  @override
  String grpFTrashedRow(String id) {
    return '[$id · ðéłéţéð ~~~~]';
  }

  @override
  String get grpFRestore => '[Ŕéšţöŕé ~~]';

  @override
  String grpFTaskRestored(String id) {
    return '[$id ŕéšţöŕéð ~~~~]';
  }

  @override
  String get grpFMoveTo => '[Möṽé ţö… ~~]';

  @override
  String grpFMoveToColumn(String name) {
    return '[Möṽé ţö $name ~~~~]';
  }

  @override
  String grpFPlusCount(int count) {
    return '[+$count ~~]';
  }

  @override
  String get grpFFoldColumn => '[Föłð ţĥé çöłûɱñ ~~~~~]';

  @override
  String get grpFColumn => '[Çöłûɱñ ~~]';

  @override
  String get grpFSetWipLimit => '[Šéţ å ŵöŕķ-íñ-þŕöĝŕéšš łíɱíţ… ~~~~~~~~~]';

  @override
  String get grpFChangeLimit => '[Çĥåñĝé ţĥé łíɱíţ… ~~~~~]';

  @override
  String get grpFAddTask => '[Åðð å ţåšķ ~~~]';

  @override
  String get grpFWipTitle => '[Ŵöŕķ-íñ-þŕöĝŕéšš łíɱíţ ~~~~~~~]';

  @override
  String get grpFWipMost => '[Möšţ çåŕðš ţĥíš çöłûɱñ šĥöûłð ĥöłð ~~~~~~~~~~~]';

  @override
  String get grpFColumnsBy => '[Çöłûɱñš ƀý ~~~]';

  @override
  String grpFColumnsChip(String name) {
    return '[Çöłûɱñš: $name ~~~~~]';
  }

  @override
  String get grpFSwimlanes => '[Šŵíɱłåñéš ~~~]';

  @override
  String get grpFLanesAssignee => '[Łåñéš: åššíĝñéé ~~~~~]';

  @override
  String get grpFNoSwimlanes => '[Ñö šŵíɱłåñéš ~~~~]';

  @override
  String get grpFByAssignee => '[ßý åššíĝñéé ~~~]';

  @override
  String get grpFCardFields => '[Çåŕð ƒíéłðš ~~~]';

  @override
  String get grpFCurrentSprint => '[Çûŕŕéñţ šþŕíñţ ~~~~]';

  @override
  String get grpFRefresh => '[Ŕéƒŕéšĥ ~~]';

  @override
  String get grpFBoardLayoutNotSaved =>
      '[Ýöûŕ ƀöåŕð łåýöûţ çöûłð ñöţ ƀé šåṽéð. Íţ ŵíłł ƀé ţŕíéð åĝåíñ öñ ýöûŕ ñéxţ çĥåñĝé. ~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpFReschedule => '[Ŕéšçĥéðûłé… ~~~]';

  @override
  String get grpFSchedule => '[Šçĥéðûłé… ~~~]';

  @override
  String get grpFRepeatsNotMade => '[Ŕéþéåţš: ñöţ ɱåðé ýéţ ~~~~~~~]';

  @override
  String get grpFEverythingDated => '[Éṽéŕýţĥíñĝ ĥåš å ðåţé. ~~~~~~~]';

  @override
  String grpFNothingOn(String day) {
    return '[Ñöţĥíñĝ öñ $day. ~~~~~]';
  }

  @override
  String get grpFKindTasks => '[Ţåšķš ~]';

  @override
  String get grpFKindComments => '[Çöɱɱéñţš ~~]';

  @override
  String get grpFKindProjects => '[Þŕöĵéçţš ~~]';

  @override
  String get grpFKindPeople => '[Þéöþłé ~~]';

  @override
  String get grpFKindPages => '[Þåĝéš ~]';

  @override
  String get grpFChipAssignedToMe => '[Åššíĝñéð ţö ɱé ~~~~]';

  @override
  String get grpFChipOpen => '[Öþéñ ~]';

  @override
  String get grpFChipDone => '[Ðöñé ~]';

  @override
  String get grpFSearchErrGeneric =>
      '[Šöɱéţĥíñĝ ŵéñţ ŵŕöñĝ. Ţŕý åĝåíñ. ~~~~~~~~~~]';

  @override
  String get grpFSearchErrNetwork =>
      '[Çöûłð ñöţ ŕéåçĥ ţĥé šéŕṽéŕ. Çĥéçķ ýöûŕ çöññéçţíöñ. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpFSearchErrDenied =>
      '[Ýöû ðö ñöţ ĥåṽé åççéšš ţö šéåŕçĥ ĥéŕé. ~~~~~~~~~~~~]';

  @override
  String get grpFSearchErrRate =>
      '[Ţöö ɱåñý šéåŕçĥéš. Ŵåíţ å ɱöɱéñţ. ~~~~~~~~~~~]';

  @override
  String get grpFSearchErrInvalid => '[Ţĥåţ šéåŕçĥ íš ñöţ ṽåłíð. ~~~~~~~~]';

  @override
  String get grpFSearchHint =>
      '[Šéåŕçĥ ţåšķš, çöɱɱéñţš, þŕöĵéçţš, þéöþłé ~~~~~~~~~~~~~]';

  @override
  String get grpFSearchClose => '[Çłöšé šéåŕçĥ ~~~~]';

  @override
  String get grpFSearchNothing =>
      '[Ñöţĥíñĝ ƒöûñð. Ţŕý ƒéŵéŕ ŵöŕðš, öŕ åñ íð łíķé ŴÉß-12. Ñåŕŕöŵ ŵíţĥ íñ:ĶÉÝ, åššíĝñéé:ɱé, šţåţûš:öþéñ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpFSearchTips =>
      '[Ţýþé ţö šéåŕçĥ. Ţŕý åñ íð łíķé ŴÉß-12, öŕ öþéŕåţöŕš: íñ:ĶÉÝ, åššíĝñéé:ɱé, šţåţûš:öþéñ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpFGoTo => '[Ĝö ţö ~]';

  @override
  String grpFShowMore(String kind) {
    return '[Šĥöŵ ɱöŕé $kind ~~~~~]';
  }

  @override
  String get grpFRecent => '[Ŕéçéñţ ~~]';

  @override
  String grpFPlusMore(int count) {
    return '[+$count ɱöŕé ~~~~]';
  }

  @override
  String get grpFSubtaskDepthLimit =>
      '[Šûƀţåšķš åŕé ñéšţéð åš ðééþ åš ţĥé åþþ åłłöŵš ĥéŕé. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpFUnscheduled => '[Ûñšçĥéðûłéð ~~~]';

  @override
  String get grpGCloseShortcuts => '[Çłöšé ţĥé ķéýƀöåŕð šĥöŕţçûţš ~~~~~~~~~]';

  @override
  String get grpGKeyboardShortcuts => '[Ķéýƀöåŕð šĥöŕţçûţš ~~~~~~]';

  @override
  String get grpGClose => '[Çłöšé ~]';

  @override
  String get grpGChangedByYou => '[Çĥåñĝéð ƀý ýöû ~~~~]';

  @override
  String get grpGNone => '[ñöñé ~]';

  @override
  String grpGChangeKeysFor(String title) {
    return '[Çĥåñĝé ţĥé ķéýš ƒöŕ $title ~~~~~~~~~]';
  }

  @override
  String grpGKeysFor(String title) {
    return '[Ķéýš ƒöŕ $title ~~~~~]';
  }

  @override
  String get grpGPressKeys => '[Þŕéšš ţĥé ķéýš ýöû ŵåñţ. ~~~~~~~~]';

  @override
  String get grpGUseDefault => '[Ûšé ðéƒåûłţ ~~~]';

  @override
  String get grpGNoKey => '[Ñö ķéý ~~]';

  @override
  String get grpGCancel => '[Çåñçéł ~~]';

  @override
  String get grpGSave => '[Šåṽé ~]';

  @override
  String grpGBrowserKeeps(String keys) {
    return '[Ţĥé ƀŕöŵšéŕ ķééþš $keys. ~~~~~~~~]';
  }

  @override
  String grpGAlreadyUsedBy(String title) {
    return '[Åłŕéåðý ûšéð ƀý \"$title\". ~~~~~~~~]';
  }

  @override
  String get grpGKeysTaken =>
      '[Åñöţĥéŕ åçţíöñ åłŕéåðý ûšéš ţĥöšé ķéýš. ~~~~~~~~~~~~~]';

  @override
  String get grpGKeysInvalid => '[Ţĥöšé ķéýš çåññöţ ƀé ûšéð. ~~~~~~~~]';

  @override
  String get grpGSaveFailed =>
      '[Çöûłð ñöţ šåṽé. Çĥéçķ ýöûŕ çöññéçţíöñ. ~~~~~~~~~~~~]';

  @override
  String grpGDefaultUsedBy(String title) {
    return '[Ţĥé ðéƒåûłţ ķéýš åŕé ûšéð ƀý \"$title\". ~~~~~~~~~~~~~]';
  }

  @override
  String get grpGDefaultUsedByOther =>
      '[Ţĥé ðéƒåûłţ ķéýš åŕé ûšéð ƀý åñöţĥéŕ åçţíöñ. ~~~~~~~~~~~~~~]';

  @override
  String get grpGPaletteHint =>
      '[Ţýþé å çöɱɱåñð, öŕ > åçţíöñš  # þŕöĵéçţš  @ þéöþłé ~~~~~~~~~~~~~~~~]';

  @override
  String get grpGNothingMatches => '[Ñöţĥíñĝ ɱåţçĥéš. ~~~~~]';

  @override
  String get grpGSearchUnavailable =>
      '[Šéåŕçĥ íš ñöţ åṽåíłåƀłé ŕíĝĥţ ñöŵ. ~~~~~~~~~~~]';

  @override
  String get grpGName => '[Ñåɱé ~]';

  @override
  String get grpGCreate => '[Çŕéåţé ~~]';

  @override
  String get grpGQuickActions => '[Qûíçķ åçţíöñš ~~~~]';

  @override
  String grpGDryRunTitle(String name) {
    return '[Ðŕý ŕûñ: $name ~~~~~]';
  }

  @override
  String get grpGDryRunIntro =>
      '[Šĥöŵš ŵĥåţ ŵöûłð ĥåþþéñ öñ å ţåšķ. Ñöţĥíñĝ íš çĥåñĝéð, šéñţ öŕ ñöţíƒíéð. ~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpGTask => '[Ţåšķ ~]';

  @override
  String get grpGTasksLoadFailed => '[Çöûłð ñöţ łöåð ţĥé ţåšķš. ~~~~~~~~]';

  @override
  String get grpGWouldRun => '[Íţ ŵöûłð ŕûñ. ~~~~]';

  @override
  String get grpGWouldNotRun => '[Íţ ŵöûłð ñöţ ŕûñ öñ ţĥíš ţåšķ. ~~~~~~~~~~]';

  @override
  String get grpGRun => '[Ŕûñ ~]';

  @override
  String get grpGConditionProblem =>
      '[Ţĥé çöñðíţíöñ ĥåš å þŕöƀłéɱ: šéé ûñðéŕ ţĥé Íƒ çåŕð. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpGRuleGone => '[Ţĥåţ ŕûłé ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpGRule => '[Ŕûłé ~]';

  @override
  String get grpGNewAutomation => '[Ñéŵ åûţöɱåţíöñ ~~~~]';

  @override
  String get grpGEditAutomation => '[Éðíţ åûţöɱåţíöñ ~~~~~]';

  @override
  String get grpGWhen => '[Ŵĥéñ ~]';

  @override
  String get grpGIfOptional => '[Íƒ (öþţíöñåł) ~~~~]';

  @override
  String get grpGThen => '[Ţĥéñ ~]';

  @override
  String get grpGAndThen => '[Åñð ţĥéñ ~~]';

  @override
  String grpGActionLimit(int max) {
    return '[Łíɱíţ öƒ $max åçţíöñš ŕéåçĥéð ~~~~~~~~~~]';
  }

  @override
  String get grpGAddAction => '[Åðð åçţíöñ ~~~]';

  @override
  String get grpGLoadLatest => '[Łöåð ţĥé łåţéšţ ṽéŕšíöñ ~~~~~~~]';

  @override
  String get grpGMoveUp => '[Möṽé ûþ ~~]';

  @override
  String get grpGMoveDown => '[Möṽé ðöŵñ ~~~]';

  @override
  String get grpGRemoveAction => '[Ŕéɱöṽé åçţíöñ ~~~~]';

  @override
  String grpGSwitchedOff(String reason) {
    return '[Šŵíţçĥéð öƒƒ: $reason\nFíx íţ: öþéñ ţĥé ŕûłé, þíçķ šöɱéţĥíñĝ ţĥåţ šţíłł éxíšţš íñ ţĥé ţŕíĝĝéŕ öŕ åçţíöñš, šåṽé, ţĥéñ šŵíţçĥ íţ öñ åĝåíñ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpGUnknown => '[Ûñķñöŵñ ~~]';

  @override
  String get grpGEmptyValue => '[(éɱþţý) ~~]';

  @override
  String get grpGNothingRunYet => '[Ñöţĥíñĝ ĥåš ŕûñ ýéţ. ~~~~~~]';

  @override
  String get grpGLoadMore => '[Łöåð ɱöŕé ~~~]';

  @override
  String get grpGRetry => '[Ŕéţŕý ~]';

  @override
  String grpGWhyNotRun(String explanation) {
    return '[Ŵĥý ðíðñ\'ţ ţĥíš ŕûñ? $explanation ~~~~~~~~~~~]';
  }

  @override
  String grpGChainDepth(int depth) {
    return '[Çĥåíñ ðéþţĥ $depth ~~~~~~]';
  }

  @override
  String get grpGFilter => '[Fíłţéŕ ~~]';

  @override
  String grpGFilterCount(int count) {
    return '[Fíłţéŕ ($count) ~~~~~]';
  }

  @override
  String get grpGSavedFilters => '[Šåṽéð ƒíłţéŕš ~~~~]';

  @override
  String get grpGNoSavedFilters => '[Ñö šåṽéð ƒíłţéŕš ýéţ ~~~~~~]';

  @override
  String grpGFieldGoneNamed(String name) {
    return '[$name (å ƒíéłð íš ĝöñé) ~~~~~~~~]';
  }

  @override
  String get grpGManageSaved => '[Måñåĝé šåṽéð ƒíłţéŕš… ~~~~~~~]';

  @override
  String grpGConditionCount(int count) {
    return '[$count çöñðíţíöñ(š) ~~~~~~]';
  }

  @override
  String get grpGClearFilterTip => '[Çłéåŕ ţĥé ƒíłţéŕ ~~~~~]';

  @override
  String get grpGNothingSaved => '[Ñöţĥíñĝ šåṽéð ýéţ. ~~~~~~]';

  @override
  String get grpGFieldItUsedGone => '[Å ƒíéłð íţ ûšéð íš ĝöñé ~~~~~~~]';

  @override
  String get grpGDelete => '[Ðéłéţé ~~]';

  @override
  String get grpGFinishConditions => '[Fíñíšĥ ţĥé çöñðíţíöñš ƒíŕšţ. ~~~~~~~~~]';

  @override
  String get grpGEveryoneWorkspace => '[Éṽéŕýöñé íñ ţĥé ŵöŕķšþåçé ~~~~~~~~]';

  @override
  String get grpGEveryoneProject => '[Éṽéŕýöñé íñ ţĥíš þŕöĵéçţ ~~~~~~~~]';

  @override
  String get grpGBuilder => '[ßûíłðéŕ ~~]';

  @override
  String get grpGAdvanced => '[Åðṽåñçéð ~~]';

  @override
  String get grpGClearFilter => '[Çłéåŕ ƒíłţéŕ ~~~~]';

  @override
  String get grpGSaveAs => '[Šåṽé åš… ~~]';

  @override
  String get grpGApply => '[Åþþłý ~]';

  @override
  String get grpGSaveThisFilter => '[Šåṽé ţĥíš ƒíłţéŕ ~~~~~]';

  @override
  String get grpGOnlyMe => '[Öñłý ɱé ~~]';

  @override
  String get grpGExportSaveFailed =>
      '[Ţĥé ƒíłé çöûłð ñöţ ƀé šåṽéð. Ţŕý åĝåíñ. ~~~~~~~~~~~~~]';

  @override
  String get grpGExport => '[Éxþöŕţ ~~]';

  @override
  String get grpGEveryProject => '[Éṽéŕý þŕöĵéçţ Í çåñ öþéñ ~~~~~~~~]';

  @override
  String get grpGOneProject => '[Öñé þŕöĵéçţ ~~~]';

  @override
  String get grpGExportInfo =>
      '[Å žíþ ŵíţĥ ţåšķš.ĵšöñ (ŵĥíçĥ ŢåšķFöŕĝé çåñ íɱþöŕţ åĝåíñ), ţåšķš.çšṽ, çöɱɱéñţš, åñ åţţåçĥɱéñţš ɱåñíƒéšţ åñð å ŔÉÅÐMÉ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpGExportSavedSized(String name, String size) {
    return '[Šåṽéð $name ($size). ~~~~~~~]';
  }

  @override
  String grpGExportSaved(String name) {
    return '[Šåṽéð $name. ~~~~]';
  }

  @override
  String grpGNotesAboutFile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ñöţéš åƀöûţ ţĥíš ƒíłé',
      one: '1 ñöţé åƀöûţ ţĥíš ƒíłé',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpGRowNumber(int line) {
    return '[Ŕöŵ $line ~~~]';
  }

  @override
  String grpGAndMore(int count) {
    return '[...åñð $count ɱöŕé. ~~~~~~]';
  }

  @override
  String get grpGNotesReadFailed =>
      '[Çöûłð ñöţ ŕéåð ţĥé ñöţéš åƀöûţ ţĥíš íɱþöŕţ. ~~~~~~~~~~~~~~]';

  @override
  String get grpGDragToOtherList => '[Ðŕåĝ ţö ţĥé öţĥéŕ łíšţ ~~~~~~~]';

  @override
  String get grpGAddedAfterStart => '[åððéð åƒţéŕ šţåŕţ ~~~~~]';

  @override
  String get grpGStoryPoints => '[Šţöŕý þöíñţš ~~~~]';

  @override
  String get grpGUnitHours => '[ĥ ]';

  @override
  String get grpGUnitPoints => '[ þţš ~]';

  @override
  String grpGLoadOf(String load, String unit, String cap) {
    return '[Łöåð $load$unit öƒ $cap$unit ~~~~~~~~~~]';
  }

  @override
  String grpGLoadNoCapacity(String load, String unit) {
    return '[Łöåð $load$unit (ñö çåþåçíţý šéţ) ~~~~~~~~~~~]';
  }

  @override
  String get grpGSetCapacity => '[Šéţ çåþåçíţý ~~~~]';

  @override
  String get grpGPoints => '[Þöíñţš ~~]';

  @override
  String get grpGHours => '[Ĥöûŕš ~]';

  @override
  String grpGOverCapacity(String amount, String unit) {
    return '[Öṽéŕ çåþåçíţý ƀý $amount$unit ~~~~~~~~~~]';
  }

  @override
  String grpGTitleWithCount(String title, int count) {
    return '[$title ($count) ~~~~~]';
  }

  @override
  String get grpHCancel => '[Çåñçéł ~~]';

  @override
  String get grpHArchive => '[Åŕçĥíṽé ~~]';

  @override
  String get grpHRestore => '[Ŕéšţöŕé ~~]';

  @override
  String get grpHRetry => '[Ŕéţŕý ~]';

  @override
  String get grpHCreate => '[Çŕéåţé ~~]';

  @override
  String get grpHName => '[Ñåɱé ~]';

  @override
  String get grpHDescription => '[Ðéšçŕíþţíöñ ~~~]';

  @override
  String grpHArchiveTitle(String name) {
    return '[Åŕçĥíṽé \"$name\"? ~~~~~]';
  }

  @override
  String get grpHArchiveBody =>
      '[Íţ ƀéçöɱéš ŕéåð-öñłý åñð ðíšåþþéåŕš ƒŕöɱ ţĥé šíðéƀåŕ. Ýöû çåñ ŕéšţöŕé íţ åţ åñý ţíɱé. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpHDangerZone => '[Ðåñĝéŕ žöñé ~~~]';

  @override
  String get grpHRestoreProject => '[Ŕéšţöŕé þŕöĵéçţ ~~~~~]';

  @override
  String get grpHArchiveProject => '[Åŕçĥíṽé þŕöĵéçţ ~~~~~]';

  @override
  String get grpHArchivedBanner =>
      '[Ţĥíš þŕöĵéçţ íš åŕçĥíṽéð åñð ŕéåð-öñłý. ~~~~~~~~~~~~~]';

  @override
  String get grpHArchivedProjects => '[Åŕçĥíṽéð þŕöĵéçţš ~~~~~]';

  @override
  String get grpHNoArchived => '[Ñö åŕçĥíṽéð þŕöĵéçţš. ~~~~~~~]';

  @override
  String get grpHLoadProjectsRetry =>
      '[Çöûłð ñöţ łöåð þŕöĵéçţš. Ŕéţŕý ~~~~~~~~~~]';

  @override
  String get grpHNewProject => '[Ñéŵ þŕöĵéçţ ~~~]';

  @override
  String get grpHKey => '[Ķéý ~]';

  @override
  String get grpHKeyHelp => '[Þŕéƒíx öƒ ţåšķ ñûɱƀéŕš, é.ĝ. ŴÉß-12 ~~~~~~~~~~~]';

  @override
  String get grpHFeatures => '[Féåţûŕéš ~~]';

  @override
  String get grpHFeaturesHint =>
      '[Šŵíţçĥíñĝ å ƒéåţûŕé öƒƒ ĥíðéš íţ ƀûţ ķééþš íţš ðåţå. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpHProjectUpdated => '[Þŕöĵéçţ ûþðåţéð. ~~~~~]';

  @override
  String get grpHGeneral => '[Ĝéñéŕåł ~~]';

  @override
  String grpHKeyFixed(String taskKey) {
    return '[Ţĥé ķéý íš ƒíxéð ƀéçåûšé ţåšķš åłŕéåðý ûšé íţ ($taskKey). ~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpHSaveChanges => '[Šåṽé çĥåñĝéš ~~~~]';

  @override
  String get grpHAddAMember => '[Åðð å ɱéɱƀéŕ ~~~~]';

  @override
  String get grpHAllAreMembers =>
      '[Éṽéŕýöñé íñ ţĥé ŵöŕķšþåçé íš åłŕéåðý å ɱéɱƀéŕ. ~~~~~~~~~~~~~~~]';

  @override
  String get grpHMembers => '[Méɱƀéŕš ~~]';

  @override
  String get grpHAddMember => '[Åðð ɱéɱƀéŕ ~~~]';

  @override
  String get grpHRemove => '[Ŕéɱöṽé ~~]';

  @override
  String get grpHLoadMembersRetry =>
      '[Çöûłð ñöţ łöåð ɱéɱƀéŕš. Ŕéţŕý ~~~~~~~~~]';

  @override
  String get grpHPrivateProjects => '[Þŕíṽåţé þŕöĵéçţš ~~~~~]';

  @override
  String get grpHNoPrivate => '[Ñö þŕíṽåţé þŕöĵéçţš. ~~~~~~]';

  @override
  String grpHKeyAndMembers(String key, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ɱéɱƀéŕš',
      one: '1 ɱéɱƀéŕ',
    );
    return '[$key · $_temp0 ~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpHAddMe => '[Åðð ɱé ~~]';

  @override
  String grpHColorLabel(String color) {
    return '[Çöłöŕ $color ~~~~]';
  }

  @override
  String get grpHVisOpen => '[Öþéñ ~]';

  @override
  String get grpHVisPrivate => '[Þŕíṽåţé ~~]';

  @override
  String get grpHVisOpenHint =>
      '[Éṽéŕýöñé íñ ţĥé ŵöŕķšþåçé çåñ šéé íţ. ~~~~~~~~~~~~]';

  @override
  String get grpHVisPrivateHint =>
      '[Öñłý íñṽíţéð ɱéɱƀéŕš çåñ šéé íţ. ~~~~~~~~~~]';

  @override
  String get grpHProject => '[Þŕöĵéçţ ~~]';

  @override
  String get grpHRemoveFavorite => '[Ŕéɱöṽé ƒåṽöŕíţé ~~~~~]';

  @override
  String get grpHAddFavorite => '[Åðð ƒåṽöŕíţé ~~~~]';

  @override
  String get grpHTrash => '[Ţŕåšĥ ~]';

  @override
  String get grpHProjectSettings => '[Þŕöĵéçţ šéţţíñĝš ~~~~~]';

  @override
  String get grpHLoadProjectRetry =>
      '[Çöûłð ñöţ łöåð ţĥé þŕöĵéçţ. Ŕéţŕý ~~~~~~~~~~~]';

  @override
  String get grpHProjectNotFound => '[Þŕöĵéçţ ñöţ ƒöûñð. ~~~~~~]';

  @override
  String get grpHBack => '[ßåçķ ~]';

  @override
  String get grpHWorkflow => '[Ŵöŕķƒłöŵ ~~]';

  @override
  String get grpHWorkflowHint =>
      '[Šţåţûšéš, ţĥéíŕ çåţéĝöŕíéš åñð ŵĥíçĥ ɱöṽéš åŕé åłłöŵéð. ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpHFields => '[Fíéłðš ~~]';

  @override
  String get grpHFieldsHint =>
      '[Çûšţöɱ ƒíéłðš šûçĥ åš Çûšţöɱéŕ, Šţöŕý þöíñţš öŕ Éñṽíŕöñɱéñţ. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpHAdd => '[Åðð ~]';

  @override
  String get grpHAttachFile => '[Åţţåçĥ å ƒíłé ~~~~]';

  @override
  String get grpHTakePhoto => '[Ţåķé å þĥöţö ~~~~]';

  @override
  String get grpHChooseGallery => '[Çĥööšé ƒŕöɱ ĝåłłéŕý ~~~~~~]';

  @override
  String get grpHPasteImage => '[Þåšţé åñ íɱåĝé ~~~~]';

  @override
  String get grpHDeleteFileQ => '[Ðéłéţé ţĥíš ƒíłé? ~~~~~]';

  @override
  String grpHFileWillBeRemoved(String filename) {
    return '[$filename ŵíłł ƀé ŕéɱöṽéð. ~~~~~~~~~]';
  }

  @override
  String get grpHDelete => '[Ðéłéţé ~~]';

  @override
  String grpHOpenFile(String filename) {
    return '[Öþéñ $filename ~~~~~]';
  }

  @override
  String grpHDeleteFile(String filename) {
    return '[Ðéłéţé $filename ~~~~~]';
  }

  @override
  String get grpHWaitingConnection => '[Ŵåíţíñĝ ƒöŕ å çöññéçţíöñ… ~~~~~~~~]';

  @override
  String get grpHWaiting => '[Ŵåíţíñĝ… ~~]';

  @override
  String get grpHUploadDone => '[Ðöñé ~]';

  @override
  String get grpHUploadCancelled => '[Çåñçéłłéð ~~~]';

  @override
  String grpHPercentUploaded(String filename, int percent) {
    return '[$filename, $percent þéŕçéñţ ûþłöåðéð ~~~~~~~~~~~~]';
  }

  @override
  String get grpHWaitingToBeSent => '[Ŵåíţíñĝ ţö ƀé šéñţ ~~~~~~]';

  @override
  String grpHCancelFile(String filename) {
    return '[Çåñçéł $filename ~~~~~]';
  }

  @override
  String grpHTryFileAgain(String filename) {
    return '[Ţŕý $filename åĝåíñ ~~~~~~]';
  }

  @override
  String grpHDismissFile(String filename) {
    return '[Ðíšɱíšš $filename ~~~~~~]';
  }

  @override
  String get grpHOpen => '[Öþéñ ~]';

  @override
  String get grpHDownload => '[Ðöŵñłöåð ~~]';

  @override
  String get grpHClose => '[Çłöšé ~]';

  @override
  String get grpHCouldNotOpenFile => '[Çöûłð ñöţ öþéñ ţĥé ƒíłé. ~~~~~~~~]';

  @override
  String get grpHCouldNotLoadPicture =>
      '[Çöûłð ñöţ łöåð ţĥé þíçţûŕé. ~~~~~~~~~]';

  @override
  String get grpHCouldNotReadFileViewer =>
      '[Çöûłð ñöţ ŕéåð ţĥé ƒíłé. ~~~~~~~~]';

  @override
  String get grpHCouldNotPlayVideo => '[Çöûłð ñöţ þłåý ţĥé ṽíðéö. ~~~~~~~~]';

  @override
  String get grpHPause => '[Þåûšé ~]';

  @override
  String get grpHPlay => '[Þłåý ~]';

  @override
  String grpHTextTruncated(String size) {
    return '[Šĥöŵíñĝ ţĥé ƒíŕšţ $size. Ðöŵñłöåð ţĥé ƒíłé ţö ŕéåð ţĥé ŕéšţ. ~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpHAttachments => '[Åţţåçĥɱéñţš ~~~]';

  @override
  String grpHAttachmentsCount(int count) {
    return '[Åţţåçĥɱéñţš ($count) ~~~~~~~]';
  }

  @override
  String get grpHCouldNotReadFile => '[Çöûłð ñöţ ŕéåð ţĥåţ ƒíłé. ~~~~~~~~]';

  @override
  String get grpHDismiss => '[Ðíšɱíšš ~~]';

  @override
  String get grpHNoAttachments => '[Ñö åţţåçĥɱéñţš. ~~~~~]';

  @override
  String get grpHDropZoneLabel =>
      '[Åţţåçĥ ƒíłéš: ðŕöþ ţĥéɱ ĥéŕé öŕ çłíçķ, ţĥéñ þåšţé åñ íɱåĝé ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpHDropToAttach => '[Ðŕöþ ţö åţţåçĥ ~~~~]';

  @override
  String get grpHDropFilesHere => '[Ðŕöþ ƒíłéš ĥéŕé ţö åţţåçĥ ţĥéɱ ~~~~~~~~~~]';

  @override
  String get grpHSnoozeLaterToday => '[Łåţéŕ ţöðåý ~~~]';

  @override
  String get grpHSnoozeTomorrow => '[Ţöɱöŕŕöŵ ~~]';

  @override
  String get grpHSnoozeNextWeek => '[Ñéxţ ŵééķ ~~~]';

  @override
  String get grpHMarkAllRead => '[Måŕķ åłł ŕéåð ~~~~]';

  @override
  String get grpHNotificationSettings => '[Ñöţíƒíçåţíöñ šéţţíñĝš ~~~~~~~]';

  @override
  String get grpHInbox => '[Íñƀöx ~]';

  @override
  String grpHUnreadCount(int count) {
    return '[$count ûñŕéåð ~~~~]';
  }

  @override
  String get grpHLoadMore => '[Łöåð ɱöŕé ~~~]';

  @override
  String get grpHEmptyAll =>
      '[Ñöţĥíñĝ ĥéŕé. Ýöû åŕé åłł çåûĝĥţ ûþ. ~~~~~~~~~~~~]';

  @override
  String get grpHEmptyUnread => '[Ñö ûñŕéåð ñöţíƒíçåţíöñš. ~~~~~~~~]';

  @override
  String get grpHEmptyMentions => '[Ñöƀöðý ĥåš ɱéñţíöñéð ýöû. ~~~~~~~~]';

  @override
  String get grpHEmptyAssigned =>
      '[Ñöţĥíñĝ åššíĝñéð ţö ýöû łåţéłý. ~~~~~~~~~~]';

  @override
  String get grpHEmptySnoozed => '[Ñöţĥíñĝ íš šñööžéð. ~~~~~~]';

  @override
  String get grpHEmptyArchived => '[Ñöţĥíñĝ íš åŕçĥíṽéð. ~~~~~~]';

  @override
  String grpHDueDate(String date) {
    return '[Ðûé $date ~~~]';
  }

  @override
  String grpHUnreadPrefix(String title) {
    return '[Ûñŕéåð. $title ~~~~~]';
  }

  @override
  String grpHMoreCount(int count) {
    return '[+$count ɱöŕé ~~~~]';
  }

  @override
  String get grpHMore => '[Möŕé ~]';

  @override
  String get grpHMarkUnread => '[Måŕķ ûñŕéåð ~~~]';

  @override
  String get grpHMarkRead => '[Måŕķ ŕéåð ~~~]';

  @override
  String get grpHStopSnoozing => '[Šţöþ šñööžíñĝ ~~~~]';

  @override
  String get grpHSnoozeEllipsis => '[Šñööžé… ~~]';

  @override
  String get grpHMoveToInbox => '[Möṽé ţö íñƀöx ~~~~]';

  @override
  String get grpHPushTitle => '[Ĝéţ å þíñĝ ŵĥéñ íţ ɱåţţéŕš ~~~~~~~~]';

  @override
  String get grpHPushBody =>
      '[ŢåšķFöŕĝé çåñ šĥöŵ å ñöţíƒíçåţíöñ ŵĥéñ ýöû åŕé åššíĝñéð å ţåšķ, ɱéñţíöñéð, öŕ å ţåšķ íš ðûé šööñ, éṽéñ ŵĥéñ ţĥé åþþ íš íñ ţĥé ƀåçķĝŕöûñð. Ñéxţ ýöûŕ ðéṽíçé ŵíłł åšķ ƒöŕ þéŕɱíššíöñ. Ýöû çĥööšé ŵĥíçĥ ķíñðš þíñĝ ýöû, åñð qûíéţ ĥöûŕš ķééþ ţĥéɱ ƒŕöɱ ŵåķíñĝ ýöû. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpHNotNow => '[Ñöţ ñöŵ ~~]';

  @override
  String get grpHContinue => '[Çöñţíñûé ~~]';

  @override
  String get grpHPickDateTime => '[Þíçķ ðåţé åñð ţíɱé ~~~~~~]';

  @override
  String get grpHRepeatReadError =>
      '[Çöûłð ñöţ ŕéåð ĥöŵ ţĥíš ŕéþéåţš. ~~~~~~~~~~]';

  @override
  String get grpHRepeat => '[Ŕéþéåţ ~~]';

  @override
  String get grpHFirstOfSeries => '[Fíŕšţ öƒ å šéŕíéš ~~~~~]';

  @override
  String get grpHRepeatingTask => '[Ŕéþéåţíñĝ ţåšķ ~~~~]';

  @override
  String grpHSeriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ţåšķš íñ ţĥíš šéŕíéš',
      one: '$count ţåšķ íñ ţĥíš šéŕíéš',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpHRepeatPaused => '[Þåûšéð: ñö ñéŵ ţåšķš åŕé ɱåðé. ~~~~~~~~~~]';

  @override
  String grpHRepeatPausedBySystem(String reason) {
    return '[Þåûšéð ƀý ţĥé šýšţéɱ: $reason ~~~~~~~~~~]';
  }

  @override
  String grpHRepeatNext(String dates) {
    return '[Ñéxţ: $dates ~~~~]';
  }

  @override
  String get grpHRepeatWaits =>
      '[Ţĥé ñéxţ öñé íš ɱåðé ŵĥéñ ţĥíš íš çöɱþłéţéð. ~~~~~~~~~~~~~~]';

  @override
  String get grpHRepeatsTitle => '[Ţĥíš ţåšķ ŕéþéåţš ~~~~~]';

  @override
  String grpHRepeatsBody(String summary) {
    return '[Íţ íš ţĥé ţéɱþłåţé öƒ \"$summary\". Ðéłéţíñĝ íţ çåñ šţöþ ţĥé šéŕíéš, öŕ ţĥé šéŕíéš çåñ ķééþ ɱåķíñĝ ñéŵ ţåšķš. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpHDeleteKeepRepeating => '[Ðéłéţé, ķééþ ŕéþéåţíñĝ ~~~~~~~]';

  @override
  String get grpHDeleteAndStop => '[Ðéłéţé åñð šţöþ ~~~~~]';

  @override
  String get grpHChartGroup => '[Ĝŕöûþ ~]';

  @override
  String get grpHOfflineReview => '[Ŕéṽíéŵ ~~]';

  @override
  String get grpHOfflineSyncing => '[Šýñçíñĝ… ~~]';

  @override
  String get grpHOfflineSyncNow => '[Šýñç ñöŵ ~~]';

  @override
  String get grpHOfflineSaved =>
      '[Ýöû åŕé öƒƒłíñé. Çĥåñĝéš åŕé šåṽéð öñ ţĥíš ðéṽíçé. ~~~~~~~~~~~~~~~~]';

  @override
  String grpHOfflineWaitsOnline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çĥåñĝéš ŵåíţ ţö ƀé šéñţ.',
      one: '$count çĥåñĝé ŵåíţš ţö ƀé šéñţ.',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpHOfflineWaitsOffline(int count) {
    return '[$count ŵåíţíñĝ ţö ƀé šéñţ. ~~~~~~~~~]';
  }

  @override
  String grpHOfflineAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çĥåñĝéš ñééð ýöûŕ åţţéñţíöñ.',
      one: '$count çĥåñĝé ñééðš ýöûŕ åţţéñţíöñ.',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpHReconnecting =>
      '[Ŕéçöññéçţíñĝ… ŵĥåţ ýöû šéé ŵíłł çåţçĥ ûþ öñçé ýöû åŕé ƀåçķ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpICancel => '[Çåñçéł ~~]';

  @override
  String get grpIDone => '[Ðöñé ~]';

  @override
  String get grpIRetry => '[Ŕéţŕý ~]';

  @override
  String get grpIClose => '[Çłöšé ~]';

  @override
  String get grpIBack => '[ßåçķ ~]';

  @override
  String get grpIEdit => '[Éðíţ ~]';

  @override
  String get grpISave => '[Šåṽé ~]';

  @override
  String get grpISaving => '[Šåṽíñĝ… ~~]';

  @override
  String get grpIDelete => '[Ðéłéţé ~~]';

  @override
  String get grpICopy => '[Çöþý ~]';

  @override
  String get grpIUndo => '[Ûñðö ~]';

  @override
  String get grpIRestore => '[Ŕéšţöŕé ~~]';

  @override
  String get grpIUnnamed => '[(ûññåɱéð) ~~~]';

  @override
  String grpIErrorRetry(String message) {
    return '[$message Ŕéţŕý ~~~~~]';
  }

  @override
  String get grpIMergeTitle =>
      '[Šöɱéöñé éłšé šåṽéð ţĥé ŵöŕķƒłöŵ ƒíŕšţ ~~~~~~~~~~~~]';

  @override
  String get grpIMergeBody =>
      '[Ýöûŕ éðíţš åŕé ķéþţ, åñð ţĥéíŕ ŵöŕķ ŵåš ñöţ öṽéŕŵŕíţţéñ. Ţĥíš íš ŵĥåţ çĥåñĝéð íñ ýöûŕ ðŕåƒţ: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpIMergeKeep => '[Í ĥåṽé ŕéåð ţĥíš, ķééþ ɱý ðŕåƒţ ~~~~~~~~~~]';

  @override
  String get grpIMergeReload => '[Ţĥŕöŵ ɱý ðŕåƒţ åŵåý ~~~~~~]';

  @override
  String get grpINoProblems => '[Ñö þŕöƀłéɱš ~~~]';

  @override
  String get grpIEveryTaskValid =>
      '[Éṽéŕý ţåšķ ķééþš å ṽåłíð šţåţûš. ~~~~~~~~~~]';

  @override
  String grpIProblemsToFix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count þŕöƀłéɱš ţö ƒíx ƀéƒöŕé šåṽíñĝ',
      one: '1 þŕöƀłéɱ ţö ƒíx ƀéƒöŕé šåṽíñĝ',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpIAnyStatusMoves =>
      '[Åñý šţåţûš çåñ ɱöṽé ţö åñý öţĥéŕ. ~~~~~~~~~~~]';

  @override
  String grpIWorkflowGraphLabel(int statuses, int moves) {
    return '[Ŵöŕķƒłöŵ ŵíţĥ $statuses šţåţûšéš åñð $moves åłłöŵéð ɱöṽéš ~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpINeedsAssignee => '[ñééðš åñ åššíĝñéé ~~~~~]';

  @override
  String get grpINeedsSubtasksDone => '[ñééðš åłł šûƀţåšķš ðöñé ~~~~~~~]';

  @override
  String grpIOnlyRoleLower(String role) {
    return '[öñłý $role ~~~]';
  }

  @override
  String get grpIOneRole => '[öñé ŕöłé ~~]';

  @override
  String get grpIDragToReorder => '[Ðŕåĝ ţö ŕéöŕðéŕ ~~~~~]';

  @override
  String get grpIColour => '[Çöłöûŕ ~~]';

  @override
  String get grpINewTasksStartHere => '[Ñéŵ ţåšķš šţåŕţ ĥéŕé ~~~~~~]';

  @override
  String get grpIMakeDefaultStatus =>
      '[Måķé ţĥíš ţĥé šţåţûš ñéŵ ţåšķš šţåŕţ íñ ~~~~~~~~~~~~~]';

  @override
  String get grpIDeleteStatus => '[Ðéłéţé šţåţûš ~~~~]';

  @override
  String grpITaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ţåšķš',
      one: '1 ţåšķ',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpICanMoveTo => '[Çåñ ɱöṽé ţö ~~~]';

  @override
  String get grpIConditionsForMove => '[Çöñðíţíöñš ƒöŕ ţĥíš ɱöṽé ~~~~~~~~]';

  @override
  String get grpIName => '[Ñåɱé ~]';

  @override
  String grpIDeleteStatusTitle(String name) {
    return '[Ðéłéţé $name? ~~~~]';
  }

  @override
  String grpITasksInStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ţåšķš åŕé íñ ţĥíš šţåţûš. Çĥööšé ŵĥéŕé ţĥéý ĝö.',
      one: '1 ţåšķ íš íñ ţĥíš šţåţûš. Çĥööšé ŵĥéŕé íţ ĝöéš.',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpIMoveTasksTo => '[Möṽé ţåšķš ţö ~~~~]';

  @override
  String get grpIMoveTasksAndDelete => '[Möṽé ţåšķš åñð ðéłéţé ~~~~~~~]';

  @override
  String get grpIWhoMayMove => '[Ŵĥö ɱåý ɱåķé ţĥíš ɱöṽé ~~~~~~~]';

  @override
  String get grpIAnyRole => '[Åñý ŕöłé ~~]';

  @override
  String grpIOnlyRole(String name) {
    return '[Öñłý $name ~~~]';
  }

  @override
  String get grpITaskNeedsAssignee => '[Ţĥé ţåšķ ñééðš åñ åššíĝñéé ~~~~~~~~]';

  @override
  String get grpIAllSubtasksDone => '[Åłł šûƀţåšķš ɱûšţ ƀé ðöñé ~~~~~~~~]';

  @override
  String get grpIDoneOrCancelledDepth =>
      '[Ðöñé öŕ çåñçéłłéð, åţ åñý ðéþţĥ. ~~~~~~~~~~]';

  @override
  String get grpIWorkflow => '[Ŵöŕķƒłöŵ ~~]';

  @override
  String get grpIDiscard => '[Ðíšçåŕð ~~]';

  @override
  String get grpIWorkflowSaved => '[Ŵöŕķƒłöŵ šåṽéð ~~~~]';

  @override
  String get grpIRestrictTransitions => '[Ŕéšţŕíçţ ţŕåñšíţíöñš ~~~~~~]';

  @override
  String get grpIRestrictTransitionsHint =>
      '[Öƒƒ: åñý šţåţûš çåñ ɱöṽé ţö åñý öţĥéŕ. Öñ: öñłý ţĥé åŕŕöŵš ýöû åłłöŵ. ~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpIRestrictCreation =>
      '[Ñéŵ ţåšķš šţåŕţ íñ ţĥé ðéƒåûłţ šţåţûš öñłý ~~~~~~~~~~~~~~]';

  @override
  String get grpIRestrictCreationHint =>
      '[Öƒƒ: å ţåšķ çåñ ƀé çŕéåţéð íñ åñý šţåţûš. Öñ: íţ šţåŕţš íñ ţĥé šţåţûš ɱåŕķéð ŵíţĥ ţĥé šţåŕ åñð ŕéåçĥéš ţĥé öţĥéŕš ƀý ƀéíñĝ ɱöṽéð. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpIAddStatus => '[Åðð šţåţûš ~~~]';

  @override
  String get grpINewStatus => '[Ñéŵ šţåţûš ~~~]';

  @override
  String get grpIMigrationNeedsPlace =>
      '[Ţåšķš ýöû çĥöšé ţö ɱöṽé ĥéŕé ñééð å ñéŵ þłåçé. ~~~~~~~~~~~~~~~]';

  @override
  String grpIMoveArrow(String from, String to) {
    return '[$from → $to ~~~~]';
  }

  @override
  String grpIDeletedStillHasTasks(String name) {
    return '[$name ŵåš ðéłéţéð ƀûţ šţíłł ĥåš ţåšķš. ~~~~~~~~~~~~~]';
  }

  @override
  String get grpIMoveItsTasksTo => '[Möṽé íţš ţåšķš ţö ~~~~~]';

  @override
  String grpIDrillTitle(String title, int count, String more) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ţåšķš',
      one: 'ţåšķ',
    );
    return '[$title · $count$more $_temp0 ~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpINoTasks => '[Ñö ţåšķš. ~~~]';

  @override
  String get grpIDrillTruncated =>
      '[Öñłý ţĥé ƒíŕšţ ţåšķš åŕé łíšţéð; ñåŕŕöŵ ţĥé ƒíłţéŕ ţö šéé ţĥé ŕéšţ. ~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpIDueOn(String date) {
    return '[ðûé $date ~~~]';
  }

  @override
  String get grpINothingToShow => '[Ñöţĥíñĝ ţö šĥöŵ ýéţ. ~~~~~~]';

  @override
  String get grpIRefresh => '[Ŕéƒŕéšĥ ~~]';

  @override
  String get grpIWidgetMenu => '[Ŵíðĝéţ ɱéñû ~~~]';

  @override
  String get grpIExportCsv => '[Éxþöŕţ ÇŠṼ ~~~]';

  @override
  String get grpIRemove => '[Ŕéɱöṽé ~~]';

  @override
  String get grpISaveToSeeNumbers => '[Šåṽé ţö šéé ñûɱƀéŕš. ~~~~~~]';

  @override
  String grpICsvTitle(String title) {
    return '[$title (ÇŠṼ) ~~~~]';
  }

  @override
  String get grpICsvCopied => '[ÇŠṼ çöþíéð. ~~~]';

  @override
  String get grpISaveAsFile => '[Šåṽé åš ƒíłé ~~~~]';

  @override
  String grpILatestPoints(int limit) {
    return '[Šĥöŵíñĝ ţĥé łåţéšţ $limit þöíñţš; šĥöŕţéñ ţĥé ŕåñĝé ţö šéé ţĥéɱ åłł. ~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpITopLimit(int limit) {
    return '[Šĥöŵíñĝ ţĥé ţöþ $limit; ñåŕŕöŵ ţĥé ƒíłţéŕ ţö šéé ţĥé ŕéšţ. ~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpIWidget => '[Ŵíðĝéţ ~~]';

  @override
  String get grpITitle => '[Ţíţłé ~]';

  @override
  String get grpIGroupBy => '[Ĝŕöûþ ƀý ~~]';

  @override
  String get grpIFilterTfqlOptional => '[Fíłţéŕ (ŢFQŁ, öþţíöñåł) ~~~~~~~]';

  @override
  String get grpIPreview => '[Þŕéṽíéŵ ~~]';

  @override
  String get grpIProject => '[Þŕöĵéçţ ~~]';

  @override
  String get grpISprint => '[Šþŕíñţ ~~]';

  @override
  String grpIDateRange(String start, String end) {
    return '[$start → $end ~~~~~]';
  }

  @override
  String grpIFromDate(String date) {
    return '[ƒŕöɱ $date ~~~]';
  }

  @override
  String get grpINoDates => '[ñö ðåţéš ~~]';

  @override
  String grpIDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ðåýš',
      one: '1 ðåý',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpINothingScheduled =>
      '[Ñöţĥíñĝ íš šçĥéðûłéð íñ ţĥíš ŕåñĝé. ~~~~~~~~~~~]';

  @override
  String get grpIOnCriticalPath => '[öñ ţĥé çŕíţíçåł þåţĥ ~~~~~~]';

  @override
  String get grpIBlocked => '[ƀłöçķéð ~~]';

  @override
  String grpIMovingPushes(String id, int count) {
    return '[Möṽíñĝ $id þûšĥéš $count ~~~~~~~~]';
  }

  @override
  String grpIRangeShift(String from, String to) {
    return '[$from  →  $to ~~~~~]';
  }

  @override
  String get grpIKeepThem => '[Ķééþ ţĥéɱ (šĥöŵ çöñƒłíçţ) ~~~~~~~~]';

  @override
  String get grpIShiftDependents => '[Šĥíƒţ ðéþéñðéñţš ~~~~~]';

  @override
  String get grpIWeekdayMon => '[Möñ ~]';

  @override
  String get grpIWeekdayTue => '[Ţûé ~]';

  @override
  String get grpIWeekdayWed => '[Ŵéð ~]';

  @override
  String get grpIWeekdayThu => '[Ţĥû ~]';

  @override
  String get grpIWeekdayFri => '[Fŕí ~]';

  @override
  String get grpIWeekdaySat => '[Šåţ ~]';

  @override
  String get grpIWeekdaySun => '[Šûñ ~]';

  @override
  String get grpIWorkingDays => '[Ŵöŕķíñĝ ðåýš ~~~~]';

  @override
  String get grpIWorkingDaysHint =>
      '[Möṽíñĝ å ţåšķ þåšţ åñöţĥéŕ šķíþš ţĥé ðåýš öƒƒ. ~~~~~~~~~~~~~~~]';

  @override
  String get grpIHolidays => '[Ĥöłíðåýš ~~]';

  @override
  String get grpIHolidaysHint =>
      '[Ðåţéš łíķé 2026-12-25, šéþåŕåţéð ƀý çöɱɱåš ~~~~~~~~~~~~~~]';

  @override
  String grpITimelineChartLabel(int count) {
    return '[Ţíɱéłíñé çĥåŕţ öƒ $count ţåšķš. Šŵíţçĥ ţö ţĥé łíšţ ṽíéŵ ţö ŕéåð ţĥéɱ. ~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpITimelineDragHint =>
      '[Ðŕåĝ å ƀåŕ ţö ɱöṽé íţ, åñ éñð ţö ŕéšížé íţ. Çţŕł + ŵĥééł öŕ þíñçĥ žööɱš. ~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpIUnscheduled => '[Ûñšçĥéðûłéð ~~~]';

  @override
  String get grpIMovedLinksBreak =>
      '[Möṽéð. Ţĥé łíñķš íţ ƀŕéåķš šĥöŵ íñ ŕéð. ~~~~~~~~~~~~~]';

  @override
  String get grpITimelineSaved => '[Ţíɱéłíñé šåṽéð. ~~~~~]';

  @override
  String get grpIDay => '[Ðåý ~]';

  @override
  String get grpIWeek => '[Ŵééķ ~]';

  @override
  String get grpIMonth => '[Möñţĥ ~]';

  @override
  String get grpIQuarter => '[Qûåŕţéŕ ~~]';

  @override
  String get grpITaskTree => '[Ţåšķ ţŕéé ~~~]';

  @override
  String get grpIByAssignee => '[ßý åššíĝñéé ~~~]';

  @override
  String get grpIByStatus => '[ßý šţåţûš ~~~]';

  @override
  String get grpIEarlier => '[Éåŕłíéŕ ~~]';

  @override
  String get grpIToday => '[Ţöðåý ~]';

  @override
  String get grpILater => '[Łåţéŕ ~]';

  @override
  String get grpICriticalPath => '[Çŕíţíçåł þåţĥ ~~~~]';

  @override
  String get grpIHideDone => '[Ĥíðé ðöñé ~~~]';

  @override
  String get grpIShowChart => '[Šĥöŵ ţĥé çĥåŕţ ~~~~]';

  @override
  String get grpIShowList => '[Šĥöŵ åš å łíšţ ~~~~]';

  @override
  String get grpIExportImage => '[Éxþöŕţ åš åñ íɱåĝé ~~~~~~]';

  @override
  String get grpICurrency => '[Çûŕŕéñçý ~~]';

  @override
  String get grpIClear => '[Çłéåŕ ~]';

  @override
  String get grpINone => '[Ñöñé ~]';

  @override
  String grpIFieldArchived(String name) {
    return '[Åŕçĥíṽéð $name. Ṽåłûéš åŕé ķéþţ 30 ðåýš. ~~~~~~~~~~~~~]';
  }

  @override
  String get grpIFields => '[Fíéłðš ~~]';

  @override
  String get grpIAddField => '[Åðð ƒíéłð ~~~]';

  @override
  String get grpINoCustomFields =>
      '[Ñö çûšţöɱ ƒíéłðš ýéţ. Åðð öñé ƒöŕ ţĥíñĝš łíķé Çûšţöɱéŕ öŕ Šţöŕý þöíñţš. ~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpIArchivedRestorable =>
      '[Åŕçĥíṽéð (ŕéšţöŕåƀłé ƒöŕ 30 ðåýš) ~~~~~~~~~~~]';

  @override
  String get grpIRequired => '[Ŕéqûíŕéð ~~]';

  @override
  String grpIOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öþţíöñš',
      one: '1 öþţíöñš',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpIArchive => '[Åŕçĥíṽé ~~]';

  @override
  String get grpIWriteComment => '[Ŵŕíţé å çöɱɱéñţ… (@ ţö ɱéñţíöñ) ~~~~~~~~~~]';

  @override
  String get grpIComment => '[Çöɱɱéñţ ~~]';

  @override
  String get grpIBulletList => '[ßûłłéţ łíšţ ~~~]';

  @override
  String get grpIQuote => '[Qûöţé ~]';

  @override
  String get grpICodeBlock => '[Çöðé ƀłöçķ ~~~]';

  @override
  String get grpILink => '[Łíñķ ~]';

  @override
  String get grpICouldNotReadFile => '[Çöûłð ñöţ ŕéåð ţĥåţ ƒíłé. ~~~~~~~~]';

  @override
  String get grpICtrlEnterToSend => '[Çţŕł+Éñţéŕ ţö šéñð ~~~~~~]';

  @override
  String get grpIDeleteCommentTitle => '[Ðéłéţé ţĥíš çöɱɱéñţ? ~~~~~~]';

  @override
  String get grpIDeleteCommentBody =>
      '[Íţ ŵíłł šĥöŵ åš \"Çöɱɱéñţ ŕéɱöṽéð\". Íţš çöñţéñţ åñð éðíţ ĥíšţöŕý åŕé ðéłéţéð. ~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpICannotSeeTask => '[Ţĥéý çåññöţ šéé ţĥíš ţåšķ ~~~~~~~~]';

  @override
  String grpICannotSeeGrant(String names) {
    return '[$names çåññöţ šéé ţĥíš ţåšķ. Åðð ţĥéɱ ţö ţĥé þŕöĵéçţ åñð šéñð ţĥé çöɱɱéñţ, öŕ ţåķé ţĥé ɱéñţíöñ öûţ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpICannotSeeRefuse(String names) {
    return '[$names çåññöţ šéé ţĥíš ţåšķ, šö ţĥéý çåññöţ ƀé ɱéñţíöñéð. Ţåķé ţĥé ɱéñţíöñ öûţ, öŕ åšķ šöɱéöñé ŵĥö ɱåñåĝéš ţĥé þŕöĵéçţ ţö åðð ţĥéɱ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpIOk => '[ÖĶ ]';

  @override
  String get grpIAddThemAndSend => '[Åðð ţĥéɱ åñð šéñð ~~~~~]';

  @override
  String grpIEditHistory(String author) {
    return '[Éðíţ ĥíšţöŕý · $author ~~~~~~~]';
  }

  @override
  String grpIRevisionCurrent(String stamp) {
    return '[$stamp · çûŕŕéñţ ~~~~~]';
  }

  @override
  String get grpISessions => '[Šéššíöñš ~~]';

  @override
  String get grpISignOutOthers => '[Šíĝñ öûţ öţĥéŕ ðéṽíçéš ~~~~~~~]';

  @override
  String get grpIUnknownDevice => '[Ûñķñöŵñ ðéṽíçé ~~~~]';

  @override
  String get grpIThisDevice => '[Ţĥíš ðéṽíçé ~~~]';

  @override
  String get grpISignOutThis => '[Šíĝñ öûţ ţĥíš ðéṽíçé ~~~~~~]';

  @override
  String get grpJLink => '[Łíñķ ~]';

  @override
  String get grpJInviteEmails => '[Éɱåíł åððŕéššéš ~~~~~]';

  @override
  String grpJInviteEmailsHelp(int max) {
    return '[Šéþåŕåţé šéṽéŕåł ŵíţĥ çöɱɱåš. Ûþ ţö $max. ~~~~~~~~~~~~~~]';
  }

  @override
  String get grpJAdd => '[Åðð ~]';

  @override
  String grpJInviteInvalidEmail(String email) {
    return '[\"$email\" íš ñöţ å ṽåłíð éɱåíł åððŕéšš. ~~~~~~~~~~~~~]';
  }

  @override
  String grpJInviteTooMany(int max) {
    return '[Ýöû çåñ íñṽíţé åţ ɱöšţ $max þéöþłé åţ öñçé. ~~~~~~~~~~~~~~]';
  }

  @override
  String get grpJInviteSendAll => '[Šéñð íñṽíţåţíöñš ~~~~~]';

  @override
  String grpJInviteSendCount(int count) {
    return '[Šéñð $count ~~~~]';
  }

  @override
  String grpJInvited(int count) {
    return '[Íñṽíţéð $count. ~~~~~]';
  }

  @override
  String grpJInviteSkipped(String emails) {
    return '[Åłŕéåðý ɱéɱƀéŕš, šķíþþéð: $emails ~~~~~~~~~~~]';
  }

  @override
  String get grpJExpiresAfter => '[Éxþíŕéš åƒţéŕ ~~~~]';

  @override
  String grpJDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ðåýš',
      one: '$count ðåý',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpJMaxUses => '[Måx ûšéš ~~]';

  @override
  String get grpJMaxUsesHelp => '[Łéåṽé éɱþţý ƒöŕ ûñłíɱíţéð. ~~~~~~~~]';

  @override
  String grpJMaxUsesInvalid(int max) {
    return '[Éñţéŕ å ñûɱƀéŕ ƒŕöɱ 1 ţö $max, öŕ łéåṽé éɱþţý. ~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpJCreateLink => '[Çŕéåţé łíñķ ~~~]';

  @override
  String get grpJCopyLink => '[Çöþý łíñķ ~~~]';

  @override
  String get grpJRole => '[Ŕöłé ~]';

  @override
  String get grpJInvitationTitle => '[Íñṽíţåţíöñ ~~~]';

  @override
  String get grpJJoin => '[Ĵöíñ ~]';

  @override
  String get grpJDecline => '[Ðéçłíñé ~~]';

  @override
  String get grpJGoToTaskForge => '[Ĝö ţö ŢåšķFöŕĝé ~~~~~]';

  @override
  String get grpJInvitedToJoin => '[Ýöû ĥåṽé ƀééñ íñṽíţéð ţö ĵöíñ ~~~~~~~~~]';

  @override
  String grpJInviterInvitedYou(String name) {
    return '[$name íñṽíţéð ýöû ţö ĵöíñ ~~~~~~~~]';
  }

  @override
  String get grpJBack => '[ßåçķ ~]';

  @override
  String get grpJMembers => '[Méɱƀéŕš ~~]';

  @override
  String get grpJInvite => '[Íñṽíţé ~~]';

  @override
  String get grpJPending => '[Þéñðíñĝ ~~]';

  @override
  String grpJJoined(String date) {
    return '[Ĵöíñéð $date ~~~~]';
  }

  @override
  String get grpJRemoveFromWorkspace => '[Ŕéɱöṽé ƒŕöɱ ŵöŕķšþåçé ~~~~~~~]';

  @override
  String get grpJSearchMembers => '[Šéåŕçĥ ɱéɱƀéŕš ~~~~]';

  @override
  String grpJRemoveMember(String name) {
    return '[Ŕéɱöṽé $name ~~~~]';
  }

  @override
  String get grpJOwnerCannotLeave =>
      '[Ýöû öŵñ ţĥíš ŵöŕķšþåçé, šö ýöû çåññöţ łéåṽé íţ. Öŵñéŕšĥíþ çåññöţ ƀé ţŕåñšƒéŕŕéð ýéţ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpJLeaveWorkspace => '[Łéåṽé ŵöŕķšþåçé ~~~~~]';

  @override
  String grpJRemoveMemberTitle(String name) {
    return '[Ŕéɱöṽé $name? ~~~~]';
  }

  @override
  String get grpJRemoveMemberBody =>
      '[Ţĥéý łöšé åççéšš ţö ţĥíš ŵöŕķšþåçé. Ýöû çåñ íñṽíţé ţĥéɱ åĝåíñ łåţéŕ. ~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpJRemove => '[Ŕéɱöṽé ~~]';

  @override
  String grpJLeaveTitle(String name) {
    return '[Łéåṽé $name? ~~~~]';
  }

  @override
  String get grpJLeaveBody =>
      '[Ýöû ŵíłł łöšé åççéšš ţö ţĥíš ŵöŕķšþåçé ûñţíł šöɱéöñé íñṽíţéš ýöû åĝåíñ. ~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpJLeave => '[Łéåṽé ~]';

  @override
  String grpJErrorRetry(String error) {
    return '[$error Ŕéţŕý ~~~~]';
  }

  @override
  String get grpJLinkCopied => '[Łíñķ çöþíéð. ~~~~]';

  @override
  String get grpJNoInvitations => '[Ñö íñṽíţåţíöñš ýéţ. ~~~~~~]';

  @override
  String get grpJInvitationResent => '[Íñṽíţåţíöñ ŕéšéñţ. ~~~~~~]';

  @override
  String get grpJResend => '[Ŕéšéñð ~~]';

  @override
  String get grpJRevoke => '[Ŕéṽöķé ~~]';

  @override
  String get grpJStatePending => '[Þéñðíñĝ ~~]';

  @override
  String get grpJStateExpired => '[Éxþíŕéð ~~]';

  @override
  String get grpJStateRevoked => '[Ŕéṽöķéð ~~]';

  @override
  String get grpJStateUsedUp => '[Ûšéð ûþ ~~]';

  @override
  String grpJUsesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ûšéš',
      one: '$count ûšé',
    );
    return '[$_temp0 ~~~~~~~~~~~~~~~~~]';
  }

  @override
  String grpJUsesOfMax(int uses, int max) {
    return '[$uses/$max ûšéš ~~~~~]';
  }

  @override
  String get grpJInviteLink => '[Íñṽíţé łíñķ ~~~]';

  @override
  String grpJInvitationMeta(String name, String date) {
    return '[ƀý $name · éxþíŕéš $date ~~~~~~~~]';
  }

  @override
  String get grpJChangeRole => '[Çĥåñĝé ŕöłé ~~~]';

  @override
  String get grpJBlockOptions => '[ßłöçķ öþţíöñš ~~~~]';

  @override
  String get grpJMoveUp => '[Möṽé ûþ ~~]';

  @override
  String get grpJMoveDown => '[Möṽé ðöŵñ ~~~]';

  @override
  String get grpJAddBlockBelow => '[Åðð ƀłöçķ ƀéłöŵ ~~~~~]';

  @override
  String get grpJDelete => '[Ðéłéţé ~~]';

  @override
  String grpJTurnInto(String label) {
    return '[Ţûŕñ íñţö $label ~~~~~]';
  }

  @override
  String get grpJClickToWrite => '[Çłíçķ ĥéŕé ţö šţåŕţ ŵŕíţíñĝ ~~~~~~~~~]';

  @override
  String get grpJAddBlock => '[Åðð ƀłöçķ ~~~]';

  @override
  String get grpJDocs => '[Ðöçš ~]';

  @override
  String get grpJPickPage => '[Þíçķ å þåĝé, öŕ çŕéåţé öñé. ~~~~~~~~~]';

  @override
  String get grpJNoMatchingBlocks => '[Ñö ɱåţçĥíñĝ ƀłöçķš ~~~~~~]';

  @override
  String get grpJNoMatchingPages => '[Ñö ɱåţçĥíñĝ þåĝéš ~~~~~]';

  @override
  String get grpJTableRow => '[Ŕöŵ ~]';

  @override
  String get grpJTableColumn => '[Çöłûɱñ ~~]';

  @override
  String get grpJNoImageAddress => '[Ñö íɱåĝé åððŕéšš ýéţ ~~~~~~]';

  @override
  String get grpJImageLoadFailed => '[Íɱåĝé çöûłð ñöţ łöåð ~~~~~~]';

  @override
  String get grpJEditImage => '[Éðíţ íɱåĝé ~~~]';

  @override
  String get grpJLoadingTask => '[Łöåðíñĝ ţåšķ... ~~~~~]';

  @override
  String get grpJNoAccessTask => '[Ñö åççéšš ţö ţĥíš ţåšķ ~~~~~~~]';

  @override
  String grpJUnknownBlock(String type) {
    return '[Ţĥíš ƀłöçķ ($type) ñééðš å ñéŵéŕ ṽéŕšíöñ öƒ ŢåšķFöŕĝé. Íţ íš ķéþţ åš íţ íš. ~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpJLinkAPage => '[Łíñķ å þåĝé ~~~]';

  @override
  String get grpJNoPagesYetLong => '[Ţĥéŕé åŕé ñö þåĝéš ýéţ. ~~~~~~~]';

  @override
  String get grpJRelatedDocs => '[Ŕéłåţéð ðöçš ~~~~]';

  @override
  String get grpJNoPagesYet => '[Ñö þåĝéš ýéţ. ~~~~]';

  @override
  String get grpJLinked => '[Łíñķéð ~~]';

  @override
  String get grpJEmbedded => '[Éɱƀéððéð ~~]';

  @override
  String get grpJUnlink => '[Ûñłíñķ ~~]';

  @override
  String grpJChangeTone(String tone) {
    return '[Çĥåñĝé ţöñé ($tone) ~~~~~~]';
  }

  @override
  String get grpJBold => '[ßöłð ~]';

  @override
  String get grpJItalic => '[Íţåłíç ~~]';

  @override
  String get grpJStrikethrough => '[Šţŕíķéţĥŕöûĝĥ ~~~~]';

  @override
  String get grpJCode => '[Çöðé ~]';

  @override
  String get grpJHintParagraph =>
      '[Ţýþé \'/\' ƒöŕ ƀłöçķš, \'[[\' ţö ɱéñţíöñ å þåĝé ~~~~~~~~~~~~~~]';

  @override
  String grpJHintHeading(int level) {
    return '[Ĥéåðíñĝ $level ~~~~~]';
  }

  @override
  String get grpJCodeLanguageHint => '[łåñĝûåĝé ~~]';

  @override
  String get grpJUndo => '[Ûñðö ~]';

  @override
  String get grpJRestore => '[Ŕéšţöŕé ~~]';

  @override
  String get grpJName => '[Ñåɱé ~]';

  @override
  String grpJWorkspaceDeleted(String name) {
    return '[\"$name\" ðéłéţéð. Ŕéšţöŕåƀłé ƒöŕ 7 ðåýš. ~~~~~~~~~~~~~]';
  }

  @override
  String get grpJDangerZone => '[Ðåñĝéŕ žöñé ~~~]';

  @override
  String get grpJDangerZoneBody =>
      '[Ðéłéţíñĝ å ŵöŕķšþåçé ĥíðéš íţ ƒöŕ éṽéŕýöñé. Ýöû çåñ ŕéšţöŕé íţ ƒöŕ 7 ðåýš. ~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpJDeleteWorkspace => '[Ðéłéţé ŵöŕķšþåçé ~~~~~]';

  @override
  String get grpJDeleteWorkspaceQ => '[Ðéłéţé ŵöŕķšþåçé? ~~~~~]';

  @override
  String grpJTypeNameToConfirm(String name) {
    return '[Ţýþé \"$name\" ţö çöñƒíŕɱ ~~~~~~~~]';
  }

  @override
  String get grpJNewWorkspace => '[Ñéŵ ŵöŕķšþåçé ~~~~]';

  @override
  String get grpJCreateYourWorkspace => '[Çŕéåţé ýöûŕ ŵöŕķšþåçé ~~~~~~~]';

  @override
  String get grpJWorkspaceHolds =>
      '[Å ŵöŕķšþåçé ĥöłðš ýöûŕ ţéåɱ\'š þŕöĵéçţš åñð ţåšķš. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpJUrl => '[ÛŔŁ ~]';

  @override
  String get grpJCreateWorkspace => '[Çŕéåţé ŵöŕķšþåçé ~~~~~]';

  @override
  String get grpJRecentlyDeleted => '[Ŕéçéñţłý ðéłéţéð ~~~~~]';

  @override
  String get grpJSwitchWorkspace => '[Šŵíţçĥ ŵöŕķšþåçé ~~~~~]';

  @override
  String get grpJTimerRunning => '[Ţíɱéŕ ŕûññíñĝ ~~~~]';

  @override
  String grpJTimerStoppedOn(String key, String title) {
    return '[Šţöþþéð ţĥé ţíɱéŕ öñ $key $title ~~~~~~~~~~~]';
  }

  @override
  String get grpJTime => '[Ţíɱé ~]';

  @override
  String get grpJStop => '[Šţöþ ~]';

  @override
  String get grpJStartTimer => '[Šţåŕţ ţíɱéŕ ~~~]';

  @override
  String get grpJAddTime => '[Åðð ţíɱé ~~]';

  @override
  String grpJTimeOfEstimate(String logged, String estimate) {
    return '[$logged öƒ $estimate ~~~~~~~]';
  }

  @override
  String grpJTimeLogged(String logged) {
    return '[$logged łöĝĝéð ~~~~~]';
  }

  @override
  String grpJTimeBillable(String duration) {
    return '[$duration ƀíłłåƀłé ~~~~~~]';
  }

  @override
  String get grpJChangeEstimate => '[Çĥåñĝé éšţíɱåţé ~~~~~]';

  @override
  String get grpJSetEstimate => '[Šéţ éšţíɱåţé ~~~~]';

  @override
  String get grpJRunning => '[Ŕûññíñĝ ~~]';

  @override
  String get grpJLoggedLabel => '[Łöĝĝéð ~~]';

  @override
  String get grpJYou => '[ýöû ~]';

  @override
  String get grpJBillableSuffix => '[ƀíłłåƀłé ~~]';

  @override
  String get grpJOverlapsEntry => '[Öṽéŕłåþš åñöţĥéŕ éñţŕý ~~~~~~~]';

  @override
  String get grpJOver24h => '[Öṽéŕ 24 ĥ: çĥéçķ íţ ~~~~~~]';

  @override
  String get grpJEdit => '[Éðíţ ~]';

  @override
  String get grpJStopTheTimer => '[Šţöþ ţĥé ţíɱéŕ ~~~~]';

  @override
  String get grpJRoleActions => '[Ŕöłé åçţíöñš ~~~~]';

  @override
  String get grpJRename => '[Ŕéñåɱé ~~]';

  @override
  String get grpJBuiltInReadOnly => '[ßûíłţ-íñ, ŕéåð-öñłý ~~~~~~]';

  @override
  String get grpJRolesAndPermissions => '[Ŕöłéš åñð þéŕɱíššíöñš ~~~~~~~]';

  @override
  String get grpJNewRole => '[Ñéŵ ŕöłé ~~]';

  @override
  String get grpJActivity => '[Åçţíṽíţý ~~]';

  @override
  String get grpJNoActivity => '[Ñö åçţíṽíţý ýéţ. ~~~~~]';

  @override
  String get grpJDebugTitle => '[ŢåšķFöŕĝé — çöññéçţíṽíţý ~~~~~~~~]';

  @override
  String grpJPingLabel(String label) {
    return '[$label þíñĝ ~~~~]';
  }

  @override
  String grpJPingError(String error) {
    return '[éŕŕöŕ: $error ~~~~]';
  }

  @override
  String get grpKClosePalette => '[Çłöšé ţĥé çöɱɱåñð þåłéţţé ~~~~~~~~]';

  @override
  String get grpKGroupGeneral => '[Ĝéñéŕåł ~~]';

  @override
  String get grpKGroupGoTo => '[Ĝö ţö ~]';

  @override
  String get grpKGroupProjects => '[Þŕöĵéçţš ~~]';

  @override
  String get grpKGroupWorkspace => '[Ŵöŕķšþåçé ~~~]';

  @override
  String get grpKGroupAccount => '[Åççöûñţ ~~]';

  @override
  String get grpKGroupThisProject => '[Ţĥíš þŕöĵéçţ ~~~~]';

  @override
  String get grpKGroupDocs => '[Ðöçš ~]';

  @override
  String get grpKGroupDashboards => '[Ðåšĥƀöåŕðš ~~~]';

  @override
  String get grpKGroupListView => '[Łíšţ ṽíéŵ ~~~]';

  @override
  String get grpKGroupThisTask => '[Ţĥíš ţåšķ ~~~]';

  @override
  String grpKGoTo(String title) {
    return '[Ĝö ţö $title ~~~~]';
  }

  @override
  String grpKProjectPageOf(String title) {
    return '[$title öƒ ţĥíš þŕöĵéçţ ~~~~~~~]';
  }

  @override
  String get grpKPaletteOpen => '[Öþéñ ţĥé çöɱɱåñð þåłéţţé ~~~~~~~~]';

  @override
  String get grpKSearch => '[Šéåŕçĥ ~~]';

  @override
  String get grpKSearchSem =>
      '[Šéåŕçĥ ţåšķš, çöɱɱéñţš, þŕöĵéçţš åñð þéöþłé ~~~~~~~~~~~~~~]';

  @override
  String get grpKShortcuts => '[Ķéýƀöåŕð šĥöŕţçûţš ~~~~~~]';

  @override
  String get grpKShortcutsSem => '[Šĥöŵ ţĥé ķéýƀöåŕð šĥöŕţçûţš ~~~~~~~~~]';

  @override
  String get grpKTHome => '[Ĥöɱé ~]';

  @override
  String get grpKTInbox => '[Íñƀöx ~]';

  @override
  String get grpKTCalendar => '[Ŵöŕķšþåçé çåłéñðåŕ ~~~~~~]';

  @override
  String get grpKTDocs => '[Ðöçš ~]';

  @override
  String get grpKTDashboards => '[Ðåšĥƀöåŕðš ~~~]';

  @override
  String get grpKTTimesheet => '[Ţíɱéšĥééţ ~~~]';

  @override
  String get grpKTMembers => '[Méɱƀéŕš ~~]';

  @override
  String get grpKTArchivedProjects => '[Åŕçĥíṽéð þŕöĵéçţš ~~~~~]';

  @override
  String get grpKTPrivateProjects => '[Þŕíṽåţé þŕöĵéçţš ~~~~~]';

  @override
  String get grpKTWorkspaceSettings => '[Ŵöŕķšþåçé šéţţíñĝš ~~~~~~]';

  @override
  String get grpKAuditLog => '[Åûðíţ łöĝ ~~~]';

  @override
  String get grpKAuditSem => '[Ĝö ţö ţĥé åûðíţ łöĝ ~~~~~~]';

  @override
  String get grpKTRoles => '[Ŕöłéš åñð þéŕɱíššíöñš ~~~~~~~]';

  @override
  String get grpKTCreateWorkspace => '[Çŕéåţé å ŵöŕķšþåçé ~~~~~~]';

  @override
  String get grpKTNotifPrefs => '[Ñöţíƒíçåţíöñ þŕéƒéŕéñçéš ~~~~~~~~]';

  @override
  String get grpKTDevices => '[Šíĝñéð-íñ ðéṽíçéš ~~~~~]';

  @override
  String get grpKTChangePassword => '[Çĥåñĝé þåššŵöŕð ~~~~~]';

  @override
  String get grpKTTasks => '[Ţåšķš ~]';

  @override
  String get grpKTSprints => '[Šþŕíñţš ~~]';

  @override
  String get grpKTAutomations => '[Åûţöɱåţíöñš ~~~]';

  @override
  String get grpKTWorkflow => '[Ŵöŕķƒłöŵ ~~]';

  @override
  String get grpKTCustomFields => '[Çûšţöɱ ƒíéłðš ~~~~]';

  @override
  String get grpKTProjectSettings => '[Þŕöĵéçţ šéţţíñĝš ~~~~~]';

  @override
  String get grpKSwitchWs => '[Šŵíţçĥ ŵöŕķšþåçé ~~~~~]';

  @override
  String get grpKSwitchWsSem => '[Šŵíţçĥ ţö åñöţĥéŕ ŵöŕķšþåçé ~~~~~~~~~]';

  @override
  String get grpKToggleDark => '[Ţöĝĝłé ðåŕķ ɱöðé ~~~~~]';

  @override
  String get grpKToggleDarkSem =>
      '[Šŵíţçĥ ƀéţŵééñ ţĥé łíĝĥţ åñð ţĥé ðåŕķ ţĥéɱé ~~~~~~~~~~~~~~]';

  @override
  String get grpKCreateProject => '[Çŕéåţé å þŕöĵéçţ ~~~~~]';

  @override
  String get grpKCreateDoc => '[Çŕéåţé å ðöç ~~~~]';

  @override
  String get grpKCreateDashboard => '[Çŕéåţé å ðåšĥƀöåŕð ~~~~~~]';

  @override
  String get grpKCreateSprint => '[Çŕéåţé å šþŕíñţ ~~~~~]';

  @override
  String get grpKCreateSprintSem =>
      '[Çŕéåţé å šþŕíñţ íñ ţĥíš þŕöĵéçţ ~~~~~~~~~~]';

  @override
  String get grpKInviteMember => '[Íñṽíţé å ɱéɱƀéŕ ~~~~~]';

  @override
  String get grpKInviteMemberSem =>
      '[Íñṽíţé šöɱéöñé ţö ţĥíš ŵöŕķšþåçé ~~~~~~~~~~]';

  @override
  String get grpKTImportExport => '[Íɱþöŕţ åñð éxþöŕţ ~~~~~]';

  @override
  String get grpKTOffline => '[Öƒƒłíñé åñð šţöŕåĝé ~~~~~~]';

  @override
  String get grpKSignOut => '[Šíĝñ öûţ ~~]';

  @override
  String get grpKSignOutSem => '[Šíĝñ öûţ öƒ ţĥíš ðéṽíçé ~~~~~~~]';

  @override
  String get grpKNewTask => '[Ñéŵ ţåšķ ~~]';

  @override
  String get grpKNewTaskSem => '[Çŕéåţé å ţåšķ íñ ţĥíš þŕöĵéçţ ~~~~~~~~~]';

  @override
  String get grpKRenameTask => '[Ŕéñåɱé ţĥé ţåšķ ûñðéŕ ţĥé çûŕšöŕ ~~~~~~~~~~]';

  @override
  String get grpKRenameTaskSem =>
      '[Ŕéñåɱé ţĥé ţåšķ ţĥé çûŕšöŕ íš öñ íñ ţĥé łíšţ ~~~~~~~~~~~~~~]';

  @override
  String get grpKChangeStatus => '[Çĥåñĝé šţåţûš öƒ ţĥíš ţåšķ ~~~~~~~~]';

  @override
  String get grpKChangeStatusSem =>
      '[Çĥåñĝé ţĥé šţåţûš öƒ ţĥé öþéñ ţåšķ ~~~~~~~~~~~]';

  @override
  String get grpKAssignMe => '[Åššíĝñ ţĥíš ţåšķ ţö ɱé ~~~~~~~]';

  @override
  String get grpKAssignMeSem => '[Åššíĝñ ţĥé öþéñ ţåšķ ţö ɱé ~~~~~~~~]';

  @override
  String get grpKTimerStart => '[Šţåŕţ ţĥé ţíɱéŕ öñ ţĥíš ţåšķ ~~~~~~~~~]';

  @override
  String get grpKTimerStartSem =>
      '[Šţåŕţ ţĥé ţíɱéŕ öñ ţĥé öþéñ ţåšķ ~~~~~~~~~~]';

  @override
  String get grpKTimerStop => '[Šţöþ ţĥé ţíɱéŕ ~~~~]';

  @override
  String get grpKTimerStopSem => '[Šţöþ ţĥé ŕûññíñĝ ţíɱéŕ ~~~~~~~]';

  @override
  String get grpKViewList => '[Łíšţ ṽíéŵ ~~~]';

  @override
  String get grpKViewBoard => '[ßöåŕð ṽíéŵ ~~~]';

  @override
  String get grpKViewCalendar => '[Çåłéñðåŕ ṽíéŵ ~~~~]';

  @override
  String get grpKViewTimeline => '[Ţíɱéłíñé ṽíéŵ ~~~~]';

  @override
  String get grpKShowList => '[Šĥöŵ ţĥíš þŕöĵéçţ åš å łíšţ ~~~~~~~~~]';

  @override
  String get grpKShowBoard => '[Šĥöŵ ţĥíš þŕöĵéçţ åš å ƀöåŕð ~~~~~~~~~]';

  @override
  String get grpKShowCalendar => '[Šĥöŵ ţĥíš þŕöĵéçţ åš å çåłéñðåŕ ~~~~~~~~~~]';

  @override
  String get grpKShowTimeline => '[Šĥöŵ ţĥíš þŕöĵéçţ åš å ţíɱéłíñé ~~~~~~~~~~]';

  @override
  String get grpLGeneric => '[Šöɱéţĥíñĝ ŵéñţ ŵŕöñĝ. Ţŕý åĝåíñ. ~~~~~~~~~~]';

  @override
  String get grpLNetCheck =>
      '[Çåññöţ ŕéåçĥ ţĥé šéŕṽéŕ. Çĥéçķ ýöûŕ çöññéçţíöñ åñð ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLNetCheckShort =>
      '[Çöûłð ñöţ ŕéåçĥ ţĥé šéŕṽéŕ. Çĥéçķ ýöûŕ çöññéçţíöñ. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpLNetTry =>
      '[Çöûłð ñöţ ŕéåçĥ ţĥé šéŕṽéŕ. Ţŕý åĝåíñ. ~~~~~~~~~~~~]';

  @override
  String get grpLNetOffline =>
      '[Ţĥíš ñééðš å çöññéçţíöñ ţö ţĥé šéŕṽéŕ. Íţ ŵöŕķš åĝåíñ öñçé ýöû åŕé ƀåçķ öñłíñé. ~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLNoConn =>
      '[Ñö çöññéçţíöñ. Çĥéçķ íţ åñð ţŕý åĝåíñ. ~~~~~~~~~~~~]';

  @override
  String get grpLNoPerm => '[Ýöû ðö ñöţ ĥåṽé þéŕɱíššíöñ. ~~~~~~~~~]';

  @override
  String get grpLNoPermDo =>
      '[Ýöû ðö ñöţ ĥåṽé þéŕɱíššíöñ ţö ðö ţĥåţ. ~~~~~~~~~~~~]';

  @override
  String get grpLNoAccess => '[Ýöû ðö ñöţ ĥåṽé åççéšš ţö ţĥåţ. ~~~~~~~~~~]';

  @override
  String get grpLCheckValues => '[Çĥéçķ ţĥé ṽåłûéš åñð ţŕý åĝåíñ. ~~~~~~~~~~]';

  @override
  String get grpLNotValid => '[Ţĥåţ íš ñöţ ṽåłíð. ~~~~~~]';

  @override
  String get grpLArchived =>
      '[Ţĥíš þŕöĵéçţ íš åŕçĥíṽéð. Ŕéšţöŕé íţ ţö ɱåķé çĥåñĝéš. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLGone => '[Ţĥåţ ñö łöñĝéŕ éxíšţš. ~~~~~~~]';

  @override
  String get grpLTaskConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš ţåšķ ƒíŕšţ. ~~~~~~~~~~~~]';

  @override
  String get grpLTaskTransition =>
      '[Ţĥé ŵöŕķƒłöŵ ðöéš ñöţ åłłöŵ ţĥåţ ɱöṽé. ~~~~~~~~~~~~]';

  @override
  String get grpLTaskHasSubtasks =>
      '[Ţĥíš ţåšķ ĥåš šûƀţåšķš: çĥööšé ŵĥåţ ĥåþþéñš ţö ţĥéɱ. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLTaskCycle =>
      '[Å ţåšķ çåññöţ ƀéçöɱé å šûƀţåšķ öƒ íţšéłƒ öŕ öƒ öñé öƒ íţš öŵñ šûƀţåšķš. ~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String grpLTaskBlocked(String detail) {
    return '[ßłöçķéð ƀý $detail: ƒíñíšĥ ţĥöšé ƒíŕšţ. ~~~~~~~~~~~~~]';
  }

  @override
  String grpLTaskLinkCycle(String detail) {
    return '[Ţĥöšé ţåšķš ŵöûłð ƀłöçķ éåçĥ öţĥéŕ íñ å łööþ: $detail. ~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpLTaskLinkExists =>
      '[Ţĥéšé ţåšķš åŕé åłŕéåðý łíñķéð ţĥåţ ŵåý. ~~~~~~~~~~~~~]';

  @override
  String get grpLFieldRequired => '[Å ŕéqûíŕéð ƒíéłð ĥåš ñö ṽåłûé. ~~~~~~~~~~]';

  @override
  String get grpLTaskGone => '[Ţĥåţ ţåšķ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpLCommentConflict =>
      '[Šöɱéöñé çĥåñĝéð ţĥíš çöɱɱéñţ ƒíŕšţ. ~~~~~~~~~~~]';

  @override
  String get grpLCommentLocked =>
      '[Ţĥåţ çöɱɱéñţ çåñ ñö łöñĝéŕ ƀé éðíţéð. ~~~~~~~~~~~~]';

  @override
  String get grpLMentionNoAccess =>
      '[Šöɱéƀöðý ýöû ɱéñţíöñéð çåññöţ šéé ţĥíš ţåšķ. ~~~~~~~~~~~~~~]';

  @override
  String get grpLCommentCheck =>
      '[Çĥéçķ ţĥé çöɱɱéñţ åñð ţŕý åĝåíñ. ~~~~~~~~~~]';

  @override
  String get grpLCommentGone => '[Ţĥåţ çöɱɱéñţ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~~]';

  @override
  String get grpLSlugTaken => '[Ţĥåţ ÛŔŁ íš ţåķéñ ~~~~~]';

  @override
  String get grpLWsStale =>
      '[Ţĥíš ŵöŕķšþåçé ŵåš çĥåñĝéð éłšéŵĥéŕé. Ŕéƒŕéšĥ ţö šéé ţĥé łåţéšţ ṽéŕšíöñ. ~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLWsNotRestorable =>
      '[Ţĥíš ŵöŕķšþåçé çåñ ñö łöñĝéŕ ƀé ŕéšţöŕéð. ~~~~~~~~~~~~~]';

  @override
  String get grpLOwnerNeeded =>
      '[Å ŵöŕķšþåçé ñééðš åţ łéåšţ öñé öŵñéŕ. ~~~~~~~~~~~~]';

  @override
  String get grpLInvEmailMismatch =>
      '[Ţĥíš íñṽíţåţíöñ íš ƒöŕ åñöţĥéŕ éɱåíł åððŕéšš. ~~~~~~~~~~~~~~~]';

  @override
  String get grpLInvExpired =>
      '[Ţĥíš íñṽíţåţíöñ ĥåš éxþíŕéð. Åšķ ƒöŕ å ñéŵ öñé. ~~~~~~~~~~~~~~~]';

  @override
  String get grpLInvRevoked => '[Ţĥíš íñṽíţåţíöñ ŵåš ŕéṽöķéð. ~~~~~~~~~]';

  @override
  String get grpLInvBeforeRemoval =>
      '[Ţĥíš íñṽíţåţíöñ þŕéðåţéš ýöûŕ ŕéɱöṽåł. Åšķ ƒöŕ å ñéŵ öñé. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLInvUsedUp =>
      '[Ţĥíš íñṽíţåţíöñ ĥåš åłŕéåðý ƀééñ ûšéð ûþ. ~~~~~~~~~~~~~]';

  @override
  String get grpLInvNotFound => '[Ţĥíš íñṽíţåţíöñ ðöéš ñöţ éxíšţ. ~~~~~~~~~~]';

  @override
  String get grpLInvRate =>
      '[Ţöö ɱåñý íñṽíţåţíöñš ĵûšţ ñöŵ. Ŵåíţ å ŵĥíłé åñð ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLInvExists =>
      '[Ţĥåţ þéŕšöñ íš åłŕéåðý íñṽíţéð öŕ å ɱéɱƀéŕ. ~~~~~~~~~~~~~~]';

  @override
  String get grpLWfInvalid =>
      '[Ţĥé ŵöŕķƒłöŵ ĥåš þŕöƀłéɱš. Fíx ţĥéɱ ţö šåṽé. ~~~~~~~~~~~~~~]';

  @override
  String get grpLWfConflict =>
      '[Šöɱéöñé éłšé šåṽéð ţĥé ŵöŕķƒłöŵ ƒíŕšţ. Ýöûŕ çĥåñĝéš åŕé šţíłł ĥéŕé: ŕéṽíéŵ ŵĥåţ çĥåñĝéð åñð šåṽé åĝåíñ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLProjectGone => '[Ţĥåţ þŕöĵéçţ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~~]';

  @override
  String get grpLDashDenied =>
      '[Ýöû åŕé ñöţ åłłöŵéð ţö ðö ţĥåţ öñ ţĥíš ðåšĥƀöåŕð. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpLDashNotFound =>
      '[Ţĥåţ ðåšĥƀöåŕð öŕ ŵíðĝéţ íš ñöţ åṽåíłåƀłé. ~~~~~~~~~~~~~~]';

  @override
  String get grpLDashHeavy =>
      '[Ţĥíš ŵíðĝéţ ţåķéš ţöö łöñĝ ţö çöɱþûţé. Ñåŕŕöŵ íţš ƒíłţéŕ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLDashConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš ðåšĥƀöåŕð. Ŕéłöåð íţ åñð ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLNotifGone =>
      '[Ţĥåţ ñöţíƒíçåţíöñ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~~~]';

  @override
  String get grpLViewConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš łåýöûţ ƒíŕšţ. ~~~~~~~~~~~~~]';

  @override
  String get grpLViewInvalid => '[Ţĥåţ łåýöûţ íš ñöţ ṽåłíð. ~~~~~~~~]';

  @override
  String get grpLViewNameTaken =>
      '[Å łåýöûţ ŵíţĥ ţĥåţ ñåɱé åłŕéåðý éxíšţš. ~~~~~~~~~~~~~]';

  @override
  String get grpLViewLimit =>
      '[Ţĥåţ íš ţĥé ɱöšţ łåýöûţš ýöû çåñ ķééþ ĥéŕé. ~~~~~~~~~~~~~~]';

  @override
  String get grpLViewGone => '[Ţĥåţ łåýöûţ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpLAutoDenied =>
      '[Ýöû ñééð ţĥé \"ɱåñåĝé åûţöɱåţíöñš\" þéŕɱíššíöñ ƒöŕ ţĥåţ. ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLAutoConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš ŕûłé ƒíŕšţ. Łöåð ţĥé łåţéšţ åñð ŕéţŕý. ~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLImpCannot => '[Ţĥåţ çåññöţ ƀé ðöñé ñöŵ. ~~~~~~~~]';

  @override
  String get grpLImpTooBig =>
      '[Ţĥåţ ƒíłé íš łåŕĝéŕ ţĥåñ ţĥíš šéŕṽéŕ åççéþţš. ~~~~~~~~~~~~~~~]';

  @override
  String get grpLImpDenied =>
      '[Öñłý åðɱíñš çåñ íɱþöŕţ åñð éxþöŕţ ðåţå. ~~~~~~~~~~~~~]';

  @override
  String get grpLImpNotFound => '[Ţĥåţ íɱþöŕţ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpLAuditDenied =>
      '[Ýöû åŕé ñöţ åłłöŵéð ţö ŕéåð ţĥé åûðíţ łöĝ. ~~~~~~~~~~~~~~]';

  @override
  String get grpLAuditTaskNA => '[Ţĥåţ ţåšķ íš ñöţ åṽåíłåƀłé. ~~~~~~~~~]';

  @override
  String get grpLAuditFilters => '[Ţĥöšé ƒíłţéŕš åŕé ñöţ ṽåłíð. ~~~~~~~~~]';

  @override
  String get grpLSprintConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš ƒíŕšţ. Ŕéłöåð åñð ŕéţŕý. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpLFieldNameTaken =>
      '[Å ƒíéłð ŵíţĥ ţĥåţ ñåɱé åłŕéåðý éxíšţš. ~~~~~~~~~~~~]';

  @override
  String grpLFieldLimit(int count) {
    return '[Å þŕöĵéçţ çåñ ĥåṽé åţ ɱöšţ $count åçţíṽé ƒíéłðš. ~~~~~~~~~~~~~~~~]';
  }

  @override
  String get grpLFieldNeedsRemap =>
      '[Šöɱé ŕéɱöṽéð öþţíöñš åŕé šţíłł ûšéð: çĥööšé ŵĥåţ ţĥéíŕ ṽåłûéš ƀéçöɱé. ~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLFieldConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš ƒíéłð ƒíŕšţ; ŕéłöåð åñð ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLFieldGone => '[Ţĥåţ ƒíéłð ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpLFilterInvalid => '[Ţĥåţ ƒíłţéŕ íš ñöţ ṽåłíð. ~~~~~~~~]';

  @override
  String get grpLFilterNameTaken =>
      '[Å ƒíłţéŕ ŵíţĥ ţĥåţ ñåɱé åłŕéåðý éxíšţš ĥéŕé. ~~~~~~~~~~~~~~]';

  @override
  String get grpLFilterLimit =>
      '[Ţĥåţ íš ţĥé ɱöšţ ƒíłţéŕš ýöû çåñ ķééþ ĥéŕé. ~~~~~~~~~~~~~~]';

  @override
  String get grpLFilterGone => '[Ţĥåţ ƒíłţéŕ ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpLFilterConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš ƒíłţéŕ ƒíŕšţ. ~~~~~~~~~~~~~]';

  @override
  String get grpLAttTooBig =>
      '[Ţĥåţ ƒíłé íš łåŕĝéŕ ţĥåñ åñ åţţåçĥɱéñţ ɱåý ƀé. ~~~~~~~~~~~~~~~]';

  @override
  String get grpLAttQuota =>
      '[Ţĥíš ŵöŕķšþåçé ĥåš ûšéð åłł íţš šţöŕåĝé. ~~~~~~~~~~~~~]';

  @override
  String get grpLAttTooMany =>
      '[Ţöö ɱåñý ûþłöåðš åŕé öþéñ. Fíñíšĥ öŕ çåñçéł šöɱé ƒíŕšţ. ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLAttUnavailable =>
      '[Ţĥé ƒíłé çöûłð ñöţ ƀé çĥéçķéð ŕíĝĥţ ñöŵ. Ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLAttChunk =>
      '[Þåŕţ öƒ ţĥé ƒíłé ŵåš ñöţ ţåķéñ. Ţŕý åĝåíñ. ~~~~~~~~~~~~~~]';

  @override
  String get grpLAttRefusedPlain =>
      '[Ţĥåţ ķíñð öƒ ƒíłé íš ñöţ åççéþţéð. ~~~~~~~~~~~]';

  @override
  String grpLAttRefused(String detail) {
    return '[Ţĥåţ ƒíłé íš ñöţ åççéþţéð: $detail ~~~~~~~~~~~]';
  }

  @override
  String get grpLAttIncomplete =>
      '[Ţĥé ûþłöåð ðíð ñöţ ƒíñíšĥ. Ţŕý åĝåíñ. ~~~~~~~~~~~~]';

  @override
  String get grpLAttExpired => '[Ţĥåţ ûþłöåð éxþíŕéð. Ţŕý åĝåíñ. ~~~~~~~~~~]';

  @override
  String get grpLAttUnreadable => '[Çöûłð ñöţ ŕéåð ţĥåţ ƒíłé. ~~~~~~~~]';

  @override
  String get grpLAttNotAllowed =>
      '[Ýöû åŕé ñöţ åłłöŵéð ţö ðö ţĥåţ. ~~~~~~~~~~]';

  @override
  String get grpLAttArchived =>
      '[Ţĥíš þŕöĵéçţ íš åŕçĥíṽéð: ƒíłéš åŕé ŕéåð-öñłý. ~~~~~~~~~~~~~~~]';

  @override
  String get grpLAttGone =>
      '[Ţĥåţ íš ĝöñé: ţĥé ƒíłé, çöɱɱéñţ öŕ ţåšķ ŵåš ŕéɱöṽéð. ~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLDocNotFound =>
      '[Ţĥåţ þåĝé ðöéš ñöţ éxíšţ öŕ ýöû çåññöţ öþéñ íţ. ~~~~~~~~~~~~~~~]';

  @override
  String get grpLDocConflict =>
      '[Šöɱéöñé éłšé çĥåñĝéð ţĥíš þåĝé ƒíŕšţ. ~~~~~~~~~~~~]';

  @override
  String get grpLDocArchived => '[Ţĥåţ þåĝé íš åŕçĥíṽéð. ~~~~~~~]';

  @override
  String get grpLDocCycle => '[Å þåĝé çåññöţ ĝö ûñðéŕ íţšéłƒ. ~~~~~~~~~~]';

  @override
  String get grpLKeyTaken =>
      '[Ţĥåţ ķéý íš åłŕéåðý ûšéð ƀý åñöţĥéŕ þŕöĵéçţ. ~~~~~~~~~~~~~~]';

  @override
  String get grpLKeyLocked =>
      '[Ţĥé ķéý çåññöţ çĥåñĝé öñçé ţĥé þŕöĵéçţ ĥåš ţåšķš. ~~~~~~~~~~~~~~~~]';

  @override
  String get grpLLastMember =>
      '[Å þŕíṽåţé þŕöĵéçţ ñééðš åţ łéåšţ öñé ɱéɱƀéŕ. ~~~~~~~~~~~~~~]';

  @override
  String get grpLProjConflict =>
      '[Ţĥíš þŕöĵéçţ çĥåñĝéð íñ ţĥé ɱéåñţíɱé. Ŕéłöåðéð — ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLRoleBuiltin =>
      '[ßûíłţ-íñ ŕöłéš çåññöţ ƀé çĥåñĝéð öŕ ðéłéţéð. ~~~~~~~~~~~~~~]';

  @override
  String get grpLRoleNameTaken =>
      '[Å ŕöłé ŵíţĥ ţĥåţ ñåɱé åłŕéåðý éxíšţš. ~~~~~~~~~~~~]';

  @override
  String get grpLRoleGone => '[Ţĥåţ ŕöłé ñö łöñĝéŕ éxíšţš. ~~~~~~~~~]';

  @override
  String get grpLRoleConflict =>
      '[Ţĥíš ŕöłé çĥåñĝéð íñ ţĥé ɱéåñţíɱé. Ŕéłöåðéð — ţŕý åĝåíñ. ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpLRepeatInvalid => '[Ţĥåţ ŕéþéåţ íš ñöţ ṽåłíð. ~~~~~~~~]';

  @override
  String get grpLRepeatDenied =>
      '[Ýöû åŕé ñöţ åłłöŵéð ţö çĥåñĝé ĥöŵ ţĥíš ŕéþéåţš. ~~~~~~~~~~~~~~~]';

  @override
  String get grpMPriUrgent => '[Ûŕĝéñţ ~~]';

  @override
  String get grpMPriHigh => '[Ĥíĝĥ ~]';

  @override
  String get grpMPriNormal => '[Ñöŕɱåł ~~]';

  @override
  String get grpMPriLow => '[Łöŵ ~]';

  @override
  String get grpMPriNone => '[Ñöñé ~]';

  @override
  String get grpMLinkBlocks => '[ßłöçķš ~~]';

  @override
  String get grpMLinkBlockedBy => '[Íš ƀłöçķéð ƀý ~~~~]';

  @override
  String get grpMLinkRelates => '[Ŕéłåţéš ţö ~~~]';

  @override
  String get grpMLinkDuplicates => '[Ðûþłíçåţéš ~~~]';

  @override
  String get grpMLinkDuplicatedBy => '[Íš ðûþłíçåţéð ƀý ~~~~~]';

  @override
  String get grpMCatNotStarted => '[Ñöţ šţåŕţéð ~~~]';

  @override
  String get grpMCatActive => '[Åçţíṽé ~~]';

  @override
  String get grpMCatDone => '[Ðöñé ~]';

  @override
  String get grpMCatCancelled => '[Çåñçéłłéð ~~~]';

  @override
  String get grpMFtypeText => '[Ţéxţ ~]';

  @override
  String get grpMFtypeNumber => '[Ñûɱƀéŕ ~~]';

  @override
  String get grpMFtypeSelect => '[Šéłéçţ ~~]';

  @override
  String get grpMFtypeMulti => '[Mûłţí-šéłéçţ ~~~~]';

  @override
  String get grpMFtypeDate => '[Ðåţé ~]';

  @override
  String get grpMFtypeCheckbox => '[Çĥéçķƀöx ~~]';

  @override
  String get grpMFtypeUrl => '[ÛŔŁ ~]';

  @override
  String get grpMFtypeUser => '[Ûšéŕ ~]';

  @override
  String get grpMFtypeMoney => '[Möñéý ~]';

  @override
  String get grpMTrigTaskCreated => '[Å ţåšķ íš çŕéåţéð ~~~~~]';

  @override
  String get grpMTrigStatusChanged => '[Å šţåţûš çĥåñĝéš ~~~~~]';

  @override
  String get grpMTrigFieldChanged => '[Å ƒíéłð çĥåñĝéš ~~~~~]';

  @override
  String get grpMTrigAssigned => '[Šöɱéöñé íš åššíĝñéð ~~~~~~]';

  @override
  String get grpMTrigDueDateReached => '[Å ðûé ðåţé íš ŕéåçĥéð ~~~~~~~]';

  @override
  String get grpMTrigCommentAdded => '[Å çöɱɱéñţ íš åððéð ~~~~~~]';

  @override
  String get grpMActSetField => '[Šéţ å ƒíéłð ~~~]';

  @override
  String get grpMActSetStatus => '[Šéţ ţĥé šţåţûš ~~~~]';

  @override
  String get grpMActSetAssignee => '[Çĥåñĝé åššíĝñééš ~~~~~]';

  @override
  String get grpMActAddComment => '[Åðð å çöɱɱéñţ ~~~~]';

  @override
  String get grpMActCreateSubtask => '[Çŕéåţé å šûƀţåšķ ~~~~~]';

  @override
  String get grpMActNotify => '[Ñöţíƒý þéöþłé ~~~~]';

  @override
  String get grpMActWebhook => '[Çåłł å ŵéƀĥööķ ~~~~]';

  @override
  String get grpMRunSucceeded => '[Šûççééðéð ~~~]';

  @override
  String get grpMRunFailed => '[Fåíłéð ~~]';

  @override
  String get grpMRunSkippedCondition => '[Šķíþþéð: çöñðíţíöñ ~~~~~~]';

  @override
  String get grpMRunSkippedLoop => '[Šţöþþéð: łööþ ~~~~]';

  @override
  String get grpMRunSkippedRate => '[Þåûšéð: ţöö ɱåñý ŕûñš ~~~~~~~]';

  @override
  String get grpMWkNumber => '[Ñûɱƀéŕ ~~]';

  @override
  String get grpMWkBar => '[ßåŕ çĥåŕţ ~~~]';

  @override
  String get grpMWkLine => '[Łíñé çĥåŕţ ~~~]';

  @override
  String get grpMWkPie => '[Þíé çĥåŕţ ~~~]';

  @override
  String get grpMWkTable => '[Ţåƀłé ~]';

  @override
  String get grpMWkBurndown => '[ßûŕñðöŵñ ~~]';

  @override
  String get grpMWkWorkload => '[Ŵöŕķłöåð ~~]';

  @override
  String get grpMMeasCount => '[Ţåšķ çöûñţ ~~~]';

  @override
  String get grpMMeasPoints => '[Šţöŕý þöíñţš ~~~~]';

  @override
  String get grpMMeasEstimateHours => '[Éšţíɱåţéð ĥöûŕš ~~~~~]';

  @override
  String get grpMMeasLoggedHours => '[Łöĝĝéð ĥöûŕš ~~~~]';

  @override
  String get grpMMeasCycleDays => '[Çýçłé ţíɱé (ðåýš) ~~~~~]';

  @override
  String get grpMScopeAll => '[Åłł ţåšķš ~~~]';

  @override
  String get grpMScopeOpen => '[Öþéñ ţåšķš ~~~]';

  @override
  String get grpMScopeDone => '[Ðöñé ţåšķš ~~~]';

  @override
  String get grpMVisPersonal => '[Öñłý ɱé ~~]';

  @override
  String get grpMVisProject => '[Éṽéŕýöñé íñ ţĥé þŕöĵéçţ ~~~~~~~]';

  @override
  String get grpMVisWorkspace => '[Éṽéŕýöñé íñ ţĥé ŵöŕķšþåçé ~~~~~~~~]';

  @override
  String get grpMLblStatus => '[Šţåţûš ~~]';

  @override
  String get grpMLblStatusCategory => '[Šţåţûš çåţéĝöŕý ~~~~~]';

  @override
  String get grpMLblPerson => '[Þéŕšöñ ~~]';

  @override
  String get grpMLblPriority => '[Þŕíöŕíţý ~~]';

  @override
  String get grpMLblProject => '[Þŕöĵéçţ ~~]';

  @override
  String get grpMLblSprint => '[Šþŕíñţ ~~]';

  @override
  String get grpMLblCreatedDay => '[Çŕéåţéð (ðåý) ~~~~]';

  @override
  String get grpMLblCreatedWeek => '[Çŕéåţéð (ŵééķ) ~~~~]';

  @override
  String get grpMLblDueWeek => '[Ðûé (ŵééķ) ~~~]';

  @override
  String get grpMImpJiraCsv => '[Ĵíŕå (ÇŠṼ éxþöŕţ) ~~~~~]';

  @override
  String get grpMImpJiraJson => '[Ĵíŕå (ĴŠÖÑ) ~~~]';

  @override
  String get grpMImpClickupCsv => '[ÇłíçķÛþ (ÇŠṼ éxþöŕţ) ~~~~~~]';

  @override
  String get grpMImpClickupJson => '[ÇłíçķÛþ (ĴŠÖÑ) ~~~~]';

  @override
  String get grpMImpCsv => '[Åñý ÇŠṼ ƒíłé ~~~~]';

  @override
  String get grpMImpTaskforge => '[ŢåšķFöŕĝé éxþöŕţ (ţåšķš.ĵšöñ) ~~~~~~~~~]';

  @override
  String get grpMNkAssigned => '[Åššíĝñéð ţö ýöû ~~~~~]';

  @override
  String get grpMNkMentioned => '[Méñţíöñš ~~]';

  @override
  String get grpMNkCommented => '[Çöɱɱéñţš ~~]';

  @override
  String get grpMNkStatusChanged => '[Šţåţûš çĥåñĝéš ~~~~]';

  @override
  String get grpMNkDueSoon => '[Ðûé šööñ ~~]';

  @override
  String get grpMNkTimerLong => '[Łöñĝ ţíɱéŕš ~~~]';

  @override
  String get grpMNkUnknown => '[Ñöţíƒíçåţíöñ ~~~~]';

  @override
  String get grpMIfAll => '[Åłł ~]';

  @override
  String get grpMIfUnread => '[Ûñŕéåð ~~]';

  @override
  String get grpMIfMentions => '[Méñţíöñš ~~]';

  @override
  String get grpMIfAssigned => '[Åššíĝñéð ~~]';

  @override
  String get grpMIfSnoozed => '[Šñööžéð ~~]';

  @override
  String get grpMIfArchived => '[Åŕçĥíṽéð ~~]';

  @override
  String get grpMEmOff => '[Öƒƒ ~]';

  @override
  String get grpMEmInstant => '[Íñšţåñţ ~~]';

  @override
  String get grpMEmDigest => '[Ðåíłý ðíĝéšţ ~~~~]';

  @override
  String get grpMRkSchedule => '[Öñ å šçĥéðûłé ~~~~]';

  @override
  String get grpMRkAfterCompletion => '[Åƒţéŕ íţ íš çöɱþłéţéð ~~~~~~~]';

  @override
  String get grpMLblOpEq => '[íš ]';

  @override
  String get grpMLblOpNe => '[íš ñöţ ~~]';

  @override
  String get grpMLblOpLt => '[ƀéƒöŕé / łéšš ţĥåñ ~~~~~~]';

  @override
  String get grpMLblOpLte => '[öñ öŕ ƀéƒöŕé / åţ ɱöšţ ~~~~~~~]';

  @override
  String get grpMLblOpGt => '[åƒţéŕ / ɱöŕé ţĥåñ ~~~~~]';

  @override
  String get grpMLblOpGte => '[öñ öŕ åƒţéŕ / åţ łéåšţ ~~~~~~~]';

  @override
  String get grpMLblOpContains => '[çöñţåíñš ~~]';

  @override
  String get grpMLblOpNotContains => '[ðöéš ñöţ çöñţåíñ ~~~~~]';

  @override
  String get grpMLblOpIn => '[íš åñý öƒ ~~~]';

  @override
  String get grpMLblOpNotIn => '[íš ñöñé öƒ ~~~]';

  @override
  String get grpMLblOpEmpty => '[íš éɱþţý ~~]';

  @override
  String get grpMLblOpNotEmpty => '[íš ñöţ éɱþţý ~~~~]';

  @override
  String get grpMLblAssignee => '[Åššíĝñéé ~~]';

  @override
  String get grpMLblStart => '[Šţåŕţ ~]';

  @override
  String get grpMLblDue => '[Ðûé ~]';

  @override
  String get grpMLblCreated => '[Çŕéåţéð ~~]';

  @override
  String get grpMLblUpdated => '[Ûþðåţéð ~~]';

  @override
  String get grpMLblDueDate => '[Ðûé ðåţé ~~]';

  @override
  String get grpMLblProgress => '[Šûƀţåšķ þŕöĝŕéšš ~~~~~]';

  @override
  String get grpMLblViewList => '[Łíšţ ~]';

  @override
  String get grpMLblViewBoard => '[ßöåŕð ~]';

  @override
  String get grpMLblViewCalendar => '[Çåłéñðåŕ ~~]';

  @override
  String get grpMLblViewTimeline => '[Ţíɱéłíñé ~~]';

  @override
  String get grpMRelNow => '[ñöŵ ~]';

  @override
  String get grpMRelJustNow => '[ĵûšţ ñöŵ ~~]';

  @override
  String grpMRelMin(int n) {
    return '[$n ɱíñ åĝö ~~~]';
  }

  @override
  String grpMRelHour(int n) {
    return '[$n ĥ åĝö ~~~]';
  }

  @override
  String get grpMRelYesterday => '[ýéšţéŕðåý ~~~]';

  @override
  String grpMRelDay(int n) {
    return '[$n ð åĝö ~~~]';
  }

  @override
  String get grpMNotifSomeone => '[Šöɱéöñé ~~]';

  @override
  String grpMNotifAssigned(String who) {
    return '[$who åššíĝñéð ýöû ~~~~~~]';
  }

  @override
  String grpMNotifMentioned(String who) {
    return '[$who ɱéñţíöñéð ýöû íñ ~~~~~~~]';
  }

  @override
  String grpMNotifCommented(String who) {
    return '[$who çöɱɱéñţéð öñ ~~~~~~]';
  }

  @override
  String grpMNotifStatusChanged(String who) {
    return '[$who çĥåñĝéð ţĥé šţåţûš öƒ ~~~~~~~~~]';
  }

  @override
  String grpMNotifMoved(String who, String fromStatus, String toStatus) {
    return '[$who ɱöṽéð ƒŕöɱ $fromStatus ţö $toStatus ~~~~~~~~~~~~~~]';
  }

  @override
  String get grpMNotifDueSoon => '[Ðûé šööñ: ~~~]';

  @override
  String get grpMNotifTimer => '[Ýöûŕ ţíɱéŕ íš šţíłł ŕûññíñĝ öñ ~~~~~~~~~~]';

  @override
  String get grpMNotifNew => '[Ñéŵ åçţíṽíţý öñ ~~~~~]';

  @override
  String get grpMUnitDay => '[ðåý ~]';

  @override
  String get grpMUnitDays => '[ðåýš ~]';

  @override
  String get grpMUnitWeek => '[ŵééķ ~]';

  @override
  String get grpMUnitWeeks => '[ŵééķš ~]';

  @override
  String get grpMUnitMonth => '[ɱöñţĥ ~]';

  @override
  String get grpMUnitMonths => '[ɱöñţĥš ~~]';

  @override
  String get grpMUnitYear => '[ýéåŕ ~]';

  @override
  String get grpMUnitYears => '[ýéåŕš ~]';

  @override
  String get grpMSlashText => '[Ţéxţ ~]';

  @override
  String get grpMSlashH1 => '[Ĥéåðíñĝ 1 ~~~]';

  @override
  String get grpMSlashH2 => '[Ĥéåðíñĝ 2 ~~~]';

  @override
  String get grpMSlashH3 => '[Ĥéåðíñĝ 3 ~~~]';

  @override
  String get grpMSlashBullet => '[ßûłłéţéð łíšţ ~~~~]';

  @override
  String get grpMSlashNumbered => '[Ñûɱƀéŕéð łíšţ ~~~~]';

  @override
  String get grpMSlashTodo => '[Çĥéçķłíšţ ~~~]';

  @override
  String get grpMSlashQuote => '[Qûöţé ~]';

  @override
  String get grpMSlashCode => '[Çöðé ~]';

  @override
  String get grpMSlashTable => '[Ţåƀłé ~]';

  @override
  String get grpMSlashDivider => '[Ðíṽíðéŕ ~~]';

  @override
  String get grpMSlashImage => '[Íɱåĝé ~]';

  @override
  String get grpMSlashCallout => '[Çåłłöûţ ~~]';

  @override
  String get grpMSlashTask => '[Ţåšķ çåŕð ~~~]';

  @override
  String get grpMMeanSucceeded => '[Éṽéŕý åçţíöñ ŕåñ. ~~~~~]';

  @override
  String get grpMMeanFailed =>
      '[Åñ åçţíöñ ƒåíłéð; ţĥé öñéš ƀéƒöŕé íţ šţåý ðöñé. ~~~~~~~~~~~~~~~]';

  @override
  String get grpMMeanSkippedCondition =>
      '[Ţĥé éṽéñţ ɱåţçĥéð, ƀûţ ţĥé ţåšķ ðíð ñöţ ɱééţ ţĥé çöñðíţíöñ. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpMMeanSkippedLoop =>
      '[Ŕûłéš ţŕíĝĝéŕéð ŕûłéš ɱöŕé ţĥåñ 5 ĥöþš ðééþ, šö ţĥíš ŕûñ ŵåš šţöþþéð ţö éñð å łööþ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpMMeanSkippedRate =>
      '[Ţĥíš ŕûłé åłŕéåðý ŕåñ 30 ţíɱéš íñ ţĥé łåšţ ɱíñûţé, šö ţĥíš ŕûñ ŵåš šķíþþéð. ~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get grpMStepOk => '[öķ ]';

  @override
  String get grpMStepFailed => '[ƒåíłéð ~~]';

  @override
  String get grpMStepNotRun => '[ñöţ ŕûñ ~~]';

  @override
  String get grpMStepPlanned => '[þłåññéð ~~]';

  @override
  String get grpMStepWouldFail => '[ŵöûłð ƒåíł ~~~]';

  @override
  String get grp1DropCardHere => '[Ðŕöþ å çåŕð ĥéŕé ~~~~~]';

  @override
  String get grp1NoCards => '[Ñö çåŕðš ~~]';

  @override
  String get grp1StopWatchingTask => '[Šţöþ ŵåţçĥíñĝ ţĥíš ţåšķ ~~~~~~~]';

  @override
  String get grp1WatchTask => '[Ŵåţçĥ ţĥíš ţåšķ ~~~~~]';

  @override
  String get grp1SecondFactorRequired => '[Šéçöñð ƒåçţöŕ ŕéqûíŕéð. ~~~~~~~]';

  @override
  String get grp1AnAutomation => '[Åñ åûţöɱåţíöñ ~~~~]';

  @override
  String get grp1TheSystem => '[Ţĥé šýšţéɱ ~~~]';

  @override
  String grp1MemberCount(int count) {
    return '[$count ɱéɱƀéŕ(š) ~~~~~]';
  }

  @override
  String get grp1SyncLive => '[Łíṽé ~]';

  @override
  String get grp1SyncConnecting => '[Çöññéçţíñĝ… ~~~]';

  @override
  String get grp1SyncReconnecting => '[Ŕéçöññéçţíñĝ… ~~~~]';

  @override
  String get grp1SyncLiveTip =>
      '[Çĥåñĝéš ƀý öţĥéŕš åþþéåŕ åš ţĥéý ĥåþþéñ ~~~~~~~~~~~~~]';

  @override
  String get grp1SyncNotLiveTip =>
      '[Ñöţ łíṽé: çĥåñĝéš ƀý öţĥéŕš ŵíłł åþþéåŕ öñçé ŕéçöññéçţéð ~~~~~~~~~~~~~~~~~~]';

  @override
  String get grp1EnterNumber => '[Éñţéŕ å ñûɱƀéŕ. ~~~~~]';

  @override
  String get grp1EnterAmount => '[Éñţéŕ åñ åɱöûñţ. ~~~~~]';

  @override
  String get grp1EnterCurrency =>
      '[Éñţéŕ å 3-łéţţéŕ çûŕŕéñçý, é.ĝ. ÛŠÐ. ~~~~~~~~~~~~]';

  @override
  String get grp1EnterUrl =>
      '[Éñţéŕ å ŵéƀ åððŕéšš šţåŕţíñĝ ŵíţĥ ĥţţþ(š):// ~~~~~~~~~~~~~~]';

  @override
  String get grp1UseIsoDate => '[Ûšé ÝÝÝÝ-MM-ÐÐ. ~~~~~]';

  @override
  String get devTitle => '[Ðéṽéłöþéŕ ~~~]';

  @override
  String get devSub => '[ÅÞÍ ţöķéñš åñð ŵéƀĥööķš ~~~~~~~]';

  @override
  String get devTokensTab => '[ÅÞÍ ţöķéñš ~~~]';

  @override
  String get devWebhooksTab => '[Ŵéƀĥööķš ~~]';

  @override
  String get devTokenNew => '[Ñéŵ ţöķéñ ~~~]';

  @override
  String get devTokenName => '[Ñåɱé ~]';

  @override
  String get devTokenScopes => '[Ŵĥåţ íţ ɱåý ðö ~~~~]';

  @override
  String get devTokenExpiry => '[Éxþíŕéš ~~]';

  @override
  String get devExpiryNever => '[Ñéṽéŕ ~]';

  @override
  String get devExpiry30 => '[Íñ 30 ðåýš ~~~]';

  @override
  String get devExpiry90 => '[Íñ 90 ðåýš ~~~]';

  @override
  String get devExpiry365 => '[Íñ å ýéåŕ ~~~]';

  @override
  String get devTokenCreate => '[Çŕéåţé ţöķéñ ~~~~]';

  @override
  String get devTokenCreatedTitle => '[Çöþý ýöûŕ ţöķéñ ñöŵ ~~~~~~]';

  @override
  String get devTokenCreatedBody =>
      '[Ţĥíš íš ţĥé öñłý ţíɱé íţ íš šĥöŵñ. Šţöŕé íţ šöɱéŵĥéŕé šåƒé. ~~~~~~~~~~~~~~~~~~~]';

  @override
  String get devCopy => '[Çöþý ~]';

  @override
  String get devCopied => '[Çöþíéð ~~]';

  @override
  String get devDone => '[Ðöñé ~]';

  @override
  String devTokenPrefix(String prefix) {
    return '[Šţåŕţš ŵíţĥ $prefix ~~~~~~]';
  }

  @override
  String get devTokenNeverUsed => '[Ñéṽéŕ ûšéð ~~~]';

  @override
  String devTokenUsed(String when) {
    return '[Łåšţ ûšéð $when ~~~~~]';
  }

  @override
  String get devTokenActive => '[Åçţíṽé ~~]';

  @override
  String get devTokenExpired => '[Éxþíŕéð ~~]';

  @override
  String get devTokenRevoked => '[Ŕéṽöķéð ~~]';

  @override
  String get devTokenRevoke => '[Ŕéṽöķé ~~]';

  @override
  String devTokenRevokeTitle(String name) {
    return '[Ŕéṽöķé \"$name\"? ~~~~~]';
  }

  @override
  String get devTokenRevokeBody =>
      '[Åñýţĥíñĝ ûšíñĝ ţĥíš ţöķéñ šţöþš ŵöŕķíñĝ åţ öñçé. ~~~~~~~~~~~~~~~~]';

  @override
  String get devTokensEmpty => '[Ñö ţöķéñš ýéţ. ~~~~]';

  @override
  String get devTokensHint =>
      '[Å ţöķéñ çåñ ðö ŵĥåţ ýöû çåñ ðö, ñåŕŕöŵéð ţö ţĥé šçöþéš ýöû þíçķ. Íţ ŵöŕķš íñ ţĥíš ŵöŕķšþåçé öñłý. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get devWebhookNew => '[Ñéŵ ŵéƀĥööķ ~~~]';

  @override
  String get devWebhookEdit => '[Éðíţ ŵéƀĥööķ ~~~~]';

  @override
  String get devWebhookName => '[Ñåɱé (öþţíöñåł) ~~~~~]';

  @override
  String get devWebhookUrl => '[ÛŔŁ ~]';

  @override
  String get devWebhookEvents => '[Éṽéñţš ~~]';

  @override
  String get devWebhookSave => '[Šåṽé ~]';

  @override
  String get devWebhookActive => '[Åçţíṽé ~~]';

  @override
  String get devWebhookSecret => '[Šíĝñíñĝ šéçŕéţ ~~~~]';

  @override
  String get devWebhookTest => '[Šéñð ţéšţ ~~~]';

  @override
  String devWebhookTestDone(String status) {
    return '[Ţĥé ţéšţ ŵåš šéñţ: $status ~~~~~~~~~]';
  }

  @override
  String get devWebhookDeliveries => '[Ðéłíṽéŕíéš ~~~]';

  @override
  String get devWebhookDelete => '[Ðéłéţé ~~]';

  @override
  String devWebhookDeleteTitle(String name) {
    return '[Ðéłéţé \"$name\"? ~~~~~]';
  }

  @override
  String get devWebhookDeleteBody =>
      '[Íţš ðéłíṽéŕý łöĝ íš ðéłéţéð ţöö. ~~~~~~~~~~]';

  @override
  String get devWebhooksEmpty => '[Ñö ŵéƀĥööķš ýéţ. ~~~~~]';

  @override
  String get devWebhooksDenied =>
      '[Öñłý þéöþłé ŵĥö çåñ ɱåñåĝé ŵéƀĥööķš šéé ţĥéšé. ~~~~~~~~~~~~~~~]';

  @override
  String devWebhookOff(String reason) {
    return '[Šŵíţçĥéð öƒƒ: $reason ~~~~~~~]';
  }

  @override
  String get devWebhookHint =>
      '[Éåçĥ éṽéñţ íš šéñţ åš å šíĝñéð ÞÖŠŢ. Ţĥé ŕéçéíṽéŕ çĥéçķš ţĥé šíĝñåţûŕé ŵíţĥ ţĥé šéçŕéţ. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get devDeliveriesTitle => '[Ðéłíṽéŕíéš ~~~]';

  @override
  String get devDeliveriesEmpty => '[Ñöţĥíñĝ ĥåš ƀééñ šéñţ ýéţ. ~~~~~~~~]';

  @override
  String get devStatusDelivered => '[Ðéłíṽéŕéð ~~~]';

  @override
  String get devStatusPending => '[Ŵåíţíñĝ ~~]';

  @override
  String get devStatusFailed => '[Fåíłéð, ŵíłł ŕéţŕý ~~~~~~]';

  @override
  String get devStatusGaveUp => '[Ĝåṽé ûþ ~~]';

  @override
  String devAttempt(int n) {
    return '[Åţţéɱþţ $n ~~~]';
  }

  @override
  String get devRequest => '[Ŕéqûéšţ ~~]';

  @override
  String get devResponse => '[Ŕéšþöñšé ~~]';

  @override
  String get devHeaders => '[Ĥéåðéŕš ~~]';

  @override
  String get devBody => '[ßöðý ~]';

  @override
  String get devResend => '[Ŕéšéñð ~~]';

  @override
  String devResent(String status) {
    return '[Šéñţ åĝåíñ: $status ~~~~~~]';
  }

  @override
  String devNextTry(String when) {
    return '[Ñéxţ ţŕý $when ~~~~~]';
  }

  @override
  String get devLoadMore => '[Łöåð ɱöŕé ~~~]';

  @override
  String get devRetry => '[Ţŕý åĝåíñ ~~~]';

  @override
  String get devDenied => '[Ýöû çåññöţ ðö ţĥåţ ĥéŕé. ~~~~~~~~]';

  @override
  String get devScopeWorkspacesRead => '[Šéé ţĥé ŵöŕķšþåçé ~~~~~]';

  @override
  String get devScopeProjectsRead => '[Ŕéåð þŕöĵéçţš ~~~~]';

  @override
  String get devScopeProjectsWrite => '[Çŕéåţé åñð çĥåñĝé þŕöĵéçţš ~~~~~~~~]';

  @override
  String get devScopeTasksRead => '[Ŕéåð ţåšķš ~~~]';

  @override
  String get devScopeTasksWrite =>
      '[Çŕéåţé, çĥåñĝé åñð ðéłéţé ţåšķš ~~~~~~~~~~]';

  @override
  String get devScopeCommentsRead => '[Ŕéåð çöɱɱéñţš ~~~~]';

  @override
  String get devScopeCommentsWrite => '[Ŵŕíţé çöɱɱéñţš ~~~~]';

  @override
  String get devEventTaskCreated => '[Å ţåšķ íš çŕéåţéð ~~~~~]';

  @override
  String get devEventTaskUpdated => '[Å ţåšķ íš éðíţéð ~~~~~]';

  @override
  String get devEventTaskStatus => '[Å ţåšķ çĥåñĝéš šţåţûš ~~~~~~~]';

  @override
  String get devEventTaskAssigned =>
      '[Þéöþłé åŕé åššíĝñéð ţö å ţåšķ ~~~~~~~~~]';

  @override
  String get devEventTaskDeleted => '[Å ţåšķ íš ðéłéţéð ~~~~~]';

  @override
  String get devEventCommentCreated => '[Å çöɱɱéñţ íš åððéð ~~~~~~]';

  @override
  String get devEventCommentUpdated => '[Å çöɱɱéñţ íš éðíţéð ~~~~~~]';

  @override
  String get devEventCommentDeleted => '[Å çöɱɱéñţ íš ðéłéţéð ~~~~~~]';

  @override
  String get devEventPing => '[Ţéšţ éṽéñţ ~~~]';
}
