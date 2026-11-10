import 'package:flutter/foundation.dart';

/// How many active fields a project may have (the server enforces it too).
const maxActiveFields = 50;
const maxFieldNameLength = 60;

/// The views a field can be hidden from (columns chooser).
const hideableViews = {
  'list': 'List',
  'board': 'Board',
  'calendar': 'Calendar',
  'timeline': 'Timeline',
};

enum FieldType {
  text('text', 'Text'),
  number('number', 'Number'),
  select('select', 'Select'),
  multiselect('multiselect', 'Multi-select'),
  date('date', 'Date'),
  checkbox('checkbox', 'Checkbox'),
  url('url', 'URL'),
  user('user', 'User'),
  money('money', 'Money');

  const FieldType(this.wire, this.label);

  final String wire;
  final String label;

  bool get hasOptions => this == select || this == multiselect;

  static FieldType parse(String wire) =>
      values.firstWhere((t) => t.wire == wire, orElse: () => FieldType.text);
}

@immutable
class FieldOption {
  const FieldOption({required this.id, required this.label, this.color = ''});

  /// Empty for an option that is new in a save.
  final String id;
  final String label;

  /// `#RRGGBB` or empty.
  final String color;

  FieldOption copyWith({String? label, String? color}) => FieldOption(
    id: id,
    label: label ?? this.label,
    color: color ?? this.color,
  );
}

@immutable
class CustomField {
  const CustomField({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    this.options = const [],
    this.required = false,
    this.defaultValue = '',
    this.hiddenViews = const [],
    this.position = 0,
    this.version = 1,
    this.archivedAt = '',
  });

  final String id;
  final String projectId;
  final String name;
  final FieldType type;
  final List<FieldOption> options;
  final bool required;

  /// In the wire form (see [fieldDisplay]); empty for none.
  final String defaultValue;
  final List<String> hiddenViews;
  final int position;
  final int version;
  final String archivedAt;

  bool get isArchived => archivedAt.isNotEmpty;

  bool shownIn(String view) => !hiddenViews.contains(view);

  /// A new task must be given a value for it: required, and nothing fills it.
  bool get needsValueOnCreate => required && defaultValue.isEmpty;

  FieldOption? option(String id) =>
      options.where((o) => o.id == id).firstOrNull;
}

/// What the editor sends: a whole definition.
@immutable
class FieldDraft {
  const FieldDraft({
    required this.name,
    required this.type,
    this.options = const [],
    this.required = false,
    this.defaultValue = '',
    this.hiddenViews = const [],
  });

  final String name;
  final FieldType type;
  final List<FieldOption> options;
  final bool required;
  final String defaultValue;
  final List<String> hiddenViews;

  factory FieldDraft.of(CustomField f) => FieldDraft(
    name: f.name,
    type: f.type,
    options: f.options,
    required: f.required,
    defaultValue: f.defaultValue,
    hiddenViews: f.hiddenViews,
  );

  /// Option ids that [other] (the saved field) has and this draft dropped.
  Set<String> removedOptionsFrom(CustomField other) {
    final kept = {for (final o in options) o.id};
    return {
      for (final o in other.options)
        if (!kept.contains(o.id)) o.id,
    };
  }
}

enum FieldFailure {
  invalid,
  required,
  nameTaken,
  limit,
  needsRemap,
  conflict,
  denied,
  forbidden,
  archived,
  notFound,
  network,
  other,
}

class FieldException implements Exception {
  const FieldException(
    this.failure, {
    this.detail,
    this.usage = const {},
    this.fieldIds = const [],
  });

  final FieldFailure failure;
  final String? detail;

  /// For [FieldFailure.needsRemap]: removed option id -> values that hold it.
  final Map<String, int> usage;

  /// For [FieldFailure.required]: the fields that are missing a value.
  final List<String> fieldIds;

  @override
  String toString() => 'FieldException($failure, $detail)';
}

