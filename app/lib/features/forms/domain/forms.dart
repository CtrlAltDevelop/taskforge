import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What a form question is: the title and description of the task, a custom
/// field of the project, or a file upload.
enum QuestionKind {
  title('title'),
  description('description'),
  custom('custom'),
  file('file');

  const QuestionKind(this.wire);

  final String wire;

  static QuestionKind parse(String wire) => values.firstWhere(
    (k) => k.wire == wire,
    orElse: () => QuestionKind.description,
  );
}

/// One question of a form as the builder edits it.
@immutable
class Question {
  const Question({
    required this.id,
    required this.kind,
    required this.label,
    this.help = '',
    this.required = false,
    this.customFieldId = '',
    this.maxFiles = 0,
  });

  /// Chosen by the client; letters, digits, dash and underscore.
  final String id;
  final QuestionKind kind;
  final String label;
  final String help;
  final bool required;

  /// The project custom field a [QuestionKind.custom] question asks for.
  final String customFieldId;

  /// For a [QuestionKind.file] question.
  final int maxFiles;

  Question copyWith({
    String? label,
    String? help,
    bool? required,
    int? maxFiles,
  }) => Question(
    id: id,
    kind: kind,
    label: label ?? this.label,
    help: help ?? this.help,
    required: required ?? this.required,
    customFieldId: customFieldId,
    maxFiles: maxFiles ?? this.maxFiles,
  );
}

/// A form in the workspace, as listed and edited.
@immutable
class IntakeForm {
  const IntakeForm({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.token,
    required this.questions,
    required this.statusId,
    required this.priority,
    required this.assigneeIds,
    required this.enabled,
    required this.requireEmail,
    required this.sendConfirmation,
    required this.notifyStatus,
    required this.brandColor,
    required this.logoUrl,
    required this.version,
    required this.submissionCount,
    required this.problem,
    this.fieldDefaults = const {},
  });

  final String id;
  final String projectId;
  final String name;
  final String description;

  /// The secret in the public address.
  final String token;
  final List<Question> questions;
  final String statusId;
  final String priority;
  final List<String> assigneeIds;
  final bool enabled;
  final bool requireEmail;
  final bool sendConfirmation;
  final bool notifyStatus;
  final String brandColor;
  final String logoUrl;
  final int version;
  final int submissionCount;

  /// Why submissions would fail now; empty when none.
  final String problem;

  /// Project field id -> the value (wire form) every task of the form starts
  /// with; a multi-select field named Labels covers labels.
  final Map<String, String> fieldDefaults;

  /// The same form after a logo upload bumped [version].
  IntakeForm withLogo({required String logoUrl, required int version}) =>
      IntakeForm(
        id: id,
        projectId: projectId,
        name: name,
        description: description,
        token: token,
        questions: questions,
        statusId: statusId,
        priority: priority,
        assigneeIds: assigneeIds,
        enabled: enabled,
        requireEmail: requireEmail,
        sendConfirmation: sendConfirmation,
        notifyStatus: notifyStatus,
        brandColor: brandColor,
        logoUrl: logoUrl,
        version: version,
        submissionCount: submissionCount,
        problem: problem,
        fieldDefaults: fieldDefaults,
      );
}

/// What the builder sends to create or save a form.
@immutable
class FormDraft {
  const FormDraft({
    required this.name,
    required this.description,
    required this.questions,
    required this.statusId,
    required this.priority,
    required this.assigneeIds,
    required this.enabled,
    required this.requireEmail,
    required this.sendConfirmation,
    required this.notifyStatus,
    required this.brandColor,
    required this.logoUrl,
    this.fieldDefaults = const {},
    this.keepLogo = false,
  });

  final String name;
  final String description;
  final List<Question> questions;
  final String statusId;
  final String priority;
  final List<String> assigneeIds;
  final bool enabled;
  final bool requireEmail;
  final bool sendConfirmation;
  final bool notifyStatus;
  final String brandColor;
  final String logoUrl;

  /// Project field id -> default value, in the wire form.
  final Map<String, String> fieldDefaults;

