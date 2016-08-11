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

abstract class CommonFormRequest extends CommonRequest implements FormRequest {
  CommonFormRequest() : super();
  CommonFormRequest.fromClient(Client wTransportClient, client)
      : super.fromClient(wTransportClient, client);

  Map<String, dynamic> _fields = {};

  @override
  int get contentLength => _encodedQuery.length;

  @override
  MediaType get defaultContentType => new MediaType(
      'application', 'x-www-form-urlencoded', {'charset': encoding.name});

  Map<String, dynamic> get fields =>
      isSent ? new Map.unmodifiable(_fields) : _fields;

  set fields(Map<String, dynamic> fields) {
    verifyUnsent();
    if (fields == null) {
      fields = {};
    }
    _fields = fields;
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
    return (super.clone() as FormRequest)..fields = fields;
  }

  @override
  Future<HttpBody> finalizeBody([body]) async {
    if (body != null) {
      this.fields = body;
    }
    return new HttpBody.fromBytes(contentType, _encodedQuery,
        fallbackEncoding: encoding);
  }
}
