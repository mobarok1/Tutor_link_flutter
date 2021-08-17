class ApiResponse<T> {
  T response;
  bool responseError;
  String errorMessage;
  int responseCode;

  ApiResponse(
      {this.response,
      this.errorMessage,
      this.responseError,
      this.responseCode});
}
