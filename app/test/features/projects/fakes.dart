import 'dart:async';

import 'package:taskforge/features/projects/data/projects_client.dart';
import 'package:taskforge/features/projects/domain/projects.dart';

const featureInfo = [
  FeatureInfo(
    key: 'sprints',
    label: 'Sprints',
    description: 'Plan work in time-boxed iterations.',
  ),
  FeatureInfo(
    key: 'time_tracking',
    label: 'Time tracking',
    description: 'Log time spent on tasks.',
  ),
];

Project project(
  String id,
  String name, {
  String? key,
  bool favorite = false,
  bool archived = false,
  bool private = false,
  bool isMember = true,
  int taskCounter = 0,
  Set<String> enabled = const {},
}) => Project(
  id: id,
  name: name,
  key: key ?? name.substring(0, 3).toUpperCase(),
  visibility: private ? ProjectVisibility.private : ProjectVisibility.open,
  archivedAt: archived ? '2026-05-01T00:00:00Z' : '',
  taskCounter: taskCounter,
  isFavorite: favorite,
  isMember: isMember,
  canOpen: isMember || !private,
  memberCount: private ? 1 : 0,
  features: [
    for (final f in featureInfo)
      Feature(key: f.key, enabled: enabled.contains(f.key)),
  ],
);

/// In-memory projects server. Private projects the caller is not in are hidden
/// from [list] and listed (cannot open) by [listPrivate].
class FakeProjectsClient implements ProjectsClient {
  FakeProjectsClient([List<Project> initial = const []])
    : projects = [...initial];

  final List<Project> projects;

  /// Members per private project id.
  final members = <String, List<ProjectMember>>{};
  final added = <({String project, String user})>[];
  final removed = <({String project, String user})>[];
  final featureCalls = <({Set<String> keys, int expectedVersion})>[];
  final workspaces = <String>[];
  ProjectException? failNext;
  ProjectException? failListNext;
  Completer<void>? _gate;
  int listCalls = 0;
  int _next = 100;

  /// Makes [list] wait until [releaseLists] (a slow workspace load).
  void holdLists() => _gate = Completer<void>();

  void releaseLists() => _gate?.complete();

  void _maybeFail() {
    final e = failNext;
    failNext = null;
    if (e != null) throw e;
  }

  int _index(String id) {
    final i = projects.indexWhere((p) => p.id == id);
    if (i < 0) throw const ProjectException(ProjectFailure.notFound);
    return i;
  }

  Project _live(String id, [int? expectedVersion]) {
    final p = projects[_index(id)];
    if (expectedVersion != null && p.version != expectedVersion) {
      throw const ProjectException(ProjectFailure.conflict);
    }
    return p;
  }

  Project _replace(Project p, Project Function(Project) change) {
    final changed = change(p);
    return projects[_index(p.id)] = changed;
  }

  /// Simulates someone else editing project [id]: bumps its version.
  void editElsewhere(String id) =>
      _replace(_live(id), (p) => _copy(p, version: p.version + 1));

  @override
  Future<ProjectCatalog> list(
    String workspaceId, {
    bool includeArchived = false,
  }) async {
    listCalls++;
    workspaces.add(workspaceId);
    await _gate?.future;
    final listFailure = failListNext;
    failListNext = null;
    if (listFailure != null) throw listFailure;
    _maybeFail();
    final visible = projects.where(
      (p) => p.canOpen && (includeArchived || !p.isArchived),
    );
    return ProjectCatalog(
      projects: [
        ...visible.where((p) => p.isFavorite),
        ...visible.where((p) => !p.isFavorite),
      ],
      featureInfo: featureInfo,
      workspaceId: workspaceId,
    );
  }

  @override
  Future<Project> create(
    String workspaceId, {
    required String name,
    required String key,
    String description = '',
    String icon = '',
    String color = '',
    ProjectVisibility visibility = ProjectVisibility.open,
  }) async {
    _maybeFail();
    if (projects.any((p) => p.key == key)) {
      throw const ProjectException(ProjectFailure.keyTaken);
    }
    final p = Project(
      id: 'p${_next++}',
      name: name,
      key: key,
      description: description,
      icon: icon,
      color: color,
      visibility: visibility,
      isMember: true,
      features: [
        for (final f in featureInfo) Feature(key: f.key, enabled: false),
      ],
    );
    projects.add(p);
    return p;
  }

