import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;

/// Why the server refused an action to a member who lacks a permission.
@immutable
class PermissionDenied {
  const PermissionDenied({
    required this.permission,
    required this.role,
    this.hint = '',
  });

  final String permission;
  final String role;
  final String hint;

  /// What to tell the user.
  String get message => denialMessage(permission, role, hint);
}

/// 'You need permission "x" - your role is Viewer'; also used by disabled gates.
String denialMessage(String permission, String role, [String hint = '']) {
  if (permission.isEmpty) {
    return hint.isEmpty ? 'You do not have permission to do that.' : hint;
  }
  final base = 'You need permission "$permission"';
  return role.isEmpty ? base : '$base — your role is $role';
}

final _reason = RegExp(
  r'PERMISSION_DENIED_REASON: missing: (.+?); your role: (.+)$',
);

/// Binary trailers may arrive base64-encoded (as on the wire) or already
/// decoded; anything that is not valid base64 of UTF-8 is taken as it is.
String _trailer(Map<String, String>? trailers, String key) {
  final raw = trailers?[key];
  if (raw == null) return '';
  try {
    return utf8.decode(base64.decode(base64.normalize(raw)));
  } on FormatException {
    return raw;
  }
}

/// The parsed denial of a gRPC error, or null when it is not a permission
/// denial (a non-member gets a plain `FORBIDDEN` with no reason). Trailers are
/// read first; the message is the fallback.
PermissionDenied? parsePermissionDenied(GrpcError error) {
  if (error.code != StatusCode.permissionDenied) return null;
  var permission = _trailer(error.trailers, 'x-error-permission-bin');
  var role = _trailer(error.trailers, 'x-error-role-bin');
  final hint = _trailer(error.trailers, 'x-error-hint-bin');
  if (permission.isEmpty) {
    final match = _reason.firstMatch(error.message ?? '');
    if (match == null) return null;
    permission = match.group(1)!;
    role = match.group(2)!;
  }
  return PermissionDenied(permission: permission, role: role, hint: hint);
}

/// The text of binary error trailer [key] (`x-error-<name>-bin`), or ''.
String errorTrailer(GrpcError error, String key) =>
    _trailer(error.trailers, key);
