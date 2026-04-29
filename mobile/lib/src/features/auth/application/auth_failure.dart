import 'package:dio/dio.dart';

enum AuthRequest {
  login,
  register,
  forgotPassword,
  resetPassword,
  updateProfile,
}

enum AuthFailure {
  invalidRequest,
  invalidCredentials,
  emailAlreadyExists,
  notFound,
  resetLinkInvalid,
  conflict,
  server,
  network,
  generic,
}

AuthFailure authFailureFromError(
  Object error, {
  required AuthRequest request,
}) {
  if (error is! DioException) {
    return AuthFailure.generic;
  }

  if (_isNetworkFailure(error)) {
    return AuthFailure.network;
  }

  final statusCode = error.response?.statusCode ?? 0;
  return switch (statusCode) {
    400 => AuthFailure.invalidRequest,
    401 => AuthFailure.invalidCredentials,
    404 => request == AuthRequest.resetPassword
        ? AuthFailure.resetLinkInvalid
        : AuthFailure.notFound,
    409 => request == AuthRequest.register
        ? AuthFailure.emailAlreadyExists
        : AuthFailure.conflict,
    >= 500 => AuthFailure.server,
    _ => AuthFailure.generic,
  };
}

bool _isNetworkFailure(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.unknown =>
      error.response == null,
    _ => false,
  };
}
