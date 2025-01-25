library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:impak_retro/config/impak_retro_form_data.dart';
import 'impak.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';

part 'config/impak_retro_config.dart';

/// A class that handles HTTP requests using the Dio package with customizable configurations.
///
/// This class allows making HTTP requests (such as GET, POST, etc.) with or without authentication, supports file uploads,
/// and provides mechanisms for handling API errors and timeouts.
class ImpakRetro {
  /// Dio instance used to make HTTP requests.
  ///
  /// This instance is responsible for performing the HTTP operations like GET, POST, PUT, DELETE, etc.
  final Dio _dio = Dio();

  /// Holds the configuration for making API requests.
  ///
  /// This configuration includes base URL, timeouts, logging, and other settings for the Dio instance.
  _ImpakRetroConfig? _configInit;

  /// Getter for the configuration.
  ///
  /// Provides access to the current configuration settings for the Dio instance.
  _ImpakRetroConfig get _config => _configInit!;

  /// The base URL for all API requests.
  ///
  /// This URL is used as the foundation for API endpoints. It can be overridden by passing a different URL to individual requests.
  String? _baseUrl;

  /// Timeout duration for HTTP requests.
  ///
  /// This is the duration (in seconds) that the Dio instance will wait for a response before throwing a timeout exception.
  int? _timeout;

  /// Time unit for timeout duration.
  ///
  /// This defines the unit of time for the timeout (`TimeUnit.SECONDS` or `TimeUnit.MILLISECONDS`).
  TimeUnit _timeUnit = TimeUnit.SECONDS;

  /// Static variable to store a global authorization token for API requests.
  ///
  /// If set, this token will be used for all requests unless a specific token is passed to a request.
  static String? _authToken;

  /// Constructor for initializing `ImpakRetro` instance.
  ///
  /// - `userLogger`: A boolean to enable logging of requests and responses (default: true).
  /// - `baseUrl`: A base URL for all API requests (default: null).
  /// - `loggingInterceptor`: A custom logging interceptor for logging requests and responses (default: null).
  /// - `authToken`: A global authorization token for all requests (default: null).
  /// - `timeout`: Timeout for API requests in seconds (default: null).
  /// - `timeUnit`: Time unit for timeout (default: `TimeUnit.SECONDS`).
  ImpakRetro({
    bool userLogger = true,
    String? baseUrl,
    Interceptor? loggingInterceptor,
    String? authToken,
    int? timeout,
    TimeUnit? timeUnit,
  }) {
    init(
      useLogger: userLogger,
      baseUrl: baseUrl,
      loggingInterceptor: loggingInterceptor,
      authToken: authToken,
      timeUnit: timeUnit,
      timeout: timeout,
    );
  }

  /// Internal constructor for creating an instance without external configuration.
  ///
  /// This constructor is used internally for creating a singleton instance.
  ImpakRetro._internal() {
    init();
  }

  /// Singleton instance of `ImpakRetro`.
  ///
  /// This ensures that only one instance of `ImpakRetro` is used throughout the app for HTTP requests.
  static ImpakRetro instance = ImpakRetro._internal();

  /// Initializes the Dio instance and configuration settings.
  ///
  /// - `useLogger`: A boolean to enable logging of requests and responses (default: true).
  /// - `baseUrl`: A base URL for all API requests (default: null).
  /// - `loggingInterceptor`: A custom logging interceptor for logging requests and responses (default: null).
  /// - `authToken`: A global authorization token for all requests (default: null).
  /// - `timeout`: Timeout for API requests in seconds (default: null).
  /// - `timeUnit`: Time unit for timeout (default: `TimeUnit.SECONDS`).
  init({
    bool useLogger = true,
    String? baseUrl,
    Interceptor? loggingInterceptor,
    String? authToken,
    int? timeout,
    TimeUnit? timeUnit,
  }) {
    _baseUrl = baseUrl ?? _baseUrl;
    _timeout = timeout ?? _timeout;
    _timeUnit = timeUnit ?? _timeUnit;

    // Add logger interceptor if logging is enabled or custom logging interceptor is provided.
    if (useLogger || loggingInterceptor != null) {
      _dio.interceptors.add(loggingInterceptor ??
          PrettyDioLogger(
            requestBody: true,
            requestHeader: true,
            responseBody: true,
            responseHeader: false,
          ));
    }

    // Set the authentication token if provided.
    if (authToken != null) {
      _authToken = authToken;
    }
    _configInit = _ImpakRetroConfig(_dio); // Initialize the configuration.
  }

