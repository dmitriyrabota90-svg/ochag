import '../../family_setup/domain/family.dart';

enum AnalyticsPeriod {
  day,
  week,
  month,
  allTime,
}

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get apiValue {
    return switch (this) {
      AnalyticsPeriod.day => 'day',
      AnalyticsPeriod.week => 'week',
      AnalyticsPeriod.month => 'month',
      AnalyticsPeriod.allTime => 'all_time',
    };
  }
}

class RatingUser {
  const RatingUser({
    required this.id,
    required this.name,
    required this.email,
    this.displayName,
  });

  final String id;
  final String name;
  final String email;
  final String? displayName;
}

class RatingPeriod {
  const RatingPeriod({
    required this.value,
    this.from,
    this.to,
  });

  final AnalyticsPeriod value;
  final DateTime? from;
  final DateTime? to;
}

class RatingItem {
  const RatingItem({
    required this.rank,
    required this.memberId,
    required this.user,
    required this.role,
    required this.level,
    required this.totalExperience,
    required this.experienceForPeriod,
    required this.sparksEarnedForPeriod,
    required this.completedTasksForPeriod,
  });

  final int rank;
  final String memberId;
  final RatingUser user;
  final FamilyRole role;
  final int level;
  final int totalExperience;
  final int experienceForPeriod;
  final int sparksEarnedForPeriod;
  final int completedTasksForPeriod;
}

class RatingResult {
  const RatingResult({
    required this.period,
    required this.items,
  });

  final RatingPeriod period;
  final List<RatingItem> items;
}

class AnalyticsTotals {
  const AnalyticsTotals({
    required this.completedTasks,
    required this.sparksEarned,
    required this.experienceEarned,
    required this.familyGoalContributedSparks,
  });

  final int completedTasks;
  final int sparksEarned;
  final int experienceEarned;
  final int familyGoalContributedSparks;
}

class AnalyticsMemberSummary {
  const AnalyticsMemberSummary({
    required this.memberId,
    required this.user,
    required this.role,
    required this.level,
    required this.completedTasks,
    required this.sparksEarned,
    required this.experienceEarned,
    required this.familyGoalContributedSparks,
  });

  final String memberId;
  final RatingUser user;
  final FamilyRole role;
  final int level;
  final int completedTasks;
  final int sparksEarned;
  final int experienceEarned;
  final int familyGoalContributedSparks;
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.period,
    required this.totals,
    required this.members,
  });

  final RatingPeriod period;
  final AnalyticsTotals totals;
  final List<AnalyticsMemberSummary> members;
}
