part of '../impak_retro.dart';

/// A configuration class that encapsulates various HTTP request settings
/// and manages communication with the Dio client for making network calls.
/// It provides utilities for setting request options, handling cancellations,
/// and setting up HTTP headers and timeouts for requests.
class _ImpakRetroConfig {
  // The Dio instance used for making HTTP requests.
  final Dio _dio;

  /// Constructor to initialize the ImpakRetroConfig with a Dio instance.
  /// The Dio instance is passed into the constructor to perform the actual
  /// HTTP requests with the configured settings.
  _ImpakRetroConfig(this._dio);

  /// Sets up request options for a network call, including method, headers,
  /// timeouts, and more. This method is used internally to configure a request
  /// before sending it via Dio.
  ///
  /// [T] is the expected response type.
  /// [baseUrl] is the base URL for the request.
  /// [path] is the path to append to the base URL.
  /// [method] is the HTTP method for the request (e.g., GET, POST).
  /// [onProgress] is an optional callback for tracking the request progress.
  /// [receiveTimeout] and [sendTimeout] define timeouts for receiving and
  /// sending data, respectively.
  /// [canceller] is an optional instance to manage cancellation of the request.
  /// [timeUnit] defines the unit of time used for timeouts (e.g., seconds or milliseconds).
  /// [authorizationToken] is an optional authorization header for the request.
  /// [body] contains the body of the request, typically for POST, PUT, or PATCH.
  /// [headers] are optional additional headers for the request.
  /// [queryParameters] contains any query parameters to be appended to the URL.
  /// [formData] is optional, used when sending form-data in a multipart request.
  RequestOptions _setStreamType<T>({
    required String baseUrl,
    required String path,
    required RequestMethod method,
    void Function(int, int)? onProgress,
    int? receiveTimeout,
    int? sendTimeout,
    Canceller? canceller,
    TimeUnit timeUnit = TimeUnit.SECONDS,
    String? authorizationToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    FormData? formData,
  }) {
    final extra = <String, dynamic>{};
    final params = queryParameters ?? <String, dynamic>{};
    params.removeWhere((k, v) => v == null);

    final header = <String, dynamic>{r'Authorization': authorizationToken};
    header.removeWhere((k, v) => v == null);
    if (headers != null) {
      header.addAll(headers);
    }

    final requestOptions = Options(
        method: _methodConverter(method),
        receiveTimeout: _getDuration(receiveTimeout, timeUnit),
        sendTimeout: _getDuration(sendTimeout, timeUnit),
        headers: header,
        extra: extra,
        contentType: formData != null ? 'multipart/form-data' : null)
        .compose(
        _dio.options,
        queryParameters: params,
        path,
        data: body ?? formData,
        onSendProgress: onProgress,
        cancelToken: canceller?.cancelToken)
        .copyWith(baseUrl: baseUrl);

    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  /// Combines the base URL provided by Dio and the base URL given in the request.
  /// This method ensures that relative URLs are resolved against the Dio base URL.
  /// If the `baseUrl` is null or empty, it returns the Dio's base URL.
  ///
  /// [dioBaseUrl] is the base URL from the Dio configuration.
  /// [baseUrl] is the base URL passed into the request method.
  /// Returns the fully combined base URL or null if neither is provided.
  String? combineBaseUrls(String? dioBaseUrl, String? baseUrl) {
    if (dioBaseUrl == null && baseUrl == null) {
      return null;
    }
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl!).resolveUri(url).toString();
  }

  /// Converts the `RequestMethod` enum to its string equivalent (e.g., GET -> 'GET').
  /// This method is used internally to convert the `RequestMethod` to a format
  /// that Dio understands.
  ///
  /// [method] is the `RequestMethod` enum that needs to be converted.
  /// Returns the corresponding string representation of the HTTP method.
  String _methodConverter(RequestMethod method) {
    switch (method) {
      case RequestMethod.POST:
        return 'POST';
      case RequestMethod.GET:
        return 'GET';
      case RequestMethod.PUT:
        return 'PUT';
      case RequestMethod.PATCH:
        return 'PATCH';
      case RequestMethod.DELETE:
        return 'DELETE';
    }
  }

  /// Converts a time value (in seconds or milliseconds) into a `Duration`.
  /// This is used to set the timeout for network requests based on the unit
  /// of time provided (seconds or milliseconds).
  ///
  /// [value] is the time value.
  /// [timeUnit] is the unit of time (either seconds or milliseconds).
  /// Returns the corresponding `Duration`.
  Duration? _getDuration(int? value, TimeUnit timeUnit) {
    if (value == null) {
      return null;
    }
    switch (timeUnit) {
      case TimeUnit.SECONDS:
        return Duration(seconds: value);
      case TimeUnit.MILLISECONDS:
        return Duration(milliseconds: value);
    }
  }

  /// Makes an HTTP request with the provided settings and options.
  /// This method uses the configured Dio instance and the request options
  /// to perform the actual HTTP call.
  ///
  /// [baseUrl] is the base URL for the request.
  /// [path] is the path for the request.
  /// [method] is the HTTP method to use (GET, POST, etc.).
  /// Other parameters are similar to those in `_setStreamType`.
  /// Returns a `Response` containing the response data.
  Future<Response<dynamic>> call<T>({
    required String baseUrl,
    required String path,
    required RequestMethod method,
    void Function(int, int)? onProgress,
    int? receiveTimeout,
    int? sendTimeout,
    Canceller? canceller,
    TimeUnit timeUnit = TimeUnit.SECONDS,
    String? authorizationToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final requestOptions = _setStreamType<T>(
      baseUrl: baseUrl,
      path: path,
      method: method,
      onProgress: onProgress,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      canceller: canceller,
      timeUnit: timeUnit,
      authorizationToken: authorizationToken,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
    );

    final response = await _dio.fetch(requestOptions);
    return response;
  }

  /// Makes an HTTP request that includes form data. This method is typically used
  /// for making `multipart/form-data` requests, such as file uploads.
  ///
  /// [formData] contains the data to be uploaded.
  /// Other parameters are similar to those in `_setStreamType`.
  /// Returns the response data from the server.
  Future<Response<dynamic>> formDataCall<T>({
    required String baseUrl,
    required String path,
    required RequestMethod method,
    required FormData formData,
    Function(int, int)? onProgress,
    int? receiveTimeout,
    int? sendTimeout,
    Canceller? canceller,
    TimeUnit timeUnit = TimeUnit.SECONDS,
    String? authorizationToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final requestOptions = _setStreamType<T>(
      baseUrl: baseUrl,
      path: path,
      method: method,
      formData: formData,
      onProgress: onProgress,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      canceller: canceller,
      timeUnit: timeUnit,
      authorizationToken: authorizationToken,
      headers: headers,
      queryParameters: queryParameters,
    );

    final response = await _dio.fetch(requestOptions);
    return response.data;
  }
}
