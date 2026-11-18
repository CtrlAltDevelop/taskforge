import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/tokens/motion.dart';

/// A row that was removed from a list after it had been shown: kept for one
/// [TfDuration.base] as a ghost that fades and collapses, then dropped.
class TfGhost {
  const TfGhost(this.id, this.child);

  final String id;

  /// The row as it was last built.
  final Widget child;
}

/// Remembers the rows a list built and the entries of its last build, so a row
/// that disappears can play out as a [TfGhost] ([TfRemoveOut]). Only rows
/// removed after the first settled paint get one (cached or still-streaming
/// data never animates), and nothing is kept when motion is reduced, so
/// removal is then instant.
///
/// Per build: `final items = removals.update(entries, ...)`, build each entry
/// row through [remember], and build each [TfGhost] with [ghostRow].
class TfRemovals<E extends Object> {
  TfRemovals(this.idOf);

  /// The id of an entry that can be removed; null for entries that cannot
  /// (group headers, the inline add field).
  final String? Function(E entry) idOf;

  List<E>? _previous;
  final _built = <String, Widget>{};
  final _ghosts = <String, int>{};

  /// [entries] with a [TfGhost] spliced in where each just-removed row was.
  List<Object> update(
    List<E> entries, {
    bool settled = true,
    bool reduced = false,
  }) {
    final ids = {for (final e in entries) ?idOf(e)};
    final previous = _previous;
    _previous = entries;
    _ghosts.removeWhere((id, _) => ids.contains(id));
    if (reduced || !settled || previous == null) {
      _ghosts.clear();
      _built.removeWhere((id, _) => !ids.contains(id));
      return entries;
    }
    for (var i = 0; i < previous.length; i++) {
      final id = idOf(previous[i]);
      if (id != null && !ids.contains(id) && _built.containsKey(id)) {
        _ghosts.putIfAbsent(id, () => i);
      }
    }
    _built.removeWhere(
      (id, _) => !ids.contains(id) && !_ghosts.containsKey(id),
    );
    final merged = <Object>[...entries];
    final byPlace = _ghosts.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    for (final g in byPlace) {
      merged.insert(
        g.value.clamp(0, merged.length),
        TfGhost(g.key, _built[g.key]!),
      );
    }
    return merged;
  }

  /// Forget everything: the list went away and comes back as a first paint.
  void reset() {
    _previous = null;
    _built.clear();
    _ghosts.clear();
  }

  /// Notes [row] as what [id] looks like now, and returns it.
  Widget remember(String id, Widget row) => _built[id] = row;

  /// The ghost's widget; [onGone] must rebuild the list.
  Widget ghostRow(TfGhost ghost, VoidCallback onGone) => TfRemoveOut(
    key: ValueKey('ghost-${ghost.id}'),
    onDone: () {
      _ghosts.remove(ghost.id);
      _built.remove(ghost.id);
      onGone();
    },
    child: ghost.child,
  );
}

/// Plays a removed row out: fades and collapses over [TfDuration.base], then
/// calls [onDone]. Takes no input and is invisible to screen readers.
class TfRemoveOut extends StatefulWidget {
  const TfRemoveOut({super.key, required this.child, required this.onDone});

  final Widget child;
  final VoidCallback onDone;

  @override
  State<TfRemoveOut> createState() => _TfRemoveOutState();
}

class _TfRemoveOutState extends State<TfRemoveOut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TfDuration.base,
  );
  late final Animation<double> _gone = CurvedAnimation(
    parent: _controller,
    curve: tfCurve,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: FadeTransition(
        opacity: ReverseAnimation(_gone),
        child: SizeTransition(
          sizeFactor: ReverseAnimation(_gone),
          alignment: Alignment.topCenter,
          child: widget.child,
        ),
      ),
    ),
  );
}
