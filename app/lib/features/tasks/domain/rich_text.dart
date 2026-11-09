import 'dart:convert';

/// The task description is the shared rich-text document (`{"type": "doc"}`,
/// the same format Docs will use). People edit it as lightly marked-up text:
///
///     # Heading (one to three #)      > quote
///     - bullet        1. numbered     - [ ] to do   - [x] done
///     ``` fences make a code block    --- is a rule   [text](https://link)
///
/// [markdownToDoc] and [docToMarkdown] convert between the two; everything the
/// server accepts is shown, so a document made elsewhere is never lost.

final _heading = RegExp(r'^(#{1,3}) (.*)$');
final _checklist = RegExp(r'^[-*] \[([ xX])\] ?(.*)$');
final _bullet = RegExp(r'^[-*] (.*)$');
final _ordered = RegExp(r'^\d+\. (.*)$');
final _quote = RegExp(r'^> ?(.*)$');
final _link = RegExp(r'\[([^\]]+)\]\(([^)\s]+)\)');

Map<String, Object?> _text(String text, {String? href}) => {
  'type': 'text',
  'text': text,
  if (href != null)
    'marks': [
      {
        'type': 'link',
        'attrs': {'href': href},
      },
    ],
};

/// Plain text with `[text](url)` links as inline nodes; empty text has none.
List<Map<String, Object?>> _inline(String line) {
  final nodes = <Map<String, Object?>>[];
  var from = 0;
  for (final m in _link.allMatches(line)) {
    if (m.start > from) nodes.add(_text(line.substring(from, m.start)));
    nodes.add(_text(m.group(1)!, href: m.group(2)));
    from = m.end;
  }
  if (from < line.length) nodes.add(_text(line.substring(from)));
  return nodes;
}

Map<String, Object?> _block(String type, String line, {Object? attrs}) => {
  'type': type,
  'attrs': ?attrs,
  if (line.isNotEmpty) 'content': _inline(line),
};

Map<String, Object?> _paragraph(String line) => _block('paragraph', line);

/// The document for [text], or `''` when there is nothing to store.
String markdownToDoc(String text) {
  if (text.trim().isEmpty) return '';
  final blocks = <Map<String, Object?>>[];
  final lines = text.replaceAll('\r\n', '\n').split('\n');
  var i = 0;

  List<Map<String, Object?>> group(String type, String item, RegExp pattern) {
    // Consecutive lines of one list kind become one list node.
    final items = <Map<String, Object?>>[];
    while (i < lines.length && pattern.hasMatch(lines[i])) {
      final m = pattern.firstMatch(lines[i])!;
      items.add(switch (type) {
        'checklist' => _block(
          'checklist_item',
          m.group(2)!,
          attrs: {'checked': m.group(1) != ' '},
        ),
        _ => {
          'type': 'list_item',
          'content': [_paragraph(m.group(1)!)],
        },
      });
      i++;
    }
    return items;
  }

  while (i < lines.length) {
    final line = lines[i];
    if (line.trimRight() == '```') {
      final code = <String>[];
      i++;
      while (i < lines.length && lines[i].trimRight() != '```') {
        code.add(lines[i++]);
      }
      i++; // the closing fence (or the end of the text)
      blocks.add({
        'type': 'code_block',
        if (code.isNotEmpty) 'content': [_text(code.join('\n'))],
      });
    } else if (line.trim() == '---') {
      blocks.add({'type': 'horizontal_rule'});
      i++;
    } else if (_heading.hasMatch(line)) {
      final m = _heading.firstMatch(line)!;
      blocks.add(
        _block('heading', m.group(2)!, attrs: {'level': m.group(1)!.length}),
      );
      i++;
    } else if (_checklist.hasMatch(line)) {
      blocks.add({
        'type': 'checklist',
        'content': group('checklist', '', _checklist),
      });
    } else if (_bullet.hasMatch(line)) {
      blocks.add({
        'type': 'bullet_list',
        'content': group('bullet', '', _bullet),
      });
    } else if (_ordered.hasMatch(line)) {
      blocks.add({
        'type': 'ordered_list',
        'content': group('ordered', '', _ordered),
      });
    } else if (_quote.hasMatch(line)) {
      blocks.add({
        'type': 'blockquote',
        'content': [_paragraph(_quote.firstMatch(line)!.group(1)!)],
      });
      i++;
    } else {
      blocks.add(_paragraph(line));
      i++;
    }
  }
  return jsonEncode({'type': 'doc', 'content': blocks});
}

/// The editable text of a stored document; `''` for none or an unreadable one.
String docToMarkdown(String json) {
  if (json.isEmpty) return '';
  try {
    final doc = jsonDecode(json);
    if (doc is! Map) return '';
    return _children(doc).map(_blockLines).join('\n');
  } on FormatException {
    return '';
  }
}

List<Object?> _children(Object? node) =>
    node is Map ? (node['content'] as List?) ?? const [] : const [];

String _inlineText(Object? node) {
  if (node is! Map) return '';
  switch (node['type']) {
    case 'text':
      final text = node['text'] as String? ?? '';
      final marks = (node['marks'] as List?) ?? const [];
      for (final mark in marks) {
        if (mark is Map && mark['type'] == 'link') {
          final href = (mark['attrs'] as Map?)?['href'];
          if (href is String && href.isNotEmpty) return '[$text]($href)';
        }
      }
      return text;
    case 'hard_break':
      return ' ';
    default:
      return _children(node).map(_inlineText).join();
  }
}

String _blockLines(Object? node) {
  if (node is! Map) return '';
  final items = _children(node);
  switch (node['type']) {
    case 'heading':
      final level = ((node['attrs'] as Map?)?['level'] as int?) ?? 1;
      return '${'#' * level.clamp(1, 3)} ${_inlineText(node)}';
    case 'bullet_list':
      return items.map((i) => '- ${_inlineText(i)}').join('\n');
    case 'ordered_list':
      return [
        for (var n = 0; n < items.length; n++)
          '${n + 1}. ${_inlineText(items[n])}',
      ].join('\n');
    case 'checklist':
      return items
          .map((i) {
            final done = i is Map && (i['attrs'] as Map?)?['checked'] == true;
            return '- [${done ? 'x' : ' '}] ${_inlineText(i)}';
          })
          .join('\n');
    case 'code_block':
      return '```\n${_inlineText(node)}\n```';
    case 'blockquote':
      return '> ${_inlineText(node)}';
    case 'horizontal_rule':
      return '---';
    default:
      return _inlineText(node);
  }
}
