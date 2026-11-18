import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/chat/presentation/chat_dialogs.dart';
import 'package:taskforge/features/chat/presentation/chat_labels.dart';
import 'package:taskforge/features/chat/presentation/conversation_pane.dart';
import 'package:taskforge/features/chat/presentation/space_list.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

/// Where the list and the conversation sit side by side.
const chatTwoPaneFrom = 720.0;

/// The Chat area: the list of spaces and the open conversation, side by side
/// on wide screens and one at a time on phones. [spaceId] (from the route)
/// is the open conversation.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, this.spaceId});

  final String? spaceId;

  void _open(BuildContext context, Space space) =>
      context.go('/chat/${space.id}');

  void _openTask(BuildContext context, TaskChatRef chat) =>
      context.go('/projects/${chat.projectId}?task=${chat.taskId}');

  Future<void> _new(BuildContext context) async {
    final space = await showNewChatDialog(context);
    if (space != null && context.mounted) _open(context, space);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spaces = ref.watch(spacesProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final open = spaceId == null ? null : spaces.list.byId(spaceId!);
    return Scaffold(
      appBar: TfAppBar(
        title: Text(l10n.chatTitle),
        actions: [
          IconButton(
            key: const Key('chat-new'),
            tooltip: l10n.chatNew,
            icon: const TfIcon(TfIcons.chatPlus, size: 24),
            onPressed: () => _new(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= chatTwoPaneFrom;
          final list = SpaceListPane(
            selectedId: spaceId,
            onOpen: (s) => _open(context, s),
            onOpenTask: (t) => _openTask(context, t),
          );
          final conversation = open != null
              ? ConversationPane(key: ValueKey(open.id), space: open)
              : _Placeholder(
                  waiting: spaces.loading && spaceId != null,
                  lost: spaceId != null && !spaces.loading,
                );
          if (wide) {
            return Row(
              children: [
                SizedBox(width: 320, child: list),
                const VerticalDivider(width: 1),
                Expanded(child: conversation),
              ],
            );
          }
          if (spaceId == null) return list;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (open != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: const Key('chat-to-list'),
                    onPressed: () => context.go('/chat'),
                    icon: const TfIcon(TfIcons.arrowStart, size: 24),
                    label: Text(spaceTitle(open, members, l10n)),
                  ),
                ),
              Expanded(child: conversation),
            ],
          );
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.waiting, required this.lost});

  final bool waiting;
  final bool lost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Text(
        lost ? l10n.grpLCommentGone : l10n.chatSelectSpace,
        key: const Key('chat-placeholder'),
      ),
    );
  }
}
