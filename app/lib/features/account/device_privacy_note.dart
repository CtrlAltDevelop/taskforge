import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

/// What the app sends about this device at sign-in, and that the server may ignore it.
class DevicePrivacyNote extends StatelessWidget {
  const DevicePrivacyNote({super.key});

  @override
  Widget build(BuildContext context) => TfTile(
    key: const Key('device-privacy-note'),
    title: Text(context.l10n.devPrivacyTitle),
    subtitle: Text(context.l10n.devPrivacyBody),
    leading: const TfIcon(TfIcons.shield),
  );
}
