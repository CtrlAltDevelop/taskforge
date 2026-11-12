import 'package:taskforge/features/recurrence/data/recurrence_client.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';

/// A server that keeps one series per task, in memory. `preview` says the rule
/// back as `rule: <RRULE>` with the dates in [previewDates].
class FakeRecurrenceClient implements RecurrenceClient {
  FakeRecurrenceClient({
    Map<String, RepeatSeries>? series,
    this.ghosts = const [],
    this.previewDates = const ['2026-11-09', '2026-11-16'],
  }) : series = {...?series};

  final Map<String, RepeatSeries> series;
  List<RepeatGhost> ghosts;
  List<String> previewDates;
  Object? failWith;
  int futureChanged = 2;
  final calls = <String>[];
  final previews = <RepeatDraft>[];
  final previewAnchors = <(String, String)>[];
  final ghostRanges = <(String, String)>[];

  void _fail() {
    final e = failWith;
    if (e != null) throw e;
  }

  @override
  Future<RepeatSeries?> get(String ws, String project, String task) async {
    _fail();
    return series[task];
  }

  @override
  Future<RepeatSeries> set(
    String ws,
    String project,
    String task,
    RepeatDraft draft,
  ) async {
    calls.add('set $task ${draft.toRrule()} ${draft.mode.wire}');
    _fail();
    final made = RepeatSeries(
      id: 's-$task',
      projectId: project,
      taskId: task,
      rrule: draft.toRrule(),
      mode: draft.mode,
      zone: draft.zone,
      atTime: draft.atTime,
      leadDays: draft.leadDays,
      skipWeekends: draft.skipWeekends,
      summary: 'rule: ${draft.toRrule()}',
      nextDates: previewDates,
      isTemplate: true,
    );
    return series[task] = made;
  }

  @override
  Future<void> clear(String ws, String project, String task) async {
    calls.add('clear $task');
    _fail();
    series.remove(task);
  }

  @override
  Future<RepeatSeries> pause(
    String ws,
    String project,
    String task, {
    required bool paused,
  }) async {
    calls.add('pause $task $paused');
    _fail();
    final was = series[task]!;
    return series[task] = RepeatSeries(
      id: was.id,
      projectId: was.projectId,
      taskId: was.taskId,
      rrule: was.rrule,
      mode: was.mode,
      summary: was.summary,
      paused: paused,
      nextDates: was.nextDates,
      isTemplate: was.isTemplate,
    );
  }

  @override
  Future<({RepeatSeries series, int changed})> updateFuture(
    String ws,
    String project,
    String task,
  ) async {
    calls.add('future $task');
    _fail();
    return (series: series[task]!, changed: futureChanged);
  }

  @override
  Future<RepeatPreview> preview(
    String ws,
    RepeatDraft draft, {
    String startsOn = '',
    String after = '',
    int count = previewCount,
  }) async {
    previews.add(draft);
    previewAnchors.add((startsOn, after));
    _fail();
    return RepeatPreview(
      summary: 'rule: ${draft.toRrule()}',
      dates: previewDates,
    );
  }

  @override
  Future<List<RepeatGhost>> upcoming(
    String ws, {
    required String start,
    required String end,
    String projectId = '',
  }) async {
    ghostRanges.add((start, end));
    _fail();
    return ghosts;
  }
}

RepeatSeries repeating(
  String task, {
  String rrule = 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH',
  String summary = 'Every 2 weeks on Mon, Thu',
  RepeatKind mode = RepeatKind.schedule,
  bool paused = false,
  String pauseReason = '',
  int index = 0,
  bool isTemplate = true,
  int instanceCount = 1,
  List<String> nextDates = const ['2026-11-16', '2026-11-19'],
}) => RepeatSeries(
  id: 's-$task',
  projectId: 'p1',
  taskId: task,
  rrule: rrule,
  mode: mode,
  summary: summary,
  paused: paused,
  pauseReason: pauseReason,
  index: index,
  instanceCount: instanceCount,
  isTemplate: isTemplate,
  nextDates: nextDates,
);
