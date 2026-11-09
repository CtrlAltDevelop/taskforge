import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/features/projects/data/projects_client.dart';
import 'package:taskforge/features/projects/domain/projects.dart';

ProjectFailure _failure(GrpcError e) => mapProjectError(e).failure;

void main() {
  group('mapProjectError', () {
    test('reads the title of ALREADY_EXISTS before it is stripped', () {
      expect(
        _failure(GrpcError.alreadyExists('KEY_TAKEN: key in use')),
        ProjectFailure.keyTaken,
      );
      expect(
        _failure(GrpcError.alreadyExists('KEY_LOCKED: has tasks')),
        ProjectFailure.keyLocked,
      );
      expect(
        _failure(GrpcError.alreadyExists('PROJECT_ARCHIVED: archived')),
        ProjectFailure.archived,
      );
      expect(
        _failure(GrpcError.alreadyExists('LAST_MEMBER: last one')),
        ProjectFailure.lastMember,
      );
    });

    test('maps version conflicts, not found and transport failures', () {
      expect(
        _failure(GrpcError.aborted('VERSION_CONFLICT: stale')),
        ProjectFailure.conflict,
      );
      expect(_failure(GrpcError.notFound('x')), ProjectFailure.notFound);
      expect(_failure(GrpcError.unavailable()), ProjectFailure.network);
      expect(_failure(GrpcError.internal()), ProjectFailure.other);
    });

    test('keeps the server text of invalid arguments without the title', () {
      final e = mapProjectError(
        GrpcError.invalidArgument('INVALID_ARGUMENT: Name is too long'),
      );

      expect(e.failure, ProjectFailure.invalid);
      expect(e.detail, 'Name is too long');
    });

    test('names the missing permission of a denial', () {
      final e = mapProjectError(
        GrpcError.permissionDenied(
          'PERMISSION_DENIED_REASON: missing: project.update; your role: Viewer',
        ),
      );

      expect(e.failure, ProjectFailure.denied);
      expect(e.detail, contains('project.update'));
      expect(
        _failure(GrpcError.permissionDenied('FORBIDDEN: not a member')),
        ProjectFailure.forbidden,
      );
    });
  });
}
