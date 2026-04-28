enum InitiativeStatus {
  draft,
  active,
  discussion,
  approved,
  approvedWithoutReward,
  rejected,
  completed,
  cancelled,
}

enum InitiativeDisplayStatus {
  discussion,
  waitingDecision,
  approved,
  approvedWithoutReward,
  rejected,
}

class InitiativeUser {
  const InitiativeUser({
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

class Initiative {
  const Initiative({
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
  final InitiativeUser? createdBy;
  final InitiativeUser? decidedBy;

  InitiativeDisplayStatus get displayStatus {
    return switch (status) {
      InitiativeStatus.approved => InitiativeDisplayStatus.approved,
      InitiativeStatus.approvedWithoutReward =>
        InitiativeDisplayStatus.approvedWithoutReward,
      InitiativeStatus.rejected => InitiativeDisplayStatus.rejected,
      _ => isWaitingDecision
          ? InitiativeDisplayStatus.waitingDecision
          : InitiativeDisplayStatus.discussion,
    };
  }

  bool get isDiscussionLocked {
    final lockedUntil = discussionLockedUntil;
    return status == InitiativeStatus.discussion &&
        lockedUntil != null &&
        lockedUntil.isAfter(DateTime.now());
  }

  bool get isWaitingDecision {
    final lockedUntil = discussionLockedUntil;
    return status == InitiativeStatus.discussion &&
        (lockedUntil == null || !lockedUntil.isAfter(DateTime.now()));
  }
}

class InitiativeDraft {
  const InitiativeDraft({
    required this.title,
    this.description,
  });

  final String title;
  final String? description;
}
