library w_transport.tool.server.handlers.test.http.upload;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

import 'package:w_transport/src/http/utils.dart' as http_utils;

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
