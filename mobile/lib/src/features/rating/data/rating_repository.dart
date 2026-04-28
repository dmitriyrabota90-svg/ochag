import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/rating.dart';
import 'rating_dto.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository(ref.watch(apiClientProvider));
});

class RatingRepository {
  const RatingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<RatingResult> getRating(AnalyticsPeriod period) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/rating',
      queryParameters: {'period': period.apiValue},
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty server response');
    }
    return RatingResultDto.fromJson(data).toDomain();
  }

  Future<AnalyticsSummary> getSummary(AnalyticsPeriod period) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/analytics/summary',
      queryParameters: {'period': period.apiValue},
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty server response');
    }
    return AnalyticsSummaryDto.fromJson(data).toDomain();
  }
}
