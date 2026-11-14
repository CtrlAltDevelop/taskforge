import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/dpop/dpop_http_client.dart';
import 'package:taskforge/core/auth/dpop/dpop_manager.dart';

/// The platform's own client, under the proof-adding wrapper `main` installs for `http.Client()`.
http.Client createBaseHttpClient() => BrowserClient();

/// In a browser the refresh token lives in an HttpOnly cookie, so requests must
/// carry credentials for the cookie to be sent and stored.
http.Client createAuthHttpClient() =>
    DpopHttpClient(BrowserClient()..withCredentials = true, DpopManager.shared);
