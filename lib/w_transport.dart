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

/// A fluent-style, platform-agnostic transport library.
/// Currently supports HTTP and WebSocket.
///
/// The HTTP API features simple request construction and response
/// handling, with the option to configure the outgoing request
/// for more advanced use cases.
///
/// The WebSocket API mirrors the dart:io WebSocket class, but works
/// for both client and server usage. If you've used the server-side
/// WebSocket, this is almost exactly the same. Add items to it like
/// a sink to send data to the server, and listen to it like a stream
/// to receive data from the server.
library w_transport.w_http;

export 'package:w_transport/src/http/w_http.dart' show WHttp;
export 'package:w_transport/src/http/w_http_exception.dart' show WHttpException;
export 'package:w_transport/src/http/w_progress.dart' show WProgress;
export 'package:w_transport/src/http/w_request.dart' show WRequest;
export 'package:w_transport/src/http/w_response.dart' show WResponse;

export 'package:w_transport/src/web_socket/w_socket.dart' show WSocket;
export 'package:w_transport/src/web_socket/w_socket_exception.dart'
    show WSocketException;
