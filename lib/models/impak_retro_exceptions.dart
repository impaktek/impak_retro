/// A custom exception class to handle specific errors in the application.
///
/// This class implements the [Exception] interface and provides additional
/// information about the error through its type, message, and status code.
class ImpakRetroException {
  /// A user-defined message that describes the exception.
  final String? message;

  /// The type of exception, represented by the [ExceptionType] enum.
  final ExceptionType type;

  /// The HTTP status code associated with the exception, if applicable.
  final int? statusCode;

  /// Creates an [ImpakRetroException] with the specified [type], [message],
  /// and [statusCode].
  ///
  /// The [type] is required, while [message] and [statusCode] are optional.
  ImpakRetroException(this.type, {this.message, required this.statusCode});

  @override
  String toString() {
    return 'ImpakRetroException(type: $type, message: ${message ?? 'No message'}, statusCode: ${statusCode ?? 'N/A'})';
  }
}

/// Enum representing various types of exceptions that can occur in the application.
//ignore_for_file: constant_identifier_names
enum ExceptionType {
  /// Indicates a timeout error.
  TIMEOUT_ERROR,

  /// Indicates a bad request error, typically HTTP 400.
  BAD_REQUEST,

  /// Indicates a server error, typically HTTP 500 or similar.
  SERVER_ERROR,

  /// Indicates that the operation was cancelled.
  CANCELLED_ERROR,

  /// Indicates an unknown error.
  UNKNOWN_ERROR,

  /// Indicates a mapping or serialization error.
  MAPPING_ERROR,

  /// Indicates an authorization error, typically HTTP 401 or 403.
  AUTHORISATION_ERROR,

  /// Indicates a connection error, such as no internet connectivity.
  CONNECTION_ERROR,
}
