import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/developer/presentation/deliveries_screen.dart';
import 'package:taskforge/features/developer/presentation/developer_screen.dart';
import 'package:taskforge/features/developer/presentation/webhooks_tab.dart';

import '../projects/fakes.dart';
import 'fakes.dart';

Future<void> _openEditor(
  WidgetTester tester,
  FakeDeveloperClient client, {
  bool existing = false,
}) async {
  await pumpDeveloper(
    tester,
    const WebhooksTab(),
    client,
    projects: FakeProjectsClient([project('p1', 'Apollo')]),
  );
  await tester.tap(
    find.byKey(Key(existing ? 'webhook-menu-h1' : 'new-webhook')),
  );
  await tester.pumpAndSettle();
  if (existing) {
    await tester.tap(find.text('Edit webhook'));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('token dialog', () {
    testWidgets('needs a name and a scope, then shows the secret once', (
      tester,
    ) async {
      final client = FakeDeveloperClient(tokenRows: [tokenRow('t1')]);
      await pumpDeveloper(tester, const DeveloperScreen(), client);

      await tester.tap(find.byKey(const Key('new-token')));
      await tester.pumpAndSettle();
      TfButton create() =>
          tester.widget<TfButton>(find.byKey(const Key('create-token')));
      expect(create().onPressed, isNull);

      await tester.enterText(find.byKey(const Key('token-name')), 'Deploy');
      await tester.pump();
      expect(create().onPressed, isNull, reason: 'no scope yet');

      expect(find.byKey(const Key('scope-tasks:read')), findsOneWidget);
      expect(find.byKey(const Key('scope-tasks:write')), findsOneWidget);
      await tester.tap(find.byKey(const Key('scope-tasks:write')));
      await tester.pump();
      expect(create().onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('create-token')));
      await tester.pumpAndSettle();

      expect(client.tokenCalls.single.name, 'Deploy');
      expect(client.tokenCalls.single.scopes, ['tasks:write']);
      expect(find.byKey(const Key('token-secret')), findsOneWidget);
      expect(find.text('tf_secret_once'), findsOneWidget);

      await tester.tap(find.byKey(const Key('secret-done')));
      await tester.pumpAndSettle();
      expect(find.text('tf_secret_once'), findsNothing);
      expect(find.byKey(const Key('token-secret')), findsNothing);
    });
  });

  group('webhook editor', () {
    testWidgets('lists the events as a checklist and needs one', (
      tester,
    ) async {
      final client = FakeDeveloperClient();
      await _openEditor(tester, client);

      expect(find.byKey(const Key('event-task.created')), findsOneWidget);
      expect(find.byKey(const Key('event-task.deleted')), findsOneWidget);
      TfButton save() =>
          tester.widget<TfButton>(find.byKey(const Key('save-webhook')));
      await tester.enterText(
        find.byKey(const Key('webhook-url')),
        'https://example.com/x',
      );
      await tester.pump();
      expect(save().onPressed, isNull, reason: 'no event chosen');

      await tester.tap(find.byKey(const Key('event-task.deleted')));
      await tester.pump();
      expect(save().onPressed, isNotNull);
    });

    testWidgets('defaults to the whole workspace', (tester) async {
      final client = FakeDeveloperClient();
      await _openEditor(tester, client);
      await tester.enterText(
        find.byKey(const Key('webhook-url')),
        'https://example.com/x',
      );
      await tester.tap(find.byKey(const Key('event-task.created')));
      await tester.pump();

      expect(find.text('Whole workspace'), findsOneWidget);
      await tester.tap(find.byKey(const Key('save-webhook')));
      await tester.pumpAndSettle();

      expect(client.created.single.projectId, '');
      expect(client.created.single.events, ['task.created']);
    });

    testWidgets('limits the hook to the project picked', (tester) async {
      final client = FakeDeveloperClient();
      await _openEditor(tester, client);
      await tester.enterText(
        find.byKey(const Key('webhook-url')),
        'https://example.com/x',
      );
      await tester.tap(find.byKey(const Key('event-task.created')));
      await tester.tap(find.byKey(const Key('webhook-project')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apollo').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-webhook')));
      await tester.pumpAndSettle();

      expect(client.created.single.projectId, 'p1');
    });

    testWidgets('an existing hook opens on its project and can go back to '
        'the whole workspace', (tester) async {
      final client = FakeDeveloperClient(hooks: [hookRow(projectId: 'p1')]);
      await _openEditor(tester, client, existing: true);

      expect(find.text('Apollo'), findsOneWidget);
      await tester.tap(find.byKey(const Key('webhook-project')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Whole workspace').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-webhook')));
      await tester.pumpAndSettle();

      expect(client.updated.single.projectId, '');
    });
  });

  group('delivery log', () {
    testWidgets('Resend sends that delivery again and refreshes the log', (
      tester,
    ) async {
      final client = FakeDeveloperClient(deliveryRows: [deliveryRow('d1')]);
      await pumpDeveloper(
        tester,
        const DeliveriesScreen(webhookId: 'h1'),
        client,
      );

      await tester.tap(find.byKey(const Key('delivery-d1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('resend-d1')));
      await tester.pumpAndSettle();

      expect(client.resent, ['d1']);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
