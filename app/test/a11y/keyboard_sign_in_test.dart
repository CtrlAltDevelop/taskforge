import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';

import '../features/workspaces/fakes.dart' show MockAuthApi;

/// Phase 49 keyboard-only walk, step 1 (docs/accessibility-checklist.md):
/// Tab goes language menu, field, password, Sign in; Enter on Sign in with empty fields
/// shows the errors and keeps focus on the form.
Future<void> _openSignIn(WidgetTester t) async {
  final session = AuthSession(api: MockAuthApi(), store: MemoryTokenStore());
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        syncClientProvider.overrideWithValue(null),
      ],
      child: const TaskForgeApp(),
    ),
  );
  await t.pumpAndSettle();
  expect(find.byType(SignInScreen), findsOneWidget);
}

/// The text field or button that holds focus now, as a finder-friendly type.
Type? _focusedKind() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  if (context.findAncestorWidgetOfExactType<EditableText>() != null) {
    return EditableText;
  }
  return context.widget.runtimeType;
}

Future<void> _tab(WidgetTester t, {bool shift = false}) async {
  if (shift) await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await t.sendKeyEvent(LogicalKeyboardKey.tab);
  if (shift) await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await t.pump();
}

void main() {
  testWidgets('sign in: Tab walks fields then the submit button', (t) async {
    await _openSignIn(t);
    final stops = <Object?>[];
    for (var i = 0; i < 3; i++) {
      await _tab(t);
      stops.add(_focusedKind());
    }
    expect(stops[0], isNot(EditableText), reason: 'first stop is the app bar');
    expect(stops[1], EditableText, reason: 'second stop is the identity field');
    expect(stops[2], EditableText, reason: 'third stop is the password');
    expect(
      find.byKey(const Key('submit')).evaluate().isNotEmpty,
      isTrue,
      reason: 'the submit button exists to be reached',
    );
  });

  testWidgets('sign in: Shift+Tab goes back to the previous field', (t) async {
    await _openSignIn(t);
    await _tab(t);
    await _tab(t);
    await _tab(t);
    final second = FocusManager.instance.primaryFocus;
    await _tab(t, shift: true);
    expect(FocusManager.instance.primaryFocus, isNot(same(second)));
    expect(_focusedKind(), EditableText);
  });

  testWidgets('sign in: Enter on an empty form shows errors, no crash', (
    t,
  ) async {
    await _openSignIn(t);
    // language menu, identity, password, show-password, Sign in
    for (var i = 0; i < 5; i++) {
      await _tab(t);
    }
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(_focusedKind(), isNotNull, reason: 'focus stays on the form');
  });
}
