import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_files.dart';
import 'package:taskforge/features/attachments/application/uploader.dart';
import 'package:taskforge/features/attachments/data/attachments_client.dart';
import 'package:taskforge/features/attachments/data/uploads_client.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show TaskRef, currentUserIdProvider;
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final attachmentsClientProvider = Provider<AttachmentsClient>(
  (ref) => GrpcAttachmentsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

final uploadsClientProvider = Provider<UploadsClient>((ref) {
  final client = HttpUploadsClient(
    ref.watch(authSessionProvider),
    restUrl: AppConfig.restUrl,
    selectedWorkspace: () => ref.read(workspaceScopeProvider),
  );
  ref.onDispose(client.close);
  return client;
});

/// Counts the times the live feed lost its place (a gap): every open list of
/// files reads again when it changes.
final attachmentsResyncProvider = NotifierProvider<ResyncCounter, int>(
  ResyncCounter.new,
);

class ResyncCounter extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// What the workspace stores and the largest file it takes.
final storageUsageProvider = FutureProvider.autoDispose<StorageUsage>((
  ref,
) async {
  final workspace = ref.watch(workspaceScopeProvider);
  if (workspace == null) {
    throw const AttachmentException(AttachmentFailure.other);
  }
  return ref.watch(attachmentsClientProvider).usage(workspace);
});

/// A signed link to a file or its thumbnail (kept while something shows it).
final fileLinkProvider = FutureProvider.autoDispose
    .family<FileLink, ({String id, bool thumb})>(
      (ref, file) =>
          ref.watch(uploadsClientProvider).link(file.id, thumb: file.thumb),
    );

@immutable
class AttachmentsState {
  const AttachmentsState({
    this.attachments = const [],
    this.uploads = const [],
    this.loading = true,
    this.error,
  });

  final List<Attachment> attachments;

  /// Files on their way (or that failed), oldest first.
  final List<UploadItem> uploads;
  final bool loading;
  final AttachmentException? error;

  AttachmentsState copyWith({
    List<Attachment>? attachments,
    List<UploadItem>? uploads,
    bool? loading,
    AttachmentException? Function()? error,
  }) => AttachmentsState(
    attachments: attachments == null
        ? this.attachments
        : List.unmodifiable(attachments),
    uploads: uploads == null ? this.uploads : List.unmodifiable(uploads),
    loading: loading ?? this.loading,
    error: error == null ? this.error : error(),
  );
}

/// One task's files and the uploads in flight. Uploads run one after another
/// and survive leaving the screen (the notifier stays alive while any runs).
final attachmentsProvider = NotifierProvider.autoDispose
    .family<AttachmentsNotifier, AttachmentsState, TaskRef>(
      AttachmentsNotifier.new,
    );

/// What an upload needs to run and to be tried again, kept out of the state.
class _Job {
  _Job(this.workspace, this.source);

  /// The workspace it was queued in: an upload never lands in another one.
  final String workspace;
  final UploadSource source;
  String? sessionId;
  var stop = false;
  var abort = Completer<void>();

  void requestStop() {
    stop = true;
    if (!abort.isCompleted) abort.complete();
  }
}

/// How recent a file must be to count as the one an upload whose answer was
/// lost may have stored.
const _justUploaded = Duration(minutes: 10);

class AttachmentsNotifier extends Notifier<AttachmentsState> {
  AttachmentsNotifier(this.task);

  final TaskRef task;
  var _generation = 0;
  var _local = 0;
  var _pumping = false;

  /// Bumped when the workspace changes: work from before it is left behind.
  var _epoch = 0;
  final _jobs = <String, _Job>{};

  /// Uploads handed to the outbox (kept on the device, sent when back online).
  final _parked = <String, String>{}; // upload id -> its outbox entity id

  /// Waits between retries of a chunk; tests make it instant.
  @visibleForTesting
  Backoff backoff = exponentialBackoff;

  AttachmentsClient get _client => ref.read(attachmentsClientProvider);

  String _workspaceOrThrow() {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const AttachmentException(AttachmentFailure.other);
    return id;
  }

  @override
  AttachmentsState build() {
    ref.watch(workspaceScopeProvider);
    ref.listen(attachmentsResyncProvider, (_, _) => unawaited(refresh()));
    // Files kept while offline have been sent: they are in the list now.
    ref.listen(outboxDrainedProvider, (_, _) => unawaited(_parkedSent()));
    // Whatever was in flight belongs to the screen being left: stop it and let
    // the server drop what it holds.
    final uploads = ref.read(uploadsClientProvider);
    _epoch++;
    ref.onDispose(() => _dropJobs(uploads));
    Future.microtask(load);
    return const AttachmentsState();
  }

  void _dropJobs(UploadsClient uploads) {
    for (final job in _jobs.values) {
      job.requestStop();
      _forgetSession(uploads, job);
    }
    _jobs.clear();
  }

  /// Best effort: the server removes it in a day anyway.
  void _forgetSession(UploadsClient uploads, _Job job) {
    final session = job.sessionId;
    if (session == null) return;
    job.sessionId = null;
    unawaited(uploads.cancel(session).catchError((Object _) {}));
  }

  Future<void> load() async {
    final generation = ++_generation;
    try {
      final files = await _client.list(
        _workspaceOrThrow(),
        task.project,
        task.task,
      );
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(
        attachments: files,
        loading: false,
        error: () => null,
      );
    } on AttachmentException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Reads again quietly, e.g. when somebody else added a file.
  Future<void> refresh() => load();

  void _setItem(String localId, UploadItem Function(UploadItem) change) {
    if (!ref.mounted) return;
    state = state.copyWith(
      uploads: [
        for (final u in state.uploads)
          if (u.localId == localId) change(u) else u,
      ],
    );
  }

  Future<int?> _maxFileBytes() async {
    try {
      final usage = await ref.read(storageUsageProvider.future);
      return usage.maxFileBytes > 0 ? usage.maxFileBytes : null;
    } on Object {
      return null; // the server says no itself
    }
  }

  /// Queues [sources] to upload (to a comment with [commentId]). A file over
  /// the size the server takes is refused here, without being sent, and one
  /// that cannot be read (gone, permission withdrawn) fails by itself without
  /// holding up the others.
  Future<void> add(
    Iterable<UploadSource> sources, {
    String commentId = '',
  }) async {
    final epoch = _epoch;
    final workspace = ref.read(workspaceScopeProvider);
    try {
      final max = await _maxFileBytes();
      for (final source in sources) {
        if (epoch != _epoch || !ref.mounted) return;
        var size = 0;
        AttachmentFailure? refused = workspace == null
            ? AttachmentFailure.other
            : null;
        try {
          size = await source.length();
          if (max != null && size > max) refused = AttachmentFailure.tooBig;
        } on Object {
          refused = AttachmentFailure.unreadable;
        }
        if (epoch != _epoch || !ref.mounted) return;
        final item = UploadItem(
          localId: 'local-${++_local}',
          filename: source.name,
          size: size,
          commentId: commentId,
          state: refused == null ? UploadState.queued : UploadState.failed,
          error: refused,
        );
        state = state.copyWith(uploads: [...state.uploads, item]);
        if (refused != null) continue;
        if (!ref.read(networkProvider) &&
            await _park(item, source, workspace!)) {
          continue;
        }
        _jobs[item.localId] = _Job(workspace!, source);
      }
    } finally {
      if (ref.mounted) unawaited(_pump());
    }
  }

  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;
    final alive = ref.keepAlive();
    try {
      while (ref.mounted) {
        final next = state.uploads
            .where(
              (u) =>
                  u.state == UploadState.queued && _jobs.containsKey(u.localId),
            )
            .firstOrNull;
        if (next == null) break;
        await _run(next);
      }
    } finally {
      _pumping = false;
      alive.close();
    }
  }

  /// The file this person uploaded a moment ago with this name, size and
  /// comment, if the task has it: proof that an upload whose answer was lost
  /// did finish.
  Future<Attachment?> _uploadedJustNow(
    String workspace,
    String filename,
    int size,
    String commentId,
  ) async {
    final me = ref.read(currentUserIdProvider);
    final files = await _client.list(workspace, task.project, task.task);
    final cutoff = DateTime.now().subtract(_justUploaded);
    return files
        .where(
          (f) =>
              f.filename == filename &&
              f.size == size &&
              f.uploaderId == me &&
              f.commentId == commentId &&
              f.createdAt.isAfter(cutoff),
        )
        .firstOrNull;
  }

  Future<void> _run(UploadItem item) async {
    final id = item.localId;
    final job = _jobs[id]!;
    final epoch = _epoch;
    bool current() => epoch == _epoch && ref.mounted;
    _setItem(id, (u) => u.copyWith(state: UploadState.uploading, sent: u.sent));
    try {
      final file = await runUpload(
        client: ref.read(uploadsClientProvider),
        source: job.source,
        workspaceId: job.workspace,
        projectId: task.project,
        taskId: task.task,
        commentId: item.commentId,
        sessionId: job.sessionId,
        backoff: backoff,
        abort: job.abort.future,
        cancelled: () => job.stop || epoch != _epoch,
        findUploaded: (name, size, comment) =>
            _uploadedJustNow(job.workspace, name, size, comment),
        onProgress: (session, sent) {
          job.sessionId = session;
          if (current()) {
            _setItem(
              id,
              (u) => u.copyWith(state: UploadState.uploading, sent: sent),
            );
          }
        },
      );
      _jobs.remove(id);
      if (!current()) return;
      state = state.copyWith(
        uploads: [
          for (final u in state.uploads)
            if (u.localId != id) u,
        ],
        attachments: [...state.attachments.where((a) => a.id != file.id), file],
      );
      ref.invalidate(storageUsageProvider);
    } on UploadCancelled {
      job.sessionId = null; // the upload cancelled it with the server
      if (current()) {
        _setItem(id, (u) => u.copyWith(state: UploadState.cancelled));
      }
    } on AttachmentException catch (e) {
      // The connection went: keep the file for when it is back.
      if (e.failure == AttachmentFailure.network &&
          current() &&
          await _park(item, job.source, job.workspace)) {
        _jobs.remove(id);
        return;
      }
      if (e.failure == AttachmentFailure.expired ||
          e.failure == AttachmentFailure.notFound) {
        job.sessionId = null;
      }
      if (current()) {
        _setItem(
          id,
          (u) => u.copyWith(
            state: UploadState.failed,
            error: e.failure,
            errorDetail: e.detail,
          ),
        );
      }
    } on Object {
      // A file that cannot be read, a bug: fail this upload, not the queue.
      if (current()) {
        _setItem(
          id,
          (u) => u.copyWith(
            state: UploadState.failed,
            error: AttachmentFailure.other,
          ),
        );
      }
    }
  }

  /// Copies the file to the device and queues it in the outbox. False when
  /// that cannot be done (no local storage): the upload then fails as usual.
  Future<bool> _park(
    UploadItem item,
    UploadSource source,
    String workspace,
  ) async {
    final store = await ref.read(offlineStoreFutureProvider);
    if (store == null) return false;
    final id = ref.read(offlineEnvProvider).newId();
    try {
      final path = await ref.read(outboxFilesProvider).keep(source, id);
      await store.enqueue(
        OutboxEntry(
          workspaceId: workspace,
          projectId: task.project,
          entity: OutboxEntity.attachment,
          entityId: id,
          op: OutboxOp.create,
          mutationId: id,
          createdAt: DateTime.now(),
          payload: {
            'taskId': task.task,
            'commentId': item.commentId,
            'name': source.name,
            'path': path,
            'size': item.size,
          },
        ),
      );
    } on Object {
      return false; // disk full, no folder: tell the person it failed
    }
    _parked[item.localId] = id;
    _setItem(
      item.localId,
      (u) => u.copyWith(state: UploadState.queued, kept: true),
    );
    return true;
  }

  /// The outbox sent what it held: the parked uploads that left it are real
  /// files now (one it refused stays, and shows in the attention list).
  Future<void> _parkedSent() async {
    if (_parked.isEmpty) return;
    final store = await ref.read(offlineStoreFutureProvider);
    if (store == null || !ref.mounted) return;
    final waiting = {for (final e in await store.everyEntry()) e.entityId};
    final sent = {
      for (final e in _parked.entries)
        if (!waiting.contains(e.value)) e.key,
    };
    if (sent.isEmpty || !ref.mounted) return;
    _parked.removeWhere((id, _) => sent.contains(id));
    state = state.copyWith(
      uploads: [
        for (final u in state.uploads)
          if (!sent.contains(u.localId)) u,
      ],
    );
    unawaited(refresh());
  }

  /// Stops an upload: at once if it has not started, by dropping the request
  /// in flight and between chunks if it has.
  void cancel(String localId) {
    final item = state.uploads.where((u) => u.localId == localId).firstOrNull;
    final job = _jobs[localId];
    if (item == null || job == null) return;
    if (item.state == UploadState.queued) {
      _setItem(localId, (u) => u.copyWith(state: UploadState.cancelled));
    } else if (item.state == UploadState.uploading) {
      job.requestStop();
    }
  }

  /// Tries a failed or cancelled upload again, from where the server has it.
  Future<void> retry(String localId) {
    final item = state.uploads.where((u) => u.localId == localId).firstOrNull;
    final job = _jobs[localId];
    if (item == null || !item.canRetry || job == null) return Future.value();
    job
      ..stop = false
      ..abort = Completer<void>();
    _setItem(localId, (u) => u.copyWith(state: UploadState.queued));
    return _pump();
  }

  /// Takes a failed, cancelled or refused upload off the list, and lets the
  /// server drop the pieces it may still hold.
  void dismiss(String localId) {
    final job = _jobs.remove(localId);
    if (job != null) _forgetSession(ref.read(uploadsClientProvider), job);
    if (!ref.mounted) return;
    state = state.copyWith(
      uploads: [
        for (final u in state.uploads)
          if (u.localId != localId) u,
      ],
    );
  }

  void clearError() => state = state.copyWith(error: () => null);

  /// Removes [file] at once; puts just that file back, with the reason, if
  /// the server says no.
  Future<void> delete(Attachment file) async {
    state = state.copyWith(
      attachments: [
        for (final a in state.attachments)
          if (a.id != file.id) a,
      ],
    );
    try {
      await _client.delete(_workspaceOrThrow(), task.project, file);
      if (ref.mounted) ref.invalidate(storageUsageProvider);
    } on AttachmentException catch (e) {
      if (!ref.mounted) return;
      final restored = [
        for (final a in state.attachments)
          if (a.id != file.id) a,
        file,
      ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = state.copyWith(attachments: restored, error: () => e);
    }
  }
}
