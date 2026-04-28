import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../family_setup/application/family_controller.dart';
import '../application/tasks_controller.dart';
import '../domain/task.dart';
import 'create_task_screen.dart';
import 'task_labels.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  const TaskDetailsScreen({
    required this.taskId,
    super.key,
  });

  static const routeName = 'taskDetails';

  final String taskId;

  static String path(String taskId) => '/tasks/$taskId';

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(tasksControllerProvider.notifier).loadTask(widget.taskId),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(tasksControllerProvider).valueOrNull;
    final task = state?.selectedTask ??
        state?.tasks.where((task) => task.id == widget.taskId).firstOrNull;
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final members = ref.watch(currentFamilyMembersProvider);
    final controller = ref.read(tasksControllerProvider.notifier);

    ref.listen(tasksControllerProvider, (previous, next) {
      final state = next.valueOrNull;
      final success = taskSuccessMessage(l10n, state?.successMessage);
      final message = state?.errorMessage ?? (success.isEmpty ? null : success);
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    if (task == null) {
      final error = state?.errorMessage;
      return AppScaffold(
        title: l10n.taskDetailsTitle,
        body: error == null
            ? const AppLoadingState()
            : AppErrorState(
                message: error,
                onRetry: () => controller.loadTask(widget.taskId),
              ),
      );
    }

    final canEdit = controller.canEditTask(task, currentMember);
    final canSubmit = controller.canSubmitTask(task, currentMember);
    final canReview = controller.canReviewTask(task, currentMember, members);

    return AppScaffold(
      title: l10n.taskDetailsTitle,
      actions: [
        if (canEdit)
          IconButton(
            tooltip: l10n.editTaskTitle,
            onPressed: () => context.push(EditTaskScreen.path(task.id)),
            icon: const Icon(Icons.edit_outlined),
          ),
        if (canEdit)
          IconButton(
            tooltip: l10n.deleteTaskAction,
            onPressed: () => _confirmDelete(task.id),
            icon: const Icon(Icons.delete_outline),
          ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppBaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(label: Text(taskStatusLabel(l10n, task.status))),
                  ],
                ),
                if (task.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(task.description!),
                ],
                const SizedBox(height: 12),
                _MetaLine(
                  label: l10n.taskAssigneeLabel,
                  value: task.assignee?.name ?? l10n.unassignedLabel,
                ),
                _MetaLine(
                  label: l10n.taskCreatorLabel,
                  value: task.createdBy?.name ?? l10n.unknownUserLabel,
                ),
                if (task.dueAt != null)
                  _MetaLine(
                    label: l10n.taskDueDateLabel,
                    value: DateFormat.yMMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(task.dueAt!),
                  ),
                _MetaLine(
                  label: l10n.taskRecurrenceLabel,
                  value: taskRecurrenceLabel(l10n, task.recurrence),
                ),
                _MetaLine(
                  label: l10n.taskRewardLabel,
                  value:
                      '${task.rewardSparks} ${l10n.sparksShortLabel} · ${task.rewardExperience} ${l10n.experienceShortLabel}',
                ),
                if (task.rejectedAt != null &&
                    task.status == TaskStatus.active) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.taskReturnedToActiveMessage,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (canSubmit)
            PrimaryButton(
              label: l10n.submitTaskAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: () => controller.submitTask(task.id),
            ),
          if (canReview) ...[
            PrimaryButton(
              label: l10n.approveTaskAction,
              isLoading: state?.isSubmitting ?? false,
              onPressed: () => controller.approveTask(task.id),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: state?.isSubmitting == true
                  ? null
                  : () => _confirmReject(task.id),
              child: Text(l10n.rejectTaskAction),
            ),
          ],
          const SizedBox(height: 16),
          _CommentsCard(
            task: task,
            controller: _commentController,
            isSubmitting: state?.isSubmitting ?? false,
            onSubmit: _addComment,
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) {
      return;
    }
    final success = await ref.read(tasksControllerProvider.notifier).addComment(
          taskId: widget.taskId,
          body: body,
        );
    if (success) {
      _commentController.clear();
    }
  }

  Future<void> _confirmDelete(String taskId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.deleteTaskAction,
      body: l10n.deleteTaskConfirmMessage,
    );
    if (!confirmed) {
      return;
    }
    final success =
        await ref.read(tasksControllerProvider.notifier).deleteTask(taskId);
    if (success && mounted) {
      context.pop();
    }
  }

  Future<void> _confirmReject(String taskId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.rejectTaskAction,
      body: l10n.rejectTaskConfirmMessage,
    );
    if (confirmed) {
      await ref.read(tasksControllerProvider.notifier).rejectTask(taskId);
    }
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text('$label: $value'),
    );
  }
}

class _CommentsCard extends StatelessWidget {
  const _CommentsCard({
    required this.task,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final Task task;
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taskCommentsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (task.comments.isEmpty)
            Text(l10n.noTaskCommentsMessage)
          else
            for (final comment in task.comments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(comment.body),
                subtitle: Text(comment.user?.name ?? l10n.unknownUserLabel),
              ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.taskCommentLabel),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: Text(l10n.addCommentAction),
            ),
          ),
        ],
      ),
    );
  }
}
