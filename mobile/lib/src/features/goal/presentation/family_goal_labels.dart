import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../domain/family_goal.dart';

String familyGoalStatusLabel(
  AppLocalizations l10n,
  FamilyGoalStatus status,
) {
  return switch (status) {
    FamilyGoalStatus.active => l10n.familyGoalStatusActive,
    FamilyGoalStatus.awaitingExecution =>
      l10n.familyGoalStatusAwaitingExecution,
    FamilyGoalStatus.completed => l10n.familyGoalStatusCompleted,
    FamilyGoalStatus.cancelled => l10n.familyGoalStatusCancelled,
  };
}

String familyGoalSuccessMessage(AppLocalizations l10n, String? code) {
  return switch (code) {
    'family_goal_created' => l10n.familyGoalCreatedMessage,
    'family_goal_updated' => l10n.familyGoalUpdatedMessage,
    'family_goal_contributed' => l10n.familyGoalContributedMessage,
    'family_goal_confirmed' => l10n.familyGoalConfirmedMessage,
    _ => '',
  };
}
