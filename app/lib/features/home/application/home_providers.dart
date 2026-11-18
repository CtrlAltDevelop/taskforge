import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/home/data/home_client.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final _grpcHomeProvider = Provider<GrpcHomeClient>(
  (ref) => GrpcHomeClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    cache: ref.watch(readCacheProvider),
  ),
);

final homeClientProvider = Provider<HomeClient>(
  (ref) => ref.watch(_grpcHomeProvider),
);

final onboardingClientProvider = Provider<OnboardingClient>(
  (ref) => ref.watch(_grpcHomeProvider),
);

/// The clock Home reads; tests replace it.
final homeNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Local hours at which the greeting changes ("good morning" starts at 5).
const greetingHours = [5, 12, 17];

/// The next moment the greeting or the date changes after [now]: the next of
/// 05:00, 12:00, 17:00 and midnight, local time.
DateTime nextClockBoundary(DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  for (final h in greetingHours) {
    final at = day.add(Duration(hours: h));
    if (at.isAfter(now)) return at;
  }
  return DateTime(now.year, now.month, now.day + 1);
}

/// The moment Home shows now, moved on at every greeting boundary and at
/// local midnight, so "good morning" never lingers into the evening or past
/// the date it was drawn for.
final homeClockProvider = NotifierProvider<HomeClock, DateTime>(HomeClock.new);

class HomeClock extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    final now = ref.read(homeNowProvider)();
    _arm(now);
    return now;
  }

  void _arm(DateTime now) {
    _timer?.cancel();
    _timer = Timer(nextClockBoundary(now).difference(now), () {
      if (!ref.mounted) return;
      final next = ref.read(homeNowProvider)();
      state = next;
      _arm(next);
    });
  }
}

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Today's date (local), changing at midnight.
final homeTodayProvider = Provider<String>(
  (ref) => isoDate(ref.watch(homeClockProvider)),
);

/// A Home read and whether it came from the last saved copy (the server could
/// not be reached).
@immutable
class Fresh<T> {
  const Fresh(this.value, {this.stale = false});

  final T value;
  final bool stale;
}

/// The summary behind Today, Recent, Mentions, Time and Pinned.
final homeSummaryProvider = FutureProvider.autoDispose<Fresh<HomeSummary>>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  final today = ref.watch(homeTodayProvider);
  if (ws == null) return const Fresh(HomeSummary());
  final offset = ref.read(homeNowProvider)().timeZoneOffset.inMinutes;
  final summary = await ref
      .watch(homeClientProvider)
      .summary(ws, today: today, utcOffsetMinutes: offset);
  return Fresh(summary, stale: !ref.read(networkProvider));
}, retry: (_, _) => null);

/// What the "Assigned to me" card lists (open tasks assigned to the person).
const assignedCardLimit = 20;

final homeAssignedProvider =
    FutureProvider.autoDispose<Fresh<List<MyWorkItem>>>((ref) async {
      final ws = ref.watch(workspaceScopeProvider);
      final today = ref.watch(homeTodayProvider);
      if (ws == null) return const Fresh([]);
      final page = await ref
          .watch(homeClientProvider)
          .myWork(
            ws,
            today: today,
            query: const MyWorkQuery(relation: MyWorkRelation.assigned),
            limit: assignedCardLimit,
          );
      return Fresh(page.items, stale: !ref.read(networkProvider));
    }, retry: (_, _) => null);

/// The first-run checklist, starters and sample count of this workspace.
final onboardingProvider = FutureProvider.autoDispose<OnboardingState>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const OnboardingState();
  return ref.watch(onboardingClientProvider).get(ws);
}, retry: (_, _) => null);

/// Tells the server a checklist step happened that only the app can see
/// (the board was opened, the palette was used). Sent once per workspace and
/// step per session; a failure is not worth an error.
final onboardingStepsProvider = NotifierProvider<OnboardingSteps, Set<String>>(
  OnboardingSteps.new,
);

class OnboardingSteps extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  Future<void> note(String step) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null || state.contains('$ws/$step')) return;
    state = {...state, '$ws/$step'};
    try {
      await ref.read(onboardingClientProvider).completeStep(ws, step);
      ref.invalidate(onboardingProvider);
    } on Object catch (e) {
      debugPrint('onboarding: cannot record $step ($e)');
      state = {...state}..remove('$ws/$step');
    }
  }
}

