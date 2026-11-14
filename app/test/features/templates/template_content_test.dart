import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/templates/domain/templates.dart';

void main() {
  test('parse reads tasks, statuses, fields, features and automations', () {
    final content = TemplateContent.parse('''
{
  "tasks": [
    {"ref": "a", "title": "Plan", "start_offset": 0, "due_offset": 3},
    {"ref": "b", "parent": "a", "title": "Do {{client}}", "priority": "high"}
  ],
  "workflow": {"statuses": [{"name": "Todo", "category": "todo", "color": "#fff"}]},
  "fields": [{"name": "Budget"}],
  "features": ["board", "sprints"],
  "automations": [{}, {}]
}''');
    expect(content.tasks.map((t) => t.ref), ['a', 'b']);
    expect(content.tasks[1].parent, 'a');
    expect(content.tasks[1].priority, 'high');
    expect(content.tasks[0].dueOffset, 3);
    expect(content.statuses.single.name, 'Todo');
    expect(content.fields, ['Budget']);
    expect(content.features, ['board', 'sprints']);
    expect(content.automations, 2);
  });

  test('bad or empty JSON gives the empty preview', () {
    expect(TemplateContent.parse(''), same(TemplateContent.empty));
    expect(TemplateContent.parse('not json'), same(TemplateContent.empty));
    expect(TemplateContent.parse('[1]'), same(TemplateContent.empty));
  });

  test('offsetLabel signs positive days', () {
    expect(offsetLabel(3), '+3d');
    expect(offsetLabel(-2), '-2d');
    expect(offsetLabel(0), '0d');
  });

  test('templateRows nests children under their parent', () {
    final content = TemplateContent.parse(
      '{"tasks":[{"ref":"a","title":"A"},{"ref":"b","parent":"a","title":"B"}]}',
    );
    final rows = templateRows(content.tasks);
    expect(rows.map((r) => r.task.ref), ['a', 'b']);
    expect(rows.map((r) => r.depth), [0, 1]);
  });
}
