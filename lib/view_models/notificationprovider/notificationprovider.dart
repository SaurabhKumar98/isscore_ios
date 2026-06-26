import 'package:flutter/material.dart';
import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/data/models/api_models/notification/notification_models.dart';
import 'package:firstedu/data/repo/notificationrepo/notificationrepo.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepo _repo;

  NotificationProvider(this._repo);

  // ── STATE ─────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  // ✅ UNREAD COUNT (IMPORTANT)
  int get unreadCount =>
      _notifications.where((n) => n.isRead == false).length;

  // ── FETCH NOTIFICATIONS ─────────────────────────────

  Future<void> fetchNotifications(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final res = await _repo.getNotifications();

      _notifications = res.data;

    } on AppException catch (e) {
      _error = e.message;

      if (context.mounted) {
        AppToast.error(context, title: "Error", message: e.message);
      }

    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        AppToast.error(
          context,
          title: "Error",
          message: "Something went wrong",
        );
      }

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsReadFromApi(BuildContext context) async {
  try {
    _isLoading = true;
    notifyListeners();

    final res = await _repo.markAllAsRead();

    // ✅ Update UI locally
    for (var n in _notifications) {
      n.isRead = true;
    }

    if (context.mounted) {
      AppToast.success(context, title: "Success", message: res.message);
    }

  } on AppException catch (e) {
    if (context.mounted) {
      AppToast.error(context, title: "Error", message: e.message);
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // ── MARK SINGLE AS READ ─────────────────────────────

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  // ── MARK ALL AS READ ─────────────────────────────

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // ── ADD NEW NOTIFICATION (OPTIONAL - REALTIME USE) ─────────────────────────

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  // ── RESET ─────────────────────────────────────────────

  void reset() {
    _isLoading = false;
    _error = null;
    _notifications = [];
    notifyListeners();
  }
}