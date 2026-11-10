import 'package:flutter/foundation.dart';

/// The filter a person has on a project's views, as it is kept: its AST as JSON
/// ('' for none) and the saved filter it is, if it still is that one. [text] is
/// the same filter in TFQL for the summary chip (read from the server when the
/// layout loads; it is not stored).
@immutable
class FilterLayout {
  const FilterLayout({this.astJson = '', this.savedId = '', this.text = ''});

  final String astJson;
  final String savedId;
  final String text;

  bool get isEmpty => astJson.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is FilterLayout &&
      other.astJson == astJson &&
      other.savedId == savedId &&
      other.text == text;

  @override
  int get hashCode => Object.hash(astJson, savedId, text);
}
