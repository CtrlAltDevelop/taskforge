import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

void main() {
  group('validateSlug', () {
    for (final ok in ['abc', 'my-team', 'a1-b2', 'a' * 40]) {
      test('accepts "$ok"', () => expect(validateSlug(ok), isNull));
    }
    for (final bad in [
      'ab',
      'a' * 41,
      '-abc',
      'abc-',
      'ABC',
      'my team',
      'a_b',
      '',
    ]) {
      test('rejects "$bad"', () => expect(validateSlug(bad), isNotNull));
    }
  });

  group('slugify', () {
    test(
      'lowercases and dashes',
      () => expect(slugify('Acme Corp!'), 'acme-corp'),
    );
    test('trims dashes', () => expect(slugify('  --Hi--  '), 'hi'));
    test('caps at 40 without a trailing dash', () {
      final slug = slugify('${'a' * 39} bbb');
      expect(slug.length, lessThanOrEqualTo(40));
      expect(slug.endsWith('-'), isFalse);
    });
  });

  test('validateWorkspaceName needs 1-80 characters', () {
    expect(validateWorkspaceName('  '), isNotNull);
    expect(validateWorkspaceName('a' * 81), isNotNull);
    expect(validateWorkspaceName('Acme'), isNull);
  });

  group('workspaceErrorMessage', () {
    String msg(WorkspaceFailure f) =>
        workspaceErrorMessage(WorkspaceException(f));
    test(
      'slug taken',
      () => expect(msg(WorkspaceFailure.slugTaken), 'That URL is taken'),
    );
    test(
      'permission denied',
      () => expect(msg(WorkspaceFailure.forbidden), contains('permission')),
    );
    test(
      'stale asks to refresh',
      () => expect(msg(WorkspaceFailure.stale), contains('Refresh')),
    );
    test('strips the server title prefix', () {
      expect(
        stripErrorTitle('UPLOAD_INVALID: The logo is too big.'),
        'The logo is too big.',
      );
      expect(stripErrorTitle('Plain message'), 'Plain message');
      expect(stripErrorTitle(null), isNull);
    });
  });
}
