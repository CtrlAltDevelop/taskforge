import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/security/domain/security.dart';
import 'package:taskforge/gen/infrastructure/security/grpc/security.pbgrpc.dart'
    as pb;

/// Two-step verification, the workspace's two-factor policy and single sign-on
/// setup over gRPC. Signing in with a code or through SSO is REST
/// (`SecondFactorApi`): there is no bearer token yet.
abstract interface class SecurityClient {
  Future<SecondFactorStatus> status();
  Future<TotpEnrolment> begin();

  /// Turns it on; returns the ten recovery codes, shown once.
  Future<List<String>> confirm(String code);
  Future<void> disable(String code);
  Future<List<String>> regenerateCodes(String code);

  /// Forgets one trusted device, or all of them when [deviceId] is empty.
  Future<void> revokeDevice(String deviceId);

  Future<SecurityPolicy> policy(String workspaceId);
  Future<SecurityPolicy> setPolicy(
    String workspaceId, {
    required bool require2fa,
    required int graceDays,
    required int expectedVersion,
  });

  Future<SsoProvider> provider(String workspaceId);
  Future<SsoProvider> saveProvider(String workspaceId, SsoDraft draft);
  Future<void> deleteProvider(String workspaceId);
  Future<SsoCheck> testProvider(String workspaceId);
}

/// What the setup form sends. An empty [clientSecret] keeps the stored one.
class SsoDraft {
  const SsoDraft({
    required this.name,
    required this.issuer,
    required this.clientId,
    required this.clientSecret,
    required this.scopes,
    required this.allowedDomains,
    required this.groupClaim,
    required this.groupRoles,
    required this.defaultRoleId,
    required this.autoCreateUsers,
    required this.enabled,
    required this.enforceSso,
    required this.expectedVersion,
  });

  final String name;
  final String issuer;
  final String clientId;
  final String clientSecret;
  final String scopes;
  final List<String> allowedDomains;
  final String groupClaim;
  final List<RoleMapping> groupRoles;
  final String defaultRoleId;
  final bool autoCreateUsers;
  final bool enabled;
  final bool enforceSso;
  final int expectedVersion;
}

SecurityException mapSecurityError(Object error) {
  if (error is SecurityException) return error;
  if (error is GrpcError) {
    final text = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(text)?.group(1);
    final message = text.replaceFirst(RegExp(r'^[A-Z][A-Z0-9_]*: '), '');
    if (title == 'INVALID_CODE') {
      return const SecurityException(SecurityFailure.invalidCode);
    }
    if (title == 'SECOND_FACTOR_LOCKED') {
      return const SecurityException(SecurityFailure.locked);
    }
    return switch (error.code) {
      StatusCode.invalidArgument => SecurityException(
        SecurityFailure.invalid,
        message,
      ),
      StatusCode.alreadyExists ||
      StatusCode.aborted => const SecurityException(SecurityFailure.conflict),
      StatusCode.resourceExhausted => const SecurityException(
        SecurityFailure.locked,
      ),
      StatusCode.permissionDenied => const SecurityException(
        SecurityFailure.denied,
      ),
      StatusCode.notFound => const SecurityException(SecurityFailure.notFound),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const SecurityException(SecurityFailure.network),
      _ => const SecurityException(SecurityFailure.other),
    };
  }
  return const SecurityException(SecurityFailure.other);
}

DateTime? _time(String iso) => iso.isEmpty ? null : DateTime.tryParse(iso);

SecurityPolicy policyFromPb(pb.PolicyAnswer a) => SecurityPolicy(
  require2fa: a.require2fa,
  graceDays: a.graceDays,
  enforcedFrom: _time(a.enforcedFrom),
  inGrace: a.inGrace,
  enrolled: a.enrolled,
  blocked: a.blocked,
  version: a.version,
);

SsoProvider providerFromPb(pb.ProviderAnswer a) {
  final p = a.provider;
  return SsoProvider(
    configured: p.configured,
    name: p.name,
    issuer: p.issuer,
    clientId: p.clientId,
    hasSecret: p.hasSecret,
    scopes: p.scopes,
    allowedDomains: List.unmodifiable(p.allowedDomains),
    groupClaim: p.groupClaim,
    groupRoles: List.unmodifiable([
      for (final m in p.groupRoles)
        RoleMapping(group: m.group, roleId: m.roleId),
    ]),
    defaultRoleId: p.defaultRoleId,
    autoCreateUsers: p.autoCreateUsers,
    enabled: p.enabled,
    enforceSso: p.enforceSso,
    version: p.version,
    redirectUri: p.redirectUri,
  );
}

