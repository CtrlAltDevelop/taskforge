import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Text and icons are anti-aliased a little differently on each OS and Flutter
/// version, so one layout differs by a few percent of pixels between a Mac and
/// a Linux CI runner. A moved, mirrored or missing element differs by far more
/// than this.
const goldenTolerance = 0.06;

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= goldenTolerance) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

/// Call from `setUpAll`: golden images in `test/i18n/goldens` then compare with
/// [goldenTolerance] instead of pixel for pixel.
void useTolerantGoldens() {
  if (goldenFileComparator is! LocalFileComparator) return;
  goldenFileComparator = _TolerantComparator(
    Uri.file('${Directory.current.path}/test/i18n/tolerant_golden.dart'),
  );
}
