// Picks the HTTP client for auth calls: in a browser it must send cookies.
export 'package:taskforge/core/auth/http_client_io.dart'
    if (dart.library.js_interop) 'package:taskforge/core/auth/http_client_web.dart';
