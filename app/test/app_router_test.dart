import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';

void main() {
  group('safeReturnPath', () {
    test(
      'keeps an in-app path',
      () => expect(safeReturnPath('/sessions'), '/sessions'),
    );
    test(
      'falls back to home when there is none',
      () => expect(safeReturnPath(null), '/'),
    );
    test(
      'refuses an absolute URL',
      () => expect(safeReturnPath('https://evil.example'), '/'),
    );
    test(
      'refuses a protocol-relative URL',
      () => expect(safeReturnPath('//evil.example'), '/'),
    );
    test('refuses a path that would bounce between the auth pages', () {
      expect(safeReturnPath('/sign-in?from=/sign-up'), '/');
      expect(safeReturnPath('/sign-up'), '/');
    });
  });
}
