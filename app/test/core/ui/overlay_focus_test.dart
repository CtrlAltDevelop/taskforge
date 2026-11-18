import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_presenter.dart';

/// A page with one button that opens a layer; its focus node is exposed so
/// the tests can see focus come back to it.
class _Page extends StatefulWidget {
  const _Page(this.open);
  final Future<void> Function(BuildContext) open;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  final node = FocusNode(debugLabel: 'opener');

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        focusNode: node,
        onPressed: () => widget.open(context),
        child: const Text('open'),
      ),
    ),
  );
}

Widget _app(Future<void> Function(BuildContext) open) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light),
  home: _Page(open),
);

Future<void> _dialog(BuildContext c) => showTfDialog<void>(
  c,
  title: 'Dialog',
  body: const TextField(key: Key('field')),
  actions: [
    TfButton(key: const Key('cancel'), label: 'Cancel', onPressed: () {}),
    TfButton(key: const Key('ok'), label: 'OK', onPressed: () {}),
  ],
);

Future<void> _sheet(BuildContext c) => showTfSideSheet<void>(
  c,
  title: 'Sheet',
  closeTooltip: 'Close',
  body: Center(
    child: TextButton(
      key: const Key('open-dialog'),
      onPressed: () => _dialog(c),
      child: const Text('more'),
    ),
  ),
);

Future<void> _bottom(BuildContext c) =>
    showTfBottomSheet<void>(c, body: const TextField(key: Key('field')));

Future<void> _esc(WidgetTester t) async {
  await t.sendKeyEvent(LogicalKeyboardKey.escape);
  await t.pumpAndSettle();
}

Future<void> _openFrom(
  WidgetTester t,
  Future<void> Function(BuildContext) open,
) async {
  await t.pumpWidget(_app(open));
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

/// Whether the focused widget sits inside what [outer] finds.
bool _focusIsIn(WidgetTester t, Finder outer) {
  final target = t.element(outer.first);
  final focus = FocusManager.instance.primaryFocus?.context;
  if (focus == null) return false;
  if (identical(focus, target)) return true;
  var found = false;
  focus.visitAncestorElements((e) {
    if (identical(e, target)) found = true;
    return !found;
  });
  return found;
}

FocusNode _openerNode(WidgetTester t) =>
    t.widget<TextButton>(find.widgetWithText(TextButton, 'open')).focusNode!;

bool _focusOnPage() =>
    FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<_Page>() !=
    null;

void main() {
  for (final (name, open, shown) in [
    ('dialog', _dialog, 'Dialog'),
    ('side sheet', _sheet, 'Sheet'),
    ('bottom sheet', _bottom, ''),
  ]) {
    testWidgets('$name: Esc closes it and focus returns to the opener', (
      t,
    ) async {
      await t.pumpWidget(_app(open));
      _openerNode(t).requestFocus();
      await t.pump();
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      final up = shown.isEmpty
          ? find.byKey(const Key('field'))
          : find.text(shown);
      expect(up, findsOneWidget);

      await _esc(t);

      expect(up, findsNothing);
      expect(_openerNode(t).hasFocus, isTrue);
    });
  }

  testWidgets('Tab stays inside a dialog and wraps around', (t) async {
    await _openFrom(t, _dialog);
    // Walk well past the number of controls: focus must never reach the page.
    for (var i = 0; i < 8; i++) {
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      expect(
        _focusIsIn(t, find.byType(Dialog)),
        isTrue,
        reason: 'tab $i left the dialog',
      );
    }
  });

  testWidgets('Shift+Tab also stays inside a side sheet', (t) async {
    await _openFrom(t, _sheet);
    for (var i = 0; i < 6; i++) {
      await t.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await t.pump();
      expect(FocusManager.instance.primaryFocus, isNotNull);
      expect(_focusOnPage(), isFalse, reason: 'shift+tab $i reached the page');
    }
  });

  testWidgets('Esc closes only the top layer: dialog over a sheet', (t) async {
    await _openFrom(t, _sheet);
    await t.tap(find.byKey(const Key('open-dialog')));
    await t.pumpAndSettle();
    expect(find.text('Dialog'), findsOneWidget);
    expect(find.text('Sheet'), findsOneWidget);

    await _esc(t);
    expect(find.text('Dialog'), findsNothing);
    expect(find.text('Sheet'), findsOneWidget);

    await _esc(t);
    expect(find.text('Sheet'), findsNothing);
  });

  testWidgets('closing the dialog hands focus back into the sheet', (t) async {
    await _openFrom(t, _sheet);
    await t.tap(find.byKey(const Key('open-dialog')));
    await t.pumpAndSettle();
    await _esc(t);
    expect(FocusManager.instance.primaryFocus, isNotNull);
    expect(_focusOnPage(), isFalse, reason: 'focus fell back to the page');
  });

  testWidgets('task peek: Esc closes only the top layer and focus returns', (
    t,
  ) async {
    final navKey = GlobalKey<NavigatorState>();
    var closed = 0;
    final presenter = TaskPresenter(
      navigator: () => navKey.currentState!,
      builder: (context, current, kind) => Material(
        child: Center(
          child: TextButton(
            key: const Key('confirm'),
            onPressed: () => _dialog(context),
            child: const Text('Task'),
          ),
        ),
      ),
      onClosed: () => closed++,
      barrierColor: () => const Color(0x66000000),
      barrierLabel: () => 'Task',
    );
    await t.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        theme: buildAppTheme(brightness: Brightness.light),
        home: _Page(
          (_) async => presenter.show('t1', TaskPresentationKind.peek),
        ),
      ),
    );
    _openerNode(t).requestFocus();
    await t.pump();
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm')));
    await t.pumpAndSettle();
    expect(find.text('Dialog'), findsOneWidget);

    await _esc(t);
    expect(find.text('Dialog'), findsNothing);
    expect(find.text('Task'), findsOneWidget);
    expect(closed, 0);

    await _esc(t);
    expect(find.text('Task'), findsNothing);
    expect(closed, 1);
    expect(_openerNode(t).hasFocus, isTrue);
  });
}
