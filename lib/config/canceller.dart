import 'package:dio/dio.dart';

/// A class that helps manage the cancellation of asynchronous operations,
/// particularly network requests made using the Dio package.
///
/// This class leverages the `CancelToken` from Dio to manage cancellation
/// states, allowing operations such as HTTP requests to be cancelled when
/// needed. It is useful in scenarios where multiple requests are in progress
/// and you need to cancel certain operations, for example, when the user
/// navigates away from a screen or when you want to stop an unnecessary
/// request from completing.
class Canceller {
  /// A private instance of `CancelToken`, which is used to track and
  /// manage the cancellation of an operation (e.g., a network request).
  ///
  /// This token is passed to Dio requests to allow them to be canceled
  /// if the user decides to stop or interrupt the request before completion.
  late final CancelToken _cancelToken;

  /// Constructor that initializes the `CancelToken` instance.
  ///
  /// When the `Canceller` class is instantiated, it creates a new
  /// `CancelToken` to be used for cancellation. The `CancelToken` is
  /// responsible for managing the cancellation process of a Dio request.
  ///
  /// Example usage:
  /// ```dart
  /// final canceller = Canceller();
  /// ```
  Canceller() {
    _cancelToken = CancelToken();
  }

  /// Cancels the ongoing operation associated with the `_cancelToken`.
  ///
  /// This method triggers the cancellation of the request or task
  /// associated with the `CancelToken`. It is commonly used when the
  /// user wants to abort a request, for example, when they navigate
  /// away from a screen or if an operation is no longer required.
  ///
  /// Example usage:
  /// ```dart
  /// canceller.cancel();
  /// ```
  void cancel() {
    _cancelToken.cancel();
  }

  /// A getter that allows access to the current `_cancelToken`.
  ///
  /// This getter provides the `CancelToken` instance, which can be
  /// passed to Dio requests or used for checking the cancellation state
  /// of a particular operation.
  ///
  /// Example usage:
  /// ```dart
  /// final token = canceller.cancelToken;
  /// dio.get('https://example.com', cancelToken: token);
  /// ```
  CancelToken get cancelToken => _cancelToken;
}
