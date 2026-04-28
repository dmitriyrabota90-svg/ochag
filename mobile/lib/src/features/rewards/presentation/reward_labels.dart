import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../domain/reward.dart';

String rewardStatusLabel(AppLocalizations l10n, RewardStatus status) {
  return switch (status) {
    RewardStatus.proposed => l10n.rewardStatusProposed,
    RewardStatus.active => l10n.rewardStatusAvailable,
    RewardStatus.rejected => l10n.rewardStatusRejected,
  };
}

String rewardRequestStatusLabel(
  AppLocalizations l10n,
  RewardRequestStatus status,
) {
  return switch (status) {
    RewardRequestStatus.inProgress => l10n.rewardRequestStatusInProgress,
    RewardRequestStatus.fulfilled => l10n.rewardRequestStatusFulfilled,
    RewardRequestStatus.received => l10n.rewardRequestStatusReceived,
    RewardRequestStatus.cancelRequested =>
      l10n.rewardRequestStatusCancelRequested,
    RewardRequestStatus.cancelled => l10n.rewardRequestStatusCancelled,
  };
}

String rewardPaymentModeLabel(
  AppLocalizations l10n,
  RewardPaymentMode mode,
) {
  return switch (mode) {
    RewardPaymentMode.sparks => l10n.rewardPaymentSparks,
    RewardPaymentMode.levelFree => l10n.rewardPaymentLevelFree,
  };
}

String rewardSuccessMessage(AppLocalizations l10n, String? code) {
  return switch (code) {
    'reward_created' => l10n.rewardCreatedMessage,
    'reward_approved' => l10n.rewardApprovedMessage,
    'reward_repriced' => l10n.rewardRepricedMessage,
    'reward_rejected' => l10n.rewardRejectedMessage,
    'reward_template_created' => l10n.rewardTemplateCreatedMessage,
    'reward_template_updated' => l10n.rewardTemplateUpdatedMessage,
    'reward_requested' => l10n.rewardRequestedMessage,
    'reward_fulfilled' => l10n.rewardFulfilledMessage,
    'reward_received' => l10n.rewardReceivedMessage,
    'reward_cancel_requested' => l10n.rewardCancelRequestedMessage,
    'reward_cancelled' => l10n.rewardCancelledMessage,
    'reward_cancel_rejected' => l10n.rewardCancelRejectedMessage,
    _ => '',
  };
}
