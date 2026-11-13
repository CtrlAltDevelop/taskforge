import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:taskforge/features/forms/domain/forms.dart';

/// How long a call may take before it counts as a lost connection. A send can
/// carry files, so it gets longer.
const readTimeout = Duration(seconds: 20);
const sendTimeout = Duration(seconds: 90);

/// The anonymous side of forms: read a form by its token, send it. Plain REST
/// with no sign-in, no cookies and no authorization header, on purpose.
abstract interface class PublicFormsClient {
  Future<PublicForm> fetch(String token);

  /// Sends the answers; returns the reference code and nothing else.
  Future<String> submit(
    String token,
    FormAnswers answers, {
    String languageTag = '',
  });
}

class HttpPublicFormsClient implements PublicFormsClient {
  HttpPublicFormsClient({required this.restUrl, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String restUrl;
  final http.Client _http;

  Uri _uri(String token, [String tail = '']) =>
      Uri.parse('$restUrl/api/public/forms/${Uri.encodeComponent(token)}$tail');

  Map<String, dynamic> _body(http.Response response) {
    Map<String, dynamic> parsed = const {};
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) parsed = decoded;
    } on FormatException {
      // Not JSON: judged by the status alone.
    }
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final data = parsed['data'];
      return data is Map<String, dynamic> ? data : const {};
    }
    throw _failure(status, parsed);
  }

  FormsException _failure(int status, Map<String, dynamic> parsed) {
    final data = parsed['data'];
    final errors = parsed['errors'];
    final detail = errors is List && errors.isNotEmpty
        ? '${errors.first}'
        : null;
    switch (status) {
      case 404:
        return const FormsException(FormsFailure.notFound);
      case 429:
        return const FormsException(FormsFailure.tooMany);
      case 503:
        return const FormsException(FormsFailure.unavailable);
      case 422:
        return FormsException(
          FormsFailure.invalid,
          detail: detail,
          fieldProblems: _problems(data),
        );
      case 400:
        return const FormsException(FormsFailure.captcha);
      case 413:
        return FormsException(FormsFailure.invalid, detail: detail);
      default:
        return const FormsException(FormsFailure.other);
    }
  }

  Map<String, String> _problems(Object? data) {
    if (data is! Map<String, dynamic>) return const {};
    final raw = data['fields'];
    if (raw is! String) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return {for (final e in decoded.entries) e.key: '${e.value}'};
      }
    } on FormatException {
      // No per-field detail.
    }
    return const {};
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on TimeoutException {
      throw const FormsException(FormsFailure.network);
    } on http.ClientException {
      throw const FormsException(FormsFailure.network);
    }
  }

  PublicForm _form(Map<String, dynamic> d) {
    final captcha = d['captcha'];
    return PublicForm(
      name: '${d['name']}',
      description: '${d['description']}',
      brandColor: '${d['brand_color']}',
      logoUrl: '${d['logo_url']}',
      requireEmail: d['require_email'] == true,
      offersUpdates: d['offers_updates'] == true,
      questions: List.unmodifiable(
        (d['fields'] as List<dynamic>? ?? const []).map(
          (raw) => _question(raw as Map<String, dynamic>),
        ),
      ),
      captcha: captcha is Map<String, dynamic>
          ? CaptchaConfig('${captcha['provider']}', '${captcha['site_key']}')
          : null,
      maxFiles: (d['max_files'] as num?)?.toInt() ?? 0,
      maxFileBytes: (d['max_file_bytes'] as num?)?.toInt() ?? 0,
    );
  }

  PublicQuestion _question(Map<String, dynamic> q) => PublicQuestion(
    id: '${q['id']}',
    kind: QuestionKind.parse('${q['kind']}'),
    label: '${q['label']}',
    help: '${q['help']}',
    required: q['required'] == true,
    type: '${q['type']}',
    options: List.unmodifiable(
      (q['options'] as List<dynamic>? ?? const []).map(
        (o) => PublicOption('${(o as Map)['id']}', '${o['label']}'),
      ),
    ),
    maxFiles: (q['max_files'] as num?)?.toInt() ?? 0,
  );

  @override
  Future<PublicForm> fetch(String token) => _guard(() async {
    final response = await _http.get(_uri(token)).timeout(readTimeout);
    return _form(_body(response));
  });

  @override
  Future<String> submit(
    String token,
    FormAnswers answers, {
    String languageTag = '',
  }) => _guard(() async {
    final request = http.MultipartRequest('POST', _uri(token, '/submit'))
      ..fields['answers'] = jsonEncode(answers.values)
      ..fields['email'] = answers.email
      ..fields['website'] =
          '' // the honeypot: a person never fills it
      ..fields['captcha_token'] = answers.captchaToken;
    if (languageTag.isNotEmpty) {
      request.headers['Accept-Language'] = languageTag;
    }
    for (final entry in answers.files.entries) {
      for (final file in entry.value) {
        request.files.add(
          http.MultipartFile.fromBytes(
            entry.key,
            file.bytes,
            filename: file.name,
          ),
        );
      }
    }
    final streamed = await _http.send(request).timeout(sendTimeout);
    final response = await http.Response.fromStream(streamed);
    return '${_body(response)['reference']}';
  });
}
