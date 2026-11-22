import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/domain/developer.dart'
    show DeliveryStatus;
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/data/forms_client.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/security/domain/security.dart';
import 'package:taskforge/features/system/data/system_client.dart';
import 'package:taskforge/features/system/domain/system.dart';
import 'package:taskforge/features/templates/application/templates_providers.dart';
import 'package:taskforge/features/templates/data/templates_client.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/features/workload/application/workload_providers.dart';
import 'package:taskforge/features/workload/data/workload_client.dart';
import 'package:taskforge/features/workload/domain/workload.dart';

import '../features/developer/fakes.dart';
import '../features/security/fakes.dart';
import '../features/system/fakes.dart';

/// Sample data for the release goldens: every admin page that reads its own
/// client shows a populated layout instead of "Something went wrong".
List<Override> goldenDataOverrides() => [
  developerClientProvider.overrideWithValue(_developer()),
  formsClientProvider.overrideWithValue(_GoldenForms()),
  templatesClientProvider.overrideWithValue(_GoldenTemplates()),
  workloadClientProvider.overrideWithValue(_GoldenWorkload()),
  // The grid opens on a fixed week so the picture does not move with the date.
  workloadQueryProvider.overrideWith(_FixedWeek.new),
  sessionsProvider.overrideWith(
    (ref) async => const [
      SessionInfo(
        id: 's1',
        userAgent: 'Mozilla/5.0 (Macintosh)',
        ipAddress: '10.0.0.4',
        lastUsedAt: '2026-11-12T10:00:00Z',
        current: true,
        dpopBound: true,
        name: 'MacBook Pro',
        fingerprintShort: 'a1b2c3d4',
      ),
      SessionInfo(
        id: 's2',
        userAgent: 'Mozilla/5.0 (Android)',
        ipAddress: '10.0.0.9',
        lastUsedAt: '2026-11-10T08:30:00Z',
        current: false,
        name: 'Pixel 8',
        fingerprintShort: 'ffee0011',
        newDevice: true,
      ),
    ],
  ),
];

FakeSecurityClient goldenSecurity() => _GoldenSecurity();

FakeSystemClient goldenSystem() => _GoldenSystem();

FakeDeveloperClient _developer() => FakeDeveloperClient(
  hooks: [hookRow()],
  tokenRows: [
    tokenRow('t1'),
    tokenRow('t2', scopes: ['tasks:write']),
  ],
  accounts: [
    accountRow('a1'),
    accountRow('a2', name: 'Deploy', roleId: 'r-admin'),
  ],
  deliveryRows: [
    deliveryRow('d1'),
    deliveryRow('d2', status: DeliveryStatus.delivered),
  ],
);

class _FixedWeek extends WorkloadQueryNotifier {
  @override
  WorkloadQuery build() =>
      WorkloadQuery(zoom: WorkloadZoom.week, anchor: DateTime.utc(2026, 11, 9));
}

class _GoldenForms implements FormsClient {
  static const _questions = [
    Question(
      id: 'title',
      kind: QuestionKind.title,
      label: 'Summary',
      required: true,
    ),
    Question(
      id: 'desc',
      kind: QuestionKind.description,
      label: 'What happened?',
    ),
  ];

  static const _form = IntakeForm(
    id: 'f1',
    projectId: 'p1',
    name: 'Bug report',
    description: 'Tell us what broke.',
    token: 'tok123',
    questions: _questions,
    statusId: '',
    priority: 'none',
    assigneeIds: [],
    enabled: true,
    requireEmail: true,
    sendConfirmation: true,
    notifyStatus: false,
    brandColor: '',
    logoUrl: '',
    version: 1,
    submissionCount: 2,
    problem: '',
  );

  @override
  Future<List<IntakeForm>> list(
    String workspaceId, {
    String projectId = '',
  }) async => const [_form];

  @override
  Future<SubmissionPage> submissions(
    String workspaceId,
    String formId, {
    String before = '',
  }) async => const SubmissionPage([
    Submission(
      id: 'x1',
      reference: 'REF-1',
      projectId: 'p1',
      taskKey: 'WEB-7',
      taskTitle: 'Login button does nothing',
      statusName: 'To do',
      email: 'ann@example.com',
      at: '2026-11-11T09:00:00Z',
    ),
    Submission(
      id: 'x2',
      reference: 'REF-2',
      projectId: 'p1',
      taskKey: 'WEB-8',
      taskTitle: 'Export is slow',
      statusName: 'In progress',
      email: 'bo@example.com',
      at: '2026-11-10T15:20:00Z',
    ),
  ], '');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_GoldenForms.${invocation.memberName}');
}

class _GoldenTemplates implements TemplatesClient {
  @override
  Future<List<Template>> list(
    String workspaceId, {
    String query = '',
    TemplateKind? kind,
  }) async => [
    for (final t in _all)
      if (kind == null || t.kind == kind) t,
  ];

