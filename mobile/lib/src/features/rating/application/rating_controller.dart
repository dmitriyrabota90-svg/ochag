import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../data/rating_repository.dart';
import '../domain/rating.dart';

final ratingControllerProvider =
    AsyncNotifierProvider<RatingController, RatingState>(
  RatingController.new,
);

class RatingState {
  const RatingState({
    this.period = AnalyticsPeriod.week,
    this.rating,
    this.summary,
    this.errorMessage,
  });

  final AnalyticsPeriod period;
  final RatingResult? rating;
  final AnalyticsSummary? summary;
  final String? errorMessage;

  RatingState copyWith({
    AnalyticsPeriod? period,
    RatingResult? rating,
    AnalyticsSummary? summary,
    String? errorMessage,
  }) {
    return RatingState(
      period: period ?? this.period,
      rating: rating ?? this.rating,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }
}

class RatingController extends AsyncNotifier<RatingState> {
  @override
  Future<RatingState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const RatingState();
    }
    return _load(AnalyticsPeriod.week);
  }

  Future<void> setPeriod(AnalyticsPeriod period) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(period));
  }

  Future<void> reload() async {
    final period = state.valueOrNull?.period ?? AnalyticsPeriod.week;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(period));
  }

  Future<RatingState> _load(AnalyticsPeriod period) async {
    try {
      final repository = ref.read(ratingRepositoryProvider);
      final rating = await repository.getRating(period);
      final summary = await repository.getSummary(period);
      return RatingState(period: period, rating: rating, summary: summary);
    } catch (error) {
      return RatingState(
          period: period, errorMessage: _messageFromError(error));
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
      }
      return error.message ?? 'Request failed';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
