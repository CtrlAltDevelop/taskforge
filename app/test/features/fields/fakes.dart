import 'package:taskforge/features/fields/data/fields_client.dart';
import 'package:taskforge/features/fields/domain/field.dart';

CustomField field(
  String id,
  String name,
  FieldType type, {
  List<FieldOption> options = const [],
  bool required = false,
  String defaultValue = '',
  List<String> hidden = const [],
  int position = 0,
  int version = 1,
  String archivedAt = '',
  String project = 'p1',
}) => CustomField(
  id: id,
  projectId: project,
  name: name,
  type: type,
  options: options,
  required: required,
  defaultValue: defaultValue,
  hiddenViews: hidden,
  position: position,
  version: version,
  archivedAt: archivedAt,
);

const bug = FieldOption(id: 'o-bug', label: 'Bug', color: '#E5484D');
const feature = FieldOption(id: 'o-feat', label: 'Feature');

/// In-memory fields server. [usage] says how many values hold each option, so
/// removing one without a remap is refused like the real server does.
class FakeFieldsClient implements FieldsClient {
  FakeFieldsClient([List<CustomField> initial = const []])
    : fields = [...initial];

  final List<CustomField> fields;
  final created = <FieldDraft>[];
  final remaps = <Map<String, String>>[];
  final archivedIds = <String>[];
  final restoredIds = <String>[];
  final orders = <List<String>>[];
  Map<String, int> usage = {};
  FieldException? failNext;

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<List<CustomField>> list(
    String workspaceId,
    String projectId, {
    bool includeArchived = false,
  }) async => [
    for (final f in fields)
      if (f.projectId == projectId && (includeArchived || !f.isArchived)) f,
  ];

  @override
  Future<CustomField> create(
    String workspaceId,
    String projectId,
    FieldDraft draft,
  ) async {
    _maybeFail();
    created.add(draft);
    final made = CustomField(
      id: 'f${fields.length + 1}',
      projectId: projectId,
      name: draft.name,
      type: draft.type,
      options: [
        for (final (i, o) in draft.options.indexed)
          FieldOption(
            id: o.id.isEmpty ? 'new-$i' : o.id,
            label: o.label,
            color: o.color,
          ),
      ],
      required: draft.required,
      defaultValue: draft.defaultValue,
      hiddenViews: draft.hiddenViews,
      position: fields.length,
    );
    fields.add(made);
    return made;
  }

  int _index(String id) => fields.indexWhere((f) => f.id == id);

  @override
  Future<CustomField> update(
    String workspaceId,
    CustomField field,
    FieldDraft draft, {
    Map<String, String> remap = const {},
  }) async {
    _maybeFail();
    final removed = draft.removedOptionsFrom(fields[_index(field.id)]);
    final used = {
      for (final id in removed)
        if ((usage[id] ?? 0) > 0) id: usage[id]!,
    };
    if (used.keys.any((id) => !remap.containsKey(id))) {
      throw FieldException(FieldFailure.needsRemap, usage: used);
    }
    remaps.add(remap);
    final next = CustomField(
      id: field.id,
      projectId: field.projectId,
      name: draft.name,
      type: draft.type,
      options: draft.options,
      required: draft.required,
      defaultValue: draft.defaultValue,
      hiddenViews: draft.hiddenViews,
      position: field.position,
      version: field.version + 1,
    );
    fields[_index(field.id)] = next;
    return next;
  }

  @override
  Future<List<CustomField>> reorder(
    String workspaceId,
    String projectId,
    List<String> ids,
  ) async {
    _maybeFail();
    orders.add(ids);
    final byId = {for (final f in fields) f.id: f};
    final rest = [
      for (final f in fields)
        if (!ids.contains(f.id)) f,
    ];
    fields
      ..clear()
      ..addAll([for (final id in ids) byId[id]!, ...rest]);
    return [
      for (final f in fields)
        if (!f.isArchived) f,
    ];
  }

  CustomField _set(CustomField f, String archivedAt) {
    final next = CustomField(
      id: f.id,
      projectId: f.projectId,
      name: f.name,
      type: f.type,
      options: f.options,
      required: f.required,
      defaultValue: f.defaultValue,
      hiddenViews: f.hiddenViews,
      position: f.position,
      version: f.version + 1,
      archivedAt: archivedAt,
    );
    fields[_index(f.id)] = next;
    return next;
  }

  @override
  Future<CustomField> archive(String workspaceId, CustomField field) async {
    _maybeFail();
    archivedIds.add(field.id);
    return _set(field, '2026-11-10T00:00:00Z');
  }

  @override
  Future<CustomField> restore(String workspaceId, CustomField field) async {
    _maybeFail();
    restoredIds.add(field.id);
    return _set(field, '');
  }
}
