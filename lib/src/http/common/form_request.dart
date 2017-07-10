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
import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/src/transport_platform.dart';

abstract class CommonFormRequest extends CommonRequest implements FormRequest {
  CommonFormRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  CommonFormRequest.fromClient(Client wTransportClient, client)
      : super.fromClient(wTransportClient, client);

  Map<String, dynamic> _fields = {};

  @override
  int get contentLength => _encodedQuery.length;

  @override
  MediaType get defaultContentType => new MediaType(
      'application', 'x-www-form-urlencoded', {'charset': encoding.name});

  @override
  Map<String, dynamic> get fields =>
      isSent ? new Map<String, dynamic>.unmodifiable(_fields) : _fields;

  @override
  set fields(Map<String, dynamic> fields) {
    verifyUnsent();
    _fields = fields ?? {};
  }

  Uint8List get _encodedQuery {
    fields.forEach((key, value) {
      if (value is! String && value is! Iterable<String>) {
        throw new ArgumentError('FormRequest: value of "$key" field must be of '
            'type `String` or `Iterable<String>`');
      }
    });
    return encoding.encode(http_utils.mapToQuery(fields, encoding: encoding));
  }

  @override
  FormRequest clone() {
    final FormRequest requestClone = super.clone();
    return requestClone..fields = fields;
  }

  @override
  Future<HttpBody> finalizeBody([dynamic body]) async {
    if (body != null) {
      if (body is Map<String, dynamic>) {
        this.fields = body;
      } else {
        throw new ArgumentError.value(
            body, 'body', 'Body must be of type Map<String, dynamic>');
      }
    }
    return new HttpBody.fromBytes(contentType, _encodedQuery,
        fallbackEncoding: encoding);
  }
}
