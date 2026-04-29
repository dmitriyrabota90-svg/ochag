import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/feedback_entry.dart';
import 'feedback_dto.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(
    apiClient: ref.watch(apiClientProvider),
    endpointPath: _feedbackEndpointPath,
  );
});

const String _feedbackEndpointPath = '/feedback';

class FeedbackRepository {
  const FeedbackRepository({
    required ApiClient apiClient,
    required String endpointPath,
  })  : _apiClient = apiClient,
        _endpointPath = endpointPath;

  final ApiClient _apiClient;
  final String _endpointPath;

  Future<void> submitFeedback(FeedbackSubmission submission) async {
    final dto = FeedbackRequestDto.fromDomain(submission);

    await _apiClient.post<Map<String, dynamic>>(
      _endpointPath,
      data: dto.toJson(),
    );
  }
}
