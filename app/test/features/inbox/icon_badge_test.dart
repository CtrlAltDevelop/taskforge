import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/inbox/application/icon_badge.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';

void main() {
  test('the app icon shows the unread total and follows it', () async {
    final shown = <int>[];
    var total = 3;
    final container = ProviderContainer(
      overrides: [
        badgeSetterProvider.overrideWithValue((c) async => shown.add(c)),
        unreadTotalProvider.overrideWith((_) async => total),
      ],
    );
    addTearDown(container.dispose);

    container.listen(iconBadgeProvider, (_, _) {});
    await container.read(unreadTotalProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(shown, [3]);

    total = 0;
    container.invalidate(unreadTotalProvider);
    await container.read(unreadTotalProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(shown.last, 0);
  });
}
