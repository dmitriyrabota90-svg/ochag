import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../data/history_repository.dart';
import '../domain/history.dart';

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, HistoryState>(
  HistoryController.new,
);

class HistoryState {
  const HistoryState({
    this.items = const [],
    this.entityType,
    this.eventType,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<HistoryEvent> items;
  final HistoryEntityType? entityType;
  final String? eventType;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  HistoryState copyWith({
    List<HistoryEvent>? items,
    HistoryEntityType? entityType,
    String? eventType,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearEntityType = false,
    bool clearEventType = false,
    bool clearError = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      entityType: clearEntityType ? null : entityType ?? this.entityType,
      eventType: clearEventType ? null : eventType ?? this.eventType,
      nextCursor: nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class HistoryController extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const HistoryState();
    }
    return _load();
  }

  Future<void> reload() async {
    final current = state.valueOrNull ?? const HistoryState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(
        entityType: current.entityType,
        eventType: current.eventType,
      ),
    );
  }

  Future<void> setEntityType(HistoryEntityType? entityType) async {
    final current = state.valueOrNull ?? const HistoryState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(
        entityType: entityType,
        eventType: current.eventType,
      ),
    );
  }

  Future<void> setEventType(String? eventType) async {
    final current = state.valueOrNull ?? const HistoryState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(
        entityType: current.entityType,
        eventType: eventType?.trim().isEmpty == true ? null : eventType,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await ref.read(historyRepositoryProvider).listHistory(
            entityType: current.entityType,
            eventType: current.eventType,
            cursor: current.nextCursor,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextCursor: page.pageInfo.nextCursor,
          hasMore: page.pageInfo.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  Future<HistoryState> _load({
    HistoryEntityType? entityType,
    String? eventType,
  }) async {
    final page = await ref.read(historyRepositoryProvider).listHistory(
          entityType: entityType,
          eventType: eventType,
        );
    return HistoryState(
      items: page.items,
      entityType: entityType,
      eventType: eventType,
      nextCursor: page.pageInfo.nextCursor,
      hasMore: page.pageInfo.hasMore,
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
      }
      return error.message ?? 'Request failed';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
