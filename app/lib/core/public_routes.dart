/// The routes of the web build that anyone may open, signed in or not. They
/// render without login chrome and send no credentials; the router's redirect
/// and any later auth or DPoP layer exempt them from this one list.
const publicAppPrefixes = <String>[
  '/f/', // a public intake form
  '/sso/', // where the identity provider's redirect lands (no token yet)
  '/two-factor', // the code prompt of a sign-in in progress
  '/update-required', // the blocking screen for an app older than the server's minimum
];

/// The API paths that answer anyone, with no credential. Mirrors
/// `backend/src/infrastructure/common/public_routes.py`; DPoP proofs are left off these
/// (nothing signed in to bind), except the ones in [dpopIssuingPrefixes].
const publicApiPrefixes = <String>[
  '/api/health',
  '/api/version',
  '/api/v1/health/',
  '/metrics',
  '/api/public/', // public intake forms
  '/api/v1/public/',
  '/api/v1/auth/sso/',
  '/api/v1/auth/2fa/challenge',
  '/api/v1/auth/2fa/verify',
  '/api/docs',
  '/api/v1/docs',
  '/api/v1/openapi.json',
];

/// The public routes that finish a sign-in, so the session they issue is bound to this device's
/// key: they still carry a proof.
const dpopIssuingPrefixes = <String>[
  '/api/v1/auth/sso/',
  '/api/v1/auth/2fa/verify',
];

/// Whether a request to API [path] carries a DPoP proof. Everything does except the public
/// routes (health, version, public forms, docs), which stay proof-free.
bool dpopApplies(String path) =>
    dpopIssuingPrefixes.any(path.startsWith) ||
    !publicApiPrefixes.any(path.startsWith);

/// Whether [path] is one of the public pages (a public intake form).
bool isPublicAppPath(String path) =>
    publicAppPrefixes.any((prefix) => path.startsWith(prefix));
