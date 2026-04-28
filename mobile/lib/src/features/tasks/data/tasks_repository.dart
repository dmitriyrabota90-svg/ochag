import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/task.dart';
import 'task_dto.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(apiClientProvider));
});

class TasksRepository {
  const TasksRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Task>> listTasks({bool includeHistory = false}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/tasks',
      queryParameters: {'includeHistory': includeHistory},
    );
    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((json) => TaskDto.fromJson(json).toDomain())
        .toList();
  }

  Future<Task> getTask(String taskId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/tasks/$taskId',
    );
    return TaskDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Task> createTask(TaskDraft draft) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/tasks',
      data: _taskDraftData(draft),
    );
    return TaskDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Task> updateTask(String taskId, TaskDraft draft) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/tasks/$taskId',
      data: _taskDraftData(draft),
    );
    return TaskDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<void> deleteTask(String taskId) async {
    await _apiClient.delete<Map<String, dynamic>>('/tasks/$taskId');
  }

  Future<Task> submitTask(String taskId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/tasks/$taskId/submit',
    );
    return TaskDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Task> approveTask(String taskId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/tasks/$taskId/approve',
    );
    return TaskDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<Task> rejectTask(String taskId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/tasks/$taskId/reject',
    );
    return TaskDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<TaskComment> createComment({
    required String taskId,
    required String body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/tasks/$taskId/comments',
      data: {'body': body.trim()},
    );
    return TaskCommentDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<List<TaskTemplate>> listTemplates() async {
    final response = await _apiClient.get<List<dynamic>>('/task-templates');
    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((json) => TaskTemplateDto.fromJson(json).toDomain())
        .toList();
  }

  Future<TaskTemplate> createTemplate(TaskTemplateDraft draft) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/task-templates',
      data: _templateDraftData(draft),
    );
    return TaskTemplateDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<TaskTemplate> updateTemplate({
    required String templateId,
    required TaskTemplateDraft draft,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/task-templates/$templateId',
      data: _templateDraftData(draft),
    );
    return TaskTemplateDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Map<String, dynamic> _taskDraftData(TaskDraft draft) {
    return {
      'title': draft.title.trim(),
      if (draft.description != null) 'description': draft.description!.trim(),
      'assigneeId': draft.assigneeMemberId,
      'dueAt': draft.dueAt?.toUtc().toIso8601String(),
      'rewardSparks': draft.rewardSparks,
      'rewardExperience': draft.rewardExperience,
      'recurrence': draft.recurrence.apiValue,
      if (draft.templateId != null) 'templateId': draft.templateId,
    };
  }

  Map<String, dynamic> _templateDraftData(TaskTemplateDraft draft) {
    return {
      'title': draft.title.trim(),
      if (draft.description != null) 'description': draft.description!.trim(),
      'rewardSparks': draft.rewardSparks,
      'rewardExperience': draft.rewardExperience,
      'recurrence': draft.recurrence.apiValue,
    };
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Empty server response');
    }
    return data;
  }
}
