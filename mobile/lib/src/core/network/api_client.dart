import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

final unauthenticatedDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
});

final authRefreshCoordinatorProvider = Provider<AuthRefreshCoordinator>((ref) {
  return AuthRefreshCoordinator(
    dio: ref.watch(unauthenticatedDioProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final refreshCoordinator = ref.watch(authRefreshCoordinatorProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra['skipAuthRefresh'] == true) {
          handler.next(options);
          return;
        }
        final token = await storage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final requestOptions = error.requestOptions;
        final shouldRefresh = error.response?.statusCode == 401 &&
            requestOptions.extra['skipAuthRefresh'] != true &&
            requestOptions.extra['retriedAfterRefresh'] != true &&
            !_isAuthEndpoint(requestOptions.path);

        if (!shouldRefresh) {
          handler.next(error);
          return;
        }

        final token = await refreshCoordinator.refreshAccessToken();
        if (token == null || token.isEmpty) {
          handler.next(error);
          return;
        }

        requestOptions.headers['Authorization'] = 'Bearer $token';
        requestOptions.extra['retriedAfterRefresh'] = true;

        try {
          final response = await dio.fetch<dynamic>(requestOptions);
          handler.resolve(response);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuthRefresh = false,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(extra: {'skipAuthRefresh': skipAuthRefresh}),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuthRefresh = false,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'skipAuthRefresh': skipAuthRefresh}),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuthRefresh = false,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'skipAuthRefresh': skipAuthRefresh}),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuthRefresh = false,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'skipAuthRefresh': skipAuthRefresh}),
    );
  }
}

class AuthRefreshCoordinator {
  AuthRefreshCoordinator({
    required Dio dio,
    required SecureStorageService storage,
  })  : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;
  Future<String?>? _refreshInFlight;

  Future<String?> refreshAccessToken() {
    _refreshInFlight ??= _refreshAccessToken();
    return _refreshInFlight!.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data == null) {
        await _storage.clearTokens();
        return null;
      }

      final accessToken = data['accessToken'] as String?;
      final nextRefreshToken = data['refreshToken'] as String?;
      if (accessToken == null ||
          accessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty) {
        await _storage.clearTokens();
        return null;
      }

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );

      return accessToken;
    } on DioException {
      await _storage.clearTokens();
      return null;
    }
  }
}

bool _isAuthEndpoint(String path) {
  return path.startsWith('/auth/login') ||
      path.startsWith('/auth/register') ||
      path.startsWith('/auth/refresh') ||
      path.startsWith('/auth/logout') ||
      path.startsWith('/auth/forgot-password') ||
      path.startsWith('/auth/reset-password');
}
