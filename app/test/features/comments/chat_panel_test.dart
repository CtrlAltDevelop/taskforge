import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

import 'comments_section_test.dart' show bodyWith, open, seed;

final _t0 = DateTime(2026, 3, 5, 10);

Comment change(
  String id,
  String field,
  Object? from,
  Object? to, {
  DateTime? at,
  String actor = 'u2',
  String type = 'user',
}) => Comment(
  id: id,
  taskId: 'a',
  authorId: type == 'user' ? actor : '',
  createdAt: at ?? _t0,
  kind: 'system',
  event: ChatEvent(
    actorType: type,
    actorId: type == 'user' ? actor : '',
    field: field,
    from: from,
    to: to,
  ),
);

void main() {
  testWidgets('shows changes and talk in one stream, muted, oldest first', (
    tester,
  ) async {
    await open(
      tester,
      comments: [
        change('s1', 'priority', 'low', 'high', at: _t0),
        seed('c1', 'Why high?', at: _t0.add(const Duration(minutes: 1))),
      ],
      overrides: [
        chatNowProvider.overrideWithValue(
          () => _t0.add(const Duration(minutes: 38)),
        ),
      ],
    );

    expect(find.text('Chat (1)'), findsOneWidget); // changes are not counted
    expect(find.byKey(const Key('system-s1')), findsOneWidget);
    expect(find.text('38 min ago'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('system-s1'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('comment-c1'))).dy),
    );
  });

  testWidgets('a change has no menu, reactions or reply', (tester) async {
    await open(tester, comments: [change('s1', 'priority', 'low', 'high')]);

    final line = find.byKey(const Key('system-s1'));
    expect(
      find.descendant(of: line, matching: find.byType(PopupMenuButton)),
      findsNothing,
    );
    expect(find.byKey(const Key('menu-s1')), findsNothing);
    expect(find.byKey(const Key('react-s1')), findsNothing);
    expect(find.byKey(const Key('comment-s1')), findsNothing);
  });

  testWidgets('Hide changes hides only changes and is remembered', (
    tester,
  ) async {
    final prefs = MemoryPrefs();
    await open(
      tester,
      comments: [
        change('s1', 'priority', 'low', 'high'),
        seed('c1', 'Why high?'),
      ],
      overrides: [localPrefsProvider.overrideWithValue(prefs)],
    );
    expect(find.byKey(const Key('system-s1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('hide-changes')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('system-s1')), findsNothing);
    expect(bodyWith('Why high?'), findsOneWidget);
    expect(await prefs.read('chat.hideChanges.u1'), 'true');
  });

  testWidgets('an empty chat says what will show up', (tester) async {
    await open(tester);

    expect(
      find.text('No messages yet — changes and talk will show up here'),
      findsOneWidget,
    );
  });

  testWidgets('a coalesced change arrives as an update and replaces the line', (
    tester,
  ) async {
    final o = await open(
      tester,
      comments: [change('s1', 'priority', 'low', 'normal')],
    );
    expect(find.textContaining('from Low to Normal'), findsOneWidget);

    o.comments.comments[0] = change('s1', 'priority', 'low', 'high');
    await o.pumped.container
        .read(commentsProvider((project: 'p1', task: 'a')).notifier)
        .refresh();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('system-s1')), findsOneWidget);
    expect(find.textContaining('from Low to High'), findsOneWidget);
    expect(find.textContaining('to Normal'), findsNothing);
  });
}
