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
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/transport_platform.dart';

abstract class CommonPlainTextRequest extends CommonRequest implements Request {
  CommonPlainTextRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  CommonPlainTextRequest.fromClient(Client wTransportClient, client)
      : super.fromClient(wTransportClient, client);

  String _body;

  Uint8List _bodyBytes;

  @override
  String get body {
    if (_body != null) return _body;
    if (_bodyBytes != null) {
      _body = encoding.decode(_bodyBytes);
      return _body;
    }
    return '';
  }

  @override
  set body(String value) {
    verifyUnsent();
    _body = value;
    _bodyBytes = null;
  }

  @override
  Uint8List get bodyBytes {
    if (_bodyBytes != null) return _bodyBytes;
    if (_body != null) {
      _bodyBytes = encoding.encode(_body);
      return _bodyBytes;
    }
    return new Uint8List.fromList([]);
  }

  @override
  set bodyBytes(List<int> bytes) {
    verifyUnsent();
    _bodyBytes = bytes;
    _body = null;
  }

  @override
  int get contentLength => bodyBytes.length;

  @override
  MediaType get defaultContentType =>
      new MediaType('text', 'plain', {'charset': encoding.name});

  @override
  Request clone() {
    final Request requestClone = super.clone();
    if (_body != null) {
      requestClone.body = body;
    } else if (_bodyBytes != null) {
      requestClone.bodyBytes = bodyBytes;
    }
    return requestClone;
  }

  @override
  Future<HttpBody> finalizeBody([dynamic body]) async {
    if (body != null) {
      if (body is String) {
        this.body = body;
      } else if (body is List<int>) {
        this.bodyBytes = body;
      } else {
        throw new ArgumentError(
            'Plain-text request body must be either a String or List<int>.');
      }
    }

    return new HttpBody.fromBytes(contentType, bodyBytes);
  }
}
