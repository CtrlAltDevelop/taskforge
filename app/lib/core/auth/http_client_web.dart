import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// In a browser the refresh token lives in an HttpOnly cookie, so requests must
/// carry credentials for the cookie to be sent and stored.
http.Client createAuthHttpClient() => BrowserClient()..withCredentials = true;
