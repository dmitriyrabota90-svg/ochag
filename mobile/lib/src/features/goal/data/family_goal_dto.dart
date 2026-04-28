import '../../auth/data/auth_dto.dart';
import '../../family_setup/domain/family.dart';
import '../domain/family_goal.dart';

class FamilyGoalDto {
  const FamilyGoalDto({
    required this.id,
    required this.familyId,
    required this.title,
    required this.status,
    required this.targetSparks,
    required this.currentSparks,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.targetAt,
    this.achievedAt,
    this.completedAt,
    this.confirmations = const [],
  });

  factory FamilyGoalDto.fromJson(Map<String, dynamic> json) {
    return FamilyGoalDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: _statusFromJson(json['status'] as String?),
      targetSparks: json['targetSparks'] as int? ?? 0,
      currentSparks: json['currentSparks'] as int? ?? 0,
      targetAt: _optionalDate(json['targetAt']),
      achievedAt: _optionalDate(json['achievedAt']),
      completedAt: _optionalDate(json['completedAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      confirmations: (json['confirmations'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(FamilyGoalConfirmationDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final FamilyGoalStatus status;
  final int targetSparks;
  final int currentSparks;
  final DateTime? targetAt;
  final DateTime? achievedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FamilyGoalConfirmationDto> confirmations;

  FamilyGoal toDomain() {
    return FamilyGoal(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      status: status,
      targetSparks: targetSparks,
      currentSparks: currentSparks,
      targetAt: targetAt,
      achievedAt: achievedAt,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      confirmations: confirmations.map((item) => item.toDomain()).toList(),
    );
  }
}

class FamilyGoalConfirmationDto {
  const FamilyGoalConfirmationDto({
    required this.id,
    required this.familyId,
    required this.goalId,
    required this.memberId,
    required this.createdAt,
    this.member,
  });

  factory FamilyGoalConfirmationDto.fromJson(Map<String, dynamic> json) {
    return FamilyGoalConfirmationDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      goalId: json['goalId'] as String,
      memberId: json['memberId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      member: json['member'] is Map<String, dynamic>
          ? FamilyMemberDto.fromJson(json['member'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String familyId;
  final String goalId;
  final String memberId;
  final DateTime createdAt;
  final FamilyMemberDto? member;

  FamilyGoalConfirmation toDomain() {
    return FamilyGoalConfirmation(
      id: id,
      familyId: familyId,
      goalId: goalId,
      memberId: memberId,
      createdAt: createdAt,
      member: member?.toDomain(),
    );
  }
}

class FamilyMemberDto {
  const FamilyMemberDto({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.user,
  });

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) {
    return FamilyMemberDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      role: _familyRoleFromJson(json['role'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] is Map<String, dynamic>
          ? AuthUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String familyId;
  final String userId;
  final FamilyRole role;
  final DateTime createdAt;
  final AuthUserDto? user;

  FamilyMember toDomain() {
    return FamilyMember(
      id: id,
      familyId: familyId,
      userId: userId,
      role: role,
      createdAt: createdAt,
      user: user?.toDomain(),
    );
  }
}

DateTime? _optionalDate(Object? value) {
  return value is String ? DateTime.parse(value) : null;
}

FamilyGoalStatus _statusFromJson(String? value) {
  return switch (value) {
    'AWAITING_EXECUTION' => FamilyGoalStatus.awaitingExecution,
    'COMPLETED' => FamilyGoalStatus.completed,
    'CANCELLED' => FamilyGoalStatus.cancelled,
    _ => FamilyGoalStatus.active,
  };
}

FamilyRole _familyRoleFromJson(String? value) {
  return switch (value) {
    'OWNER' => FamilyRole.owner,
    'ADULT' => FamilyRole.adult,
    _ => FamilyRole.child,
  };
}
