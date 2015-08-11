library w_transport.src.http.client.w_response;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:w_transport/src/http/common/w_response.dart';
import 'package:w_transport/src/http/common/util.dart' as util;
import 'package:w_transport/src/http/server/util.dart' as server_util;
import 'package:w_transport/src/http/w_progress.dart';
import 'package:w_transport/src/http/w_response.dart';

class ServerWResponse extends CommonWResponse implements WResponse {
  Encoding _encoding;

  ServerWResponse(HttpClientResponse response, Encoding this._encoding,
      int total, StreamController<WProgress> downloadProgressController)
      : super(response.statusCode, response.reasonPhrase,
          server_util.parseHeaders(response.headers), response.transform(
              server_util.wProgressListener(
                  total, downloadProgressController)));

  Future<Object> asFuture() => asStream()
      .reduce((previous, element) => new List.from(previous)..addAll(element));
  Stream asStream() => source;
  Future<String> asText() =>
      asStream().transform(util.decodeAttempt(_encoding)).join('');
}
