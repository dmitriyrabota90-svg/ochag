enum TaskStatus {
  todo,
  active,
  inProgress,
  pendingConfirmation,
  done,
  confirmed,
  skipped,
  cancelled,
}

enum TaskRecurrence {
  none,
  daily,
  weekly,
}

extension TaskRecurrenceX on TaskRecurrence {
  String get apiValue {
    return switch (this) {
      TaskRecurrence.none => 'NONE',
      TaskRecurrence.daily => 'DAILY',
      TaskRecurrence.weekly => 'WEEKLY',
    };
  }
}

class TaskUser {
  const TaskUser({
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

class Task {
  const Task({
    required this.id,
    required this.familyId,
    required this.title,
    required this.status,
    required this.rewardSparks,
    required this.rewardExperience,
    required this.recurrence,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueAt,
    this.assigneeId,
    this.createdById,
    this.submittedAt,
    this.confirmedAt,
    this.rejectedAt,
    this.deletedAt,
    this.templateId,
    this.assignee,
    this.createdBy,
    this.comments = const [],
  });

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueAt;
  final String? assigneeId;
  final String? createdById;
  final int rewardSparks;
  final int rewardExperience;
  final DateTime? submittedAt;
  final DateTime? confirmedAt;
  final DateTime? rejectedAt;
  final DateTime? deletedAt;
  final TaskRecurrence recurrence;
  final String? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TaskUser? assignee;
  final TaskUser? createdBy;
  final List<TaskComment> comments;

  bool get isHistory =>
      status == TaskStatus.confirmed ||
      status == TaskStatus.skipped ||
      status == TaskStatus.cancelled ||
      deletedAt != null;
}

class TaskComment {
  const TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.user,
  });

  final String id;
  final String taskId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final TaskUser? user;
}

class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.familyId,
    required this.title,
    required this.rewardSparks,
    required this.rewardExperience,
    required this.recurrence,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final int rewardSparks;
  final int rewardExperience;
  final TaskRecurrence recurrence;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.assigneeMemberId,
    this.description,
    this.dueAt,
    this.rewardSparks = 0,
    this.rewardExperience = 0,
    this.recurrence = TaskRecurrence.none,
    this.templateId,
  });

  final String title;
  final String? description;
  final String assigneeMemberId;
  final DateTime? dueAt;
  final int rewardSparks;
  final int rewardExperience;
  final TaskRecurrence recurrence;
  final String? templateId;
}

class TaskTemplateDraft {
  const TaskTemplateDraft({
    required this.title,
    this.description,
    this.rewardSparks = 0,
    this.rewardExperience = 0,
    this.recurrence = TaskRecurrence.none,
  });

  final String title;
  final String? description;
  final int rewardSparks;
  final int rewardExperience;
  final TaskRecurrence recurrence;
}
