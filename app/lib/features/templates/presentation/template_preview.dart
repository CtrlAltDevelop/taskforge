import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/templates/domain/templates.dart';

/// What a template creates: the task tree with relative dates, the statuses,
/// the fields and the feature switches.
class TemplatePreview extends StatelessWidget {
  const TemplatePreview({super.key, required this.template});

  final Template template;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final content = TemplateContent.parse(template.contentJson);
    final rows = templateRows(content.tasks);
    return Column(
      key: const Key('template-preview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.statuses.isNotEmpty) ...[
          _Heading(t.tplStatuses),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in content.statuses)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: CircleAvatar(backgroundColor: _color(s.color)),
                  label: Text(s.name),
                ),
            ],
          ),
        ],
        if (content.fields.isNotEmpty) ...[
          _Heading(t.tplFields),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in content.fields)
                Chip(visualDensity: VisualDensity.compact, label: Text(f)),
            ],
          ),
        ],
        if (content.features.isNotEmpty || content.automations > 0) ...[
          _Heading(t.tplFeatures),
          Text(
            [
              ...content.features,
              if (content.automations > 0)
                t.tplAutomationsN(content.automations),
            ].join(' · '),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        _Heading(t.tplTasks),
        if (rows.isEmpty)
          Text(t.tplNoTasks, style: theme.textTheme.bodySmall)
        else
          for (final row in rows)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 12.0 * row.depth,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                children: [
                  Icon(
                    row.depth == 0
                        ? Icons.task_alt
                        : Icons.subdirectory_arrow_right,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(row.task.title)),
                  if (row.task.dueOffset != null)
                    Text(
                      offsetLabel(row.task.dueOffset!),
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

Color _color(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? Colors.grey : Color(0xFF000000 | value);
}
