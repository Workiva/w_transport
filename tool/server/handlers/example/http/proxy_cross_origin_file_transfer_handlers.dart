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

import 'package:w_transport/w_transport.dart' as transport;
import 'package:w_transport/vm.dart' show vmTransportPlatform;

import '../../../handler.dart';

String pathPrefix = '/proxy/example/http/cross_origin_file_transfer';
Map<String, Handler> proxyExampleHttpCrossOriginFileTransferRoutes = {
  '$pathPrefix/files/': FilesProxy(),
  '$pathPrefix/download': DownloadProxy(),
  '$pathPrefix/upload': UploadProxy()
};

Uri filesEndpoint = Uri.parse(
    'http://localhost:8024/example/http/cross_origin_file_transfer/files/');
Uri uploadEndpoint = Uri.parse(
    'http://localhost:8024/example/http/cross_origin_file_transfer/upload');
Uri downloadEndpoint = Uri.parse(
    'http://localhost:8024/example/http/cross_origin_file_transfer/download');

transport.HttpClient client;
transport.HttpClient getHttpClient() {
  if (client == null) {
    client = transport.HttpClient(transportPlatform: vmTransportPlatform);
  }
  return client;
}

class FilesProxy extends Handler {
  FilesProxy() : super() {
    enableCors();
  }

  @override
  Future<Null> get(HttpRequest request) async {
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });
    final proxyRequest = getHttpClient().newRequest()..headers = headers;

    final proxyResponse = await proxyRequest.streamGet(uri: filesEndpoint);
    request.response.statusCode = HttpStatus.ok;
    setCorsHeaders(request);
    proxyResponse.headers.forEach((h, v) {
      request.response.headers.set(h, v);
    });
    await request.response.addStream(proxyResponse.body.byteStream);
  }

  @override
  Future<Null> delete(HttpRequest request) async {
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });
    final proxyRequest = getHttpClient().newRequest()..headers = headers;

    final proxyResponse = await proxyRequest.streamDelete(uri: filesEndpoint);
    request.response.statusCode = HttpStatus.ok;
    setCorsHeaders(request);
    proxyResponse.headers.forEach((h, v) {
      request.response.headers.set(h, v);
    });
    await request.response.addStream(proxyResponse.body.byteStream);
  }
}

class UploadProxy extends Handler {
  UploadProxy() : super() {
    enableCors();
  }

  @override
  Future<Null> post(HttpRequest request) async {
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });
    final contentType =
        transport.MediaType.parse(request.headers.value('content-type'));
    final proxyRequest = getHttpClient().newStreamedRequest()
      ..headers = headers
      ..body = request.cast<List<int>>()
      ..contentLength = request.contentLength
      ..contentType = contentType;

    proxyRequest.uploadProgress.listen((progress) {
      print('Uploading: ${progress.percent}%');
    });

    transport.StreamedResponse proxyResponse;
    try {
      proxyResponse = await proxyRequest.streamPost(uri: uploadEndpoint);
      request.response.statusCode = HttpStatus.ok;
      setCorsHeaders(request);
      proxyResponse.headers.forEach((h, v) {
        request.response.headers.set(h, v);
      });
      await request.response.addStream(proxyResponse.body.byteStream);
    } on HttpException catch (e) {
      proxyRequest.abort(e);
      request.response.statusCode = HttpStatus.internalServerError;
      setCorsHeaders(request);
    }
  }
}

class DownloadProxy extends Handler {
  DownloadProxy() : super() {
    enableCors();
  }

  @override
  Future<Null> get(HttpRequest request) async {
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });
    final proxyRequest = getHttpClient().newRequest()
      ..uri = downloadEndpoint
      ..query = request.uri.query
      ..headers = headers;

    proxyRequest.downloadProgress.listen((progress) {
      print(
          'Downloading ${request.uri.queryParameters['file']}: ${progress.percent}%');
    });

    transport.StreamedResponse proxyResponse;
    try {
      proxyResponse = await proxyRequest.streamGet();
      request.response.statusCode = HttpStatus.ok;
      setCorsHeaders(request);
      proxyResponse.headers.forEach((h, v) {
        request.response.headers.set(h, v);
      });
      await request.response.addStream(proxyResponse.body.byteStream);
    } on HttpException catch (e) {
      proxyRequest.abort(e);
      request.response.statusCode = HttpStatus.internalServerError;
      setCorsHeaders(request);
    }
  }
}
