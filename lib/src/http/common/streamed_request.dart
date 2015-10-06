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

library w_transport.src.http.common.streamed_request;

import 'dart:async';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/requests.dart';

abstract class CommonStreamedRequest extends CommonRequest
    implements StreamedRequest {
  CommonStreamedRequest() : super();
  CommonStreamedRequest.withClient(client) : super.withClient(client);

  Stream<List<int>> _body;

  int _contentLength;

  Stream<List<int>> get body => _body;

  set body(Stream<List<int>> byteStream) {
    verifyUnsent();
    _body = byteStream;
  }

  @override
  int get contentLength => _contentLength;

  @override
  set contentLength(int value) {
    verifyUnsent();
    _contentLength = value;
  }

  @override
  MediaType get defaultContentType =>
      new MediaType('text', 'plain', {'charset': encoding.name});

  @override
  Future<StreamedHttpBody> finalizeBody([body]) async {
    if (body != null) {
      if (body is Stream<List<int>>) {
        this.body = body;
      } else {
        throw new ArgumentError(
            'Streamed request body must be a Stream<List<int>>.');
      }
    }

    if (this.body == null) {
      this.body = new Stream.fromIterable([]);
    }
    return new StreamedHttpBody.fromByteStream(contentType, this.body,
        contentLength: contentLength);
  }
}