  /// Sets the authorization token for all requests.
  ///
  /// This token will be used for all requests made by `ImpakRetro` unless another token is explicitly passed to a request.
  static setAuthToken(String authToken) {
    _authToken = authToken;
  }

  /// Makes an HTTP request with form data, and returns a type-safe response.
  ///
  /// - `path`: The endpoint for the request.
  /// - `method`: The HTTP method (GET, POST, etc.).
  /// - `formData`:  An instance of ImpakRetroFormData containing a map of data.
  /// - `successFromJson`: A function to parse the response data into a model of type `T`.
  /// - `baseUrl`: Optional base URL.
  /// - `onProgress`: Optional callback for progress during uploads/downloads.
  /// - `canceller`: Optional canceller for the request.
  /// - `useAuthToken`: Whether to use the default authorization token (default: true).
  /// - `authorizationToken`: Optional custom authorization token for this request.
  /// - `headers`: Optional request headers.
  /// - `queryParameters`: Optional query parameters for the request.
  Future<ImpakRetroResponse<T>> typeSafeFormDataCall<T>({
    required String path,
    required RequestMethod method,
    required ImpakRetroFormData formData,
    required T Function(dynamic) successFromJson,
    String? baseUrl,
    void Function(int, int)? onProgress,
    Canceller? canceller,
    bool useAuthToken = true,
    String? authorizationToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final result = await formDataCall(
        path: path,
        method: method,
        headers: headers,
        queryParameters: queryParameters,
        baseUrl: baseUrl,
        onProgress: onProgress,
        canceller: canceller,
        useAuthToken: useAuthToken,
        authorizationToken: authorizationToken,
        formData: formData,
      );

      if (result.isSuccessful) {
        try {
          final data = successFromJson(result.data); // Parse the data using the provided function.
          return ImpakRetroSuccess(data: data, statusCode: result.statusCode);
        } on Object catch (e, s) {
          // Log and throw mapping error if parsing fails.
          if (kDebugMode) {
            print(e.toString());
            print(s.toString());
          }
          throw ImpakRetroException(
              statusCode: result.statusCode,
              ExceptionType.MAPPING_ERROR,
              message: e.toString());
        }
      } else {
        return ImpakRetroFailure(error: result.error, statusCode: result.statusCode);
      }
    } on ImpakRetroException catch (_) {
      rethrow;
    } catch (e) {
      throw ImpakRetroException(
          statusCode: null,
          ExceptionType.UNKNOWN_ERROR,
          message: e.toString());
    }
  }

  /// Makes a simple HTTP request with a type-safe response and returns the parsed data.
  ///
  /// - `path`: The endpoint for the request.
  /// - `method`: The HTTP method (GET, POST, etc.).
  /// - `successFromJson`: A function to parse the response data into a model of type `T`.
  /// - `baseUrl`: Optional base URL.
  /// - `onProgress`: Optional callback for progress during uploads/downloads.
  /// - `canceller`: Optional canceller for the request.
  /// - `useAuthToken`: Whether to use the default authorization token (default: true).
  /// - `authorizationToken`: Optional custom authorization token for this request.
  /// - `body`: Optional request body.
  /// - `headers`: Optional request headers.
  /// - `queryParameters`: Optional query parameters for the request.
  Future<ImpakRetroResponse<T>> typeSafeCall<T>({
    required String path,
    required RequestMethod method,
    required T Function(dynamic) successFromJson,
    String? baseUrl,
    void Function(int, int)? onProgress,
    Canceller? canceller,
    bool useAuthToken = true,
    String? authorizationToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final result = await call(
        path: path,
        method: method,
        headers: headers,
        queryParameters: queryParameters,
        baseUrl: baseUrl,
        onProgress: onProgress,
        canceller: canceller,
        useAuthToken: useAuthToken,
        authorizationToken: authorizationToken,
        body: body,
      );

      if (result.isSuccessful) {
        try {
          final data = successFromJson(result.data); // Parse the data using the provided function.
          return ImpakRetroSuccess(data: data, statusCode: result.statusCode);
        } on Object catch (e, s) {
          // Log and throw mapping error if parsing fails.
          if (kDebugMode) {
            print(e.toString());
            print(s.toString());
          }
          throw ImpakRetroException(
              statusCode: result.statusCode,
              ExceptionType.MAPPING_ERROR,
              message: e.toString());
        }
      } else {
        return ImpakRetroFailure(error: result.error, statusCode: result.statusCode);
      }
    } on ImpakRetroException catch (_) {
      rethrow;
    } catch (e) {
      throw ImpakRetroException(
          statusCode: null,
          ExceptionType.UNKNOWN_ERROR,
          message: e.toString());
    }
  }

