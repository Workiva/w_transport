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

import 'package:w_transport/w_transport.dart';

/// Base class representing an interceptor that can be registered with a
/// HttpClient instance to intercept HTTP requests and responses in order to
/// modify or augment them prior to dispatch and delivery, respectively.
class HttpInterceptor {
  Future<RequestPayload> interceptRequest(RequestPayload payload) async {
    return payload;
  }

  Future<ResponsePayload> interceptResponse(ResponsePayload payload) async {
    return payload;
  }
}

/// Representation of a request payload. Currently only contains the request
/// instance, but may contain more contextual information in the future.
///
/// The [request] instance can be type checked and cast to [FormRequest],
/// [JsonRequest], [MultipartRequest], [Request], or [StreamedRequest] as
/// necessary.
class RequestPayload {
  final BaseRequest request;
  RequestPayload(this.request);
}

/// Representation of a response payload. Contains the [response] instance, the
/// finalized [request] that initiated the response, and an [exception] if one
/// occurred.
///
/// The [response] instance can be type checked and cast to [Response] or
/// [StreamedResponse] as necessary.
class ResponsePayload {
  final FinalizedRequest request;
  BaseResponse response;
  final RequestException exception;
  ResponsePayload(this.request, this.response, [this.exception]);
}

/// Representation of a pathway on which..
///
/// 1. payloads of a certain type travel, and
/// 2. a set of interceptors can be attached.
///
/// As a payload travels a pathway, each interceptor (in the order they were
/// attached) has the opportunity to process, evaluate, modify, augment, or
/// replace the payload. This interception can be synchronous or asynchronous -
/// the pathway ensures that each interceptor is applied serially.
///
/// Simply put, a pathway accepts a payload and asynchronously returns a
/// payload.
class Pathway<T> {
  List<Function> _interceptors = [];

  bool get hasInterceptors => _interceptors.isNotEmpty;

  void addInterceptor(/* T | Future<T> */ interceptor(T payload)) {
    _interceptors.add(interceptor);
  }

  Future<T> process(T payload) async {
    for (final interceptor in _interceptors) {
      final result = interceptor(payload);
      if (result is Future<T>) {
        payload = await result;
      } else if (result is T) {
        payload = result;
      } else {
        final msg = 'Interceptor returned a value of the incorrect type.\n'
            '  Expected: ${T.runtimeType}\n'
            '  Actual:   ${result.runtimeType}';
        throw new Exception(msg);
      }
    }
    return payload;
  }
}
