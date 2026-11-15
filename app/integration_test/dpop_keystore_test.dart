// The device key in the real platform keystore (macOS login keychain, Windows/Linux secret
// store, Keychain/Keystore on phones): made once, found again by a new store, forgotten on reset.
// Run on a device: `flutter test integration_test/dpop_keystore_test.dart -d macos`.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskforge/core/auth/dpop/dpop_key.dart';
import 'package:taskforge/core/auth/dpop/dpop_key_store_native.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the key persists in the platform keystore and signs', (
    tester,
  ) async {
    final first = NativeDpopKeyStore();
    await first.reset();
    final made = await first.signer();
    final thumbprint = jwkThumbprint(made.publicJwk);

    // A new store (a relaunch) finds the same key.
    final again = await NativeDpopKeyStore().signer();
    expect(jwkThumbprint(again.publicJwk), thumbprint);
    expect(made.publicJwk['crv'], 'P-256');

    final signature = await again.sign(Uint8List.fromList([1, 2, 3]));
    expect(signature.length, 64); // raw r || s

    // Forgetting it makes a different key next time.
    await first.reset();
    final fresh = await NativeDpopKeyStore().signer();
    expect(jwkThumbprint(fresh.publicJwk), isNot(thumbprint));
    await NativeDpopKeyStore().reset();
  });
}
