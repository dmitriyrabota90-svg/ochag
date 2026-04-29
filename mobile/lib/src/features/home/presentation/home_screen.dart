import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../goal/domain/family_goal.dart';
import '../../goal/presentation/family_goal_labels.dart';
import '../../goal/presentation/goal_screen.dart';
import '../../history/domain/history.dart';
import '../../history/presentation/history_labels.dart';
import '../../history/presentation/history_screen.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_details_screen.dart';
import '../../tasks/presentation/task_labels.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../application/home_controller.dart';
import '../domain/home_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final homeAsync = ref.watch(homeControllerProvider);

    return AppScaffold(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () => ref.read(homeControllerProvider.notifier).reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: homeAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: l10n.genericErrorMessage,
          onRetry: () => ref.read(homeControllerProvider.notifier).reload(),
        ),
        data: (dashboard) => _HomeContent(dashboard: dashboard),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(homeControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => controller.reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressCard(dashboard: dashboard),
          const SizedBox(height: 16),
          _QuickActions(actions: dashboard.quickActions),
          const SizedBox(height: 16),
          _MyTasksSection(tasks: dashboard.myActiveTasks),
          const SizedBox(height: 16),
          _WaitingActionsSection(actions: dashboard.waitingActions),
          const SizedBox(height: 16),
          _GoalSection(goal: dashboard.currentGoal),
          const SizedBox(height: 16),
          _HistorySection(events: dashboard.historyPreview),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboard.family.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(l10n.betaBadgeLabel),
          ),
          const SizedBox(height: 4),
          Text(dashboard.currentMember.displayName),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricTile(
                label: l10n.levelLabel,
                value: dashboard.currentLevel.toString(),
              ),
              if (dashboard.totalExperience != null)
                _MetricTile(
                  label: l10n.homeTotalExperienceLabel,
                  value: dashboard.totalExperience.toString(),
                ),
              if (dashboard.periodSparks != null)
                _MetricTile(
                  label: l10n.periodSparksLabel,
                  value: dashboard.periodSparks.toString(),
                ),
              if (dashboard.periodExperience != null)
                _MetricTile(
                  label: l10n.periodExperienceLabel,
                  value: dashboard.periodExperience.toString(),
                ),
              if (dashboard.periodCompletedTasks != null)
                _MetricTile(
                  label: l10n.periodTasksLabel,
                  value: dashboard.periodCompletedTasks.toString(),
                ),
              _MetricTile(
                label: l10n.homeAvailableFreeRewardsLabel,
                value: dashboard.availableLevelFreeRewards.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});

  final List<HomeQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.homeQuickActionsTitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in actions)
              ActionChip(
                avatar: Icon(_quickActionIcon(action.type), size: 18),
                label: Text(_quickActionLabel(l10n, action.type)),
                onPressed: () => context.push(action.routePath),
              ),
          ],
        ),
      ],
    );
  }
}

class _MyTasksSection extends StatelessWidget {
  const _MyTasksSection({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l10n.homeMyActiveTasksTitle,
          actionLabel: l10n.homeViewAllAction,
          onAction: () => context.push(TasksScreen.routePath),
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          AppBaseCard(child: Text(l10n.homeNoActiveTasksMessage))
        else
          AppBaseCard(
            child: Column(
              children: [
                for (final task in tasks) _TaskPreviewTile(task: task),
              ],
            ),
          ),
      ],
    );
  }
}

class _TaskPreviewTile extends StatelessWidget {
  const _TaskPreviewTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dueAt = task.dueAt;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(task.title),
      subtitle: Text(
        dueAt == null
            ? taskStatusLabel(l10n, task.status)
            : '${taskStatusLabel(l10n, task.status)} · '
                '${DateFormat.MMMd(Localizations.localeOf(context).toString()).format(dueAt.toLocal())}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(TaskDetailsScreen.path(task.id)),
    );
  }
}

class _WaitingActionsSection extends StatelessWidget {
  const _WaitingActionsSection({required this.actions});

