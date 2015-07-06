library w_transport.src.mocks.mock_w_response;

import 'dart:async';
import 'dart:convert';

import 'package:w_transport/w_transport.dart' show WProgress, WResponse;

import 'package:w_transport/src/http/w_http.dart' show decodeAttempt;

part 'package:w_transport/src/mocks/source/w_response_source.dart';

class MockWResponse extends WResponseSource implements WResponse {
  MockWResponse(int status,
      {Map<String, String> headers, String statusText, body})
      : super(new Stream.fromIterable([]), status,
          statusText != null ? statusText : _mapStatusToText(status),
          headers != null ? headers : {}) {
    if (body != null) {
      update(body);
    }
  }

  MockWResponse.ok({Map<String, String> headers, String statusText, body})
      : this(200, headers: headers, statusText: statusText, body: body);

  MockWResponse.badRequest(
      {Map<String, String> headers, String statusText, body})
      : this(400, headers: headers, statusText: statusText, body: body);

  MockWResponse.unauthorized(
      {Map<String, String> headers, String statusText, body})
      : this(401, headers: headers, statusText: statusText, body: body);

  MockWResponse.forbidden(
      {Map<String, String> headers, String statusText, body})
      : this(403, headers: headers, statusText: statusText, body: body);

  MockWResponse.notFound({Map<String, String> headers, String statusText, body})
      : this(404, headers: headers, statusText: statusText, body: body);

  MockWResponse.methodNotAllowed(
      {Map<String, String> headers, String statusText, body})
      : this(405, headers: headers, statusText: statusText, body: body);

  MockWResponse.internalServerError(
      {Map<String, String> headers, String statusText, body})
      : this(500, headers: headers, statusText: statusText, body: body);

  MockWResponse.notImplemented(
      {Map<String, String> headers, String statusText, body})
      : this(501, headers: headers, statusText: statusText, body: body);

  MockWResponse.badGateway(
      {Map<String, String> headers, String statusText, body})
      : this(502, headers: headers, statusText: statusText, body: body);

  set mock(dynamic body) {
    update(body);
  }

  Future<Object> _getFuture() => asStream().single;

  Future<String> _getText() =>
      asStream().transform(decodeAttempt(_encoding)).join('');
}

String _mapStatusToText(int status) {
  switch (status) {
    case 200:
      return 'OK';
    case 400:
      return 'BAD REQUEST';
    case 401:
      return 'UNAUTHORIZED';
    case 403:
      return 'FORBIDDEN';
    case 404:
      return 'NOT FOUND';
    case 405:
      return 'METHOD NOT ALLOWED';
    case 500:
      return 'INTERNAL SERVER ERROR';
    case 501:
      return 'NOT IMPLEMENTED';
    case 502:
      return 'BAD GATEWAY';
    default:
      return '';
  }
}
