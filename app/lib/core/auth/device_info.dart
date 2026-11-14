import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// What the app tells the server about this device so a session can be named (phase 40).
///
/// Every field except `model` and `os` is optional on the server's side and the whole header
/// may be ignored. The same set of fields is sent every time: the server's fingerprint hashes a
/// missing field as empty, so a client that sent `tz` once and omitted it later would look like
/// a new device.
@immutable
class DeviceFacts {
  const DeviceFacts({
    required this.model,
    required this.os,
    this.osVersion = '',
    this.build = '',
    this.screen = '',
    this.locale = '',
    this.tz = '',
    this.abi = '',
  });

  final String model;
  final String os;
  final String osVersion;
  final String build;
  final String screen;
  final String locale;
  final String tz;
  final String abi;
}

const _maxHeaderLength = 512;

// The server's own patterns, so a value it would drop is never sent.
final _patterns = <String, RegExp>{
  'model': RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9 ._+,/()\-]{0,62}[A-Za-z0-9)])?$'),
  'os': RegExp(r'^[a-z][a-z0-9]{1,15}$'),
  'osVersion': RegExp(r'^[0-9A-Za-z][0-9A-Za-z._\-]{0,23}$'),
  'build': RegExp(r'^[0-9A-Za-z][0-9A-Za-z._\-]{0,31}$'),
  'screen': RegExp(r'^\d{3,5}x\d{3,5}@\d(?:\.\d{1,2})?$'),
  'locale': RegExp(r'^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8}){0,3}$'),
  'tz': RegExp(r'^(?:UTC|[A-Za-z]+(?:/[A-Za-z0-9_+\-]+){1,2})$'),
  'abi': RegExp(r'^[A-Za-z0-9][A-Za-z0-9_\-]{1,23}$'),
};

/// The `X-Device-Info` value for [facts], or `null` when `model` or `os` is unusable (the
/// server would ignore the whole header). An optional key whose value would not pass is left
/// out, the same way every time.
String? buildDeviceInfoHeader(DeviceFacts facts) {
  final values = <String, String>{
    'model': facts.model,
    'os': facts.os,
    'osVersion': facts.osVersion,
    'build': facts.build,
    'screen': facts.screen,
    'locale': facts.locale,
    'tz': facts.tz,
    'abi': facts.abi,
  };
  final parts = <String>[];
  for (final entry in values.entries) {
    if (_patterns[entry.key]!.hasMatch(entry.value)) {
      parts.add('${entry.key}=${entry.value}');
    } else if (entry.key == 'model' || entry.key == 'os') {
      return null;
    }
  }
  final header = parts.join(';');
  return header.length > _maxHeaderLength ? null : header;
}

/// Where the header comes from. Tests substitute a fixed one.
abstract interface class DeviceInfoSource {
  Future<String?> header();
}

/// Reads the platform once and builds the header; every later call returns the same value.
class PlatformDeviceInfoSource implements DeviceInfoSource {
  PlatformDeviceInfoSource({DeviceInfoPlugin? plugin})
    : _plugin = plugin ?? DeviceInfoPlugin();

  /// The one instance the app's auth clients share, so the header is built once.
  static final shared = PlatformDeviceInfoSource();

  final DeviceInfoPlugin _plugin;
  Future<String?>? _header;

  @override
  Future<String?> header() => _header ??= _build();

  Future<String?> _build() async {
    try {
      return buildDeviceInfoHeader(await _facts());
    } on Object {
      return null; // device info must never get in the way of signing in
    }
  }

