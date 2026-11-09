import 'dart:convert';

/// A JWT-shaped string whose `exp` claim is [expiry]; the signature is not real.
String fakeJwt(DateTime expiry) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part({'exp': expiry.millisecondsSinceEpoch ~/ 1000})}.sig';
}
