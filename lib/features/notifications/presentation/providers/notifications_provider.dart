import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/notification_item.dart';
import '../../../../shared/providers/mock_providers.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  FutureOr<List<NotificationItem>> build() async {
    return ref.watch(notificationsRepositoryProvider).fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(notificationsRepositoryProvider).fetchNotifications();
    });
  }

  Future<void> markAsRead(String id) async {
    final currentList = state.value;
    if (currentList == null) return;

    // Optimistic Update
    final updatedList = currentList.map((item) {
      if (item.id == id) {
        return NotificationItem(
          id: item.id,
          userId: item.userId,
          title: item.title,
          body: item.body,
          isRead: true,
          createdAt: item.createdAt,
          data: item.data,
        );
      }
      return item;
    }).toList();

    state = AsyncValue.data(updatedList);

    try {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
    } catch (e) {
      // Revert/refresh on error
      ref.invalidateSelf();
    }
  }

  Future<void> markAllAsRead() async {
    final currentList = state.value;
    if (currentList == null) return;

    // Optimistic Update
    final updatedList = currentList.map((item) {
      return NotificationItem(
        id: item.id,
        userId: item.userId,
        title: item.title,
        body: item.body,
        isRead: true,
        createdAt: item.createdAt,
        data: item.data,
      );
    }).toList();

    state = AsyncValue.data(updatedList);

    try {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
    } catch (e) {
      // Revert/refresh on error
      ref.invalidateSelf();
    }
  }
}

final notificationsProvider = AsyncNotifierProvider.autoDispose<NotificationsNotifier, List<NotificationItem>>(() {
  return NotificationsNotifier();
});
