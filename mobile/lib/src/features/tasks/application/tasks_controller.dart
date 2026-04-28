import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../data/tasks_repository.dart';
import '../domain/task.dart';

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, TasksState>(TasksController.new);

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.templates = const [],
    this.selectedTask,
    this.includeHistory = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<Task> tasks;
  final List<TaskTemplate> templates;
  final Task? selectedTask;
  final bool includeHistory;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  TasksState copyWith({
    List<Task>? tasks,
    List<TaskTemplate>? templates,
    Task? selectedTask,
    bool? includeHistory,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedTask = false,
    bool clearMessages = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      templates: templates ?? this.templates,
      selectedTask:
          clearSelectedTask ? null : selectedTask ?? this.selectedTask,
      includeHistory: includeHistory ?? this.includeHistory,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
    );
  }
}

class TasksController extends AsyncNotifier<TasksState> {
  @override
  Future<TasksState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const TasksState();
    }
    return _load(includeHistory: false);
  }

  Future<void> reload() async {
    final current = state.valueOrNull ?? const TasksState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(includeHistory: current.includeHistory),
    );
  }

  Future<void> setIncludeHistory(bool includeHistory) async {
    final current = state.valueOrNull ?? const TasksState();
    state = AsyncData(current.copyWith(includeHistory: includeHistory));
    await reload();
  }

  Future<void> loadTask(String taskId) async {
    final current = state.valueOrNull ?? const TasksState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final task = await ref.read(tasksRepositoryProvider).getTask(taskId);
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          selectedTask: task,
          isSubmitting: false,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isSubmitting: false,
          errorMessage: _messageFromError(error),
          clearMessages: true,
        ),
      );
    }
  }

  Future<bool> createTask(TaskDraft draft) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).createTask(draft),
      'task_created',
    );
  }

  Future<bool> updateTask({
    required String taskId,
    required TaskDraft draft,
  }) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).updateTask(taskId, draft),
      'task_updated',
    );
  }

  Future<bool> deleteTask(String taskId) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).deleteTask(taskId),
      'task_deleted',
      clearSelectedTask: true,
    );
  }

  Future<bool> submitTask(String taskId) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).submitTask(taskId),
      'task_submitted',
    );
  }

  Future<bool> approveTask(String taskId) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).approveTask(taskId),
      'task_approved',
    );
  }

  Future<bool> rejectTask(String taskId) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).rejectTask(taskId),
      'task_rejected',
    );
  }

  Future<bool> addComment({
    required String taskId,
    required String body,
  }) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).createComment(
            taskId: taskId,
            body: body,
          ),
      'task_comment_added',
    );
  }

  Future<bool> createTemplate(TaskTemplateDraft draft) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).createTemplate(draft),
      'task_template_created',
    );
  }

  Future<bool> updateTemplate({
    required String templateId,
    required TaskTemplateDraft draft,
  }) async {
    return _mutateAndReload(
      () => ref.read(tasksRepositoryProvider).updateTemplate(
            templateId: templateId,
            draft: draft,
          ),
      'task_template_updated',
    );
  }

  bool canCreateTask(FamilyMember? currentMember) {
    return currentMember?.role.isAdult ?? false;
  }

  bool canSubmitTask(Task task, FamilyMember? currentMember) {
    return task.status == TaskStatus.active &&
        task.assigneeId == currentMember?.userId;
  }

  bool canEditTask(Task task, FamilyMember? currentMember) {
    return canCreateTask(currentMember) &&
        task.createdById == currentMember?.userId &&
        task.status == TaskStatus.active;
  }

  bool canReviewTask(
    Task task,
    FamilyMember? currentMember,
    List<FamilyMember> members,
  ) {
    if (currentMember == null ||
        task.status != TaskStatus.pendingConfirmation ||
        task.assigneeId == currentMember.userId) {
      return false;
    }
    if (currentMember.role.isAdult &&
        task.createdById == currentMember.userId) {
      return true;
    }

    final adultMembers =
        members.where((member) => member.role.isAdult).toList();
    final assignee =
        members.where((member) => member.userId == task.assigneeId);
    return adultMembers.length == 1 &&
        currentMember.role == FamilyRole.child &&
        assignee.isNotEmpty &&
        assignee.first.role.isAdult;
  }

  Future<TasksState> _load({required bool includeHistory}) async {
    final repository = ref.read(tasksRepositoryProvider);
    final tasks = await repository.listTasks(includeHistory: includeHistory);
    final templates = await repository.listTemplates();
    return TasksState(
      tasks: tasks,
      templates: templates,
      includeHistory: includeHistory,
    );
  }

  Future<bool> _mutateAndReload(
    Future<Object?> Function() action,
    String successMessage, {
    bool clearSelectedTask = false,
  }) async {
    final current = state.valueOrNull ?? const TasksState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final result = await action();
      final loaded = await _load(includeHistory: current.includeHistory);
      final selectedTask = clearSelectedTask
          ? null
          : result is Task
              ? result
              : current.selectedTask == null
                  ? null
                  : await ref
                      .read(tasksRepositoryProvider)
                      .getTask(current.selectedTask!.id);
      state = AsyncData(
        loaded.copyWith(
          selectedTask: selectedTask,
          successMessage: successMessage,
          clearMessages: true,
        ),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isSubmitting: false,
          errorMessage: _messageFromError(error),
          clearMessages: true,
        ),
      );
      return false;
    }
  }

  String _messageFromError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String) {
          return message;
        }
        if (message is List && message.isNotEmpty) {
          return message.join(', ');
        }
      }
      return error.message ?? 'Request failed';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
