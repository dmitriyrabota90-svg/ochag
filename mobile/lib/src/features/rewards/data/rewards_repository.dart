import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/reward.dart';
import 'reward_dto.dart';

final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return RewardsRepository(ref.watch(apiClientProvider));
});

class RewardsRepository {
  const RewardsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Reward>> listRewards() async {
    final response = await _apiClient.get<List<dynamic>>('/rewards');
    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((json) => RewardDto.fromJson(json).toDomain())
        .toList();
  }

  Future<Reward> getReward(String rewardId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/rewards/$rewardId',
    );
    return RewardDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Reward> createReward(RewardDraft draft) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/rewards',
      data: _rewardDraftData(draft),
    );
    return RewardDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Reward> approveReward(String rewardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/rewards/$rewardId/approve',
    );
    return RewardDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Reward> repriceReward({
    required String rewardId,
    required int pointsCost,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/rewards/$rewardId/reprice',
      data: {'pointsCost': pointsCost},
    );
    return RewardDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Reward> rejectReward(String rewardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/rewards/$rewardId/reject',
    );
    return RewardDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<List<RewardTemplate>> listTemplates() async {
    final response = await _apiClient.get<List<dynamic>>('/reward-templates');
    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((json) => RewardTemplateDto.fromJson(json).toDomain())
        .toList();
  }

  Future<RewardTemplate> createTemplate(RewardDraft draft) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reward-templates',
      data: _rewardDraftData(draft),
    );
    return RewardTemplateDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardTemplate> updateTemplate({
    required String templateId,
    required RewardDraft draft,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/reward-templates/$templateId',
      data: _rewardDraftData(draft),
    );
    return RewardTemplateDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardRequest> createRequest(String rewardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reward-requests',
      data: {'rewardId': rewardId},
    );
    return RewardRequestDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardRequest> getRequest(String requestId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reward-requests/$requestId',
    );
    return RewardRequestDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardRequest> markFulfilled(String requestId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reward-requests/$requestId/mark-fulfilled',
    );
    return RewardRequestDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardRequest> confirmReceived(String requestId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reward-requests/$requestId/confirm-received',
    );
    return RewardRequestDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardRequest> requestCancel(String requestId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reward-requests/$requestId/cancel',
    );
    return RewardRequestDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<RewardRequest> respondCancel({
    required String requestId,
    required bool approve,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reward-requests/$requestId/cancel/respond',
      data: {'approve': approve},
    );
    return RewardRequestDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Map<String, dynamic> _rewardDraftData(RewardDraft draft) {
    return {
      'title': draft.title.trim(),
      if (draft.description != null) 'description': draft.description!.trim(),
      'pointsCost': draft.pointsCost,
      'paymentMode': draft.paymentMode.apiValue,
    };
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Empty server response');
    }
    return data;
  }
}
