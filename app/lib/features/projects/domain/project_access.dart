import 'package:taskforge/features/projects/domain/projects.dart';

/// Whether [error] is the server refusing the person this project or page
/// (the cue for the "no access" page rather than a retry).
bool isDenied(Object? error) =>
    error is ProjectException &&
    (error.failure == ProjectFailure.denied ||
        error.failure == ProjectFailure.forbidden);
