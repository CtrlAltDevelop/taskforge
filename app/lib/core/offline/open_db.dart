// Opens the local database where the platform has one (files on mobile and
// desktop); the browser has none yet, so the app stays online-only there.
export 'package:taskforge/core/offline/open_db_native.dart'
    if (dart.library.js_interop) 'open_db_web.dart';
