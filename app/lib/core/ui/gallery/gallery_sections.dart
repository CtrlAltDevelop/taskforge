import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/features/home/presentation/sample_badge.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_key_hint.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_progress.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

Widget _section(BuildContext context, String title, Widget child) {
  final tf = context.tf;
  return Padding(
    padding: const EdgeInsets.only(bottom: TfSpace.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tf.typography.lead.copyWith(color: tf.colors.text)),
        const SizedBox(height: TfSpace.sm),
        child,
      ],
    ),
  );
}

Widget _wrap(List<Widget> children) => Wrap(
  spacing: TfSpace.md,
  runSpacing: TfSpace.md,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: children,
);

/// Sections in the order the components are listed in the phase doc.
const _samples = {
  'en': [
    'Write the release notes',
    'In progress',
    'Assigned to you',
    'Due tomorrow',
  ],
  'fa': [
    'نوشتن یادداشت‌های انتشار',
    'در حال انجام',
    'واگذار شده به شما',
    'سررسید فردا',
  ],
  'ar': ['اكتب ملاحظات الإصدار', 'قيد التنفيذ', 'مسند إليك', 'الاستحقاق غدًا'],
};

/// The same components with real text in the chosen script (Vazirmatn fallback).
Widget _scripts(BuildContext context, String language) {
  final t = _samples[language] ?? _samples['en']!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TfPanel(
        padding: const EdgeInsets.all(TfSpace.xs),
        child: Column(
          children: [
            TfRow(
              title: t[0],
              subtitle: 'TF-12 ۱۲۳',
              leading: const TfIcon(TfIcons.todo),
              trailing: TfStatusPill(label: t[1], kind: TfStatusKind.active),
              onTap: () {},
            ),
          ],
        ),
      ),
      const SizedBox(height: TfSpace.sm),
      _wrap(
        [
              TfChip(label: t[2], onRemove: () {}, removeTooltip: t[3]),
              TfButton(label: t[3], onPressed: () {}),
              TfBanner(message: t[0], kind: TfBannerKind.info),
            ]
            .map((w) => w is TfBanner ? SizedBox(width: 320, child: w) : w)
            .toList(),
      ),
      const SizedBox(height: TfSpace.sm),
      TfTextField(label: t[2], hint: t[3]),
    ],
  );
}

