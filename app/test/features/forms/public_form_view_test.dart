import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/forms/presentation/public_form_view.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

PublicQuestion _title({bool required = true}) => PublicQuestion(
  id: 'q1',
  kind: QuestionKind.title,
  label: 'Summary',
  help: '',
  required: required,
  type: '',
  options: const [],
  maxFiles: 0,
);

PublicForm _form({bool requireEmail = false, bool required = true}) =>
    PublicForm(
      name: 'Bug report',
      description: '',
      brandColor: '',
      logoUrl: '',
      requireEmail: requireEmail,
      offersUpdates: false,
      questions: [_title(required: required)],
      captcha: null,
      maxFiles: 0,
      maxFileBytes: 0,
    );

Future<List<FormAnswers>> _pump(WidgetTester tester, PublicForm form) async {
  final sent = <FormAnswers>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: PublicFormView(
            form: form,
            onSubmit: (answers) async {
              sent.add(answers);
              return 'REF-1';
            },
          ),
        ),
      ),
    ),
  );
  return sent;
}

void main() {
  test('brandColorOf accepts only #RRGGBB', () {
    expect(brandColorOf('#ff0000'), const Color(0xFFFF0000));
    expect(brandColorOf('ff0000'), isNull);
    expect(brandColorOf('#fff'), isNull);
    expect(brandColorOf(''), isNull);
  });

  testWidgets('a required question left empty blocks the send', (tester) async {
    final sent = await _pump(tester, _form());
    await tester.tap(find.byKey(const Key('form-submit')));
    await tester.pump();
    expect(find.text('This is required.'), findsOneWidget);
    expect(sent, isEmpty);
  });

  testWidgets('an email without @ is refused; a required email must be given', (
    tester,
  ) async {
    final sent = await _pump(tester, _form(requireEmail: true));
    await tester.enterText(find.byKey(const Key('form-q-q1')), 'Broken');
    await tester.tap(find.byKey(const Key('form-submit')));
    await tester.pump();
    expect(find.text('This is required.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('form-email')), 'nope');
    await tester.tap(find.byKey(const Key('form-submit')));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(sent, isEmpty);
  });

  testWidgets('a valid form sends trimmed answers and shows the reference', (
    tester,
  ) async {
    final sent = await _pump(tester, _form());
    await tester.enterText(find.byKey(const Key('form-q-q1')), '  Broken  ');
    await tester.enterText(find.byKey(const Key('form-email')), 'a@b.co');
    await tester.tap(find.byKey(const Key('form-submit')));
    await tester.pumpAndSettle();

    expect(sent.single.values, {'q1': 'Broken'});
    expect(sent.single.email, 'a@b.co');
    expect(find.textContaining('REF-1'), findsOneWidget);
    expect(find.byKey(const Key('form-another')), findsOneWidget);
  });
}
