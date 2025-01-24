// ignore_for_file: constant_identifier_names

/// Represents the different HTTP request methods supported by the application.
///
/// Each value corresponds to a standard HTTP method, allowing for clear
/// and consistent representation of HTTP operations.
enum RequestMethod {
  /// The HTTP GET method, typically used to retrieve data from a server.
  GET,

  /// The HTTP POST method, commonly used to send data to a server to create new resources.
  POST,

  /// The HTTP PUT method, often used to update or replace existing resources on a server.
  PUT,

  /// The HTTP PATCH method, used for partial updates to existing resources on a server.
  PATCH,

  /// The HTTP DELETE method, used to remove resources from a server.
  DELETE;
}
