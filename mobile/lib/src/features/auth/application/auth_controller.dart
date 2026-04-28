import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

enum AuthStatus {
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  const AuthState.authenticated(AuthUser user)
      : this(
          status: AuthStatus.authenticated,
          user: user,
        );

  const AuthState.unauthenticated({
    bool isSubmitting = false,
    String? errorMessage,
    String? successMessage,
  }) : this(
          status: AuthStatus.unauthenticated,
          isSubmitting: isSubmitting,
          errorMessage: errorMessage,
          successMessage: successMessage,
        );

  final AuthStatus status;
  final AuthUser? user;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
    );
  }
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final user = await repository.restoreSession();
    if (user == null) {
      return const AuthState.unauthenticated();
    }

    return AuthState.authenticated(user);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _submit(
      action: () => ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          ),
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _submit(
      action: () => ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            displayName: displayName,
          ),
    );
  }

  Future<bool> forgotPassword(String email) async {
    state = AsyncData(
      const AuthState.unauthenticated(isSubmitting: true),
    );
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      state = const AsyncData(
        AuthState.unauthenticated(successMessage: 'password_reset_requested'),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        AuthState.unauthenticated(errorMessage: _messageFromError(error)),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    state = AsyncData(
      const AuthState.unauthenticated(isSubmitting: true),
    );
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            token: token,
            password: password,
          );
      state = const AsyncData(
        AuthState.unauthenticated(successMessage: 'password_reset_completed'),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        AuthState.unauthenticated(errorMessage: _messageFromError(error)),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = AsyncData(
      (state.valueOrNull ?? const AuthState.unauthenticated()).copyWith(
        isSubmitting: true,
        clearMessages: true,
      ),
    );
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.unauthenticated());
  }

  Future<bool> _submit({
    required Future<AuthUser> Function() action,
  }) async {
    state = AsyncData(
      (state.valueOrNull ?? const AuthState.unauthenticated()).copyWith(
        isSubmitting: true,
        clearMessages: true,
      ),
    );
    try {
      final user = await action();
      state = AsyncData(AuthState.authenticated(user));
      return true;
    } catch (error) {
      state = AsyncData(
        AuthState.unauthenticated(errorMessage: _messageFromError(error)),
      );
      return false;
    }
  }

  String _messageFromError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