  Future<DeviceFacts> _facts() async {
    final view = ui.PlatformDispatcher.instance.views.firstOrNull;
    final size = view?.physicalSize ?? ui.Size.zero;
    final screen = size.isEmpty
        ? ''
        : '${size.width.round()}x${size.height.round()}'
              '@${_ratio(view!.devicePixelRatio)}';
    final locale = ui.PlatformDispatcher.instance.locale.toLanguageTag();
    // Dart exposes only the zone's abbreviation ("IRST"). It is sent when it happens to be an
    // IANA name and left out (every time) otherwise; the server's pattern decides.
    final tz = DateTime.now().timeZoneName;
    if (kIsWeb) {
      final web = await _plugin.webBrowserInfo;
      final browser = parseBrowser(web.userAgent ?? '');
      return DeviceFacts(
        model: browser.model,
        os: browser.os,
        osVersion: browser.osVersion,
        screen: screen,
        locale: locale,
        tz: tz,
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await _plugin.androidInfo;
        return DeviceFacts(
          model: info.model,
          os: 'android',
          osVersion: info.version.release,
          build: '${info.version.sdkInt}',
          screen: screen,
          locale: locale,
          tz: tz,
          abi: info.supportedAbis.isEmpty ? '' : info.supportedAbis.first,
        );
      case TargetPlatform.iOS:
        final info = await _plugin.iosInfo;
        return DeviceFacts(
          model: info.utsname.machine,
          os: 'ios',
          osVersion: info.systemVersion,
          screen: screen,
          locale: locale,
          tz: tz,
        );
      case TargetPlatform.macOS:
        final info = await _plugin.macOsInfo;
        return DeviceFacts(
          model: info.model,
          os: 'macos',
          osVersion:
              '${info.majorVersion}.${info.minorVersion}.${info.patchVersion}',
          screen: screen,
          locale: locale,
          tz: tz,
          abi: info.arch,
        );
      case TargetPlatform.windows:
        final info = await _plugin.windowsInfo;
        return DeviceFacts(
          model: info.productName,
          os: 'windows',
          osVersion: '${info.majorVersion}.${info.minorVersion}',
          build: '${info.buildNumber}',
          screen: screen,
          locale: locale,
          tz: tz,
        );
      case TargetPlatform.linux || TargetPlatform.fuchsia:
        final info = await _plugin.linuxInfo;
        return DeviceFacts(
          model: info.prettyName,
          os: 'linux',
          osVersion: info.versionId ?? '',
          screen: screen,
          locale: locale,
          tz: tz,
        );
    }
  }

  static String _ratio(double ratio) => ratio
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// A browser name and version, and the operating system, from a `User-Agent`.
@visibleForTesting
({String model, String os, String osVersion}) parseBrowser(String agent) {
  String? versioned(String token, String name) {
    final match = RegExp('$token/(\\d+)').firstMatch(agent);
    return match == null ? null : '$name ${match.group(1)}';
  }

  final model =
      versioned('Edg', 'Edge') ??
      versioned('OPR', 'Opera') ??
      versioned('Firefox', 'Firefox') ??
      versioned('Chrome', 'Chrome') ??
      versioned('Version', 'Safari') ??
      'Browser';
  String capture(String pattern) =>
      (RegExp(pattern).firstMatch(agent)?.group(1) ?? '').replaceAll('_', '.');
  if (agent.contains('Android')) {
    return (
      model: model,
      os: 'android',
      osVersion: capture(r'Android (\d+(?:\.\d+)*)'),
    );
  }
  if (agent.contains('iPhone') || agent.contains('iPad')) {
    return (model: model, os: 'ios', osVersion: capture(r'OS (\d+(?:_\d+)*)'));
  }
  if (agent.contains('Windows')) {
    return (
      model: model,
      os: 'windows',
      osVersion: capture(r'Windows NT (\d+(?:\.\d+)?)'),
    );
  }
  if (agent.contains('Macintosh')) {
    return (
      model: model,
      os: 'macos',
      osVersion: capture(r'Mac OS X (\d+(?:_\d+)*)'),
    );
  }
  if (agent.contains('Linux')) {
    return (model: model, os: 'linux', osVersion: '');
  }
  return (model: model, os: 'web', osVersion: '');
}