  @override
  Future<Project> update(
    String workspaceId,
    String id, {
    required int expectedVersion,
    String? name,
    String? key,
    String? description,
    String? icon,
    String? color,
    ProjectVisibility? visibility,
  }) async {
    _maybeFail();
    final p = _live(id, expectedVersion);
    // Like the server, a call that changes nothing keeps the version.
    if ([
      name,
      key,
      description,
      icon,
      color,
      visibility,
    ].every((v) => v == null)) {
      return p;
    }
    if (key != null && key != p.key && p.keyLocked) {
      throw const ProjectException(ProjectFailure.keyLocked);
    }
    return _replace(
      p,
      (p) => _copy(
        p,
        name: name,
        key: key,
        description: description,
        icon: icon,
        color: color,
        visibility: visibility,
        version: p.version + 1,
      ),
    );
  }

  @override
  Future<Project> archive(String workspaceId, String id, int version) async {
    _maybeFail();
    return _replace(
      _live(id, version),
      (p) =>
          _copy(p, archivedAt: '2026-05-01T00:00:00Z', version: p.version + 1),
    );
  }

  @override
  Future<Project> restore(String workspaceId, String id, int version) async {
    _maybeFail();
    return _replace(
      _live(id, version),
      (p) => _copy(p, archivedAt: '', version: p.version + 1),
    );
  }

  @override
  Future<Project> setFeatures(
    String workspaceId,
    String id,
    Set<String> enabledKeys,
    int version,
  ) async {
    featureCalls.add((keys: enabledKeys, expectedVersion: version));
    _maybeFail();
    return _replace(
      _live(id, version),
      (p) => _copy(
        p,
        features: [
          for (final f in featureInfo)
            Feature(key: f.key, enabled: enabledKeys.contains(f.key)),
        ],
        version: p.version + 1,
      ),
    );
  }

  @override
  Future<Project> favorite(String workspaceId, String id, bool favorite) async {
    _maybeFail();
    return _replace(_live(id), (p) => _copy(p, isFavorite: favorite));
  }

  @override
  Future<List<ProjectMember>> listMembers(
    String workspaceId,
    String id,
  ) async => [...?members[id]];

  @override
  Future<void> addMember(String workspaceId, String id, String userId) async {
    _maybeFail();
    added.add((project: id, user: userId));
    // An empty id means the caller, who is 'u1' in these tests.
    final who = userId.isEmpty ? 'u1' : userId;
    members[id] = [
      ...?members[id],
      ProjectMember(userId: who, displayName: 'User $who', email: ''),
    ];
    _replace(_live(id), (p) => _copy(p, isMember: true, canOpen: true));
  }

  @override
  Future<void> removeMember(
    String workspaceId,
    String id,
    String userId,
  ) async {
    _maybeFail();
    final current = [...?members[id]];
    if (current.length <= 1) {
      throw const ProjectException(ProjectFailure.lastMember);
    }
    removed.add((project: id, user: userId));
    members[id] = [
      for (final m in current)
        if (m.userId != userId) m,
    ];
  }

  @override
  Future<List<Project>> listPrivate(String workspaceId) async => [
    for (final p in projects)
      if (p.isPrivate && !p.isArchived) p,
  ];

  Project _copy(
    Project p, {
    String? name,
    String? key,
    String? description,
    String? icon,
    String? color,
    ProjectVisibility? visibility,
    String? archivedAt,
    int? version,
    List<Feature>? features,
    bool? isFavorite,
    bool? isMember,
    bool? canOpen,
  }) => Project(
    id: p.id,
    name: name ?? p.name,
    key: key ?? p.key,
    description: description ?? p.description,
    icon: icon ?? p.icon,
    color: color ?? p.color,
    visibility: visibility ?? p.visibility,
    archivedAt: archivedAt ?? p.archivedAt,
    version: version ?? p.version,
    taskCounter: p.taskCounter,
    features: features ?? p.features,
    isFavorite: isFavorite ?? p.isFavorite,
    memberCount: p.memberCount,
    isMember: isMember ?? p.isMember,
    canOpen: canOpen ?? p.canOpen,
  );
}
