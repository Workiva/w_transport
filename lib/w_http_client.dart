/// A fluent-style HTTP request library for use in the browser.
/// Supports simple request construction and response retrieval
/// for most use cases, with the option to configure the outgoing
/// [HttpRequest] if necessary.
///
/// To use this library in your code:
///
///     import 'package:w_transport/w_http_client.dart';
///
///     void main() {
///       new WHttp().get(Uri.parse('example.com')).then((WResponse response) {
///         print(response.text);
///       });
///     }
///
///
/// ## [WRequest]
/// The class used to create and send HTTP requests from the browser.
/// Supports headers, request data, progress monitoring, withCredentials,
/// request cancellation, and sending requests with these HTTP methods:
///
/// * DELETE
/// * GET
/// * HEAD
/// * OPTIONS
/// * PATCH
/// * POST
/// * PUT
///
/// Additionally, [WRequest] extends [UrlMutation] for convenient request URL
/// construction.
///
///
/// ## [WResponse]
/// The class that contains the response to a [WRequest]. All expected relevant information
/// is available: response headers, status code (200), status text ('OK'), and response data.

library w_transport.w_http_client;

export 'src/http/w_http_client.dart';