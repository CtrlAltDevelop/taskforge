import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/sessions_api.dart';
import 'package:taskforge/features/account/sessions_screen.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

class _FakeSessionsApi implements SessionsApi {
  _FakeSessionsApi(this.items);

  List<SessionInfo> items;
  final renamed = <String, String>{};
  bool failRename = false;

  @override
  Future<List<SessionInfo>> list() async => [
    for (final s in items)
      if (renamed.containsKey(s.id)) _named(s, renamed[s.id]!) else s,
  ];

  @override
  Future<String> rename(String sessionId, String name) async {
    if (failRename) {
      throw const AuthApiException(status: 500, title: 'X', message: 'no');
    }
    renamed[sessionId] = name;
    return name;
  }

  SessionInfo _named(SessionInfo s, String name) => SessionInfo(
    id: s.id,
    userAgent: s.userAgent,
    ipAddress: s.ipAddress,
    lastUsedAt: s.lastUsedAt,
    current: s.current,
    name: name,
  );
}

SessionInfo _session(
  String id, {
  String name = '',
  bool current = false,
  bool newDevice = false,
  bool keyChanged = false,
  bool bound = false,
}) => SessionInfo(
  id: id,
  userAgent: 'Mozilla',
  ipAddress: '10.0.0.1',
  lastUsedAt: '2026-03-02T10:00:00Z',
  current: current,
  name: name,
  newDevice: newDevice,
  keyChanged: keyChanged,
  dpopBound: bound,
);

Future<_FakeSessionsApi> _pump(
  WidgetTester tester,
  List<SessionInfo> items,
) async {
  final api = _FakeSessionsApi(items);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionsApiProvider.overrideWithValue(api)],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

void main() {
  testWidgets('shows This device, New and Key changed chips per session', (
    tester,
  ) async {
    await _pump(tester, [
      _session('a', name: 'Work laptop', current: true, bound: true),
      _session('b', newDevice: true),
      _session('c', keyChanged: true),
    ]);

    expect(find.text('Work laptop'), findsOneWidget);
    expect(find.byKey(const Key('chip-current')), findsOneWidget);
    expect(find.byKey(const Key('chip-new')), findsOneWidget);
    expect(find.byKey(const Key('chip-key-changed')), findsOneWidget);
    expect(find.byKey(const Key('session-bound')), findsOneWidget);
    // The current session cannot be revoked from its own list.
    expect(find.byKey(const Key('revoke-a')), findsNothing);
    expect(find.byKey(const Key('revoke-b')), findsOneWidget);
    expect(find.byKey(const Key('revoke-others')), findsOneWidget);
    expect(find.byKey(const Key('device-privacy-note')), findsOneWidget);
  });

  testWidgets('renaming saves the trimmed name and refreshes the list', (
    tester,
  ) async {
    final api = await _pump(tester, [_session('a', current: true)]);

    await tester.tap(find.byKey(const Key('rename-a')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rename-field')), '  Phone  ');
    await tester.tap(find.byKey(const Key('rename-save')));
    await tester.pumpAndSettle();

    expect(api.renamed['a'], 'Phone');
    expect(find.text('Phone'), findsOneWidget);
  });

  testWidgets('an empty name keeps the dialog open and does not save', (
    tester,
  ) async {
    final api = await _pump(tester, [_session('a', current: true)]);

    await tester.tap(find.byKey(const Key('rename-a')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rename-field')), '   ');
    await tester.tap(find.byKey(const Key('rename-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rename-field')), findsOneWidget);
    expect(api.renamed, isEmpty);
  });

  testWidgets('a failed rename shows a message', (tester) async {
    final api = await _pump(tester, [_session('a', current: true)]);
    api.failRename = true;

    await tester.tap(find.byKey(const Key('rename-a')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rename-field')), 'Phone');
    await tester.tap(find.byKey(const Key('rename-save')));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
