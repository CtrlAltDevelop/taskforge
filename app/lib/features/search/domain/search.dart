import 'package:taskforge/core/ui/tf_icons.dart';

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show IconData;

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What can be found. [wire] is what the server calls it.
enum SearchKind {
  task('task', 'Tasks', TfIcons.success),
  comment('comment', 'Comments', TfIcons.chat),
  project('project', 'Projects', TfIcons.folder),
  member('member', 'People', TfIcons.user),
  doc('doc', 'Pages', TfIcons.file);

  const SearchKind(this.wire, this.label, this.tfIcon);

  final String wire;

  /// The English name; [labelIn] gives it in the language on screen.
  final String label;
  final TfIconData tfIcon;

  IconData get icon => tfIcon.glyph;

  String labelIn(AppLocalizations l10n) => switch (this) {
    task => l10n.grpFKindTasks,
    comment => l10n.grpFKindComments,
    project => l10n.grpFKindProjects,
    member => l10n.grpFKindPeople,
    doc => l10n.grpFKindPages,
  };

  static SearchKind? of(String wire) {
    for (final k in values) {
      if (k.wire == wire) return k;
    }
    return null;
  }
}

/// Where a match starts and ends in a string (UTF-16 units, like Dart's).
@immutable
class Mark {
  const Mark(this.start, this.end);

  final int start;
  final int end;
}

/// One result. [taskId] and [projectId] say where it lives; [key] is `WEB-12`
/// (or the project key).
@immutable
class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    this.taskId = '',
    this.projectId = '',
    this.key = '',
    this.titleMarks = const [],
    this.snippet = '',
    this.snippetMarks = const [],
    this.projectName = '',
    this.status = '',
    this.author = '',
  });

  final SearchKind kind;
  final String id;
  final String title;
  final String taskId;
  final String projectId;
  final String key;
  final List<Mark> titleMarks;
  final String snippet;
  final List<Mark> snippetMarks;
  final String projectName;
  final String status;
  final String author;

  /// Where tapping it goes in the app.
  String get location => switch (kind) {
    SearchKind.task ||
    SearchKind.comment => '/projects/$projectId?task=$taskId',
    SearchKind.project => '/projects/$projectId',
    SearchKind.member => '/members',
    SearchKind.doc => '/docs/$id',
  };
}

/// An answer: hits per kind, the task an id jumps to, and for each kind that
/// has more the cursor to ask with.
@immutable
class SearchResults {
  const SearchResults({
    this.hits = const {},
    this.jump,
    this.cursors = const {},
  });

  final Map<SearchKind, List<SearchHit>> hits;
  final SearchHit? jump;
  final Map<SearchKind, String> cursors;

  bool get isEmpty => jump == null && hits.values.every((h) => h.isEmpty);

  List<SearchHit> of(SearchKind kind) => hits[kind] ?? const [];

  /// Every hit in the order the screen shows them (the jump first).
  List<SearchHit> get ordered => [
    ?jump,
    for (final k in SearchKind.values) ...of(k),
  ];
}

enum SearchFailure { network, denied, invalid, rateLimited, other }

class SearchException implements Exception {
  const SearchException(this.failure, {this.detail});

  final SearchFailure failure;
  final String? detail;

  @override
  String toString() => 'SearchException($failure)';
}

String searchErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! SearchException) return t.grpFSearchErrGeneric;
  return switch (error.failure) {
    SearchFailure.network => t.grpFSearchErrNetwork,
    SearchFailure.denied => t.grpFSearchErrDenied,
    SearchFailure.rateLimited => t.grpFSearchErrRate,
    SearchFailure.invalid =>
      error.detail == null || error.detail!.isEmpty
          ? t.grpFSearchErrInvalid
          : error.detail!,
    SearchFailure.other => t.grpFSearchErrGeneric,
  };
}

/// Operators the filter chips add to (or take from) the text.
const operatorChips = <String>['assignee:me', 'status:open', 'status:done'];

/// The name on the chip for one of the [operatorChips].
String operatorChipLabel(String operator, AppLocalizations l10n) =>
    switch (operator) {
      'assignee:me' => l10n.grpFChipAssignedToMe,
      'status:open' => l10n.grpFChipOpen,
      _ => l10n.grpFChipDone,
    };

bool hasOperator(String text, String operator) =>
    text.split(RegExp(r'\s+')).contains(operator);

/// [text] with [operator] added, or removed when it is there.
String toggleOperator(String text, String operator) {
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.contains(operator)) {
    words.remove(operator);
  } else {
    words.add(operator);
  }
  return words.join(' ');
}
