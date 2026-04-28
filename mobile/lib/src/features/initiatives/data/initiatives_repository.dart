import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/initiative.dart';
import 'initiative_dto.dart';

final initiativesRepositoryProvider = Provider<InitiativesRepository>((ref) {
  return InitiativesRepository(ref.watch(apiClientProvider));
});

class InitiativesRepository {
  const InitiativesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Initiative>> listInitiatives() async {
    final response = await _apiClient.get<List<dynamic>>('/initiatives');
    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((json) => InitiativeDto.fromJson(json).toDomain())
        .toList();
  }

  Future<Initiative> getInitiative(String initiativeId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/initiatives/$initiativeId',
    );
    return InitiativeDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Initiative> createInitiative(InitiativeDraft draft) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/initiatives',
      data: {
        'title': draft.title.trim(),
        if (draft.description != null) 'description': draft.description!.trim(),
      },
    );
    return InitiativeDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Initiative> approveInitiative({
    required String initiativeId,
    required int finalSparks,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/initiatives/$initiativeId/approve',
      data: {'finalSparks': finalSparks},
    );
    return InitiativeDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Initiative> approveWithoutReward(String initiativeId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/initiatives/$initiativeId/approve-without-reward',
    );
    return InitiativeDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Initiative> rejectInitiative(String initiativeId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/initiatives/$initiativeId/reject',
    );
    return InitiativeDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Empty server response');
    }
    return data;
  }
}
