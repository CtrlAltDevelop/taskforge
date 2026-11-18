import 'package:taskforge/core/ui/tf_app_bar.dart';

import 'package:taskforge/core/ui/tf_icons.dart';

import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart' as d;
import 'package:taskforge/features/dashboards/presentation/dashboard_grid.dart';
import 'package:taskforge/features/dashboards/presentation/widget_editor.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/features/home/application/home_providers.dart';

/// Dashboards of the workspace, or of one project: pick one, look at it, and
/// (for those who may) edit it, share it or start a new one from a template.
class DashboardsScreen extends ConsumerStatefulWidget {
  const DashboardsScreen({super.key, this.projectId = ''});

  final String projectId;

  @override
  ConsumerState<DashboardsScreen> createState() => _DashboardsScreenState();
}

class _DashboardsScreenState extends ConsumerState<DashboardsScreen> {
  String? _selected;
  d.Dashboard? _draft; // set while editing
  var _unsaved = <String>{};
  var _busy = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final every = ref.read(dashboardRefreshProvider);
    if (every != null) {
      _timer = Timer.periodic(
        every,
        (_) => ref.read(dashboardTickProvider.notifier).auto(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _editing => _draft != null;

  Future<void> _try(Future<void> Function() act) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await act();
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(d.dashboardErrorMessage(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A random (version 4) id: the server keeps a widget's id as its own, so it
  /// must not be guessable.
  String _newId() {
    final random = Random.secure();
    final b = List<int>.generate(16, (_) => random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String h(int from, int to) => [
      for (final x in b.sublist(from, to)) x.toRadixString(16).padLeft(2, '0'),
    ].join();
    return '${h(0, 4)}-${h(4, 6)}-${h(6, 8)}-${h(8, 10)}-${h(10, 16)}';
  }

  void _startEditing(d.Dashboard dash) => setState(() => _draft = dash);

  void _cancel() => setState(() {
    _draft = null;
    _unsaved = {};
  });

  Future<void> _save() => _try(() async {
    final draft = _draft;
    if (draft == null) return;
    final saved = await ref.read(dashboardActionsProvider).save(draft);
    if (!mounted) return;
    setState(() {
      _selected = saved.id;
      _draft = null;
      _unsaved = {};
    });
  });

  Future<void> _newBlank() async {
    final dash = d.Dashboard(
      id: '',
      name: context.l10n.grpCDashNew,
      visibility: d.DashVisibility.personal,
      projectId: widget.projectId,
      widgets: const [],
      layout: const [],
    );
    setState(() {
      _draft = dash;
      _unsaved = {};
    });
  }

  Future<void> _fromTemplate(String template) => _try(() async {
    final made = await ref
        .read(dashboardActionsProvider)
        .fromTemplate(template, projectId: widget.projectId);
    if (mounted) setState(() => _selected = made.id);
  });

  Future<void> _delete(d.Dashboard dash) => _try(() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.grpCDashDeleteTitle(dash.name)),
        content: Text(context.l10n.grpCDashDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.grpCCancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-dashboard'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.grpCDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(dashboardActionsProvider).delete(dash.id);
    if (mounted) setState(() => _selected = null);
  });

  Future<void> _addWidget() async {
    final draft = _draft;
    if (draft == null || draft.widgets.length >= d.maxWidgets) return;
    final id = _newId();
    final fresh = d.DashboardWidget(
      id: id,
      kind: d.WidgetKind.number,
      title: '',
      config: const d.WidgetConfig(),
    );
    final made = await showWidgetEditor(
      context,
      initial: fresh,
      projectId: draft.projectId,
    );
    if (made == null || !mounted) return;
    setState(() {
      _unsaved = {..._unsaved, id};
      _draft = draft.copyWith(
        widgets: [...draft.widgets, made],
        layout: d.addCell(draft.layout, id),
      );
    });
  }

  Future<void> _editWidget(d.DashboardWidget w) async {
    final draft = _draft;
    if (draft == null) return;
    final made = await showWidgetEditor(
      context,
      initial: w,
      projectId: draft.projectId,
    );
    if (made == null || !mounted) return;
    setState(() {
      _draft = draft.copyWith(
        widgets: [for (final x in draft.widgets) x.id == w.id ? made : x],
      );
      // A changed widget is read afresh once saved; until then it has no numbers.
      if (made.config != w.config || made.kind != w.kind) {
        _unsaved = {..._unsaved, w.id};
      }
    });
  }

  void _removeWidget(d.DashboardWidget w) {
    final draft = _draft;
    if (draft == null) return;
    setState(() {
      _unsaved = {..._unsaved}..remove(w.id);
      _draft = draft.copyWith(
        widgets: [
          for (final x in draft.widgets)
            if (x.id != w.id) x,
        ],
        layout: [
          for (final c in draft.layout)
            if (c.widgetId != w.id) c,
        ],
      );
    });
  }

  Future<void> _share() async {
    final draft = _draft;
    if (draft == null) return;
    final canShare = ref.read(permissionSetProvider).can(Perm.dashboardManage);
    final result =
        await showDialog<({String name, d.DashVisibility visibility})>(
          context: context,
          builder: (_) => _ShareDialog(
            name: draft.name,
            visibility: draft.visibility,
            canShare: canShare,
            hasProject: draft.projectId.isNotEmpty,
          ),
        );
    if (result == null || !mounted) return;
    setState(
      () => _draft = draft.copyWith(
        name: result.name.isEmpty ? draft.name : result.name,
        visibility: result.visibility,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.projectId.isEmpty
        ? null
        : ref.watch(projectProvider(widget.projectId));
    final list = ref.watch(dashboardsProvider(widget.projectId));
    return Scaffold(
      appBar: TfAppBar(
        title: Text(
          project == null
              ? context.l10n.grpCDashTitle
              : context.l10n.grpCDashTitleProject(project.name),
        ),
      ),
      body: switch (list) {
        AsyncData(:final value) => _body(context, value),
        AsyncError(:final error) => TfError(
          key: const Key('dashboards-error'),
          message: d.dashboardErrorMessage(error, context.l10n),
          details: '$error',
          retryKey: const Key('dashboards-retry'),
          onRetry: () => ref.invalidate(dashboardsProvider(widget.projectId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(BuildContext context, List<d.Dashboard> all) {
    final current =
        _draft ??
        all.where((x) => x.id == _selected).firstOrNull ??
        all.firstOrNull;
    return Column(
      children: [
        _toolbar(context, all, current),
        const Divider(height: 1),
        Expanded(
          child: current == null
              ? _empty()
              : DashboardGrid(
                  dashboard: current,
                  editing: _editing,
                  unsaved: _unsaved,
                  onLayout: (cells) =>
                      setState(() => _draft = _draft?.copyWith(layout: cells)),
                  onEdit: _editWidget,
                  onRemove: _removeWidget,
                ),
        ),
      ],
    );
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.grpCDashEmpty, key: const Key('dashboards-empty')),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _newButtons()),
      ],
    ),
  );

  List<Widget> _newButtons() => [
    OutlinedButton(
      key: const Key('new-blank'),
      onPressed: _busy ? null : _newBlank,
      child: Text(context.l10n.grpCDashBlankDashboard),
    ),
    if (widget.projectId.isNotEmpty)
      OutlinedButton(
        key: const Key('template-project_overview'),
        onPressed: _busy ? null : () => _fromTemplate('project_overview'),
        child: Text(context.l10n.grpCDashProjectOverview),
      ),
    OutlinedButton(
      key: const Key('template-my_work'),
      onPressed: _busy ? null : () => _fromTemplate('my_work'),
      child: Text(context.l10n.grpCDashMyWork),
    ),
  ];

  /// "Pin to Home" / "Unpin from Home": the dashboard shows on Home's Pinned
  /// card while pinned.
  Widget _pinButton(BuildContext context, d.Dashboard current) {
    final l = context.l10n;
    final pinned = ref.watch(pinnedDashboardIdsProvider).contains(current.id);
    return IconButton(
      key: const Key('pin-dashboard'),
      tooltip: pinned ? l.dashUnpinFromHome : l.dashPinToHome,
      isSelected: pinned,
      icon: TfIcon(pinned ? TfIcons.pinOff : TfIcons.pin, size: 24),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await ref.read(pinDashboardProvider)(current.id, pinned: !pinned);
          messenger.showSnackBar(
            SnackBar(content: Text(pinned ? l.dashUnpinned : l.dashPinned)),
          );
        } on Object {
          messenger.showSnackBar(SnackBar(content: Text(l.dashPinFailed)));
        }
      },
    );
  }

  Widget _toolbar(
    BuildContext context,
    List<d.Dashboard> all,
    d.Dashboard? current,
  ) => Padding(
    padding: const EdgeInsets.all(8),
    child: Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!_editing && all.isNotEmpty)
          DropdownButton<String>(
            key: const Key('dashboard-picker'),
            value: current?.id,
            items: [
              for (final x in all)
                DropdownMenuItem(value: x.id, child: Text(x.name)),
            ],
            onChanged: (v) => setState(() => _selected = v),
          ),
        if (_editing)
          Text(
            _draft!.name,
            key: const Key('dashboard-editing-name'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (!_editing)
          PopupMenuButton<String>(
            key: const Key('new-dashboard'),
            tooltip: context.l10n.grpCDashNew,
            icon: const TfIcon(TfIcons.plus, size: 24),
            onSelected: (v) => v == 'blank' ? _newBlank() : _fromTemplate(v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'blank',
                child: Text(context.l10n.grpCDashBlank),
              ),
              if (widget.projectId.isNotEmpty)
                PopupMenuItem(
                  value: 'project_overview',
                  child: Text(context.l10n.grpCDashProjectOverview),
                ),
              PopupMenuItem(
                value: 'my_work',
                child: Text(context.l10n.grpCDashMyWork),
              ),
            ],
          ),
        if (!_editing && current != null && current.canEdit)
          OutlinedButton.icon(
            key: const Key('edit-dashboard'),
            icon: const TfIcon(TfIcons.edit, size: 24),
            label: Text(context.l10n.grpCDashEdit),
            onPressed: () => _startEditing(current),
          ),
        if (!_editing && current != null)
          IconButton(
            key: const Key('refresh-all'),
            tooltip: context.l10n.grpCDashRefresh,
            icon: const TfIcon(TfIcons.refresh, size: 24),
            onPressed: () => ref.read(dashboardActionsProvider).refreshWidgets([
              for (final w in current.widgets)
                if (!_unsaved.contains(w.id)) (id: w.id, version: w.version),
            ]),
          ),
        if (!_editing && current != null) _pinButton(context, current),
        if (!_editing && current != null && current.canEdit)
          IconButton(
            key: const Key('delete-dashboard'),
            tooltip: context.l10n.grpCDelete,
            icon: const TfIcon(TfIcons.trash, size: 24),
            onPressed: _busy ? null : () => _delete(current),
          ),
        if (_editing) ...[
          OutlinedButton.icon(
            key: const Key('add-widget'),
            icon: const TfIcon(TfIcons.chart, size: 24),
            label: Text(context.l10n.grpCDashAddWidget),
            onPressed: _draft!.widgets.length >= d.maxWidgets
                ? null
                : _addWidget,
          ),
          OutlinedButton.icon(
            key: const Key('share-dashboard'),
            icon: const TfIcon(TfIcons.users, size: 24),
            label: Text(_draft!.visibility.labelIn(context.l10n)),
            onPressed: _share,
          ),
          FilledButton(
            key: const Key('save-dashboard'),
            onPressed: _busy ? null : _save,
            child: Text(context.l10n.grpCDashSave),
          ),
          TextButton(
            key: const Key('cancel-edit'),
            onPressed: _busy ? null : _cancel,
            child: Text(context.l10n.grpCCancel),
          ),
        ],
      ],
    ),
  );
}

/// Name and who may open it. Owns its text field, so the field outlives the
/// dialog's closing animation.
class _ShareDialog extends StatefulWidget {
  const _ShareDialog({
    required this.name,
    required this.visibility,
    required this.canShare,
    required this.hasProject,
  });

  final String name;
  final d.DashVisibility visibility;
  final bool canShare;
  final bool hasProject;

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  late final _name = TextEditingController(text: widget.name);
  late var _visibility = widget.visibility;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const Key('share-dialog'),
    title: Text(context.l10n.grpCDashDialogTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const Key('dashboard-name'),
          controller: _name,
          maxLength: 80,
          decoration: InputDecoration(labelText: context.l10n.grpCDashName),
        ),
        const SizedBox(height: 12),
        RadioGroup<d.DashVisibility>(
          groupValue: _visibility,
          onChanged: (x) => setState(() => _visibility = x ?? _visibility),
          child: Column(
            children: [
              for (final v in d.DashVisibility.values)
                RadioListTile<d.DashVisibility>(
                  key: Key('visibility-${v.wire}'),
                  value: v,
                  title: Text(v.labelIn(context.l10n)),
                  enabled:
                      (v == d.DashVisibility.personal || widget.canShare) &&
                      (v != d.DashVisibility.project || widget.hasProject),
                ),
            ],
          ),
        ),
        if (!widget.canShare)
          Text(
            context.l10n.grpCDashShareDenied,
            key: const Key('share-denied'),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpCCancel),
      ),
      FilledButton(
        key: const Key('share-ok'),
        onPressed: () => Navigator.pop(context, (
          name: _name.text.trim(),
          visibility: _visibility,
        )),
        child: Text(context.l10n.grpCDashOk),
      ),
    ],
  );
}
