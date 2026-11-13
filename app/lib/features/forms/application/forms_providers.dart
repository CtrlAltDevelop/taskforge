import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/forms/data/forms_client.dart';
import 'package:taskforge/features/forms/data/public_forms_client.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final formsClientProvider = Provider<FormsClient>(
  (ref) => GrpcFormsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// Every form of the workspace (the caller must be allowed to manage them).
final formsProvider = FutureProvider.autoDispose<List<IntakeForm>>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(formsClientProvider).list(ws);
}, retry: (_, _) => null);

/// The first page of a form's sends.
final submissionsProvider = FutureProvider.autoDispose
    .family<SubmissionPage, String>((ref, formId) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const SubmissionPage([], '');
      return ref.watch(formsClientProvider).submissions(ws, formId);
    }, retry: (_, _) => null);

/// The anonymous client: no session, no workspace, no authorization header.
final publicFormsClientProvider = Provider<PublicFormsClient>(
  (ref) => HttpPublicFormsClient(restUrl: AppConfig.restUrl),
);

/// A public form by its token.
final publicFormProvider = FutureProvider.autoDispose
    .family<PublicForm, String>(
      (ref, token) => ref.watch(publicFormsClientProvider).fetch(token),
      retry: (_, _) => null,
    );
