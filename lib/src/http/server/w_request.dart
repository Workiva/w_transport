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

library w_transport.src.http.server.w_request;

import 'dart:async';
import 'dart:io';

import 'package:w_transport/src/http/common/util.dart' show encodeAttempt;
import 'package:w_transport/src/http/common/w_request.dart';
import 'package:w_transport/src/http/server/util.dart' show progressListener;
import 'package:w_transport/src/http/server/w_response.dart';
import 'package:w_transport/src/http/w_request.dart';
import 'package:w_transport/src/http/w_response.dart';

class ServerWRequest extends CommonWRequest implements WRequest {
  HttpClient _client;

  /// Whether or not this request is the only request that will be
  /// sent by its HTTP client. If that is the case, the client
  /// will have to be closed immediately after sending.
  final bool _isSingle;

  HttpClientRequest _request;

  ServerWRequest()
      : _client = new HttpClient(),
        _isSingle = true;

  ServerWRequest.withClient(HttpClient this._client) : _isSingle = false;

  void abortRequest() {
    if (_request != null) {
      _request.close();
    }
  }

  @override
  void cleanUp() {
    if (_isSingle && _client != null) {
      _client.close();
    }
  }

  Future openRequest() async {
    _request = await _client.openUrl(method, uri);
  }

  Future<WResponse> fetchResponse() async {
    if (headers != null) {
      headers.forEach(_request.headers.set);
    }

    // Allow the caller to configure the request.
    dynamic configurationResult;
    if (configureFn != null) {
      configurationResult = configureFn(_request);
    }

    // Wait for the configuration if applicable.
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }

    // If supplied, convert request data to a stream and send.
    Stream dataStream;
    if (data != null) {
      if (data is String) {
        dataStream = new Stream.fromIterable([encoding.encode(data)]);
      } else {
        dataStream = (data as Stream).transform(encodeAttempt(encoding));
      }

      _request.contentLength = contentLength != null ? contentLength : -1;
      await _request.addStream(dataStream.transform(
          progressListener(_request.contentLength, uploadProgressController)));
    } else {
      _request.contentLength = 0;
    }

    // Close the request now that data has been sent and wait for the response.
    HttpClientResponse response = await _request.close();
    return new ServerWResponse(
        response, encoding, response.contentLength, downloadProgressController);
  }

  void validateDataType() {
    if (data is! String && data is! Stream && data != null) {
      throw new ArgumentError('WRequest body must be a String or a Stream.');
    }
  }
}
