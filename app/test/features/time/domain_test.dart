import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/features/time/data/time_client.dart';
import 'package:taskforge/features/time/domain/time.dart';

import 'fakes.dart';

void main() {
  test('durations read the way people write them', () {
    expect(parseDuration('1h 30m'), 5400);
    expect(parseDuration('90m'), 5400);
    expect(parseDuration('1.5h'), 5400);
    expect(parseDuration('1:30'), 5400);
    expect(parseDuration('45'), 2700);
    expect(parseDuration(' 2H '), 7200);
    expect(parseDuration('15m'), 900);
    for (final bad in [
      '',
      '0',
      '0m',
      'abc',
      '1:75',
      '-5',
      'h',
      '99999999999999999999',
      '99999999999999999999h',
      '9999999:00',
    ]) {
      expect(parseDuration(bad), isNull, reason: bad);
    }
  });

  test('durations are shown as totals and as a clock', () {
    expect(durationText(0), '0m');
    expect(durationText(2700), '45m');
    expect(durationText(7500), '2h 05m');
    expect(clockText(3725), '1:02:05');
    expect(clockText(-4), '0:00:00');
  });

  test('the elapsed time is the server figure plus what passed since', () {
    final received = DateTime(2026, 11, 11, 12);
    final state = TimerState(
      entry: TimeEntry(
        id: 'e',
        taskId: 'a',
        projectId: 'p',
        key: 'WEB-1',
        title: 'T',
        userId: 'u',
        userName: 'U',
        startedAt: DateTime.utc(2000),
        durationSec: 600, // the server said ten minutes at that moment
      ),
      receivedAt: received,
    );

    expect(state.elapsedAt(received), 600);
    expect(state.elapsedAt(received.add(const Duration(seconds: 7))), 607);
    expect(state.elapsedAt(received.subtract(const Duration(hours: 1))), 600);
    expect(TimerState(receivedAt: received).elapsedAt(received), 0);
  });

  test('days are added by the calendar, so a daylight-saving week stays on Mondays', () {
    // Whatever zone the tests run in, midnight stays midnight.
    for (
      var start = DateTime(2026, 1, 5);
      start.year == 2026;
      start = addDays(start, 7)
    ) {
      expect(start.weekday, DateTime.monday);
      expect((start.hour, start.minute), (0, 0));
    }
    expect(addDays(DateTime(2026, 10, 26), 7), DateTime(2026, 11, 2));
    expect(addDays(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
  });

  test('a week starts on Monday', () {
    expect(weekStartOf(DateTime(2026, 11, 11)), DateTime(2026, 11, 9));
    expect(weekStartOf(DateTime(2026, 11, 9, 23)), DateTime(2026, 11, 9));
    expect(weekStartOf(DateTime(2026, 11, 15)), DateTime(2026, 11, 9));
    expect(isoDate(DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('summaries know when the estimate is passed', () {
    expect(const TimeSummary().hasEstimate, isFalse);
    expect(const TimeSummary(estimateSec: 60, loggedSec: 61).over, isTrue);
    expect(const TimeSummary(estimateSec: 60, loggedSec: 60).over, isFalse);
  });

  test('server refusals become what the screens can say', () {
    expect(
      mapTimeError(GrpcError.invalidArgument('VALIDATION_ERROR: Off')),
      isA<TimeException>().having((e) => e.detail, 'detail', 'Off'),
    );
    expect(
      mapTimeError(GrpcError.permissionDenied()).failure,
      TimeFailure.denied,
    );
    expect(mapTimeError(GrpcError.notFound()).failure, TimeFailure.notFound);
    expect(mapTimeError(GrpcError.unavailable()).failure, TimeFailure.network);
    expect(mapTimeError(GrpcError.internal()).failure, TimeFailure.other);
    expect(
      timeErrorMessage(const TimeException(TimeFailure.denied)),
      contains('access'),
    );
  });

  test('the fake keeps one timer, like the server', () async {
    final fake = FakeTimeClient();
    await fake.start('w', 'p1', 'a');
    final second = await fake.start('w', 'p1', 'b');

    expect(second.stopped?.taskId, 'a');
    expect(fake.entries_.where((e) => e.running).length, 1);
  });
}