  /// Leave the logo as the server has it (it may be an upload): [logoUrl] is
  /// then not sent, since sending it back would turn the logo into a link.
  final bool keepLogo;
}

/// One send, as the submissions list shows it.
@immutable
class Submission {
  const Submission({
    required this.id,
    required this.reference,
    required this.projectId,
    required this.taskKey,
    required this.taskTitle,
    required this.statusName,
    required this.email,
    required this.at,
  });

  final String id;
  final String reference;
  final String projectId;
  final String taskKey;
  final String taskTitle;
  final String statusName;
  final String email;
  final String at;
}

@immutable
class SubmissionPage {
  const SubmissionPage(this.submissions, this.cursor);

  final List<Submission> submissions;

  /// Pass as `before` for the next page; empty at the end.
  final String cursor;
}

// ---- the public side ----

@immutable
class PublicOption {
  const PublicOption(this.id, this.label);

  final String id;
  final String label;
}

/// A question as a visitor sees it. [type] is the custom field type
/// (`text`, `number`, `select`, ...) and empty for the other kinds.
@immutable
class PublicQuestion {
  const PublicQuestion({
    required this.id,
    required this.kind,
    required this.label,
    required this.help,
    required this.required,
    required this.type,
    required this.options,
    required this.maxFiles,
  });

  final String id;
  final QuestionKind kind;
  final String label;
  final String help;
  final bool required;
  final String type;
  final List<PublicOption> options;
  final int maxFiles;
}

@immutable
class CaptchaConfig {
  const CaptchaConfig(this.provider, this.siteKey);

  /// `turnstile` or `hcaptcha`.
  final String provider;
  final String siteKey;
}

/// The only thing the server tells a visitor about a form.
@immutable
class PublicForm {
  const PublicForm({
    required this.name,
    required this.description,
    required this.brandColor,
    required this.logoUrl,
    required this.requireEmail,
    required this.offersUpdates,
    required this.questions,
    required this.captcha,
    required this.maxFiles,
    required this.maxFileBytes,
  });

  final String name;
  final String description;
  final String brandColor;
  final String logoUrl;
  final bool requireEmail;
  final bool offersUpdates;
  final List<PublicQuestion> questions;
  final CaptchaConfig? captcha;
  final int maxFiles;
  final int maxFileBytes;
}

/// A file the visitor chose.
@immutable
class PickedUpload {
  const PickedUpload(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

/// What a visitor sends.
@immutable
class FormAnswers {
  const FormAnswers({
    this.values = const {},
    this.files = const {},
    this.email = '',
    this.captchaToken = '',
  });

  /// Question id -> the text (the wire form for custom fields).
  final Map<String, String> values;
  final Map<String, List<PickedUpload>> files;
  final String email;
  final String captchaToken;
}

enum FormsFailure {
  network,
  denied,
  invalid,
  notFound,
  conflict,
  tooMany,
  unavailable,
  captcha,
  other,
}

class FormsException implements Exception {
  const FormsException(
    this.failure, {
    this.detail,
    this.fieldProblems = const {},
  });

  final FormsFailure failure;
  final String? detail;

  /// Question id (or `email`) -> what is wrong with it, from a refused send.
  final Map<String, String> fieldProblems;

  @override
  String toString() => 'FormsException($failure)';
}

String formsErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! FormsException) return t.grpLGeneric;
  final detail = error.detail;
  final hasDetail = detail != null && detail.isNotEmpty;
  return switch (error.failure) {
    FormsFailure.network => t.grpLNetCheckShort,
    FormsFailure.denied => t.formsDenied,
    FormsFailure.notFound => t.formsGone,
    FormsFailure.conflict => t.formsConflict,
    FormsFailure.invalid => hasDetail ? detail : t.grpLNotValid,
    FormsFailure.tooMany => t.formsTooMany,
    FormsFailure.unavailable => t.formsUnavailable,
    FormsFailure.captcha => t.formsCaptchaFailed,
    FormsFailure.other => t.grpLGeneric,
  };
}

/// The public address of a form.
String formAddress(String webUrl, String token) => '$webUrl/f/$token';

const maxQuestions = 40;
const priorities = ['none', 'low', 'medium', 'high', 'urgent'];
