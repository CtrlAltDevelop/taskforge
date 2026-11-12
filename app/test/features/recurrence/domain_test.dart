import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:taskforge/features/recurrence/data/recurrence_client.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/gen/infrastructure/recurrence/grpc/recurrence.pbgrpc.dart'
    as pb;

void main() {
  group('RepeatDraft.toRrule', () {
    test('writes weekly days in week order', () {
      const draft = RepeatDraft(interval: 2, weekdays: {3, 0});
      expect(draft.toRrule(), 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH');
    });

    test('writes the nth weekday of a month and the last one', () {
      expect(
        const RepeatDraft(
          freq: RepeatFreq.monthly,
          monthlyBy: MonthlyBy.nthWeekday,
          nthWeekday: 4,
          nth: -1,
        ).toRrule(),
        'FREQ=MONTHLY;BYDAY=-1FR',
      );
    });

    test('writes a day of the month, a count and an until', () {
      expect(
        const RepeatDraft(
          freq: RepeatFreq.monthly,
          monthDay: 31,
          end: RepeatEnd.count,
          count: 6,
        ).toRrule(),
        'FREQ=MONTHLY;BYMONTHDAY=31;COUNT=6',
      );
      expect(
        const RepeatDraft(
          freq: RepeatFreq.daily,
          end: RepeatEnd.until,
          until: '2026-12-31',
        ).toRrule(),
        'FREQ=DAILY;UNTIL=20261231',
      );
    });

    test('an after-completion repeat only says how long to wait', () {
      expect(
        const RepeatDraft(
          freq: RepeatFreq.weekly,
          interval: 3,
          weekdays: {0},
          mode: RepeatKind.afterCompletion,
        ).toRrule(),
        'FREQ=WEEKLY;INTERVAL=3',
      );
    });
  });

  group('RepeatDraft.fromRrule', () {
    test('reads back what toRrule wrote', () {
      for (final draft in [
        const RepeatDraft(interval: 2, weekdays: {0, 3}),
        const RepeatDraft(freq: RepeatFreq.daily, end: RepeatEnd.count),
        const RepeatDraft(
          freq: RepeatFreq.monthly,
          monthlyBy: MonthlyBy.nthWeekday,
          nth: 2,
          nthWeekday: 1,
        ),
        const RepeatDraft(freq: RepeatFreq.monthly, monthDay: 15),
        const RepeatDraft(
          freq: RepeatFreq.yearly,
          end: RepeatEnd.until,
          until: '2030-01-02',
        ),
      ]) {
        final back = RepeatDraft.fromRrule(draft.toRrule());
        expect(back?.toRrule(), draft.toRrule());
      }
    });

    test('gives null for a rule the editor cannot show', () {
      expect(RepeatDraft.fromRrule('FREQ=HOURLY'), isNull);
      expect(RepeatDraft.fromRrule('nonsense'), isNull);
      expect(RepeatDraft.fromRrule('FREQ=WEEKLY;BYDAY=XX'), isNull);
    });

    test('is strict: anything it cannot show faithfully is null', () {
      for (final rule in [
        'FREQ=YEARLY;BYMONTH=2',
        'FREQ=MONTHLY;BYDAY=MO,TU;BYSETPOS=1',
        'FREQ=MONTHLY;BYMONTHDAY=-1',
        'FREQ=MONTHLY;BYMONTHDAY=40',
        'FREQ=MONTHLY;BYDAY=5MO',
        'FREQ=MONTHLY;BYDAY=1MO,3MO',
        'FREQ=MONTHLY;BYDAY=MO',
        'FREQ=WEEKLY;BYMONTHDAY=3',
        'FREQ=WEEKLY;BYDAY=1MO',
        'FREQ=DAILY;BYDAY=MO',
        'FREQ=DAILY;COUNT=3;UNTIL=20261231',
        'FREQ=DAILY;INTERVAL=999',
        'FREQ=DAILY;UNTIL=soon',
        'FREQ=DAILY;BYHOUR=9',
      ]) {
        expect(RepeatDraft.fromRrule(rule), isNull, reason: rule);
      }
    });

    test('carries the series settings and its end date', () {
      final back = RepeatDraft.fromRrule(
        'FREQ=DAILY',
        mode: RepeatKind.afterCompletion,
        zone: 'Asia/Tokyo',
        leadDays: 2,
        skipWeekends: true,
        endsOn: '2027-01-01',
      )!;
      expect(back.zone, 'Asia/Tokyo');
      expect((back.leadDays, back.skipWeekends), (2, true));
      expect((back.end, back.until), (RepeatEnd.until, '2027-01-01'));
    });
  });

  group('RepeatDraft.problem', () {
    test('names what is wrong', () {
      expect(const RepeatDraft(interval: 0).problem, isNotNull);
      expect(const RepeatDraft().problem, 'Pick at least one weekday.');
      expect(
        const RepeatDraft(weekdays: {1}, end: RepeatEnd.until).problem,
        'Pick an end date.',
      );
      expect(
        const RepeatDraft(
          weekdays: {1},
          end: RepeatEnd.count,
          count: 5000,
        ).problem,
        isNotNull,
      );
      expect(const RepeatDraft(weekdays: {1}, leadDays: 31).problem, isNotNull);
    });

    test(
      'a valid draft has none, and an after-completion one needs no days',
      () {
        expect(const RepeatDraft(weekdays: {1}).problem, isNull);
        expect(
          const RepeatDraft(mode: RepeatKind.afterCompletion).problem,
          isNull,
        );
      },
    );

    test('drafts with the same rule and settings are equal', () {
      expect(
        const RepeatDraft(weekdays: {1}),
        const RepeatDraft(weekdays: {1}),
      );
      expect(
        const RepeatDraft(weekdays: {1}) == const RepeatDraft(weekdays: {2}),
        isFalse,
      );
    });
  });

  group('server adapter', () {
    test('maps a series message', () {
      final s = seriesFromPb(
        pb.Series(
          id: 's1',
          taskId: 't1',
          rrule: 'FREQ=DAILY',
          mode: 'after_completion',
          summary: '1 day after it is completed',
          nextDates: ['2026-11-09'],
          index: 2,
          isTemplate: true,
          paused: true,
          pauseReason: 'owner left',
        ),
      );
      expect(s.mode, RepeatKind.afterCompletion);
      expect((s.index, s.isTemplate, s.paused), (2, true, true));
      expect(s.nextDates, ['2026-11-09']);
      expect(s.draft?.mode, RepeatKind.afterCompletion);
    });

    test('maps refusals to failures', () {
      expect(
        mapRepeatError(GrpcError.invalidArgument('INVALID_ARGUMENT: bad rule'))
            .detail,
        'bad rule',
      );
      expect(
        mapRepeatError(GrpcError.permissionDenied()).failure,
        RepeatFailure.denied,
      );
      expect(
        mapRepeatError(GrpcError.notFound()).failure,
        RepeatFailure.notFound,
      );
      expect(
        mapRepeatError(GrpcError.unavailable()).failure,
        RepeatFailure.network,
      );
      expect(mapRepeatError(GrpcError.internal()).failure, RepeatFailure.other);
      expect(mapRepeatError(StateError('x')).failure, RepeatFailure.network);
    });

    test('says each failure in words', () {
      expect(
        repeatErrorMessage(
          const RepeatException(RepeatFailure.invalid, detail: 'bad'),
        ),
        'bad',
      );
      for (final f in RepeatFailure.values) {
        expect(repeatErrorMessage(RepeatException(f)), isNotEmpty);
      }
      expect(repeatErrorMessage(StateError('x')), isNotEmpty);
    });
  });
}
