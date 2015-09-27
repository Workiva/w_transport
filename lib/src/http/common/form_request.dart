library w_transport.src.http.common.form_request;

import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

abstract class CommonFormRequest extends CommonRequest implements FormRequest {
  CommonFormRequest() : super();
  CommonFormRequest.withClient(client) : super.withClient(client);

  Map<String, String> _fields = {};

  @override
  int get contentLength => _encodedQuery.length;

  @override
  MediaType get defaultContentType => new MediaType('application', 'x-www-form-urlencoded', {'charset': encoding.name});

  Map<String, String> get fields => _fields;

  set fields(Map<String, String> fields) {
    if (fields == null) {
      fields = {};
    }
    _fields = fields;
  }

  Uint8List get _encodedQuery => encoding.encode(http_utils.mapToQuery(fields));

  @override
  HttpBody finalizeBody([body]) {
    if (body != null) {
      this.fields = body;
    }
    return new HttpBody.fromBytes(contentType, _encodedQuery);
  }
}