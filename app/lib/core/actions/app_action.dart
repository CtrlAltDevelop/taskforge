// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:go_router/go_router.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What an action can look at when it asks "am I available?" and when it runs.
class ActionContext {
  const ActionContext({
    required this.context,
    required this.container,
    required this.router,
    required this.location,
  });

  final BuildContext context;

  /// Reads providers; stays valid after the palette that chose the action closed.
  final ProviderContainer container;
  final GoRouter router;

  /// The route the person is on, e.g. `/projects/p1/settings`.
  final String location;

  /// The project the current route belongs to, or null.
  String? get projectId =>
      RegExp(r'^/projects/([^/?]+)').firstMatch(location)?.group(1);

  /// The way the project's tasks are shown (`?view=` in the route; the list
  /// when it names none), or null off a project page.
  String? get view {
    if (projectId == null) return null;
    final v = Uri.tryParse(location)?.queryParameters['view'];
    return v == null || v.isEmpty ? 'list' : v;
  }

  /// The task open on screen (`?task=` in the route), or null.
  String? get taskId => Uri.tryParse(location)?.queryParameters['task'];
}

/// One thing a person can do, registered once. The palette, the keys, the
/// cheat sheet and the phone quick-actions sheet all read this entry, so
/// they cannot drift apart.
class AppAction {
  /// Each of title, group and semantic label is given either as plain text
  /// (tests, simple entries) or as a localized callback (`titleOf` ...).
  const AppAction({
    required this.id,
    String? title,
    String? group,
    String? semanticLabel,
    this.titleOf,
    this.groupOf,
    this.semanticOf,
    required this.run,
    this.keywords = const [],
    this.defaultKeys = '',
    this.views,
    this.available,
  }) : _title = title,
       _group = group,
       _semanticLabel = semanticLabel;

  /// Stable and lower-case (`nav.inbox`): the server stores bindings by it.
  final String id;
  final String? _title;
  final String? _group;
  final String? _semanticLabel;
  final String Function(AppLocalizations)? titleOf;
  final String Function(AppLocalizations)? groupOf;
  final String Function(AppLocalizations)? semanticOf;

  static AppLocalizations get _english =>
      lookupAppLocalizations(const Locale('en'));

  /// The title in English (search and tests); screens use [titleIn].
  String get title => _title ?? titleOf!(_english);

  /// The heading the cheat sheet files it under, in English.
  String get group => _group ?? groupOf!(_english);

  /// What a screen reader says, in English; never empty.
  String get semanticLabel => _semanticLabel ?? semanticOf!(_english);

  String titleIn(AppLocalizations l) => titleOf?.call(l) ?? title;
  String groupIn(AppLocalizations l) => groupOf?.call(l) ?? group;
  String semanticLabelIn(AppLocalizations l) =>
      semanticOf?.call(l) ?? semanticLabel;

  /// English words that also find it (searched next to the localized title).
  final List<String> keywords;

  /// The wire form of the default chord, or empty for none.
  final String defaultKeys;

  /// The views of a project page this action belongs to (`list`, `board`,
  /// `calendar`, `timeline`): it is offered, and its keys work, only there.
  /// Null: every page.
  final Set<String>? views;

  /// Null: always available.
  final bool Function(ActionContext)? available;
  final FutureOr<void> Function(ActionContext) run;

  bool isAvailable(ActionContext context) {
    final only = views;
    if (only != null && !only.contains(context.view)) return false;
    return available?.call(context) ?? true;
  }
}
