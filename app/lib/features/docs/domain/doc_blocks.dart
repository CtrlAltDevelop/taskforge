import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// The block schema version the app writes (the server's `SCHEMA_VERSION`).
const docSchemaVersion = 1;

/// A character that stands in for an inline node the app does not edit.
const atomChar = '￼';

final _random = Random.secure();

/// A fresh block id.
String newBlockId() {
  return List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// [value] as JSON text with every object's keys sorted: two values that mean
/// the same compare equal.
String canonicalJson(Object? value) => jsonEncode(_sorted(value));

Object? _sorted(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((k) => '$k').toList()..sort();
    return {for (final k in keys) k: _sorted(value[k])};
  }
  if (value is List) return [for (final v in value) _sorted(v)];
  return value;
}

/// Same JSON, whatever the key order.
bool sameJson(Object? a, Object? b) => canonicalJson(a) == canonicalJson(b);

/// The wire form of a mark.
const boldMark = '{"type":"bold"}';
const italicMark = '{"type":"italic"}';
const strikeMark = '{"type":"strike"}';
const codeMark = '{"type":"code"}';

String linkMark(String href) => jsonEncode({
  'type': 'link',
  'attrs': {'href': href},
});

/// The address of a link mark, or null when [mark] is not one.
String? linkHref(String mark) {
  final Object? decoded;
  try {
    decoded = jsonDecode(mark);
  } on FormatException {
    return null;
  }
  if (decoded is! Map || decoded['type'] != 'link') return null;
  final attrs = decoded['attrs'];
  return attrs is Map ? attrs['href'] as String? : null;
}

/// An inline node shown as text but kept whole: a `[[` page mention (its label
/// is the text), a hard break, or a node of a newer client (shown as a
/// placeholder). It goes back out exactly as it came.
@immutable
class Atom {
  const Atom(this.node, this.text);

  /// The mention of page [docId], shown as [label].
  factory Atom.mention(String docId, String label) => Atom({
    'type': 'mention',
    'attrs': {'doc_id': docId, 'label': label},
  }, label.isEmpty ? 'page' : label);

  final Map<String, Object?> node;

  /// What the text field shows for it.
  final String text;

  String get kind => node['type'] as String? ?? '';
  bool get isMention => kind == 'mention';
  bool get isBreak => kind == 'hard_break';
  String? get docId {
    if (!isMention) return null;
    final id = (node['attrs'] as Map?)?['doc_id'];
    return id is String ? id : null;
  }
}

/// How one character looks: its marks (in the order they were given, each as
/// JSON text so a mark the app does not know survives) and, for a character
/// that is part of an inline node, that [atom].
@immutable
class Attr {
  const Attr([this.marks = const [], this.atom]);

  static const plain = Attr();

  final List<String> marks;
  final Atom? atom;

  bool has(String mark) => marks.contains(mark);
  bool get bold => has(boldMark);
  bool get italic => has(italicMark);
  bool get strike => has(strikeMark);
  bool get code => has(codeMark);
  String? get link {
    for (final m in marks) {
      final href = linkHref(m);
      if (href != null) return href;
    }
    return null;
  }

  Attr withMark(String mark) => has(mark) ? this : Attr([...marks, mark], atom);
  Attr withoutMark(String mark) => Attr([
    for (final m in marks)
      if (m != mark) m,
  ], atom);

  /// Without any link mark.
  Attr withoutLinks() => Attr([
    for (final m in marks)
      if (linkHref(m) == null) m,
  ], atom);

  @override
  bool operator ==(Object other) =>
      other is Attr && other.atom == atom && listEquals(other.marks, marks);

  @override
  int get hashCode => Object.hash(atom, Object.hashAll(marks));
}

/// The text of one block with a look for every UTF-16 unit. Immutable: every
/// edit gives a new one. Converts to and from the server's inline nodes.
@immutable
class Rich {
  const Rich(this.text, this.attrs);

  static const empty = Rich('', []);

  factory Rich.plain(String text) =>
      Rich(text, List.filled(text.length, Attr.plain));

