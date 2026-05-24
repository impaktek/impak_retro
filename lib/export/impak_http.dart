/// Re-exports selected [Dio](https://pub.dev/packages/dio) types so apps only depend on
/// `impak_retro` when writing [Interceptor]s or [ImpakRetroClientInterceptor] subclasses.
library;

export 'package:dio/dio.dart'
    show
        Dio,
        DioException,
        DioExceptionType,
        ErrorInterceptorHandler,
        Interceptor,
        RequestInterceptorHandler,
        RequestOptions,
        Response,
        ResponseInterceptorHandler;