/// Records that the person opened a task (the Recent card). Failures are
/// ignored: Recent is a convenience.
Future<void> recordRecentTask(Ref ref, String taskId) async {
  final ws = ref.read(workspaceScopeProvider);
  if (ws == null || taskId.isEmpty) return;
  try {
    await ref.read(homeClientProvider).recordRecent(ws, taskId);
  } on Object catch (e) {
    debugPrint('home: cannot record recent ($e)');
  }
}

final recordRecentProvider = Provider<Future<void> Function(String)>(
  (ref) =>
      (taskId) => recordRecentTask(ref, taskId),
);

/// The cards Home can show, in their default order.
const homeCardIds = [
  'checklist',
  'today',
  'assigned',
  'mentions',
  'recent',
  'time',
  'pinned',
];

/// Which cards show and in what order: a local preference.
@immutable
class HomeCards {
  const HomeCards({this.order = homeCardIds, this.hidden = const {}});

  final List<String> order;
  final Set<String> hidden;

  List<String> get shown => [
    for (final id in order)
      if (!hidden.contains(id)) id,
  ];

  HomeCards copyWith({List<String>? order, Set<String>? hidden}) =>
      HomeCards(order: order ?? this.order, hidden: hidden ?? this.hidden);

  /// The saved form, kept for cards added in a later version.
  String toJson() => jsonEncode({'order': order, 'hidden': hidden.toList()});

  static HomeCards fromJson(String? text) {
    if (text == null) return const HomeCards();
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      final saved = [
        for (final id in (map['order'] as List? ?? const []))
          if (homeCardIds.contains(id)) id as String,
      ];
      final order = [
        ...saved,
        for (final id in homeCardIds)
          if (!saved.contains(id)) id,
      ];
      return HomeCards(
        order: List.unmodifiable(order),
        hidden: {
          for (final id in (map['hidden'] as List? ?? const []))
            if (homeCardIds.contains(id)) id as String,
        },
      );
    } on Object {
      return const HomeCards();
    }
  }
}

final homeCardsProvider = NotifierProvider<HomeCardsNotifier, HomeCards>(
  HomeCardsNotifier.new,
);

class HomeCardsNotifier extends Notifier<HomeCards> {
  static const _key = 'home.cards.v1';

  @override
  HomeCards build() {
    ref.read(localPrefsProvider).read(_key).then((saved) {
      if (!ref.mounted || saved == null) return;
      state = HomeCards.fromJson(saved);
    });
    return const HomeCards();
  }

  void _set(HomeCards next) {
    state = next;
    ref.read(localPrefsProvider).write(_key, next.toJson());
  }

  void hide(String id) => _set(state.copyWith(hidden: {...state.hidden, id}));

  void show(String id) =>
      _set(state.copyWith(hidden: {...state.hidden}..remove(id)));

  void reorder(int from, int to) {
    final order = [...state.order];
    final moved = order.removeAt(from);
    order.insert(to > from ? to - 1 : to, moved);
    _set(state.copyWith(order: order));
  }

  void reset() => _set(const HomeCards());
}

/// My work's own toolbar choices: who the work is mine through, and whether
/// finished work shows. The filter is the shared one (see
/// [myWorkFilterScope]).
@immutable
class MyWorkOptions {
  const MyWorkOptions({
    this.relation = MyWorkRelation.both,
    this.includeDone = false,
  });

  final MyWorkRelation relation;
  final bool includeDone;
}

final myWorkOptionsProvider =
    NotifierProvider<MyWorkOptionsNotifier, MyWorkOptions>(
      MyWorkOptionsNotifier.new,
    );

/// Kept on this device ([_key]); the filter is not (it is per session).
class MyWorkOptionsNotifier extends Notifier<MyWorkOptions> {
  static const _key = 'mywork.options.v1';

  /// Completes when the saved choice has been read; My work waits for it so
  /// the list is asked for once, with the right options.
  late final Future<void> ready = _load();

  @override
  MyWorkOptions build() {
    unawaited(ready);
    return const MyWorkOptions();
  }

  Future<void> _load() async {
    final saved = await ref.read(localPrefsProvider).read(_key);
    if (!ref.mounted || saved == null) return;
    try {
      final map = jsonDecode(saved) as Map<String, dynamic>;
      state = MyWorkOptions(
        relation:
            MyWorkRelation.values
                .where((r) => r.name == map['relation'])
                .firstOrNull ??
            MyWorkRelation.both,
        includeDone: map['includeDone'] == true,
      );
    } on Object {
      // A broken value is the same as none.
    }
  }

