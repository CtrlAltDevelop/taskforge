import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/filters/data/filters_client.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/views/application/personal_layout.dart';
import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/filter_layout.dart';
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

/// The person's filter on a project, kept like a layout: it is read when the
/// project opens (and checked: a filter whose field is gone is dropped) and
/// saved a moment after every change, so it is there on the next visit and on
/// another device. The calendar of every project (the empty project id) keeps
/// its filter for the session only.
final filterLayoutProvider = NotifierProvider.autoDispose
    .family<FilterLayoutNotifier, PersonalLayoutState<FilterLayout>, String>(
      FilterLayoutNotifier.new,
    );

class FilterLayoutNotifier extends PersonalLayoutNotifier<FilterLayout> {
  FilterLayoutNotifier(String projectId)
    : super(projectId, const FilterLayout());

  bool get _sessionOnly => projectId.isEmpty;

  @override
  bool get keepAlive => _sessionOnly;

  @override
  bool get persists => !_sessionOnly;

  @override
  Future<StoredLayout<FilterLayout>?> findMine(
    ViewsClient client,
    String workspace,
  ) async {
    if (_sessionOnly) return null;
    final found = await client.findFilter(workspace, projectId);
    if (found == null || found.layout.isEmpty) return null;
    // Read it again: the text follows today's names, and a filter that no longer
    // means anything (a field was removed) is not applied.
    try {
      final checked = await ref
          .read(filtersClientProvider)
          .validate(workspace, projectId, astJson: found.layout.astJson);
      if (!checked.ok) {
        return (
          id: found.id,
          version: found.version,
          layout: const FilterLayout(),
        );
      }
      return (
        id: found.id,
        version: found.version,
        layout: FilterLayout(
          astJson: found.layout.astJson,
          savedId: found.layout.savedId,
          text: checked.tfql,
        ),
      );
    } on FilterException {
      return (
        id: found.id,
        version: found.version,
        layout: const FilterLayout(),
      );
    }
  }

  @override
  Future<StoredLayout<FilterLayout>> store(
    ViewsClient client,
    String workspace,
    FilterLayout layout, {
    required String id,
    required int version,
  }) async {
    if (_sessionOnly) return (id: '', version: 0, layout: layout);
    final saved = await client.saveFilter(
      workspace,
      projectId,
      layout: layout,
      id: id,
      expectedVersion: version,
    );
    return (id: saved.id, version: saved.version, layout: layout);
  }
}

/// Whether the person's filter has been read, so a view reads its data once,
/// with it.
final filterReadyProvider = Provider.autoDispose.family<bool, String>(
  (ref, projectId) =>
      ref.watch(filterLayoutProvider(projectId).select((s) => s.loaded)),
);

/// The filter applied to a project's list, board and calendar at once.
final activeFilterProvider = NotifierProvider.autoDispose
    .family<ActiveFilter, ActiveFilterState, String>(ActiveFilter.new);

class ActiveFilter extends Notifier<ActiveFilterState> {
  ActiveFilter(this.projectId);

  final String projectId;

  @override
  ActiveFilterState build() {
    final layout = ref.watch(
      filterLayoutProvider(projectId).select((s) => s.layout),
    );
    return ActiveFilterState(
      query: FilterQuery.fromJsonString(layout.astJson),
      savedId: layout.savedId.isEmpty ? null : layout.savedId,
      text: layout.text,
    );
  }

  void apply(FilterQuery query, {String? saved, String text = ''}) => ref
      .read(filterLayoutProvider(projectId).notifier)
      .set(
        FilterLayout(
          astJson: query.toJsonString(),
          savedId: saved ?? '',
          text: text,
        ),
      );

  void clear() => ref
      .read(filterLayoutProvider(projectId).notifier)
      .set(const FilterLayout());
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
