# ImpakRetro

ImpakRetro is a powerful Dart library for handling HTTP requests. Built on top of the [Dio](https://pub.dev/packages/dio) package, it offers a type-safe, configurable, and easy-to-use interface for interacting with APIs.

---

## Features

- **Type-Safe Requests**: Parse API responses into typed objects with ease.
- **Global and Request-Specific Authorization Tokens**: Simplify authenticated API calls.
- **Customizable Logging**: Leverage built-in logging or provide your custom logging interceptors.
- **Timeouts and Error Handling**: Define request timeouts and handle API errors gracefully.
- **Singleton Support**: Maintain a single `ImpakRetro` instance across your application.
- **File Uploads**: Built-in support for form-data and file uploads.
- **Flexible Configuration**: Customize base URLs, headers, and request parameters.

---

## Installation

Add `impak_retro` to your `pubspec.yaml`:

```yaml
dependencies:
  impak_retro: ^1.0.1+1
```
Then run `flutter pub get` to install the package.

or run `flutter pub add impak_retro` to install the package package from terminal

## Usage

### 1. Initial Setup

Using Singleton Instance

```dart
import 'package:impak_retro/impak.dart';


ImpakRetro.instance.init(
  useLogger: true, 
  baseUrl: "https://api.example.com", //optional
  authToken: "your_auth_token" //optional
);
```

Or Using Constructor

```dart
import 'package:impak_retro/impak.dart';


final impakRetro = ImpakRetro(
  userLogger: true,
  baseUrl: "https://api.example.com", //optional
  authToken: "your_auth_token", //optional
  timeout: 30, //optional
  timeUnit: TimeUnit.SECONDS, //optional
);
```

You can also set an authorization token that you will use repeatedly using the static method `setAuthToken`
example 

```dart
ImpakRetro.setAuthToken("Bearer $token");
```

### 2. Making Requests

The `ImpakRetro` class provides a `typeSafeCall` method for making type-safe HTTP requests, `typeSafeFormDataCall` for making type-safe `form-data` request as well raw requests using the `call` or `formDataCall` methods.

- **Type-Safe Requests**:

```dart
  try{
    final result = await impakRetro.typeSafeCall<Response>(
        path: Constants.SAMPLE_PATH,// e.g "/api/v1/users
        successFromJson: (json) => Response.fromJson(json),
        method: RequestMethod.POST,
        //headers: {} //optional
        useAuthToken: true, //set this when you have set an auth token
        //authorizationToken: "Bearer ${Constants.TOKEN}" //this can be used to provide a different auth Token from the one provided at initialization
        body: {"password": Constants.SAMPLE_PASSWORD1,});

    if(result.isSuccessful){
      ///Response is my custom model and has a field `data`
      _result = result.asBody.data;
    }else {
      error = result.asError.toString(); //asError returns a dynamic data which conforms to what the api returns when there is an error
    }

    //Response can also be obtained using a switch statement as below
    switch(result){
      case ImpakRetroSuccess<Response>():
        _result = result.asBody.data;
        break;

      case ImpakRetroFailure():
        setState(() {
          error = result.error.toString();
        });
        break;

    }
  }catch(e){
    if(e.runtimeType is ImpakRetroException){
      e as ImpakRetroException;
      error = e.message;
      print(e.statusCode);
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
    }
  }
```

- **Type-Safe Form-data Request**:
```dart
    try{
      final file = File("some path");
      final result = await impakRetro.typeSafeFormDataCall<Response>(
          path: Constants.SAMPLE_PATH1,
          successFromJson: (json) => Response.fromJson(json),
          method: RequestMethod.POST,
          onProgress: (uploaded, total)=>{} //optional
          useAuthToken: true,
          baseUrl: Constants.BASE_URL,
          authorizationToken: "Bearer ${Constants.TOKEN1}",
          formData: ImpakRetroFormData({
            "File": file,
            "name": file.path,
            //and so on
          })
      );

      if(result.isSuccessful){
        ///Response is my custom model and has a field `data`
        _result = result.asBody.data;
      }else {
        error = result.asError.toString(); //asError returns a dynamic data which conforms to what the api returns when there is an error
      }

      //Response can also be obtained using a switch statement as below
      switch(result){
        case ImpakRetroSuccess<Response>():
          _result = result.asBody.data;
          break;

        case ImpakRetroFailure():
          setState(() {
            error = result.error.toString();
          });
          break;

      }
    }catch(e){
      if(e.runtimeType is ImpakRetroException){
        e as ImpakRetroException;
        error = e.message;
        print(e.statusCode);
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
      }
    }
```

- **Raw Form-data Request**:

```dart
    try{
      final file = File("some path");
      final result = await impakRetro.formDataCall(
          path: Constants.SAMPLE_PATH1,
          method: RequestMethod.POST,
          useAuthToken: true,
          onProgress: (uploaded, total)=>{} //optional
          baseUrl: Constants.BASE_URL,
          authorizationToken: "Bearer ${Constants.TOKEN1}",
          formData: ImpakRetroFormData({
            "File": file,
            "name": file.path,
            //and so on
          })
      );

      if(result.isSuccessful){
        ///Response is my custom model and has a field `data`
        ///`asBody` returns a dynamic result that matches `Response` model
        _result = Response.fromJson(result.asBody).data;
        ///OR
        ///
        _result = result.asBody["data"];
      }else {
        error = result.asError.toString(); //asError returns a dynamic data which conforms to what the api returns when there is an error
      }
      
    }catch(e){
      if(e.runtimeType is ImpakRetroException){
        e as ImpakRetroException;
        error = e.message;
        print(e.statusCode);
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
      }
    }
```

- **Raw Request**: A raw request other than form data request
```dart
    try{
      final result = await impakRetro.call(
          path: Constants.SAMPLE_PATH1,
          method: RequestMethod.GET,
          queryParameters: {
            "param1": 3,
            'param2': "other params"
          },
          baseUrl: Constants.BASE_URL,
          authorizationToken: "Bearer ${Constants.TOKEN1}",
      );

      if(result.isSuccessful){
        ///Response is my custom model and has a field `data`
        ///`asBody` returns a dynamic result that matches `Response` model
        _result = Response.fromJson(result.asBody).data;
        ///OR
        ///
        _result = result.asBody["data"];
      }else {
        error = result.asError.toString(); //asError returns a dynamic data which conforms to what the api returns when there is an error
      }

    }catch(e){
      if(e.runtimeType is ImpakRetroException){
        e as ImpakRetroException;
        error = e.message;
        print(e.statusCode);
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
      }
    }
```

## 5. Exception Handling with `ImpakRetroException`
The exceptions that are thrown during a request are instances of ImpakRetroException, which contains an `ExceptionType` enum. Use the switch statement to handle different types of exceptions:

```dart
try {
  final response = await ImpakRetro.instance.typeSafeCall<MyModel>(
    path: "/some-api-endpoint",
    method: RequestMethod.GET,
    successFromJson: (json) => MyModel.fromJson(json),
  );
} catch (e) {
  if (e is ImpakRetroException) {
    switch (e.type) {
      case ExceptionType.TIMEOUT_ERROR:
        print("Timeout error: ${e.message}");
        break;
      case ExceptionType.AUTHORISATION_ERROR:
        print("Authorization error: ${e.message}");
        break;
      case ExceptionType.BAD_REQUEST:
        print("Bad request: ${e.message}");
        break;
      case ExceptionType.SERVER_ERROR:
        print("Server error: ${e.message}");
        break;
      case ExceptionType.UNKNOWN_ERROR:
        print("Unknown error: ${e.message}");
        break;
      case ExceptionType.MAPPING_ERROR:
        print("Mapping error: ${e.message}");
        break;
      case ExceptionType.CANCELLED_ERROR:
        print("Request cancelled: ${e.message}");
        break;
      case ExceptionType.CONNECTION_ERROR:
        print("Connection error: ${e.message}");
        break;
    }
  }
}
```

### Available Exception Types

`ImpakRetroException` contains the following exception types:
- **TIMEOUT_ERROR**: Thrown when the request times out.
- **AUTHORISATION_ERROR**: Thrown when the user is unauthorized (e.g., invalid or missing token).
- **BAD_REQUEST**: Thrown when the server returns a bad request response.
- **SERVER_ERROR**: Thrown when the server encounters an error (status code 5xx).
- **UNKNOWN_ERROR**: Thrown for any unknown errors.
- **MAPPING_ERROR**: Thrown when the response cannot be mapped to the expected model.
- **CANCELLED_ERROR**: Thrown when the request is cancelled.
- **CONNECTION_ERROR**: Thrown when a connection error occurs.

## Contribution
If you'd like to contribute to this project, feel free to fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
# impakdio