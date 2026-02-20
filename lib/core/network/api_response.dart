class ApiResponse<T> {
  final T? data;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;

  ApiResponse.success(this.data) : errorMessage = null;
  ApiResponse.error(this.errorMessage) : data = null;
}
