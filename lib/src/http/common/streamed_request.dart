library w_transport.src.http.common.streamed_request;

import 'dart:async';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/requests.dart';

abstract class CommonStreamedRequest extends CommonRequest
    implements StreamedRequest {
  CommonStreamedRequest() : super();
  CommonStreamedRequest.withClient(client) : super.withClient(client);

  Stream<List<int>> _body;

  int _contentLength;

  Stream<List<int>> get body => _body;

  set body(Stream<List<int>> byteStream) {
    verifyUnsent();
    _body = byteStream;
  }

  @override
  int get contentLength => _contentLength;

  @override
  set contentLength(int value) {
    verifyUnsent();
    _contentLength = value;
  }

  @override
  MediaType get defaultContentType =>
      new MediaType('text', 'plain', {'charset': encoding.name});

  @override
  Future<StreamedHttpBody> finalizeBody([body]) async {
    if (body != null) {
      if (body is Stream<List<int>>) {
        this.body = body;
      } else {
        throw new ArgumentError(
            'Streamed request body must be a Stream<List<int>>.');
      }
    }

    if (this.body == null) {
      this.body = new Stream.fromIterable([]);
    }
    return new StreamedHttpBody.fromByteStream(contentType, this.body,
        contentLength: contentLength);
  }
}
