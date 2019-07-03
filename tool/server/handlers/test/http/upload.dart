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

import 'package:dart2_constant/io.dart' as io_constant;
import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

import '../../../handler.dart';

/// Uploads one or many files
class UploadHandler extends Handler {
  UploadHandler() : super() {
    enableCors();
  }

  Future<void> upload(HttpRequest request) async {
    final contentType =
        ContentType.parse(request.headers.value('content-type'));
    final boundary = contentType.parameters['boundary'];
    final stream = request
        .transform(MimeMultipartTransformer(boundary))
        .map(HttpMultipartFormData.parse);

    await for (HttpMultipartFormData formData in stream) {
      if (formData.isText) {
        await formData.toList();
      } else {
        throw Exception('Unknown multipart formdata.');
      }
    }

    request.response.statusCode = io_constant.HttpStatus.ok;
    setCorsHeaders(request);
  }

  @override
  Future<void> delete(HttpRequest request) async => upload(request);

  @override
  Future<void> get(HttpRequest request) async => upload(request);

  @override
  Future<void> head(HttpRequest request) async => upload(request);

  @override
  Future<void> options(HttpRequest request) async => upload(request);

  @override
  Future<void> patch(HttpRequest request) async => upload(request);

  @override
  Future<void> post(HttpRequest request) async => upload(request);

  @override
  Future<void> put(HttpRequest request) async => upload(request);

  @override
  Future<void> trace(HttpRequest request) async => upload(request);
}
