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
