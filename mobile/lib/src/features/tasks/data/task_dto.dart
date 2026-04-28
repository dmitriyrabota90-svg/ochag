import '../domain/task.dart';

class TaskDto {
  const TaskDto({
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

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: _statusFromJson(json['status'] as String),
      dueAt: _optionalDate(json['dueAt']),
      assigneeId: json['assigneeId'] as String?,
      createdById: json['createdById'] as String?,
      rewardSparks: json['rewardSparks'] as int? ?? 0,
      rewardExperience: json['rewardExperience'] as int? ?? 0,
      submittedAt: _optionalDate(json['submittedAt']),
      confirmedAt: _optionalDate(json['confirmedAt']),
      rejectedAt: _optionalDate(json['rejectedAt']),
      deletedAt: _optionalDate(json['deletedAt']),
      recurrence: _recurrenceFromJson(json['recurrence'] as String? ?? 'NONE'),
      templateId: json['templateId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      assignee: json['assignee'] is Map<String, dynamic>
          ? TaskUserDto.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? TaskUserDto.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      comments: (json['comments'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(TaskCommentDto.fromJson)
          .toList(),
    );
  }

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
  final TaskUserDto? assignee;
  final TaskUserDto? createdBy;
  final List<TaskCommentDto> comments;

  Task toDomain() {
    return Task(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      status: status,
      dueAt: dueAt,
      assigneeId: assigneeId,
      createdById: createdById,
      rewardSparks: rewardSparks,
      rewardExperience: rewardExperience,
      submittedAt: submittedAt,
      confirmedAt: confirmedAt,
      rejectedAt: rejectedAt,
      deletedAt: deletedAt,
      recurrence: recurrence,
      templateId: templateId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      assignee: assignee?.toDomain(),
      createdBy: createdBy?.toDomain(),
      comments: comments.map((comment) => comment.toDomain()).toList(),
    );
  }
}

class TaskUserDto {
  const TaskUserDto({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory TaskUserDto.fromJson(Map<String, dynamic> json) {
    return TaskUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  final String id;
  final String email;
  final String? displayName;

  TaskUser toDomain() {
    return TaskUser(
      id: id,
      email: email,
      displayName: displayName,
    );
  }
}

class TaskCommentDto {
  const TaskCommentDto({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.user,
  });

  factory TaskCommentDto.fromJson(Map<String, dynamic> json) {
    return TaskCommentDto(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] is Map<String, dynamic>
          ? TaskUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String taskId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final TaskUserDto? user;

  TaskComment toDomain() {
    return TaskComment(
      id: id,
      taskId: taskId,
      userId: userId,
      body: body,
      createdAt: createdAt,
      user: user?.toDomain(),
    );
  }
}

class TaskTemplateDto {
  const TaskTemplateDto({
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

  factory TaskTemplateDto.fromJson(Map<String, dynamic> json) {
    return TaskTemplateDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      rewardSparks: json['rewardSparks'] as int? ?? 0,
      rewardExperience: json['rewardExperience'] as int? ?? 0,
      recurrence: _recurrenceFromJson(json['recurrence'] as String? ?? 'NONE'),
      createdById: json['createdById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

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

  TaskTemplate toDomain() {
    return TaskTemplate(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      rewardSparks: rewardSparks,
      rewardExperience: rewardExperience,
      recurrence: recurrence,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

DateTime? _optionalDate(Object? value) {
  return value is String ? DateTime.parse(value) : null;
}

TaskStatus _statusFromJson(String value) {
  return switch (value) {
    'TODO' => TaskStatus.todo,
    'ACTIVE' => TaskStatus.active,
    'IN_PROGRESS' => TaskStatus.inProgress,
    'PENDING_CONFIRMATION' => TaskStatus.pendingConfirmation,
    'DONE' => TaskStatus.done,
    'CONFIRMED' => TaskStatus.confirmed,
    'SKIPPED' => TaskStatus.skipped,
    'CANCELLED' => TaskStatus.cancelled,
    _ => TaskStatus.active,
  };
}

TaskRecurrence _recurrenceFromJson(String value) {
  return switch (value) {
    'DAILY' => TaskRecurrence.daily,
    'WEEKLY' => TaskRecurrence.weekly,
    _ => TaskRecurrence.none,
  };
}
