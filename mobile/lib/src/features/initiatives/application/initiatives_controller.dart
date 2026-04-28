import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../data/initiatives_repository.dart';
import '../domain/initiative.dart';

final initiativesControllerProvider =
    AsyncNotifierProvider<InitiativesController, InitiativesState>(
  InitiativesController.new,
);

class InitiativesState {
  const InitiativesState({
    this.initiatives = const [],
    this.selectedInitiative,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<Initiative> initiatives;
  final Initiative? selectedInitiative;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  InitiativesState copyWith({
    List<Initiative>? initiatives,
    Initiative? selectedInitiative,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return InitiativesState(
      initiatives: initiatives ?? this.initiatives,
      selectedInitiative: selectedInitiative ?? this.selectedInitiative,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
    );
  }
}

class InitiativesController extends AsyncNotifier<InitiativesState> {
  @override
  Future<InitiativesState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const InitiativesState();
    }
    return _load();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadInitiative(String initiativeId) async {
    final current = state.valueOrNull ?? const InitiativesState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final initiative = await ref
          .read(initiativesRepositoryProvider)
          .getInitiative(initiativeId);
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          selectedInitiative: initiative,
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

  Future<bool> createInitiative(InitiativeDraft draft) async {
    return _mutateAndReload(
      () => ref.read(initiativesRepositoryProvider).createInitiative(draft),
      'initiative_created',
    );
  }

  Future<bool> approveInitiative({
    required String initiativeId,
    required int finalSparks,
  }) async {
    return _mutateAndReload(
      () => ref.read(initiativesRepositoryProvider).approveInitiative(
            initiativeId: initiativeId,
            finalSparks: finalSparks,
          ),
      'initiative_approved',
    );
  }

  Future<bool> approveWithoutReward(String initiativeId) async {
    return _mutateAndReload(
      () => ref
          .read(initiativesRepositoryProvider)
          .approveWithoutReward(initiativeId),
      'initiative_approved_without_reward',
    );
  }

  Future<bool> rejectInitiative(String initiativeId) async {
    return _mutateAndReload(
      () => ref
          .read(initiativesRepositoryProvider)
          .rejectInitiative(initiativeId),
      'initiative_rejected',
    );
  }

  bool canCreateInitiative(FamilyMember? currentMember) {
    return currentMember != null;
  }

  bool canReviewInitiative(
    Initiative initiative,
    FamilyMember? currentMember,
    List<FamilyMember> members,
  ) {
    if (currentMember == null ||
        !initiative.isWaitingDecision ||
        initiative.createdById == currentMember.userId) {
      return false;
    }
    if (currentMember.role.isAdult) {
      return true;
    }
    final adultMembers =
        members.where((member) => member.role.isAdult).toList();
    final submitter = members.where(
      (member) => member.userId == initiative.createdById,
    );
    return adultMembers.length == 1 &&
        currentMember.role == FamilyRole.child &&
        submitter.isNotEmpty &&
        submitter.first.role.isAdult;
  }

  Future<InitiativesState> _load() async {
    final initiatives =
        await ref.read(initiativesRepositoryProvider).listInitiatives();
    return InitiativesState(initiatives: initiatives);
  }

  Future<bool> _mutateAndReload(
    Future<Initiative> Function() action,
    String successMessage,
  ) async {
    final current = state.valueOrNull ?? const InitiativesState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final initiative = await action();
      final loaded = await _load();
      state = AsyncData(
        loaded.copyWith(
          selectedInitiative: initiative,
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
