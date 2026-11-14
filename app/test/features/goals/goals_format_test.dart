import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/goals/domain/goals.dart';

void main() {
  test('trimNumber drops trailing zeros and keeps non-numbers', () {
    expect(trimNumber('12.50'), '12.5');
    expect(trimNumber('12.00'), '12');
    expect(trimNumber('0.3333333'), '0.3333');
    expect(trimNumber('abc'), 'abc');
    expect(trimNumber('-4.0'), '-4');
  });

  test('percentOf rounds and clamps to 0..100', () {
    expect(percentOf(0.456), 46);
    expect(percentOf(0), 0);
    expect(percentOf(1.7), 100);
    expect(percentOf(-0.2), 0);
  });

  test('goalsErrorMessage falls back to the generic text', () {
    expect(goalsErrorMessage(StateError('x')), isNotEmpty);
    expect(
      goalsErrorMessage(
        const GoalsException(GoalsFailure.invalid, detail: 'Bad'),
      ),
      'Bad',
    );
  });
}
