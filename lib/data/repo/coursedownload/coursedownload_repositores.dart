import 'package:firstedu/core/error/app_exception.dart';
import 'package:firstedu/core/network/api_client.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/competetive/applycoupanmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursedetailsbyidmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursedownloadallmodels.dart';
import 'package:firstedu/data/models/api_models/coursedownload/coursepaymentmodels.dart';
import 'package:firstedu/data/models/api_models/resourcestore/Categorymodels.dart';
import 'package:flutter/foundation.dart';


class CourseDownloadRepository {
  final ApiClient _apiClient;

  CourseDownloadRepository(this._apiClient);


  Future<DownloadCourseResponse> getAllCourseDownloads({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get(
        ApiEndpoint.courseDownloads,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AppException(
          "Server returned an empty response. Please try again.",
        );
      }

      final model = DownloadCourseResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(
          model.message?.isNotEmpty == true
              ? model.message!
              : "Failed to load course downloads. Please try again.",
        );
      }

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong. Please try again.");
    }
  }


  Future<CourseDetailsModel> getCourseDetails(String courseId) async {
    try {
      debugPrint("🔄 Fetching course details for ID: $courseId");
      
      final response = await _apiClient.get(
        '${ApiEndpoint.courseDownloads}/$courseId',
      );

      if (response.data == null) {
        debugPrint("❌ Empty response from server");
        throw AppException("Empty response from server");
      }

      debugPrint("✅ Response received: ${response.data}");

      if (response.data is! Map<String, dynamic>) {
        debugPrint("❌ Invalid response type: ${response.data.runtimeType}");
        throw AppException("Invalid response format from server");
      }

      final model = CourseDetailsModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      debugPrint("✅ Model parsed successfully");
      debugPrint("   Success: ${model.success}");
      debugPrint("   Message: ${model.message}");
      debugPrint("   Data present: ${model.data != null}");
      debugPrint("   Modules count: ${model.data?.modules.length ?? 0}");

      if (!model.success) {
        debugPrint("❌ API returned success=false: ${model.message}");
        throw AppException(model.message.isNotEmpty ? model.message : "Failed to load course details");
      }

      return model;
    } on AppException catch (e) {
      debugPrint("❌ AppException: ${e.message}");
      rethrow;
    } on FormatException catch (e) {
      debugPrint("❌ FormatException (JSON parsing): $e");
      throw AppException("Invalid data format. Please try again.");
    } catch (e, stackTrace) {
      debugPrint("❌ Unexpected error: $e");
      debugPrint("Stack trace: $stackTrace");
      throw AppException("Something went wrong: ${e.toString()}");
    }
  }


  Future<DownloadCourseResponse> getCourseDownloads({
    String? type,
    String? access,
    bool? isCertification,
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (isCertification != null) 'isCertification': isCertification,
        if (type != null) 'type': type.toLowerCase(),
        if (access != null && access != 'both') 'access': access,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await _apiClient.get(
        ApiEndpoint.courseDownloads,
        queryParameters: queryParams,
      );

      if (response.data == null) throw AppException("Empty response from server");

      final model = DownloadCourseResponse.fromJson(response.data as Map<String, dynamic>);

      if (!model.success) throw AppException(model.message ?? "Failed to load courses");

      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Something went wrong");
    }
  }


  Future<CategoryResponse> getCourseCategories({
    bool? isCertification,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.categories,
        queryParameters: {
          'linkedTo': 'course',
          if (isCertification != null) 'isCertification': isCertification,
        },
      );

      if (response.data == null) throw AppException("Empty response.");

      final model = CategoryResponse.fromJson(response.data as Map<String, dynamic>);
      if (!model.success) throw AppException(model.message);
      return model;
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException("Failed to load categories.");
    }
  }


  Future<CourseInitiatePaymentResponse> initiatePayment({
    required String courseId,
    required CoursePaymentMethod method,
    String? couponCode,
  }) async {
    try {
      final body = CourseInitiatePaymentRequest(
        paymentMethod: method.value,
        couponCode: couponCode,
      ).toJson();

      final response = await _apiClient.post(
        '${ApiEndpoint.courseDownloads}/$courseId/initiate-payment',
        data: body,
      );

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = CourseInitiatePaymentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(model.message ?? "Failed to initiate payment");
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException("Something went wrong");
    }
  }


  Future<CoursePurchaseResponse> completePurchase({
    required String courseId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final body = CoursePurchaseRequest(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      ).toJson();

      final response = await _apiClient.post(
        '${ApiEndpoint.courseDownloads}/$courseId/purchase',
        data: body,
      );

      if (response.data == null) {
        throw AppException("Empty response from server");
      }

      final model = CoursePurchaseResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!model.success) {
        throw AppException(model.message ?? "Purchase failed");
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException("Something went wrong");
    }
  }

  // Add to CourseDownloadRepository:

Future<ApplyCouponModels> applyCoupon({
  required String code,
  required int amount,
  required String module,
}) async {
  try {
    final response = await _apiClient.post(
      '${ApiEndpoint.appBaseUrl}/coupons/apply',
      data: {
        'code': code.trim().toUpperCase(),
        'amount': amount,
        'module': module,
      },
    );

    if (response.data == null) {
      throw AppException('Empty response from server.');
    }

    final model = ApplyCouponModels.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (model.success != true) {
      throw AppException(
        (model.message?.isNotEmpty ?? false)
            ? model.message!
            : 'Invalid coupon code.',
      );
    }

    return model;
  } on AppException {
    rethrow;
  } catch (_) {
    throw AppException('Failed to apply coupon. Please try again.');
  }
}
}