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
    headers = new CaseInsensitiveMap<String>.from(headers ?? {});

    // If an encoding was given, update the content-type charset parameter.
    if (encoding != null) {
      MediaType contentType = http_utils.parseContentTypeFromHeaders(headers);
      contentType = contentType.change(parameters: {'charset': encoding.name});
      headers['content-type'] = contentType.toString();
    }

    // Use a default status text based on the status code if one is not given.
    statusText ??= _mapStatusToText(status);
    body ??= '';

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

  @override
  HttpBody get body => _response.body;

  @override
  int get contentLength => _response.contentLength;

  @override
  MediaType get contentType => _response.contentType;

  @override
  Encoding get encoding => _response.encoding;

  @override
  Map<String, String> get headers => _response.headers;

  @override
  int get status => _response.status;

  @override
  String get statusText => _response.statusText;

  @override
  Response replace(
      {List<int> bodyBytes,
      String bodyString,
      int status,
      String statusText,
      Map<String, String> headers}) {
    return _response.replace(
        bodyBytes: bodyBytes,
        bodyString: bodyString,
        status: status,
        statusText: statusText,
        headers: headers);
  }
}

class MockStreamedResponse implements StreamedResponse {
  StreamedResponse _response;

  MockStreamedResponse(int status,
      {Stream<List<int>> byteStream,
      Encoding encoding,
      Map<String, String> headers,
      String statusText}) {
    // Ensure the headers are case insensitive.
    headers = new CaseInsensitiveMap<String>.from(headers ?? {});

    // If an encoding was given, update the content-type charset parameter.
    if (encoding != null) {
      MediaType contentType = http_utils.parseContentTypeFromHeaders(headers);
      contentType = contentType.change(parameters: {'charset': encoding.name});
      headers['content-type'] = contentType.toString();
    }

    // Use a default status text based on the status code if one is not given.
    statusText ??= _mapStatusToText(status);
    byteStream ??= new Stream.fromIterable([]);

    // Construct the body according to the data type.
    _response = new StreamedResponse.fromByteStream(
        status, statusText, headers, byteStream);
  }

  factory MockStreamedResponse.ok(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(200,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.badRequest(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(400,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.unauthorized(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(401,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.forbidden(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(403,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.notFound(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(404,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.methodNotAllowed(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(405,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.internalServerError(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(500,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.notImplemented(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(501,
          byteStream: byteStream, headers: headers, statusText: statusText);

  factory MockStreamedResponse.badGateway(
          {Stream<List<int>> byteStream,
          Map<String, String> headers,
          String statusText}) =>
      new MockStreamedResponse(502,
          byteStream: byteStream, headers: headers, statusText: statusText);

  @override
  StreamedHttpBody get body => _response.body;

  @override
  int get contentLength => _response.contentLength;

  @override
  MediaType get contentType => _response.contentType;

  @override
  Encoding get encoding => _response.encoding;

  @override
  Map<String, String> get headers => _response.headers;

  @override
  int get status => _response.status;

  @override
  String get statusText => _response.statusText;

  @override
  StreamedResponse replace(
      {Stream<List<int>> byteStream,
      int status,
      String statusText,
      Map<String, String> headers}) {
    return _response.replace(
        byteStream: byteStream,
        status: status,
        statusText: statusText,
        headers: headers);
  }
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
