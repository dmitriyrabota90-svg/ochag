import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../application/tasks_controller.dart';
import '../domain/task.dart';
import 'task_labels.dart';

class CreateTaskScreen extends ConsumerWidget {
  const CreateTaskScreen({super.key});

  static const routePath = '/tasks/new';
  static const routeName = 'createTask';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TaskFormScreen();
  }
}

class EditTaskScreen extends ConsumerWidget {
  const EditTaskScreen({
    required this.taskId,
    super.key,
  });

  static const routeName = 'editTask';

  final String taskId;

  static String path(String taskId) => '/tasks/$taskId/edit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksControllerProvider).valueOrNull;
    final task = state?.selectedTask ??
        state?.tasks.where((task) => task.id == taskId).firstOrNull;

    if (task == null) {
      Future.microtask(
        () => ref.read(tasksControllerProvider.notifier).loadTask(taskId),
      );
      return AppScaffold(
        title: AppLocalizations.of(context).editTaskTitle,
        body: state?.errorMessage == null
            ? const AppLoadingState()
            : AppErrorState(
                message: state!.errorMessage!,
                onRetry: () =>
                    ref.read(tasksControllerProvider.notifier).loadTask(taskId),
              ),
      );
    }

    return TaskFormScreen(task: task);
  }
}

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({
    this.task,
    super.key,
  });

  final Task? task;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sparksController = TextEditingController(text: '0');
  final _experienceController = TextEditingController(text: '0');

  String? _assigneeMemberId;
  DateTime? _dueAt;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  String? _templateId;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _sparksController.text = task.rewardSparks.toString();
      _experienceController.text = task.rewardExperience.toString();
      _dueAt = task.dueAt;
      _recurrence = task.recurrence;
      _templateId = task.templateId;
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
    final tasksState = ref.watch(tasksControllerProvider).valueOrNull;
    final familyState = ref.watch(familyControllerProvider).valueOrNull;
    final currentMember = familyState?.currentMember;
    final members = familyState?.members ?? const <FamilyMember>[];
    final templates = tasksState?.templates ?? const <TaskTemplate>[];
    final isSubmitting = tasksState?.isSubmitting ?? false;
    final isEdit = widget.task != null;
    final availableAssignees = members
        .where((member) => member.userId != currentMember?.userId)
        .toList();

    _assigneeMemberId ??= _memberIdForTaskAssignee(members, widget.task) ??
        (availableAssignees.isEmpty ? null : availableAssignees.first.id);

    return AppScaffold(
      title: isEdit ? l10n.editTaskTitle : l10n.createTaskTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (templates.isNotEmpty && !isEdit) ...[
              DropdownButtonFormField<String>(
                initialValue: _templateId,
                decoration: InputDecoration(labelText: l10n.taskTemplateLabel),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.noTemplateLabel),
                  ),
                  for (final template in templates)
                    DropdownMenuItem(
                      value: template.id,
                      child: Text(template.title),
                    ),
                ],
                onChanged: (value) {
                  final template = templates
                      .where((template) => template.id == value)
                      .firstOrNull;
                  setState(() {
                    _templateId = value;
                    if (template != null) {
                      _titleController.text = template.title;
                      _descriptionController.text = template.description ?? '';
                      _sparksController.text = template.rewardSparks.toString();
                      _experienceController.text =
                          template.rewardExperience.toString();
                      _recurrence = template.recurrence;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
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
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.taskDescriptionLabel),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _assigneeMemberId,
              decoration: InputDecoration(labelText: l10n.taskAssigneeLabel),
              items: [
                for (final member in availableAssignees)
                  DropdownMenuItem(
                    value: member.id,
                    child: Text(member.displayName),
                  ),
              ],
              validator: (value) =>
                  value == null ? l10n.taskAssigneeValidationError : null,
              onChanged: (value) => setState(() => _assigneeMemberId = value),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.taskDueDateLabel),
              subtitle: Text(_dueAt == null
                  ? l10n.noDueDateLabel
                  : MaterialLocalizations.of(context)
                      .formatMediumDate(_dueAt!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
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
              decoration: InputDecoration(labelText: l10n.taskRecurrenceLabel),
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
              label: isEdit ? l10n.saveAction : l10n.createTaskAction,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueAt = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _assigneeMemberId == null) {
      return;
    }
    final draft = TaskDraft(
      title: _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text,
      assigneeMemberId: _assigneeMemberId!,
      dueAt: _dueAt,
      rewardSparks: int.tryParse(_sparksController.text) ?? 0,
      rewardExperience: int.tryParse(_experienceController.text) ?? 0,
      recurrence: _recurrence,
      templateId: _templateId,
    );

    final controller = ref.read(tasksControllerProvider.notifier);
    final success = widget.task == null
        ? await controller.createTask(draft)
        : await controller.updateTask(taskId: widget.task!.id, draft: draft);

    if (success && mounted) {
      context.pop();
    }
  }

  String? _validateReward(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0 || parsed > 100000) {
      return AppLocalizations.of(context).rewardValidationError;
    }
    return null;
  }

  String? _memberIdForTaskAssignee(List<FamilyMember> members, Task? task) {
    if (task?.assigneeId == null) {
      return null;
    }
    return members
        .where((member) => member.userId == task!.assigneeId)
        .firstOrNull
        ?.id;
  }
}
