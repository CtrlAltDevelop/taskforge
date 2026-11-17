import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../i18n/tolerant_golden.dart';
import 'chat_ui_test.dart' show open, server;
import 'fakes.dart';

/// The chat area as a picture: the wide two-pane layout with the unread
/// badges and a conversation, and the phone layout with the list alone.
/// Flutter tests draw text in a fixed test font, so the images do not depend
/// on the machine's fonts.
void main() {
  setUpAll(useTolerantGoldens);

  setUp(() {
    // Capturing an image lets real time pass, and the deep-link plugin then
    // listens; there is no platform here to answer it.
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
  });

  testWidgets('wide: space list beside a conversation', (tester) async {
    final chat = server(
      messages: [
        msg('m1', 'rnd', 'Morning all', at: t0),
        msg('m2', 'rnd', 'Standup in five', author: 'u1', at: t0),
      ],
    );
    await open(tester, chat, location: '/chat/rnd');

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/chat_wide.png'),
    );
  });

  testWidgets('phone: the list on its own', (tester) async {
    await open(tester, server(), size: const Size(420, 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/chat_phone_list.png'),
    );
  });
}
