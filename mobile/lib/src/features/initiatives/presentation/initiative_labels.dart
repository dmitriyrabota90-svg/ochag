import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../domain/initiative.dart';

String initiativeStatusLabel(
  AppLocalizations l10n,
  InitiativeDisplayStatus status,
) {
  return switch (status) {
    InitiativeDisplayStatus.discussion => l10n.initiativeStatusDiscussion,
    InitiativeDisplayStatus.waitingDecision =>
      l10n.initiativeStatusWaitingDecision,
    InitiativeDisplayStatus.approved => l10n.initiativeStatusApproved,
    InitiativeDisplayStatus.approvedWithoutReward =>
      l10n.initiativeStatusApprovedWithoutReward,
    InitiativeDisplayStatus.rejected => l10n.initiativeStatusRejected,
  };
}

String initiativeSuccessMessage(AppLocalizations l10n, String? code) {
  return switch (code) {
    'initiative_created' => l10n.initiativeCreatedMessage,
    'initiative_approved' => l10n.initiativeApprovedMessage,
    'initiative_approved_without_reward' =>
      l10n.initiativeApprovedWithoutRewardMessage,
    'initiative_rejected' => l10n.initiativeRejectedMessage,
    _ => '',
  };
}
