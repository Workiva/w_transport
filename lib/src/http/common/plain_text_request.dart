library w_transport.src.http.common.plain_text_request;

import 'dart:async';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/requests.dart';

abstract class CommonPlainTextRequest extends CommonRequest implements Request {
  CommonPlainTextRequest() : super();
  CommonPlainTextRequest.withClient(client) : super.withClient(client);

  String _body;

  Uint8List _bodyBytes;

  String get body {
    if (_body != null) return _body;
    if (_bodyBytes != null) {
      _body = encoding.decode(_bodyBytes);
      return _body;
    }
    return '';
  }

  set body(String value) {
    verifyUnsent();
    _body = value;
    _bodyBytes = null;
  }

  Uint8List get bodyBytes {
    if (_bodyBytes != null) return _bodyBytes;
    if (_body != null) {
      _bodyBytes = encoding.encode(_body);
      return _bodyBytes;
    }
    return new Uint8List.fromList([]);
  }

  set bodyBytes(List<int> bytes) {
    verifyUnsent();
    _bodyBytes = bytes;
    _body = null;
  }

  @override
  int get contentLength => bodyBytes.length;

  @override
  MediaType get defaultContentType => new MediaType('text', 'plain', {'charset': encoding.name});

  @override
  Future<HttpBody> finalizeBody([body]) async {
    if (body != null) {
      if (body is String) {
        this.body = body;
      } else if (body is List<int>) {
        this.bodyBytes = body;
      } else {
        throw new ArgumentError('Plain-text request body must be either a String or List<int>.');
      }
    }

    return new HttpBody.fromBytes(contentType, bodyBytes);
  }
}