import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_session.dart';

/// The one [AuthSession]. `main` overrides it with the restored, real one.
final authSessionProvider = Provider<AuthSession>(
  (ref) => throw UnimplementedError('override authSessionProvider'),
);
