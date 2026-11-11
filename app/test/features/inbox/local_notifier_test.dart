import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/inbox/data/local_notifier.dart';

const _channel = MethodChannel('dexterous.com/flutter/local_notifications');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];

  setUp(calls.clear);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test(
    'on a platform without the plugin nothing is shown and nothing throws',
    () async {
      final notifier = SystemLocalNotifier();

      await notifier.show(id: 1, title: 't', body: 'b', payload: 'p1|a');
      expect(await notifier.requestPermission(), isFalse);
    },
  );

  test(
    'with the plugin it is initialised once and shows the notification',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith(); // what a device does at start
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            calls.add(call.method);
            return true;
          });
      final notifier = SystemLocalNotifier();

      await notifier.show(id: 7, title: 'Mentions', body: 'Hank mentioned you');
      await notifier.show(id: 8, title: 'Mentions', body: 'again');

      expect(calls.where((c) => c == 'initialize'), hasLength(1));
      expect(calls.where((c) => c == 'show'), hasLength(2));
    },
  );

  test('permission is asked of the platform', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith(); // what a device does at start
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call.method);
          return true;
        });

    final granted = await SystemLocalNotifier().requestPermission();

    expect(granted, isTrue);
    expect(calls, contains('requestNotificationsPermission'));
  });

  test('a refusal at the platform is a no', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith(); // what a device does at start
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          return call.method == 'requestNotificationsPermission' ? false : true;
        });

    expect(await SystemLocalNotifier().requestPermission(), isFalse);
  });
}
