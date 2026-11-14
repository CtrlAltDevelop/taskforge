import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/system/domain/update_feed.dart';

void main() {
  test('reads a GitHub release', () {
    final r = ReleaseInfo.fromJson(
      '{"tag_name":"v1.4.0","html_url":"https://github.com/o/r/releases/tag/v1.4.0"}',
    );
    expect(r?.version, '1.4.0');
    expect(r?.downloadUrl, startsWith('https://github.com/'));
    expect(r!.isNewerThan('1.3.9'), isTrue);
    expect(r.isNewerThan('1.4.0'), isFalse);
  });

  test('ignores a body that is not a release', () {
    expect(ReleaseInfo.fromJson('nope'), isNull);
    expect(ReleaseInfo.fromJson('[]'), isNull);
    expect(ReleaseInfo.fromJson('{"tag_name":"nightly"}'), isNull);
  });

  test('drops a download link that is not https', () {
    final r = ReleaseInfo.fromJson(
      '{"tag_name":"2.0.0","html_url":"javascript:alert(1)"}',
    );
    expect(r?.downloadUrl, '');
  });
}
