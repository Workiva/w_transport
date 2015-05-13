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

library w_transport.tool.server.handlers.test.http.reflect_handler;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;

import '../../../handler.dart';

/// Always responds with a 200 OK and dumps a reflection
/// of the request to the response body. This reflection
/// is a JSON payload that includes the request method,
/// request URL path, request headers, and request body.
class ReflectHandler extends Handler {
  ReflectHandler() : super() {
    enableCors();
  }

  Future<shelf.Response> reflect(shelf.Request request) async {
    Map reflection = {
      'method': request.method,
      'path': request.url.path,
      'headers': request.headers,
      'body': await request.readAsString(),
    };

    return new shelf.Response.ok(JSON.encode(reflection));
  }

  Future<shelf.Response> delete(shelf.Request request) async =>
      reflect(request);
  Future<shelf.Response> get(shelf.Request request) async => reflect(request);
  Future<shelf.Response> head(shelf.Request request) async => reflect(request);
  Future<shelf.Response> options(shelf.Request request) async =>
      reflect(request);
  Future<shelf.Response> patch(shelf.Request request) async => reflect(request);
  Future<shelf.Response> post(shelf.Request request) async => reflect(request);
  Future<shelf.Response> put(shelf.Request request) async => reflect(request);
  Future<shelf.Response> trace(shelf.Request request) async => reflect(request);
}
