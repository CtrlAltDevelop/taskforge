/// The routes of the web build that anyone may open, signed in or not. They
/// render without login chrome and send no credentials; the router's redirect
/// and any later auth or DPoP layer exempt them from this one list.
const publicAppPrefixes = <String>[
  '/f/', // a public intake form
  '/sso/', // where the identity provider's redirect lands (no token yet)
  '/two-factor', // the code prompt of a sign-in in progress
];

/// Whether [path] is one of the public pages (a public intake form).
bool isPublicAppPath(String path) =>
    publicAppPrefixes.any((prefix) => path.startsWith(prefix));
