import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/automations/domain/automations.dart';

const _ok = RuleAction(type: ActionType.addComment, text: 'Done {key}');

RuleDraft _draft({
  String name = 'Rule',
  Trigger trigger = const Trigger(),
  String condition = '',
  List<RuleAction> actions = const [_ok],
}) => RuleDraft(
  name: name,
  trigger: trigger,
  condition: condition,
  actions: actions,
);

void main() {
  group('trigger JSON', () {
    test('round trips every type with only its own options', () {
      const triggers = [
        Trigger(),
        Trigger(type: TriggerType.statusChanged, toStatus: 's1'),
        Trigger(type: TriggerType.statusChanged),
        Trigger(type: TriggerType.fieldChanged, field: 'field:abc'),
        Trigger(type: TriggerType.assigned, userId: 'u1'),
        Trigger(type: TriggerType.dueDateReached, daysBefore: 3),
        Trigger(type: TriggerType.commentAdded),
      ];
      for (final t in triggers) {
        expect(Trigger.fromJson(jsonDecode(jsonEncode(t.toJson()))), t);
      }
    });

    test('leaves out options that do not belong to the type', () {
      const t = Trigger(
        type: TriggerType.statusChanged,
        field: 'x',
        daysBefore: 4,
      );
      expect(t.toJson(), {'type': 'status_changed'});
      expect(const Trigger(type: TriggerType.dueDateReached).toJson(), {
        'type': 'due_date_reached',
        'days_before': 0,
      });
    });

    test('an unknown type decodes to the default, not a crash', () {
      expect(decodeTrigger('{"type":"nope"}'), const Trigger());
      expect(decodeTrigger('not json'), const Trigger());
    });
  });

  group('action JSON', () {
    test('round trips every action type', () {
      const actions = [
        RuleAction(type: ActionType.setField, field: 'priority', value: 'high'),
        RuleAction(type: ActionType.setStatus, status: 's2'),
        RuleAction(
          type: ActionType.setAssignee,
          mode: 'add',
          userIds: ['u1', 'u2'],
        ),
        _ok,
        RuleAction(type: ActionType.createSubtask, text: 'Review {title}'),
        RuleAction(
          type: ActionType.notify,
          to: ['assignees', 'u1'],
          text: 'Hi',
        ),
        RuleAction(
          type: ActionType.webhook,
          url: 'https://x.io/h',
          method: 'PUT',
        ),
      ];
      expect(decodeActions(encodeActions(actions)), actions);
    });

    test('uses the server key names', () {
      expect(
        const RuleAction(type: ActionType.createSubtask, text: 't').toJson(),
        {'type': 'create_subtask', 'title': 't'},
      );
      expect(
        const RuleAction(
          type: ActionType.notify,
          to: ['owner'],
          text: 'm',
        ).toJson(),
        {
          'type': 'notify',
          'to': ['owner'],
          'message': 'm',
        },
      );
      expect(
        const RuleAction(
          type: ActionType.setAssignee,
          mode: 'clear',
          userIds: ['u1'],
        ).toJson(),
        {'type': 'set_assignee', 'mode': 'clear', 'user_ids': <String>[]},
      );
    });

    test('drops unknown actions and survives bad JSON', () {
      expect(
        decodeActions('[{"type":"zap"},{"type":"add_comment","text":"a"}]'),
        [const RuleAction(text: 'a')],
      );
      expect(decodeActions('{'), isEmpty);
      expect(decodeActions('{}'), isEmpty);
    });
  });

  group('validation', () {
    test('a good rule has no problem', () {
      expect(draftProblem(_draft()), isNull);
    });

    test('name is 1 to 80 characters', () {
      expect(draftProblem(_draft(name: '  ')), isNotNull);
      expect(draftProblem(_draft(name: 'x' * 80)), isNull);
      expect(draftProblem(_draft(name: 'x' * 81)), isNotNull);
    });

    test('needs 1 to 10 actions', () {
      expect(draftProblem(_draft(actions: const [])), contains('at least one'));
      expect(draftProblem(_draft(actions: List.filled(10, _ok))), isNull);
      expect(
        draftProblem(_draft(actions: List.filled(11, _ok))),
        contains('at most 10'),
      );
    });

    test('names the action that is wrong', () {
      final p = draftProblem(
        _draft(
          actions: const [
            _ok,
            RuleAction(type: ActionType.setStatus),
          ],
        ),
      );
      expect(p, startsWith('Action 2:'));
    });

    test('trigger options', () {
      expect(
        triggerProblem(const Trigger(type: TriggerType.fieldChanged)),
        isNotNull,
      );
      expect(
        triggerProblem(
          const Trigger(type: TriggerType.dueDateReached, daysBefore: 31),
        ),
        isNotNull,
      );
      expect(
        triggerProblem(
          const Trigger(type: TriggerType.dueDateReached, daysBefore: 30),
        ),
        isNull,
      );
    });

    test('action rules', () {
      String? p(RuleAction a) => actionProblem(a);
      expect(p(const RuleAction(type: ActionType.setField)), isNotNull);
      expect(
        p(
          const RuleAction(
            type: ActionType.setField,
            field: 'title',
            value: '{today}',
          ),
        ),
        contains('date'),
      );
      expect(
        p(
          const RuleAction(
            type: ActionType.setField,
            field: 'due_date',
            value: '{today}',
          ),
        ),
        isNull,
      );
      expect(
        p(const RuleAction(type: ActionType.setAssignee, mode: 'set')),
        isNotNull,
      );
      expect(
        p(const RuleAction(type: ActionType.setAssignee, mode: 'clear')),
        isNull,
      );
      expect(
        p(const RuleAction(type: ActionType.notify, text: 'x')),
        isNotNull,
      );
      expect(
        p(RuleAction(type: ActionType.addComment, text: 'x' * 2001)),
        isNotNull,
      );
      expect(
        p(const RuleAction(type: ActionType.webhook, url: 'ftp://a.b')),
        isNotNull,
      );
      expect(
        p(const RuleAction(type: ActionType.webhook, url: 'https://u:p@a.b')),
        isNotNull,
      );
      expect(
        p(const RuleAction(type: ActionType.webhook, url: 'https://a.b/x')),
        isNull,
      );
    });

    test('condition brackets and quotes', () {
      expect(conditionProblem(''), isNull);
      expect(conditionProblem('(a = 1 OR b = "x)y")'), isNull);
      expect(conditionProblem('(a = 1'), isNotNull);
      expect(conditionProblem('a = 1)'), isNotNull);
      expect(conditionProblem('a = "x'), isNotNull);
    });
  });

  group('runs and steps', () {
    test('decodes steps with changes', () {
      final steps = decodeSteps(
        jsonEncode([
          {
            'type': 'set_field',
            'status': 'planned',
            'detail': '',
            'changes': [
              {'field': 'priority', 'from': 'low', 'to': 'high'},
            ],
          },
          {'type': 'webhook', 'status': 'would_fail', 'error': 'refused'},
        ]),
      );
      expect(steps, hasLength(2));
      expect(steps[0].changes.single.to, 'high');
      expect(steps[1].isFailure, isTrue);
      expect(steps[1].label, 'Call a webhook');
      expect(decodeSteps('nope'), isEmpty);
    });

    test('every status has a plain-words meaning', () {
      for (final s in RunStatus.values) {
        expect(s.meaning, isNotEmpty);
        expect(RunStatus.tryParse(s.wire), s);
      }
      expect(RunStatus.tryParse('weird'), isNull);
    });

    test('changedFields lists only what differs', () {
      const old = Automation(
        id: 'a',
        projectId: 'p',
        name: 'A',
        trigger: Trigger(),
        actions: [_ok],
      );
      expect(changedFields(old, old.toDraft()), isEmpty);
      expect(
        changedFields(
          old,
          old.toDraft().copyWith(name: 'B', condition: 'x = 1'),
        ),
        ['name', 'condition'],
      );
    });

    test('error messages are plain', () {
      expect(
        automationErrorMessage(
          const AutomationException(AutomationFailure.conflict),
        ),
        contains('Someone else'),
      );
      expect(
        automationErrorMessage(
          const AutomationException(AutomationFailure.invalid, detail: 'Bad.'),
        ),
        'Bad.',
      );
    });
  });
}
