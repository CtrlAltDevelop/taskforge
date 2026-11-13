import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/gen/infrastructure/forms/grpc/forms.pbgrpc.dart'
    as pb;

/// The signed-in side of forms: build, list, change, delete, read sends.
abstract interface class FormsClient {
  Future<List<IntakeForm>> list(String workspaceId, {String projectId = ''});
  Future<IntakeForm> create(
    String workspaceId,
    String projectId,
    FormDraft draft,
  );
  Future<IntakeForm> update(
    String workspaceId,
    IntakeForm form,
    FormDraft draft,
  );
  Future<IntakeForm> setEnabled(
    String workspaceId,
    IntakeForm form, {
    required bool enabled,
  });
  Future<IntakeForm> rotateToken(String workspaceId, IntakeForm form);
  Future<void> delete(String workspaceId, String formId);
  Future<SubmissionPage> submissions(
    String workspaceId,
    String formId, {
    String before = '',
  });
}

FormsException mapFormsError(Object error) {
  if (error is FormsException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => FormsException(
        FormsFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists ||
      StatusCode.aborted => const FormsException(FormsFailure.conflict),
      StatusCode.permissionDenied => const FormsException(FormsFailure.denied),
      StatusCode.notFound => const FormsException(FormsFailure.notFound),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const FormsException(FormsFailure.network),
      _ => const FormsException(FormsFailure.other),
    };
  }
  return const FormsException(FormsFailure.other);
}

Question questionFromPb(pb.IntakeField f) => Question(
  id: f.id,
  kind: QuestionKind.parse(f.kind),
  label: f.label,
  help: f.help,
  required: f.required,
  customFieldId: f.customFieldId,
  maxFiles: f.maxFiles,
);

pb.IntakeField questionToPb(Question q) => pb.IntakeField(
  id: q.id,
  kind: q.kind.wire,
  label: q.label,
  help: q.help,
  required: q.required,
  customFieldId: q.customFieldId,
  maxFiles: q.maxFiles,
);

IntakeForm formFromPb(pb.IntakeForm f) => IntakeForm(
  id: f.id,
  projectId: f.projectId,
  name: f.name,
  description: f.description,
  token: f.token,
  questions: List.unmodifiable(f.formFields.map(questionFromPb)),
  statusId: f.statusId,
  priority: f.priority,
  assigneeIds: List.unmodifiable(f.assigneeIds),
  enabled: f.enabled,
  requireEmail: f.requireEmail,
  sendConfirmation: f.sendConfirmation,
  notifyStatus: f.notifyStatus,
  brandColor: f.brandColor,
  logoUrl: f.logoUrl,
  version: f.version,
  submissionCount: f.submissionCount,
  problem: f.problem,
);

class GrpcFormsClient implements FormsClient {
  GrpcFormsClient(ClientChannelBase channel, this._session)
    : _stub = pb.FormControllerClient(channel);

  final pb.FormControllerClient _stub;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapFormsError(e);
    }
  }

  @override
  Future<List<IntakeForm>> list(String workspaceId, {String projectId = ''}) =>
      _run(() async {
        final r = await _stub.list(
          pb.FormListRequest(workspaceId: workspaceId, projectId: projectId),
          options: _options,
        );
        return List.unmodifiable(r.forms.map(formFromPb));
      });

  @override
  Future<IntakeForm> create(
    String workspaceId,
    String projectId,
    FormDraft draft,
  ) => _run(() async {
    final r = await _stub.create(
      pb.FormCreateRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        name: draft.name.trim(),
        description: draft.description.trim(),
        formFields: draft.questions.map(questionToPb),
        statusId: draft.statusId,
        priority: draft.priority,
        assigneeIds: draft.assigneeIds,
        enabled: draft.enabled,
        requireEmail: draft.requireEmail,
        sendConfirmation: draft.sendConfirmation,
        notifyStatus: draft.notifyStatus,
        brandColor: draft.brandColor.trim(),
        logoUrl: draft.logoUrl.trim(),
      ),
      options: _options,
    );
    return formFromPb(r.form);
  });

  @override
  Future<IntakeForm> update(
    String workspaceId,
    IntakeForm form,
    FormDraft draft,
  ) => _run(() async {
    final r = await _stub.update(
      pb.FormUpdateRequest(
        workspaceId: workspaceId,
        formId: form.id,
        expectedVersion: form.version,
        changed: const [
          'name',
          'description',
          'fields',
          'defaults',
          'enabled',
          'require_email',
          'send_confirmation',
          'notify_status',
          'brand_color',
          'logo_url',
        ],
        name: draft.name.trim(),
        description: draft.description.trim(),
        formFields: draft.questions.map(questionToPb),
        statusId: draft.statusId,
        priority: draft.priority,
        assigneeIds: draft.assigneeIds,
        enabled: draft.enabled,
        requireEmail: draft.requireEmail,
        sendConfirmation: draft.sendConfirmation,
        notifyStatus: draft.notifyStatus,
        brandColor: draft.brandColor.trim(),
        logoUrl: draft.logoUrl.trim(),
      ),
      options: _options,
    );
    return formFromPb(r.form);
  });

  @override
  Future<IntakeForm> setEnabled(
    String workspaceId,
    IntakeForm form, {
    required bool enabled,
  }) => _run(() async {
    final r = await _stub.update(
      pb.FormUpdateRequest(
        workspaceId: workspaceId,
        formId: form.id,
        expectedVersion: form.version,
        changed: const ['enabled'],
        enabled: enabled,
      ),
      options: _options,
    );
    return formFromPb(r.form);
  });

  @override
  Future<IntakeForm> rotateToken(String workspaceId, IntakeForm form) =>
      _run(() async {
        final r = await _stub.update(
          pb.FormUpdateRequest(
            workspaceId: workspaceId,
            formId: form.id,
            expectedVersion: form.version,
            changed: const ['rotate_token'],
            rotateToken: true,
          ),
          options: _options,
        );
        return formFromPb(r.form);
      });

  @override
  Future<void> delete(String workspaceId, String formId) => _run(() async {
    await _stub.delete(
      pb.FormDeleteRequest(workspaceId: workspaceId, formId: formId),
      options: _options,
    );
  });

  @override
  Future<SubmissionPage> submissions(
    String workspaceId,
    String formId, {
    String before = '',
  }) => _run(() async {
    final r = await _stub.submissions(
      pb.SubmissionsRequest(
        workspaceId: workspaceId,
        formId: formId,
        before: before,
        limit: 30,
      ),
      options: _options,
    );
    return SubmissionPage(
      List.unmodifiable(
        r.submissions.map(
          (s) => Submission(
            id: s.id,
            reference: s.reference,
            projectId: s.projectId,
            taskKey: s.taskKey,
            taskTitle: s.taskTitle,
            statusName: s.statusName,
            email: s.submitterEmail,
            at: s.at,
          ),
        ),
      ),
      r.cursor,
    );
  });
}
