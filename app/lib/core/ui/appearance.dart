import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

/// Density default: pointer platforms start compact, touch ones comfortable.
TfDensity defaultDensity() =>
    const {
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform)
    ? TfDensity.compact
    : TfDensity.comfortable;

/// Per-device choice of density, kept in the local prefs and applied live.
final densityProvider = NotifierProvider<DensityNotifier, TfDensity>(
  DensityNotifier.new,
);

class DensityNotifier extends Notifier<TfDensity> {
  static const _key = 'theme.density';
  var _chose = false; // a tap before the saved value arrives wins

  @override
  TfDensity build() {
    ref.read(localPrefsProvider).read(_key).then((saved) {
      final chosen = TfDensity.values.where((d) => d.name == saved).firstOrNull;
      if (ref.mounted && !_chose && chosen != null) state = chosen;
    });
    return defaultDensity();
  }

  void choose(TfDensity density) {
    _chose = true;
    state = density;
    ref.read(localPrefsProvider).write(_key, density.name);
  }
}

/// High-contrast variant of the light or dark look.
final contrastProvider = NotifierProvider<ContrastNotifier, bool>(
  ContrastNotifier.new,
);

class ContrastNotifier extends Notifier<bool> {
  static const _key = 'theme.contrast';
  var _chose = false;

  @override
  bool build() {
    ref.read(localPrefsProvider).read(_key).then((saved) {
      if (ref.mounted && !_chose && saved == 'high') state = true;
    });
    return false;
  }

  void choose({required bool high}) {
    _chose = true;
    state = high;
    ref.read(localPrefsProvider).write(_key, high ? 'high' : 'normal');
  }
}
