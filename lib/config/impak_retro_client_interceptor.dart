import 'package:dio/dio.dart';

/// Dio [Interceptor] with explicit **pre-request** and **post-response / post-error**
/// hooks for app code (access-token checks, refresh flows, global 401 handling, etc.).
///
/// Each hook **must** end by calling exactly one of the methods on the supplied
/// [RequestInterceptorHandler], [ResponseInterceptorHandler], or
/// [ErrorInterceptorHandler]: `next`, `reject`, or `resolve` — same contract as Dio.
///
/// Insert order: pass these in [ImpakRetro.init] via `clientInterceptors`; they are
/// registered **before** the optional HTTP logger so they run first on outbound
/// requests and last on inbound responses/errors (Dio reverses the stack on the way back).
abstract class ImpakRetroClientInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _run(
      () => beforeRequest(options, handler),
      onFailure: (Object e, StackTrace st) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: e,
            stackTrace: st,
            type: DioExceptionType.unknown,
          ),
        );
      },
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _run(
      () => afterResponse(response, handler),
      onFailure: (Object e, StackTrace st) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: e,
            stackTrace: st,
            type: DioExceptionType.unknown,
          ),
        );
      },
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _run(
      () => afterError(err, handler),
      onFailure: (Object e, StackTrace st) {
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: e,
            stackTrace: st,
            type: DioExceptionType.unknown,
          ),
        );
      },
    );
  }

  /// Runs immediately before the request is sent. Default forwards unchanged.
  ///
  /// Typical uses: ensure valid access token, attach headers, refresh and retry
  /// by calling [handler.resolve] with a cloned request after refresh.
  Future<void> beforeRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    handler.next(options);
  }

  /// Runs after a response is received (any status) and before ImpakRetro maps it.
  /// Default forwards unchanged.
  Future<void> afterResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    handler.next(response);
  }

  /// Runs when Dio reports an error (network, bad response, cancel, etc.).
  /// Default forwards unchanged.
  Future<void> afterError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
  }

  void _run(
    Future<void> Function() action, {
    required void Function(Object e, StackTrace st) onFailure,
  }) {
    action().catchError(onFailure);
  }
}

/// Callback-driven [ImpakRetroClientInterceptor] when subclassing is not preferred.
///
/// Any callback omitted behaves like the base defaults (`handler.next(...)`).
class ImpakRetroClientInterceptorCallbacks extends ImpakRetroClientInterceptor {
  /// Creates hooks; each callback must forward the [handler] when finished.
  ImpakRetroClientInterceptorCallbacks({
    this.onBeforeRequest,
    this.onAfterResponse,
    this.onAfterError,
  });

  final Future<void> Function(
    RequestOptions options,
    RequestInterceptorHandler handler,
  )? onBeforeRequest;

  final Future<void> Function(
    Response response,
    ResponseInterceptorHandler handler,
  )? onAfterResponse;

  final Future<void> Function(
    DioException err,
    ErrorInterceptorHandler handler,
  )? onAfterError;

  @override
  Future<void> beforeRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (onBeforeRequest != null) {
      await onBeforeRequest!(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  Future<void> afterResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (onAfterResponse != null) {
      await onAfterResponse!(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  Future<void> afterError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (onAfterError != null) {
      await onAfterError!(err, handler);
    } else {
      handler.next(err);
    }
  }
}
