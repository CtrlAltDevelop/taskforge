import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped whenever a mutating call is refused for lack of permission. The
/// permission, role and member providers watch it, so a stale gate re-reads
/// after the first refusal. Reads never bump it (a refused read would loop).
final refusalCountProvider = NotifierProvider<RefusalCount, int>(
  RefusalCount.new,
);

class RefusalCount extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