  /// Reads the server's inline nodes.
  factory Rich.fromInlines(Object? inlines) {
    final buffer = StringBuffer();
    final attrs = <Attr>[];
    if (inlines is List) {
      for (final node in inlines) {
        if (node is! Map) continue;
        final type = node['type'];
        if (type == 'text' && node['text'] is String) {
          final marks = [
            for (final m in (node['marks'] as List? ?? const [])) jsonEncode(m),
          ];
          final text = node['text'] as String;
          buffer.write(text);
          attrs.addAll(List.filled(text.length, Attr(marks)));
        } else if (type == 'hard_break') {
          buffer.write('\n');
          attrs.add(Attr(const [], Atom(Map.of(node.cast()), '\n')));
        } else if (type == 'mention') {
          final a = (node['attrs'] as Map?) ?? const {};
          final label = '${a['label'] ?? ''}';
          final atom = Atom(
            Map<String, Object?>.from(node),
            label.isEmpty ? 'page' : label,
          );
          buffer.write(atom.text);
          attrs.addAll(List.filled(atom.text.length, Attr(const [], atom)));
        } else {
          buffer.write(atomChar);
          attrs.add(
            Attr(const [], Atom(Map<String, Object?>.from(node), atomChar)),
          );
        }
      }
    }
    return Rich(buffer.toString(), attrs);
  }

  final String text;
  final List<Attr> attrs;

  bool get isEmpty => text.isEmpty;
  int get length => text.length;

  /// The server's inline nodes for this text.
  List<Map<String, Object?>> toInlines() {
    final out = <Map<String, Object?>>[];
    var i = 0;
    while (i < text.length) {
      final attr = attrs[i];
      final atom = attr.atom;
      var j = i + 1;
      if (atom != null) {
        while (j < text.length && identical(attrs[j].atom, atom)) {
          j++;
        }
        if (text.substring(i, j) == atom.text) {
          out.add(Map<String, Object?>.from(atom.node));
        } else {
          // Somebody typed into or cut the node: what is left is plain text.
          _text(out, text.substring(i, j), attr.marks);
        }
      } else {
        while (j < text.length &&
            attrs[j].atom == null &&
            listEquals(attrs[j].marks, attr.marks)) {
          j++;
        }
        _text(out, text.substring(i, j), attr.marks);
      }
      i = j;
    }
    return out;
  }

  static void _text(
    List<Map<String, Object?>> out,
    String text,
    List<String> marks,
  ) {
    out.add({
      'type': 'text',
      'text': text,
      if (marks.isNotEmpty) 'marks': [for (final m in marks) jsonDecode(m)],
    });
  }

  /// This text after [start]..[end] was replaced by [inserted]. New characters
  /// look like the one before them (so typing goes on in bold) but never
  /// belong to an inline node.
  Rich replaceRange(int start, int end, String inserted) {
    final s = start.clamp(0, text.length);
    final e = end.clamp(s, text.length);
    Attr look = Attr.plain;
    if (s > 0 && attrs[s - 1].atom == null) {
      look = attrs[s - 1];
    } else if (s < text.length && attrs[s].atom == null && s != e) {
      look = attrs[s];
    }
    return Rich(text.replaceRange(s, e, inserted), [
      ...attrs.sublist(0, s),
      ...List.filled(inserted.length, look),
      ...attrs.sublist(e),
    ]);
  }

