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
}
