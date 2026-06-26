import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/dashboardmodels/dashboard_models.dart';
import 'package:flutter/material.dart';

class DashBoardRepo {
  final ApiClient _apiClient;

  DashBoardRepo(this._apiClient);

  Future<StudentDashboardModel> getDashBoard() async {
    try {
      final res = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/dashboard/stats',
      );

      if (res.data == null) {
        throw AppException('Empty response from server');
      }


      return StudentDashboardModel.fromJson(res.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException('Failed to fetch dashboard data: $e');
    }
  }
}