class GrpcSecurityClient implements SecurityClient {
  GrpcSecurityClient(ClientChannelBase channel, this._session)
    : _factor = pb.SecondFactorControllerClient(channel),
      _policy = pb.SecurityPolicyControllerClient(channel),
      _sso = pb.SsoControllerClient(channel);

  final pb.SecondFactorControllerClient _factor;
  final pb.SecurityPolicyControllerClient _policy;
  final pb.SsoControllerClient _sso;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapSecurityError(e);
    }
  }

  @override
  Future<SecondFactorStatus> status() => _run(() async {
    final r = await _factor.status(
      pb.SecondFactorStatusRequest(),
      options: _options,
    );
    return SecondFactorStatus(
      enabled: r.enabled,
      unusedRecoveryCodes: r.unusedRecoveryCodes,
      devices: List.unmodifiable([
        for (final d in r.trustedDevices)
          TrustedDevice(
            id: d.id,
            label: d.label,
            createdAt: _time(d.createdAt),
            lastUsedAt: _time(d.lastUsedAt),
            expiresAt: _time(d.expiresAt),
          ),
      ]),
    );
  });

  @override
  Future<TotpEnrolment> begin() => _run(() async {
    final r = await _factor.begin(
      pb.SecondFactorBeginRequest(),
      options: _options,
    );
    return TotpEnrolment(secret: r.secret, otpauthUri: r.otpauthUri);
  });

  @override
  Future<List<String>> confirm(String code) => _run(() async {
    final r = await _factor.confirm(
      pb.SecondFactorConfirmRequest(code: code),
      options: _options,
    );
    return List.unmodifiable(r.recoveryCodes);
  });

  @override
  Future<void> disable(String code) => _run(() async {
    await _factor.disable(
      pb.SecondFactorDisableRequest(code: code),
      options: _options,
    );
  });

  @override
  Future<List<String>> regenerateCodes(String code) => _run(() async {
    final r = await _factor.regenerateCodes(
      pb.SecondFactorRegenerateRequest(code: code),
      options: _options,
    );
    return List.unmodifiable(r.recoveryCodes);
  });

  @override
  Future<void> revokeDevice(String deviceId) => _run(() async {
    await _factor.revokeDevice(
      pb.RevokeDeviceRequest(deviceId: deviceId),
      options: _options,
    );
  });

  @override
  Future<SecurityPolicy> policy(String workspaceId) => _run(
    () async => policyFromPb(
      await _policy.get(
        pb.PolicyGetRequest(workspaceId: workspaceId),
        options: _options,
      ),
    ),
  );

  @override
  Future<SecurityPolicy> setPolicy(
    String workspaceId, {
    required bool require2fa,
    required int graceDays,
    required int expectedVersion,
  }) => _run(
    () async => policyFromPb(
      await _policy.set(
        pb.PolicySetRequest(
          workspaceId: workspaceId,
          require2fa: require2fa,
          graceDays: graceDays,
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<SsoProvider> provider(String workspaceId) => _run(
    () async => providerFromPb(
      await _sso.get(
        pb.SsoGetRequest(workspaceId: workspaceId),
        options: _options,
      ),
    ),
  );

  @override
  Future<SsoProvider> saveProvider(String workspaceId, SsoDraft d) => _run(
    () async => providerFromPb(
      await _sso.save(
        pb.SsoSaveRequest(
          workspaceId: workspaceId,
          name: d.name,
          issuer: d.issuer,
          clientId: d.clientId,
          clientSecret: d.clientSecret,
          scopes: d.scopes,
          allowedDomains: d.allowedDomains,
          groupClaim: d.groupClaim,
          groupRoles: [
            for (final m in d.groupRoles)
              pb.RoleMapping(group: m.group, roleId: m.roleId),
          ],
          defaultRoleId: d.defaultRoleId,
          autoCreateUsers: d.autoCreateUsers,
          enabled: d.enabled,
          enforceSso: d.enforceSso,
          expectedVersion: d.expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> deleteProvider(String workspaceId) => _run(() async {
    await _sso.delete(
      pb.SsoDeleteRequest(workspaceId: workspaceId),
      options: _options,
    );
  });

  @override
  Future<SsoCheck> testProvider(String workspaceId) => _run(() async {
    final r = await _sso.test(
      pb.SsoTestRequest(workspaceId: workspaceId),
      options: _options,
    );
    return SsoCheck(
      ok: r.ok,
      message: r.message,
      keys: r.keys,
      redirectUri: r.redirectUri,
    );
  });
}
