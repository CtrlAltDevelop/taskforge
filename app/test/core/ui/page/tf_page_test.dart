import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/page/tf_danger_zone.dart';
import 'package:taskforge/core/ui/page/tf_form.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';

Widget _host(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  double scale = 1,
}) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light),
  home: Directionality(
    textDirection: dir,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  testWidgets('TfPage caps its width and centres on a wide window', (t) async {
    t.view.physicalSize = const Size(1600, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      _host(TfPage(children: const [SizedBox(key: Key('row'), height: 40)])),
    );
    final box = t.getRect(find.byKey(const Key('row')));
    expect(box.width, lessThanOrEqualTo(TfPageWidth.reading));
    expect(box.center.dx, closeTo(800, 1));
  });

  testWidgets('TfPage gutter is tighter on a phone', (t) async {
    t.view.physicalSize = const Size(390, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      _host(TfPage(children: const [SizedBox(key: Key('row'), height: 40)])),
    );
    expect(t.getRect(find.byKey(const Key('row'))).left, 12);
  });

  testWidgets('TfPageHeader shows title, description, actions and back', (
    t,
  ) async {
    var back = 0;
    await t.pumpWidget(
      _host(
        TfPageHeader(
          title: 'Members',
          description: 'People in this workspace',
          actions: const [Text('Invite')],
          onBack: () => back++,
          backTooltip: 'Back',
        ),
      ),
    );
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('People in this workspace'), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    await t.tap(find.byKey(const Key('page-back')));
    expect(back, 1);
  });

  testWidgets('TfPageHeader survives RTL, 200% text and a phone', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      _host(
        const TfPageHeader(
          title: 'عنوان بسیار طولانی برای صفحه تنظیمات فضای کار',
          description: 'توضیح',
          actions: [Text('یک'), Text('دو'), Text('سه')],
        ),
        dir: TextDirection.rtl,
        scale: 2,
      ),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('TfStickySaveBar appears only while dirty', (t) async {
    var saved = 0;
    var discarded = 0;
    Widget bar(bool dirty) => _host(
      TfStickySaveBar(
        dirty: dirty,
        onSave: () => saved++,
        saveLabel: 'Save',
        onDiscard: () => discarded++,
        discardLabel: 'Discard',
      ),
    );
    await t.pumpWidget(bar(false));
    expect(find.text('Save'), findsNothing);
    await t.pumpWidget(bar(true));
    await t.tap(find.text('Save'));
    await t.tap(find.text('Discard'));
    expect([saved, discarded], [1, 1]);
  });

  testWidgets('TfFormField shows the error instead of the helper', (t) async {
    Widget field(String? error) => _host(
      TfFormField(
        label: 'Slug',
        helper: 'Used in links',
        error: error,
        child: const TfTextField(),
      ),
    );
    await t.pumpWidget(field(null));
    expect(find.text('Used in links'), findsOneWidget);
    await t.pumpWidget(field('Taken'));
    expect(find.text('Used in links'), findsNothing);
    expect(find.text('Taken'), findsOneWidget);
    expect(find.text('Slug'), findsOneWidget);
  });

  testWidgets('TfFormSection lays out title, description and children', (
    t,
  ) async {
    await t.pumpWidget(
      _host(
        const TfFormSection(
          title: 'Profile',
          description: 'Shown to others',
          children: [Text('one'), Text('two')],
        ),
      ),
    );
    for (final s in ['Profile', 'Shown to others', 'one', 'two']) {
      expect(find.text(s), findsOneWidget);
    }
  });

  group('typed confirm', () {
    Future<bool?> open(
      WidgetTester t, {
      required Future<void> Function() act,
    }) async {
      bool? result;
      await t.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showTfTypedConfirm(
                context,
                title: 'Delete?',
                phrase: 'Acme',
                promptLabel: 'Type Acme',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
                fieldKey: const Key('f'),
                confirmKey: const Key('ok'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await act();
      await t.pumpAndSettle();
      return result;
    }

    testWidgets('confirm is disabled until the phrase matches', (t) async {
      final r = await open(
        t,
        act: () async {
          await t.enterText(find.byKey(const Key('f')), 'Acm');
          await t.pump();
          await t.tap(find.byKey(const Key('ok')), warnIfMissed: false);
          await t.pumpAndSettle();
          expect(find.text('Delete?'), findsOneWidget);
          await t.enterText(find.byKey(const Key('f')), 'Acme');
          await t.pump();
          await t.tap(find.byKey(const Key('ok')));
        },
      );
      expect(r, isTrue);
    });

    testWidgets('cancel resolves to false', (t) async {
      final r = await open(t, act: () => t.tap(find.text('Cancel')));
      expect(r, isFalse);
    });
  });

  testWidgets('TfDangerZone fires its action', (t) async {
    var n = 0;
    await t.pumpWidget(
      _host(
        TfDangerZone(
          title: 'Danger zone',
          description: 'Cannot be undone',
          actions: [
            TfDangerAction(
              label: 'Delete workspace',
              description: 'Removes everything',
              buttonKey: const Key('del'),
              onPressed: () => n++,
            ),
          ],
        ),
      ),
    );
    await t.tap(find.byKey(const Key('del')));
    expect(n, 1);
    expect(find.text('Removes everything'), findsOneWidget);
  });
}
