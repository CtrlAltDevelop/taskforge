import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/domain/rich_text.dart';

/// A run of a comment's text as it is shown: plain, a link or a mention.
@immutable
class Segment {
  const Segment(this.text, {this.href, this.mentionId, this.bold = false});

  final String text;
  final String? href;
  final String? mentionId;
  final bool bold;

  bool get isMention => mentionId != null;

  @override
  bool operator ==(Object other) =>
      other is Segment &&
      other.text == text &&
      other.href == href &&
      other.mentionId == mentionId &&
      other.bold == bold;

  @override
  int get hashCode => Object.hash(text, href, mentionId, bold);
}

/// The text of a comment body (JSON) as lines of [Segment]s: one list per
/// block, nested blocks flattened, a bullet shown with a leading `• `.
List<List<Segment>> segmentsOf(String bodyJson, {bool markdown = false}) {
  if (bodyJson.isEmpty) return const [];
  final Object? decoded;
  try {
    decoded = jsonDecode(bodyJson);
  } on FormatException {
    return const [];
  }
  final lines = <List<Segment>>[];
  void block(Object? node, String prefix) {
    if (node is! Map<String, dynamic>) return;
    final type = node['type'];
    final content = (node['content'] as List<dynamic>?) ?? const [];
    if (type == 'paragraph' ||
        type == 'heading' ||
        type == 'code_block' ||
        (content.isNotEmpty &&
            content.first is Map &&
            _isInline(content.first))) {
      lines.add([
        if (prefix.isNotEmpty) Segment(prefix),
        for (final c in content) ..._inline(c),
      ]);
      return;
    }
    final next = switch (type) {
      'bullet_list' => markdown ? '- ' : '• ',
      'checklist' => markdown ? '- [ ] ' : '☐ ',
      'blockquote' => '> ',
      _ => prefix,
    };
    for (final c in content) {
      block(c, next);
    }
  }

  block(decoded, '');
  return lines;
}

bool _isInline(Object? node) =>
    node is Map && {'text', 'mention', 'hard_break'}.contains(node['type']);

List<Segment> _inline(Object? node) {
  if (node is! Map<String, dynamic>) return const [];
  switch (node['type']) {
    case 'text':
      final marks = (node['marks'] as List<dynamic>?) ?? const [];
      String? href;
      var bold = false;
      for (final m in marks) {
        if (m is Map && m['type'] == 'link') {
          href = (m['attrs'] as Map?)?['href'] as String?;
        }
        if (m is Map && m['type'] == 'bold') bold = true;
      }
      return [Segment(node['text'] as String? ?? '', href: href, bold: bold)];
    case 'mention':
      final attrs = (node['attrs'] as Map?) ?? const {};
      return [
        Segment('@${attrs['label'] ?? ''}', mentionId: attrs['id'] as String?),
      ];
    case 'hard_break':
      return const [Segment('\n')];
  }
  return const [];
}

/// The plain text of a body, lines joined with newlines (for a notification
/// line, an edit box, a copy).
String plainTextOf(String bodyJson) =>
    segmentsOf(bodyJson)
        .map((line) => line.map((s) => s.text).join())
        .join('\n');

const _mark = '\u0001';

/// The document for what was typed in the composer. [text] is lightly marked up
/// (see `markdownToDoc`); each `@label` of a pick becomes a mention node.
/// Returns `''` when there is nothing to send.
String bodyFromComposer(String text, List<MentionPick> picks) {
  if (text.trim().isEmpty) return '';
  var work = text;
  final used = <int, MentionPick>{};
  // Longest labels first so "@Ana Maria" is not read as "@Ana".
  final ordered = [...picks]..sort((a, b) => b.label.length - a.label.length);
  for (final pick in ordered) {
    if (!work.contains(pick.token)) continue;
    final slot = used.length;
    used[slot] = pick;
    work = work.replaceAll(pick.token, '$_mark$slot$_mark');
  }
  final doc = jsonDecode(markdownToDoc(work)) as Map<String, dynamic>;
  return jsonEncode(_mentions(doc, used));
}

Object? _mentions(Object? node, Map<int, MentionPick> used) {
  if (node is List) return [for (final n in node) ..._split(n, used)];
  if (node is! Map<String, dynamic>) return node;
  final content = node['content'];
  return {...node, if (content is List) 'content': _mentions(content, used)};
}

Iterable<Object?> _split(Object? node, Map<int, MentionPick> used) sync* {
  if (node is Map<String, dynamic> && node['type'] == 'text') {
    final text = node['text'] as String? ?? '';
    if (!text.contains(_mark)) {
      yield node;
      return;
    }
    final parts = text.split(_mark);
    // parts alternate: text, slot, text, slot, ... text
    for (var i = 0; i < parts.length; i++) {
      if (i.isEven) {
        if (parts[i].isNotEmpty) yield {...node, 'text': parts[i]};
      } else {
        final pick = used[int.tryParse(parts[i])];
        if (pick == null) continue;
        yield {
          'type': 'mention',
          'attrs': {'id': pick.userId, 'label': pick.label},
        };
      }
    }
    return;
  }
  yield _mentions(node, used);
}

/// Ids mentioned in a composer text (to know whom to ask the server about).
Set<String> mentionedIn(String text, List<MentionPick> picks) => {
  for (final p in picks)
    if (text.contains(p.token)) p.userId,
};

/// What the composer shows when a comment is edited: the lightly marked-up
/// text (bullets as `- `), mentions as `@name`.
String composerTextOf(String bodyJson) => segmentsOf(
  bodyJson,
  markdown: true,
).map((line) => line.map((s) => s.text).join()).join('\n');

/// The people a body mentions, as the picks that stand in the composer text.
List<MentionPick> picksOf(String bodyJson) {
  final seen = <String>{};
  return [
    for (final line in segmentsOf(bodyJson))
      for (final s in line)
        if (s.mentionId != null && seen.add(s.mentionId!))
          MentionPick(s.mentionId!, s.text.substring(1)),
  ];
}
