import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/device_info.dart';

void main() {
  const full = DeviceFacts(
    model: 'Pixel 8',
    os: 'android',
    osVersion: '14',
    build: '34',
    screen: '1080x2400@2.75',
    locale: 'en-US',
    tz: 'Asia/Tehran',
    abi: 'arm64-v8a',
  );

  test('field set and order are stable', () {
    expect(
      buildDeviceInfoHeader(full),
      'model=Pixel 8;os=android;osVersion=14;build=34;screen=1080x2400@2.75;'
      'locale=en-US;tz=Asia/Tehran;abi=arm64-v8a',
    );
  });

  test('invalid optional fields are dropped, the rest is kept', () {
    const facts = DeviceFacts(
      model: 'Mac',
      os: 'macos',
      tz: 'IRST',
      locale: 'fa-IR',
    );
    expect(buildDeviceInfoHeader(facts), 'model=Mac;os=macos;locale=fa-IR');
  });

  test('unusable model or os yields no header', () {
    expect(
      buildDeviceInfoHeader(const DeviceFacts(model: '', os: 'ios')),
      isNull,
    );
    expect(
      buildDeviceInfoHeader(const DeviceFacts(model: 'X1', os: 'iOS')),
      isNull,
    );
  });

  test('a model over its 64-character pattern is refused', () {
    final facts = DeviceFacts(model: 'M' * 70, os: 'linux');
    expect(buildDeviceInfoHeader(facts), isNull);
  });

  test('the full header stays within 512 characters', () {
    expect(buildDeviceInfoHeader(full)!.length, lessThanOrEqualTo(512));
  });

  group('parseBrowser', () {
    test('Chrome on Windows', () {
      final b = parseBrowser(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
      );
      expect(b.model, 'Chrome 126');
      expect(b.os, 'windows');
      expect(b.osVersion, '10.0');
    });

    test('Safari on iPhone converts underscores', () {
      final b = parseBrowser(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
        'AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1',
      );
      expect(b.model, 'Safari 17');
      expect(b.os, 'ios');
      expect(b.osVersion, '17.5');
    });

    test('unknown agent falls back', () {
      final b = parseBrowser('curl');
      expect((b.model, b.os), ('Browser', 'web'));
    });
  });
}
