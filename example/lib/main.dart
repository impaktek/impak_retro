import 'dart:io';

import 'package:example/src/domain/sample_api_response_model.dart';
import 'package:flutter/material.dart';
import 'package:impak_retro/impak.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? error;
  late ImpakRetro impakRetro;

  final List<Post> _response = [];

  /// Recent lines from [ImpakRetroClientInterceptorCallbacks] (all three hooks).
  final List<String> _interceptorEvents = [];

  /*void _appendInterceptorLog(String line) {
    if (!mounted) return;
    setState(() {
      final stamp = DateTime.now().toIso8601String();
      _interceptorEvents.insert(0, '$stamp $line');
      if (_interceptorEvents.length > 10) {
        _interceptorEvents.removeLast();
      }
    });
  }*/

  /// Demo interceptors: one [ImpakRetroClientInterceptorCallbacks] using every hook.
  /*List<Interceptor> _demoClientInterceptors() {
    return [
      ImpakRetroClientInterceptorCallbacks(
        onBeforeRequest: (options, handler) async {
          _appendInterceptorLog(
            'onBeforeRequest: ${options.method} ${options.uri}',
          );
          // Pre-request: validate or refresh token, mutate headers, etc.
          handler.next(options);
        },
        onAfterResponse: (response, handler) async {
          _appendInterceptorLog(
            'onAfterResponse: HTTP ${response.statusCode} '
            '${response.requestOptions.uri}',
          );
          // Post-response: metrics, response shaping, status checks.
          handler.next(response);
        },
        onAfterError: (err, handler) async {
          final code = err.response?.statusCode;
          _appendInterceptorLog(
            'onAfterError: ${err.type} status=${code ?? '—'}',
          );
          if (code == 401 || code == 403) {
            _appendInterceptorLog(
              'onAfterError: would handle unauthorized (e.g. go to login)',
            );
          }
          // Post-error: refresh + retry uses handler.resolve after dio.fetch, etc.
          handler.next(err);
        },
      ),
    ];
  }*/

  @override
  void initState() {
    /*impakRetro = ImpakRetro(
      baseUrl: Constants.BASE_URL,
      authToken: "Bearer ${Constants.TOKEN}",
      userLogger: true,
      timeout: 30,
      timeUnit: TimeUnit.SECONDS,
      clientInterceptors: _demoClientInterceptors(),
    );*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeCall();
    });
    super.initState();
  }

  Future<void> _download() async {
    final status = await Permission.storage.request();
    late String savePath;
    try {
      if (!status.isGranted) {
        //print("Storage permission denied.");
        return;
      }

      final Directory documents =
          Directory('/storage/emulated/0/Documents/my_app_folder');
      if (!await documents.exists()) {
        await documents.create(recursive: true);
      }
      savePath = '${documents.path}/File_Downloaded.pdf';
      impakRetro.download(
          path:
              "https://cross-river-pay.s3.us-east-2.amazonaws.com/cas-assets/1744163907785.pdf",
          savePath: savePath,
          onProgress: (progress, total) {
            setState(() {
              error = "${progress / total * 100}%";
            });
          });
    } catch (__, _) {}
  }

  Future<void> _safeCall() async {
    try {
      final result = await impakRetro.typeSafeCall(
        path: "/auth/login",
        baseUrl: 'https://agent.api.onemoni.com/api/v1',
        method: RequestMethod.POST,
        body: {"username": 'takonajie', "password": 'ABab12.'},
        successFromJson: (json) => Response.fromJson(json),
      );
      if (result.isSuccessful) {
      } else {
        error = result.asError["error"];
      }
    } catch (e) {
      if (e is ImpakRetroException) {
        error = e.message;
        switch (e.type) {
          case ExceptionType.TIMEOUT_ERROR:
          //Custom implementation
          case ExceptionType.BAD_REQUEST:
          //Custom implementation
          case ExceptionType.SERVER_ERROR:
          //Custom implementation
          case ExceptionType.CANCELLED_ERROR:
          //Custom implementation
          case ExceptionType.UNKNOWN_ERROR:
          //Custom implementation
          case ExceptionType.MAPPING_ERROR:
          //Custom implementation
          case ExceptionType.AUTHORISATION_ERROR:
          //Custom implementation
          case ExceptionType.CONNECTION_ERROR:
          //Custom implementation
        }
      } else {
        setState(() {
          // error = e.toString();
        });
      }
    }
  }

  /*void _call() async {
    try {
      setState(() {
        _response = [];
      });
      final params = {"page": 19, "size": 3};
      impakRetro.init(
          baseUrl: Constants.BASE_URL1, authToken: "Bearer ${Constants.TOKEN}");
      final header = {"Authorization": "Bearer ${Constants.TOKEN}"};
      final result = await impakRetro.call(
        path: Constants.SAMPLE_PATH1,
        queryParameters: params,
        headers: header,
        canceller: Canceller(),
        method: RequestMethod.GET,
      );
      if (result.isSuccessful) {
        final response = ApiResponseModel.fromJson(result.data);
        _response = response.data.posts;
        error = null;
      } else {
        _response = [];
        error = result.asError["message"];
      }
    } catch (e) {
      if (e.runtimeType == ImpakRetroException) {
        e as ImpakRetroException;
        setState(() {
          _response = [];
          error = e.message;
        });
        switch (e.type) {
          case ExceptionType.TIMEOUT_ERROR:
            break;
          case ExceptionType.SERVER_ERROR:
            break;
          case ExceptionType.UNKNOWN_ERROR:
            break;
          case ExceptionType.AUTHORISATION_ERROR:
            break;
          case ExceptionType.CONNECTION_ERROR:
            break;
          case ExceptionType.MAPPING_ERROR:
            break;
          case ExceptionType.BAD_REQUEST:
            break;
          case ExceptionType.CANCELLED_ERROR:
            break;
        }
      } else {
        setState(() {
          _response = [];
          error = e.toString();
        });
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            if (_interceptorEvents.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(top: 12.0, bottom: 4.0),
                child: Text(
                  'ImpakRetroClientInterceptorCallbacks (all hooks)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: ListView.builder(
                  itemCount: _interceptorEvents.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      _interceptorEvents[i],
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
            if (_response.isNotEmpty) ...[
              Text(
                'TODOS',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Flexible(
                  child: ListView.builder(
                      itemCount: _response.length,
                      itemBuilder: (_, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 8.0),
                            child: Column(
                              children: [
                                Text(
                                  _response[index].title,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(_response[index].title),
                              ],
                            ),
                          )))
            ],
            if (error != null) ...[
              Text(
                'Request Error',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '$error',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _download,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Response {
  final int status;
  final String message;
  final bool data;

  Response({required this.status, required this.message, required this.data});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
        status: json['status'], message: json['message'], data: json['data']);
  }
}
