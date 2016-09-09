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

import 'dart:async';
import 'dart:io';

import '../../../handler.dart';

/// Always responds with a 200 OK and reads the request body into memory to
/// verify that the body was sent successfully and the content-length was set
/// correctly. The response body then echos the request.
class EchoHandler extends Handler {
  EchoHandler() : super() {
    enableCors();
  }

  Future<Null> echo(HttpRequest request) async {
    request.response.statusCode = HttpStatus.OK;
    request.response.headers.contentType = request.headers.contentType;
    setCorsHeaders(request);
    await request.response.addStream(request);
  }

  @override
  Future<Null> copy(HttpRequest request) async => echo(request);

  @override
  Future<Null> delete(HttpRequest request) async => echo(request);

  @override
  Future<Null> get(HttpRequest request) async => echo(request);

  @override
  Future<Null> head(HttpRequest request) async => echo(request);

  @override
  Future<Null> options(HttpRequest request) async => echo(request);

  @override
  Future<Null> patch(HttpRequest request) async => echo(request);

  @override
  Future<Null> post(HttpRequest request) async => echo(request);

  @override
  Future<Null> put(HttpRequest request) async => echo(request);

  @override
  Future<Null> trace(HttpRequest request) async => echo(request);
}
