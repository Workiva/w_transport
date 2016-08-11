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

import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

import '../../../handler.dart';

/// Uploads one or many files
class UploadHandler extends Handler {
  UploadHandler() : super() {
    enableCors();
  }

  Future upload(HttpRequest request) async {
    ContentType contentType =
        ContentType.parse(request.headers.value('content-type'));
    String boundary = contentType.parameters['boundary'];
    Stream stream = request
        .transform(new MimeMultipartTransformer(boundary))
        .map(HttpMultipartFormData.parse);

    await for (HttpMultipartFormData formData in stream) {
      if (formData.isText) {
        await formData.toList();
      } else {
        throw new Exception('Unknown multipart formdata.');
      }
    }

    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
  }

  Future delete(HttpRequest request) async => upload(request);
  Future get(HttpRequest request) async => upload(request);
  Future head(HttpRequest request) async => upload(request);
  Future options(HttpRequest request) async => upload(request);
  Future patch(HttpRequest request) async => upload(request);
  Future post(HttpRequest request) async => upload(request);
  Future put(HttpRequest request) async => upload(request);
  Future trace(HttpRequest request) async => upload(request);
}
