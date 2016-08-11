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
import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/utils.dart' as http_utils;

import '../../../handler.dart';

/// Always responds with a 200 OK and dumps a reflection
/// of the request to the response body. This reflection
/// is a JSON payload that includes the request method,
/// request URL path, request headers, and request body.
class ReflectHandler extends Handler {
  ReflectHandler() : super() {
    enableCors();
  }

  Future reflect(HttpRequest request) async {
    Map<String, String> headers = {};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });

    Encoding encoding;
    if (request.headers.contentType == null) {
      encoding = LATIN1;
    } else {
      MediaType contentType = new MediaType(
          request.headers.contentType.primaryType,
          request.headers.contentType.subType,
          request.headers.contentType.parameters);
      encoding = http_utils.parseEncodingFromContentType(contentType,
          fallback: LATIN1);
    }

    Map reflection = {
      'method': request.method,
      'path': request.uri.path,
      'headers': headers,
      'body': await encoding.decodeStream(request),
    };

    request.response.statusCode = HttpStatus.OK;
    request.response.headers
        .set('content-type', 'application/json; charset=utf-8');
    setCorsHeaders(request);
    request.response.write(JSON.encode(reflection));
  }

  Future copy(HttpRequest request) async => reflect(request);
  Future delete(HttpRequest request) async => reflect(request);
  Future get(HttpRequest request) async => reflect(request);
  Future head(HttpRequest request) async => reflect(request);
  Future options(HttpRequest request) async => reflect(request);
  Future patch(HttpRequest request) async => reflect(request);
  Future post(HttpRequest request) async => reflect(request);
  Future put(HttpRequest request) async => reflect(request);
  Future trace(HttpRequest request) async => reflect(request);
}
