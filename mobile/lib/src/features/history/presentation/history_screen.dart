import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../application/history_controller.dart';
import '../domain/history.dart';
import 'history_labels.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const routePath = '/profile/history';
  static const routeName = 'history';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _eventTypeController = TextEditingController();

  @override
  void dispose() {
    _eventTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(historyControllerProvider);

    return AppScaffold(
      title: l10n.historyTitle,
      actions: [
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () =>
              ref.read(historyControllerProvider.notifier).reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: historyAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: l10n.genericErrorMessage,
          onRetry: () => ref.read(historyControllerProvider.notifier).reload(),
        ),
        data: (state) => _HistoryContent(
          state: state,
          eventTypeController: _eventTypeController,
        ),
      ),
    );
  }
}

class _HistoryContent extends ConsumerWidget {
  const _HistoryContent({
    required this.state,
    required this.eventTypeController,
  });

  final HistoryState state;
  final TextEditingController eventTypeController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (eventTypeController.text.isEmpty && state.eventType != null) {
      eventTypeController.text = state.eventType!;
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppBaseCard(
            child: Column(
              children: [
                DropdownButtonFormField<HistoryEntityType?>(
                  initialValue: state.entityType,
                  decoration:
                      InputDecoration(labelText: l10n.historyEntityFilterLabel),
                  items: [
                    DropdownMenuItem<HistoryEntityType?>(
                      value: null,
                      child: Text(historyEntityTypeLabel(l10n, null)),
                    ),
                    for (final type in HistoryEntityType.values
                        .where((type) => type != HistoryEntityType.unknown))
                      DropdownMenuItem<HistoryEntityType?>(
                        value: type,
                        child: Text(historyEntityTypeLabel(l10n, type)),
                      ),
                  ],
                  onChanged: (value) => ref
                      .read(historyControllerProvider.notifier)
                      .setEntityType(value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: eventTypeController,
                  decoration: InputDecoration(
                    labelText: l10n.historyEventTypeFilterLabel,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => ref
                          .read(historyControllerProvider.notifier)
                          .setEventType(eventTypeController.text),
                    ),
                  ),
                  onSubmitted: (value) => ref
                      .read(historyControllerProvider.notifier)
                      .setEventType(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (state.errorMessage != null)
            AppBaseCard(child: Text(l10n.genericErrorMessage)),
          if (state.items.isEmpty)
            AppBaseCard(child: Text(l10n.noHistoryMessage))
          else
            for (final event in state.items) _HistoryEventCard(event: event),
          if (state.hasMore) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.isLoadingMore
                  ? null
                  : () =>
                      ref.read(historyControllerProvider.notifier).loadMore(),
              child: Text(
                state.isLoadingMore ? l10n.loadingAction : l10n.loadMoreAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryEventCard extends StatelessWidget {
  const _HistoryEventCard({required this.event});

  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_Hm()
        .format(event.occurredAt.toLocal());

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            historyEventSummaryLabel(l10n, event),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(date),
          Text(
              '${l10n.historyActorLabel}: ${event.actor?.name ?? l10n.unknownUserLabel}'),
          Text(
              '${l10n.historyEntityFilterLabel}: ${historyEntityTypeLabel(l10n, event.entityType)}'),
          Text(
            '${l10n.historyEventTypeFilterLabel}: '
            '${historyEventTypeLabel(l10n, event.eventType)}',
          ),
        ],
      ),
    );
  }
}
