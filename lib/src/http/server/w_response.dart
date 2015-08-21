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
import 'dart:io';

import 'package:w_transport/src/http/common/w_response.dart';
import 'package:w_transport/src/http/common/util.dart' as util;
import 'package:w_transport/src/http/server/util.dart' as server_util;
import 'package:w_transport/src/http/w_progress.dart';
import 'package:w_transport/src/http/w_response.dart';

class ServerWResponse extends CommonWResponse implements WResponse {
  Encoding _encoding;

  ServerWResponse(HttpClientResponse response, Encoding this._encoding,
      int total, StreamController<WProgress> downloadProgressController)
      : super(
            response.statusCode,
            response.reasonPhrase,
            server_util.parseHeaders(response.headers),
            response.transform(server_util.wProgressListener(
                total, downloadProgressController)));

  Future<Object> asFuture() => asStream()
      .reduce((previous, element) => new List.from(previous)..addAll(element));
  Stream asStream() => source;
  Future<String> asText() =>
      asStream().transform(util.decodeAttempt(_encoding)).join('');
}
