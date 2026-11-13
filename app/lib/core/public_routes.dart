/// The routes of the web build that anyone may open, signed in or not. They
/// render without login chrome and send no credentials; the router's redirect
/// and any later auth or DPoP layer exempt them from this one list.
const publicAppPrefixes = <String>['/f/'];

/// Whether [path] is one of the public pages (a public intake form).
bool isPublicAppPath(String path) =>
    publicAppPrefixes.any((prefix) => path.startsWith(prefix));
