import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows a notification of the operating system (and asks leave to). The
/// default talks to the platform; tests bring a fake.
abstract class LocalNotifier {
  /// Called with the `payload` of a notification the person tapped.
  void Function(String payload)? onOpen;

  /// Asks the system for leave to show notifications; true when granted
  /// (or when the platform needs no leave).
  Future<bool> requestPermission();

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String payload = '',
  });
}

/// The platform's notifications through `flutter_local_notifications`. Every
/// call is guarded: a platform without them (the web, a missing plugin) just
/// shows nothing, and a failure never reaches a screen.
class SystemLocalNotifier extends LocalNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
    ),
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) onOpen?.call(payload);
    },
  );

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      await _init();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final mac = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      if (mac != null) {
        return await mac.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      return true; // desktop: no leave to ask for
    } on Object {
      return false;
    }
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String payload = '',
  }) async {
    if (kIsWeb) return;
    try {
      await _init();
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'taskforge-inbox',
            'Notifications',
            channelDescription: 'Assignments, mentions and other activity',
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
          linux: LinuxNotificationDetails(),
        ),
      );
    } on Object {
      // No notifications on this platform: nothing to show.
    }
  }
}
