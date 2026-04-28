import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/history.dart';
import 'history_dto.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(apiClientProvider));
});

class HistoryRepository {
  const HistoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<HistoryPage> listHistory({
    HistoryEntityType? entityType,
    String? eventType,
    String? cursor,
    int limit = 30,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/history',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (entityType?.apiValue != null) 'entityType': entityType!.apiValue,
        if (eventType != null && eventType.trim().isNotEmpty)
          'eventType': eventType.trim(),
      },
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty server response');
    }
    return HistoryPageDto.fromJson(data).toDomain();
  }
}
