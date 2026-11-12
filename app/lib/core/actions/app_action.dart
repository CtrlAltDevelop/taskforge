import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:go_router/go_router.dart';

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
  const AppAction({
    required this.id,
    required this.title,
    required this.group,
    required this.semanticLabel,
    required this.run,
    this.keywords = const [],
    this.defaultKeys = '',
    this.views,
    this.available,
  });

  /// Stable and lower-case (`nav.inbox`): the server stores bindings by it.
  final String id;
  final String title;

  /// The heading the cheat sheet files it under.
  final String group;

  /// What a screen reader says; never empty.
  final String semanticLabel;
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
