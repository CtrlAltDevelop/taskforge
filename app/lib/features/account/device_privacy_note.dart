import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

/// What the app sends about this device at sign-in, and that the server may ignore it.
class DevicePrivacyNote extends StatelessWidget {
  const DevicePrivacyNote({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('device-privacy-note'),
    leading: const Icon(Icons.privacy_tip_outlined),
    title: Text(context.l10n.devPrivacyTitle),
    subtitle: Text(context.l10n.devPrivacyBody),
  );
}
