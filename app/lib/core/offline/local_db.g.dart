// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $CachedRowsTable extends CachedRows
    with TableInfo<$CachedRowsTable, CachedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    workspaceId,
    kind,
    id,
    scope,
    version,
    json,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId, kind, id};
  @override
  CachedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRow(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $CachedRowsTable createAlias(String alias) {
    return $CachedRowsTable(attachedDatabase, alias);
  }
}

class CachedRow extends DataClass implements Insertable<CachedRow> {
  final String workspaceId;
  final String kind;
  final String id;
  final String scope;
  final int version;
  final String json;
  final DateTime savedAt;
  const CachedRow({
    required this.workspaceId,
    required this.kind,
    required this.id,
    required this.scope,
    required this.version,
    required this.json,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['kind'] = Variable<String>(kind);
    map['id'] = Variable<String>(id);
    map['scope'] = Variable<String>(scope);
    map['version'] = Variable<int>(version);
    map['json'] = Variable<String>(json);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  CachedRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedRowsCompanion(
      workspaceId: Value(workspaceId),
      kind: Value(kind),
      id: Value(id),
      scope: Value(scope),
      version: Value(version),
      json: Value(json),
      savedAt: Value(savedAt),
    );
  }

  factory CachedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRow(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      kind: serializer.fromJson<String>(json['kind']),
      id: serializer.fromJson<String>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      version: serializer.fromJson<int>(json['version']),
      json: serializer.fromJson<String>(json['json']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'kind': serializer.toJson<String>(kind),
      'id': serializer.toJson<String>(id),
      'scope': serializer.toJson<String>(scope),
      'version': serializer.toJson<int>(version),
      'json': serializer.toJson<String>(json),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  CachedRow copyWith({
    String? workspaceId,
    String? kind,
    String? id,
    String? scope,
    int? version,
    String? json,
    DateTime? savedAt,
  }) => CachedRow(
    workspaceId: workspaceId ?? this.workspaceId,
    kind: kind ?? this.kind,
    id: id ?? this.id,
    scope: scope ?? this.scope,
    version: version ?? this.version,
    json: json ?? this.json,
    savedAt: savedAt ?? this.savedAt,
  );
  CachedRow copyWithCompanion(CachedRowsCompanion data) {
    return CachedRow(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      version: data.version.present ? data.version.value : this.version,
      json: data.json.present ? data.json.value : this.json,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRow(')
          ..write('workspaceId: $workspaceId, ')
          ..write('kind: $kind, ')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('version: $version, ')
          ..write('json: $json, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(workspaceId, kind, id, scope, version, json, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRow &&
          other.workspaceId == this.workspaceId &&
          other.kind == this.kind &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.version == this.version &&
          other.json == this.json &&
          other.savedAt == this.savedAt);
}

class CachedRowsCompanion extends UpdateCompanion<CachedRow> {
  final Value<String> workspaceId;
  final Value<String> kind;
  final Value<String> id;
  final Value<String> scope;
  final Value<int> version;
  final Value<String> json;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const CachedRowsCompanion({
    this.workspaceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.version = const Value.absent(),
    this.json = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRowsCompanion.insert({
    required String workspaceId,
    required String kind,
    required String id,
    this.scope = const Value.absent(),
    this.version = const Value.absent(),
    required String json,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       kind = Value(kind),
       id = Value(id),
       json = Value(json),
       savedAt = Value(savedAt);
  static Insertable<CachedRow> custom({
    Expression<String>? workspaceId,
    Expression<String>? kind,
    Expression<String>? id,
    Expression<String>? scope,
    Expression<int>? version,
    Expression<String>? json,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (kind != null) 'kind': kind,
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (version != null) 'version': version,
      if (json != null) 'json': json,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRowsCompanion copyWith({
    Value<String>? workspaceId,
    Value<String>? kind,
    Value<String>? id,
    Value<String>? scope,
    Value<int>? version,
    Value<String>? json,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return CachedRowsCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      kind: kind ?? this.kind,
      id: id ?? this.id,
      scope: scope ?? this.scope,
      version: version ?? this.version,
      json: json ?? this.json,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRowsCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('kind: $kind, ')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('version: $version, ')
          ..write('json: $json, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxRowsTable extends OutboxRows
    with TableInfo<$OutboxRowsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedVersionMeta = const VerificationMeta(
    'expectedVersion',
  );
  @override
  late final GeneratedColumn<int> expectedVersion = GeneratedColumn<int>(
    'expected_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _theirsMeta = const VerificationMeta('theirs');
  @override
  late final GeneratedColumn<String> theirs = GeneratedColumn<String>(
    'theirs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    projectId,
    entity,
    entityId,
    op,
    payload,
    expectedVersion,
    mutationId,
    state,
    error,
    theirs,
    attempts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('expected_version')) {
      context.handle(
        _expectedVersionMeta,
        expectedVersion.isAcceptableOrUnknown(
          data['expected_version']!,
          _expectedVersionMeta,
        ),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('theirs')) {
      context.handle(
        _theirsMeta,
        theirs.isAcceptableOrUnknown(data['theirs']!, _theirsMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      expectedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_version'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      )!,
      theirs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theirs'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxRowsTable createAlias(String alias) {
    return $OutboxRowsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int id;
  final String workspaceId;
  final String projectId;
  final String entity;
  final String entityId;
  final String op;
  final String payload;
  final int expectedVersion;
  final String mutationId;
  final String state;
  final String error;
  final String theirs;
  final int attempts;
  final DateTime createdAt;
  const OutboxRow({
    required this.id,
    required this.workspaceId,
    required this.projectId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payload,
    required this.expectedVersion,
    required this.mutationId,
    required this.state,
    required this.error,
    required this.theirs,
    required this.attempts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['project_id'] = Variable<String>(projectId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['payload'] = Variable<String>(payload);
    map['expected_version'] = Variable<int>(expectedVersion);
    map['mutation_id'] = Variable<String>(mutationId);
    map['state'] = Variable<String>(state);
    map['error'] = Variable<String>(error);
    map['theirs'] = Variable<String>(theirs);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxRowsCompanion toCompanion(bool nullToAbsent) {
    return OutboxRowsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      projectId: Value(projectId),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      payload: Value(payload),
      expectedVersion: Value(expectedVersion),
      mutationId: Value(mutationId),
      state: Value(state),
      error: Value(error),
      theirs: Value(theirs),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String>(json['payload']),
      expectedVersion: serializer.fromJson<int>(json['expectedVersion']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      state: serializer.fromJson<String>(json['state']),
      error: serializer.fromJson<String>(json['error']),
      theirs: serializer.fromJson<String>(json['theirs']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'projectId': serializer.toJson<String>(projectId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String>(payload),
      'expectedVersion': serializer.toJson<int>(expectedVersion),
      'mutationId': serializer.toJson<String>(mutationId),
      'state': serializer.toJson<String>(state),
      'error': serializer.toJson<String>(error),
      'theirs': serializer.toJson<String>(theirs),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxRow copyWith({
    int? id,
    String? workspaceId,
    String? projectId,
    String? entity,
    String? entityId,
    String? op,
    String? payload,
    int? expectedVersion,
    String? mutationId,
    String? state,
    String? error,
    String? theirs,
    int? attempts,
    DateTime? createdAt,
  }) => OutboxRow(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    projectId: projectId ?? this.projectId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    payload: payload ?? this.payload,
    expectedVersion: expectedVersion ?? this.expectedVersion,
    mutationId: mutationId ?? this.mutationId,
    state: state ?? this.state,
    error: error ?? this.error,
    theirs: theirs ?? this.theirs,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRow copyWithCompanion(OutboxRowsCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      expectedVersion: data.expectedVersion.present
          ? data.expectedVersion.value
          : this.expectedVersion,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      state: data.state.present ? data.state.value : this.state,
      error: data.error.present ? data.error.value : this.error,
      theirs: data.theirs.present ? data.theirs.value : this.theirs,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('expectedVersion: $expectedVersion, ')
          ..write('mutationId: $mutationId, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('theirs: $theirs, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    projectId,
    entity,
    entityId,
    op,
    payload,
    expectedVersion,
    mutationId,
    state,
    error,
    theirs,
    attempts,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.projectId == this.projectId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.expectedVersion == this.expectedVersion &&
          other.mutationId == this.mutationId &&
          other.state == this.state &&
          other.error == this.error &&
          other.theirs == this.theirs &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class OutboxRowsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> id;
  final Value<String> workspaceId;
  final Value<String> projectId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> payload;
  final Value<int> expectedVersion;
  final Value<String> mutationId;
  final Value<String> state;
  final Value<String> error;
  final Value<String> theirs;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  const OutboxRowsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.expectedVersion = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.theirs = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxRowsCompanion.insert({
    this.id = const Value.absent(),
    required String workspaceId,
    this.projectId = const Value.absent(),
    required String entity,
    required String entityId,
    required String op,
    required String payload,
    this.expectedVersion = const Value.absent(),
    required String mutationId,
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.theirs = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime createdAt,
  }) : workspaceId = Value(workspaceId),
       entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       payload = Value(payload),
       mutationId = Value(mutationId),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? id,
    Expression<String>? workspaceId,
    Expression<String>? projectId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<int>? expectedVersion,
    Expression<String>? mutationId,
    Expression<String>? state,
    Expression<String>? error,
    Expression<String>? theirs,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (projectId != null) 'project_id': projectId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (expectedVersion != null) 'expected_version': expectedVersion,
      if (mutationId != null) 'mutation_id': mutationId,
      if (state != null) 'state': state,
      if (error != null) 'error': error,
      if (theirs != null) 'theirs': theirs,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? workspaceId,
    Value<String>? projectId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? payload,
    Value<int>? expectedVersion,
    Value<String>? mutationId,
    Value<String>? state,
    Value<String>? error,
    Value<String>? theirs,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
  }) {
    return OutboxRowsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      expectedVersion: expectedVersion ?? this.expectedVersion,
      mutationId: mutationId ?? this.mutationId,
      state: state ?? this.state,
      error: error ?? this.error,
      theirs: theirs ?? this.theirs,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (expectedVersion.present) {
      map['expected_version'] = Variable<int>(expectedVersion.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (theirs.present) {
      map['theirs'] = Variable<String>(theirs.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRowsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('projectId: $projectId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('expectedVersion: $expectedVersion, ')
          ..write('mutationId: $mutationId, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('theirs: $theirs, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OfflineMetaTable extends OfflineMeta
    with TableInfo<$OfflineMetaTable, OfflineMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  OfflineMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $OfflineMetaTable createAlias(String alias) {
    return $OfflineMetaTable(attachedDatabase, alias);
  }
}

class OfflineMetaData extends DataClass implements Insertable<OfflineMetaData> {
  final String key;
  final String value;
  const OfflineMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  OfflineMetaCompanion toCompanion(bool nullToAbsent) {
    return OfflineMetaCompanion(key: Value(key), value: Value(value));
  }

  factory OfflineMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  OfflineMetaData copyWith({String? key, String? value}) =>
      OfflineMetaData(key: key ?? this.key, value: value ?? this.value);
  OfflineMetaData copyWithCompanion(OfflineMetaCompanion data) {
    return OfflineMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class OfflineMetaCompanion extends UpdateCompanion<OfflineMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const OfflineMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<OfflineMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return OfflineMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $CachedRowsTable cachedRows = $CachedRowsTable(this);
  late final $OutboxRowsTable outboxRows = $OutboxRowsTable(this);
  late final $OfflineMetaTable offlineMeta = $OfflineMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedRows,
    outboxRows,
    offlineMeta,
  ];
}

typedef $$CachedRowsTableCreateCompanionBuilder = CachedRowsCompanion Function({
  required String workspaceId,
  required String kind,
  required String id,
  Value<String> scope,
  Value<int> version,
  required String json,
  required DateTime savedAt,
  Value<int> rowid,
});
typedef $$CachedRowsTableUpdateCompanionBuilder = CachedRowsCompanion Function({
  Value<String> workspaceId,
  Value<String> kind,
  Value<String> id,
  Value<String> scope,
  Value<int> version,
  Value<String> json,
  Value<DateTime> savedAt,
  Value<int> rowid,
});

class $$CachedRowsTableFilterComposer
    extends Composer<_$LocalDb, $CachedRowsTable> {
  $$CachedRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRowsTableOrderingComposer
    extends Composer<_$LocalDb, $CachedRowsTable> {
  $$CachedRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRowsTableAnnotationComposer
    extends Composer<_$LocalDb, $CachedRowsTable> {
  $$CachedRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$CachedRowsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $CachedRowsTable,
          CachedRow,
          $$CachedRowsTableFilterComposer,
          $$CachedRowsTableOrderingComposer,
          $$CachedRowsTableAnnotationComposer,
          $$CachedRowsTableCreateCompanionBuilder,
          $$CachedRowsTableUpdateCompanionBuilder,
          (CachedRow, BaseReferences<_$LocalDb, $CachedRowsTable, CachedRow>),
          CachedRow,
          PrefetchHooks Function()
        > {
  $$CachedRowsTableTableManager(_$LocalDb db, $CachedRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRowsCompanion(
                workspaceId: workspaceId,
                kind: kind,
                id: id,
                scope: scope,
                version: version,
                json: json,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                required String kind,
                required String id,
                Value<String> scope = const Value.absent(),
                Value<int> version = const Value.absent(),
                required String json,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedRowsCompanion.insert(
                workspaceId: workspaceId,
                kind: kind,
                id: id,
                scope: scope,
                version: version,
                json: json,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedRowsTable, CachedRow>(table),
                  BaseReferences<_$LocalDb, $CachedRowsTable, CachedRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $CachedRowsTable,
      CachedRow,
      $$CachedRowsTableFilterComposer,
      $$CachedRowsTableOrderingComposer,
      $$CachedRowsTableAnnotationComposer,
      $$CachedRowsTableCreateCompanionBuilder,
      $$CachedRowsTableUpdateCompanionBuilder,
      (CachedRow, BaseReferences<_$LocalDb, $CachedRowsTable, CachedRow>),
      CachedRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxRowsTableCreateCompanionBuilder = OutboxRowsCompanion Function({
  Value<int> id,
  required String workspaceId,
  Value<String> projectId,
  required String entity,
  required String entityId,
  required String op,
  required String payload,
  Value<int> expectedVersion,
  required String mutationId,
  Value<String> state,
  Value<String> error,
  Value<String> theirs,
  Value<int> attempts,
  required DateTime createdAt,
});
typedef $$OutboxRowsTableUpdateCompanionBuilder = OutboxRowsCompanion Function({
  Value<int> id,
  Value<String> workspaceId,
  Value<String> projectId,
  Value<String> entity,
  Value<String> entityId,
  Value<String> op,
  Value<String> payload,
  Value<int> expectedVersion,
  Value<String> mutationId,
  Value<String> state,
  Value<String> error,
  Value<String> theirs,
  Value<int> attempts,
  Value<DateTime> createdAt,
});

class $$OutboxRowsTableFilterComposer
    extends Composer<_$LocalDb, $OutboxRowsTable> {
  $$OutboxRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedVersion => $composableBuilder(
    column: $table.expectedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theirs => $composableBuilder(
    column: $table.theirs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxRowsTableOrderingComposer
    extends Composer<_$LocalDb, $OutboxRowsTable> {
  $$OutboxRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedVersion => $composableBuilder(
    column: $table.expectedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theirs => $composableBuilder(
    column: $table.theirs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxRowsTableAnnotationComposer
    extends Composer<_$LocalDb, $OutboxRowsTable> {
  $$OutboxRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get expectedVersion => $composableBuilder(
    column: $table.expectedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get theirs =>
      $composableBuilder(column: $table.theirs, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxRowsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $OutboxRowsTable,
          OutboxRow,
          $$OutboxRowsTableFilterComposer,
          $$OutboxRowsTableOrderingComposer,
          $$OutboxRowsTableAnnotationComposer,
          $$OutboxRowsTableCreateCompanionBuilder,
          $$OutboxRowsTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$LocalDb, $OutboxRowsTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxRowsTableTableManager(_$LocalDb db, $OutboxRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> expectedVersion = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> error = const Value.absent(),
                Value<String> theirs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxRowsCompanion(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                entity: entity,
                entityId: entityId,
                op: op,
                payload: payload,
                expectedVersion: expectedVersion,
                mutationId: mutationId,
                state: state,
                error: error,
                theirs: theirs,
                attempts: attempts,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String workspaceId,
                Value<String> projectId = const Value.absent(),
                required String entity,
                required String entityId,
                required String op,
                required String payload,
                Value<int> expectedVersion = const Value.absent(),
                required String mutationId,
                Value<String> state = const Value.absent(),
                Value<String> error = const Value.absent(),
                Value<String> theirs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required DateTime createdAt,
              }) => OutboxRowsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                projectId: projectId,
                entity: entity,
                entityId: entityId,
                op: op,
                payload: payload,
                expectedVersion: expectedVersion,
                mutationId: mutationId,
                state: state,
                error: error,
                theirs: theirs,
                attempts: attempts,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxRowsTable, OutboxRow>(table),
                  BaseReferences<_$LocalDb, $OutboxRowsTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $OutboxRowsTable,
      OutboxRow,
      $$OutboxRowsTableFilterComposer,
      $$OutboxRowsTableOrderingComposer,
      $$OutboxRowsTableAnnotationComposer,
      $$OutboxRowsTableCreateCompanionBuilder,
      $$OutboxRowsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$LocalDb, $OutboxRowsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$OfflineMetaTableCreateCompanionBuilder =
    OfflineMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$OfflineMetaTableUpdateCompanionBuilder =
    OfflineMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$OfflineMetaTableFilterComposer
    extends Composer<_$LocalDb, $OfflineMetaTable> {
  $$OfflineMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineMetaTableOrderingComposer
    extends Composer<_$LocalDb, $OfflineMetaTable> {
  $$OfflineMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineMetaTableAnnotationComposer
    extends Composer<_$LocalDb, $OfflineMetaTable> {
  $$OfflineMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$OfflineMetaTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $OfflineMetaTable,
          OfflineMetaData,
          $$OfflineMetaTableFilterComposer,
          $$OfflineMetaTableOrderingComposer,
          $$OfflineMetaTableAnnotationComposer,
          $$OfflineMetaTableCreateCompanionBuilder,
          $$OfflineMetaTableUpdateCompanionBuilder,
          (
            OfflineMetaData,
            BaseReferences<_$LocalDb, $OfflineMetaTable, OfflineMetaData>,
          ),
          OfflineMetaData,
          PrefetchHooks Function()
        > {
  $$OfflineMetaTableTableManager(_$LocalDb db, $OfflineMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => OfflineMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => OfflineMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OfflineMetaTable, OfflineMetaData>(table),
                  BaseReferences<_$LocalDb, $OfflineMetaTable, OfflineMetaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $OfflineMetaTable,
      OfflineMetaData,
      $$OfflineMetaTableFilterComposer,
      $$OfflineMetaTableOrderingComposer,
      $$OfflineMetaTableAnnotationComposer,
      $$OfflineMetaTableCreateCompanionBuilder,
      $$OfflineMetaTableUpdateCompanionBuilder,
      (
        OfflineMetaData,
        BaseReferences<_$LocalDb, $OfflineMetaTable, OfflineMetaData>,
      ),
      OfflineMetaData,
      PrefetchHooks Function()
    >;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$CachedRowsTableTableManager get cachedRows =>
      $$CachedRowsTableTableManager(_db, _db.cachedRows);
  $$OutboxRowsTableTableManager get outboxRows =>
      $$OutboxRowsTableTableManager(_db, _db.outboxRows);
  $$OfflineMetaTableTableManager get offlineMeta =>
      $$OfflineMetaTableTableManager(_db, _db.offlineMeta);
}
