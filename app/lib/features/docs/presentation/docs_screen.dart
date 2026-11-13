import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/presentation/doc_page.dart';
import 'package:taskforge/features/docs/presentation/doc_panels.dart';
import 'package:taskforge/features/docs/presentation/page_tree.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';

/// Width from which the tree sits beside the page; below it the tree is a
/// drawer (and the whole screen when no page is open).
const docsTreeBreakpoint = 820.0;

const _treeWidth = 280.0;

/// The docs space: a tree of pages and the page that is open.
class DocsScreen extends ConsumerWidget {
  const DocsScreen({super.key, this.docId, this.project = ''});

  final String? docId;

  /// '' for the workspace's pages.
  final String project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(permissionSetProvider).can(Perm.docEdit);
    final query = project.isEmpty ? '' : '?project=$project';
    void open(String id) =>
        context.go(id.isEmpty ? '/docs$query' : '/docs/$id$query');

    Widget tree() => PageTree(
      project: project,
      selectedId: docId,
      canEdit: canEdit,
      onOpen: open,
    );

    final id = docId;
    final canEditPage = id == null
        ? false
        : ref.watch(docSessionProvider(id).select((s) => s.canEdit));
    return ShellScaffold(
      appBar: AppBar(title: Text(context.l10n.grpJDocs)),
      body: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= docsTreeBreakpoint;
          Widget page(BuildContext inner) => id == null
              ? Center(
                  child: Text(
                    context.l10n.grpJPickPage,
                    key: const Key('no-page-open'),
                  ),
                )
              : DocPageView(
                  key: ValueKey('page-$id'),
                  docId: id,
                  project: project,
                  onOpenTree: wide
                      ? null
                      : () => Scaffold.of(inner).openDrawer(),
                );
          return Scaffold(
            drawer: wide || id == null
                ? null
                : Drawer(
                    key: const Key('tree-drawer'),
                    child: SafeArea(
                      child: PageTree(
                        project: project,
                        selectedId: id,
                        canEdit: canEdit,
                        onOpen: (p) {
                          Navigator.of(context).pop();
                          open(p);
                        },
                      ),
                    ),
                  ),
            endDrawer: id == null
                ? null
                : RevisionsPanel(docId: id, canEdit: canEditPage),
            body: wide
                ? Row(
                    children: [
                      SizedBox(width: _treeWidth, child: tree()),
                      const VerticalDivider(width: 1),
                      Expanded(child: Builder(builder: page)),
                    ],
                  )
                : id == null
                ? tree()
                : Builder(builder: page),
          );
        },
      ),
    );
  }
}
