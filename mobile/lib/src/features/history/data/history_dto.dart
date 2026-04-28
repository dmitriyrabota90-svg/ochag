import '../domain/history.dart';

class HistoryPageDto {
  const HistoryPageDto({
    required this.items,
    required this.pageInfo,
  });

  factory HistoryPageDto.fromJson(Map<String, dynamic> json) {
    return HistoryPageDto(
      items: (json['items'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(HistoryEventDto.fromJson)
          .toList(),
      pageInfo: HistoryPageInfoDto.fromJson(
        json['pageInfo'] as Map<String, dynamic>,
      ),
    );
  }

  final List<HistoryEventDto> items;
  final HistoryPageInfoDto pageInfo;

  HistoryPage toDomain() {
    return HistoryPage(
      items: items.map((item) => item.toDomain()).toList(),
      pageInfo: pageInfo.toDomain(),
    );
  }
}

class HistoryEventDto {
  const HistoryEventDto({
    required this.id,
    required this.eventType,
    required this.entityType,
    required this.occurredAt,
    required this.summary,
    this.entityId,
    this.actor,
    this.payload = const {},
  });

  factory HistoryEventDto.fromJson(Map<String, dynamic> json) {
    return HistoryEventDto(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      entityType: _entityTypeFromJson(json['entityType'] as String?),
      entityId: json['entityId'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      actor: json['actor'] is Map<String, dynamic>
          ? HistoryActorDto.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] as String? ?? json['eventType'] as String,
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : const {},
    );
  }

  final String id;
  final String eventType;
  final HistoryEntityType entityType;
  final String? entityId;
  final DateTime occurredAt;
  final HistoryActorDto? actor;
  final String summary;
  final Map<String, dynamic> payload;

  HistoryEvent toDomain() {
    return HistoryEvent(
      id: id,
      eventType: eventType,
      entityType: entityType,
      entityId: entityId,
      occurredAt: occurredAt,
      actor: actor?.toDomain(),
      summary: summary,
      payload: payload,
    );
  }
}

class HistoryActorDto {
  const HistoryActorDto({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory HistoryActorDto.fromJson(Map<String, dynamic> json) {
    return HistoryActorDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  final String id;
  final String email;
  final String? displayName;

  HistoryActor toDomain() {
    return HistoryActor(id: id, email: email, displayName: displayName);
  }
}

class HistoryPageInfoDto {
  const HistoryPageInfoDto({
    required this.limit,
    required this.hasMore,
    this.page,
    this.nextCursor,
  });

  factory HistoryPageInfoDto.fromJson(Map<String, dynamic> json) {
    return HistoryPageInfoDto(
      limit: json['limit'] as int? ?? 30,
      page: json['page'] as int?,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final int limit;
  final int? page;
  final String? nextCursor;
  final bool hasMore;

  HistoryPageInfo toDomain() {
    return HistoryPageInfo(
      limit: limit,
      page: page,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }
}

HistoryEntityType _entityTypeFromJson(String? value) {
  return switch (value) {
    'family' => HistoryEntityType.family,
    'task' => HistoryEntityType.task,
    'task_template' => HistoryEntityType.taskTemplate,
    'initiative' => HistoryEntityType.initiative,
    'reward' => HistoryEntityType.reward,
    'reward_template' => HistoryEntityType.rewardTemplate,
    'reward_request' => HistoryEntityType.rewardRequest,
    'family_goal' => HistoryEntityType.familyGoal,
    _ => HistoryEntityType.unknown,
  };
}
