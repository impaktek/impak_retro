
// ignore_for_file: overridden_field
import 'impak_retro_exceptions.dart';

/// A sealed base class representing a generic response.
///
/// This class serves as the foundation for all response types in the application.
/// It encapsulates the response data, error details, and HTTP status code.
///
/// [T] is the type of data returned in the response.
sealed class ImpakRetroResponse<T> {
  /// The data returned in the response, if available.
  final T? success;

  /// The error details associated with the response, if any.
  final dynamic failure;

  /// The HTTP status code of the response, if applicable.
  int? statusCode;

  /// Creates an [ImpakRetroResponse] with the given [statusCode], [data], and [error].
  ///
  /// - [statusCode] is required.
  /// - [data] and [error] are optional.
  ImpakRetroResponse({
    required this.statusCode,
    this.success,
    this.failure,
  });

  /// Returns `true` if the response is successful and contains data.
  bool get isSuccessful => success != null;

  T get asBody => success!;

  dynamic get asError => failure;

  @override
  String toString() {
    return 'ImpakRetroResponse(statusCode: $statusCode, exception: $success)';
  }
}

/// A specific implementation of [ImpakRetroResponse] for dynamic data.
///
/// This class is useful for generic operations where the type of data
/// is not known at compile time.
class ImpakResponse extends ImpakRetroResponse<dynamic> {
  final dynamic data;
  final dynamic error;
  /// Creates an [ImpakResponse] with the given [statusCode], [data], and [error].
  ImpakResponse({required super.statusCode, this.data, this.error}): super(success: data, failure: error);

  @override
  String toString() {
    return 'ImpakResponse(statusCode: $statusCode, exception: $data, error: $error)';
  }

}

/// Represents a successful response with typed data.
///
/// [T] is the type of data returned in the response.
class ImpakRetroSuccess<T> extends ImpakRetroResponse<T> {
  /// The data returned in the successful response.
  /// // ignore: overridden_field
  final T data;

  /// Creates an [ImpakRetroSuccess] with the given [statusCode] and [data].
  ///
  /// - [statusCode] is required.
  /// - [data] is required and represents the successful result.
  ImpakRetroSuccess({
    required super.statusCode,
    required this.data,
  }) : super(success: data);

  @override
  String toString() {
    return 'ImpakRetroSuccess(statusCode: $statusCode, exception: $data)';
  }
}

/// Represents a response that indicates a failure without a valid result.
///
/// This class is useful for scenarios where an operation fails but does not throw an exception.
class ImpakRetroFailure extends ImpakRetroResponse<Never> {
  /// The error details associated with the failure.
  final dynamic error;

  /// Creates an [ImpakRetroFailure] with the given [statusCode] and [error].
  ///
  /// - [statusCode] is required.
  /// - [error] is required and describes the failure.
  ImpakRetroFailure({
    required super.statusCode,
    required this.error,
  });
  @override
  String toString() {
    return 'ImpakRetroFailure(statusCode: $statusCode, exception: $error)';
  }
}

/// Represents a response that encapsulates an exception.
///
/// This class is useful for scenarios where a specific [ImpakRetroException]
/// provides more context about the error.
class ImpakdioError extends ImpakRetroResponse<Never> {
  /// The exception associated with the error.
  final ImpakRetroException exception;


  /// Creates an [ImpakdioError] with the given [statusCode] and [exception].
  ///
  /// - [statusCode] is required.
  /// - [exception] is required and provides details about the error.
  ImpakdioError({
    required super.statusCode,
    required this.exception,
  });

  @override
  String toString() {
    return 'ImpakdioError(statusCode: $statusCode, exception: $exception)';
  }
}
