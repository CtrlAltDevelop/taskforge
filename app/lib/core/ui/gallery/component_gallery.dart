import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/gallery/gallery_sections.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// The look a gallery page is drawn in.
class GalleryLook {
  const GalleryLook({
    this.brightness = Brightness.light,
    this.highContrast = false,
    this.density = TfDensity.comfortable,
    this.rtl = false,
    this.textScale = 1,
    this.language = 'en',
  });

  final Brightness brightness;
  final bool highContrast;
  final TfDensity density;
  final bool rtl;
  final double textScale;

  /// Sample text script: 'en', 'fa' or 'ar'.
  final String language;

  GalleryLook copyWith({
    Brightness? brightness,
    bool? highContrast,
    TfDensity? density,
    bool? rtl,
    double? textScale,
    String? language,
  }) => GalleryLook(
    brightness: brightness ?? this.brightness,
    highContrast: highContrast ?? this.highContrast,
    density: density ?? this.density,
    rtl: rtl ?? this.rtl,
    textScale: textScale ?? this.textScale,
    language: language ?? this.language,
  );
}

/// Every Tf* component in every state, in the chosen look. Debug-only
/// (`/debug/gallery`); the one place designers and reviewers look.
class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  GalleryLook _look = const GalleryLook();

  @override
  Widget build(BuildContext context) {
    final bar = Wrap(
      spacing: TfSpace.md,
      runSpacing: TfSpace.sm,
      children: [
        TfSegmented<Brightness>(
          options: const {Brightness.light: 'Light', Brightness.dark: 'Dark'},
          value: _look.brightness,
          onChanged: (b) =>
              setState(() => _look = _look.copyWith(brightness: b)),
        ),
        TfSegmented<bool>(
          options: const {false: 'Normal', true: 'High contrast'},
          value: _look.highContrast,
          onChanged: (v) =>
              setState(() => _look = _look.copyWith(highContrast: v)),
        ),
        TfSegmented<TfDensity>(
          options: const {
            TfDensity.comfortable: 'Comfortable',
            TfDensity.compact: 'Compact',
          },
          value: _look.density,
          onChanged: (d) => setState(() => _look = _look.copyWith(density: d)),
        ),
        TfSegmented<bool>(
          options: const {false: 'LTR', true: 'RTL'},
          value: _look.rtl,
          onChanged: (v) => setState(() => _look = _look.copyWith(rtl: v)),
        ),
        TfSegmented<String>(
          options: const {'en': 'English', 'fa': 'فارسی', 'ar': 'العربية'},
          value: _look.language,
          onChanged: (l) => setState(
            () => _look = _look.copyWith(language: l, rtl: l != 'en'),
          ),
        ),
        TfSegmented<int>(
          options: const {1: '100%', 2: '200%'},
          value: _look.textScale.round(),
          onChanged: (s) =>
              setState(() => _look = _look.copyWith(textScale: s.toDouble())),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Component gallery')),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(TfSpace.md), child: bar),
          Expanded(child: GalleryBody(look: _look)),
        ],
      ),
    );
  }
}

/// The gallery sections in [look]; tests pump this directly for the sweeps.
class GalleryBody extends StatelessWidget {
  const GalleryBody({super.key, required this.look});

  final GalleryLook look;

  @override
  Widget build(BuildContext context) {
    final theme = buildAppTheme(
      brightness: look.brightness,
      density: look.density,
      highContrast: look.highContrast,
    );
    return Theme(
      data: theme,
      child: Directionality(
        textDirection: look.rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(look.textScale)),
          child: Builder(
            builder: (context) => ColoredBox(
              color: context.tf.colors.canvas,
              child: ListView(
                key: const Key('gallery-list'),
                padding: const EdgeInsets.all(TfSpace.lg),
                children: gallerySections(context, look.language),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
