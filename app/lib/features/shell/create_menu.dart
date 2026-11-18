import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/chat/presentation/chat_dialogs.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

/// The things "+ Create" offers, as action ids in order. Each is the same
/// registered action the palette and the keys run, so what is allowed and
/// what happens cannot differ from them.
const createActionIds = [
  ('task.new', TfIcons.check),
  ('doc.create', TfIcons.file),
  ('project.create', TfIcons.folder),
  ('dashboard.create', TfIcons.dashboard),
  ('sprint.create', TfIcons.clock),
  ('member.invite', TfIcons.users),
];

/// The "+ Create" menu of the top bar: Task, Doc, Project, Channel and the
/// rest, only what the person can do here.
class CreateMenu extends ConsumerWidget {
  const CreateMenu({super.key, this.compact = false});

  /// An icon button instead of a labelled one.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final from = actionContextOf(context);
    // Availability reads permissions: rebuild when they arrive or change.
    ref.watch(permissionSetProvider);
    final registry = ref.watch(actionRegistryProvider);
    final items = <TfMenuItem>[
      for (final (id, icon) in createActionIds)
        if (registry.byId(id) case final action? when action.isAvailable(from))
          TfMenuItem(
            label: action.titleIn(l),
            icon: icon,
            shortcut: _keys(ref, id, context),
            onSelected: () {
              ref.read(recentActionsProvider.notifier).ran(action.id);
              action.run(from);
            },
          ),
      TfMenuItem(
        label: l.chatNew,
        icon: TfIcons.chat,
        onSelected: () => showNewChatDialog(context),
      ),
    ];
    return TfMenu(
      items: items,
      builder: (context, toggle) => compact
          ? TfIconButton(
              key: const Key('create-menu'),
              icon: TfIcons.plus,
              tooltip: l.shellCreate,
              variant: TfButtonVariant.primary,
              onPressed: toggle,
            )
          : TfButton(
              key: const Key('create-menu'),
              label: l.shellCreate,
              icon: TfIcons.plus,
              variant: TfButtonVariant.primary,
              size: TfButtonSize.small,
              onPressed: toggle,
            ),
    );
  }

  String? _keys(WidgetRef ref, String id, BuildContext context) => ref
      .watch(bindingsProvider)
      .chordOf(id)
      ?.label(isMac: isApplePlatform, l10n: context.l10n);
}
