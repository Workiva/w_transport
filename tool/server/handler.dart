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

library w_transport.tool.server.handler;

import 'dart:async';
import 'dart:io';

/// Base request handler class that enables CORS by default.
/// Should be subclassed and the handleRequest() method must be implemented.
abstract class Handler {
  List<String> _allowedMethods;
  String _allowedOrigin;
  bool _credentialsAllowed;
  bool _corsEnabled;

  Handler() : _corsEnabled = false;

  /// Main entry point for request handling.
  /// Sub-classes should implement only the necessary REST method handlers.
  Future processRequest(HttpRequest request) async {
    Function handler;
    switch (request.method) {
      case 'COPY':
        handler = copy;
        break;
      case 'DELETE':
        handler = delete;
        break;
      case 'GET':
        handler = get;
        break;
      case 'HEAD':
        handler = head;
        break;
      case 'OPTIONS':
        handler = options;
        break;
      case 'PATCH':
        handler = options;
        break;
      case 'POST':
        handler = post;
        break;
      case 'PUT':
        handler = post;
        break;
      case 'TRACE':
        handler = trace;
        break;
      default:
        request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
    }
    await handler(request);
    request.response.close();
  }

  /// Enable Cross Origin Resource Sharing support.
  /// Call this in the sub-class constructor.
  void enableCors(
      {bool credentials: true, List<String> methods, String origin}) {
    _corsEnabled = true;
    _credentialsAllowed = credentials == true;
    _allowedMethods = (methods != null)
        ? methods
        : ['COPY', 'DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT', 'TRACE'];
    _allowedOrigin = (origin != null) ? origin : null;
  }

  /// Creates and sets the Access-Control headers based on the CORS settings
  /// configured in the call to [enableCors].
  void setCorsHeaders(HttpRequest request) {
    // Use given allow origin, but default to allowing every origin (by using origin of request)
    String origin = _allowedOrigin != null
        ? _allowedOrigin
        : request.headers.value('Origin');
    request.response.headers.set('Access-Control-Allow-Origin', origin);

    // Allow all headers (by using the requested headers)
    List<String> requestHeaders =
        request.headers['Access-Control-Request-Headers'];
    if (requestHeaders != null) {
      requestHeaders.forEach((h) {
        request.response.headers.add('Access-Control-Allow-Headers', h);
      });
    }

    // Use given allow methods, but default to allowing all methods
    _allowedMethods.forEach((m) {
      request.response.headers.add('Access-Control-Allow-Methods', m);
    });

    // Optionally allow credentials
    if (_credentialsAllowed) {
      request.response.headers.set('Access-Control-Allow-Credentials', 'true');
    }
  }

  /// RESTful method handlers. Override as necessary.
  Future copy(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future delete(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future get(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future head(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future patch(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future post(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future put(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
  Future trace(HttpRequest request) async =>
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;

  /// Handler for the OPTIONS request. For convenience, this returns
  /// 200 OK by default if CORS support has been enabled.
  Future options(HttpRequest request) async {
    if (_corsEnabled) {
      request.response.statusCode = HttpStatus.OK;
      setCorsHeaders(request);
    } else {
      request.response.statusCode = HttpStatus.METHOD_NOT_ALLOWED;
      setCorsHeaders(request);
    }
  }
}

abstract class WebSocketHandler extends Handler {
  @override
  Future processRequest(HttpRequest request) async {
    WebSocket webSocket = await WebSocketTransformer.upgrade(request);
    onConnection(webSocket);
  }

  void onConnection(WebSocket webSocket);
}
