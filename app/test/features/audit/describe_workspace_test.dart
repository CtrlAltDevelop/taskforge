import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/audit/domain/describe.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import 'fakes.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  String say(String action, [Map<String, Object?> changes = const {}]) =>
      describeEntry(entry(1, action, changes: changes), const {}, en);

  test(
    'token, webhook, form, template and security actions read as phrases',
    () {
      expect(say('token.created'), 'created an API token');
      expect(say('token.revoked'), 'revoked an API token');
      expect(say('webhook.created'), 'added a webhook');
      expect(say('webhook.updated'), 'changed a webhook');
      expect(say('webhook.deleted'), 'deleted a webhook');
      expect(say('webhook.disabled'), contains('switched off'));
      expect(say('form.created'), 'created an intake form');
      expect(say('form.submitted'), 'submitted an intake form');
      expect(say('template.applied'), 'used a template');
      expect(say('security.sso_configured'), 'set up single sign-on');
      expect(say('security.policy_changed'), 'changed the security policy');
      expect(say('security.sso_member_joined'), contains('single sign-on'));
    },
  );

  test('goal folders name the folder, key results name the key result', () {
    expect(
      say('goal.folder_created', {'name': 'Q4'}),
      'created the goal folder “Q4”',
    );
    expect(
      say('goal.folder_renamed', {'from': 'Q4', 'name': 'Q4 2026'}),
      'renamed the goal folder “Q4” to “Q4 2026”',
    );
    expect(
      say('goal.folder_deleted', {'name': 'Q4'}),
      'deleted the goal folder “Q4”',
    );
    expect(
      say('goal.kr_created', {'key_result': 'Signups'}),
      'added the key result “Signups”',
    );
    expect(
      say('goal.checked_in', {'key_result': 'Signups', 'value': '40'}),
      'checked in “40” on “Signups”',
    );
  });

  test('workload actions are tailored, not humanized', () {
    for (final action in [
      'workload.capacity.set',
      'workload.time_off.create',
      'workload.holiday.delete',
      'workload.estimate.set',
    ]) {
      expect(say(action), isNot(contains('workload')), reason: action);
    }
  });

  test('an unknown action still falls back to a readable phrase', () {
    expect(say('webhook.exploded'), isNot(contains('added a webhook')));
  });

  test('the phrases are translated', () {
    final fa = lookupAppLocalizations(const Locale('fa'));
    final text = describeEntry(
      entry(1, 'goal.folder_created', changes: {'name': 'Q4'}),
      const {},
      fa,
    );
    expect(text, fa.audGoalFolderCreated('“Q4”'));
    expect(text, isNot(en.audGoalFolderCreated('“Q4”')));
  });
}
