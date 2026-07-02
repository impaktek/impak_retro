import 'dart:io'; // Provides support for working with files and directories.
import 'package:dio/dio.dart'; // A powerful HTTP client library for Dart.
import 'package:http_parser/http_parser.dart'; // Utility for handling media types and content types.

/// A utility class for converting a map of key-value pairs into a `FormData` object,
/// which is used for making HTTP POST requests with multipart form data.
///
/// This class is particularly useful for handling form submissions that include files.
class ImpakRetroFormData {
  // A private map holding the initial data to be converted to FormData.
  final Map<String, dynamic> _data;

  /// Constructor to initialize the `_data` map.
  ///
  /// @param [data] A map of key-value pairs to be used for generating the FormData.
  ///               Defaults to an empty map if not provided.
  ImpakRetroFormData([this._data = const {}]);

  /// A getter that asynchronously converts `_data` into a `FormData` object.
  ///
  /// @return A `Future` that resolves to a `FormData` object.
  Future<FormData> get data => _fromMap();

  /// A private method that converts `_data` into a `FormData` object.
  ///
  /// This method iterates over each key-value pair in the `_data` map and adds them
  /// to the appropriate `FormData` fields or files, depending on the value type.
  ///
  /// @return A `Future` that resolves to a `FormData` object.
  Future<FormData> _fromMap() async {
    final formData = FormData();

    for (final entry in _data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        formData.files.add(
          MapEntry(key, await _multipartFile(value)),
        );
      } else if (value is List) {
        for (final item in value) {
          if (item is File) {
            formData.files.add(
              MapEntry(key, await _multipartFile(item)),
            );
          } else {
            formData.fields.add(MapEntry(key, _toFieldString(item)));
          }
        }
      } else {
        formData.fields.add(MapEntry(key, _toFieldString(value)));
      }
    }

    return formData;
  }

  /// Converts a non-file field value to the [String] required by [FormData.fields].
  String _toFieldString(dynamic value) => value.toString();

  /// A private helper method to convert a `File` into a `MultipartFile`.
  ///
  /// This method reads the file's bytes and creates a `MultipartFile` instance
  /// with a content type of `application/octet-stream`.
  ///
  /// @param [file] The `File` to be converted.
  /// @return A `Future` that resolves to a `MultipartFile` instance.
  Future<MultipartFile> _multipartFile(File file) async {
    final byte = await file.readAsBytes(); // Read the file's bytes.

    // Return a MultipartFile created from the file's bytes.
    return MultipartFile.fromBytes(
      byte,
      filename: file.path
          .split('/')
          .last, // Extract the file name from the file path.
      contentType:
          MediaType('application', 'octet-stream'), // Set the content type.
    );
  }
}
