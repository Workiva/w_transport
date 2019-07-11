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

  Future<void> notFound(HttpRequest request) async {
    request.response.statusCode = HttpStatus.notFound;
    setCorsHeaders(request);
  }

  @override
  Future<void> delete(HttpRequest request) => notFound(request);

  @override
  Future<void> get(HttpRequest request) => notFound(request);

  @override
  Future<void> head(HttpRequest request) => notFound(request);

  @override
  Future<void> options(HttpRequest request) => notFound(request);

  @override
  Future<void> patch(HttpRequest request) => notFound(request);

  @override
  Future<void> post(HttpRequest request) => notFound(request);

  @override
  Future<void> put(HttpRequest request) => notFound(request);

  @override
  Future<void> trace(HttpRequest request) => notFound(request);
}
