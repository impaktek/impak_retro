# Changelog

## [2.0.1] - 2025-07-13
### Added
- **HTTP Request Handling:**
    - Ability to make HTTP requests (GET, POST, etc.) with or without authentication.
    - Support for file uploads with progress tracking.
    - Configurable timeout settings with `TimeUnit`.

- **Logging:**
    - Integrated `PrettyDioLogger` for detailed request and response logging.
    - Custom logging interceptor support.

- **Singleton Instance:**
    - Introduced a singleton instance (`ImpakRetro.instance`) for consistent usage across the application.

- **Authorization:**
    - Support for a global authorization token for API requests.
    - Methods to set and use custom or default tokens per request.

- **Error Handling:**
    - Comprehensive exception handling with detailed error messages.
    - Specific error types for mapping, timeout, connection, and server errors.

- **Type-Safe Responses:**
    - `typeSafeCall` and `typeSafeFormDataCall` methods for parsing API responses into specific data models.

- **Raw Response Handling**: 
- Includes `call` and `formDataCall` methods for making HTTP requests and directly retrieving raw responses without additional transformations.

- **Form Data Support:**
    - Support for making requests with `ImpakRetroFormData`.

- **Customizability:**
    - Ability to pass custom headers, query parameters, and body data for requests.
    - Configurable base URL for each request.

- **Extensibility:**
    - Flexible initialization with optional configuration for base URL, timeout, and logging.

### Notes
- Initial release with core HTTP request capabilities, error handling, and type safety.
