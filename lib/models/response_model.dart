class ResponseModel<T> {
  final bool success;
  final T? data;
  final String? message;

  ResponseModel({required this.success, this.data, this.message});
}