List<Widget> gallerySections(
  BuildContext context, [
  String language = 'en',
]) => [
  _section(context, 'Text in the chosen language', _scripts(context, language)),
  _section(
    context,
    'Colour',
    _wrap([
      for (final i in List.generate(10, (i) => i))
        Container(width: 28, height: 28, color: context.tf.colors.category(i)),
      for (final t in [
        context.tf.colors.success,
        context.tf.colors.warning,
        context.tf.colors.danger,
        context.tf.colors.info,
        context.tf.colors.neutral,
      ])
        TfChip(label: 'Tone', tone: t),
    ]),
  ),
  _section(
    context,
    'Type',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display 28',
          style: context.tf.typography.display.copyWith(
            color: context.tf.colors.text,
          ),
        ),
        Text(
          'Title 20',
          style: context.tf.typography.title.copyWith(
            color: context.tf.colors.text,
          ),
        ),
        Text(
          'Lead 16',
          style: context.tf.typography.lead.copyWith(
            color: context.tf.colors.text,
          ),
        ),
        Text(
          'Body 14',
          style: context.tf.typography.body.copyWith(
            color: context.tf.colors.text,
          ),
        ),
        Text(
          'Label 13',
          style: context.tf.typography.label.copyWith(
            color: context.tf.colors.text,
          ),
        ),
        Text(
          'Small 12  1 234 567',
          style: context.tf.typography.tabular.copyWith(
            color: context.tf.colors.text,
          ),
        ),
        Text(
          'TF-1234',
          style: context.tf.typography.mono.copyWith(
            color: context.tf.colors.text,
          ),
        ),
      ],
    ),
  ),
  _section(
    context,
    'Icons',
    _wrap([
      for (final e in TfIcons.all.entries)
        TfIcon(e.value, size: 20, semanticLabel: e.key),
    ]),
  ),
  _section(
    context,
    'Buttons',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final v in TfButtonVariant.values)
          Padding(
            padding: const EdgeInsets.only(bottom: TfSpace.sm),
            child: _wrap([
              for (final s in TfButtonSize.values)
                TfButton(label: v.name, variant: v, size: s, onPressed: () {}),
              TfButton(
                label: 'Icon',
                icon: TfIcons.plus,
                variant: v,
                onPressed: () {},
              ),
              TfButton(
                label: 'Loading',
                variant: v,
                loading: true,
                onPressed: () {},
              ),
              TfButton(label: 'Disabled', variant: v, onPressed: null),
              TfIconButton(
                icon: TfIcons.more,
                tooltip: 'More',
                variant: v,
                onPressed: () {},
              ),
              TfIconButton(
                icon: TfIcons.star,
                tooltip: 'Selected',
                variant: v,
                selected: true,
                onPressed: () {},
              ),
            ]),
          ),
      ],
    ),
  ),
  _section(
    context,
    'Forced states (hover, focus, pressed)',
    _wrap([
      for (final state in [
        WidgetState.hovered,
        WidgetState.focused,
        WidgetState.pressed,
      ])
        TfForcedStates(
          states: {state},
          child: _wrap([
            TfButton(
              label: state.name,
              variant: TfButtonVariant.primary,
              onPressed: () {},
            ),
            TfButton(label: state.name, onPressed: () {}),
            TfChip(label: state.name, onTap: () {}),
            SizedBox(
              width: 160,
              child: TfRow(title: state.name, onTap: () {}),
            ),
            TfCheckbox(value: true, label: state.name, onChanged: (_) {}),
          ]),
        ),
    ]),
  ),
  _section(
    context,
    'Inputs',
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [
          const TfTextField(label: 'Title', hint: 'What needs doing?'),
          const SizedBox(height: TfSpace.md),
          const TfTextField(label: 'With error', errorText: 'Required'),
          const SizedBox(height: TfSpace.md),
          const TfTextField(label: 'Disabled', enabled: false),
          const SizedBox(height: TfSpace.md),
          TfSearchField(
            onChanged: (_) {},
            hint: 'Search',
            clearTooltip: 'Clear',
          ),
          const SizedBox(height: TfSpace.md),
          TfSelect<int>(
            options: const {1: 'One', 2: 'Two'},
            value: 1,
            onChanged: (_) {},
          ),
        ],
      ),
    ),
  ),
  _section(
    context,
    'Selection',
    _wrap([
      TfCheckbox(value: true, onChanged: (_) {}, label: 'Checked'),
      TfCheckbox(value: false, onChanged: (_) {}, label: 'Unchecked'),
      TfCheckbox(value: null, onChanged: (_) {}, label: 'Mixed'),
      const TfCheckbox(value: true, onChanged: null, label: 'Disabled'),
      TfToggle(value: true, onChanged: (_) {}, label: 'On'),
      TfToggle(value: false, onChanged: (_) {}, label: 'Off'),
      TfSegmented<int>(
        options: const {1: 'List', 2: 'Board', 3: 'Calendar'},
        value: 1,
        onChanged: (_) {},
      ),
    ]),
  ),
  _section(
    context,
    'Tabs',
    TfTabs(
      labels: const ['Overview', 'Activity', 'Files'],
      index: 0,
      onChanged: (_) {},
    ),
  ),
  _section(
    context,
    'Chips, tags, badges',
    _wrap([
      TfChip(label: 'Chip', onTap: () {}),
      TfChip(label: 'Selected', selected: true, onTap: () {}),
      TfChip(label: 'Removable', onRemove: () {}, removeTooltip: 'Remove'),
      const TfTag(label: 'Design', colorIndex: 1),
      const TfTag(label: 'Backend', colorIndex: 7),
      const TfBadge(count: 4),
      const TfBadge(count: 120),
      const TfBadge(),
      const SampleBadge(),
    ]),
  ),
  _section(
    context,
    'Status and priority',
    _wrap([
      for (final k in TfStatusKind.values) TfStatusPill(label: k.name, kind: k),
      for (final p in TfPriority.values)
        TfPriorityIcon(priority: p, label: p.name, showLabel: true),
    ]),
  ),
  _section(
    context,
    'People',
    _wrap([
      const TfAvatar(name: 'Mina Rahimi'),
      const TfAvatar(name: 'Omar Haddad', size: 32),
      const TfAvatarStack(
        names: [
          'Mina Rahimi',
          'Omar Haddad',
          'Sara Noori',
          'Ali Karimi',
          'Lena Aziz',
        ],
      ),
    ]),
  ),
  _section(
    context,
    'Progress',
    _wrap([
      const SizedBox(width: 200, child: TfProgressBar(value: 0.4)),
      const SizedBox(width: 200, child: TfProgressBar(value: 1)),
      const TfProgressRing(value: 0.65),
      const TfProgressRing(value: 0.65, size: 48),
    ]),
  ),
  _section(
    context,
    'Rows',
    TfPanel(
      padding: const EdgeInsets.all(TfSpace.xs),
      child: Column(
        children: [
          const TfSectionHeader(title: 'Today', count: 3),
          TfRow(
            title: 'Write release notes',
            subtitle: 'TF-12',
            leading: const TfIcon(TfIcons.todo),
            trailing: const TfAvatar(name: 'Mina Rahimi'),
            onTap: () {},
          ),
          TfRow(
            title: 'Selected row',
            selected: true,
            leading: const TfIcon(TfIcons.active),
            onTap: () {},
          ),
          const TfRow(title: 'Static row'),
          const TfTableRow(
            header: true,
            cells: [
              Expanded(child: Text('Name')),
              SizedBox(width: 80, child: Text('Due')),
            ],
          ),
          TfTableRow(
            onTap: () {},
            cells: const [
              Expanded(child: Text('Fix login')),
              SizedBox(width: 80, child: Text('12 Mar')),
            ],
          ),
        ],
      ),
    ),
  ),
  _section(
    context,
    'Menu and tooltip',
    _wrap([
      TfMenu(
        items: [
          TfMenuItem(
            label: 'Rename',
            icon: TfIcons.edit,
            shortcut: 'F2',
            onSelected: () {},
          ),
          TfMenuItem(
            label: 'Delete',
            icon: TfIcons.trash,
            danger: true,
            onSelected: () {},
          ),
        ],
        builder: (context, toggle) =>
            TfButton(label: 'Open menu', onPressed: toggle),
      ),
      TfTooltip(
        message: 'A tooltip',
        child: TfButton(label: 'Hover me', onPressed: () {}),
      ),
      const TfKeyHint('Ctrl+K'),
    ]),
  ),
  _section(
    context,
    'Overlays',
    _wrap([
      TfButton(
        label: 'Dialog',
        onPressed: () => showTfDialog<void>(
          context,
          title: 'Delete task?',
          body: const Text('This cannot be undone.'),
          actions: [
            TfButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
            TfButton(
              label: 'Delete',
              variant: TfButtonVariant.danger,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      TfButton(
        label: 'Side sheet',
        onPressed: () => showTfSideSheet<void>(
          context,
          title: 'Details',
          closeTooltip: 'Close',
          body: const Padding(
            padding: EdgeInsets.all(TfSpace.lg),
            child: Text('Side sheet body'),
          ),
        ),
      ),
      TfButton(
        label: 'Bottom sheet',
        onPressed: () => showTfBottomSheet<void>(
          context,
          body: const Text('Bottom sheet body'),
        ),
      ),
      TfButton(
        label: 'Toast',
        onPressed: () =>
            showTfToast(context, 'Saved', kind: TfBannerKind.success),
      ),
    ]),
  ),
  _section(
    context,
    'Banners',
    Column(
      children: [
        for (final k in TfBannerKind.values)
          Padding(
            padding: const EdgeInsets.only(bottom: TfSpace.sm),
            child: TfBanner(
              message: 'A ${k.name} message',
              kind: k,
              actionLabel: 'Action',
              onAction: () {},
              onDismiss: () {},
              dismissTooltip: 'Dismiss',
            ),
          ),
      ],
    ),
  ),
  _section(
    context,
    'Empty and loading',
    Column(
      children: [
        const SizedBox(
          height: 320,
          child: TfEmpty(
            illustration: TfIllustrationKind.tasks,
            title: 'No tasks yet',
            message: 'Create the first one to get going.',
            actionLabel: 'New task',
            docsLabel: 'Learn about tasks',
            onDocs: _noop,
          ),
        ),
        const TfEmpty(
          compact: true,
          title: 'Nothing here',
          message: 'Compact, for lists and cards.',
        ),
        const SizedBox(
          height: 120,
          child: TfEmpty(
            icon: TfIcons.list,
            title: 'Icon only (older call sites)',
          ),
        ),
        const SizedBox(
          height: 320,
          child: TfError(
            message: 'We could not load the tasks.',
            details: 'GrpError(unavailable)',
            onRetry: _noop,
          ),
        ),
        const TfError(
          compact: true,
          message: 'We could not load the tasks.',
          onRetry: _noop,
        ),
        _wrap([
          for (final kind in TfIllustrationKind.values)
            TfIllustration(kind, height: 72),
        ]),
        _wrap(const [
          TfSkeleton(width: 160),
          TfSkeleton(width: 40, height: 40, circle: true),
          TfSkeleton(width: 240, height: 20),
        ]),
      ],
    ),
  ),
];

void _noop() {}
