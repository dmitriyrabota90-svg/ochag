enum HistoryEntityType {
  family,
  task,
  taskTemplate,
  initiative,
  reward,
  rewardTemplate,
  rewardRequest,
  familyGoal,
  unknown,
}

extension HistoryEntityTypeX on HistoryEntityType {
  String? get apiValue {
    return switch (this) {
      HistoryEntityType.family => 'family',
      HistoryEntityType.task => 'task',
      HistoryEntityType.taskTemplate => 'task_template',
      HistoryEntityType.initiative => 'initiative',
      HistoryEntityType.reward => 'reward',
      HistoryEntityType.rewardTemplate => 'reward_template',
      HistoryEntityType.rewardRequest => 'reward_request',
      HistoryEntityType.familyGoal => 'family_goal',
      HistoryEntityType.unknown => null,
    };
  }
}

class HistoryActor {
  const HistoryActor({
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

class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.eventType,
    required this.entityType,
    required this.occurredAt,
    required this.summary,
    this.entityId,
    this.actor,
    this.payload = const {},
  });

  final String id;
  final String eventType;
  final HistoryEntityType entityType;
  final String? entityId;
  final DateTime occurredAt;
  final HistoryActor? actor;
  final String summary;
  final Map<String, dynamic> payload;
}

class HistoryPageInfo {
  const HistoryPageInfo({
    required this.limit,
    required this.hasMore,
    this.page,
    this.nextCursor,
  });

  final int limit;
  final int? page;
  final String? nextCursor;
  final bool hasMore;
}

class HistoryPage {
  const HistoryPage({
    required this.items,
    required this.pageInfo,
  });

  final List<HistoryEvent> items;
  final HistoryPageInfo pageInfo;
}
