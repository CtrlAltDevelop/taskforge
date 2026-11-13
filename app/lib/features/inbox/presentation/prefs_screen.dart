import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/application/push.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/inbox/domain/timezones.dart';
import 'package:taskforge/features/inbox/presentation/push_prompt.dart';

/// Which kinds of event reach this person by which channel, when they may be
/// disturbed and what time zone that is in.
class NotificationPrefsScreen extends ConsumerWidget {
  const NotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.grpENotifSettings)),
      body: switch (prefs) {
        AsyncData(:final value) => _Body(prefs: value),
        AsyncError(:final error) => Center(
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  inboxErrorMessage(error, context.l10n),
                  key: const Key('prefs-error'),
                ),
                TextButton(
                  key: const Key('retry-prefs'),
                  onPressed: () => ref.invalidate(prefsProvider),
                  child: Text(context.l10n.grpERetry),
                ),
              ],
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.prefs});

  final Prefs prefs;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  late final _zone = TextEditingController(
    text: widget.prefs.settings.timezone,
  );
  late var _savedZone = widget.prefs.settings.timezone;
  String? _zoneError;
  String? _quietError;

  @override
  void dispose() {
    _zone.dispose();
    super.dispose();
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Runs [action], saying in words what went wrong; false when it failed.
  Future<bool> _guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on Object catch (e) {
      if (mounted) _say(inboxErrorMessage(e, context.l10n));
      return false;
    }
  }

  PrefsNotifier get _notifier => ref.read(prefsProvider.notifier);

  Future<void> _setRow(PrefRow row) => _guard(() => _notifier.setPref(row));

  /// Turning push on explains it first and asks the system once.
  Future<void> _setPush(PrefRow row, bool on) async {
    if (on && ref.read(pushPermissionProvider) != true) {
      if (!await explainPush(context) || !mounted) return;
      final granted = await ref.read(pushPermissionProvider.notifier).ask();
      if (!mounted) return;
      if (!granted) {
        _say(context.l10n.grpEPushOffNotice);
      }
    }
    await _setRow(row.copyWith(push: on));
  }

  Future<bool> _saveSettings(InboxSettings settings) =>
      _guard(() => _notifier.setSettings(settings));

  Future<void> _saveZone(String name) async {
    final zone = name.trim();
    if (!isValidTimezone(zone)) {
      setState(() => _zoneError = context.l10n.grpEZoneInvalid);
      return;
    }
    setState(() => _zoneError = null);
    // Submitting and leaving the field both come here: once is enough.
    if (zone != _savedZone) {
      final before = _savedZone;
      _savedZone = zone;
      final saved = await _saveSettings(
        widget.prefs.settings.copyWith(timezone: zone),
      );
      if (!saved) {
        _savedZone = before; // refused: try the same zone again
      }
    }
  }

  Future<void> _pickQuiet({required bool start}) async {
    final settings = widget.prefs.settings;
    final current = parseHhmm(start ? settings.quietStart : settings.quietEnd);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current?.hour ?? (start ? 22 : 7),
        minute: current?.minute ?? 0,
      ),
    );
    if (picked == null || !mounted) return;
    final text = hhmm(picked.hour, picked.minute);
    final next = start
        ? settings.copyWith(quietStart: text)
        : settings.copyWith(quietEnd: text);
    await _setQuiet(next);
  }

  Future<void> _setQuiet(InboxSettings next) async {
    if (next.quietOn && next.quietStart == next.quietEnd) {
      setState(() => _quietError = context.l10n.grpEQuietDifferent);
      return;
    }
    setState(() => _quietError = null);
    await _saveSettings(next);
  }

  Future<void> _toggleQuiet(bool on) async {
    final settings = widget.prefs.settings;
    if (!on) {
      setState(() => _quietError = null);
      await _saveSettings(settings.copyWith(quietStart: '', quietEnd: ''));
      return;
    }
    await _setQuiet(
      settings.copyWith(
        quietStart: settings.quietStart.isEmpty ? '22:00' : settings.quietStart,
        quietEnd: settings.quietEnd.isEmpty ? '07:00' : settings.quietEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.prefs.settings;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.l10n.grpEWhatReachesYou,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final row in widget.prefs.rows)
          Card(
            key: Key('pref-${row.eventType}'),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                    child: Text(row.label, style: theme.textTheme.titleSmall),
                  ),
                  SwitchListTile(
                    key: Key('pref-inbox-${row.eventType}'),
                    title: Text(context.l10n.grpEInbox),
                    value: row.inbox,
                    onChanged: (v) => _setRow(row.copyWith(inbox: v)),
                  ),
                  SwitchListTile(
                    key: Key('pref-push-${row.eventType}'),
                    title: Text(context.l10n.grpEPush),
                    value: row.push,
                    onChanged: (v) => _setPush(row, v),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(context.l10n.grpEEmail),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SegmentedButton<EmailMode>(
                            key: Key('pref-email-${row.eventType}'),
                            showSelectedIcon: false,
                            segments: [
                              for (final m in EmailMode.values)
                                ButtonSegment(
                                  value: m,
                                  label: Text(m.labelIn(context.l10n)),
                                ),
                            ],
                            selected: {row.email},
                            onSelectionChanged: (s) =>
                                _setRow(row.copyWith(email: s.first)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(context.l10n.grpEQuietHours, style: theme.textTheme.titleMedium),
        SwitchListTile(
          key: const Key('quiet-switch'),
          title: Text(context.l10n.grpEQuietHold),
          subtitle: Text(context.l10n.grpEQuietHoldSub),
          value: settings.quietOn,
          onChanged: _toggleQuiet,
        ),
        if (settings.quietOn)
          Row(
            children: [
              Expanded(
                child: ListTile(
                  key: const Key('quiet-start'),
                  title: Text(context.l10n.grpEFrom),
                  subtitle: Text(context.localDigits(settings.quietStart)),
                  onTap: () => _pickQuiet(start: true),
                ),
              ),
              Expanded(
                child: ListTile(
                  key: const Key('quiet-end'),
                  title: Text(context.l10n.grpEUntil),
                  subtitle: Text(context.localDigits(settings.quietEnd)),
                  onTap: () => _pickQuiet(start: false),
                ),
              ),
            ],
          ),
        if (_quietError != null)
          Semantics(
            liveRegion: true,
            child: Text(
              _quietError!,
              key: const Key('quiet-error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          context.l10n.grpETimeZoneDigest,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: settings.timezone),
          optionsBuilder: (value) {
            final q = value.text.trim().toLowerCase();
            return commonTimezones.keys.where(
              (z) => z.toLowerCase().contains(q),
            );
          },
          onSelected: _saveZone,
          fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
            key: const Key('timezone-field'),
            controller: controller,
            focusNode: focus,
            decoration: InputDecoration(
              labelText: context.l10n.grpETimeZone,
              helperText: context.l10n.grpETimeZoneHelper,
              errorText: _zoneError,
            ),
            onSubmitted: _saveZone,
            onEditingComplete: () => _saveZone(controller.text),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const Key('timezone-device'),
            icon: const Icon(Icons.phone_android),
            label: Text(context.l10n.grpEUseDeviceZone),
            onPressed: () {
              final zone = timezoneForOffset(DateTime.now().timeZoneOffset);
              if (zone == null) {
                _say(context.l10n.grpETypeZone);
                return;
              }
              _saveZone(zone);
            },
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          key: const Key('digest-hour'),
          initialValue: settings.digestHour,
          decoration: InputDecoration(labelText: context.l10n.grpEDigestAt),
          items: [
            for (var h = 0; h < 24; h++)
              DropdownMenuItem(value: h, child: Text(hhmm(h, 0))),
          ],
          onChanged: (h) {
            if (h != null) _saveSettings(settings.copyWith(digestHour: h));
          },
        ),
      ],
    );
  }
}