  final List<HomeActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.homeWaitingForYouTitle),
        const SizedBox(height: 8),
        if (actions.isEmpty)
          AppBaseCard(child: Text(l10n.homeNoWaitingActionsMessage))
        else
          AppBaseCard(
            child: Column(
              children: [
                for (final action in actions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_waitingActionIcon(action.type)),
                    title: Text(action.title),
                    subtitle: Text(_waitingActionLabel(l10n, action.type)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(action.routePath),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.goal});

  final FamilyGoal? goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l10n.homeFamilyGoalTitle,
          actionLabel: l10n.homeOpenGoalAction,
          onAction: () => context.push(GoalScreen.routePath),
        ),
        const SizedBox(height: 8),
        if (goal == null)
          AppBaseCard(child: Text(l10n.noFamilyGoalMessage))
        else
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
                      goal!.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(familyGoalStatusLabel(l10n, goal!.status)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: goal!.progress),
                const SizedBox(height: 8),
                Text(
                  '${goal!.currentSparks} / ${goal!.targetSparks} '
                  '${l10n.sparksShortLabel}',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.events});

  final List<HistoryEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l10n.homeLatestEventsTitle,
          actionLabel: l10n.homeViewAllAction,
          onAction: () => context.push(HistoryScreen.routePath),
        ),
        const SizedBox(height: 8),
        if (events.isEmpty)
          AppBaseCard(child: Text(l10n.homeNoRecentEventsMessage))
        else
          AppBaseCard(
            child: Column(
              children: [
                for (final event in events)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(historyEventSummaryLabel(l10n, event)),
                    subtitle: Text(
                      DateFormat.MMMd(
                        Localizations.localeOf(context).toString(),
                      ).add_Hm().format(event.occurredAt.toLocal()),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

IconData _quickActionIcon(HomeQuickActionType type) {
  return switch (type) {
    HomeQuickActionType.createTask => Icons.add_task,
    HomeQuickActionType.createInitiative => Icons.lightbulb_outline,
    HomeQuickActionType.openRewards => Icons.card_giftcard,
    HomeQuickActionType.contributeGoal => Icons.local_fire_department,
    HomeQuickActionType.sendFeedback => Icons.feedback_outlined,
  };
}

String _quickActionLabel(AppLocalizations l10n, HomeQuickActionType type) {
  return switch (type) {
    HomeQuickActionType.createTask => l10n.createTaskAction,
    HomeQuickActionType.createInitiative => l10n.createInitiativeAction,
    HomeQuickActionType.openRewards => l10n.homeOpenRewardsAction,
    HomeQuickActionType.contributeGoal => l10n.contributeFamilyGoalAction,
    HomeQuickActionType.sendFeedback => l10n.homeSendFeedbackAction,
  };
}

IconData _waitingActionIcon(HomeActionType type) {
  return switch (type) {
    HomeActionType.taskReview => Icons.rate_review_outlined,
    HomeActionType.initiativeDecision => Icons.lightbulb_outline,
    HomeActionType.rewardFulfillment => Icons.inventory_2_outlined,
    HomeActionType.rewardReceiving => Icons.verified_outlined,
    HomeActionType.rewardCancelResponse => Icons.undo_outlined,
    HomeActionType.goalCompletion => Icons.flag_outlined,
  };
}

String _waitingActionLabel(AppLocalizations l10n, HomeActionType type) {
  return switch (type) {
    HomeActionType.taskReview => l10n.homeTaskReviewAction,
    HomeActionType.initiativeDecision => l10n.homeInitiativeDecisionAction,
    HomeActionType.rewardFulfillment => l10n.homeRewardFulfillmentAction,
    HomeActionType.rewardReceiving => l10n.homeRewardReceivingAction,
    HomeActionType.rewardCancelResponse => l10n.homeRewardCancelResponseAction,
    HomeActionType.goalCompletion => l10n.homeGoalCompletionAction,
  };
}
