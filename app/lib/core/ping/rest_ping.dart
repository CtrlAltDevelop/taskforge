import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ping_client.dart';

class RestPing implements PingClient {
  RestPing(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  String get label => 'REST';

  @override
  Future<String> ping() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/api/v1/health/live'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body);
    return body is Map
        ? (body['data']?['status'] ?? body['status'] ?? 'ok').toString()
        : 'ok';
  }
}
