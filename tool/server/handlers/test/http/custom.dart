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

/// Return a custom response dictated by the request.
class CustomHandler extends Handler {
  CustomHandler() : super() {
    enableCors();
  }

  @override
  Future<Null> get(HttpRequest request) async {
    request.response.statusCode =
        request.uri.queryParameters['status'] ?? HttpStatus.OK;
    request.response.headers.contentType = ContentType.TEXT;
    setCorsHeaders(request);
  }
}
