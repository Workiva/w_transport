/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.tool.server.handler;

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

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
  Future<shelf.Response> processRequest(shelf.Request request) async {
    Function handler;
    switch (request.method) {
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
        return new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
    }
    shelf.Response response = await handler(request);
    if (_corsEnabled) {
      response = response.change(headers: _getCorsHeaders(request));
    }
    return response;
  }

  /// Enable Cross Origin Resource Sharing support.
  /// Call this in the sub-class constructor.
  void enableCors({bool credentials: true, List<String> methods, String origin}) {
    _corsEnabled = true;
    _credentialsAllowed = credentials == true;
    _allowedMethods = (methods != null)
        ? methods
        : ['DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT', 'TRACE'];
    _allowedOrigin = (origin != null) ? origin : null;
  }

  /// Creates and returns a map of Access-Control headers based
  /// on the CORS settings configured in the call to [enableCors].
  Map<String, String> _getCorsHeaders(shelf.Request request) {
    Map<String, String> headers = {};

    // Use given allow origin, but default to allowing every origin (by using origin of request)
    String origin =
        _allowedOrigin != null ? _allowedOrigin : request.headers['Origin'];
    headers['Access-Control-Allow-Origin'] = origin;

    // Allow all headers (by using the requested headers)
    String requestHeaders = request.headers['Access-Control-Request-Headers'];
    if (requestHeaders != null) {
      headers['Access-Control-Allow-Headers'] = requestHeaders;
    }

    // Use given allow methods, but default to allowing all methods
    headers['Access-Control-Allow-Methods'] = _allowedMethods.join(', ');

    // Optionally allow credentials
    if (_credentialsAllowed) {
      headers['Access-Control-Allow-Credentials'] = 'true';
    }

    return headers;
  }

  /// RESTful method handlers. Override as necessary.
  Future<shelf.Response> delete(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  Future<shelf.Response> get(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  Future<shelf.Response> head(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  Future<shelf.Response> patch(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  Future<shelf.Response> post(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  Future<shelf.Response> put(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  Future<shelf.Response> trace(shelf.Request request) async =>
      new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);

  /// Handler for the OPTIONS request. For convenience, this returns
  /// 200 OK by default if CORS support has been enabled.
  Future<shelf.Response> options(shelf.Request request) async {
    if (_corsEnabled) return new shelf.Response.ok('');
    return new shelf.Response(HttpStatus.METHOD_NOT_ALLOWED);
  }
}
