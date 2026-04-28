import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/family_goal.dart';
import 'family_goal_dto.dart';

final familyGoalRepositoryProvider = Provider<FamilyGoalRepository>((ref) {
  return FamilyGoalRepository(ref.watch(apiClientProvider));
});

class FamilyGoalRepository {
  const FamilyGoalRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<FamilyGoal> getCurrentGoal() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/family-goal');
    return FamilyGoalDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<FamilyGoal> createGoal(FamilyGoalDraft draft) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/family-goal',
      data: _draftData(draft),
    );
    return FamilyGoalDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<FamilyGoal> updateGoal({
    required String goalId,
    required FamilyGoalDraft draft,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/family-goal/$goalId',
      data: _draftData(draft),
    );
    return FamilyGoalDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<FamilyGoal> contribute({
    required String goalId,
    required int sparks,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/family-goal/$goalId/contributions',
      data: {'sparks': sparks},
    );
    return FamilyGoalDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<FamilyGoal> confirmCompletion(String goalId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/family-goal/$goalId/confirm-completion',
    );
    return FamilyGoalDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Map<String, dynamic> _draftData(FamilyGoalDraft draft) {
    return {
      'title': draft.title.trim(),
      if (draft.description != null) 'description': draft.description!.trim(),
      'targetSparks': draft.targetSparks,
      'targetAt': draft.targetAt?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Empty server response');
    }
    return data;
  }
}
