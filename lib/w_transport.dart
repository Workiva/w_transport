// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Platform-agnostic transport library for sending and receiving data over HTTP
/// and WebSocket. HTTP support includes plain-text, JSON, form-data, and
/// multipart data, as well as custom encoding. WebSocket support includes native
/// WebSockets in the browser and the VM with the option to use SockJS in the
/// browser.
///
///     import 'package:w_transport/w_transport.dart';
///
/// ## HTTP
///
/// To send HTTP requests, there are two options. For simple plain-text
/// requests, the static methods on the [Http] can be used.
///
///     Response response = await Http.get(Uri.parse('/ping'));
///
/// These static methods on [Http] require a URI but also take headers and a
/// plain-text body.
///
/// Alternatively, there are several request classes available that offer a
/// greater amount of control and help with sending different types of data:
///
/// - Plain-text request: [Request]
/// - JSON request: [JsonRequest]
/// - FormRequest: [FormRequest]
/// - MultipartRequest: [MultipartRequest]
///
///     // Plain-text request - supports plain-text body as a String or bytes.
///     // content-type: text/plain
///     Request request = new Request();
///
///     // JSON request - supports a Map or List as the request body.
///     // content-type: application/json
///     JsonRequest request = new JsonRequest();
///
///     // Form request - supports sending a Map of form fields
///     // content-type: application/www-form-urlencoded
///     FormRequest request = new FormRequest();
///
///     // Multipart request - supports sending a request with several parts,
///     // consisting of text fields and/or files.
///     MultipartRequest request = new MultipartRequest();
///
/// Each one of these requests shares the exact same API (see [BaseRequest]) for
/// everything that doesn't pertain to the request body. The request body API is
/// tailored to the type of request.
///
/// When sending a request, there are two options that dictate the type of
/// response that will be returned. The default request dispatch methods
/// (`get()`, `post()`, 'put()`, etc.) return a `Future` that resolves with an
/// instance of [Response]. This response object provides synchronous access to
/// the complete response body as plain-text, as bytes, or as JSON (if
/// decodable).
///
/// If the response body is exceptionally large or if you'd prefer to deal with
/// the response body in a streamed format, there are a set of request dispatch
/// methods that will return a `Future` that resolves with an instance of
/// [StreamedResponse]. These methods are the same as the above, with "stream"
/// prepended (`streamGet()`, `streamPost()`, `streamPut()`, etc.). This
/// response object provides synchronous access to the response metadata (status
/// code, headers, etc.), but do not load the entire response body into memory.
/// Instead, the response body is available as a stream of chunks of bytes.
///
/// ## WebSocket
///
/// The WebSocket API mirrors the dart:io WebSocket class, but works
/// for both client and server usage. If you've used the server-side
/// WebSocket, this is almost exactly the same.
///
/// To establish a WebSocket connection, use the static `connect()` method:
///
///     Uri wsUri = Uri.parse('ws://echo.websocket.org');
///     WSocket webSocket = await WSocket.connect(wsUri);
///
/// Once connected, add items to the WebSocket like a sink to send data to the
/// server, and listen to it like a stream to receive data from the server.
library w_transport;

// Transport Platforms
export 'package:w_transport/src/global_transport_platform.dart'
    show globalTransportPlatform, resetGlobalTransportPlatform;
export 'package:w_transport/src/transport_platform.dart'
    show TransportPlatform, TransportPlatformMissing;

// HTTP
export 'package:w_transport/src/http/auto_retry.dart'
    show RetryBackOff, RetryBackOffMethod;
export 'package:w_transport/src/http/base_request.dart' show BaseRequest;
export 'package:w_transport/src/http/client.dart'
    show Client; // ignore: deprecated_member_use
export 'package:w_transport/src/http/finalized_request.dart'
    show FinalizedRequest;
export 'package:w_transport/src/http/http.dart' show Http;
export 'package:w_transport/src/http/http_body.dart'
    show HttpBody, StreamedHttpBody;
export 'package:w_transport/src/http/http_interceptor.dart'
    show HttpInterceptor, RequestPayload, ResponsePayload;
export 'package:w_transport/src/http/http_client.dart' show HttpClient;
export 'package:w_transport/src/http/multipart_file.dart' show MultipartFile;
export 'package:w_transport/src/http/request_exception.dart'
    show RequestException;
export 'package:w_transport/src/http/request_progress.dart'
    show RequestProgress;
export 'package:w_transport/src/http/requests.dart'
    show FormRequest, JsonRequest, MultipartRequest, Request, StreamedRequest;
export 'package:w_transport/src/http/response.dart'
    show BaseResponse, Response, StreamedResponse;
export 'package:w_transport/src/http/response_format_exception.dart'
    show ResponseFormatException;

// WebSocket
export 'package:w_transport/src/web_socket/w_socket.dart'
    show WSocket; // ignore: deprecated_member_use
export 'package:w_transport/src/web_socket/w_socket_close_event.dart'
    show WSocketCloseEvent; // ignore: deprecated_member_use
export 'package:w_transport/src/web_socket/w_socket_exception.dart'
    show WSocketException; // ignore: deprecated_member_use
export 'package:w_transport/src/web_socket/web_socket_exception.dart'
    show WebSocketException;
export 'package:w_transport/src/web_socket/web_socket.dart' show WebSocket;
export 'package:w_transport/src/web_socket/global_web_socket_monitor.dart'
    show GlobalWebSocketMonitor, WebSocketConnectEvent;

// Third-party
export 'package:http_parser/http_parser.dart' show MediaType;
