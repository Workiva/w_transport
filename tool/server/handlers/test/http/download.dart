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

import '../../../handler.dart';

/// Always responds with a 200 OK and send a large
/// file in the response body to simulate a download.
class DownloadHandler extends Handler {
  DownloadHandler() : super() {
    enableCors();
  }

  Future<Null> download(HttpRequest request) async {
    final file = File('tool/server/handlers/test/http/file.txt');
    final downloadStream = file.openRead();
    request.response.statusCode = io_constant.HttpStatus.ok;
    request.response.headers
        .set('content-length', file.lengthSync().toString());
    request.response.headers.set('content-type', 'text/plain; charset=utf-8');
    setCorsHeaders(request);
    await request.response.addStream(downloadStream);
  }

  @override
  Future<Null> copy(HttpRequest request) async => download(request);

  @override
  Future<Null> delete(HttpRequest request) async => download(request);

  @override
  Future<Null> get(HttpRequest request) async => download(request);

  @override
  Future<Null> head(HttpRequest request) async => download(request);

  @override
  Future<Null> options(HttpRequest request) async => download(request);

  @override
  Future<Null> patch(HttpRequest request) async => download(request);

  @override
  Future<Null> post(HttpRequest request) async => download(request);

  @override
  Future<Null> put(HttpRequest request) async => download(request);

  @override
  Future<Null> trace(HttpRequest request) async => download(request);
}
