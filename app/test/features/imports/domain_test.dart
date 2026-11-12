import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:taskforge/features/imports/data/imports_client.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/gen/infrastructure/imports/grpc/imports.pbgrpc.dart'
    as pb;

import 'fakes.dart';

void main() {
  group('ImportMapping', () {
    test('round trips through the server JSON', () {
      final mapping = proposed(projectId: 'p1');
      final back = ImportMapping.fromJson(mapping.toJson(csv: true));
      expect(back.projectId, 'p1');
      expect(back.columns, mapping.columns);
      expect(back.statuses, mapping.statuses);
      expect(back.users['bob@old.test'], 'placeholder');
      expect(back.labels, isTrue);
    });

    test('names a new project in the target and upper-cases its key', () {
      const m = ImportMapping(newName: ' Shop ', newKey: 'shp');
      final json = jsonDecode(m.toJson()) as Map<String, dynamic>;
      expect(json['target'], {'name': 'Shop', 'key': 'SHP'});
      expect(
        json.containsKey('columns'),
        isFalse,
      ); // only CSV sources send them
    });

    test('says what is wrong before asking the server', () {
      expect(const ImportMapping().problemFor(null), 'Name the new project.');
      expect(
        const ImportMapping(newName: 'x', newKey: '1ab').problemFor(null),
        contains('project key'),
      );
      expect(
        const ImportMapping(
          newName: 'x',
          newKey: 'ABC',
        ).problemFor(ImportSource.csv),
        'Choose the column that holds the title.',
      );
      expect(
        const ImportMapping(
          newName: 'x',
          newKey: 'ABC',
          columns: {'title': 'Name'},
        ).problemFor(ImportSource.csv),
        isNull,
      );
      expect(
        const ImportMapping(projectId: 'p').problemFor(ImportSource.jiraJson),
        isNull,
      );
    });

    test('reads an empty or partial mapping', () {
      expect(ImportMapping.fromJson('').intoNewProject, isTrue);
      final m = ImportMapping.fromJson('{"target": {"project_id": "p"}}');
      expect(m.intoNewProject, isFalse);
      expect(m.statuses, isEmpty);
    });
  });

  group('ImportAnalysis', () {
    test('reads what the server found', () {
      final a = ImportAnalysis.fromJson(
        jsonEncode({
          'issues': 3,
          'statuses': {'To Do': 2},
          'people': {'a@x.test': 'Ann'},
          'sprints': ['S1'],
          'columns': ['Name'],
          'sample': [
            {'id': 'a', 'title': 'T'},
          ],
        }),
      );
      expect(a.issues, 3);
      expect(a.statuses, {'To Do': 2});
      expect(a.people['a@x.test'], 'Ann');
      expect(a.sample.single['title'], 'T');
      expect(ImportAnalysis.fromJson('').issues, 0);
    });
  });

  group('ImportJob', () {
    test('knows what may be done to it', () {
      expect(job('a', status: 'running').isActive, isTrue);
      expect(job('a', status: 'done').canUndo, isTrue);
      expect(job('a', status: 'failed').canResume, isTrue);
      expect(job('a', status: 'cancelled').canResume, isTrue);
      expect(job('a', status: 'undone').canUndo, isFalse);
      expect(job('a', status: 'analyzed').canUndo, isFalse);
      expect(job('a', status: 'done').isFinished, isTrue);
    });

    test('progress is a fraction that never leaves 0..1', () {
      expect(job('a', total: 0).progress, 0);
      expect(job('a', total: 4, done: 1).progress, 0.25);
      expect(job('a', total: 4, done: 9).progress, 1);
      expect(job('a', stats: {'tasks': 7}).stat('tasks'), 7);
      expect(job('a').kind, ImportSource.jiraCsv);
    });
  });

  test('sizes are said in words', () {
    expect(humanSize(12), '12 B');
    expect(humanSize(2048), '2 KB');
    expect(humanSize(5 * 1024 * 1024), '5.0 MB');
    expect(humanSize(3 * 1024 * 1024 * 1024), '3.0 GB');
  });

  group('server adapter', () {
    test('maps a job and an export', () {
      final j = jobFromPb(
        pb.Job(
          id: 'j',
          source: 'csv',
          status: 'running',
          total: 10,
          done: 3,
          statsJson: '{"tasks": 3}',
          problemCount: 2,
        ),
      );
      expect((j.done, j.total, j.stat('tasks'), j.problemCount), (3, 10, 3, 2));
      final e = exportFromPb(
        pb.ExportJob(
          id: 'e',
          status: 'done',
          downloadPath: '/x',
          statsJson: '',
        ),
      );
      expect(e.isDone && e.downloadPath == '/x', isTrue);
      expect(
        problemFromPb(pb.Problem(line: 2, message: 'm', level: 'warning'))
            .isError,
        isFalse,
      );
    });

    test('maps refusals to failures', () {
      expect(
        mapImportError(GrpcError.invalidArgument('INVALID_ARGUMENT: bad'))
            .detail,
        'bad',
      );
      expect(
        mapImportError(GrpcError.permissionDenied()).failure,
        ImportFailure.denied,
      );
      expect(
        mapImportError(GrpcError.notFound()).failure,
        ImportFailure.notFound,
      );
      expect(
        mapImportError(GrpcError.aborted('x')).failure,
        ImportFailure.conflict,
      );
      expect(
        mapImportError(GrpcError.unavailable()).failure,
        ImportFailure.network,
      );
      expect(mapImportError(GrpcError.internal()).failure, ImportFailure.other);
      expect(mapImportError(StateError('x')).failure, ImportFailure.network);
    });

    test('says each failure in words', () {
      for (final f in ImportFailure.values) {
        expect(importErrorMessage(ImportException(f)), isNotEmpty);
      }
      expect(
        importErrorMessage(
          const ImportException(ImportFailure.invalid, detail: 'Bad row.'),
        ),
        'Bad row.',
      );
      expect(importErrorMessage(StateError('x')), isNotEmpty);
    });
  });
}
