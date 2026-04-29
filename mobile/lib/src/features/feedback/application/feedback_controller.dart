import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/feedback_repository.dart';
import '../domain/feedback_entry.dart';

final feedbackControllerProvider =
    AutoDisposeNotifierProvider<FeedbackController, FeedbackState>(
  FeedbackController.new,
);

class FeedbackState {
  const FeedbackState({
    this.isSubmitting = false,
    this.failure,
    this.submitted = false,
  });

  final bool isSubmitting;
  final FeedbackFailure? failure;
  final bool submitted;

  FeedbackState copyWith({
    bool? isSubmitting,
    FeedbackFailure? failure,
    bool clearFailure = false,
    bool? submitted,
  }) {
    return FeedbackState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : failure ?? this.failure,
      submitted: submitted ?? this.submitted,
    );
  }
}

enum FeedbackFailure {
  network,
  server,
  unknown,
}

class FeedbackController extends AutoDisposeNotifier<FeedbackState> {
  @override
  FeedbackState build() {
    return const FeedbackState();
  }

  Future<bool> submit({
    required FeedbackType type,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      state = const FeedbackState(failure: FeedbackFailure.unknown);
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitted: false,
      clearFailure: true,
    );

    try {
      await ref.read(feedbackRepositoryProvider).submitFeedback(
            FeedbackSubmission(type: type, text: trimmedText),
          );
      state = const FeedbackState(submitted: true);
      return true;
    } catch (error) {
      state = FeedbackState(failure: _failureFromError(error));
      return false;
    }
  }

  FeedbackFailure _failureFromError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return FeedbackFailure.network;
      }

      final statusCode = error.response?.statusCode ?? 0;
      if (statusCode >= 500) {
        return FeedbackFailure.server;
      }
    }

    return FeedbackFailure.unknown;
  }
}
