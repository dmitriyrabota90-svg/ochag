import '../domain/initiative.dart';

class InitiativeDto {
  const InitiativeDto({
    required this.id,
    required this.familyId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.createdById,
    this.discussionLockedUntil,
    this.finalSparks,
    this.decidedById,
    this.decidedAt,
    this.createdBy,
    this.decidedBy,
  });

  factory InitiativeDto.fromJson(Map<String, dynamic> json) {
    return InitiativeDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: _statusFromJson(json['status'] as String),
      createdById: json['createdById'] as String?,
      discussionLockedUntil: _optionalDate(json['discussionLockedUntil']),
      finalSparks: json['finalSparks'] as int?,
      decidedById: json['decidedById'] as String?,
      decidedAt: _optionalDate(json['decidedAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? InitiativeUserDto.fromJson(
              json['createdBy'] as Map<String, dynamic>)
          : null,
      decidedBy: json['decidedBy'] is Map<String, dynamic>
          ? InitiativeUserDto.fromJson(
              json['decidedBy'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final InitiativeStatus status;
  final String? createdById;
  final DateTime? discussionLockedUntil;
  final int? finalSparks;
  final String? decidedById;
  final DateTime? decidedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final InitiativeUserDto? createdBy;
  final InitiativeUserDto? decidedBy;

  Initiative toDomain() {
    return Initiative(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      status: status,
      createdById: createdById,
      discussionLockedUntil: discussionLockedUntil,
      finalSparks: finalSparks,
      decidedById: decidedById,
      decidedAt: decidedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy?.toDomain(),
      decidedBy: decidedBy?.toDomain(),
    );
  }
}

class InitiativeUserDto {
  const InitiativeUserDto({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory InitiativeUserDto.fromJson(Map<String, dynamic> json) {
    return InitiativeUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  final String id;
  final String email;
  final String? displayName;

  InitiativeUser toDomain() {
    return InitiativeUser(
      id: id,
      email: email,
      displayName: displayName,
    );
  }
}

DateTime? _optionalDate(Object? value) {
  return value is String ? DateTime.parse(value) : null;
}

InitiativeStatus _statusFromJson(String value) {
  return switch (value) {
    'DRAFT' => InitiativeStatus.draft,
    'ACTIVE' => InitiativeStatus.active,
    'DISCUSSION' => InitiativeStatus.discussion,
    'APPROVED' => InitiativeStatus.approved,
    'APPROVED_WITHOUT_REWARD' => InitiativeStatus.approvedWithoutReward,
    'REJECTED' => InitiativeStatus.rejected,
    'COMPLETED' => InitiativeStatus.completed,
    'CANCELLED' => InitiativeStatus.cancelled,
    _ => InitiativeStatus.discussion,
  };
}
