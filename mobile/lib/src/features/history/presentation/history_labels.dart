import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../domain/history.dart';

String historyEntityTypeLabel(
  AppLocalizations l10n,
  HistoryEntityType? entityType,
) {
  return switch (entityType) {
    null => l10n.allHistoryEntitiesLabel,
    HistoryEntityType.family => l10n.historyEntityFamily,
    HistoryEntityType.task => l10n.historyEntityTask,
    HistoryEntityType.taskTemplate => l10n.historyEntityTaskTemplate,
    HistoryEntityType.initiative => l10n.historyEntityInitiative,
    HistoryEntityType.reward => l10n.historyEntityReward,
    HistoryEntityType.rewardTemplate => l10n.historyEntityRewardTemplate,
    HistoryEntityType.rewardRequest => l10n.historyEntityRewardRequest,
    HistoryEntityType.familyGoal => l10n.historyEntityFamilyGoal,
    HistoryEntityType.unknown => l10n.historyEntityUnknown,
  };
}

String historyEventSummaryLabel(
  AppLocalizations l10n,
  HistoryEvent event,
) {
  final base = historyEventTypeLabel(l10n, event.eventType);
  final sparks = _numericPayload(event, 'sparks') ??
      _numericPayload(event, 'finalSparks') ??
      _numericPayload(event, 'rewardSparks');
  if (sparks == null) {
    return base;
  }
  return '$base: $sparks ${l10n.sparksShortLabel}';
}

String historyEventTypeLabel(AppLocalizations l10n, String eventType) {
  return switch (eventType) {
    'family.created' => l10n.familyCreatedMessage,
    'family.updated' => l10n.familyUpdatedMessage,
    'family.member.joined' => l10n.familyJoinedMessage,
    'family.member.left' => l10n.familyLeftMessage,
    'family.member.role_updated' => l10n.memberRoleUpdatedMessage,
    'family.member.removed' => l10n.memberRemovedMessage,
    'family.creator.transferred' => l10n.creatorTransferredMessage,
    'family.invite.created' => l10n.inviteCreatedMessage,
    'family.invite.regenerated' => l10n.inviteRegeneratedMessage,
    'family.delete.requested' => l10n.familyDeleteRequestedMessage,
    'family.delete.confirmed' => l10n.familyUpdatedMessage,
    'task.created' => l10n.taskCreatedMessage,
    'task.updated' => l10n.taskUpdatedMessage,
    'task.deleted' => l10n.taskDeletedMessage,
    'task.submitted' => l10n.taskSubmittedMessage,
    'task.approved' => l10n.taskApprovedMessage,
    'task.rejected' => l10n.taskRejectedMessage,
    'task.commented' => l10n.taskCommentAddedMessage,
    'task.recurring.skipped' => l10n.taskStatusSkipped,
    'task.recurring.created' => l10n.taskCreatedMessage,
    'task_template.created' => l10n.taskTemplateCreatedMessage,
    'task_template.updated' => l10n.taskTemplateUpdatedMessage,
    'initiative_submitted' => l10n.initiativeCreatedMessage,
    'initiative_approved' => l10n.initiativeApprovedMessage,
    'initiative_approved_without_reward' =>
      l10n.initiativeApprovedWithoutRewardMessage,
    'initiative_rejected' => l10n.initiativeRejectedMessage,
    'reward.proposed' => l10n.rewardCreatedMessage,
    'reward.approved' => l10n.rewardApprovedMessage,
    'reward.repriced' => l10n.rewardRepricedMessage,
    'reward.rejected' => l10n.rewardRejectedMessage,
    'reward_template.created' => l10n.rewardTemplateCreatedMessage,
    'reward_template.updated' => l10n.rewardTemplateUpdatedMessage,
    'reward_request.created' => l10n.rewardRequestedMessage,
    'reward_request.fulfilled' => l10n.rewardFulfilledMessage,
    'reward_request.received' => l10n.rewardReceivedMessage,
    'reward_request.cancel_requested' => l10n.rewardCancelRequestedMessage,
    'reward_request.cancel_rejected' => l10n.rewardCancelRejectedMessage,
    'reward_request.cancel_approved' => l10n.rewardCancelledMessage,
    'family_goal_created' => l10n.familyGoalCreatedMessage,
    'family_goal_updated' => l10n.familyGoalUpdatedMessage,
    'family_goal_contributed' => l10n.familyGoalContributedMessage,
    'family_goal_achieved' => l10n.familyGoalAchievedMessage,
    'family_goal_completion_confirmed' => l10n.familyGoalConfirmedMessage,
    'family_goal_completed' => l10n.familyGoalCompletedSummaryMessage,
    _ => l10n.historyEntityUnknown,
  };
}

num? _numericPayload(HistoryEvent event, String key) {
  final value = event.payload[key];
  return value is num ? value : null;
}
