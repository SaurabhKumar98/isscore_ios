import 'package:dio/dio.dart';
import 'package:firstedu/core/error/api_exception.dart';
import 'package:firstedu/core/localstorage/localstorage.dart';
import 'package:firstedu/core/navigatorkey/navigatorkey.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';

class ApiClient {
  late final Dio _dio;
  String? _accessToken;
  bool _isLoggingOut = false;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        validateStatus: (status) {
          return status != null && status >= 200 && status < 600;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ Use memory token first, fallback to SharedPreferences
          String? token = _accessToken;
          if (token == null || token.isEmpty) {
            token = await UserLocalStorage.getAccessToken();
            // ✅ Cache it in memory for next time
            if (token != null && token.isNotEmpty) {
              _accessToken = token;
            }
          }

          options.headers.addAll({
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          });

          debugPrint('➡️ ${options.method} ${options.uri}');
          debugPrint('HEADERS → ${options.headers}');
          debugPrint('BODY → ${options.data}');

          handler.next(options);
        },
        onResponse: (response, handler) async {
          debugPrint(
              '✅ ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('RESPONSE → ${response.data}');

          if (response.statusCode == 401 && !_isLoggingOut) {
            _isLoggingOut = true;

            final message = response.data?['message'] ??
                'Session expired. Please login again.';

            await UserLocalStorage.clearUser();
            clearToken();

            AppToast.errorGlobal(title: "Session Expired", message: message);

            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AppRoutesName.login,
              (route) => false,
            );
          }

          handler.next(response);
        },
      ),
    );
  }

  void setAccessToken(String? token) {
    _accessToken = token;
    _isLoggingOut = false; // ✅ Reset logout flag on new login
  }

  void clearToken() {
    _accessToken = null;
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode! >= 500) {
        throw ApiException.fromResponse(response);
      }

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
    String url, {
    dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: isMultipart
              ? {'Content-Type': 'multipart/form-data'}
              : {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode! >= 500) {
        throw ApiException.fromResponse(response);
      }

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
    String url, {
    dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(
          headers: isMultipart
              ? {'Content-Type': 'multipart/form-data'}
              : {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode! >= 500) {
        throw ApiException.fromResponse(response);
      }

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> patch(
    String url, {
    dynamic data,
    bool isMultipart = false,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        options: Options(
          headers: isMultipart
              ? {'Content-Type': 'multipart/form-data'}
              : {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode! >= 500) {
        throw ApiException.fromResponse(response);
      }

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(String url, {dynamic data}) async {
    try {
      final response = await _dio.delete(url, data: data);
      if (response.statusCode! >= 500) {
        throw ApiException.fromResponse(response);
      }

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}