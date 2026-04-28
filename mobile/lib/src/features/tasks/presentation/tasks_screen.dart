import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../family_setup/application/family_controller.dart';
import '../../initiatives/presentation/initiatives_screen.dart';
import '../application/tasks_controller.dart';
import '../domain/task.dart';
import 'create_task_screen.dart';
import 'task_details_screen.dart';
import 'task_labels.dart';
import 'task_template_form_sheet.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  static const routePath = '/tasks';
  static const routeName = 'tasks';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasksAsync = ref.watch(tasksControllerProvider);
    final currentMember = ref.watch(currentFamilyMemberProvider);
    final canCreate =
        ref.read(tasksControllerProvider.notifier).canCreateTask(currentMember);

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

    return AppScaffold(
      title: l10n.tasksTitle,
      actions: [
        IconButton(
          tooltip: l10n.taskTemplatesTitle,
          onPressed: canCreate
              ? () => showTaskTemplateFormSheet(context: context)
              : null,
          icon: const Icon(Icons.bookmark_add_outlined),
        ),
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () => ref.read(tasksControllerProvider.notifier).reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push(CreateTaskScreen.routePath),
              child: const Icon(Icons.add),
            )
          : null,
      body: tasksAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.read(tasksControllerProvider.notifier).reload(),
        ),
        data: (state) => _TasksList(state: state),
      ),
    );
  }
}

class _TasksList extends ConsumerWidget {
  const _TasksList({required this.state});

  final TasksState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(tasksControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.includeHistoryAction),
            value: state.includeHistory,
            onChanged: (value) => ref
                .read(tasksControllerProvider.notifier)
                .setIncludeHistory(value),
          ),
          AppBaseCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(l10n.initiativesTitle),
              subtitle: Text(l10n.initiativesInTasksDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(InitiativesScreen.routePath),
            ),
          ),
          const SizedBox(height: 16),
          if (state.tasks.isEmpty)
            AppBaseCard(
              child: Text(l10n.noTasksMessage),
            )
          else
            for (final task in state.tasks) _TaskTile(task: task),
          if (state.templates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.taskTemplatesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final template in state.templates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(template.title),
                subtitle: Text(
                  '${template.rewardSparks} ${l10n.sparksShortLabel} · '
                  '${template.rewardExperience} ${l10n.experienceShortLabel}',
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => showTaskTemplateFormSheet(
                  context: context,
                  template: template,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dueAt = task.dueAt;

    return AppBaseCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.assignee?.name ?? l10n.unassignedLabel),
            if (dueAt != null)
              Text(DateFormat.yMMMd(Localizations.localeOf(context).toString())
                  .format(dueAt)),
            Text(
              '${task.rewardSparks} ${l10n.sparksShortLabel} · '
              '${task.rewardExperience} ${l10n.experienceShortLabel}',
            ),
          ],
        ),
        trailing: Chip(label: Text(taskStatusLabel(l10n, task.status))),
        onTap: () => context.push(TaskDetailsScreen.path(task.id)),
      ),
    );
  }
}
