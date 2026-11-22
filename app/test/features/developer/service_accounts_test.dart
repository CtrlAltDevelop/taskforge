import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/developer/presentation/service_accounts_tab.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

import 'fakes.dart';

const _roles = RoleCatalog(
  roles: [
    Role(id: 'r-owner', name: 'Owner', isBuiltin: true, permissions: {}),
    Role(id: 'r-admin', name: 'Admin', isBuiltin: true, permissions: {}),
    Role(id: 'r-member', name: 'Member', isBuiltin: true, permissions: {}),
  ],
  registry: [],
);

Future<void> _open(WidgetTester tester, FakeDeveloperClient client) =>
    pumpDeveloper(
      tester,
      const Scaffold(body: ServiceAccountsTab()),
      client,
      overrides: [rolesProvider.overrideWith((ref) async => _roles)],
    );

void main() {
  testWidgets('lists accounts with their role and token count', (tester) async {
    await _open(
      tester,
      FakeDeveloperClient(accounts: [accountRow('sa1', name: 'Deploy bot')]),
    );
    expect(find.text('Deploy bot'), findsOneWidget);
    expect(find.textContaining('Member · 1 token'), findsOneWidget);
  });

  testWidgets('shows an empty state', (tester) async {
    await _open(tester, FakeDeveloperClient());
    expect(find.text('No service accounts yet.'), findsOneWidget);
  });

  testWidgets('creating needs a name and a role, and never offers Owner', (
    tester,
  ) async {
    final client = FakeDeveloperClient();
    await _open(tester, client);
    await tester.tap(find.byKey(const Key('new-account')));
    await tester.pumpAndSettle();

    TfButton save() =>
        tester.widget<TfButton>(find.byKey(const Key('save-account')));
    expect(save().onPressed, isNull);
    await tester.enterText(find.byKey(const Key('account-name')), 'CI');
    await tester.pump();
    expect(save().onPressed, isNull, reason: 'no role yet');

    await tester.tap(find.byKey(const Key('account-role')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-role-option-r-owner')), findsNothing);
    await tester.tap(find.byKey(const Key('account-role-option-r-admin')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-account')));
    await tester.pumpAndSettle();
    expect(find.text('CI'), findsOneWidget);
    expect(client.accounts.single.roleId, 'r-admin');
  });

  testWidgets('changes the role of an account', (tester) async {
    final client = FakeDeveloperClient(accounts: [accountRow('sa1')]);
    await _open(tester, client);
    await tester.tap(find.byKey(const Key('account-role-sa1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-role')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-role-option-r-admin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-account')));
    await tester.pumpAndSettle();
    expect(client.roleChanges, [('sa1', 'r-admin')]);
  });

  testWidgets('deleting asks first, then removes the account', (tester) async {
    final client = FakeDeveloperClient(accounts: [accountRow('sa1')]);
    await _open(tester, client);
    await tester.tap(find.byKey(const Key('account-delete-sa1')));
    await tester.pumpAndSettle();
    expect(client.deletedAccounts, isEmpty);
    await tester.tap(find.byKey(const Key('confirm-delete-account')));
    await tester.pumpAndSettle();
    expect(client.deletedAccounts, ['sa1']);
    expect(find.text('No service accounts yet.'), findsOneWidget);
  });

  testWidgets('a refused create shows the server reason', (tester) async {
    final client = FakeDeveloperClient()
      ..failAccount = const DeveloperException(
        DeveloperFailure.conflict,
        detail: 'Name taken',
      );
    await _open(tester, client);
    await tester.tap(find.byKey(const Key('new-account')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account-name')), 'CI');
    await tester.tap(find.byKey(const Key('account-role')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-role-option-r-member')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-account')));
    await tester.pumpAndSettle();
    expect(find.text('Name taken'), findsOneWidget);
  });

  testWidgets('makes a token for the account and shows its secret once', (
    tester,
  ) async {
    final client = FakeDeveloperClient(
      accounts: [accountRow('sa1')],
      tokenRows: [
        tokenRow('t-sa', serviceAccountId: 'sa1'),
        tokenRow('t-me'),
      ],
    );
    await _open(tester, client);
    await tester.tap(find.byKey(const Key('account-tokens-sa1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-token-t-sa')), findsOneWidget);
    expect(find.byKey(const Key('account-token-t-me')), findsNothing);

    await tester.tap(find.byKey(const Key('new-account-token')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('token-name')), 'Deploy');
    await tester.tap(find.byKey(const Key('scope-tasks:read')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('create-token')));
    await tester.pumpAndSettle();

    expect(client.accountTokenCalls, ['sa1']);
    expect(find.text('tf_secret_once'), findsOneWidget);
  });

  testWidgets('revokes a token of the account', (tester) async {
    final client = FakeDeveloperClient(
      accounts: [accountRow('sa1')],
      tokenRows: [tokenRow('t-sa', serviceAccountId: 'sa1')],
    );
    await _open(tester, client);
    await tester.tap(find.byKey(const Key('account-tokens-sa1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-revoke-t-sa')));
    await tester.pumpAndSettle();
    expect(client.revoked, ['t-sa']);
  });
}
