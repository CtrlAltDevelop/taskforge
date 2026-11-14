import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Draws [data] as a QR code: dark modules on a white square with the quiet
/// zone a scanner needs, whatever the theme.
class QrView extends StatelessWidget {
  const QrView({super.key, required this.data, this.size = 200});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(QrCode(payload: QrPayload.fromString(data)));
    return Semantics(
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _QrPainter(image)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  static const _quietModules = 2;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final modules = image.moduleCount + _quietModules * 2;
    final cell = size.shortestSide / modules;
    final ink = Paint()..color = Colors.black;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (!image.isDark(row, col)) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            (col + _quietModules) * cell,
            (row + _quietModules) * cell,
            cell + 0.5, // overlap a little so no seams show
            cell + 0.5,
          ),
          ink,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}
