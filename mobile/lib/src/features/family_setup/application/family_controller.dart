import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../../auth/application/auth_controller.dart';
import '../data/family_repository.dart';
import '../domain/family.dart';

final familyControllerProvider =
    AsyncNotifierProvider<FamilyController, FamilyState>(
  FamilyController.new,
);

final currentFamilyProvider = Provider<Family?>((ref) {
  return ref.watch(familyControllerProvider).valueOrNull?.family;
});

final currentFamilyMemberProvider = Provider<FamilyMember?>((ref) {
  return ref.watch(familyControllerProvider).valueOrNull?.currentMember;
});

final currentFamilyMembersProvider = Provider<List<FamilyMember>>((ref) {
  return ref.watch(familyControllerProvider).valueOrNull?.members ?? const [];
});

enum FamilyStatus {
  noFamily,
  hasFamily,
}

class FamilyState {
  const FamilyState({
    required this.status,
    this.family,
    this.currentMember,
    this.members = const [],
    this.invite,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  const FamilyState.noFamily({
    bool isSubmitting = false,
    String? errorMessage,
    String? successMessage,
  }) : this(
          status: FamilyStatus.noFamily,
          isSubmitting: isSubmitting,
          errorMessage: errorMessage,
          successMessage: successMessage,
        );

  const FamilyState.hasFamily({
    required Family family,
    required FamilyMember currentMember,
    List<FamilyMember> members = const [],
    FamilyInvite? invite,
    bool isSubmitting = false,
    String? errorMessage,
    String? successMessage,
  }) : this(
          status: FamilyStatus.hasFamily,
          family: family,
          currentMember: currentMember,
          members: members,
          invite: invite,
          isSubmitting: isSubmitting,
          errorMessage: errorMessage,
          successMessage: successMessage,
        );

  final FamilyStatus status;
  final Family? family;
  final FamilyMember? currentMember;
  final List<FamilyMember> members;
  final FamilyInvite? invite;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  bool get hasFamily => status == FamilyStatus.hasFamily;
  bool get canManageFamily => currentMember?.role.isCreator ?? false;
  bool get canManageInvites => currentMember?.role.isAdult ?? false;

  FamilyState copyWith({
    FamilyStatus? status,
    Family? family,
    FamilyMember? currentMember,
    List<FamilyMember>? members,
    FamilyInvite? invite,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearInvite = false,
    bool clearMessages = false,
  }) {
    return FamilyState(
      status: status ?? this.status,
      family: family ?? this.family,
      currentMember: currentMember ?? this.currentMember,
      members: members ?? this.members,
      invite: clearInvite ? null : invite ?? this.invite,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
    );
  }
}

class FamilyController extends AsyncNotifier<FamilyState> {
  @override
  Future<FamilyState> build() async {
    final authState = await ref.watch(authControllerProvider.future);
    if (!authState.isAuthenticated) {
      return const FamilyState.noFamily();
    }

    return _loadCurrentFamily();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadCurrentFamily);
  }

  Future<bool> createFamily(String name) async {
    return _submitWithContext(
      action: () => ref.read(familyRepositoryProvider).createFamily(name),
      successMessage: 'family_created',
    );
  }

  Future<bool> joinFamily(String inviteCodeOrLink) async {
    return _submitWithContext(
      action: () => ref
          .read(familyRepositoryProvider)
          .joinFamily(_extractInviteCode(inviteCodeOrLink)),
      successMessage: 'family_joined',
    );
  }

  Future<bool> updateFamilyName(String name) async {
    return _submit(
      action: () async {
        final family =
            await ref.read(familyRepositoryProvider).updateFamilyName(name);
        final current = state.valueOrNull;
        if (current == null || current.currentMember == null) {
          return;
        }
        state = AsyncData(
          current.copyWith(
            family: family,
            isSubmitting: false,
            successMessage: 'family_updated',
            clearMessages: true,
          ),
        );
      },
    );
  }

  Future<bool> leaveFamily() async {
    return _submit(
      action: () async {
        await ref.read(familyRepositoryProvider).leaveFamily();
        state = const AsyncData(
          FamilyState.noFamily(successMessage: 'family_left'),
        );
      },
    );
  }

  Future<bool> changeMemberRole({
    required String memberId,
    required FamilyRole role,
  }) async {
    return _mutateAndReload(
      () => ref.read(familyRepositoryProvider).changeMemberRole(
            memberId: memberId,
            role: role,
          ),
      'member_role_updated',
    );
  }

  Future<bool> removeMember(String memberId) async {
    return _mutateAndReload(
      () => ref.read(familyRepositoryProvider).removeMember(memberId),
      'member_removed',
    );
  }

  Future<bool> transferCreator(String memberId) async {
    return _mutateAndReload(
      () => ref.read(familyRepositoryProvider).transferCreator(memberId),
      'creator_transferred',
    );
  }

  Future<bool> createInviteLink() async {
    return _submit(
      action: () async {
        final invite =
            await ref.read(familyRepositoryProvider).createInviteLink();
        final current = state.valueOrNull;
        if (current == null) {
          return;
        }
        state = AsyncData(
          current.copyWith(
            invite: invite,
            isSubmitting: false,
            successMessage: 'invite_created',
            clearMessages: true,
          ),
        );
      },
    );
  }

  Future<bool> regenerateInviteCode() async {
    return _submit(
      action: () async {
        final invite =
            await ref.read(familyRepositoryProvider).regenerateInviteCode();
        final current = state.valueOrNull;
        if (current == null) {
          return;
        }
        state = AsyncData(
          current.copyWith(
            invite: invite,
            isSubmitting: false,
            successMessage: 'invite_regenerated',
            clearMessages: true,
          ),
        );
      },
    );
  }

  Future<bool> requestFamilyDelete() async {
    return _mutateAndKeepContext(
      () => ref.read(familyRepositoryProvider).requestFamilyDelete(),
      'family_delete_requested',
    );
  }

  Future<FamilyState> _loadCurrentFamily() async {
    try {
      final context =
          await ref.read(familyRepositoryProvider).getCurrentFamily();
      final members =
          await ref.read(familyRepositoryProvider).getCurrentFamilyMembers();
      return FamilyState.hasFamily(
        family: context.family,
        currentMember: context.currentMember,
        members: members,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const FamilyState.noFamily();
      }
      return FamilyState.noFamily(errorMessage: _messageFromError(error));
    }
  }

  Future<bool> _submitWithContext({
    required Future<CurrentFamilyContext> Function() action,
    required String successMessage,
  }) async {
    return _submit(
      action: () async {
        final context = await action();
        final members =
            await ref.read(familyRepositoryProvider).getCurrentFamilyMembers();
        state = AsyncData(
          FamilyState.hasFamily(
            family: context.family,
            currentMember: context.currentMember,
            members: members,
            successMessage: successMessage,
          ),
        );
      },
    );
  }

  Future<bool> _mutateAndReload(
    Future<void> Function() action,
    String successMessage,
  ) async {
    return _submit(
      action: () async {
        await action();
        final next = await _loadCurrentFamily();
        state = AsyncData(
          next.copyWith(successMessage: successMessage, clearMessages: true),
        );
      },
    );
  }

  Future<bool> _mutateAndKeepContext(
    Future<void> Function() action,
    String successMessage,
  ) async {
    return _submit(
      action: () async {
        await action();
        final current = state.valueOrNull;
        if (current == null) {
          return;
        }
        state = AsyncData(
          current.copyWith(
            isSubmitting: false,
            successMessage: successMessage,
            clearMessages: true,
          ),
        );
      },
    );
  }

  Future<bool> _submit({
    required Future<void> Function() action,
  }) async {
    final current = state.valueOrNull ?? const FamilyState.noFamily();
    state = AsyncData(
      current.copyWith(isSubmitting: true, clearMessages: true),
    );
    try {
      await action();
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

  String _extractInviteCode(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    final codeFromQuery = uri?.queryParameters['code'];
    if (codeFromQuery != null && codeFromQuery.isNotEmpty) {
      return codeFromQuery;
    }
    return trimmed;
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
