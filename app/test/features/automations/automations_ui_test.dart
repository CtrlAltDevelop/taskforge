import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';

import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';

import '../filters/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart' as t;
import 'fakes.dart';

final _high = FilterQuery(
  root: const FilterGroup(
    children: [
      FilterCondition(
        field: 'priority',
        cmp: 'eq',
        values: [FilterValue.id('high')],
      ),
    ],
  ),
);

Finder key(String k) => find.byKey(Key(k));

Future<Pumped> open(
  WidgetTester tester,
  FakeAutomationsClient automations, {
  String role = 'Owner',
  Size size = const Size(1400, 1200),
  t.FakeTasksClient? tasks,
  FakeFiltersClient? filters,
}) async {
  final pumped = await pumpProjects(
    tester,
    role: role,
    size: size,
    projects: [project('p1', 'Web')],
    automations: automations,
    tasks: tasks,
    filters: filters ?? FakeFiltersClient(texts: {'priority = high': _high}),
  );
  await pumped.go(tester, '/projects/p1/automations');
  return pumped;
}

Future<void> choose(WidgetTester tester, String k, String label) async {
  await tester.ensureVisible(key(k));
  await tester.tap(key(k));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists rules with toggle and last run status', (tester) async {
    final fake = FakeAutomationsClient(
      rules: [
        rule('a1', 'Notify on done', lastRunStatus: 'failed'),
        rule('a2', 'Quiet rule', enabled: false),
      ],
    );
    await open(tester, fake);
    expect(find.text('Notify on done'), findsOneWidget);
    expect(
      find.descendant(of: key('last-a1'), matching: find.text('Failed')),
      findsOneWidget,
    );
    expect(find.text('Never run'), findsOneWidget);
    expect(tester.widget<Switch>(key('toggle-a1')).value, isTrue);
    await tester.tap(key('toggle-a2'));
    await tester.pumpAndSettle();
    expect(fake.toggles, ['a2:true']);
    expect(tester.widget<Switch>(key('toggle-a2')).value, isTrue);
  });

  testWidgets('empty project says how a rule works', (tester) async {
    await open(tester, FakeAutomationsClient());
    expect(key('automations-empty'), findsOneWidget);
  });

  testWidgets('a rule the server switched off shows the reason and a hint', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(
      rules: [
        rule(
          'a1',
          'Broken',
          enabled: false,
          disabledReason: 'A status it uses was deleted.',
        ),
      ],
    );
    await open(tester, fake);
    expect(
      find.textContaining('A status it uses was deleted.'),
      findsOneWidget,
    );
    expect(find.textContaining('Fix it:'), findsOneWidget);
    await tester.tap(key('toggle-a1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fix it first'), findsOneWidget);
    expect(tester.widget<Switch>(key('toggle-a1')).value, isFalse);
  });

  testWidgets('builder creates a rule from the When, If, Then cards', (
    tester,
  ) async {
    final fake = FakeAutomationsClient();
    await open(tester, fake);
    await tester.tap(key('new-rule'));
    await tester.pumpAndSettle();

    // Nothing yet: the validation says why.
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('name'), findsWidgets);
    expect(fake.created, isEmpty);

    await tester.enterText(key('rule-name'), 'Triage');
    await choose(tester, 'trigger-type', 'A status changes');
    await choose(tester, 'trigger-status', 'Done');
    await tester.enterText(key('rule-condition'), 'priority = high');
    await tester.tap(key('add-action'));
    await tester.pumpAndSettle();
    await tester.enterText(key('action-text').first, 'Closed {key}');
    await tester.ensureVisible(key('placeholder-{today}').first);
    await tester.tap(key('placeholder-{today}').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(key('rule-save'));
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();

    expect(fake.created, hasLength(1));
    final d = fake.created.single;
    expect(d.name, 'Triage');
    expect(d.trigger.type, TriggerType.statusChanged);
    expect(d.trigger.toStatus, 'done');
    expect(d.condition, 'priority = high');
    expect(d.actions.single.text, 'Closed {key}{today}');
    expect(find.text('Triage'), findsOneWidget);
  });

  testWidgets('builder blocks a bad condition and an incomplete action', (
    tester,
  ) async {
    final fake = FakeAutomationsClient();
    await open(tester, fake);
    await tester.tap(key('new-rule'));
    await tester.pumpAndSettle();
    await tester.enterText(key('rule-name'), 'X');
    await tester.enterText(key('rule-condition'), '(priority = high');
    await tester.pump();
    expect(find.text('A bracket is not closed.'), findsOneWidget);
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(key('rule-error'), findsOneWidget);
    expect(fake.created, isEmpty);
  });

  testWidgets('builder edits a rule and sends only what changed', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(rules: [rule('a1', 'Old')]);
    await open(tester, fake);
    await tester.tap(key('open-a1'));
    await tester.pumpAndSettle();
    expect(find.text('Edit automation'), findsOneWidget);
    await tester.enterText(key('rule-name'), 'Renamed');
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(fake.updated.single.fields, ['name']);
    expect(find.text('Renamed'), findsOneWidget);
  });

  testWidgets('a stale version shows the conflict and loads the latest', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(rules: [rule('a1', 'Old')]);
    await open(tester, fake);
    await tester.tap(key('open-a1'));
    await tester.pumpAndSettle();
    // Someone else saves first.
    await fake.update(
      'w1',
      fake.rules.single,
      const RuleDraft(
        name: 'Theirs',
        actions: [RuleAction(text: 'x')],
      ),
      ['name'],
    );
    await tester.enterText(key('rule-name'), 'Mine');
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Someone else changed'), findsOneWidget);
    await tester.tap(key('rule-reload'));
    await tester.pumpAndSettle();
    expect(find.text('Theirs'), findsWidgets);
    expect(key('rule-error'), findsNothing);
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(fake.updated, hasLength(2));
  });

  testWidgets('delete asks first', (tester) async {
    final fake = FakeAutomationsClient(rules: [rule('a1', 'Old')]);
    await open(tester, fake);
    await tester.tap(key('delete-a1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(fake.deleted, isEmpty);
    await tester.tap(key('delete-a1'));
    await tester.pumpAndSettle();
    await tester.tap(key('confirm-delete'));
    await tester.pumpAndSettle();
    expect(fake.deleted, ['a1']);
    expect(key('automations-empty'), findsOneWidget);
  });

  testWidgets('dry run shows the would-be changes', (tester) async {
    final fake = FakeAutomationsClient(rules: [rule('a1', 'Old')])
      ..dryAnswer = const DryRunResult(
        wouldRun: true,
        steps: [
          RunStep(
            type: 'set_field',
            status: 'planned',
            changes: [StepChange(field: 'priority', from: 'low', to: 'high')],
          ),
          RunStep(
            type: 'webhook',
            status: 'planned',
            detail: 'POST https://x.io/hook',
          ),
        ],
      );
    await open(
      tester,
      fake,
      tasks: t.FakeTasksClient([t.task('t1', 'Fix it')]),
    );
    await tester.tap(key('dry-a1'));
    await tester.pumpAndSettle();
    expect(tester.widget<TfButton>(key('dry-run')).onPressed, isNull);
    await choose(tester, 'dry-task', 'WEB-1 Fix it');
    await tester.tap(key('dry-run'));
    await tester.pumpAndSettle();
    expect(fake.dryRuns, ['a1:t1']);
    expect(find.text('It would run.'), findsOneWidget);
    expect(find.text('priority: low -> high'), findsOneWidget);
    expect(find.text('POST https://x.io/hook'), findsOneWidget);
  });

  testWidgets('dry run explains when it would not run', (tester) async {
    final fake = FakeAutomationsClient(rules: [rule('a1', 'Old')])
      ..dryAnswer = const DryRunResult(
        wouldRun: false,
        status: 'skipped_condition',
        explanation: 'the task does not meet: priority = high',
      );
    await open(
      tester,
      fake,
      tasks: t.FakeTasksClient([t.task('t1', 'Fix it')]),
    );
    await tester.tap(key('dry-a1'));
    await tester.pumpAndSettle();
    await choose(tester, 'dry-task', 'WEB-1 Fix it');
    await tester.tap(key('dry-run'));
    await tester.pumpAndSettle();
    expect(find.text('It would not run on this task.'), findsOneWidget);
    expect(find.textContaining('priority = high'), findsOneWidget);
  });

  testWidgets('run history expands steps, errors and the explainer', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(
      rules: [rule('a1', 'Rule one'), rule('a2', 'Rule two')],
      runs: [
        run(
          'r1',
          status: RunStatus.failed,
          error: 'Step 1 (webhook): refused',
          steps: const [
            RunStep(type: 'webhook', status: 'failed', error: 'refused'),
            RunStep(type: 'add_comment', status: 'not_run'),
          ],
        ),
        run(
          'r2',
          ruleId: 'a2',
          name: 'Rule two',
          status: RunStatus.skippedCondition,
          explanation: 'the task does not meet: priority = high',
        ),
        run('r3', status: RunStatus.skippedLoop),
        run('r4', status: RunStatus.skippedRate),
      ],
    );
    await open(tester, fake);
    await tester.tap(find.text('Run history'));
    await tester.pumpAndSettle();
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Skipped: condition'), findsOneWidget);
    expect(find.text('Stopped: loop'), findsOneWidget);
    expect(find.text('Paused: too many runs'), findsOneWidget);

    await tester.tap(key('run-r1'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 (webhook): refused'), findsOneWidget);
    expect(key('step-1'), findsOneWidget);

    await tester.tap(key('run-r2'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("Why didn't this run? the task does not meet"),
      findsOneWidget,
    );

    await tester.ensureVisible(key('run-r3'));
    await tester.tap(key('run-r3'));
    await tester.pumpAndSettle();
    expect(find.textContaining('more than 5 hops'), findsWidgets);
    await tester.ensureVisible(key('run-r4'));
    await tester.tap(key('run-r4'));
    await tester.pumpAndSettle();
    expect(find.textContaining('30 times in the last minute'), findsWidgets);
  });

  testWidgets('history of one rule is filtered and can be cleared', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(
      rules: [rule('a1', 'Rule one'), rule('a2', 'Rule two')],
      runs: [
        run('r1'),
        run('r2', ruleId: 'a2', name: 'Rule two'),
      ],
    );
    await open(tester, fake);
    await tester.tap(key('history-a2'));
    await tester.pumpAndSettle();
    expect(key('run-r2'), findsOneWidget);
    expect(key('run-r1'), findsNothing);
    await tester.tap(
      find.descendant(of: key('history-filter'), matching: find.byType(Icon)),
    );
    await tester.pumpAndSettle();
    expect(key('run-r1'), findsOneWidget);
  });

  testWidgets('without automation.manage everything is read only', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(rules: [rule('a1', 'Old')]);
    await open(tester, fake, role: 'Member');
    expect(key('read-only'), findsOneWidget);
    expect(key('new-rule'), findsNothing);
    expect(key('delete-a1'), findsNothing);
    expect(key('dry-a1'), findsNothing);
    expect(tester.widget<Switch>(key('toggle-a1')).onChanged, isNull);
    await tester.tap(key('open-a1'));
    await tester.pumpAndSettle();
    expect(key('rule-save'), findsNothing);
    expect(key('add-action'), findsNothing);
    expect(tester.widget<TextField>(key('rule-name')).readOnly, isTrue);
  });

  testWidgets('the limit of 50 rules stops new ones', (tester) async {
    final fake = FakeAutomationsClient(
      rules: [for (var i = 0; i < 50; i++) rule('a$i', 'R$i')],
    );
    await open(tester, fake);
    expect(key('rule-limit'), findsOneWidget);
    expect(tester.widget<TfButton>(key("new-rule")).onPressed, isNull);
  });

  testWidgets('the builder fits a phone', (tester) async {
    final fake = FakeAutomationsClient(
      rules: [
        rule(
          'a1',
          'Old',
          actions: const [
            RuleAction(type: ActionType.webhook, url: 'https://x.io/h'),
            RuleAction(type: ActionType.notify, to: ['owner'], text: 'hi'),
          ],
        ),
      ],
    );
    await open(tester, fake, size: const Size(390, 800));
    await tester.tap(key('open-a1'));
    await tester.pumpAndSettle();
    expect(key('card-when'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(key('rule-save'));
    expect(key('rule-save'), findsOneWidget);
  });

  testWidgets('the sidebar links to the page', (tester) async {
    await open(tester, FakeAutomationsClient());
    expect(key('open-automations-p1'), findsOneWidget);
  });

  testWidgets('run history pages on identical start times by id', (
    tester,
  ) async {
    final fake = FakeAutomationsClient(
      rules: [rule('a1', 'Rule one')],
      runs: [
        for (var n = 99; n >= 40; n--)
          run('r$n', startedAt: '2026-11-12 10:00'),
      ],
    );
    await open(tester, fake);
    await tester.tap(find.text('Run history'));
    await tester.pumpAndSettle();
    final scroll = find.descendant(
      of: key('runs-list'),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      key('runs-load-more'),
      300,
      scrollable: scroll,
    );
    await tester.tap(key('runs-load-more'));
    await tester.pumpAndSettle();
    expect(fake.runRequests.last, (
      before: '2026-11-12 10:00#r50',
      limit: runPageSize,
    ));
    await tester.scrollUntilVisible(key('run-r40'), 300, scrollable: scroll);
    expect(key('run-r40'), findsOneWidget);
  });

  testWidgets('run history pages older runs with Load more', (tester) async {
    String at(int n) => '2026-11-12 ${(100 - n).toString().padLeft(3, '0')}';
    final fake = FakeAutomationsClient(
      rules: [rule('a1', 'Rule one')],
      runs: [for (var n = 0; n < 60; n++) run('r$n', startedAt: at(n))],
    );
    await open(tester, fake);
    await tester.tap(find.text('Run history'));
    await tester.pumpAndSettle();
    expect(key('run-r0'), findsOneWidget);
    expect(fake.runRequests.last, (before: '', limit: runPageSize));

    await tester.scrollUntilVisible(
      key('runs-load-more'),
      300,
      scrollable: find.descendant(
        of: key('runs-list'),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(key('runs-load-more'));
    await tester.pumpAndSettle();
    expect(fake.runRequests.last, (
      before: '${at(49)}#r49',
      limit: runPageSize,
    ));
    // 10 older rows came; the button is gone because the page was short.
    expect(key('runs-load-more'), findsNothing);
    await tester.scrollUntilVisible(
      key('run-r59'),
      300,
      scrollable: find.descendant(
        of: key('runs-list'),
        matching: find.byType(Scrollable),
      ),
    );
    expect(key('run-r59'), findsOneWidget);
  });

  testWidgets('the condition is checked by the server as you type', (
    tester,
  ) async {
    final filters = FakeFiltersClient(texts: {'priority = high': _high})
      ..suggestions = const [
        QuerySuggestion('assignee', 'field', 0, 'Assignee'),
      ];
    final fake = FakeAutomationsClient();
    await open(tester, fake, filters: filters);
    await tester.tap(key('new-rule'));
    await tester.pumpAndSettle();

    await tester.enterText(key('rule-condition'), 'priority ? high');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Unexpected text. (at character 10)'), findsOneWidget);
    expect(filters.validated.last.tfql, 'priority ? high');
    expect(key('suggest-assignee'), findsOneWidget);

    // Saving asks again and refuses while the condition is wrong.
    await tester.enterText(key('rule-name'), 'X');
    await choose(tester, 'trigger-type', 'A status changes');
    await choose(tester, 'trigger-status', 'Done');
    await tester.tap(key('add-action'));
    await tester.pumpAndSettle();
    await tester.enterText(key('action-text').first, 'Hi');
    await tester.ensureVisible(key('rule-save'));
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('The condition has a problem'), findsOneWidget);
    expect(fake.created, isEmpty);

    // Fixed: it saves.
    await tester.enterText(key('rule-condition'), 'priority = high');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unexpected text'), findsNothing);
    await tester.ensureVisible(key('rule-save'));
    await tester.tap(key('rule-save'));
    await tester.pumpAndSettle();
    expect(fake.created.single.condition, 'priority = high');
  });
}
