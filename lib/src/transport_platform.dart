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

import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/mock/http_client.dart';
import 'package:w_transport/src/http/mock/requests.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/mocks/mock_transports.dart'
    show MockWebSocketInternal, MockTransportsInternal;
import 'package:w_transport/src/web_socket/mock/w_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

abstract class TransportPlatform {
  /// Constructs a new [HttpClient] instance.
  HttpClient newHttpClient();

  /// Constructs a new [FormRequest] instance.
  FormRequest newFormRequest();

  /// Constructs a new [JsonRequest] instance.
  JsonRequest newJsonRequest();

  /// Constructs a new [MultipartRequest] instance.
  MultipartRequest newMultipartRequest();

  /// Constructs a new [Request] instance.
  Request newRequest();

  /// Constructs a new [StreamedRequest] instance.
  StreamedRequest newStreamedRequest();

  /// Constructs a new [WebSocket] instance.
  Future<WebSocket> newWebSocket(Uri uri,
      {Map<String, dynamic> headers,
      Iterable<String> protocols,
      @Deprecated(v3Deprecation) bool sockJSDebug,
      @Deprecated(v3Deprecation) bool sockJSNoCredentials,
      @Deprecated(v3Deprecation) List<String> sockJSProtocolsWhitelist,
      @Deprecated(v3Deprecation) Duration sockJSTimeout,
      @Deprecated(v3Deprecation) bool useSockJS});
}

class MockAwareTransportPlatform {
  /// Construct a new [MockHttpClient] instance that implements [HttpClient].
  static HttpClient newHttpClient(TransportPlatform realTransportPlatform) =>
      new MockHttpClient(realTransportPlatform);

  // ignore: deprecated_member_use
  /// Construct a new [MockFormRequest] instance that implements
  /// [FormRequest].
  static FormRequest newFormRequest(TransportPlatform realTransportPlatform) =>
      // ignore: deprecated_member_use
      new MockFormRequest(realTransportPlatform);

  // ignore: deprecated_member_use
  /// Construct a new [MockJsonRequest] instance that implements
  /// [JsonRequest].
  static JsonRequest newJsonRequest(TransportPlatform realTransportPlatform) =>
      // ignore: deprecated_member_use
      new MockJsonRequest(realTransportPlatform);

  // ignore: deprecated_member_use
  /// Construct a new [MockMultipartRequest] instance that implements
  /// [MultipartRequest].
  static MultipartRequest newMultipartRequest(
          TransportPlatform realTransportPlatform) =>
      // ignore: deprecated_member_use
      new MockMultipartRequest(realTransportPlatform);

  // ignore: deprecated_member_use
  /// Construct a new [MockPlainTextRequest] instance that implements
  /// [Request].
  static Request newRequest(TransportPlatform realTransportPlatform) =>
      // ignore: deprecated_member_use
      new MockPlainTextRequest(realTransportPlatform);

  // ignore: deprecated_member_use
  /// Construct a new [MockStreamedRequest] instance that implements
  /// [StreamedRequest].
  static StreamedRequest newStreamedRequest(
          TransportPlatform realTransportPlatform) =>
      // ignore: deprecated_member_use
      new MockStreamedRequest(realTransportPlatform);

  /// Construct a new [MockWebSocket] instance that implements [WebSocket].
  static Future<WebSocket> newWebSocket(
      TransportPlatform realTransportPlatform, Uri uri,
      {Map<String, dynamic> headers,
      Iterable<String> protocols,
      @Deprecated(v3Deprecation) bool sockJSDebug,
      @Deprecated(v3Deprecation) bool sockJSNoCredentials,
      @Deprecated(v3Deprecation) List<String> sockJSProtocolsWhitelist,
      @Deprecated(v3Deprecation) Duration sockJSTimeout,
      @Deprecated(v3Deprecation) bool useSockJS}) {
    if (MockTransportsInternal.isInstalled &&
        MockWebSocketInternal.hasHandlerForWebSocket(uri)) {
      // ignore: deprecated_member_use
      return MockWSocket.connect(uri, headers: headers, protocols: protocols);
    } else if (MockTransportsInternal.fallThrough &&
        realTransportPlatform != null) {
      return realTransportPlatform.newWebSocket(uri,
          headers: headers,
          protocols: protocols,
          // ignore: deprecated_member_use
          sockJSDebug: sockJSDebug,
          // ignore: deprecated_member_use
          sockJSNoCredentials: sockJSNoCredentials,
          // ignore: deprecated_member_use
          sockJSProtocolsWhitelist: sockJSProtocolsWhitelist,
          // ignore: deprecated_member_use
          sockJSTimeout: sockJSTimeout,
          // ignore: deprecated_member_use
          useSockJS: useSockJS);
    } else {
      throw new TransportPlatformMissing.webSocketFailed(uri);
    }
  }
}

class TransportPlatformMissing extends StateError {
  static const String _platformHelp = '  Ensure that you are configuring the '
      'transport platform before sending requests.\n\n'
      '  Two transport platforms are provided for you\n'
      '    Browser:\n'
      '      import \'package:w_transport/browser.dart\' show '
      'browserTransportPlatform;\n'
      '    Dart VM:\n'
      '      import \'package:w_transport/vm.dart\' show '
      'vmTransportPlatform;';

  TransportPlatformMissing.httpClientFailed()
      : super(_buildExceptionMessageForHttpClient());

  TransportPlatformMissing.httpRequestFailed(String type)
      : super(_buildExceptionMessageForHttpRequest(type));

  TransportPlatformMissing.webSocketFailed(Uri uri)
      : super(_buildExceptionMessageForWebSocket(uri));

  static String _buildExceptionMessageForHttpClient() =>
      'w_transport: Cannot construct an HTTP Client - Missing Transport '
      'Platform\n\n'
      '$_platformHelp\n\n'
      '  There are two ways to configure the transport platform\n'
      '    For a single HTTP Client:\n'
      '      new transport.HttpClient(transportPlatform: ...);\n'
      '    For all HTTP Clients:\n'
      '      transport.globalTransportPlatform = ...;';

  static String _buildExceptionMessageForHttpRequest(String type) =>
      'w_transport: Cannot send $type - Missing Transport Platform\n\n'
      '$_platformHelp\n\n'
      '  There are three ways to configure the transport platform\n'
      '    For a single request:\n'
      '      new transport.$type(transportPlatform: ...);\n'
      '    For an HTTP client:\n'
      '      new transport.HttpClient(transportPlatform: ...);\n'
      '    For all requests:\n'
      '      transport.globalTransportPlatform = ...;';

  static String _buildExceptionMessageForWebSocket(Uri uri) =>
      'w_transport: Cannot open WebSocket - Missing Transport Platform\n'
      '  (uri: $uri)\n\n'
      '$_platformHelp\n\n'
      '  There are two ways to configure the transport platform\n'
      '    For a single WebSocket connection:\n'
      '      transport.WebSocket.connect(uri, transportPlatform: ...);\n'
      '    For all WebSocket connections:\n'
      '      transport.globalTransportPlatform = ...;';

  @override
  String toString() => message;
}
