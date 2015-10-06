library w_transport.src.http.mock.response;

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

class MockResponse implements Response {
  Response _response;

  MockResponse(int status,
      {body,
      Encoding encoding,
      Map<String, String> headers,
      String statusText}) {
    // Ensure the headers are case insensitive.
    headers = new CaseInsensitiveMap.from(headers != null ? headers : {});

    // If an encoding was given, update the content-type charset parameter.
    if (encoding != null) {
      var contentType = http_utils.parseContentTypeFromHeaders(headers);
      contentType = contentType.change(parameters: {'charset': encoding.name});
      headers['content-type'] = contentType.toString();
    }

    // Use a default status text based on the status code if one is not given.
    if (statusText == null) {
      statusText = _mapStatusToText(status);
    }

    if (body == null) {
      body = '';
    }

    // Construct the body according to the data type.
    if (body is String) {
      _response = new Response.fromString(status, statusText, headers, body);
    } else if (body is List<int>) {
      _response = new Response.fromBytes(status, statusText, headers, body);
    } else {
      throw new ArgumentError(
          'Mock response body must be a String or bytes (List<int>).');
    }
  }

  HttpBody get body => _response.body;

  int get contentLength => _response.contentLength;

  MediaType get contentType => _response.contentType;

  Encoding get encoding => _response.encoding;

  Map<String, String> get headers => _response.headers;

  int get status => _response.status;

  String get statusText => _response.statusText;

  factory MockResponse.ok(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(200,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.badRequest(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(400,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.unauthorized(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(401,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.forbidden(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(403,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.notFound(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(404,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.methodNotAllowed(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(405,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.internalServerError(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(500,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.notImplemented(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(501,
          body: body, headers: headers, statusText: statusText);

  factory MockResponse.badGateway(
          {body, Map<String, String> headers, String statusText}) =>
      new MockResponse(502,
          body: body, headers: headers, statusText: statusText);
}

class MockStreamedResponse implements StreamedResponse {
  StreamedResponse _response;

  MockStreamedResponse(int status,
      {Stream<List<int>> byteStream,
      Encoding encoding,
      Map<String, String> headers,
      String statusText}) {
    // Ensure the headers are case insensitive.
    headers = new CaseInsensitiveMap.from(headers != null ? headers : {});

    // If an encoding was given, update the content-type charset parameter.
    if (encoding != null) {
      var contentType = http_utils.parseContentTypeFromHeaders(headers);
      contentType = contentType.change(parameters: {'charset': encoding.name});
      headers['content-type'] = contentType.toString();
    }

    // Use a default status text based on the status code if one is not given.
    if (statusText == null) {
      statusText = _mapStatusToText(status);
    }

    if (byteStream == null) {
      byteStream = new Stream.fromIterable([]);
    }

    // Construct the body according to the data type.
    _response = new StreamedResponse.fromByteStream(
        status, statusText, headers, byteStream);
  }

  StreamedHttpBody get body => _response.body;

  int get contentLength => _response.contentLength;

  MediaType get contentType => _response.contentType;

  Encoding get encoding => _response.encoding;

  Map<String, String> get headers => _response.headers;

  int get status => _response.status;

  String get statusText => _response.statusText;

  factory MockStreamedResponse.ok(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(200,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.badRequest(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(400,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.unauthorized(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(401,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.forbidden(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(403,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.notFound(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(404,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.methodNotAllowed(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(405,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.internalServerError(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(500,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.notImplemented(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(501,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.badGateway(
          {byteStream, Map<String, String> headers, String statusText}) =>
      new MockStreamedResponse(502,
          byteStream: byteStream, headers: headers, statusText: statusText);
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
