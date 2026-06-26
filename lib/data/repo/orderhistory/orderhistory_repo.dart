import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/orderhistorymodels/orderhistory_models.dart';
import 'package:flutter/material.dart';

class OrderhistoryRepo {
  final ApiClient _apiClient;

  OrderhistoryRepo(this._apiClient);

  Future<OrderHistoryModels> getOrderHistory({
    int page = 1,
    int limit = 10,
    // Comma-separated type string, e.g. "course,test" — null means All
    String? type,
    // Category ObjectId filter — null means no filter
    String? categoryId,
    // ISO date strings YYYY-MM-DD
    String? from,
    String? to,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (type != null) queryParams['type'] = type;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final response = await _apiClient.get(
        '${ApiEndpoint.appBaseUrl}/orders',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException("No order history data found");
      }

      return OrderHistoryModels.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on AppException {
      rethrow;
    } catch (e, st) {
      debugPrint('OrderHistory parse error: $e\n$st');
      throw AppException("Failed to load order history data");
    }
  }
}