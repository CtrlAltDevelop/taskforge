import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

void main() {
  testWidgets('a native link event opens the invitation page', (tester) async {
    final links = StreamController<Uri>();
    addTearDown(links.close);
    await pumpSignedIn(
      tester,
      FakeWorkspaceClient([ws('w1', 'Acme')]),
      overrides: [
        membersClientProvider.overrideWithValue(FakeMembersClient()),
        deepLinkStreamProvider.overrideWithValue(links.stream),
      ],
    );
    expect(byKey('join-workspace'), findsNothing);

    links.add(Uri.parse('taskforge://invite/abc123'));
    await tester.pumpAndSettle();

    expect(byKey('join-workspace'), findsOneWidget);
  });
}
