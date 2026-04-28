import '../../family_setup/domain/family.dart';

enum RewardStatus {
  proposed,
  active,
  rejected,
}

enum RewardPaymentMode {
  sparks,
  levelFree,
}

extension RewardPaymentModeX on RewardPaymentMode {
  String get apiValue {
    return switch (this) {
      RewardPaymentMode.sparks => 'SPARKS',
      RewardPaymentMode.levelFree => 'LEVEL_FREE',
    };
  }
}

enum RewardRequestStatus {
  inProgress,
  fulfilled,
  received,
  cancelRequested,
  cancelled,
}

class RewardUser {
  const RewardUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : email;
}

class Reward {
  const Reward({
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
  final RewardUser? createdBy;
  final RewardUser? approvedBy;

  bool get isAvailable => status == RewardStatus.active;
  bool get usesSparks => paymentMode == RewardPaymentMode.sparks;
  bool get usesLevelFree => paymentMode == RewardPaymentMode.levelFree;
}

class RewardTemplate {
  const RewardTemplate({
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

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final int pointsCost;
  final RewardPaymentMode paymentMode;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class RewardMember {
  const RewardMember({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.user,
  });

  final String id;
  final String familyId;
  final String userId;
  final FamilyRole role;
  final DateTime createdAt;
  final RewardUser? user;

  String get displayName => user?.name ?? userId;
}

class RewardRequest {
  const RewardRequest({
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
  final Reward reward;
  final RewardMember requester;
  final RewardMember provider;

  bool get isInProgress => status == RewardRequestStatus.inProgress;
  bool get isFulfilled => status == RewardRequestStatus.fulfilled;
  bool get isReceived => status == RewardRequestStatus.received;
  bool get isCancelRequested => status == RewardRequestStatus.cancelRequested;
  bool get isCancelled => status == RewardRequestStatus.cancelled;
}

class RewardDraft {
  const RewardDraft({
    required this.title,
    required this.pointsCost,
    required this.paymentMode,
    this.description,
  });

  final String title;
  final String? description;
  final int pointsCost;
  final RewardPaymentMode paymentMode;
}
