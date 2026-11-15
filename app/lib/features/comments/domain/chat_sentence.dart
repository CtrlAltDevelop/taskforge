import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart' show TaskPriority;
import 'package:taskforge/features/time/domain/time.dart' show durationText;
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What a system message says happened, as a phrase that follows the actor
/// ("@Sara" + "changed priority from Low to High"), in the language of [l].
/// [userName] and [statusName] turn ids into what a reader knows them by.
/// A field this client does not know is "changed a field": never its values.
String chatPhrase(
  ChatEvent e, {
  required AppLocalizations l,
  required String Function(String id) userName,
  required String Function(String id) statusName,
  LocalePrefs? prefs,
}) {
  String text(Object? v) => (v == null || '$v'.isEmpty) ? l.grpRMnNone : '$v';
  String date(Object? v) {
    final d = v == null ? null : DateTime.tryParse('$v');
    return d == null ? text(v) : dateOrIso(d, prefs: prefs, l10n: l);
  }

  String status(Object? v) =>
      (v == null || '$v'.isEmpty) ? l.grpRMnNone : statusName('$v');
  String priority(Object? v) => TaskPriority.parse('${v ?? 'none'}').labelIn(l);
  String estimate(Object? v) {
    final seconds = v is num ? v.toInt() : int.tryParse('${v ?? ''}');
    return seconds == null ? l.grpRMnNone : durationText(seconds);
  }

  switch (e.field) {
    case 'title':
      return l.chatEvTitle(text(e.from), text(e.to));
    case 'status_id':
      return l.chatEvStatus(status(e.from), status(e.to));
    case 'priority':
      return l.chatEvPriority(priority(e.from), priority(e.to));
    case 'start_date':
      return l.chatEvStartDate(date(e.from), date(e.to));
    case 'due_date':
      return l.chatEvDueDate(date(e.from), date(e.to));
    case 'estimate_sec':
      return l.chatEvEstimate(estimate(e.from), estimate(e.to));
    case 'subtask_added':
      return l.chatEvSubtask(text(e.to));
    case 'assignees':
      return _assignees(e, l, userName);
  }
  return l.chatEvOther;
}

String _assignees(
  ChatEvent e,
  AppLocalizations l,
  String Function(String) userName,
) {
  List<String> ids(Object? v) => [
    if (v is List)
      for (final x in v) '$x',
  ];
  final was = ids(e.from);
  final now = ids(e.to);
  final added = [
    for (final id in now)
      if (!was.contains(id)) userName(id),
  ];
  final removed = [
    for (final id in was)
      if (!now.contains(id)) userName(id),
  ];
  final parts = [
    if (added.isNotEmpty) l.grpRAuAssigned(added.join(', ')),
    if (removed.isNotEmpty) l.grpRAuUnassigned(removed.join(', ')),
  ];
  return switch (parts.length) {
    0 => l.chatEvOther,
    1 => parts.single,
    _ => l.grpRAuAnd(parts[0], parts[1]),
  };
}

/// Who an automation, a form or an import is called (a person has a name).
String chatNonPersonActor(String actorType, AppLocalizations l) =>
    switch (actorType) {
      'automation' => l.chatActorAutomation,
      'form' => l.chatActorForm,
      'import' => l.chatActorImport,
      _ => l.chatActorSystem,
    };
