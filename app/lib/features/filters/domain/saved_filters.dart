import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Where in a query text something is wrong.
@immutable
class QueryProblem {
  const QueryProblem(this.position, this.length, this.message);

  final int position;
  final int length;
  final String message;
}

/// What the server made of a query: the AST and the normal text, or problems.
@immutable
class QueryChecked {
  const QueryChecked({this.query, this.tfql = '', this.errors = const []});

  final FilterQuery? query;
  final String tfql;
  final List<QueryProblem> errors;

  bool get ok => errors.isEmpty && query != null;
}

/// Something that could be typed next; [text] replaces the query from [start]
/// to the cursor.
@immutable
class QuerySuggestion {
  const QuerySuggestion(this.text, this.kind, this.start, this.label);

  final String text;
  final String kind;
  final int start;
  final String label;
}

/// A saved filter: private, shared with the project, or with the workspace.
@immutable
class SavedFilter {
  const SavedFilter({
    required this.id,
    required this.name,
    required this.visibility,
    required this.query,
    required this.tfql,
    required this.version,
    this.projectId = '',
  });

  final String id;
  final String name;
  final String visibility; // private | project | workspace
  final FilterQuery query;

  /// Rendered with today's names; empty when a field it used is gone.
  final String tfql;
  final int version;
  final String projectId;

  bool get isShared => visibility != 'private';

  /// A filter whose field was removed cannot be applied.
  bool get isBroken => tfql.isEmpty && !query.isEmpty;
}

enum FilterFailure {
  invalid,
  nameTaken,
  limit,
  denied,
  forbidden,
  archived,
  notFound,
  conflict,
  network,
  other,
}

class FilterException implements Exception {
  const FilterException(this.failure, {this.detail, this.version = 0});

  final FilterFailure failure;
  final String? detail;
  final int version;

  @override
  String toString() => 'FilterException($failure, $detail)';
}

String filterErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! FilterException) return t.grpLGeneric;
  return switch (error.failure) {
    FilterFailure.invalid => error.detail ?? t.grpLFilterInvalid,
    FilterFailure.nameTaken => t.grpLFilterNameTaken,
    FilterFailure.limit => t.grpLFilterLimit,
    FilterFailure.denied => error.detail ?? t.grpLNoPerm,
    FilterFailure.forbidden => t.grpLNoPermDo,
    FilterFailure.archived => t.grpLArchived,
    FilterFailure.notFound => t.grpLFilterGone,
    FilterFailure.conflict => t.grpLFilterConflict,
    FilterFailure.network => t.grpLNetCheck,
    FilterFailure.other => t.grpLGeneric,
  };
}
