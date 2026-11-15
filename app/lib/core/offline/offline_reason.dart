import 'package:taskforge/core/offline/outbox_worker.dart'
    show commentErrorText;
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Why an offline change was refused (or a project could not be kept), as it
/// is stored: the English sentence, a separator, then a typed code. The
/// sentence is what older rows and logs show; the code lets the offline screen
/// say it in the language on screen ([reasonText]).
const _sep = '\u001f';

String _join(String english, String code) => '$english$_sep$code';

/// [stored] without its code: the English sentence.
String reasonEnglish(String stored) => stored.split(_sep).first;

/// The reason for a refused task call.
String taskReason(TaskException e) =>
    _join(taskErrorMessage(e), 't:${e.failure.name}|${e.detail ?? ''}');

/// The reason for a refused file call.
String attachmentReason(AttachmentException e) =>
    _join(attachmentErrorMessage(e), 'a:${e.failure.name}|${e.detail ?? ''}');

/// The reason for a refused comment.
String commentReason(CommentException e) =>
    _join(commentErrorText(e), 'c:${e.failure.name}|${e.detail ?? ''}');

/// A change that waited on one that was then refused.
String dependentReason(String refused) => _join(
  'This depends on a change that was refused: ${reasonEnglish(refused)}',
  'd:${refused.contains(_sep) ? refused.split(_sep).last : ''}',
);

/// A project that could not be read for offline use.
String unreadableReason() =>
    _join('It could not be read. Try again.', 'k:unreadable');

/// [stored] in the language of [l]; a row without a code shows as stored.
String reasonText(String stored, AppLocalizations l) {
  final parts = stored.split(_sep);
  if (parts.length < 2) return stored;
  return _decode(parts[1], l) ?? parts[0];
}

String? _decode(String code, AppLocalizations l) {
  final colon = code.indexOf(':');
  if (colon < 0) return null;
  final kind = code.substring(0, colon);
  final rest = code.substring(colon + 1);
  final bar = rest.indexOf('|');
  final name = bar < 0 ? rest : rest.substring(0, bar);
  final raw = bar < 0 ? '' : rest.substring(bar + 1);
  final detail = raw.isEmpty ? null : raw;
  try {
    switch (kind) {
      case 't':
        return taskErrorMessage(
          TaskException(TaskFailure.values.byName(name), detail: detail),
          l,
        );
      case 'a':
        return attachmentErrorMessage(
          AttachmentException(
            AttachmentFailure.values.byName(name),
            detail: detail,
          ),
          l,
        );
      case 'c':
        return commentErrorText(
          CommentException(CommentFailure.values.byName(name), detail: detail),
          l,
        );
      case 'd':
        final inner = _decode(rest, l);
        return inner == null ? null : l.grpRDependsRefused(inner);
      case 'k':
        return l.grpRKeepUnreadable;
    }
  } on ArgumentError {
    return null;
  }
  return null;
}
