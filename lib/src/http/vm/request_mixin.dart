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

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/request_progress.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/src/http/vm/utils.dart' as vm_utils;

abstract class VMRequestMixin implements BaseRequest, CommonRequest {
  HttpClient _client;

  /// Whether or not this request is the only request that will be sent by its
  /// HTTP client. If that is the case, the client will have to be closed
  /// immediately after sending.
  bool _isSingle;

  HttpClientRequest _request;

  @override
  void abortRequest() {
    _request?.close();
  }

  @override
  void cleanUp() {
    if (_isSingle) {
      _client?.close();
    }
  }

  @override
  Future<Null> openRequest([Object client]) async {
    final HttpClient httpClient = client;
    if (httpClient != null) {
      _client = httpClient;
      _isSingle = false;
    } else {
      _client = new HttpClient();
      _isSingle = true;
    }
    _request = await _client.openUrl(method, uri);
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse: false}) async {
    streamResponse ??= false;

    if (finalizedRequest.headers != null) {
      finalizedRequest.headers.forEach(_request.headers.set);
    }

    // Allow the caller to configure the request.
    Object configurationResult;
    if (configureFn != null) {
      configurationResult = configureFn(_request);
    }

    // Wait for the configuration if applicable.
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }

    if (finalizedRequest.body.contentLength != null) {
      _request.contentLength = finalizedRequest.body.contentLength;
    }

    if (finalizedRequest.body is StreamedHttpBody) {
      final StreamedHttpBody body = finalizedRequest.body;
      // Use a byte stream progress listener to transform the request body such
      // that it produces a stream of progress events.
      final progressListener = new http_utils.ByteStreamProgressListener(
          body.byteStream,
          total: finalizedRequest.body.contentLength);

      // Add the now-transformed request body stream.
      await _request.addStream(progressListener.byteStream);

      // Map the progress stream back to this request's upload progress.
      progressListener.progressStream.listen(uploadProgressController.add);
    } else {
      final HttpBody body = finalizedRequest.body;
      // The entire request body is available immediately as bytes.
      _request.add(body.asBytes());

      // Since the entire request body has already been sent, the upload
      // progress stream can be "completed" by adding a single progress event.
      RequestProgress progress;
      if (_request.contentLength == 0) {
        progress = new RequestProgress(0, 0);
      } else {
        progress =
            new RequestProgress(_request.contentLength, _request.contentLength);
      }
      uploadProgressController.add(progress);
    }

    // Close the request now that data has been sent and wait for the response.
    final response = await _request.close();

    // Use a byte stream progress listener to transform the response stream such
    // that it produces a stream of progress events.
    final progressListener = new http_utils.ByteStreamProgressListener(response,
        total: response.contentLength);

    // Response body now resides in this transformed byte stream.
    final byteStream = progressListener.byteStream;

    // Map the progress stream back to this request's download progress.
    progressListener.progressStream.listen(downloadProgressController.add);

    // Parse the response headers into a platform-independent format.
    final responseHeaders = vm_utils.parseServerHeaders(response.headers);

    // By default, responses in the VM are streamed. If this is the desired
    // format, simply return it.
    final streamedResponse = new StreamedResponse.fromByteStream(
        response.statusCode,
        response.reasonPhrase,
        responseHeaders,
        byteStream);
    if (streamResponse) return streamedResponse;

    // Otherwise, the byte stream needs to be reduced to a single list of bytes.
    return new Response.fromBytes(response.statusCode, response.reasonPhrase,
        responseHeaders, await streamedResponse.body.toBytes());
  }
}
