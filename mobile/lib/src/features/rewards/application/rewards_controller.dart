import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../../family_setup/domain/family.dart';
import '../data/rewards_repository.dart';
import '../domain/reward.dart';

final rewardsControllerProvider =
    AsyncNotifierProvider<RewardsController, RewardsState>(
  RewardsController.new,
);

class RewardsState {
  const RewardsState({
    this.rewards = const [],
    this.templates = const [],
    this.requests = const [],
    this.selectedReward,
    this.selectedRequest,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<Reward> rewards;
  final List<RewardTemplate> templates;
  final List<RewardRequest> requests;
  final Reward? selectedReward;
  final RewardRequest? selectedRequest;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  RewardsState copyWith({
    List<Reward>? rewards,
    List<RewardTemplate>? templates,
    List<RewardRequest>? requests,
    Reward? selectedReward,
    RewardRequest? selectedRequest,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return RewardsState(
      rewards: rewards ?? this.rewards,
      templates: templates ?? this.templates,
      requests: requests ?? this.requests,
      selectedReward: selectedReward ?? this.selectedReward,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
    );
  }
}

class RewardsController extends AsyncNotifier<RewardsState> {
  @override
  Future<RewardsState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const RewardsState();
    }
    return _load();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadReward(String rewardId) async {
    final current = state.valueOrNull ?? const RewardsState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final reward =
          await ref.read(rewardsRepositoryProvider).getReward(rewardId);
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          selectedReward: reward,
          isSubmitting: false,
        ),
      );
    } catch (error) {
      _emitError(current, error);
    }
  }

  Future<void> loadRequest(String requestId) async {
    final current = state.valueOrNull ?? const RewardsState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final request =
          await ref.read(rewardsRepositoryProvider).getRequest(requestId);
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          selectedRequest: request,
          requests: _upsertRequest(current.requests, request),
          isSubmitting: false,
        ),
      );
    } catch (error) {
      _emitError(current, error);
    }
  }

  Future<bool> createReward(RewardDraft draft) async {
    return _mutateReward(
      () => ref.read(rewardsRepositoryProvider).createReward(draft),
      'reward_created',
    );
  }

  Future<bool> approveReward(String rewardId) async {
    return _mutateReward(
      () => ref.read(rewardsRepositoryProvider).approveReward(rewardId),
      'reward_approved',
    );
  }

  Future<bool> repriceReward({
    required String rewardId,
    required int pointsCost,
  }) async {
    return _mutateReward(
      () => ref.read(rewardsRepositoryProvider).repriceReward(
            rewardId: rewardId,
            pointsCost: pointsCost,
          ),
      'reward_repriced',
    );
  }

  Future<bool> rejectReward(String rewardId) async {
    return _mutateReward(
      () => ref.read(rewardsRepositoryProvider).rejectReward(rewardId),
      'reward_rejected',
    );
  }

  Future<bool> createTemplate(RewardDraft draft) async {
    return _mutateTemplate(
      () => ref.read(rewardsRepositoryProvider).createTemplate(draft),
      'reward_template_created',
    );
  }

  Future<bool> updateTemplate({
    required String templateId,
    required RewardDraft draft,
  }) async {
    return _mutateTemplate(
      () => ref.read(rewardsRepositoryProvider).updateTemplate(
            templateId: templateId,
            draft: draft,
          ),
      'reward_template_updated',
    );
  }

  Future<bool> createRequest(String rewardId) async {
    return _mutateRequest(
      () => ref.read(rewardsRepositoryProvider).createRequest(rewardId),
      'reward_requested',
    );
  }

  Future<bool> markFulfilled(String requestId) async {
    return _mutateRequest(
      () => ref.read(rewardsRepositoryProvider).markFulfilled(requestId),
      'reward_fulfilled',
    );
  }

  Future<bool> confirmReceived(String requestId) async {
    return _mutateRequest(
      () => ref.read(rewardsRepositoryProvider).confirmReceived(requestId),
      'reward_received',
    );
  }

  Future<bool> requestCancel(String requestId) async {
    return _mutateRequest(
      () => ref.read(rewardsRepositoryProvider).requestCancel(requestId),
      'reward_cancel_requested',
    );
  }

  Future<bool> respondCancel({
    required String requestId,
    required bool approve,
  }) async {
    return _mutateRequest(
      () => ref.read(rewardsRepositoryProvider).respondCancel(
            requestId: requestId,
            approve: approve,
          ),
      approve ? 'reward_cancelled' : 'reward_cancel_rejected',
    );
  }

  bool canProposeReward(FamilyMember? currentMember) {
    return currentMember != null;
  }

  bool canManageTemplates(FamilyMember? currentMember) {
    return currentMember?.role.isAdult ?? false;
  }

  bool canReviewReward(Reward reward, FamilyMember? currentMember) {
    return reward.status == RewardStatus.proposed &&
        (currentMember?.role.isAdult ?? false) &&
        reward.createdById != currentMember?.userId;
  }

  bool canRequestReward(Reward reward, FamilyMember? currentMember) {
    return reward.status == RewardStatus.active && currentMember != null;
  }

  bool canMarkFulfilled(RewardRequest request, FamilyMember? currentMember) {
    return request.isInProgress &&
        request.providerMemberId == currentMember?.id;
  }

  bool canConfirmReceived(RewardRequest request, FamilyMember? currentMember) {
    return request.isFulfilled &&
        request.requesterMemberId == currentMember?.id;
  }

  bool canRequestCancel(RewardRequest request, FamilyMember? currentMember) {
    return currentMember != null &&
        (request.requesterMemberId == currentMember.id ||
            request.providerMemberId == currentMember.id) &&
        !request.isReceived &&
        !request.isCancelled &&
        !request.isCancelRequested;
  }

  bool canRespondCancel(RewardRequest request, FamilyMember? currentMember) {
    return request.isCancelRequested &&
        currentMember != null &&
        (request.requesterMemberId == currentMember.id ||
            request.providerMemberId == currentMember.id) &&
        request.cancelRequestedById != currentMember.id;
  }

  Future<RewardsState> _load() async {
    final repository = ref.read(rewardsRepositoryProvider);
    final rewards = await repository.listRewards();
    final templates = await repository.listTemplates();
    return (state.valueOrNull ?? const RewardsState()).copyWith(
      rewards: rewards,
      templates: templates,
      isSubmitting: false,
      clearMessages: true,
    );
  }

  Future<bool> _mutateReward(
    Future<Reward> Function() action,
    String successMessage,
  ) async {
    final current = state.valueOrNull ?? const RewardsState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final reward = await action();
      final loaded = await _load();
      state = AsyncData(
        loaded.copyWith(
          selectedReward: reward,
          successMessage: successMessage,
          clearMessages: true,
        ),
      );
      return true;
    } catch (error) {
      _emitError(current, error);
      return false;
    }
  }

  Future<bool> _mutateTemplate(
    Future<RewardTemplate> Function() action,
    String successMessage,
  ) async {
    final current = state.valueOrNull ?? const RewardsState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await action();
      final loaded = await _load();
      state = AsyncData(
        loaded.copyWith(
          successMessage: successMessage,
          clearMessages: true,
        ),
      );
      return true;
    } catch (error) {
      _emitError(current, error);
      return false;
    }
  }

  Future<bool> _mutateRequest(
    Future<RewardRequest> Function() action,
    String successMessage,
  ) async {
    final current = state.valueOrNull ?? const RewardsState();
    state =
        AsyncData(current.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final request = await action();
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          requests: _upsertRequest(current.requests, request),
          selectedRequest: request,
          isSubmitting: false,
          successMessage: successMessage,
          clearMessages: true,
        ),
      );
      return true;
    } catch (error) {
      _emitError(current, error);
      return false;
    }
  }

  List<RewardRequest> _upsertRequest(
    List<RewardRequest> requests,
    RewardRequest request,
  ) {
    return [
      request,
      ...requests.where((item) => item.id != request.id),
    ];
  }

  void _emitError(RewardsState current, Object error) {
    state = AsyncData(
      current.copyWith(
        isSubmitting: false,
        errorMessage: _messageFromError(error),
        clearMessages: true,
      ),
    );
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
