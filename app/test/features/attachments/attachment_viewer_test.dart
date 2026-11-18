import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tasks/detail_tabs.dart';

import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachments_io.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fake_video.dart';
import 'fakes.dart';

Future<void> open(WidgetTester tester, FakeAttachments files) async {
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Fix login')]),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    attachments: files,
    size: const Size(1400, 2000),
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Fix login'));
  await tester.pumpAndSettle();
  await openTab(tester, 'Attachments');
}

FakeAttachments withVideo() =>
    FakeAttachments(initial: [attachment('v1', 'clip.mp4', mime: 'video/mp4')]);

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

/// Lets the player's own async clean-up (it awaits streams on the real
/// clock) finish.
Future<void> letPlayerFinish(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  late FakeVideoPlatform platform;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // The deep-link plugin listens once real time passes (see
    // letPlayerFinish); there is no platform here to answer it.
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
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  testWidgets('a video plays, and the icon follows what the player does', (
    tester,
  ) async {
    await open(tester, withVideo());

    await tapKey(tester, 'open-v1');
    expect(platform.created, ['https://files.test/v1']);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tapKey(tester, 'video-toggle');
    expect(platform.playing[1], isTrue);
    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tapKey(tester, 'video-toggle');
    expect(platform.playing[1], isFalse);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tapKey(tester, 'viewer-close');
  });

  testWidgets('closing the viewer lets the player go', (tester) async {
    await open(tester, withVideo());
    await tapKey(tester, 'open-v1');

    await tapKey(tester, 'viewer-close');
    await letPlayerFinish(tester);

    expect(platform.disposed, [1]);
  });

  testWidgets('closing before the link arrives makes no player at all', (
    tester,
  ) async {
    final files = withVideo()..linkGate = Completer<void>();
    await open(tester, files);

    await tester.tap(find.byKey(const Key('open-v1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('viewer-close')));
    await tester.pumpAndSettle();
    files.linkGate!.complete();
    await tester.pumpAndSettle();

    expect(platform.created, isEmpty);
  });

  testWidgets('closing while the player is being made disposes it', (
    tester,
  ) async {
    platform.createGate = Completer<void>();
    await open(tester, withVideo());

    await tester.tap(find.byKey(const Key('open-v1')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('viewer-close')));
    await tester.pumpAndSettle();
    platform.createGate!.complete();
    await letPlayerFinish(tester);

    expect(platform.created, hasLength(1));
    expect(platform.live, 0);
  });

  testWidgets(
    'a playback error renews the link and carries on from the same place',
    (tester) async {
      final files = withVideo();
      await open(tester, files);
      await tapKey(tester, 'open-v1');
      platform.position = const Duration(seconds: 12);
      await tester.tap(find.byKey(const Key('video-toggle')));
      // The player reads its position every half second while it plays.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      platform.fail(1);
      await letPlayerFinish(tester);

      expect(platform.created, hasLength(2));
      expect(files.links.where((l) => l == 'v1'), hasLength(2)); // a fresh link
      expect(platform.disposed, [1]);
      expect(platform.seeks[2], const Duration(seconds: 12));
      expect(platform.playing[2], isTrue);
      expect(find.byKey(const Key('viewer-error')), findsNothing);
      await tapKey(tester, 'viewer-close');
    },
  );

  testWidgets('a second error gives up with a message', (tester) async {
    await open(tester, withVideo());
    await tapKey(tester, 'open-v1');

    platform.fail(1);
    await letPlayerFinish(tester);
    platform.fail(2);
    await letPlayerFinish(tester);

    expect(find.byKey(const Key('viewer-error')), findsOneWidget);
    expect(find.text('Could not play the video.'), findsOneWidget);
  });

  testWidgets('a video whose link cannot be had says so', (tester) async {
    final files = withVideo();
    await open(tester, files);
    files.failLink = const AttachmentException(AttachmentFailure.network);

    await tapKey(tester, 'open-v1');

    expect(find.byKey(const Key('viewer-error')), findsOneWidget);
    expect(platform.created, isEmpty);
  });

  testWidgets('a long text file says it was cut', (tester) async {
    final files =
        FakeAttachments(
            initial: [attachment('t1', 'big.log', mime: 'text/plain')],
          )
          ..textBody = 'first part'
          ..textTruncated = true;
    await open(tester, files);

    await tapKey(tester, 'open-t1');

    expect(find.byKey(const Key('viewer-text')), findsOneWidget);
    expect(find.byKey(const Key('viewer-truncated')), findsOneWidget);
    expect(find.textContaining('200 KB'), findsOneWidget);
  });

  testWidgets('a whole text file carries no such note', (tester) async {
    await open(
      tester,
      FakeAttachments(
        initial: [attachment('t1', 'small.log', mime: 'text/plain')],
      ),
    );

    await tapKey(tester, 'open-t1');

    expect(find.byKey(const Key('viewer-truncated')), findsNothing);
  });

  testWidgets(
    'a system that refuses the link is told apart from a missing app',
    (tester) async {
      final files = FakeAttachments(
        initial: [attachment('z1', 'data.zip', mime: 'application/zip')],
      );
      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        tasks: FakeTasksClient([task('a', 'Fix login')]),
        workflows: FakeWorkflowsClient(defaultWorkflow()),
        attachments: files,
        size: const Size(1400, 2000),
        overrides: [
          urlOpenerProvider.overrideWithValue(
            (uri) async => throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
          ),
        ],
      );
      await pumped.go(tester, '/projects/p1');
      await tester.tap(find.text('Fix login'));
      await tester.pumpAndSettle();
      await openTab(tester, 'Attachments');
      await tapKey(tester, 'open-z1');

      await tapKey(tester, 'viewer-download');

      expect(find.text('Could not open the file.'), findsOneWidget);
    },
  );

  testWidgets('a link that cannot be fetched is explained', (tester) async {
    final files = FakeAttachments(
      initial: [attachment('z1', 'data.zip', mime: 'application/zip')],
    );
    await open(tester, files);
    await tapKey(tester, 'open-z1');
    files.failLink = const AttachmentException(AttachmentFailure.forbidden);

    await tapKey(tester, 'viewer-download');

    expect(find.text('You are not allowed to do that.'), findsOneWidget);
  });
}
