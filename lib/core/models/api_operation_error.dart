class ApiOperationResponse {
  final bool status;
  final String message;

  ApiOperationResponse({required this.status, required this.message});

  factory ApiOperationResponse.error(String message) {
    return ApiOperationResponse(status: false, message: message);
  }
}
