import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/domain/system.dart';
import 'package:taskforge/features/system/presentation/version_screens.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

void main() {
  test('isUpdateRequired compares against the server minimum', () {
    const server = ServerVersion(version: '2.0.0', minClientVersion: '1.5.0');
    expect(server.isUpdateRequired('1.4.9'), isTrue);
    expect(server.isUpdateRequired('1.5.0'), isFalse);
    expect(server.isUpdateRequired('1.10.0'), isFalse);
    expect(server.isNewerThan('1.9.0'), isTrue);
    expect(server.isNewerThan('2.0.0'), isFalse);
  });

  testWidgets('an app older than the minimum is held on the update screen', (
    tester,
  ) async {
    final container = await pumpSignedIn(
      tester,
      FakeWorkspaceClient([ws('w1', 'WS one')]),
      system: FakeSystemClient(
        server: const ServerVersion(
          version: '999.0.0',
          minClientVersion: '999.0.0',
        ),
      ),
    );
    expect(container.read(updateRequiredProvider), isTrue);
    expect(find.byType(UpdateRequiredScreen), findsOneWidget);
  });

  testWidgets('a supported app is not gated', (tester) async {
    final container = await pumpSignedIn(
      tester,
      FakeWorkspaceClient([ws('w1', 'WS one')]),
    );
    expect(container.read(updateRequiredProvider), isFalse);
    expect(find.byType(UpdateRequiredScreen), findsNothing);
  });
}