  /// This text after the characters were changed to [newText]: finds what was
  /// inserted and removed around the unchanged start and end.
  Rich withText(String newText) {
    if (newText == text) return this;
    var prefix = 0;
    final shortest = min(text.length, newText.length);
    while (prefix < shortest &&
        text.codeUnitAt(prefix) == newText.codeUnitAt(prefix)) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < shortest - prefix &&
        text.codeUnitAt(text.length - 1 - suffix) ==
            newText.codeUnitAt(newText.length - 1 - suffix)) {
      suffix++;
    }
    return replaceRange(
      prefix,
      text.length - suffix,
      newText.substring(prefix, newText.length - suffix),
    );
  }

  Rich slice(int start, int end) =>
      Rich(text.substring(start, end), attrs.sublist(start, end));

  Rich operator +(Rich other) =>
      Rich(text + other.text, [...attrs, ...other.attrs]);

  /// Whether every character of [start]..[end] has [mark].
  bool allHave(int start, int end, String mark) {
    if (start >= end) return false;
    for (var i = start; i < end; i++) {
      if (attrs[i].atom != null) continue;
      if (!attrs[i].has(mark)) return false;
    }
    return true;
  }

  /// Marks (or, when they all have it already, unmarks) [start]..[end].
  Rich toggleMark(int start, int end, String mark) {
    final remove = allHave(start, end, mark);
    return Rich(text, [
      for (var i = 0; i < attrs.length; i++)
        if (i < start || i >= end || attrs[i].atom != null)
          attrs[i]
        else if (remove)
          attrs[i].withoutMark(mark)
        else
          attrs[i].withMark(mark),
    ]);
  }

  /// [start]..[end] as a link to [href]; an empty address takes links off.
  Rich setLink(int start, int end, String href) => Rich(text, [
    for (var i = 0; i < attrs.length; i++)
      if (i < start || i >= end || attrs[i].atom != null)
        attrs[i]
      else if (href.isEmpty)
        attrs[i].withoutLinks()
      else
        attrs[i].withoutLinks().withMark(linkMark(href)),
  ]);

  @override
  bool operator ==(Object other) =>
      other is Rich && other.text == text && listEquals(other.attrs, attrs);

  @override
  int get hashCode => Object.hash(text, Object.hashAll(attrs));
}

/// Block types the editor knows.
abstract final class BlockType {
  static const paragraph = 'paragraph';
  static const heading = 'heading';
  static const bullet = 'bullet_item';
  static const numbered = 'numbered_item';
  static const checklist = 'checklist_item';
  static const quote = 'quote';
  static const code = 'code';
  static const table = 'table';
  static const divider = 'divider';
  static const image = 'image';
  static const callout = 'callout';
  static const taskCard = 'task_card';

  static const known = {
    paragraph,
    heading,
    bullet,
    numbered,
    checklist,
    quote,
    code,
    table,
    divider,
    image,
    callout,
    taskCard,
  };

  /// Types whose body is rich text.
  static const rich = {
    paragraph,
    heading,
    bullet,
    numbered,
    checklist,
    quote,
    callout,
  };
}

const calloutTones = ['info', 'warning', 'success', 'danger'];

/// One block as the server stores it: a JSON object. The app edits it by
/// making a changed copy, never in place, and keeps every key it does not
/// know, so a block of a newer kind (or with newer keys) goes back unchanged.
@immutable
class DocBlock {
  const DocBlock(this.json);

  /// A new, empty block of [type].
  factory DocBlock.create(String type, {String? id}) {
    final base = <String, Object?>{'id': id ?? newBlockId(), 'type': type};
    switch (type) {
      case BlockType.heading:
        base['attrs'] = {'level': 1};
        base['content'] = <Object?>[];
      case BlockType.bullet || BlockType.numbered:
        base['attrs'] = {'indent': 0};
        base['content'] = <Object?>[];
      case BlockType.checklist:
        base['attrs'] = {'indent': 0, 'checked': false};
        base['content'] = <Object?>[];
      case BlockType.callout:
        base['attrs'] = {'tone': 'info'};
        base['content'] = <Object?>[];
      case BlockType.code:
        base['attrs'] = {'language': ''};
        base['text'] = '';
      case BlockType.table:
        base['attrs'] = {'header': true};
        base['rows'] = [
          [<Object?>[], <Object?>[]],
          [<Object?>[], <Object?>[]],
        ];
      case BlockType.image:
        base['attrs'] = {'src': '', 'alt': ''};
      case BlockType.taskCard:
        base['attrs'] = {'task_id': ''};
      case BlockType.divider:
        break;
      default:
        base['content'] = <Object?>[];
    }
    return DocBlock(base);
  }

  final Map<String, Object?> json;

