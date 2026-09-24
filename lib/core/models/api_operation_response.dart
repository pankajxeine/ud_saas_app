class ApiOperationResponse<T> {
  final bool status;
  final String message;
  final T? body;

  ApiOperationResponse({
    required this.status,
    required this.message,
    this.body,
  });

  factory ApiOperationResponse.success(T? body, {String message = 'Success'}) {
    return ApiOperationResponse(status: true, message: message, body: body);
  }

  factory ApiOperationResponse.error(String message) {
    return ApiOperationResponse(status: false, message: message, body: null);
  }
}
