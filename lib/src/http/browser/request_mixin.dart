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
import 'dart:html';
import 'dart:typed_data';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/utils.dart' as browser_utils;
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/request_exception.dart';
import 'package:w_transport/src/http/response.dart';

abstract class BrowserRequestMixin implements BaseRequest, CommonRequest {
  HttpRequest? _request;

  @override
  void abortRequest() {
    _request?.abort();
  }

  @override
  Future<Null> openRequest([_]) async {
    _request = HttpRequest();
    _request!.open(method!, uri.toString());
  }

  @override
  Future<BaseResponse> sendRequestAndFetchResponse(
      FinalizedRequest finalizedRequest,
      {bool streamResponse = false}) async {
    final c = Completer<BaseResponse>();
    final request = _request!;
    final finalizedResponseType = responseType;

    // Add request headers.
    final headersToAdd = Map<String, String>.from(finalizedRequest.headers);
    headersToAdd.remove('connection');
    headersToAdd.remove('content-length');
    headersToAdd.forEach(request.setRequestHeader);

    if (withCredentials) {
      request.withCredentials = true;
    }

    // Pipe onProgress events to the progress controllers.

    // ignore: unawaited_futures
    request.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(downloadProgressController);

    // ignore: unawaited_futures
    request.upload.onProgress
        .transform(browser_utils.transformProgressEvents)
        .pipe(uploadProgressController);

    // Listen for request completion/errors.
    request.onLoad.listen((event) {
      if (!c.isCompleted) {
        c.complete(_createResponse(
            responseType: finalizedResponseType,
            streamResponse: streamResponse));
      }
    });
    Future<Null> onError(Object error) async {
      if (!c.isCompleted) {
        final response = await _createResponse(
            responseType: finalizedResponseType,
            streamResponse: streamResponse);
        error = RequestException(method, uri, this, response, error);
        c.completeError(error, StackTrace.current);
      }
    }

    request.onError.listen(onError);
    request.onAbort.listen(onError);

    if (streamResponse == true) {
      request.responseType = 'blob';
    } else if (finalizedResponseType?.isNotEmpty == true) {
      request.responseType = finalizedResponseType!;
    }

    // Allow the caller to configure the request.
    Object? configurationResult;
    if (configureFn != null) {
      configurationResult = configureFn!(request);
    }

    // Wait for the configuration if applicable before sending the request.
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }

    if (finalizedRequest.body is HttpBody) {
      HttpBody body = finalizedRequest.body as HttpBody;
      request.send(body.asBytes().buffer);
    } else if (finalizedRequest.body is StreamedHttpBody) {
      StreamedHttpBody body = finalizedRequest.body as StreamedHttpBody;
      request.send(await body.toBytes());
    } else if (finalizedRequest.body is FormDataBody) {
      FormDataBody body = finalizedRequest.body as FormDataBody;
      request.send(body.formData);
    }
    return await c.future;
  }

  Future<BaseResponse> _createResponse(
      {String? responseType, bool streamResponse = false}) async {
    BaseResponse response;
    final request = _request!;
    if (streamResponse) {
      final result = Completer<List<int>>();
      final reader = FileReader();
      // ignore: unawaited_futures
      reader.onLoad.first.then((_) {
        result.complete(reader.result as FutureOr<List<int>>?);
      });
      // ignore: unawaited_futures
      reader.onError.first.then(result.completeError);
      reader.readAsArrayBuffer(request.response ?? Blob([]));
      final bytes = await result.future;
      final byteStream = Stream.fromIterable([bytes]);
      response = StreamedResponse.fromByteStream(
        request.status!,
        request.statusText ?? '',
        request.responseHeaders,
        byteStream,
      );
    } else if (responseType == 'arraybuffer') {
      final buffer = request.response as ByteBuffer?;
      final bytes = buffer != null ? Uint8List.view(buffer) : Uint8List(0);
      response = Response.fromBytes(
        request.status!,
        request.statusText ?? '',
        request.responseHeaders,
        bytes,
      );
    } else {
      response = Response.fromString(
        request.status!,
        request.statusText ?? '',
        request.responseHeaders,
        request.responseText ?? '',
      );
    }
    return response;
  }
}
