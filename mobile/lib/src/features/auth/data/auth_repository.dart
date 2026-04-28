import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/auth_user.dart';
import 'auth_dto.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email.trim(),
        'password': password,
      },
      skipAuthRefresh: true,
    );
    return _saveSession(response.data);
  }

  Future<AuthUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email.trim(),
        'password': password,
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
      },
      skipAuthRefresh: true,
    );
    return _saveSession(response.data);
  }

  Future<AuthUser?> restoreSession() async {
    final accessToken = await _storage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    try {
      return await me();
    } catch (_) {
      await _storage.clearTokens();
      return null;
    }
  }

  Future<AuthUser> me() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/me');
    return AuthUserDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      data: {'email': email.trim()},
      skipAuthRefresh: true,
    );
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/reset-password',
      data: {
        'token': token,
        'password': password,
      },
      skipAuthRefresh: true,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post<Map<String, dynamic>>(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          skipAuthRefresh: true,
        );
      }
    } catch (_) {
      // Local logout should still clear stale tokens when the server is absent.
    } finally {
      await _storage.clearTokens();
    }
  }

  Future<AuthUser> _saveSession(Map<String, dynamic>? data) async {
    final dto = AuthResponseDto.fromJson(_requireMap(data));
    await _storage.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
    return dto.user.toDomain();
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Empty server response');
    }
    return data;
  }
}
