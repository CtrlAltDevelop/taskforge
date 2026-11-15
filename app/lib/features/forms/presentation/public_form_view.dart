import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/forms/presentation/captcha_box.dart';

/// `#RRGGBB` as a colour; null for anything else.
Color? brandColorOf(String hex) {
  final match = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex);
  if (match == null) return null;
  return Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
}

/// The form a visitor fills: used by the public page (sends for real) and by
/// the builder's preview (sends nothing). [onSubmit] returns the reference.
class PublicFormView extends StatefulWidget {
  const PublicFormView({
    super.key,
    required this.form,
    required this.onSubmit,
    this.preview = false,
  });

  final PublicForm form;
  final Future<String> Function(FormAnswers answers) onSubmit;
  final bool preview;

  @override
  State<PublicFormView> createState() => _PublicFormViewState();
}

class _PublicFormViewState extends State<PublicFormView> {
  final Map<String, TextEditingController> _text = {};
  final Map<String, String> _values = {};
  final Map<String, List<PickedUpload>> _files = {};
  final _email = TextEditingController();
  Map<String, String> _problems = const {};
  String _captcha = '';
  String _reference = '';
  String _failure = '';
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    _email.dispose();
    super.dispose();
  }

  TextEditingController _controller(String id) =>
      _text.putIfAbsent(id, () => TextEditingController());

  String _valueOf(PublicQuestion q) {
    final isText =
        q.kind == QuestionKind.title ||
        q.kind == QuestionKind.description ||
        (q.kind == QuestionKind.custom &&
            const {'text', 'url', 'number', 'money'}.contains(q.type));
    return isText ? _controller(q.id).text.trim() : (_values[q.id] ?? '');
  }

  Map<String, String> _validate() {
    final t = context.l10n;
    final problems = <String, String>{};
    for (final q in widget.form.questions) {
      final empty = q.kind == QuestionKind.file
          ? (_files[q.id] ?? const []).isEmpty
          : _valueOf(q).isEmpty || _valueOf(q) == 'false' && q.required;
      if (q.required && empty) problems[q.id] = t.formsRequired;
    }
    final email = _email.text.trim();
    if (widget.form.requireEmail && email.isEmpty) {
      problems['email'] = t.formsRequired;
    } else if (email.isNotEmpty && !email.contains('@')) {
      problems['email'] = t.formsEmailInvalid;
    }
    if (widget.form.captcha != null && _captcha.isEmpty && !widget.preview) {
      problems['captcha'] = t.formsCaptchaRequired;
    }
    return problems;
  }

  Future<void> _send() async {
    final problems = _validate();
    if (problems.isNotEmpty) {
      setState(() {
        _problems = problems;
        _failure = '';
      });
      return;
    }
    setState(() {
      _busy = true;
      _problems = const {};
      _failure = '';
    });
    final values = {
      for (final q in widget.form.questions)
        if (q.kind != QuestionKind.file && _valueOf(q).isNotEmpty)
          q.id: _valueOf(q),
    };
    final answers = FormAnswers(
      values: values,
      files: _files,
      email: _email.text.trim(),
      captchaToken: _captcha,
    );
    try {
      final reference = await widget.onSubmit(answers);
      if (mounted) setState(() => _reference = reference);
    } on FormsException catch (e) {
      if (mounted) {
        setState(() {
          _problems = e.fieldProblems;
          _failure = e.fieldProblems.isEmpty
              ? formsErrorMessage(e, context.l10n)
              : '';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _again() {
    for (final c in _text.values) {
      c.clear();
    }
    _email.clear();
    setState(() {
      _values.clear();
      _files.clear();
      _captcha = '';
      _reference = '';
    });
  }

  Future<void> _pickFiles(PublicQuestion q) async {
    final t = context.l10n;
    final picked = await FilePicker.pickFiles();
    final room = q.maxFiles - (_files[q.id]?.length ?? 0);
    final added = <PickedUpload>[];
    var tooBig = false;
    for (final f in picked.take(room < 0 ? 0 : room)) {
      final bytes = await f.xFile.readAsBytes();
      if (widget.form.maxFileBytes > 0 &&
          bytes.length > widget.form.maxFileBytes) {
        tooBig = true;
        continue;
      }
      added.add(PickedUpload(f.name, bytes));
    }
    if (!mounted) return;
    setState(() {
      _files[q.id] = [...?_files[q.id], ...added];
      if (tooBig) _problems = {..._problems, q.id: t.formsFileTooBig};
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (_reference.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.formsThanksTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SelectableText(t.formsThanksBody(_reference)),
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('form-another'),
            onPressed: _again,
            child: Text(t.formsAnother),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final q in widget.form.questions) ...[
          _question(q),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 12),
        _emailField(),
        const SizedBox(height: 12),
        if (widget.form.captcha case final captcha?) ...[
          const SizedBox(height: 16),
          if (widget.preview)
            Text(t.formsCaptchaPreview)
          else
            CaptchaBox(
              config: captcha,
              onToken: (token) => setState(() => _captcha = token),
            ),
          if (_problems['captcha'] case final problem?)
            Text(
              problem,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
        const SizedBox(height: 20),
        if (_failure.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _failure,
              key: const Key('form-failure'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        FilledButton(
          key: const Key('form-submit'),
          onPressed: _busy || widget.preview ? null : _send,
          child: Text(_busy ? t.formsSending : t.formsSubmit),
        ),
      ],
    );
  }

  Widget _emailField() {
    final t = context.l10n;
    return TextField(
      key: const Key('form-email'),
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: widget.form.requireEmail
            ? t.formsEmailLabelRequired
            : t.formsEmailLabel,
        helperText: widget.form.offersUpdates ? t.formsEmailHelp : null,
        errorText: _problems['email'],
        border: const OutlineInputBorder(),
      ),
    );
  }

  InputDecoration _decoration(PublicQuestion q, {String? hint}) =>
      InputDecoration(
        labelText: q.required ? '${q.label} *' : q.label,
        helperText: q.help.isEmpty ? null : q.help,
        hintText: hint,
        errorText: _problems[q.id],
        border: const OutlineInputBorder(),
      );

  Widget _question(PublicQuestion q) {
    final t = context.l10n;
    final key = Key('form-q-${q.id}');
    switch (q.kind) {
      case QuestionKind.title:
        return TextField(
          key: key,
          controller: _controller(q.id),
          maxLength: 500,
          decoration: _decoration(q),
        );
      case QuestionKind.description:
        return TextField(
          key: key,
          controller: _controller(q.id),
          minLines: 4,
          maxLines: 10,
          decoration: _decoration(q),
        );
      case QuestionKind.file:
        return _fileQuestion(q);
      case QuestionKind.custom:
        break;
    }
    switch (q.type) {
      case 'number':
        return TextField(
          key: key,
          controller: _controller(q.id),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
          ],
          decoration: _decoration(q),
        );
      case 'money':
        return TextField(
          key: key,
          controller: _controller(q.id),
          decoration: _decoration(q, hint: t.formsMoneyHint),
        );
      case 'url':
        return TextField(
          key: key,
          controller: _controller(q.id),
          keyboardType: TextInputType.url,
          decoration: _decoration(q),
        );
      case 'select':
        return DropdownButtonFormField<String>(
          key: key,
          initialValue: _values[q.id],
          decoration: _decoration(q),
          items: [
            for (final o in q.options)
              DropdownMenuItem(value: o.id, child: Text(o.label)),
          ],
          onChanged: (v) => setState(() => _values[q.id] = v ?? ''),
        );
      case 'multiselect':
        return _multi(q);
      case 'date':
        return _date(q);
      case 'checkbox':
        return CheckboxListTile(
          key: key,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(q.required ? '${q.label} *' : q.label),
          subtitle: q.help.isEmpty ? null : Text(q.help),
          value: _values[q.id] == 'true',
          onChanged: (v) => setState(() => _values[q.id] = '${v ?? false}'),
        );
      default:
        return TextField(
          key: key,
          controller: _controller(q.id),
          decoration: _decoration(q),
        );
    }
  }

  Widget _multi(PublicQuestion q) {
    final chosen = (_values[q.id] ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();
    return InputDecorator(
      key: Key('form-q-${q.id}'),
      decoration: _decoration(q),
      child: Wrap(
        spacing: 8,
        children: [
          for (final o in q.options)
            FilterChip(
              label: Text(o.label),
              selected: chosen.contains(o.id),
              onSelected: (on) => setState(() {
                final next = {...chosen};
                on ? next.add(o.id) : next.remove(o.id);
                _values[q.id] = next.join(',');
              }),
            ),
        ],
      ),
    );
  }

  Widget _date(PublicQuestion q) {
    final t = context.l10n;
    final value = _values[q.id] ?? '';
    return InputDecorator(
      key: Key('form-q-${q.id}'),
      decoration: _decoration(q),
      child: Row(
        children: [
          Expanded(child: Text(value.isEmpty ? t.formsNoDate : value)),
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(now.year - 100),
                lastDate: DateTime(now.year + 100),
              );
              if (picked == null) return;
              final iso = picked.toIso8601String().substring(0, 10);
              setState(() => _values[q.id] = iso);
            },
            child: Text(t.formsPickDate),
          ),
          if (value.isNotEmpty)
            IconButton(
              tooltip: t.formsClearDate,
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _values[q.id] = ''),
            ),
        ],
      ),
    );
  }

  Widget _fileQuestion(PublicQuestion q) {
    final t = context.l10n;
    final files = _files[q.id] ?? const <PickedUpload>[];
    return InputDecorator(
      key: Key('form-q-${q.id}'),
      decoration: _decoration(q),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < files.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(files[i].name),
              trailing: IconButton(
                tooltip: t.formsRemoveFile,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _files[q.id] = [...files]..removeAt(i);
                }),
              ),
            ),
          OutlinedButton.icon(
            onPressed: files.length >= q.maxFiles ? null : () => _pickFiles(q),
            icon: const Icon(Icons.upload_file),
            label: Text(t.formsAddFile(q.maxFiles)),
          ),
        ],
      ),
    );
  }
}