  void _set(MyWorkOptions next) {
    state = next;
    ref
        .read(localPrefsProvider)
        .write(
          _key,
          jsonEncode({
            'relation': next.relation.name,
            'includeDone': next.includeDone,
          }),
        );
  }

  void relation(MyWorkRelation r) =>
      _set(MyWorkOptions(relation: r, includeDone: state.includeDone));

  void includeDone({required bool on}) =>
      _set(MyWorkOptions(relation: state.relation, includeDone: on));
}

/// What My work asks the server: the options and the filter's AST.
final myWorkQueryProvider = Provider.autoDispose<MyWorkQuery>((ref) {
  final options = ref.watch(myWorkOptionsProvider);
  return MyWorkQuery(
    relation: options.relation,
    includeDone: options.includeDone,
    filterAst: ref.watch(filterJsonProvider(myWorkFilterScope)),
  );
});

@immutable
class MyWorkState {
  const MyWorkState({
    this.page = MyWorkPage.empty,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.stale = false,
  });

  final MyWorkPage page;
  final bool loading;
  final bool loadingMore;
  final Object? error;
  final bool stale;
}

/// The My work list: the first page, then more by cursor. A new query (a
/// filter, the relation, include done) starts again from the top.
final myWorkProvider =
    NotifierProvider.autoDispose<MyWorkNotifier, MyWorkState>(
      MyWorkNotifier.new,
    );

class MyWorkNotifier extends Notifier<MyWorkState> {
  var _generation = 0;

  @override
  MyWorkState build() {
    final ws = ref.watch(workspaceScopeProvider);
    ref.watch(myWorkQueryProvider);
    ref.watch(homeTodayProvider);
    if (ws == null) return const MyWorkState();
    Future.microtask(reload);
    return const MyWorkState(loading: true);
  }

  Future<MyWorkPage> _fetch(String cursor) => ref
      .read(homeClientProvider)
      .myWork(
        ref.read(workspaceScopeProvider)!,
        today: ref.read(homeTodayProvider),
        query: ref.read(myWorkQueryProvider),
        cursor: cursor,
      );

  Future<void> reload() async {
    if (!ref.mounted || ref.read(workspaceScopeProvider) == null) return;
    final generation = ++_generation;
    state = MyWorkState(page: state.page, loading: true);
    try {
      await ref.read(myWorkOptionsProvider.notifier).ready;
      if (!ref.mounted || generation != _generation) return;
      final page = await _fetch('');
      if (!ref.mounted || generation != _generation) return;
      state = MyWorkState(page: page, stale: !ref.read(networkProvider));
    } on Object catch (e) {
      if (!ref.mounted || generation != _generation) return;
      state = MyWorkState(error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.page.hasMore) return;
    final generation = _generation;
    final before = state;
    state = MyWorkState(
      page: before.page,
      loadingMore: true,
      stale: before.stale,
    );
    try {
      final next = await _fetch(before.page.nextCursor);
      if (!ref.mounted || generation != _generation) return;
      state = MyWorkState(page: before.page.plus(next), stale: before.stale);
    } on Object catch (e) {
      if (!ref.mounted || generation != _generation) return;
      state = MyWorkState(page: before.page, error: e, stale: before.stale);
    }
  }
}

/// The ids of the dashboards pinned to Home (empty while the summary loads or
/// when it cannot be read).
final pinnedDashboardIdsProvider = Provider.autoDispose<Set<String>>(
  (ref) => {
    for (final p
        in ref.watch(homeSummaryProvider).value?.value.pinned ?? const [])
      p.dashboardId,
  },
);

/// Pins a dashboard to Home or takes it off, then reads the summary again so
/// the Pinned card follows. Throws a [HomeException] when the server refuses.
final pinDashboardProvider =
    Provider<Future<void> Function(String dashboardId, {required bool pinned})>(
      (ref) => (dashboardId, {required pinned}) async {
        final ws = ref.read(workspaceScopeProvider);
        if (ws == null) return;
        await ref
            .read(homeClientProvider)
            .pinDashboard(ws, dashboardId, pinned: pinned);
        ref.invalidate(homeSummaryProvider);
      },
    );
