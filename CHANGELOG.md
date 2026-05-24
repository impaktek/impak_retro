# Changelog

## [2.1.0] - 2026-05-24

### Added

- **Client lifecycle interceptors:** `ImpakRetroClientInterceptor` and `ImpakRetroClientInterceptorCallbacks` for pre-request (`beforeRequest`), post-response (`afterResponse`), and post-error (`afterError`) hooks (token checks, refresh flows, global 401 handling, etc.).
- **`clientInterceptors` on `ImpakRetro` / `init`:** register, replace, or clear client interceptors (inserted before the optional HTTP logger).
- **Dio type re-exports:** `lib/export/impak_http.dart` exported from `package:impak_retro/impak.dart` so apps can implement interceptors without a direct `dio` dependency.

### Notes

- See README **Client lifecycle interceptors** for usage and the example app for `ImpakRetroClientInterceptorCallbacks`.

## [2.0.2] - 2025-07-14
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
