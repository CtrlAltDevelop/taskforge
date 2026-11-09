import 'package:taskforge/features/roles/domain/roles.dart';

/// Whether to show the controls that need project permission [perm] (update,
/// archive, member management).
///
/// The backend also lets a project's creator do these as a plain Member, but
/// the project payload carries no way to tell "created by me" (the app has no
/// current-user id). So the controls are shown to anyone holding [perm] or
/// `project.create` (Member and up; never a Viewer) and the server decides; its
/// denial reason is shown when it refuses. Cosmetic only.
bool canManageProject(Permissions permissions, String perm) =>
    permissions.can(perm) || permissions.can(Perm.projectCreate);
