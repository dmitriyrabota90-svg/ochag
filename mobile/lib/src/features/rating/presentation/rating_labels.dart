import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../family_setup/domain/family.dart';
import '../domain/rating.dart';

String analyticsPeriodLabel(AppLocalizations l10n, AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.day => l10n.periodDay,
    AnalyticsPeriod.week => l10n.periodWeek,
    AnalyticsPeriod.month => l10n.periodMonth,
    AnalyticsPeriod.allTime => l10n.periodAllTime,
  };
}

String ratingRoleLabel(AppLocalizations l10n, FamilyRole role) {
  return switch (role) {
    FamilyRole.owner => l10n.familyRoleOwner,
    FamilyRole.adult => l10n.familyRoleAdult,
    FamilyRole.child => l10n.familyRoleChild,
  };
}
