import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../data/family_goal_repository.dart';
import '../domain/family_goal.dart';

final familyGoalControllerProvider =
    AsyncNotifierProvider<FamilyGoalController, FamilyGoalState>(
  FamilyGoalController.new,
);

class FamilyGoalState {
  const FamilyGoalState({
    this.goal,
    this.hasGoal = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final FamilyGoal? goal;
  final bool hasGoal;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  FamilyGoalState copyWith({
    FamilyGoal? goal,
    bool? hasGoal,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return FamilyGoalState(
      goal: goal ?? this.goal,
      hasGoal: hasGoal ?? this.hasGoal,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
    );
  }
}

class FamilyGoalController extends AsyncNotifier<FamilyGoalState> {
  @override
  Future<FamilyGoalState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const FamilyGoalState();
    }
    return _load();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<bool> createGoal(FamilyGoalDraft draft) async {
    return _mutate(
      () => ref.read(familyGoalRepositoryProvider).createGoal(draft),
      'family_goal_created',
    );
  }

  Future<bool> updateGoal({
    required String goalId,
    required FamilyGoalDraft draft,
  }) async {
    return _mutate(
      () => ref
          .read(familyGoalRepositoryProvider)
          .updateGoal(goalId: goalId, draft: draft),
      'family_goal_updated',
    );
  }

  Future<bool> contribute({
    required String goalId,
    required int sparks,
  }) async {
    return _mutate(
      () => ref
          .read(familyGoalRepositoryProvider)
          .contribute(goalId: goalId, sparks: sparks),
      'family_goal_contributed',
    );
  }

  Future<bool> confirmCompletion(String goalId) async {
    return _mutate(
      () => ref.read(familyGoalRepositoryProvider).confirmCompletion(goalId),
      'family_goal_confirmed',
    );
  }

  bool canManageGoal(FamilyMember? currentMember) {
    return currentMember?.role.isAdult ?? false;
  }

  bool canContribute(FamilyGoal? goal, FamilyMember? currentMember) {
    return goal?.isActive == true && currentMember != null;
  }

  bool canConfirmCompletion(FamilyGoal? goal, FamilyMember? currentMember) {
    if (goal?.isAwaitingExecution != true || currentMember == null) {
      return false;
    }
    final alreadyConfirmed = goal!.confirmations.any(
      (confirmation) => confirmation.memberId == currentMember.id,
    );
    return !alreadyConfirmed;
  }

  int contributionExperience(int sparks) {
    return (sparks * 1.5).floor();
  }

  Future<FamilyGoalState> _load() async {
    try {
      final goal =
          await ref.read(familyGoalRepositoryProvider).getCurrentGoal();
      return FamilyGoalState(goal: goal, hasGoal: true);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const FamilyGoalState();
      }
      return FamilyGoalState(errorMessage: _messageFromError(error));
    }
  }

  Future<bool> _mutate(
    Future<FamilyGoal> Function() action,
    String successMessage,
  ) async {
    final current = state.valueOrNull ?? const FamilyGoalState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final goal = await action();
      state = AsyncData(
        FamilyGoalState(
          goal: goal,
          hasGoal: true,
          successMessage: successMessage,
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
