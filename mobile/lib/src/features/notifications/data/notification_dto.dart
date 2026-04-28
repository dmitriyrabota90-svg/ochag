import '../domain/notification.dart';

class NotificationsPageDto {
  const NotificationsPageDto({
    required this.items,
    required this.pageInfo,
  });

  factory NotificationsPageDto.fromJson(Map<String, dynamic> json) {
    return NotificationsPageDto(
      items: (json['items'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(NotificationDto.fromJson)
          .toList(),
      pageInfo: NotificationsPageInfoDto.fromJson(
        json['pageInfo'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final List<NotificationDto> items;
  final NotificationsPageInfoDto pageInfo;

  NotificationsPage toDomain() {
    return NotificationsPage(
      items: items.map((item) => item.toDomain()).toList(),
      pageInfo: pageInfo.toDomain(),
    );
  }
}

class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.payload = const {},
    this.readAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : const {},
      readAt: _dateTimeFromJson(json['readAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      payload: payload,
      readAt: readAt,
      createdAt: createdAt,
    );
  }
}

class NotificationsPageInfoDto {
  const NotificationsPageInfoDto({
    required this.limit,
    required this.hasMore,
    this.nextCursor,
  });

  factory NotificationsPageInfoDto.fromJson(Map<String, dynamic> json) {
    return NotificationsPageInfoDto(
      limit: json['limit'] as int? ?? 30,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final int limit;
  final bool hasMore;
  final String? nextCursor;

  NotificationsPageInfo toDomain() {
    return NotificationsPageInfo(
      limit: limit,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value);
  }
  return null;
}
