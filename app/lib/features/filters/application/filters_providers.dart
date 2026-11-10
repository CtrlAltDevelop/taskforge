import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/filters/data/filters_client.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final filtersClientProvider = Provider<FiltersClient>(
  (ref) => GrpcFiltersClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The filter on a project's views: what it is, the saved filter it came from
/// (if it is still that one) and its text for a summary chip.
@immutable
class ActiveFilterState {
  const ActiveFilterState({
    this.query = FilterQuery.none,
    this.savedId,
    this.text = '',
  });

  final FilterQuery query;
  final String? savedId;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is ActiveFilterState &&
      other.query == query &&
      other.savedId == savedId &&
      other.text == text;

  @override
  int get hashCode => Object.hash(query, savedId, text);
}

/// The filter applied to a project's list, board and calendar at once. It lasts
/// while the project is open (it is not saved: save a filter to keep one).
final activeFilterProvider = NotifierProvider.autoDispose
    .family<ActiveFilter, ActiveFilterState, String>(ActiveFilter.new);

class ActiveFilter extends Notifier<ActiveFilterState> {
  ActiveFilter(this.projectId);

  final String projectId;

  @override
  ActiveFilterState build() => const ActiveFilterState();

  void apply(FilterQuery query, {String? saved, String text = ''}) {
    state = ActiveFilterState(query: query, savedId: saved, text: text);
  }

  void clear() => state = const ActiveFilterState();
}

/// The AST of a project's active filter as the JSON the reads take ('' for no
/// filter). Only a change of the filter itself changes it.
final filterJsonProvider = Provider.autoDispose.family<String, String>(
  (ref, projectId) => ref.watch(
    activeFilterProvider(projectId).select((s) => s.query.toJsonString()),
  ),
);

/// The filters the person may use in a project.
final savedFiltersProvider = FutureProvider.autoDispose
    .family<List<SavedFilter>, String>((ref, projectId) async {
      final workspace = ref.watch(workspaceScopeProvider);
      if (workspace == null) return const [];
      return ref.watch(filtersClientProvider).list(workspace, projectId);
    }, retry: (_, _) => null);