  /// Makes a generic HTTP request and returns the response.
  ///
  /// - `path`: The endpoint for the request.
  /// - `method`: The HTTP method (GET, POST, etc.).
  /// - `baseUrl`: Optional base URL.
  /// - `onProgress`: Optional progress callback for file uploads/downloads.
  /// - `canceller`: Optional canceller to cancel the request.
  /// - `useAuthToken`: Whether to use the default auth token.
  /// - `authorizationToken`: Optional custom authorization token.
  /// - `body`: Optional request body.
  /// - `headers`: Optional request headers.
  /// - `queryParameters`: Optional query parameters for the request.
  Future<ImpakResponse> call({
    required String path,
    required RequestMethod method,
    String? baseUrl,
    void Function(int, int)? onProgress,
    Canceller? canceller,
    bool useAuthToken = true,
    String? authorizationToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_config.combineBaseUrls(_baseUrl, baseUrl) == null) {
      throw (ImpakRetroException(ExceptionType.BAD_REQUEST, statusCode: 400, message: "Base URL cannot be null"));
    }

    var token = authorizationToken;
    if (useAuthToken && authorizationToken == null) {
      token = _authToken;
    }

    try {
      final result = await _config.call(
        baseUrl: _config.combineBaseUrls(_baseUrl, baseUrl)!,
        path: path,
        method: method,
        authorizationToken: token,
        onProgress: onProgress,
        canceller: canceller,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        timeUnit: _timeUnit,
        body: body,
        headers: headers,
        queryParameters: queryParameters,
      );

      return ImpakResponse(statusCode: result.statusCode, data: result.data);
    } on TimeoutException catch (_) {
      throw(ImpakRetroException(ExceptionType.TIMEOUT_ERROR, statusCode: null, message: "Request timed out"));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw(ImpakRetroException(ExceptionType.CANCELLED_ERROR, message: "Request was cancelled by user", statusCode: e.response?.statusCode));
      }
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        /*if (response?.statusCode == 401 || response?.statusCode == 403) {
          throw(ImpakRetroException(ExceptionType.AUTHORISATION_ERROR, message: "Unauthorized request", statusCode: e.response?.statusCode));
        }*/

        if (response?.statusCode != null && response!.statusCode! > 499) {
          final error = ImpakRetroException(ExceptionType.SERVER_ERROR, statusCode: e.response?.statusCode, message: "Server returned an error. Check server status", );
          throw(error);
        }
        if (response != null) {
          return ImpakResponse(error: e.response?.data, statusCode: e.response?.statusCode);
        }
        throw(ImpakRetroException(ExceptionType.BAD_REQUEST, statusCode: e.response?.statusCode, message: "Server returned an error. Check server status"));
      }

