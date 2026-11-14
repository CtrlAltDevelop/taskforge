import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/public_routes.dart';

void main() {
  test('public app paths', () {
    expect(isPublicAppPath('/f/abc'), isTrue);
    expect(isPublicAppPath('/sso/callback'), isTrue);
    expect(isPublicAppPath('/two-factor'), isTrue);
    expect(isPublicAppPath('/update-required'), isTrue);
    expect(isPublicAppPath('/tasks'), isFalse);
    expect(isPublicAppPath('/form/abc'), isFalse);
  });

  test('DPoP skips public API routes but not the issuing ones', () {
    expect(dpopApplies('/api/health'), isFalse);
    expect(dpopApplies('/api/version'), isFalse);
    expect(dpopApplies('/api/public/forms/x'), isFalse);
    expect(dpopApplies('/api/v1/auth/2fa/challenge'), isFalse);
    expect(dpopApplies('/api/v1/auth/sso/callback'), isTrue);
    expect(dpopApplies('/api/v1/auth/2fa/verify'), isTrue);
    expect(dpopApplies('/api/v1/tasks'), isTrue);
  });
}
