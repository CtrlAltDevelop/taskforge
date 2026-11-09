import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/features/members/data/members_client.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/roles/data/roles_client.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/data/workspace_client.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

String _b64(String s) => base64.encode(utf8.encode(s));

GrpcError _denied({Map<String, String>? trailers, String? message}) =>
    GrpcError.custom(
      StatusCode.permissionDenied,
      message ??
          'PERMISSION_DENIED_REASON: missing: task.edit; your role: Viewer',
      null,
      null,
      trailers ?? const {},
    );

void main() {
  group('parsePermissionDenied', () {
    test('reads base64 trailers first', () {
      final denied = parsePermissionDenied(
        _denied(
          message: 'PERMISSION_DENIED_REASON: ignored',
          trailers: {
            'x-error-permission-bin': _b64('member.invite'),
            'x-error-role-bin': _b64('Viewer'),
            'x-error-hint-bin': _b64('ask an admin'),
          },
        ),
      )!;

      expect(denied.permission, 'member.invite');
      expect(denied.role, 'Viewer');
      expect(denied.hint, 'ask an admin');
      expect(
        denied.message,
        'You need permission "member.invite" — your role is Viewer',
      );
    });

    test('accepts trailers that were already decoded', () {
      final denied = parsePermissionDenied(
        _denied(
          trailers: {
            'x-error-permission-bin': 'member.invite',
            'x-error-role-bin': 'Viewer',
          },
        ),
      )!;

      expect(denied.permission, 'member.invite');
      expect(denied.role, 'Viewer');
    });

    test('falls back to the message', () {
      final denied = parsePermissionDenied(_denied())!;

      expect(denied.permission, 'task.edit');
      expect(denied.role, 'Viewer');
    });

    test('keeps several missing keys together', () {
      final denied = parsePermissionDenied(
        _denied(
          message:
              'PERMISSION_DENIED_REASON: missing: a.x, b.y; your role: Member',
        ),
      )!;

      expect(denied.permission, 'a.x, b.y');
    });

    test('is null for a non-member refusal and other codes', () {
      expect(
        parsePermissionDenied(_denied(message: 'FORBIDDEN: nope')),
        isNull,
      );
      expect(
        parsePermissionDenied(
          const GrpcError.custom(StatusCode.notFound, 'NOT_FOUND: x'),
        ),
        isNull,
      );
    });
  });

  group('error mapping', () {
    test('every client shows the hint on a denial', () {
      const hint = 'You need permission "task.edit" — your role is Viewer';
      final error = _denied();

      final workspace = mapWorkspaceError(error);
      expect(workspace.failure, WorkspaceFailure.denied);
      expect(workspaceErrorMessage(workspace), hint);

      final invite = mapInviteError(error);
      expect(invite.failure, InviteFailure.denied);
      expect(inviteErrorMessage(invite), hint);

      final role = mapRoleError(error);
      expect(role.failure, RoleFailure.denied);
      expect(roleErrorMessage(role), hint);
    });

    test('a plain FORBIDDEN stays a generic refusal', () {
      final error = _denied(message: 'FORBIDDEN: no');

      expect(mapWorkspaceError(error).failure, WorkspaceFailure.forbidden);
      expect(mapInviteError(error).failure, InviteFailure.forbidden);
      expect(mapRoleError(error).failure, RoleFailure.forbidden);
    });

    test('role titles map to their own failures', () {
      RoleFailure failure(int code, String message) =>
          mapRoleError(GrpcError.custom(code, message)).failure;

      expect(
        failure(StatusCode.permissionDenied, 'ROLE_BUILTIN: x'),
        RoleFailure.builtin,
      );
      expect(
        failure(StatusCode.permissionDenied, 'OWNER_PROTECTED: x'),
        RoleFailure.ownerProtected,
      );
      expect(
        failure(StatusCode.alreadyExists, 'ROLE_NAME_TAKEN: x'),
        RoleFailure.nameTaken,
      );
      expect(
        mapRoleError(
          const GrpcError.custom(
            StatusCode.invalidArgument,
            'INVALID_ARGUMENT: Choose a role to move members to.',
          ),
        ).detail,
        'Choose a role to move members to.',
      );
      expect(
        failure(StatusCode.notFound, 'NOT_FOUND: x'),
        RoleFailure.notFound,
      );
    });
  });
}
