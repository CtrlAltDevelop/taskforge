import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';

/// The text of "Search in view": one per project, so it stays when the person
/// moves between the list, board, calendar and timeline.
final viewSearchProvider = NotifierProvider.family<ViewSearch, String, String>(
  ViewSearch.new,
);

class ViewSearch extends Notifier<String> {
  ViewSearch(this.projectId);

  final String projectId;

  @override
  String build() => '';

  void set(String text) => state = text.trim();
}

/// Whether [task] fits the search: its title or id holds every word.
bool matchesSearch(Task task, String query) {
  if (query.isEmpty) return true;
  final hay = '${task.displayId} ${task.title}'.toLowerCase();
  return query.toLowerCase().split(RegExp(r'\s+')).every(hay.contains);
}

/// [tasks] narrowed by [query] (the same list when there is no search).
List<Task> searched(List<Task> tasks, String query) => query.isEmpty
    ? tasks
    : [
        for (final t in tasks)
          if (matchesSearch(t, query)) t,
      ];
