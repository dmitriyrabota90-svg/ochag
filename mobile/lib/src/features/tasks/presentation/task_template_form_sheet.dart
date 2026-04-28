import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/primary_button.dart';
import '../application/tasks_controller.dart';
import '../domain/task.dart';
import 'task_labels.dart';

Future<void> showTaskTemplateFormSheet({
  required BuildContext context,
  TaskTemplate? template,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _TaskTemplateFormSheet(template: template),
  );
}

class _TaskTemplateFormSheet extends ConsumerStatefulWidget {
  const _TaskTemplateFormSheet({this.template});

  final TaskTemplate? template;

  @override
  ConsumerState<_TaskTemplateFormSheet> createState() =>
      _TaskTemplateFormSheetState();
}

class _TaskTemplateFormSheetState
    extends ConsumerState<_TaskTemplateFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sparksController = TextEditingController(text: '0');
  final _experienceController = TextEditingController(text: '0');
  TaskRecurrence _recurrence = TaskRecurrence.none;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    if (template != null) {
      _titleController.text = template.title;
      _descriptionController.text = template.description ?? '';
      _sparksController.text = template.rewardSparks.toString();
      _experienceController.text = template.rewardExperience.toString();
      _recurrence = template.recurrence;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sparksController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting =
        ref.watch(tasksControllerProvider).valueOrNull?.isSubmitting ?? false;
    final isEdit = widget.template != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? l10n.editTaskTemplateTitle
                    : l10n.createTaskTemplateTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.taskTitleLabel),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty || trimmed.length > 120) {
                    return l10n.taskTitleValidationError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration:
                    InputDecoration(labelText: l10n.taskDescriptionLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sparksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.rewardSparksLabel),
                validator: _validateReward,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.rewardExperienceLabel),
                validator: _validateReward,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskRecurrence>(
                initialValue: _recurrence,
                decoration:
                    InputDecoration(labelText: l10n.taskRecurrenceLabel),
                items: [
                  for (final recurrence in TaskRecurrence.values)
                    DropdownMenuItem(
                      value: recurrence,
                      child: Text(taskRecurrenceLabel(l10n, recurrence)),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _recurrence = value ?? TaskRecurrence.none),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.saveAction,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final draft = TaskTemplateDraft(
      title: _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text,
      rewardSparks: int.tryParse(_sparksController.text) ?? 0,
      rewardExperience: int.tryParse(_experienceController.text) ?? 0,
      recurrence: _recurrence,
    );
    final controller = ref.read(tasksControllerProvider.notifier);
    final success = widget.template == null
        ? await controller.createTemplate(draft)
        : await controller.updateTemplate(
            templateId: widget.template!.id,
            draft: draft,
          );
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _validateReward(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0 || parsed > 100000) {
      return AppLocalizations.of(context).rewardValidationError;
    }
    return null;
  }
}
