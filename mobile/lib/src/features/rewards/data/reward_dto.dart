import '../../family_setup/domain/family.dart';
import '../domain/reward.dart';

class RewardDto {
  const RewardDto({
    required this.id,
    required this.familyId,
    required this.title,
    required this.pointsCost,
    required this.paymentMode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.levelRequired,
    this.createdById,
    this.approvedById,
    this.approvedAt,
    this.rejectedAt,
    this.createdBy,
    this.approvedBy,
  });

  factory RewardDto.fromJson(Map<String, dynamic> json) {
    return RewardDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      pointsCost: json['pointsCost'] as int? ?? 0,
      paymentMode: _paymentModeFromJson(json['paymentMode'] as String?),
      status: _rewardStatusFromJson(json['status'] as String?),
      levelRequired: json['levelRequired'] as int?,
      createdById: json['createdById'] as String?,
      approvedById: json['approvedById'] as String?,
      approvedAt: _optionalDate(json['approvedAt']),
      rejectedAt: _optionalDate(json['rejectedAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? RewardUserDto.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      approvedBy: json['approvedBy'] is Map<String, dynamic>
          ? RewardUserDto.fromJson(json['approvedBy'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final int pointsCost;
  final RewardPaymentMode paymentMode;
  final RewardStatus status;
  final int? levelRequired;
  final String? createdById;
  final String? approvedById;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RewardUserDto? createdBy;
  final RewardUserDto? approvedBy;

  Reward toDomain() {
    return Reward(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      pointsCost: pointsCost,
      paymentMode: paymentMode,
      status: status,
      levelRequired: levelRequired,
      createdById: createdById,
      approvedById: approvedById,
      approvedAt: approvedAt,
      rejectedAt: rejectedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy?.toDomain(),
      approvedBy: approvedBy?.toDomain(),
    );
  }
}

class RewardTemplateDto {
  const RewardTemplateDto({
    required this.id,
    required this.familyId,
    required this.title,
    required this.pointsCost,
    required this.paymentMode,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory RewardTemplateDto.fromJson(Map<String, dynamic> json) {
    return RewardTemplateDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      pointsCost: json['pointsCost'] as int? ?? 0,
      paymentMode: _paymentModeFromJson(json['paymentMode'] as String?),
      createdById: json['createdById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final int pointsCost;
  final RewardPaymentMode paymentMode;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  RewardTemplate toDomain() {
    return RewardTemplate(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      pointsCost: pointsCost,
      paymentMode: paymentMode,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class RewardRequestDto {
  const RewardRequestDto({
    required this.id,
    required this.familyId,
    required this.rewardId,
    required this.requesterMemberId,
    required this.providerMemberId,
    required this.status,
    required this.paymentMode,
    required this.sparksCost,
    required this.createdAt,
    required this.updatedAt,
    required this.reward,
    required this.requester,
    required this.provider,
    this.statusBeforeCancel,
    this.levelSnapshot,
    this.fulfilledAt,
    this.receivedAt,
    this.cancelRequestedById,
    this.cancelRequestedAt,
    this.cancelledAt,
  });

  factory RewardRequestDto.fromJson(Map<String, dynamic> json) {
    return RewardRequestDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      rewardId: json['rewardId'] as String,
      requesterMemberId: json['requesterMemberId'] as String,
      providerMemberId: json['providerMemberId'] as String,
      status: _requestStatusFromJson(json['status'] as String?),
      statusBeforeCancel:
          _nullableRequestStatusFromJson(json['statusBeforeCancel'] as String?),
      paymentMode: _paymentModeFromJson(json['paymentMode'] as String?),
      sparksCost: json['sparksCost'] as int? ?? 0,
      levelSnapshot: json['levelSnapshot'] as int?,
      fulfilledAt: _optionalDate(json['fulfilledAt']),
      receivedAt: _optionalDate(json['receivedAt']),
      cancelRequestedById: json['cancelRequestedById'] as String?,
      cancelRequestedAt: _optionalDate(json['cancelRequestedAt']),
      cancelledAt: _optionalDate(json['cancelledAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      reward: RewardDto.fromJson(json['reward'] as Map<String, dynamic>),
      requester:
          RewardMemberDto.fromJson(json['requester'] as Map<String, dynamic>),
      provider:
          RewardMemberDto.fromJson(json['provider'] as Map<String, dynamic>),
    );
  }

  final String id;
  final String familyId;
  final String rewardId;
  final String requesterMemberId;
  final String providerMemberId;
  final RewardRequestStatus status;
  final RewardRequestStatus? statusBeforeCancel;
  final RewardPaymentMode paymentMode;
  final int sparksCost;
  final int? levelSnapshot;
  final DateTime? fulfilledAt;
  final DateTime? receivedAt;
  final String? cancelRequestedById;
  final DateTime? cancelRequestedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RewardDto reward;
  final RewardMemberDto requester;
  final RewardMemberDto provider;

  RewardRequest toDomain() {
    return RewardRequest(
      id: id,
      familyId: familyId,
      rewardId: rewardId,
      requesterMemberId: requesterMemberId,
      providerMemberId: providerMemberId,
      status: status,
      statusBeforeCancel: statusBeforeCancel,
      paymentMode: paymentMode,
      sparksCost: sparksCost,
      levelSnapshot: levelSnapshot,
      fulfilledAt: fulfilledAt,
      receivedAt: receivedAt,
      cancelRequestedById: cancelRequestedById,
      cancelRequestedAt: cancelRequestedAt,
      cancelledAt: cancelledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reward: reward.toDomain(),
      requester: requester.toDomain(),
      provider: provider.toDomain(),
    );
  }
}

class RewardUserDto {
  const RewardUserDto({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory RewardUserDto.fromJson(Map<String, dynamic> json) {
    return RewardUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  final String id;
  final String email;
  final String? displayName;

  RewardUser toDomain() {
    return RewardUser(id: id, email: email, displayName: displayName);
  }
}

class RewardMemberDto {
  const RewardMemberDto({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.user,
  });

  factory RewardMemberDto.fromJson(Map<String, dynamic> json) {
    return RewardMemberDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      role: _familyRoleFromJson(json['role'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] is Map<String, dynamic>
          ? RewardUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String familyId;
  final String userId;
  final FamilyRole role;
  final DateTime createdAt;
  final RewardUserDto? user;

  RewardMember toDomain() {
    return RewardMember(
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

RewardStatus _rewardStatusFromJson(String? value) {
  return switch (value) {
    'ACTIVE' => RewardStatus.active,
    'REJECTED' => RewardStatus.rejected,
    _ => RewardStatus.proposed,
  };
}

RewardPaymentMode _paymentModeFromJson(String? value) {
  return value == 'LEVEL_FREE'
      ? RewardPaymentMode.levelFree
      : RewardPaymentMode.sparks;
}

RewardRequestStatus _requestStatusFromJson(String? value) {
  return _nullableRequestStatusFromJson(value) ??
      RewardRequestStatus.inProgress;
}

RewardRequestStatus? _nullableRequestStatusFromJson(String? value) {
  return switch (value) {
    'FULFILLED' => RewardRequestStatus.fulfilled,
    'RECEIVED' => RewardRequestStatus.received,
    'CANCEL_REQUESTED' => RewardRequestStatus.cancelRequested,
    'CANCELLED' => RewardRequestStatus.cancelled,
    'IN_PROGRESS' => RewardRequestStatus.inProgress,
    _ => null,
  };
}

FamilyRole _familyRoleFromJson(String? value) {
  return switch (value) {
    'OWNER' => FamilyRole.owner,
    'ADULT' => FamilyRole.adult,
    _ => FamilyRole.child,
  };
}