  static const _all = [
    Template(
      id: 'tpl1',
      kind: TemplateKind.project,
      name: 'Software team',
      description: 'Backlog, sprints and a bug workflow.',
      visibility: TemplateVisibility.workspace,
      builtin: true,
      version: 1,
      taskCount: 6,
      variables: [],
      includes: [],
      statusNames: ['To do', 'In progress', 'Done'],
      canEdit: false,
      contentJson: '',
    ),
    Template(
      id: 'tpl2',
      kind: TemplateKind.project,
      name: 'Client onboarding',
      description: 'Steps for a new customer.',
      visibility: TemplateVisibility.workspace,
      builtin: false,
      version: 2,
      taskCount: 4,
      variables: ['client'],
      includes: [],
      statusNames: ['To do', 'Done'],
      canEdit: true,
      contentJson: '',
    ),
    Template(
      id: 'tpl3',
      kind: TemplateKind.task,
      name: 'Release checklist',
      description: '',
      visibility: TemplateVisibility.private,
      builtin: false,
      version: 1,
      taskCount: 1,
      variables: [],
      includes: [],
      statusNames: [],
      canEdit: true,
      contentJson: '',
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_GoldenTemplates.${invocation.memberName}');
}

class _GoldenWorkload implements WorkloadClient {
  static const _capacity = Capacity(
    userId: 'u1',
    hoursPerDay: 8,
    workingDays: [0, 1, 2, 3, 4],
    isSet: true,
  );

  @override
  Future<WorkloadData> get(String workspaceId, WorkloadQuery query) async {
    final mon = DateTime.utc(2026, 11, 9);
    DateTime day(int n) => mon.add(Duration(days: n));
    return WorkloadData(
      start: query.range.$1,
      end: query.range.$2,
      canSeeAll: true,
      people: [
        PersonLoad(
          userId: 'u1',
          capacity: _capacity,
          timeOff: const [],
          days: {
            day(0): const [Contribution('t1', 4 * 3600)],
            day(1): const [
              Contribution('t1', 4 * 3600),
              Contribution('t2', 6 * 3600),
            ],
            day(2): const [Contribution('t2', 12 * 3600)],
          },
        ),
        PersonLoad(
          userId: 'u2',
          capacity: const Capacity(
            userId: 'u2',
            hoursPerDay: 6,
            workingDays: [0, 1, 2, 3],
            isSet: true,
          ),
          timeOff: const [],
          days: {
            day(0): const [Contribution('t3', 2 * 3600)],
          },
        ),
      ],
      tasks: {
        't1': _task('t1', 'WEB-1', 'Design the new login', day(0), day(1), 8, [
          'u1',
        ]),
        't2': _task('t2', 'WEB-2', 'Fix the export bug', day(1), day(2), 18, [
          'u1',
        ]),
        't3': _task('t3', 'WEB-3', 'Write the docs', day(0), day(0), 2, ['u2']),
      },
      unplaced: const [],
      holidays: const {},
      truncated: false,
    );
  }

  static LoadTask _task(
    String id,
    String key,
    String title,
    DateTime start,
    DateTime due,
    int hours,
    List<String> who,
  ) => LoadTask(
    id: id,
    projectId: 'p1',
    displayId: key,
    title: title,
    version: 1,
    start: start,
    due: due,
    estimateSec: hours * 3600,
    assigneeIds: who,
    own: const {},
  );

  @override
  Future<List<Capacity>> capacities(
    String workspaceId, {
    String userId = '',
  }) async => const [
    _capacity,
    Capacity(
      userId: 'u2',
      hoursPerDay: 6,
      workingDays: [0, 1, 2, 3],
      isSet: true,
    ),
  ];

  @override
  Future<List<TimeOff>> listTimeOff(
    String workspaceId, {
    String userId = '',
  }) async => [
    TimeOff(
      id: 'o1',
      userId: 'u2',
      start: DateTime.utc(2026, 11, 16),
      end: DateTime.utc(2026, 11, 20),
      kind: TimeOffKind.vacation,
      note: 'Family trip',
    ),
  ];

  @override
  Future<List<Holiday>> holidays(String workspaceId) async => [
    Holiday(id: 'h1', date: DateTime.utc(2026, 12, 25), name: 'Winter break'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_GoldenWorkload.${invocation.memberName}');
}

class _GoldenSecurity extends FakeSecurityClient {
  _GoldenSecurity()
    : super(
        policyAnswer: const SecurityPolicy(
          require2fa: true,
          graceDays: 7,
          enforcedFrom: null,
          inGrace: false,
          enrolled: true,
          blocked: false,
          version: 2,
        ),
      );

  @override
  Future<SecondFactorStatus> status() async => const SecondFactorStatus(
    enabled: true,
    unusedRecoveryCodes: 8,
    devices: [],
  );

  @override
  Future<SsoProvider> provider(String workspaceId) async => const SsoProvider(
    configured: true,
    name: 'Acme SSO',
    issuer: 'https://id.example.com',
    clientId: 'taskforge',
    hasSecret: true,
    scopes: 'openid email profile',
    allowedDomains: ['example.com'],
    groupClaim: 'groups',
    groupRoles: [RoleMapping(group: 'eng', roleId: 'r-member')],
    defaultRoleId: 'r-member',
    autoCreateUsers: true,
    enabled: true,
    enforceSso: false,
    version: 1,
    redirectUri: 'https://tasks.example.com/sso/callback',
  );
}

class _GoldenSystem extends FakeSystemClient implements SystemClient {
  @override
  Future<SystemInfo> info() async => const SystemInfo(
    version: '1.0.0',
    minClientVersion: '0.0.0',
    api: 'ok',
    commit: 'ab12cd3',
    redis: 'ok',
    broker: 'ok',
    eager: false,
    workers: 2,
    backlog: {'notifications': 3, 'recurrence': 0},
    collectDeviceInfo: true,
    devicePepperSet: true,
  );
}
