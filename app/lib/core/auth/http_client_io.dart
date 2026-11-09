import 'package:http/http.dart' as http;

/// Mobile and desktop keep the refresh token in secure storage; no cookies involved.
http.Client createAuthHttpClient() => http.Client();
