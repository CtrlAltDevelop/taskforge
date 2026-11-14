import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The phrase for an audit action of the developer, forms, goals, templates,
/// workload and security areas; null for an action this file does not know.
/// [after] reads a changed field (a plain value or the new half of a pair) and
/// [shown] makes a value readable; both come from the caller.
String? describeWorkspaceAction(
  String action,
  Object? Function(String field) after,
  String Function(Object? value) shown,
  AppLocalizations l,
) {
  String text(String field) => shown(after(field));
  return switch (action) {
    'token.created' => l.audTokenCreated,
    'token.revoked' => l.audTokenRevoked,
    'webhook.created' => l.audWebhookCreated,
    'webhook.updated' => l.audWebhookUpdated,
    'webhook.deleted' => l.audWebhookDeleted,
    'webhook.disabled' => l.audWebhookDisabled,
    'form.created' => l.audFormCreated,
    'form.updated' => l.audFormUpdated,
    'form.deleted' => l.audFormDeleted,
    'form.submitted' => l.audFormSubmitted,
    'goal.created' => l.audGoalCreated,
    'goal.updated' => l.audGoalUpdated,
    'goal.deleted' => l.audGoalDeleted,
    'goal.folder_created' => l.audGoalFolderCreated(text('name')),
    'goal.folder_renamed' => l.audGoalFolderRenamed(text('from'), text('name')),
    'goal.folder_deleted' => l.audGoalFolderDeleted(text('name')),
    'goal.kr_created' => l.audGoalKrCreated(text('key_result')),
    'goal.kr_updated' => l.audGoalKrUpdated(text('key_result')),
    'goal.kr_deleted' => l.audGoalKrDeleted(text('key_result')),
    'goal.checked_in' => l.audGoalCheckedIn(text('value'), text('key_result')),
    'template.created' => l.audTemplateCreated,
    'template.updated' => l.audTemplateUpdated,
    'template.deleted' => l.audTemplateDeleted,
    'template.applied' => l.audTemplateApplied,
    'workload.capacity.set' => l.audWorkloadCapacity,
    'workload.time_off.create' => l.audWorkloadTimeOffCreated,
    'workload.time_off.update' => l.audWorkloadTimeOffUpdated,
    'workload.time_off.delete' => l.audWorkloadTimeOffDeleted,
    'workload.holiday.create' => l.audWorkloadHolidayCreated,
    'workload.holiday.update' => l.audWorkloadHolidayUpdated,
    'workload.holiday.delete' => l.audWorkloadHolidayDeleted,
    'workload.estimate.set' => l.audWorkloadEstimateSet,
    'security.sso_configured' => l.audSecuritySsoConfigured,
    'security.sso_removed' => l.audSecuritySsoRemoved,
    'security.sso_member_joined' => l.audSecuritySsoMemberJoined,
    'security.sso_role_changed' => l.audSecuritySsoRoleChanged,
    'security.policy_changed' => l.audSecurityPolicyChanged,
    _ => null,
  };
}
