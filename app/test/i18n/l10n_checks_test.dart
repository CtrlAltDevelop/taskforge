import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The two CI checks behind "no hardcoded user-visible strings" and "missing
/// keys fail": every translation has every key, and the number of hardcoded
/// strings in a file can only go down.
///
/// Fixing a file lowers its number: run
/// `UPDATE_L10N_BASELINE=1 flutter test test/i18n` to record it.

const _baselinePath = 'test/i18n/hardcoded_baseline.json';

// Text('...'), plus the named arguments that put words on screen.
final _literal = RegExp(
  r'''(?:Text\(\s*|(?:label|labelText|hintText|helperText|tooltip|title|subtitle|semanticLabel|helpText)\s*:\s*(?:const\s+Text\(\s*)?)(?:'([^'\n]*[A-Za-z][^'\n]*)'|"([^"\n]*[A-Za-z][^"\n]*)")''',
);

/// A string that is not words: a key, a route, a file name, interpolation only.
bool _isUserFacing(String text) =>
    text.contains(RegExp(r'[A-Za-z]{3,}')) &&
    !text.startsWith('/') &&
    !text.contains(RegExp(r'^[a-z0-9_.\-:]+$')) &&
    !RegExp(r'^[A-Z0-9_]+$').hasMatch(text) && // an error code
    !text.startsWith(r'$');

