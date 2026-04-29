import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../domain/notification.dart';

String notificationTitleLabel(
  AppLocalizations l10n,
  AppNotification notification,
) {
  return switch (notification.type) {
    'task.created' => l10n.taskCreatedMessage,
    'task.submitted' => l10n.taskSubmittedMessage,
    'task.approved' => l10n.taskApprovedMessage,
    'task.rejected' => l10n.taskRejectedMessage,
    'initiative_submitted' => l10n.initiativeCreatedMessage,
    'initiative_approved' => l10n.initiativeApprovedMessage,
    'initiative_approved_without_reward' =>
      l10n.initiativeApprovedWithoutRewardMessage,
    'initiative_rejected' => l10n.initiativeRejectedMessage,
    'reward_request.created' => l10n.rewardRequestedMessage,
    'reward_request.fulfilled' => l10n.rewardFulfilledMessage,
    'reward_request.received' => l10n.rewardReceivedMessage,
    'reward_request.cancel_requested' => l10n.rewardCancelRequestedMessage,
    'reward_request.cancel_rejected' => l10n.rewardCancelRejectedMessage,
    'reward_request.cancel_approved' => l10n.rewardCancelledMessage,
    'family_goal_contributed' => l10n.familyGoalContributedMessage,
    'family_goal_achieved' => l10n.familyGoalAchievedMessage,
    _ => _isRawKey(notification.title)
        ? l10n.notificationsTitle
        : notification.title.trim().isEmpty
            ? l10n.notificationsTitle
            : notification.title.trim(),
  };
}

String notificationTypeLabel(
  AppLocalizations l10n,
  AppNotification notification,
) {
  final type = notification.type;
  if (type.startsWith('task.')) {
    return l10n.tasksTitle;
  }
  if (type.startsWith('initiative_')) {
    return l10n.initiativesTitle;
  }
  if (type.startsWith('reward_request.') || type.startsWith('reward.')) {
    return l10n.rewardsTitle;
  }
  if (type.startsWith('family_goal_')) {
    return l10n.homeFamilyGoalTitle;
  }
  return l10n.notificationsTitle;
}

bool _isRawKey(String value) {
  final trimmed = value.trim();
  return trimmed.contains('.') || trimmed.contains('_');
}
