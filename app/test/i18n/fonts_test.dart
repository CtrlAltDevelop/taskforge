import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Arabic-script font ships with the app (not the system's) and keeps its
/// license beside it.
void main() {
  test('Vazirmatn is bundled, declared and licensed', () {
    final font = File('assets/fonts/Vazirmatn-Variable.ttf');
    expect(font.existsSync(), isTrue);
    final header = font.readAsBytesSync().sublist(0, 4);
    expect(header, [0x00, 0x01, 0x00, 0x00], reason: 'a TrueType file');
    expect(File('assets/fonts/OFL.txt').existsSync(), isTrue);

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: Vazirmatn'));
    expect(pubspec, contains('assets/fonts/Vazirmatn-Variable.ttf'));
  });
}
