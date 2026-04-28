import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../family_setup/application/family_controller.dart';
import '../data/notifications_repository.dart';
import '../domain/notification.dart';

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.readingIds = const {},
    this.errorMessage,
  });

  final List<AppNotification> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final Set<String> readingIds;
  final String? errorMessage;

  int get unreadCount => items.where((item) => !item.isRead).length;

  NotificationsState copyWith({
    List<AppNotification>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    Set<String>? readingIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      nextCursor: nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      readingIds: readingIds ?? this.readingIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationsController extends AsyncNotifier<NotificationsState> {
  @override
  Future<NotificationsState> build() async {
    final familyState = await ref.watch(familyControllerProvider.future);
    if (!familyState.hasFamily) {
      return const NotificationsState();
    }
    return _load();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .listNotifications(cursor: current.nextCursor);
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

  Future<void> markAsRead(String notificationId) async {
    final current = state.valueOrNull;
    if (current == null || current.readingIds.contains(notificationId)) {
      return;
    }

    final index = current.items.indexWhere((item) => item.id == notificationId);
    if (index == -1 || current.items[index].isRead) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        readingIds: {...current.readingIds, notificationId},
        clearError: true,
      ),
    );

    try {
      final readNotification = await ref
          .read(notificationsRepositoryProvider)
          .markAsRead(notificationId);
      final latest = state.valueOrNull ?? current;
      final readAt = readNotification?.readAt ?? DateTime.now().toUtc();
      state = AsyncData(
        latest.copyWith(
          items: latest.items
              .map(
                (item) => item.id == notificationId
                    ? (readNotification ?? item.copyWith(readAt: readAt))
                    : item,
              )
              .toList(),
          readingIds: latest.readingIds.difference({notificationId}),
          clearError: true,
        ),
      );
    } catch (error) {
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(
          readingIds: latest.readingIds.difference({notificationId}),
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  Future<NotificationsState> _load() async {
    final page =
        await ref.read(notificationsRepositoryProvider).listNotifications();
    return NotificationsState(
      items: page.items,
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
        if (message is List && message.isNotEmpty) {
          return message.join(', ');
        }
      }
      return error.message ?? 'Request failed';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
