class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.payload = const {},
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationsPageInfo {
  const NotificationsPageInfo({
    required this.limit,
    required this.hasMore,
    this.nextCursor,
  });

  final int limit;
  final bool hasMore;
  final String? nextCursor;
}

class NotificationsPage {
  const NotificationsPage({
    required this.items,
    required this.pageInfo,
  });

  final List<AppNotification> items;
  final NotificationsPageInfo pageInfo;
}
