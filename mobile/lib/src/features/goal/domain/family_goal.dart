import '../../family_setup/domain/family.dart';

enum FamilyGoalStatus {
  active,
  awaitingExecution,
  completed,
  cancelled,
}

class FamilyGoal {
  const FamilyGoal({
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
  final List<FamilyGoalConfirmation> confirmations;

  double get progress {
    if (targetSparks <= 0) {
      return 0;
    }
    return (currentSparks / targetSparks).clamp(0, 1).toDouble();
  }

  bool get isActive => status == FamilyGoalStatus.active;
  bool get isAwaitingExecution => status == FamilyGoalStatus.awaitingExecution;
  bool get isCompleted => status == FamilyGoalStatus.completed;
}

class FamilyGoalConfirmation {
  const FamilyGoalConfirmation({
    required this.id,
    required this.familyId,
    required this.goalId,
    required this.memberId,
    required this.createdAt,
    this.member,
  });

  final String id;
  final String familyId;
  final String goalId;
  final String memberId;
  final DateTime createdAt;
  final FamilyMember? member;
}

class FamilyGoalDraft {
  const FamilyGoalDraft({
    required this.title,
    required this.targetSparks,
    this.description,
    this.targetAt,
  });

  final String title;
  final String? description;
  final int targetSparks;
  final DateTime? targetAt;
}
