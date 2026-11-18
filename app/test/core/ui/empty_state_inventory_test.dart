import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 48: every screen with a list, board, dashboard, doc, chat or inbox
/// view says "nothing here" with `TfEmpty` and "it failed" with `TfError`.
/// This greps `lib/features` for the hand-rolled shapes they replaced; a hit
/// means a new ad-hoc empty or error widget. The inventory is in
/// docs/phases/phase-48-home-onboarding-empty-states.md.
final _forbidden = {
  'a bare Center(child: Text(...))': RegExp(
    r'\bCenter\(\s*child:\s*Text\(\s*(?:context\.l10n|l10n|t)\.',
  ),
  'an error branch that is only text': RegExp(
    r'(?:error:\s*\([^)]*\)|AsyncError\([^)]*\))\s*=>\s*(?:const\s+)?(?:Center|Text|Padding)\(',
  ),
  'a hand-made retry button': RegExp(
    // retry-save retries a save, not a load.
    r'(?:TextButton|FilledButton|OutlinedButton)\(\s*key:\s*const Key\(\s*.[a-z-]*retry(?!-save)',
  ),
  'an emptyText parameter': RegExp(r'\bemptyText\b'),
};

/// Places exempt from the rules, each with its reason. None today: every
/// empty and error state in `lib/features` is a `TfEmpty` or a `TfError`
/// (compact ones sit inside forms, dialogs and panels).
const _exempt = <String, String>{};

String _norm(String p) => p.replaceAll(r'\', '/');

Map<String, List<String>> _scan(Iterable<MapEntry<String, String>> sources) {
  final hits = <String, List<String>>{};
  for (final MapEntry(key: path, value: source) in sources) {
    for (final MapEntry(key: name, value: rule) in _forbidden.entries) {
      if (rule.hasMatch(source)) hits.putIfAbsent(path, () => []).add(name);
    }
  }
  return hits;
}

void main() {
  test(
    'no list, board, dashboard, doc, chat or inbox screen is hand-rolled',
    () {
      final sources = [
        for (final f in Directory('lib/features').listSync(recursive: true))
          if (f is File && f.path.endsWith('.dart'))
            MapEntry(_norm(f.path), f.readAsStringSync()),
      ];
      final hits = _scan(sources)
        ..removeWhere((path, _) => _exempt.containsKey(path));
      expect(
        hits,
        isEmpty,
        reason: 'use TfEmpty / TfError (lib/core/ui/tf/tf_feedback.dart)',
      );
    },
  );

  test('every exemption still exists and still needs it', () {
    for (final path in _exempt.keys) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path is gone: drop it');
      expect(
        _scan([MapEntry(path, file.readAsStringSync())]),
        isNotEmpty,
        reason: '$path is clean now: drop the exemption',
      );
    }
  });

  test('the rules recognise what they are meant to catch', () {
    final bad = {
      'Center(child: Text(t.x))': 'a bare Center(child: Text(...))',
      'error: (e, _) => Center(child: x)': 'an error branch that is only text',
      'AsyncError(:final error) => Center(':
          'an error branch that is only text',
      "TextButton(key: const Key('retry-x'),": 'a hand-made retry button',
      'emptyText: t.x': 'an emptyText parameter',
    };
    for (final MapEntry(key: code, value: rule) in bad.entries) {
      expect(_forbidden[rule]!.hasMatch(code), isTrue, reason: code);
    }
    expect(
      _forbidden['a bare Center(child: Text(...))']!.hasMatch(
        'TfEmpty(title: t.x)',
      ),
      isFalse,
    );
  });
}
