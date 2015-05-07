/// A fluent-style, platform-agnostic HTTP request library.
/// Supports simple request construction and response retrieval
/// for most use cases, with the option to configure the outgoing
/// if necessary.
///
/// ## Platform Agnostic
/// The main library (w_transport/w_http.dart) does not depend on dart:html or dart:io,
/// making it platform agnostic. This means you can use the [w_http] library to build
/// components, libraries, or APIs that will be reusable in the browser AND on the server.
///
/// The end consumer will make the decision between client and server, most likely in a
/// main() block somewhere.
///
/// To use [w_http] in the browser:
///
///     import 'package:w_transport/w_http.dart';
///     import 'package:w_transport/w_http_client.dart' show configureWHttpForBrowser;
///
///     main() async {
///       configureWHttpForBrowser();
///       WResponse response = await WHttp.get(Uri.parse('example.com'));
///       print(await response.text);
///     }
///
/// To use [w_http] on the server:
///
///     import 'package:w_transport/w_http.dart';
///     import 'package:w_transport/w_http_server.dart' show configureWHttpForServer;
///
///     main() async {
///       configureWHttpForServer();
///       WResponse response = await WHttp.get(Uri.parse('example.com'));
///       print(await response.text);
///     }
///
/// ## [WHttp]
/// [WHttp] acts as an HTTP client that can be used to send many HTTP requests.
/// Client-side this has no effect, but on the server this gives you the benefit
/// of cached network connections.
///
/// Additionally, [WHttp] has static methods that make simple HTTP requests easy.
///
///     WHttp.get(Uri.parse('example.com'));
///     WHttp.post(Uri.parse('example.com'), 'data');
///
/// All standard HTTP methods are supported:
///
/// * DELETE
/// * GET
/// * HEAD
/// * OPTIONS
/// * PATCH
/// * POST
/// * PUT
/// * TRACE (only on the server)
///
/// If you do create an instance of [WHttp], make sure you close it when finished.
///
///     WHttp http = new WHttp();
///     ...
///     http.close();
///
///
/// ## [WRequest]
/// [WRequest] is the class used to create and send HTTP requests.
/// It supports headers, request data, upload & download progress monitoring,
/// withCredentials (only useful in the browser), and request cancellation.
///
/// Additionally, [WRequest] utilizes [FluriMixin] for convenient request URI
/// construction.
///
///
/// ## [WResponse]
/// [WResponse] is the class that contains the response to a [WRequest].
///
/// This includes response meta data (available synchronously):
/// * Response headers
/// * Status code (200)
/// * Status text ('OK')
///
/// As well as the response content in the following formats (available asynchronously):
/// * Dynamic object (ByteBuffer, Document, String, List<int>, etc.)
/// * Text (decoded and joined if necessary)
/// * Stream
///
/// ## [WProgress]
/// [WProgress] is a simple class that mimics [ProgressEvent] with an additional `percent`
/// property for convenience. [WProgress] is platform-agnostic, unlike [ProgressEvent].
///
/// ## [WHttpException]
/// [WHttpException] is a custom exception that is raised when a [w_http] request responds
/// with a non-successful status code.
library w_transport.lib.w_http;

export 'src/http/w_http.dart'
    show WHttp, WHttpException, WProgress, WRequest, WResponse;
