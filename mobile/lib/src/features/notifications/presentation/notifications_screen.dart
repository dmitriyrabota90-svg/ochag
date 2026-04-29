import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../application/notifications_controller.dart';
import '../domain/notification.dart';
import 'notification_labels.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const routePath = '/profile/notifications';
  static const routeName = 'notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsControllerProvider);

    return AppScaffold(
      title: l10n.notificationsTitle,
      actions: [
        IconButton(
          tooltip: l10n.refreshAction,
          onPressed: () =>
              ref.read(notificationsControllerProvider.notifier).reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: notificationsAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: l10n.genericErrorMessage,
          onRetry: () =>
              ref.read(notificationsControllerProvider.notifier).reload(),
        ),
        data: (state) => _NotificationsContent(state: state),
      ),
    );
  }
}

class _NotificationsContent extends ConsumerWidget {
  const _NotificationsContent({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(notificationsControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.errorMessage != null)
            AppBaseCard(child: Text(l10n.genericErrorMessage)),
          if (state.items.isEmpty)
            AppBaseCard(child: Text(l10n.noNotificationsMessage))
          else
            for (final notification in state.items)
              _NotificationCard(
                notification: notification,
                isReading: state.readingIds.contains(notification.id),
              ),
          if (state.hasMore) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.isLoadingMore
                  ? null
                  : () => ref
                      .read(notificationsControllerProvider.notifier)
                      .loadMore(),
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

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({
    required this.notification,
    required this.isReading,
  });

  final AppNotification notification;
  final bool isReading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final createdAt = DateFormat.yMMMd(locale)
        .add_Hm()
        .format(notification.createdAt.toLocal());
    final readAt = notification.readAt == null
        ? null
        : DateFormat.yMMMd(locale)
            .add_Hm()
            .format(notification.readAt!.toLocal());
    final statusColor = notification.isRead
        ? theme.colorScheme.outline
        : theme.colorScheme.primary;
    final titleStyle = notification.isRead
        ? theme.textTheme.titleMedium
        : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final body = notification.body.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppBaseCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    notification.isRead
                        ? Icons.mark_email_read_outlined
                        : Icons.mark_email_unread_outlined,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationTitleLabel(l10n, notification),
                        style: titleStyle,
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(body),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    notification.isRead
                        ? l10n.readNotificationLabel
                        : l10n.unreadNotificationLabel,
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(notificationTypeLabel(l10n, notification)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              createdAt,
              style: theme.textTheme.bodySmall,
            ),
            if (readAt != null)
              Text(
                '${l10n.notificationReadAtLabel}: $readAt',
                style: theme.textTheme.bodySmall,
              ),
            if (!notification.isRead) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: isReading
                      ? null
                      : () => ref
                          .read(notificationsControllerProvider.notifier)
                          .markAsRead(notification.id),
                  icon: isReading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.done),
                  label: Text(l10n.markAsReadAction),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
