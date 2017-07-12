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
import 'dart:convert';
import 'dart:html' hide Client;

import 'package:http_parser/http_parser.dart'
    show CaseInsensitiveMap, MediaType;

import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/request_mixin.dart';
import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/multipart_file.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;
import 'package:w_transport/src/transport_platform.dart';

class BrowserMultipartRequest extends CommonRequest
    with BrowserRequestMixin
    implements MultipartRequest {
  BrowserMultipartRequest(TransportPlatform transportPlatform)
      : super(transportPlatform);
  // ignore: deprecated_member_use
  BrowserMultipartRequest.fromClient(Client wTransportClient)
      : super.fromClient(wTransportClient, null);

  Map<String, String> _fields = {};

  Map<String, Blob> _files = {};

  @override
  int get contentLength {
    // Let the browser set the content-length.
    return null;
  }

  @override
  set contentLength(int contentLength) {
    throw new UnsupportedError(
        'The content-length of a multipart request cannot be set manually.');
  }

  @override
  MediaType get defaultContentType {
    // Let the browser set the content-type.
    return null;
  }

  @override
  Map<String, String> get fields =>
      isSent ? new Map<String, String>.unmodifiable(_fields) : _fields;

  @override
  set fields(Map<String, String> fields) {
    verifyUnsent();
    _fields = new Map<String, String>.from(fields);
  }

  @override
  Map<String, dynamic> get files {
    if (isSent) return new Map<String, Blob>.unmodifiable(_files);
    return _files;
  }

  @override
  set files(Map<String, dynamic> files) {
    verifyUnsent();
    _files = new Map<String, Blob>.from(files);
  }

  @override
  MultipartRequest clone() {
    final MultipartRequest requestClone = super.clone();
    return requestClone
      ..fields = fields
      ..files = files;
  }

  @override
  Map<String, String> finalizeHeaders() {
    final headers =
        new CaseInsensitiveMap<String>.from(super.finalizeHeaders());

    // Remove the content-type header to allow the browser to set it.
    headers.remove('content-type');

    return new Map<String, String>.unmodifiable(headers);
  }

  @override
  Future<FormDataBody> finalizeBody([dynamic body]) async {
    if (body != null) {
      throw new UnsupportedError(
          'The body of a Multipart request must be set via `fields` and/or `files`.');
    }

    final formData = new FormData();

    // Add each text field.
    fields.forEach((name, value) {
      if (http_utils.isAsciiOnly(value)) {
        formData.append(name, value);
      } else {
        final contentType =
            new MediaType('text', 'plain', {'charset': UTF8.name});
        final blob = new Blob([UTF8.encode(value)], contentType.toString());
        formData.appendBlob(name, blob);
      }
    });
    fields.forEach(formData.append);

    // Add each blob/file.
    final additions = <Future>[];
    files.forEach((name, value) {
      additions.add(() async {
        if (value is File) {
          formData.appendBlob(name, value, value.name);
        } else if (value is Blob) {
          formData.appendBlob(name, value);
        } else if (value is MultipartFile) {
          final contentType = value.contentType?.toString();
          final blob = new Blob(await value.byteStream.toList(), contentType);
          formData.appendBlob(name, blob, value.filename);
        }
      }());
    });
    await Future.wait(additions);

    return new FormDataBody(formData);
  }
}
