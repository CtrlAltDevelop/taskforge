import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// The platform's own client, under the proof-adding wrapper `main` installs for `http.Client()`.
http.Client createBaseHttpClient() => IOClient();

/// Mobile and desktop keep the refresh token in secure storage; no cookies involved.
http.Client createAuthHttpClient() => http.Client();
