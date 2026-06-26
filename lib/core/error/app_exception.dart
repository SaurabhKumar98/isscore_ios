class   AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? sessionId;

  AppException(
    this.message, {
    this.statusCode,
    this.sessionId
  });

  @override
  String toString() => message;
}