Map<String, int> _scan() {
  final counts = <String, int>{};
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll(r'\', '/').contains('lib/gen/'))
      .where((f) => !f.path.replaceAll(r'\', '/').contains('lib/l10n/'));
  for (final file in files) {
    final source = file.readAsStringSync();
    final n = _literal.allMatches(source).where((m) {
      final text = m.group(1) ?? m.group(2) ?? '';
      return _isUserFacing(text);
    }).length;
    if (n > 0) counts[file.path.replaceAll(r'\', '/')] = n;
  }
  return Map.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('translations', () {
    final template = _arb('en');
    final keys = template.keys.where((k) => !k.startsWith('@')).toSet();

    for (final code in ['fa', 'ar', 'ps']) {
      test('$code has every key of the English template and nothing extra', () {
        final other = _arb(code);
        final have = other.keys.where((k) => !k.startsWith('@')).toSet();
        expect(keys.difference(have), isEmpty, reason: 'missing in $code');
        expect(have.difference(keys), isEmpty, reason: 'unknown in $code');
      });

      test('$code has no empty values', () {
        final other = _arb(code);
        for (final key in keys) {
          expect((other[key] as String).trim(), isNotEmpty, reason: key);
        }
      });

      test('$code keeps the placeholders of the English message', () {
        final other = _arb(code);
        final placeholder = RegExp(r'\{(\w+)(?:,|\})');
        // A plural branch like `one{task}` holds words, not a placeholder.
        final branch = RegExp(r'(?:=\d+|zero|one|two|few|many|other)\{\w+\}');
        String bare(String m) => m.replaceAll(branch, '');
        for (final key in keys) {
          final wanted = placeholder
              .allMatches(bare(template[key] as String))
              .map((m) => m.group(1))
              .toSet();
          final got = placeholder
              .allMatches(bare(other[key] as String))
              .map((m) => m.group(1))
              .toSet();
          expect(got, wanted, reason: '$code/$key');
        }
      });
    }
  });

  group('hardcoded strings', () {
    test('no file has more hardcoded strings than its recorded baseline', () {
      final now = _scan();
      if (Platform.environment['UPDATE_L10N_BASELINE'] == '1') {
        File(_baselinePath).writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(now)}\n',
        );
        return;
      }
      final baseline = (jsonDecode(
        File(_baselinePath).readAsStringSync(),
      ) as Map<String, dynamic>).cast<String, int>();
      final worse = <String>[
        for (final e in now.entries)
          if (e.value > (baseline[e.key] ?? 0))
            '${e.key}: ${e.value} hardcoded (allowed ${baseline[e.key] ?? 0}) - '
                'use context.l10n and add the key to the .arb files',
      ];
      expect(worse, isEmpty);
    });

    test('screens already moved to l10n stay free of hardcoded strings', () {
      final now = _scan();
      for (final done in [
        'lib/features/account/home_screen.dart',
        'lib/features/account/language_screen.dart',
        'lib/features/account/language_menu.dart',
        'lib/features/auth/sign_in_screen.dart',
        'lib/features/auth/sign_up_screen.dart',
        'lib/features/auth/forgot_password_screen.dart',
        'lib/features/auth/reset_password_screen.dart',
        'lib/features/auth/change_password_screen.dart',
        'lib/features/auth/credentials_form.dart',
        'lib/features/auth/auth_form.dart',
        'lib/features/auth/validators.dart',
        'lib/core/i18n/date_picker.dart',
        'lib/features/tasks/presentation/bulk_bar.dart',
        'lib/features/tasks/presentation/links_panel.dart',
        'lib/features/tasks/presentation/list_lookups.dart',
        'lib/features/tasks/presentation/presence_strip.dart',
        'lib/features/tasks/presentation/subtask_dialogs.dart',
        'lib/features/tasks/presentation/subtasks_panel.dart',
        'lib/features/tasks/presentation/table_cells.dart',
        'lib/features/tasks/presentation/task_actions.dart',
        'lib/features/tasks/presentation/task_fields_panel.dart',
        'lib/features/tasks/presentation/task_section.dart',
        'lib/features/tasks/presentation/task_table.dart',
        'lib/features/tasks/presentation/task_trash_screen.dart',
        'lib/features/board/presentation/board_card.dart',
        'lib/features/board/presentation/board_column.dart',
        'lib/features/board/presentation/board_toolbar.dart',
        'lib/features/calendar/presentation/calendar_agenda.dart',
        'lib/features/calendar/presentation/calendar_ghosts.dart',
        'lib/features/calendar/presentation/calendar_grid.dart',
        'lib/features/calendar/presentation/calendar_tray.dart',
        'lib/features/calendar/presentation/calendar_view.dart',
        'lib/features/calendar/presentation/workspace_calendar_screen.dart',
        'lib/features/search/domain/search.dart',
        'lib/features/search/presentation/search_overlay.dart',
        'lib/features/shortcuts/presentation/cheat_sheet.dart',
        'lib/features/shortcuts/presentation/command_palette.dart',
        'lib/features/shortcuts/presentation/prompt_dialog.dart',
        'lib/features/shortcuts/presentation/shortcut_host.dart',
        'lib/features/automations/presentation/dry_run_dialog.dart',
        'lib/features/automations/presentation/rule_builder.dart',
        'lib/features/automations/presentation/runs_panel.dart',
        'lib/features/filters/presentation/filter_bar.dart',
        'lib/features/filters/presentation/filter_panel.dart',
        'lib/features/imports/presentation/export_dialog.dart',
        'lib/features/imports/presentation/problems_list.dart',
        'lib/features/sprints/presentation/planning_panes.dart',
        'lib/features/projects/presentation/archive_zone.dart',
        'lib/features/projects/presentation/archived_banner.dart',
        'lib/features/projects/presentation/archived_screen.dart',
        'lib/features/projects/presentation/create_project_dialog.dart',
        'lib/features/projects/presentation/features_section.dart',
        'lib/features/projects/presentation/general_section.dart',
        'lib/features/projects/presentation/members_section.dart',
        'lib/features/projects/presentation/private_projects_screen.dart',
        'lib/features/projects/presentation/project_look_picker.dart',
        'lib/features/projects/presentation/project_screen.dart',
        'lib/features/projects/presentation/project_settings_screen.dart',
        'lib/features/attachments/presentation/attach_buttons.dart',
        'lib/features/attachments/presentation/attachment_access.dart',
        'lib/features/attachments/presentation/attachment_tiles.dart',
        'lib/features/attachments/presentation/attachment_viewer.dart',
        'lib/features/attachments/presentation/attachments_section.dart',
        'lib/features/inbox/domain/inbox.dart',
        'lib/features/inbox/presentation/inbox_screen.dart',
        'lib/features/inbox/presentation/push_prompt.dart',
        'lib/features/inbox/presentation/snooze_sheet.dart',
        'lib/features/recurrence/presentation/repeat_section.dart',
        'lib/core/charts/dashboard_charts.dart',
        'lib/core/offline/presentation/offline_banner.dart',
        'lib/core/sync/presentation/connection_status.dart',
        'lib/features/workflows/presentation/merge_banner.dart',
        'lib/features/workflows/presentation/status_card.dart',
        'lib/features/workflows/presentation/status_dialogs.dart',
        'lib/features/workflows/presentation/validation_panel.dart',
        'lib/features/workflows/presentation/workflow_graph.dart',
        'lib/features/workflows/presentation/workflow_screen.dart',
        'lib/features/dashboards/presentation/drill_sheet.dart',
        'lib/features/dashboards/presentation/widget_body.dart',
        'lib/features/dashboards/presentation/widget_card.dart',
        'lib/features/timeline/presentation/timeline_dialogs.dart',
        'lib/features/timeline/presentation/timeline_list.dart',
        'lib/features/timeline/presentation/timeline_toolbar.dart',
        'lib/features/timeline/presentation/timeline_view.dart',
        'lib/features/fields/presentation/field_input.dart',
        'lib/features/fields/presentation/fields_screen.dart',
        'lib/features/comments/presentation/comment_composer.dart',
        'lib/features/comments/presentation/comment_dialogs.dart',
        'lib/features/account/sessions_screen.dart',
        'lib/features/members/presentation/invite_dialog.dart',
        'lib/features/members/presentation/invite_screen.dart',
        'lib/features/members/presentation/members_screen.dart',
        'lib/features/members/presentation/pending_tab.dart',
        'lib/features/members/presentation/role_picker.dart',
        'lib/features/docs/presentation/block_editor.dart',
        'lib/features/docs/presentation/doc_panels.dart',
        'lib/features/docs/presentation/docs_screen.dart',
        'lib/features/docs/presentation/other_blocks.dart',
        'lib/features/docs/presentation/related_docs_panel.dart',
        'lib/features/docs/presentation/slash_menu.dart',
        'lib/features/docs/presentation/text_block.dart',
        'lib/features/workspaces/presentation/danger_zone.dart',
        'lib/features/workspaces/presentation/onboarding_screen.dart',
        'lib/features/workspaces/presentation/recently_deleted.dart',
        'lib/features/workspaces/presentation/workspace_switcher.dart',
        'lib/features/time/application/timer_notification.dart',
        'lib/features/time/presentation/time_section.dart',
        'lib/features/time/presentation/timer_chip.dart',
        'lib/features/roles/presentation/role_matrix.dart',
        'lib/features/roles/presentation/roles_screen.dart',
        'lib/features/audit/presentation/activity_section.dart',
        'lib/features/debug/debug_screen.dart',
        'lib/core/offline/presentation/offline_screen.dart',
        'lib/features/sprints/presentation/sprint_dialogs.dart',
        'lib/features/sprints/presentation/sprints_screen.dart',
        'lib/features/sprints/presentation/sprint_charts.dart',
        'lib/features/time/presentation/timesheet_screen.dart',
        'lib/features/time/presentation/entry_dialog.dart',
        'lib/features/docs/presentation/doc_dialogs.dart',
        'lib/features/docs/presentation/doc_page.dart',
        'lib/features/docs/presentation/page_tree.dart',
        'lib/features/comments/presentation/comments_section.dart',
        'lib/features/audit/presentation/audit_screen.dart',
        'lib/features/dashboards/presentation/dashboards_screen.dart',
        'lib/features/imports/presentation/import_screen.dart',
        'lib/features/imports/presentation/import_wizard.dart',
        'lib/features/imports/presentation/mapping_step.dart',
        'lib/features/automations/presentation/automations_screen.dart',
        'lib/features/tasks/presentation/list_toolbar.dart',
        'lib/features/tasks/presentation/task_detail.dart',
        'lib/features/recurrence/presentation/repeat_editor.dart',
        'lib/features/workspaces/presentation/settings_screen.dart',
        'lib/features/inbox/presentation/prefs_screen.dart',
        'lib/features/fields/presentation/field_dialogs.dart',
        'lib/features/projects/presentation/project_sidebar.dart',
        'lib/features/calendar/presentation/calendar_toolbar.dart',
        'lib/features/roles/presentation/role_dialogs.dart',
      ]) {
        expect(now[done], isNull, reason: done);
      }
    });
  });
}
