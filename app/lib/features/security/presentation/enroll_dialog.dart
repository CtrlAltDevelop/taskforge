import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/security/domain/security.dart';
import 'package:taskforge/features/security/presentation/code_dialogs.dart';
import 'package:taskforge/features/security/presentation/qr_view.dart';

/// Turns two-step verification on: scan the QR code (or type the key), prove
/// the app works with a code, then keep the ten recovery codes. Returns true
/// when it ended up on.
Future<bool?> showEnrollDialog(BuildContext context) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const _EnrollDialog(),
);

class _EnrollDialog extends ConsumerStatefulWidget {
  const _EnrollDialog();

  @override
  ConsumerState<_EnrollDialog> createState() => _EnrollDialogState();
}

class _EnrollDialogState extends ConsumerState<_EnrollDialog> {
  final _code = TextEditingController();
  TotpEnrolment? _enrolment;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _begin();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _begin() async {
    try {
      final enrolment = await ref.read(securityClientProvider).begin();
      if (mounted) setState(() => _enrolment = enrolment);
    } on Object catch (e) {
      if (mounted) {
        setState(() => _error = securityErrorMessage(e, context.l10n));
      }
    }
  }

  Future<void> _confirm() async {
    final t = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final codes = await ref
          .read(securityClientProvider)
          .confirm(_code.text.trim());
      if (!mounted) return;
      await showRecoveryCodes(context, codes);
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = securityErrorMessage(e, t);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final enrolment = _enrolment;
    return AlertDialog(
      title: Text(t.secEnrollTitle),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: enrolment == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error == null)
                      const CircularProgressIndicator()
                    else
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.secScanQr),
                    const SizedBox(height: 12),
                    Center(
                      child: QrView(
                        key: const Key('sec-qr'),
                        data: enrolment.otpauthUri,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(t.secOrTypeKey),
                    CopyableValue(
                      value: enrolment.secret,
                      copyKey: const Key('sec-secret-copy'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('sec-enroll-code'),
                      controller: _code,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t.secEnterCode),
                      onSubmitted: (_) => _busy ? null : _confirm(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(t.grpBCancel),
        ),
        FilledButton(
          key: const Key('sec-enroll-go'),
          onPressed: enrolment == null || _busy ? null : _confirm,
          child: Text(t.secTurnOn),
        ),
      ],
    );
  }
}
