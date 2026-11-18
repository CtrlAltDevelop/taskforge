import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/page/tf_danger_zone.dart';
import 'package:taskforge/core/ui/page/tf_form.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Gallery blocks for the page layout components (phase 49).
List<Widget> pageGalleryBlocks() => [
  const TfPageHeader(
    title: 'Page header',
    description: 'Title, description and actions; actions wrap when narrow.',
    actions: [Text('Action')],
  ),
  const TfFormSection(
    title: 'Form section',
    description: 'Label above the field, helper text, inline error.',
    children: [
      TfTextField(label: 'Name', hint: 'Acme'),
      TfFormField(
        label: 'Slug',
        helper: 'Used in links',
        error: 'That slug is taken',
        child: TfTextField(hint: 'acme'),
      ),
    ],
  ),
  TfStickySaveBar(
    dirty: true,
    onSave: _noop,
    saveLabel: 'Save',
    onDiscard: _noop,
    discardLabel: 'Discard',
    message: 'Unsaved changes',
  ),
  const SizedBox(height: TfSpace.sm),
  TfDangerZone(
    title: 'Danger zone',
    description: 'These cannot be undone.',
    actions: [
      TfDangerAction(
        label: 'Delete workspace',
        description: 'Removes every project and task.',
        onPressed: _noop,
      ),
    ],
  ),
];

void _noop() {}
