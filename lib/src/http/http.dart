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

import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/response.dart';
import 'package:w_transport/src/transport_platform.dart';

/// Static methods for quickly sending HTTP requests.
class Http {
  /// Sends a DELETE request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> delete(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .delete();

  /// Sends a GET request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> get(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .get();

  /// Sends a HEAD request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> head(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .head();

  /// Sends an OPTIONS request to [uri]. Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> options(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .options();

  /// Sends a PATCH request to [uri]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> patch(Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .patch();

  /// Sends a POST request to [uri]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> post(Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .post();

  /// Sends a PUT request to [uri]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> put(Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .put();

  /// Sends a request to [uri] using the HTTP method specified by [method].
  /// Includes request [headers] and a request [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<Response> send(String method, Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .send(method);

  /// Sends a DELETE request to [uri] and returns a [StreamedResponse]. Includes
  /// request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamDelete(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamDelete();

  /// Sends a GET request to [uri] and returns a [StreamedResponse]. Includes
  /// request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamGet(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamGet();

  /// Sends a HEAD request to [uri] and returns a [StreamedResponse]. Includes
  /// request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamHead(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamHead();

  /// Sends an OPTIONS request to [uri] and returns a [StreamedResponse].
  /// Includes request [headers] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamOptions(Uri uri,
          {Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamOptions();

  /// Sends a PATCH request to [uri] and returns a [StreamedResponse]. Includes
  /// request [headers] and a request [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamPatch(Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamPatch();

  /// Sends a POST request to [uri] and returns a [StreamedResponse]. Includes
  /// request [headers] and a request [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamPost(Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamPost();

  /// Sends a PUT request to [uri] and returns a [StreamedResponse]. Includes
  /// request [headers] and a request [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamPut(Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamPut();

  /// Sends a request to [uri] using the HTTP method specified by [method] and
  /// returns a [StreamedResponse]. Includes request [headers] and a request
  /// [body] if given.
  ///
  /// Secure cookies (credentials) will be included (in the browser) if
  /// [withCredentials] is true.
  static Future<StreamedResponse> streamSend(String method, Uri uri,
          {String body,
          Map<String, String> headers,
          TransportPlatform transportPlatform,
          bool withCredentials}) =>
      _createRequest(uri,
              body: body,
              headers: headers,
              transportPlatform: transportPlatform,
              withCredentials: withCredentials)
          .streamSend(method);

  static Request _createRequest(Uri uri,
      {String body,
      Map<String, String> headers,
      TransportPlatform transportPlatform,
      bool withCredentials}) {
    final request = new Request(transportPlatform: transportPlatform)
      ..uri = uri;
    if (body != null) {
      request.body = body;
    }
    if (headers != null) {
      request.headers = headers;
    }
    if (withCredentials != null) {
      request.withCredentials = withCredentials;
    }
    return request;
  }
}
