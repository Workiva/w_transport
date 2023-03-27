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

/// Always responds with a 404 Not Found.
class FourzerofourHandler extends Handler {
  FourzerofourHandler() : super() {
    enableCors();
  }

  Future<Null> notFound(HttpRequest request) async {
    request.response.statusCode = HttpStatus.notFound;
    setCorsHeaders(request);
  }

  @override
  Future<Null> delete(HttpRequest request) => notFound(request);

  @override
  Future<Null> get(HttpRequest request) => notFound(request);

  @override
  Future<Null> head(HttpRequest request) => notFound(request);

  @override
  Future<Null> options(HttpRequest request) => notFound(request);

  @override
  Future<Null> patch(HttpRequest request) => notFound(request);

  @override
  Future<Null> post(HttpRequest request) => notFound(request);

  @override
  Future<Null> put(HttpRequest request) => notFound(request);

  @override
  Future<Null> trace(HttpRequest request) => notFound(request);
}
