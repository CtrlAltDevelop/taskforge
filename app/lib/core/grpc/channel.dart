// Picks the right channel for the platform: gRPC-Web in browsers, native elsewhere.
export 'package:taskforge/core/grpc/channel_native.dart'
    if (dart.library.js_interop) 'channel_web.dart';
