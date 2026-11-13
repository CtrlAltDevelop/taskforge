import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

const minKeyLength = 2;
const maxKeyLength = 6;

/// Icons a project may use (the server accepts any short printable string).
const projectIcons = ['📁', '🚀', '🛠', '🎨', '📣', '🧪', '📊', '🌱'];

/// Swatches a project may use (`#RRGGBB`).
const projectColors = [
  '#3F51B5',
  '#E53935',
  '#FB8C00',
  '#43A047',
  '#00897B',
  '#1E88E5',
  '#8E24AA',
  '#6D4C41',
];

enum ProjectVisibility {
  open,
  private;

  String get wire => name;
}

@immutable
class Feature {
  const Feature({required this.key, required this.enabled});

  final String key;
  final bool enabled;
}

/// Label and one-line explanation of a feature switch (from the server).
@immutable
class FeatureInfo {
  const FeatureInfo({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;
}

@immutable
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.key,
    this.description = '',
    this.icon = '',
    this.color = '',
    this.visibility = ProjectVisibility.open,
    this.archivedAt = '',
    this.version = 1,
    this.taskCounter = 0,
    this.features = const [],
    this.isFavorite = false,
    this.memberCount = 0,
    this.isMember = false,
    this.canOpen = true,
  });

  final String id;
  final String name;
  final String key;
  final String description;
  final String icon;
  final String color;
  final ProjectVisibility visibility;

  /// ISO timestamp, empty while active.
  final String archivedAt;

  /// Optimistic-lock counter; send it back as `expected_version`.
  final int version;
  final int taskCounter;
  final List<Feature> features;
  final bool isFavorite;
  final int memberCount;
  final bool isMember;

  /// False only in the admin list of private projects the caller is not in.
  final bool canOpen;

  bool get isArchived => archivedAt.isNotEmpty;
  bool get isPrivate => visibility == ProjectVisibility.private;

  /// The key can change only until the first task exists.
  bool get keyLocked => taskCounter > 0;

  Set<String> get enabledFeatures => {
    for (final f in features)
      if (f.enabled) f.key,
  };
}

/// Active projects of the sidebar: favorites first, then the rest, both by name.
List<Project> sidebarOrder(Iterable<Project> projects) {
  int byName(Project a, Project b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  final active = projects.where((p) => !p.isArchived);
  return [
    ...active.where((p) => p.isFavorite).toList()..sort(byName),
    ...active.where((p) => !p.isFavorite).toList()..sort(byName),
  ];
}

@immutable
class ProjectCatalog {
  const ProjectCatalog({
    required this.projects,
    required this.featureInfo,
    this.workspaceId = '',
  });

  static const empty = ProjectCatalog(projects: [], featureInfo: []);

  /// The workspace this list was read from.
  final String workspaceId;

  final List<Project> projects;
  final List<FeatureInfo> featureInfo;
}

@immutable
class ProjectMember {
  const ProjectMember({
    required this.userId,
    required this.displayName,
    required this.email,
  });

  final String userId;
  final String displayName;
  final String email;

  String get label => displayName.isEmpty ? email : displayName;
}

/// Uppercases and drops everything but A-Z, capped at [maxKeyLength].
String normalizeKey(String raw) {
  final letters = raw.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
  return letters.length > maxKeyLength
      ? letters.substring(0, maxKeyLength)
      : letters;
}

/// A suggested key: initials of several words, or the first three letters of
/// one word.
String deriveKey(String name) {
  final words = name
      .split(RegExp(r'[^A-Za-z]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  final raw = words.length > 1
      ? words.map((w) => w[0]).join()
      : words.first.substring(
          0,
          words.first.length < 3 ? words.first.length : 3,
        );
  return normalizeKey(raw);
}

/// Mirrors the server: 2-6 capital letters.
String? validateProjectKey(String? value) =>
    RegExp('^[A-Z]{$minKeyLength,$maxKeyLength}\$').hasMatch(value ?? '')
    ? null
    : 'Use $minKeyLength-$maxKeyLength capital letters (A-Z).';

String? validateProjectName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter a name.';
  return v.length > 80 ? 'Use at most 80 characters.' : null;
}

enum ProjectFailure {
  keyTaken,
  keyLocked,
  archived,
  lastMember,
  conflict,
  denied,
  forbidden,
  invalid,
  notFound,
  network,
  other,
}

class ProjectException implements Exception {
  const ProjectException(this.failure, [this.detail]);

  final ProjectFailure failure;
  final String? detail;

  @override
  String toString() => 'ProjectException($failure, $detail)';
}

/// What to tell the user about a failed projects call.
String projectErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! ProjectException) return t.grpLGeneric;
  return switch (error.failure) {
    ProjectFailure.keyTaken => t.grpLKeyTaken,
    ProjectFailure.keyLocked => t.grpLKeyLocked,
    ProjectFailure.archived => t.grpLArchived,
    ProjectFailure.lastMember => t.grpLLastMember,
    ProjectFailure.conflict => t.grpLProjConflict,
    ProjectFailure.denied => error.detail ?? t.grpLNoPerm,
    ProjectFailure.forbidden => t.grpLNoPermDo,
    ProjectFailure.invalid => error.detail ?? t.grpLCheckValues,
    ProjectFailure.notFound => t.grpLProjectGone,
    ProjectFailure.network => t.grpLNetCheck,
    ProjectFailure.other => t.grpLGeneric,
  };
}
