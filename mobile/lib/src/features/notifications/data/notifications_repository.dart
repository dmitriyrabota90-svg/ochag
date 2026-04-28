import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/notification.dart';
import 'notification_dto.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});

class NotificationsRepository {
  const NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<NotificationsPage> listNotifications({
    String? cursor,
    int limit = 30,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/v1/notifications',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty server response');
    }
    return NotificationsPageDto.fromJson(data).toDomain();
  }

  Future<AppNotification?> markAsRead(String notificationId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/v1/notifications/$notificationId/read',
    );
    final data = response.data;
    if (data == null) {
      return null;
    }
    return NotificationDto.fromJson(data).toDomain();
  }
}
