import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../application/rating_controller.dart';
import '../domain/rating.dart';
import 'rating_labels.dart';

class RatingScreen extends ConsumerWidget {
  const RatingScreen({super.key});

  static const routePath = '/profile/rating';
  static const routeName = 'rating';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ratingAsync = ref.watch(ratingControllerProvider);

    return AppScaffold(
      title: l10n.ratingTitle,
      actions: [
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () => ref.read(ratingControllerProvider.notifier).reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: ratingAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: l10n.genericErrorMessage,
          onRetry: () => ref.read(ratingControllerProvider.notifier).reload(),
        ),
        data: (state) {
          if (state.errorMessage != null) {
            return AppErrorState(
              message: l10n.genericErrorMessage,
              onRetry: () =>
                  ref.read(ratingControllerProvider.notifier).reload(),
            );
          }
          return _RatingContent(state: state);
        },
      ),
    );
  }
}

class _RatingContent extends ConsumerWidget {
  const _RatingContent({required this.state});

  final RatingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rating = state.rating;
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () => ref.read(ratingControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<AnalyticsPeriod>(
            segments: [
              for (final period in AnalyticsPeriod.values)
                ButtonSegment(
                  value: period,
                  label: Text(analyticsPeriodLabel(l10n, period)),
                ),
            ],
            selected: {state.period},
            onSelectionChanged: (selection) => ref
                .read(ratingControllerProvider.notifier)
                .setPeriod(selection.first),
          ),
          const SizedBox(height: 16),
          if (summary != null) _AnalyticsSummaryCard(summary: summary),
          if (rating == null || rating.items.isEmpty)
            AppBaseCard(child: Text(l10n.noRatingMessage))
          else
            for (final item in rating.items) _RatingItemCard(item: item),
        ],
      ),
    );
  }
}

class _AnalyticsSummaryCard extends StatelessWidget {
  const _AnalyticsSummaryCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = summary.totals;

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.analyticsSummaryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Metric(
                  label: l10n.completedTasksLabel,
                  value: totals.completedTasks),
              _Metric(
                  label: l10n.sparksEarnedLabel, value: totals.sparksEarned),
              _Metric(
                  label: l10n.experienceEarnedLabel,
                  value: totals.experienceEarned),
              _Metric(
                label: l10n.familyGoalContributedLabel,
                value: totals.familyGoalContributedSparks,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingItemCard extends StatelessWidget {
  const _RatingItemCard({required this.item});

  final RatingItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text(item.rank.toString())),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.user.name,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                    '${ratingRoleLabel(l10n, item.role)} · ${l10n.levelLabel} ${item.level}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Metric(
                        label: l10n.periodExperienceLabel,
                        value: item.experienceForPeriod),
                    _Metric(
                        label: l10n.periodSparksLabel,
                        value: item.sparksEarnedForPeriod),
                    _Metric(
                        label: l10n.periodTasksLabel,
                        value: item.completedTasksForPeriod),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value.toString(), style: Theme.of(context).textTheme.titleMedium),
        Text(label),
      ],
    );
  }
}
