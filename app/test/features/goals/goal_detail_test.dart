import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/goals/application/goals_providers.dart';
import 'package:taskforge/features/goals/data/goals_client.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/features/goals/presentation/goal_detail_screen.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

KeyResult _kr(String id, String name, {KrType type = KrType.number}) =>
    KeyResult(
      id: id,
      goalId: 'g1',
      name: name,
      type: type,
      startValue: '0',
      targetValue: '100',
      currentValue: '40',
      filterText: '',
      taskIds: const [],
      weight: '1',
      linkedDone: 0,
      linkedTotal: 0,
      progress: 0.4,
      version: 1,
    );

Goal _goal({bool canCheckIn = true, List<KeyResult>? krs}) => Goal(
  id: 'g1',
  parentId: '',
  folderId: '',
  name: 'Grow signups',
  description: 'More people',
  ownerId: '',
  private: false,
  periodStart: '2026-10-01',
  periodEnd: '2026-12-31',
  statusOverride: '',
  status: GoalStatus.onTrack,
  statusHint: GoalStatus.onTrack,
  weight: '1',
  progress: 0.4,
  version: 1,
  canEdit: true,
  canCheckIn: canCheckIn,
  contributorIds: const [],
  childIds: const [],
  keyResults: krs ?? [_kr('k1', 'Signups')],
);

class _Goals implements GoalsClient {
  _Goals(this.goal);

  final Goal goal;
  final sent = <({String kr, String value, String note})>[];
  GoalsException? fail;
  List<CheckIn> history = [
    CheckIn(
      id: 'c1',
      krId: 'k1',
      userId: '',
      value: '40',
      previousValue: '25',
      progress: 0.4,
      note: 'Launch week',
      at: DateTime(2026, 11, 1),
    ),
  ];

  @override
  Future<GoalCatalog> list(String workspaceId) async =>
      GoalCatalog([goal], const []);

  @override
  Future<List<CheckIn>> checkIns(String workspaceId, String krId) async =>
      history;

  @override
  Future<Goal> addCheckIn(
    String workspaceId,
    String krId,
    String value,
    String note,
  ) async {
    final error = fail;
    if (error != null) throw error;
    sent.add((kr: krId, value: value, note: note));
    return goal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_Goals.${invocation.memberName}');
}

Future<void> _pump(WidgetTester tester, _Goals client) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceScopeProvider.overrideWithValue('w1'),
        goalsClientProvider.overrideWithValue(client),
        membersProvider.overrideWith((ref) async => const []),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: GoalDetailScreen(goalId: 'g1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the goal, its status and its key results', (tester) async {
    await _pump(tester, _Goals(_goal()));

    expect(find.text('Grow signups'), findsOneWidget);
    expect(find.text('More people'), findsOneWidget);
    expect(find.byKey(const Key('kr-k1')), findsOneWidget);
    expect(find.text('Signups'), findsOneWidget);
  });

  testWidgets('says so when a goal has no key results', (tester) async {
    await _pump(tester, _Goals(_goal(krs: const [])));

    expect(find.byKey(const Key('kr-k1')), findsNothing);
    expect(find.byKey(const Key('add-kr')), findsOneWidget);
  });

  testWidgets('no check-in button without the right to check in', (
    tester,
  ) async {
    await _pump(tester, _Goals(_goal(canCheckIn: false)));

    expect(find.byKey(const Key('checkin-k1')), findsNothing);
  });

  testWidgets('a check-in sends the value and note and shows the history', (
    tester,
  ) async {
    final client = _Goals(_goal());
    await _pump(tester, client);

    await tester.tap(find.byKey(const Key('checkin-k1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkin-c1')), findsOneWidget);
    expect(find.text('25 → 40'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('checkin-value')), '55');
    await tester.enterText(find.byKey(const Key('checkin-note')), 'Ads');
    await tester.tap(find.byKey(const Key('save-checkin')));
    await tester.pumpAndSettle();

    expect(client.sent.single, (kr: 'k1', value: '55', note: 'Ads'));
    expect(find.byKey(const Key('save-checkin')), findsNothing);
  });

  testWidgets('a refused check-in keeps the dialog open with the reason', (
    tester,
  ) async {
    final client = _Goals(_goal())
      ..fail = const GoalsException(GoalsFailure.invalid, detail: 'Too big.');
    await _pump(tester, client);

    await tester.tap(find.byKey(const Key('checkin-k1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-checkin')));
    await tester.pumpAndSettle();

    expect(find.text('Too big.'), findsOneWidget);
    expect(find.byKey(const Key('save-checkin')), findsOneWidget);
  });

  testWidgets('a yes/no key result is checked in with a switch', (
    tester,
  ) async {
    final client = _Goals(
      _goal(krs: [_kr('k1', 'Ship it', type: KrType.boolean)]),
    );
    await _pump(tester, client);

    await tester.tap(find.byKey(const Key('checkin-k1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkin-done')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save-checkin')));
    await tester.pumpAndSettle();

    expect(client.sent.single.value, '1');
  });
}
