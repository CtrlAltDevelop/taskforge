import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A person: initials on a colour taken from their id, so the same person
/// has the same colour everywhere. Colour never carries meaning; the name does.
class TfAvatar extends StatelessWidget {
  const TfAvatar({
    super.key,
    required this.name,
    this.colorSeed,
    this.size = 24,
  });

  final String name;

  /// Stable key for the colour (user id); the name when null.
  final String? colorSeed;
  final double size;

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final seed = (colorSeed ?? name).codeUnits.fold<int>(0, (a, b) => a + b);
    final fill = c.category(seed);
    return Semantics(
      label: name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: Text(
          initials(name),
          style: tf.typography.caption.copyWith(
            color: tfOnColor(fill),
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Overlapping avatars; the rest are summed in a "+N" bubble.
class TfAvatarStack extends StatelessWidget {
  const TfAvatarStack({
    super.key,
    required this.names,
    this.max = 3,
    this.size = 24,
  });

  final List<String> names;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final shown = names.take(max).toList();
    final more = names.length - shown.length;
    final step = size * 0.7;
    final overflowLabel = '+$more';
    final count = shown.length + (more > 0 ? 1 : 0);
    return Semantics(
      label: names.join(', '),
      excludeSemantics: true,
      child: SizedBox(
        width: count == 0 ? 0 : size + step * (count - 1),
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              PositionedDirectional(
                start: i * step,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: tf.colors.surface, width: 2),
                  ),
                  child: TfAvatar(name: shown[i], size: size),
                ),
              ),
            if (more > 0)
              PositionedDirectional(
                start: shown.length * step,
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tf.colors.neutral.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: tf.colors.surface, width: 2),
                  ),
                  child: Text(
                    overflowLabel,
                    style: tf.typography.tabular.copyWith(
                      color: tf.colors.neutral.fg,
                      fontSize: size * 0.38,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Gap used between avatars and text in rows.
const tfAvatarGap = TfSpace.sm;
