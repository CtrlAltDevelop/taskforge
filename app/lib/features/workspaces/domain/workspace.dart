import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

const workspaceNameMaxLength = 80;
const slugMinLength = 3;
const slugMaxLength = 40;

final _slugPattern = RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$');

@immutable
class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.slug,
    required this.version,
    this.logo = '',
    this.isOwner = false,
    this.defaultLocale = '',
  });

  final String id;
  final String name;
  final String slug;
  final String logo;
  final int version;
  final bool isOwner;

  /// The language a member who never chose one starts with ('' = none).
  final String defaultLocale;

  @override
  bool operator ==(Object other) =>
      other is Workspace &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.logo == logo &&
      other.version == version &&
      other.isOwner == isOwner &&
      other.defaultLocale == defaultLocale;

  @override
  int get hashCode =>
      Object.hash(id, name, slug, logo, version, isOwner, defaultLocale);
}

/// Mirrors the server rule (the server also refuses reserved words such as `api`).
String? validateSlug(String? value) {
  final slug = value ?? '';
  if (slug.length < slugMinLength || slug.length > slugMaxLength) {
    return 'Use $slugMinLength-$slugMaxLength characters.';
  }
  if (!_slugPattern.hasMatch(slug)) {
    return 'Use lowercase letters, numbers and hyphens, not starting or ending with a hyphen.';
  }
  return null;
}

String? validateWorkspaceName(String? value) {
  final name = (value ?? '').trim();
  if (name.isEmpty) return 'Enter a name.';
  if (name.length > workspaceNameMaxLength) {
    return 'Use at most $workspaceNameMaxLength characters.';
  }
  return null;
}

/// A URL slug suggested from a workspace name.
String slugify(String name) {
  final dashed = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final cut = dashed.length > slugMaxLength
      ? dashed.substring(0, slugMaxLength)
      : dashed;
  return cut.replaceAll(RegExp(r'-+$'), '');
}

/// The server prefixes gRPC messages with their title (`UPLOAD_INVALID: ...`);
/// users should see only the message.
String? stripErrorTitle(String? message) =>
    message?.replaceFirst(RegExp(r'^[A-Z][A-Z0-9_]*: '), '');

enum WorkspaceFailure {
  slugTaken,
  forbidden,
  denied,
  stale,
  invalid,
  notFound,
  network,
  other,
}

class WorkspaceException implements Exception {
  const WorkspaceException(this.failure, [this.detail]);

  final WorkspaceFailure failure;
  final String? detail;

  @override
  String toString() => 'WorkspaceException($failure, $detail)';
}

/// What to tell the user about a failed workspace call.
String workspaceErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! WorkspaceException) return t.grpLGeneric;
  return switch (error.failure) {
    WorkspaceFailure.slugTaken => t.grpLSlugTaken,
    WorkspaceFailure.forbidden =>
      'You do not have permission to do that in this workspace.',
    WorkspaceFailure.denied => error.detail ?? t.grpLNoPerm,
    WorkspaceFailure.stale => t.grpLWsStale,
    WorkspaceFailure.invalid => error.detail ?? t.grpLCheckValues,
    WorkspaceFailure.notFound => t.grpLWsNotRestorable,
    WorkspaceFailure.network => t.grpLNetCheck,
    WorkspaceFailure.other => t.grpLGeneric,
  };
}
