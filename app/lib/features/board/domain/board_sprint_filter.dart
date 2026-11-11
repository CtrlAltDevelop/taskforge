import 'dart:convert';

/// The condition `sprint = currentSprint()` in the server's filter AST.
const _currentSprint = <String, Object?>{
  'op': 'cmp',
  'field': 'sprint',
  'cmp': 'eq',
  'values': [
    {'k': 'func', 'v': 'currentSprint'},
  ],
};

/// [filterJson] (the person's filter, '' for none) narrowed to the project's
/// active sprint: its condition and the sprint one must both hold. The
/// ordering of [filterJson] is kept.
String withCurrentSprint(String filterJson) {
  final ast = filterJson.isEmpty
      ? <String, Object?>{}
      : jsonDecode(filterJson) as Map<String, Object?>;
  final where = ast['where'];
  return jsonEncode({
    'where': where == null
        ? _currentSprint
        : {
            'op': 'and',
            'args': [where, _currentSprint],
          },
    'order': ast['order'] ?? const <Object?>[],
  });
}
