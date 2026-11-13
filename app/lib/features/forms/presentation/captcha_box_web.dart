import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'package:taskforge/features/forms/domain/forms.dart';

const _boxHeight = 90.0;
final _safeKey = RegExp(r'[^A-Za-z0-9_\-]');

String _frameHtml(CaptchaConfig config, String nonce) {
  final key = config.siteKey.replaceAll(_safeKey, '');
  final isTurnstile = config.provider == 'turnstile';
  final script = isTurnstile
      ? 'https://challenges.cloudflare.com/turnstile/v0/api.js'
      : 'https://js.hcaptcha.com/1/api.js';
  final widgetClass = isTurnstile ? 'cf-turnstile' : 'h-captcha';
  return '<!doctype html><html><body style="margin:0">'
      '<script src="$script" async defer></script>'
      '<script>function done(t){parent.postMessage('
      '{tfCaptcha:t,nonce:"$nonce"},"*")}</script>'
      '<div class="$widgetClass" data-sitekey="$key" '
      'data-callback="done"></div></body></html>';
}

/// The provider's own widget in an iframe; its answer comes back as a
/// message carrying a one-time nonce, so another frame cannot answer for it.
class CaptchaBox extends StatefulWidget {
  const CaptchaBox({super.key, required this.config, required this.onToken});

  final CaptchaConfig config;
  final ValueChanged<String> onToken;

  @override
  State<CaptchaBox> createState() => _CaptchaBoxState();
}

class _CaptchaBoxState extends State<CaptchaBox> {
  late final String _nonce = List.generate(
    16,
    (_) => Random.secure().nextInt(36).toRadixString(36),
  ).join();
  late final String _viewType = 'tf-captcha-$_nonce';
  late final JSFunction _listener;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final doc = globalContext.getProperty<JSObject>('document'.toJS);
      final frame = doc.callMethod<JSObject>(
        'createElement'.toJS,
        'iframe'.toJS,
      );
      frame.setProperty('srcdoc'.toJS, _frameHtml(widget.config, _nonce).toJS);
      final style = frame.getProperty<JSObject>('style'.toJS);
      style.setProperty('border'.toJS, '0'.toJS);
      style.setProperty('width'.toJS, '100%'.toJS);
      style.setProperty('height'.toJS, '100%'.toJS);
      return frame;
    });
    _listener = ((JSObject event) {
      final data = event.getProperty<JSAny?>('data'.toJS);
      if (data == null || !data.isA<JSObject>()) return;
      final map = data as JSObject;
      final nonce = map.getProperty<JSAny?>('nonce'.toJS).dartify();
      final token = map.getProperty<JSAny?>('tfCaptcha'.toJS).dartify();
      if (nonce == _nonce && token is String) widget.onToken(token);
    }).toJS;
    globalContext.callMethod<JSAny?>(
      'addEventListener'.toJS,
      'message'.toJS,
      _listener,
    );
  }

  @override
  void dispose() {
    globalContext.callMethod<JSAny?>(
      'removeEventListener'.toJS,
      'message'.toJS,
      _listener,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _boxHeight,
    child: HtmlElementView(viewType: _viewType),
  );
}
