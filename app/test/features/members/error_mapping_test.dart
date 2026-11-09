import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/members/data/members_client.dart';
import 'package:taskforge/features/members/domain/members.dart';

InviteFailure failureOf(int code, String message) =>
    mapInviteError(GrpcError.custom(code, message)).failure;

void main() {
  group('mapInviteError', () {
    test('reads the title that tells the not-found cases apart', () {
      expect(
        failureOf(StatusCode.notFound, 'INVITE_EXPIRED: gone'),
        InviteFailure.expired,
      );
      expect(
        failureOf(StatusCode.notFound, 'INVITE_REVOKED: gone'),
        InviteFailure.revoked,
      );
      expect(
        failureOf(StatusCode.notFound, 'INVITE_USED_UP: gone'),
        InviteFailure.usedUp,
      );
      expect(
        failureOf(StatusCode.notFound, 'INVITE_BEFORE_REMOVAL: gone'),
        InviteFailure.beforeRemoval,
      );
      expect(
        failureOf(StatusCode.notFound, 'NOT_FOUND: no'),
        InviteFailure.notFound,
      );
    });

    test('tells permission failures apart', () {
      expect(
        failureOf(StatusCode.permissionDenied, 'OWNER_PROTECTED: x'),
        InviteFailure.ownerProtected,
      );
      expect(
        failureOf(StatusCode.permissionDenied, 'INVITE_EMAIL_MISMATCH: x'),
        InviteFailure.emailMismatch,
      );
      expect(
        failureOf(StatusCode.permissionDenied, 'FORBIDDEN: x'),
        InviteFailure.forbidden,
      );
    });

    test('maps the remaining codes', () {
      expect(
        failureOf(StatusCode.resourceExhausted, 'x'),
        InviteFailure.rateLimited,
      );
      expect(failureOf(StatusCode.alreadyExists, 'x'), InviteFailure.exists);
      expect(failureOf(StatusCode.unavailable, 'x'), InviteFailure.network);
      final invalid = mapInviteError(
        GrpcError.custom(StatusCode.invalidArgument, 'BAD: Too many emails'),
      );
      expect(invalid.detail, 'Too many emails');
    });
  });

  test('each failure has its own clear message', () {
    expect(
      inviteErrorMessage(const InviteException(InviteFailure.emailMismatch)),
      'This invitation is for another email address.',
    );
    final all = {
      for (final f in InviteFailure.values)
        inviteErrorMessage(InviteException(f)),
    };
    expect(all.length, greaterThan(8));
  });

  test('customSchemeRoute maps taskforge://invite/<token>', () {
    expect(
      customSchemeRoute(Uri.parse('taskforge://invite/abc')),
      '/invite/abc',
    );
    expect(customSchemeRoute(Uri.parse('https://x.test/invite/abc')), isNull);
    expect(customSchemeRoute(Uri.parse('taskforge://other/abc')), isNull);
  });
}
