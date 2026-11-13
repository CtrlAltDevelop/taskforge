import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/forms/domain/forms.dart';

/// Only a browser can show a CAPTCHA; elsewhere the person is told so.
class CaptchaBox extends StatelessWidget {
  const CaptchaBox({super.key, required this.config, required this.onToken});

  final CaptchaConfig config;
  final ValueChanged<String> onToken;

  @override
  Widget build(BuildContext context) => Text(context.l10n.formsCaptchaWebOnly);
}