String fieldErrorMessage(Object error) {
  if (error is! FieldException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    FieldFailure.invalid => error.detail ?? 'Check the values and try again.',
    FieldFailure.required => error.detail ?? 'A required field has no value.',
    FieldFailure.nameTaken => 'A field with that name already exists.',
    FieldFailure.limit =>
      'A project can have at most $maxActiveFields active fields.',
    FieldFailure.needsRemap =>
      'Some removed options are still used: choose what their values become.',
    FieldFailure.conflict =>
      'Someone else changed this field first; reload and try again.',
    FieldFailure.denied => error.detail ?? 'You do not have permission.',
    FieldFailure.forbidden => 'You do not have permission to do that.',
    FieldFailure.archived =>
      'This project is archived. Restore it to make changes.',
    FieldFailure.notFound => 'That field no longer exists.',
    FieldFailure.network =>
      'Cannot reach the server. Check your connection and try again.',
    FieldFailure.other => 'Something went wrong. Try again.',
  };
}

// ----------------------------------------------------------------- values
//
// A value travels as one string: text and url as typed, number and money as
// decimal strings (never floats; money is "12.50 USD"), select as an option
// id, multi-select as ids joined by commas, date as YYYY-MM-DD, checkbox as
// true/false, user as a user id. Empty means no value.

List<String> splitIds(String wire) => [
  for (final p in wire.split(','))
    if (p.trim().isNotEmpty) p.trim(),
];

final _decimal = RegExp(r'^-?\d+(\.\d+)?$');
final _currency = RegExp(r'^[A-Za-z]{3}$');

/// Splits money into amount and currency ("12.50 USD"); both empty if unset.
({String amount, String currency}) splitMoney(String wire) {
  final parts = wire.trim().split(RegExp(r'\s+'));
  if (wire.trim().isEmpty) return (amount: '', currency: '');
  return (
    amount: parts.first,
    currency: parts.length > 1 ? parts[1].toUpperCase() : '',
  );
}

String joinMoney(String amount, String currency) => amount.trim().isEmpty
    ? ''
    : '${amount.trim()} ${currency.trim().toUpperCase()}';

/// A message when [wire] is not a valid value for [type], else null. The
/// server checks again; this keeps obvious mistakes from a round trip.
String? validateFieldValue(FieldType type, String wire) {
  final v = wire.trim();
  if (v.isEmpty) return null;
  switch (type) {
    case FieldType.number:
      return _decimal.hasMatch(v) ? null : 'Enter a number.';
    case FieldType.money:
      final m = splitMoney(v);
      if (!_decimal.hasMatch(m.amount)) return 'Enter an amount.';
      return _currency.hasMatch(m.currency)
          ? null
          : 'Enter a 3-letter currency, e.g. USD.';
    case FieldType.url:
      final uri = Uri.tryParse(v);
      final ok =
          uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
      return ok ? null : 'Enter a web address starting with http(s)://';
    case FieldType.date:
      return DateTime.tryParse(v) == null ? 'Use YYYY-MM-DD.' : null;
    case FieldType.text:
    case FieldType.select:
    case FieldType.multiselect:
    case FieldType.checkbox:
    case FieldType.user:
      return null;
  }
}

/// [wire] as a short text for a row or a conflict dialog. [userLabel] names a
/// user id.
String fieldDisplay(
  CustomField field,
  String wire, {
  String Function(String id)? userLabel,
}) {
  if (wire.isEmpty) return '';
  return switch (field.type) {
    FieldType.select => field.option(wire)?.label ?? '',
    FieldType.multiselect =>
      splitIds(wire)
          .map((id) => field.option(id)?.label ?? '')
          .where((l) => l.isNotEmpty)
          .join(', '),
    FieldType.checkbox => wire == 'true' ? 'Yes' : 'No',
    FieldType.user => userLabel?.call(wire) ?? wire,
    _ => wire,
  };
}