      if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout) {
        throw(ImpakRetroException(ExceptionType.TIMEOUT_ERROR, message: "Request timed out", statusCode: e.response?.statusCode));
      }
      if (e.type == DioExceptionType.connectionError) {
        throw(ImpakRetroException(ExceptionType.CONNECTION_ERROR, message: "Failed to connect to server. Check internet connection", statusCode: e.response?.statusCode));
      }

      if (e.type == DioExceptionType.unknown) {
        throw(ImpakRetroException(ExceptionType.UNKNOWN_ERROR, message: "An unknown error occurred", statusCode: e.response?.statusCode));
      }

      throw(ImpakRetroException(ExceptionType.SERVER_ERROR, message: "A server error occurred", statusCode: e.response?.statusCode));
    }
    on Object catch (exception) {
      throw(ImpakRetroException(ExceptionType.UNKNOWN_ERROR, message: exception.toString(), statusCode: null), statusCode: null);
    }
  }

  /// Makes a form data HTTP request and returns the response.
  ///
  /// - `path`: The endpoint for the request.
  /// - `method`: The HTTP method (GET, POST, etc.).
  /// - `formData`:  An instance of ImpakRetroFormData containing a map of data.
  /// - `baseUrl`: Optional base URL.
  /// - `onProgress`: Optional progress callback for file uploads/downloads.
  /// - `canceller`: Optional canceller to cancel the request.
  /// - `useAuthToken`: Whether to use the default auth token.
  /// - `authorizationToken`: Optional custom authorization token.
  /// - `headers`: Optional request headers.
  /// - `queryParameters`: Optional query parameters for the request.
  Future<ImpakResponse> formDataCall({
    required String path,
    required RequestMethod method,
    required ImpakRetroFormData formData,
    String? baseUrl,
    void Function(int, int)? onProgress,
    Canceller? canceller,
    bool useAuthToken = true,
    String? authorizationToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_config.combineBaseUrls(_baseUrl, baseUrl) == null) {
      throw (ImpakRetroException(ExceptionType.BAD_REQUEST, statusCode: 400, message: "Base URL cannot be null"));
    }
    var token = authorizationToken;
    if (useAuthToken && authorizationToken == null) {
      token = _authToken;
    }

    try {
      final result = await _config.formDataCall(
        baseUrl: _config.combineBaseUrls(_baseUrl, baseUrl)!,
        path: path,
        formData: await formData.data,
        method: method,
        authorizationToken: token,
        onProgress: onProgress,
        canceller: canceller,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        timeUnit: _timeUnit,
        headers: headers,
        queryParameters: queryParameters,
      );

      return ImpakResponse(statusCode: result.statusCode, data: result.data);
    } on TimeoutException catch (_) {
      throw(ImpakRetroException(ExceptionType.TIMEOUT_ERROR, statusCode: null, message: "Request timed out"));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw(ImpakRetroException(ExceptionType.CANCELLED_ERROR, message: "Request was cancelled by user", statusCode: e.response?.statusCode));
      }
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        if (response?.statusCode == 401 || response?.statusCode == 403) {
          throw(ImpakRetroException(ExceptionType.AUTHORISATION_ERROR, message: "Unauthorized request", statusCode: e.response?.statusCode));
        }

        if (response?.statusCode != null && response!.statusCode! > 499) {
          final error = ImpakRetroException(ExceptionType.SERVER_ERROR, statusCode: e.response?.statusCode, message: "Server returned an error. Check server status", );
          throw(error);
        }
        if (response != null) {
          return ImpakResponse(error: e.response?.data, statusCode: e.response?.statusCode);
        }
        throw(ImpakRetroException(ExceptionType.BAD_REQUEST, statusCode: e.response?.statusCode, message: "Server returned an error. Check server status"));
      }

      if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout) {
        throw(ImpakRetroException(ExceptionType.TIMEOUT_ERROR, message: "Request timed out", statusCode: e.response?.statusCode));
      }
      if (e.type == DioExceptionType.connectionError) {
        throw(ImpakRetroException(ExceptionType.CONNECTION_ERROR, message: "Failed to connect to server. Check internet connection", statusCode: e.response?.statusCode));
      }

      if (e.type == DioExceptionType.unknown) {
        throw(ImpakRetroException(ExceptionType.UNKNOWN_ERROR, message: "An unknown error occurred", statusCode: e.response?.statusCode));
      }

      throw(ImpakRetroException(ExceptionType.SERVER_ERROR, message: "A server error occurred", statusCode: e.response?.statusCode));
    }
    on Object catch (exception) {
      throw(ImpakRetroException(ExceptionType.UNKNOWN_ERROR, message: exception.toString(), statusCode: null));
    }
  }
}