  String get id => json['id'] as String? ?? '';
  String get type => json['type'] as String? ?? '';
  bool get isKnown => BlockType.known.contains(type);
  bool get hasRichText => BlockType.rich.contains(type);

  Map<String, Object?> get attrs {
    final a = json['attrs'];
    return a is Map ? Map<String, Object?>.from(a) : const {};
  }

  int get level => (attrs['level'] as num?)?.toInt().clamp(1, 3) ?? 1;
  int get indent => (attrs['indent'] as num?)?.toInt().clamp(0, 5) ?? 0;
  bool get checked => attrs['checked'] == true;
  String get tone => attrs['tone'] as String? ?? 'info';
  String get language => attrs['language'] as String? ?? '';
  String get src => attrs['src'] as String? ?? '';
  String get alt => attrs['alt'] as String? ?? '';
  String get taskId => attrs['task_id'] as String? ?? '';
  bool get header => attrs['header'] == true;

  /// The plain text of a code block.
  String get codeText => json['text'] as String? ?? '';

  Rich get rich => Rich.fromInlines(json['content']);

  /// A table's cells, each as rich text.
  List<List<Rich>> get rows => [
    for (final row in (json['rows'] as List? ?? const []))
      [for (final cell in (row as List? ?? const [])) Rich.fromInlines(cell)],
  ];

  /// What a quick look at the block says (for placeholders and previews).
  String get plain {
    if (type == BlockType.code) return codeText;
    if (type == BlockType.table) {
      return rows.map((r) => r.map((c) => c.text).join(' | ')).join('\n');
    }
    return rich.text;
  }

  DocBlock _with(Map<String, Object?> changes) =>
      DocBlock({...json, ...changes});

  DocBlock withRich(Rich rich) => _with({'content': rich.toInlines()});

  DocBlock withAttrs(Map<String, Object?> changes) => _with({
    'attrs': {...attrs, ...changes},
  });

  DocBlock withCodeText(String text) => _with({'text': text});

  DocBlock withRows(List<List<Rich>> rows) => _with({
    'rows': [
      for (final row in rows) [for (final cell in row) cell.toInlines()],
    ],
  });

  /// This block turned into [type], keeping its text where both have text.
  DocBlock turnInto(String type, {Map<String, Object?> attrs = const {}}) {
    if (type == this.type && attrs.isEmpty) return this;
    final fresh = DocBlock.create(type, id: id);
    final text = hasRichText ? rich : null;
    var out = fresh;
    if (fresh.hasRichText && text != null) out = out.withRich(text);
    if (type == BlockType.code && text != null) {
      out = out.withCodeText(text.text);
    }
    if (type == BlockType.code && this.type == BlockType.code) {
      out = out.withCodeText(codeText);
    }
    if (attrs.isNotEmpty) out = out.withAttrs(attrs);
    return out;
  }

  @override
  bool operator ==(Object other) =>
      other is DocBlock && sameJson(other.json, json);

  @override
  int get hashCode => canonicalJson(json).hashCode;

  @override
  String toString() => 'DocBlock($type $id)';
}

/// Reads a page body. An empty text is an empty page.
List<DocBlock> parseBlocks(String text) {
  if (text.trim().isEmpty) return const [];
  final decoded = jsonDecode(text);
  if (decoded is! List) throw const FormatException('Blocks must be a list.');
  return List.unmodifiable([
    for (final b in decoded)
      if (b is Map)
        DocBlock(Map<String, Object?>.from(b))
      else
        DocBlock({'id': newBlockId(), 'type': 'unknown', 'value': b}),
  ]);
}

String encodeBlocks(List<DocBlock> blocks) =>
    jsonEncode([for (final b in blocks) b.json]);

bool sameBlocks(List<DocBlock> a, List<DocBlock> b) =>
    a.length == b.length &&
    [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((e) => e);

/// Ids of the tasks embedded as cards, once each, in order.
List<String> taskCardIds(List<DocBlock> blocks) => {
  for (final b in blocks)
    if (b.type == BlockType.taskCard && b.taskId.isNotEmpty) b.taskId,
}.toList();
