import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/features/dashboards/presentation/widget_body.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Pick or change a widget: what it is, what it counts, and a live preview of
/// the numbers it would show (read from the server without saving).
Future<DashboardWidget?> showWidgetEditor(
  BuildContext context, {
  required DashboardWidget initial,
  required String projectId,
}) => showDialog<DashboardWidget>(
  context: context,
  builder: (_) => WidgetEditor(initial: initial, projectId: projectId),
);

class WidgetEditor extends ConsumerStatefulWidget {
  const WidgetEditor({
    super.key,
    required this.initial,
    required this.projectId,
  });

  final DashboardWidget initial;

  /// The dashboard's project ('' for a workspace dashboard).
  final String projectId;

  @override
  ConsumerState<WidgetEditor> createState() => _WidgetEditorState();
}

class _WidgetEditorState extends ConsumerState<WidgetEditor> {
  late DashboardWidget _w = widget.initial;
  late final _title = TextEditingController(text: widget.initial.title);
  late final _tfql = TextEditingController(text: widget.initial.config.tfql);
  Timer? _debounce;
  var _generation = 0;
  WidgetData? _preview;
  Object? _error;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _title.dispose();
    _tfql.dispose();
    super.dispose();
  }

  void _change(DashboardWidget next) {
    setState(() => _w = next);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _refreshPreview);
  }

  Future<void> _refreshPreview() async {
    final generation = ++_generation;
    setState(() => _loading = true);
    try {
      final data = await ref
          .read(dashboardActionsProvider)
          .preview(
            _w.config.projectId.isNotEmpty
                ? _w.config.projectId
                : widget.projectId,
            _w.kind,
            _w.config,
          );
      if (generation != _generation || !mounted) return;
      setState(() {
        _preview = data;
        _error = null;
        _loading = false;
      });
    } on Object catch (e) {
      if (generation != _generation || !mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _kind(WidgetKind kind) {
    var c = _w.config;
    if (kind == WidgetKind.number) c = c.copyWith(groupBy: '');
    if (kind.picksGrouping && c.groupBy.isEmpty) {
      c = c.copyWith(groupBy: 'status');
    }
    if (kind == WidgetKind.line && !timeGroupings.contains(c.groupBy)) {
      c = c.copyWith(groupBy: 'created_week');
    }
    if (kind == WidgetKind.workload) {
      c = c.copyWith(groupBy: 'assignee', scope: Scope.open);
    }
    _change(_w.copyWith(kind: kind, config: c));
  }

  void _config(WidgetConfig c) => _change(_w.copyWith(config: c));

  bool get _canSave {
    if (_w.kind.picksGrouping && _w.config.groupBy.isEmpty) return false;
    if (_w.kind == WidgetKind.burndown && _w.config.sprintId.isEmpty) {
      return false;
    }
    return _error == null && !_loading;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _w.kind == WidgetKind.line
        ? {for (final g in timeGroupings) g: groupings[g]!}
        : groupings;
    final project = _w.config.projectId.isNotEmpty
        ? _w.config.projectId
        : widget.projectId;
    return TfDialogFrame(
      key: const Key('widget-editor'),
      title: context.l10n.grpIWidget,
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('widget-title'),
                controller: _title,
                maxLength: 80,
                decoration: InputDecoration(labelText: context.l10n.grpITitle),
                onChanged: (v) => setState(() => _w = _w.copyWith(title: v)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TfSelectField(
                    key: const Key('widget-kind'),
                    options: {
                      for (final k in WidgetKind.values)
                        k: k.labelIn(context.l10n),
                    },
                    value: _w.kind,
                    onChanged: (k) => _kind(k),
                  ),
                  if (_w.kind != WidgetKind.burndown)
                    TfSelectField(
                      key: const Key('widget-measure'),
                      options: {
                        for (final m in Measure.values)
                          m: m.labelIn(context.l10n),
                      },
                      value: _w.config.measure,
                      onChanged: (m) => _config(_w.config.copyWith(measure: m)),
                    ),
                  if (_w.kind.picksGrouping || _w.kind == WidgetKind.line)
                    TfSelectField(
                      key: const Key('widget-group'),
                      options: {
                        for (final g in groups.entries)
                          g.key:
                              groupingLabelIn(context.l10n, g.key) ?? g.value,
                      },
                      value: groups.containsKey(_w.config.groupBy)
                          ? _w.config.groupBy
                          : null,
                      onChanged: (g) => _config(_w.config.copyWith(groupBy: g)),
                      hint: context.l10n.grpIGroupBy,
                    ),
                  if (_w.kind != WidgetKind.burndown &&
                      _w.kind != WidgetKind.workload)
                    TfSelectField(
                      key: const Key('widget-scope'),
                      options: {
                        for (final s in Scope.values)
                          s: s.labelIn(context.l10n),
                      },
                      value: _w.config.scope,
                      onChanged: (s) => _config(_w.config.copyWith(scope: s)),
                    ),
                ],
              ),
              if (_w.kind == WidgetKind.burndown) _sprintPicker(project),
              const SizedBox(height: 12),
              if (_w.kind != WidgetKind.burndown)
                TfTextField(
                  key: const Key('widget-tfql'),
                  controller: _tfql,
                  label: context.l10n.grpIFilterTfqlOptional,
                  hint: 'priority = high AND assignee = me',
                  onChanged: (v) =>
                      _config(_w.config.copyWith(tfql: v, filterId: '')),
                ),
              const SizedBox(height: 12),
              Text(
                context.l10n.grpIPreview,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(
                height: 200,
                child: _error != null
                    ? TfError(
                        key: const Key('preview-error'),
                        compact: true,
                        message: dashboardErrorMessage(_error!, context.l10n),
                      )
                    : _preview == null
                    ? const Center(child: CircularProgressIndicator())
                    : WidgetBody(widget: _w, data: _preview!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TfButton(
          label: context.l10n.grpICancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('widget-save'),
          label: context.l10n.grpIDone,
          variant: TfButtonVariant.primary,
          onPressed: _canSave
              ? () => Navigator.of(context).pop(_w.copyWith(title: _title.text))
              : null,
        ),
      ],
    );
  }

  Widget _sprintPicker(String project) {
    final projects =
        ref.watch(projectCatalogProvider(false)).value?.projects ?? const [];
    final chosen = _w.config.projectId.isNotEmpty
        ? _w.config.projectId
        : widget.projectId;
    final sprints = chosen.isEmpty
        ? null
        : ref.watch(sprintsProvider(chosen)).value;
    return Wrap(
      spacing: 12,
      children: [
        if (widget.projectId.isEmpty)
          TfSelectField(
            key: const Key('widget-project'),
            options: {for (final p in projects) p.id: p.name},
            value: projects.any((p) => p.id == chosen) ? chosen : null,
            onChanged: (p) =>
                _config(_w.config.copyWith(projectId: p, sprintId: '')),
            hint: context.l10n.grpIProject,
          ),
        TfSelectField(
          key: const Key('widget-sprint'),
          options: {for (final s in sprints ?? const []) s.id: s.name},
          value: sprints?.any((s) => s.id == _w.config.sprintId) == true
              ? _w.config.sprintId
              : null,
          onChanged: (s) => _config(_w.config.copyWith(sprintId: s ?? '')),
          hint: context.l10n.grpISprint,
        ),
      ],
    );
  }
}
