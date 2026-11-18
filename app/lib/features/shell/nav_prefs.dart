import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

/// How many recently opened projects the sidebar remembers.
const recentProjectsMax = 5;

/// The frame's per-device memory: sidebar collapsed, which groups are open,
/// the project order and the projects opened last. Local only (decided in
/// phase 45): a synced order can come later as its own change.
@immutable
class NavPrefs {
  const NavPrefs({
    this.collapsed = false,
    this.openSections = const {},
    this.projectOrder = const [],
    this.recent = const [],
  });

  factory NavPrefs.fromJson(Map<String, dynamic> json) => NavPrefs(
    collapsed: json['collapsed'] == true,
    openSections: _strings(json['open']).toSet(),
    projectOrder: _strings(json['order']),
    recent: _strings(json['recent']),
  );

  static List<String> _strings(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  final bool collapsed;

  /// Section ids (`workspace`, `admin`, `favorites`, ...) the person opened;
  /// see [isOpen] for which start open.
  final Set<String> openSections;
  final List<String> projectOrder;

  /// Project ids, newest first.
  final List<String> recent;

  /// Workspace and Admin start closed, the project lists start open; a
  /// toggle flips the default.
  bool isOpen(String section) =>
      openSections.contains(section) != _startsOpen(section);

  static bool _startsOpen(String section) =>
      section != 'workspace' && section != 'admin';

  NavPrefs copyWith({
    bool? collapsed,
    Set<String>? openSections,
    List<String>? projectOrder,
    List<String>? recent,
  }) => NavPrefs(
    collapsed: collapsed ?? this.collapsed,
    openSections: openSections ?? this.openSections,
    projectOrder: projectOrder ?? this.projectOrder,
    recent: recent ?? this.recent,
  );

  Map<String, dynamic> toJson() => {
    'collapsed': collapsed,
    'open': openSections.toList(),
    'order': projectOrder,
    'recent': recent,
  };
}

/// [projects] in the saved [order]; ones not in it yet follow by name.
List<Project> orderedProjects(List<Project> projects, List<String> order) {
  final rank = {for (final (i, id) in order.indexed) id: i};
  final known = projects.where((p) => rank.containsKey(p.id)).toList()
    ..sort((a, b) => rank[a.id]!.compareTo(rank[b.id]!));
  final rest = projects.where((p) => !rank.containsKey(p.id)).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return [...known, ...rest];
}

/// The new full order after moving [list]`[from]` to index [to] of the list
/// without it (`onReorderItem`'s already-adjusted index). Projects outside
/// [list] keep their place after it.
List<String> movedOrder(
  List<Project> list,
  int from,
  int to,
  List<String> old,
) {
  final ids = [for (final p in list) p.id];
  final moved = ids.removeAt(from);
  ids.insert(to, moved);
  return [...ids, ...old.where((id) => !ids.contains(id))];
}

final navPrefsProvider = NotifierProvider<NavPrefsNotifier, NavPrefs>(
  NavPrefsNotifier.new,
);

class NavPrefsNotifier extends Notifier<NavPrefs> {
  static const _key = 'nav.v1';

  /// Changes made before the saved copy arrived; they are applied on top of
  /// it, so opening the app on a project page cannot erase what was saved.
  final _pending = <NavPrefs Function(NavPrefs)>[];
  bool _loaded = false;

  @override
  NavPrefs build() {
    ref.read(localPrefsProvider).read(_key).then((saved) {
      if (!ref.mounted) return;
      var next = state;
      if (saved != null) {
        try {
          final json = jsonDecode(saved);
          if (json is Map<String, dynamic>) next = NavPrefs.fromJson(json);
        } on FormatException catch (e) {
          debugPrint('nav prefs: unreadable ($e)');
        }
      }
      _loaded = true;
      final changes = [..._pending];
      _pending.clear();
      for (final change in changes) {
        next = change(next);
      }
      state = next;
      if (changes.isNotEmpty) _write();
    });
    return const NavPrefs();
  }

  void _write() =>
      ref.read(localPrefsProvider).write(_key, jsonEncode(state.toJson()));

  void _apply(NavPrefs Function(NavPrefs) change) {
    state = change(state);
    if (_loaded) {
      _write();
    } else {
      _pending.add(change);
    }
  }

  void toggleCollapsed() => _apply((p) => p.copyWith(collapsed: !p.collapsed));

  void toggleSection(String id) => _apply((p) {
    final open = {...p.openSections};
    open.contains(id) ? open.remove(id) : open.add(id);
    return p.copyWith(openSections: open);
  });

  void setOrder(List<String> order) =>
      _apply((p) => p.copyWith(projectOrder: order));

  /// [projectId] was opened: it moves to the front of the recent list.
  void visited(String projectId) {
    if (state.recent.firstOrNull == projectId) return;
    _apply(
      (p) => p.copyWith(
        recent: [
          projectId,
          ...p.recent.where((id) => id != projectId),
        ].take(recentProjectsMax).toList(),
      ),
    );
  }
}

/// Where the sidebar list was scrolled to. Each page brings its own frame,
/// so the new sidebar starts where the last one stopped.
class SidebarScrollMemory {
  double offset = 0;
}

final sidebarScrollProvider = Provider<SidebarScrollMemory>(
  (ref) => SidebarScrollMemory(),
);

/// The sidebar item that had keyboard focus when a page was opened, so the
/// new page's sidebar can hand focus back to it.
final sidebarFocusProvider = NotifierProvider<SidebarFocus, String?>(
  SidebarFocus.new,
);

class SidebarFocus extends Notifier<String?> {
  @override
  String? build() => null;

  void remember(String? key) => state = key;
}
