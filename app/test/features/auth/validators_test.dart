import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/features/auth/validators.dart';

void main() {
  group('validateEmail', () {
    test(
      'accepts a normal address',
      () => expect(validateEmail('zoe@example.com'), isNull),
    );
    test('rejects an empty value', () => expect(validateEmail(''), isNotNull));
    test(
      'rejects a value with no @',
      () => expect(validateEmail('zoe.example.com'), isNotNull),
    );
    test(
      'rejects a value with no domain dot',
      () => expect(validateEmail('zoe@example'), isNotNull),
    );
  });

  group('validatePassword', () {
    test(
      'rejects nine characters',
      () => expect(validatePassword('123456789'), contains('10')),
    );
    test(
      'accepts ten characters',
      () => expect(validatePassword('Xq7-mnbvcz'), isNull),
    );
    test('rejects empty', () => expect(validatePassword(null), isNotNull));
  });

  group('validateSignInPassword', () {
    test('only requires something to be typed, so older shorter passwords still work', () {
      expect(validateSignInPassword('short'), isNull);
      expect(validateSignInPassword(''), isNotNull);
    });
  });

  group('authErrorMessage', () {
    test('explains the backend rate limit title', () {
      final text = authErrorMessage(
        const AuthApiException(
          status: 429,
          title: 'RATE_LIMITED',
          message: 'x',
        ),
      );
      expect(text, contains('Too many attempts'));
    });
    test('explains wrong credentials without saying which part was wrong', () {
      final text = authErrorMessage(
        const AuthApiException(
          status: 401,
          title: 'INVALID_CREDENTIALS',
          message: 'x',
        ),
      );
      expect(text, 'Wrong email or password.');
    });
    test('explains rate limiting', () {
      final text = authErrorMessage(
        const AuthApiException(
          status: 429,
          title: 'TOO_MANY_ATTEMPTS',
          message: 'x',
        ),
      );
      expect(text, contains('Too many attempts'));
    });
    test('explains an existing account', () {
      final text = authErrorMessage(
        const AuthApiException(
          status: 409,
          title: 'ACCOUNT_EXISTS',
          message: 'x',
        ),
      );
      expect(text, contains('already exists'));
    });
    test(
      'explains being offline',
      () => expect(
        authErrorMessage(const NetworkUnavailable('x')),
        contains('reach the server'),
      ),
    );
    test('explains a server that answered with something unreadable', () {
      final text = authErrorMessage(
        const AuthApiException(
          status: 500,
          title: 'BAD_RESPONSE',
          message: 'Unexpected server answer.',
        ),
      );
      expect(text, contains('server had a problem'));
    });
    test('passes server validation messages through', () {
      final text = authErrorMessage(
        const AuthApiException(
          status: 400,
          title: 'VALIDATION_ERROR',
          message: 'Too common.',
        ),
      );
      expect(text, 'Too common.');
    });
  });
}
