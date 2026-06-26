import 'package:dio/dio.dart';
import 'package:firstedu/core/error/app_exception.dart';

class ApiException extends AppException {
  ApiException(
    super.message, {
    super.statusCode,
  });

  factory ApiException.fromResponse(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

    String message = 'Something went wrong';

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null) {
        message = data['message'].toString();
      } else if (data.containsKey('error') && data['error'] != null) {
        message = data['error'].toString();
      }
    }

    return ApiException(
      message,
      statusCode: statusCode,
    );
  }
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException("Connection timeout. Please try again.");

      case DioExceptionType.sendTimeout:
        return ApiException("Request timeout. Please try again.");

      case DioExceptionType.receiveTimeout:
        return ApiException("Server response timeout.");

      case DioExceptionType.cancel:
        return ApiException("Request was cancelled.");

      case DioExceptionType.unknown:
      default:
        return ApiException(
          "No internet connection. Please check your network.",
        );
    }
  }
}
