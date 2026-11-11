import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/features/search/data/search_client.dart';
import 'package:taskforge/features/search/domain/search.dart';

import 'fakes.dart';

void main() {
  test('operators are added once and taken away again', () {
    expect(toggleOperator('login', 'status:open'), 'login status:open');
    expect(toggleOperator('login status:open', 'status:open'), 'login');
    expect(hasOperator('a assignee:me', 'assignee:me'), isTrue);
    expect(hasOperator('a assignee:mel', 'assignee:me'), isFalse);
  });

  test('each kind of hit goes where it lives', () {
    expect(taskHit('a', 'T').location, '/projects/p1?task=a');
    expect(
      const SearchHit(
        kind: SearchKind.project,
        id: 'p9',
        projectId: 'p9',
        title: 'P',
      ).location,
      '/projects/p9',
    );
    expect(
      const SearchHit(kind: SearchKind.member, id: 'u', title: 'U').location,
      '/members',
    );
  });

  test('results list the jump first, then the kinds in order', () {
    final results = SearchResults(
      jump: taskHit('j', 'Jump'),
      hits: {
        SearchKind.project: [
          const SearchHit(kind: SearchKind.project, id: 'p', title: 'P'),
        ],
        SearchKind.task: [taskHit('a', 'A')],
      },
    );

    expect(results.ordered.map((h) => h.id), ['j', 'a', 'p']);
    expect(const SearchResults().isEmpty, isTrue);
  });

  test('server refusals become what the box can say', () {
    expect(
      mapSearchError(GrpcError.resourceExhausted('RATE_LIMITED: slow')).failure,
      SearchFailure.rateLimited,
    );
    expect(
      mapSearchError(GrpcError.invalidArgument('VALIDATION_ERROR: Too long')),
      isA<SearchException>().having((e) => e.detail, 'detail', 'Too long'),
    );
    expect(
      mapSearchError(GrpcError.permissionDenied()).failure,
      SearchFailure.denied,
    );
    expect(
      mapSearchError(GrpcError.unavailable()).failure,
      SearchFailure.network,
    );
    expect(mapSearchError(GrpcError.internal()).failure, SearchFailure.other);
    expect(
      searchErrorMessage(const SearchException(SearchFailure.rateLimited)),
      contains('Too many'),
    );
  });
}
