import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/breakpoints.dart';

void main() {
  test('width maps to the three screen sizes at their boundaries', () {
    expect(ScreenSize.ofWidth(390), ScreenSize.compact);
    expect(ScreenSize.ofWidth(599.9), ScreenSize.compact);
    expect(ScreenSize.ofWidth(600), ScreenSize.medium);
    expect(ScreenSize.ofWidth(1023.9), ScreenSize.medium);
    expect(ScreenSize.ofWidth(1024), ScreenSize.expanded);
  });

  test('the theme builds in both brightnesses with its own colour scheme', () {
    for (final b in Brightness.values) {
      final theme = buildAppTheme(brightness: b);
      expect(theme.colorScheme.brightness, b);
      expect(theme.useMaterial3, isTrue);
    }
  });
}
