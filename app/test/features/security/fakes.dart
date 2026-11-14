import 'package:taskforge/features/security/data/security_client.dart';
import 'package:taskforge/features/security/domain/security.dart';

/// A security client that answers "no two-factor requirement" and nothing else: the router
/// asks for the policy of every workspace it opens, so app-level tests need it.
class FakeSecurityClient implements SecurityClient {
  FakeSecurityClient({this.policyAnswer = SecurityPolicy.none});

  SecurityPolicy policyAnswer;

  @override
  Future<SecurityPolicy> policy(String workspaceId) async => policyAnswer;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeSecurityClient.${invocation.memberName}');
}
