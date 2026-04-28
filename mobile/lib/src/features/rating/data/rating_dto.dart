import '../../family_setup/domain/family.dart';
import '../domain/rating.dart';

class RatingResultDto {
  const RatingResultDto({
    required this.period,
    required this.items,
  });

  factory RatingResultDto.fromJson(Map<String, dynamic> json) {
    return RatingResultDto(
      period: RatingPeriodDto.fromJson(json['period'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RatingItemDto.fromJson)
          .toList(),
    );
  }

  final RatingPeriodDto period;
  final List<RatingItemDto> items;

  RatingResult toDomain() {
    return RatingResult(
      period: period.toDomain(),
      items: items.map((item) => item.toDomain()).toList(),
    );
  }
}

class AnalyticsSummaryDto {
  const AnalyticsSummaryDto({
    required this.period,
    required this.totals,
    required this.members,
  });

  factory AnalyticsSummaryDto.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryDto(
      period: RatingPeriodDto.fromJson(json['period'] as Map<String, dynamic>),
      totals: AnalyticsTotalsDto.fromJson(
        json['totals'] as Map<String, dynamic>,
      ),
      members: (json['members'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(AnalyticsMemberSummaryDto.fromJson)
          .toList(),
    );
  }

  final RatingPeriodDto period;
  final AnalyticsTotalsDto totals;
  final List<AnalyticsMemberSummaryDto> members;

  AnalyticsSummary toDomain() {
    return AnalyticsSummary(
      period: period.toDomain(),
      totals: totals.toDomain(),
      members: members.map((member) => member.toDomain()).toList(),
    );
  }
}

class RatingItemDto {
  const RatingItemDto({
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

  factory RatingItemDto.fromJson(Map<String, dynamic> json) {
    return RatingItemDto(
      rank: json['rank'] as int? ?? 0,
      memberId: json['memberId'] as String,
      user: RatingUserDto.fromJson(json['user'] as Map<String, dynamic>),
      role: _familyRoleFromJson(json['role'] as String?),
      level: json['level'] as int? ?? 1,
      totalExperience: json['totalExperience'] as int? ?? 0,
      experienceForPeriod: json['experienceForPeriod'] as int? ?? 0,
      sparksEarnedForPeriod: json['sparksEarnedForPeriod'] as int? ?? 0,
      completedTasksForPeriod: json['completedTasksForPeriod'] as int? ?? 0,
    );
  }

  final int rank;
  final String memberId;
  final RatingUserDto user;
  final FamilyRole role;
  final int level;
  final int totalExperience;
  final int experienceForPeriod;
  final int sparksEarnedForPeriod;
  final int completedTasksForPeriod;

  RatingItem toDomain() {
    return RatingItem(
      rank: rank,
      memberId: memberId,
      user: user.toDomain(),
      role: role,
      level: level,
      totalExperience: totalExperience,
      experienceForPeriod: experienceForPeriod,
      sparksEarnedForPeriod: sparksEarnedForPeriod,
      completedTasksForPeriod: completedTasksForPeriod,
    );
  }
}

class AnalyticsTotalsDto {
  const AnalyticsTotalsDto({
    required this.completedTasks,
    required this.sparksEarned,
    required this.experienceEarned,
    required this.familyGoalContributedSparks,
  });

  factory AnalyticsTotalsDto.fromJson(Map<String, dynamic> json) {
    return AnalyticsTotalsDto(
      completedTasks: json['completedTasks'] as int? ?? 0,
      sparksEarned: json['sparksEarned'] as int? ?? 0,
      experienceEarned: json['experienceEarned'] as int? ?? 0,
      familyGoalContributedSparks:
          json['familyGoalContributedSparks'] as int? ?? 0,
    );
  }

  final int completedTasks;
  final int sparksEarned;
  final int experienceEarned;
  final int familyGoalContributedSparks;

  AnalyticsTotals toDomain() {
    return AnalyticsTotals(
      completedTasks: completedTasks,
      sparksEarned: sparksEarned,
      experienceEarned: experienceEarned,
      familyGoalContributedSparks: familyGoalContributedSparks,
    );
  }
}

class AnalyticsMemberSummaryDto {
  const AnalyticsMemberSummaryDto({
    required this.memberId,
    required this.user,
    required this.role,
    required this.level,
    required this.completedTasks,
    required this.sparksEarned,
    required this.experienceEarned,
    required this.familyGoalContributedSparks,
  });

  factory AnalyticsMemberSummaryDto.fromJson(Map<String, dynamic> json) {
    return AnalyticsMemberSummaryDto(
      memberId: json['memberId'] as String,
      user: RatingUserDto.fromJson(json['user'] as Map<String, dynamic>),
      role: _familyRoleFromJson(json['role'] as String?),
      level: json['level'] as int? ?? 1,
      completedTasks: json['completedTasks'] as int? ?? 0,
      sparksEarned: json['sparksEarned'] as int? ?? 0,
      experienceEarned: json['experienceEarned'] as int? ?? 0,
      familyGoalContributedSparks:
          json['familyGoalContributedSparks'] as int? ?? 0,
    );
  }

  final String memberId;
  final RatingUserDto user;
  final FamilyRole role;
  final int level;
  final int completedTasks;
  final int sparksEarned;
  final int experienceEarned;
  final int familyGoalContributedSparks;

  AnalyticsMemberSummary toDomain() {
    return AnalyticsMemberSummary(
      memberId: memberId,
      user: user.toDomain(),
      role: role,
      level: level,
      completedTasks: completedTasks,
      sparksEarned: sparksEarned,
      experienceEarned: experienceEarned,
      familyGoalContributedSparks: familyGoalContributedSparks,
    );
  }
}

class RatingUserDto {
  const RatingUserDto({
    required this.id,
    required this.name,
    required this.email,
    this.displayName,
  });

  factory RatingUserDto.fromJson(Map<String, dynamic> json) {
    return RatingUserDto(
      id: json['id'] as String,
      name: json['name'] as String? ??
          json['displayName'] as String? ??
          json['email'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String,
    );
  }

  final String id;
  final String name;
  final String email;
  final String? displayName;

  RatingUser toDomain() {
    return RatingUser(
      id: id,
      name: name,
      email: email,
      displayName: displayName,
    );
  }
}

class RatingPeriodDto {
  const RatingPeriodDto({
    required this.value,
    this.from,
    this.to,
  });

  factory RatingPeriodDto.fromJson(Map<String, dynamic> json) {
    return RatingPeriodDto(
      value: _periodFromJson(json['value'] as String?),
      from: _optionalDate(json['from']),
      to: _optionalDate(json['to']),
    );
  }

  final AnalyticsPeriod value;
  final DateTime? from;
  final DateTime? to;

  RatingPeriod toDomain() {
    return RatingPeriod(value: value, from: from, to: to);
  }
}

DateTime? _optionalDate(Object? value) {
  return value is String ? DateTime.parse(value) : null;
}

AnalyticsPeriod _periodFromJson(String? value) {
  return switch (value) {
    'day' => AnalyticsPeriod.day,
    'month' => AnalyticsPeriod.month,
    'all_time' => AnalyticsPeriod.allTime,
    _ => AnalyticsPeriod.week,
  };
}

FamilyRole _familyRoleFromJson(String? value) {
  return switch (value) {
    'OWNER' => FamilyRole.owner,
    'ADULT' => FamilyRole.adult,
    _ => FamilyRole.child,
  };
}
