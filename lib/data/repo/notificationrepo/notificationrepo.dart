import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/notification/markedasreadmodels.dart';
import 'package:firstedu/data/models/api_models/notification/notification_models.dart';

class NotificationRepo {
  final ApiClient _apiClient;

  NotificationRepo(this._apiClient);

  Future<NotificationModels> getNotifications() async {
    try {
      final res = await _apiClient.get(
        "${ApiEndpoint.appBaseUrl}/notifications",
      );

      if (res.data == null) {
        throw AppException("Empty response from server");
      }

      if (res.data is! Map<String, dynamic>) {
        throw AppException("Invalid response format");
      }

      return NotificationModels.fromJson(res.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException("Failed to fetch notifications: ${e.toString()}");
    }
  }
  Future<MarkedasReadModels> markAllAsRead() async {
  try {
    final res = await _apiClient.put(
      "${ApiEndpoint.appBaseUrl}/notifications/read-all",
    );

    if (res.data == null) {
      throw AppException("Empty response from server");
    }

    return MarkedasReadModels.fromJson(res.data);

  } on AppException {
    rethrow;
  } catch (e) {
    throw AppException("Failed to mark all as read: ${e.toString()}");
  }
}
}