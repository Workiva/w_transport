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

library w_transport.src.http.client.w_response;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:w_transport/src/http/common/util.dart' as util;
import 'package:w_transport/src/http/common/w_response.dart';
import 'package:w_transport/src/http/w_response.dart';

class ClientWResponse extends CommonWResponse implements WResponse {
  Encoding _encoding;

  ClientWResponse(HttpRequest request, Encoding this._encoding)
      : super(request.status, request.statusText, request.responseHeaders,
            new Stream.fromIterable([request.response]));

  Future<Object> asFuture() => asStream().first;
  Stream asStream() => source;
  Future<String> asText() async {
    Object data =
        await asStream().transform(util.decodeAttempt(_encoding)).first;
    return data != null ? data.toString() : null;
  }
}
