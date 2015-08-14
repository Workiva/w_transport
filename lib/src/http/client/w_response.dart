library w_transport.src.http.client.w_response;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:w_transport/src/http/common/util.dart' as util;
import 'package:w_transport/src/http/common/w_response.dart';
import 'package:w_transport/src/http/w_response.dart';

class ClientWResponse extends CommonWResponse implements WResponse {
  Encoding _encoding;

  ClientWResponse(HttpRequest request, Encoding this._encoding) : super(
          request.status, request.statusText, request.responseHeaders,
          new Stream.fromIterable([request.response]));

  Future<Object> asFuture() => asStream().first;
  Stream asStream() => source;
  Future<String> asText() async {
    Object data =
        await asStream().transform(util.decodeAttempt(_encoding)).first;
    return data != null ? data.toString() : null;
  }
}
