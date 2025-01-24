import 'package:example/src/constants/local_constants.dart';
import 'package:example/src/domain/sample_api_response_model.dart';
import 'package:flutter/material.dart';
import 'package:impak_retro/config/impak_retro_form_data.dart';
import 'package:impak_retro/impak.dart';

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

  List<Post> _response = [];

  bool _result = false;

  @override
  void initState() {
    impakRetro = ImpakRetro(
      baseUrl: Constants.BASE_URL,
      authToken: "Bearer ${Constants.TOKEN}",
      userLogger: true,
      timeout: 30,
      timeUnit: TimeUnit.SECONDS
    );
    WidgetsBinding.instance.addPostFrameCallback((_){
      _safeCall();
    });
    super.initState();
  }

  _safeCall() async{
    try{
      final result = await impakRetro.typeSafeFormDataCall(
          path: Constants.SAMPLE_PATH1,
          method: RequestMethod.GET,
          formData: ImpakRetroFormData({
            "data": "",
            "dlfd ": ""
          }),
          queryParameters: {
            "param1": 3,
            'param2': "other params"
          },
          baseUrl: Constants.BASE_URL,
          authorizationToken: "Bearer ${Constants.TOKEN1}",
        successFromJson: (json) => Response.fromJson(json),
      );

      if(result.isSuccessful){
        ///Response is my custom model and has a field `data`
        ///`asBody` returns a dynamic result that matches `Response` model
        _result = result.asBody.data;//Response.fromJson(result.asBody).data;
        ///OR
        ///
        //_result = result.asBody["data"];
      }else {
        error = result.asError.toString(); //asError returns a dynamic data which conforms to what the api returns when there is an error
      }

    }catch(e){
      if(e is ImpakRetroException){
        error = e.message;
        switch(e.type){
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
      }else{
        setState(() {
         // error = e.toString();
        });
      }
    }
  }

  void _call() async{
    try {
      setState(() {
        _response = [];
      });
      final params = {
        "page": 19,
        "size": 3
      };
      impakRetro.init(baseUrl: Constants.BASE_URL1, authToken: "Bearer ${Constants.TOKEN}");
      final header = {
        "Authorization": "Bearer ${Constants.TOKEN}"
      };
      final result = await impakRetro.call(
        path: Constants.SAMPLE_PATH1,
        queryParameters: params,
        headers: header,
        canceller: Canceller(),
        method: RequestMethod.GET,
      );
      if(result.isSuccessful){
        final response = ApiResponseModel.fromJson(result.data);
        _response = response.data.posts;
        error = null;
      }else {
        _response = [];
        error = result.error["message"];
      }

    } catch(e){
      if(e.runtimeType == ImpakRetroException){
        e as ImpakRetroException;
        setState(() {
          _response = [];
          error = e.message;
        });
        switch(e.type){
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
      }else{
        setState(() {
          _response = [];
          error = e.toString();
        });
      }

    }
  }

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

            if(_response.isNotEmpty)...[
              Text('TODOS', style: TextStyle(fontWeight: FontWeight.w600),),
              Flexible(child: ListView.builder(itemCount: _response.length, itemBuilder: (_, index)=> Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    Text(_response[index].title, style: TextStyle(fontWeight: FontWeight.w500),),
                    const SizedBox(height: 8,),
                    Text(_response[index].title),
                  ],
                ),
              )))
            ],
            if(error != null)...[
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
        onPressed: _call,
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
