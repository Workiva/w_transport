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

library w_transport.src.http.mock.w_response;

import 'dart:async';
import 'dart:convert';

import 'package:w_transport/src/http/common/util.dart' as util;
import 'package:w_transport/src/http/common/w_response.dart';

import 'package:w_transport/src/http/w_response.dart';

class MockWResponse extends CommonWResponse implements WResponse {
  Encoding _encoding;

  MockWResponse(int status,
      {Map<String, String> headers, String statusText, body, Encoding encoding})
      : super(
            status,
            statusText != null ? statusText : _mapStatusToText(status),
            headers != null ? headers : {},
            new Stream.fromIterable([])),
        _encoding = encoding != null ? encoding : UTF8 {
    if (body != null) {
      update(body);
    }
  }

  MockWResponse.ok({Map<String, String> headers, String statusText, body})
      : this(200, headers: headers, statusText: statusText, body: body);

  MockWResponse.badRequest(
      {Map<String, String> headers, String statusText, body})
      : this(400, headers: headers, statusText: statusText, body: body);

  MockWResponse.unauthorized(
      {Map<String, String> headers, String statusText, body})
      : this(401, headers: headers, statusText: statusText, body: body);

  MockWResponse.forbidden(
      {Map<String, String> headers, String statusText, body})
      : this(403, headers: headers, statusText: statusText, body: body);

  MockWResponse.notFound({Map<String, String> headers, String statusText, body})
      : this(404, headers: headers, statusText: statusText, body: body);

  MockWResponse.methodNotAllowed(
      {Map<String, String> headers, String statusText, body})
      : this(405, headers: headers, statusText: statusText, body: body);

  MockWResponse.internalServerError(
      {Map<String, String> headers, String statusText, body})
      : this(500, headers: headers, statusText: statusText, body: body);

  MockWResponse.notImplemented(
      {Map<String, String> headers, String statusText, body})
      : this(501, headers: headers, statusText: statusText, body: body);

  MockWResponse.badGateway(
      {Map<String, String> headers, String statusText, body})
      : this(502, headers: headers, statusText: statusText, body: body);

  Future asFuture() => asStream().first;
  Stream asStream() => source;
  Future<String> asText() async {
    Object data =
        await asStream().transform(util.decodeAttempt(_encoding)).first;
    return data != null ? data.toString() : null;
  }
}

String _mapStatusToText(int status) {
  switch (status) {
    case 200:
      return 'OK';
    case 400:
      return 'BAD REQUEST';
    case 401:
      return 'UNAUTHORIZED';
    case 403:
      return 'FORBIDDEN';
    case 404:
      return 'NOT FOUND';
    case 405:
      return 'METHOD NOT ALLOWED';
    case 500:
      return 'INTERNAL SERVER ERROR';
    case 501:
      return 'NOT IMPLEMENTED';
    case 502:
      return 'BAD GATEWAY';
    default:
      return '';
  }
}
