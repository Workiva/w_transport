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
import 'package:w_transport/src/http/browser/http_client.dart';
import 'package:w_transport/src/http/browser/requests.dart';
import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/browser/sockjs.dart';
import 'package:w_transport/src/web_socket/browser/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

const BrowserTransportPlatform browserTransportPlatform =
    BrowserTransportPlatform();

class BrowserTransportPlatform implements TransportPlatform {
  const BrowserTransportPlatform();

  /// Construct a [HttpClient] instance for use in the browser.
  @override
  HttpClient newHttpClient() => BrowserHttpClient();

  /// Construct a [FormRequest] instance for use in the browser.
  @override
  FormRequest newFormRequest() => BrowserFormRequest(this);

  /// Construct a [JsonRequest] instance for use in the browser.
  @override
  JsonRequest newJsonRequest() => BrowserJsonRequest(this);

  /// Construct a [MultipartRequest] instance for use in the browser.
  @override
  MultipartRequest newMultipartRequest() => BrowserMultipartRequest(this);

  /// Construct a [Request] instance for use in the browser.
  @override
  Request newRequest() => BrowserPlainTextRequest(this);

  /// Construct a [StreamedRequest] instance for use in the browser.
  @override
  StreamedRequest newStreamedRequest() => BrowserStreamedRequest(this);

  /// Construct a [WebSocket] instance for use in the browser.
  @override
  Future<WebSocket> newWebSocket(Uri uri,
      {Map<String, dynamic> headers,
      Iterable<String> protocols,
      @Deprecated(v3Deprecation) bool sockJSDebug,
      @Deprecated(v3Deprecation) bool sockJSNoCredentials,
      @Deprecated(v3Deprecation) List<String> sockJSProtocolsWhitelist,
      @Deprecated(v3Deprecation) Duration sockJSTimeout,
      @Deprecated(v3Deprecation) bool useSockJS}) {
    // TODO: remove this backwards-compat logic in v4 when deprecated SockJS params are removed.
    // If consumers are still using the sockJS optional params to configure
    // WebSockets instead of a TransportPlatform instance, we need to respect
    // that for backwards compatibility.

    // If useSockJS is enabled, switch to a SockJS WebSocket.
    // ignore: deprecated_member_use_from_same_package
    if (useSockJS == true) {
      return SockJSWebSocket.connect(uri,
          // ignore: deprecated_member_use_from_same_package
          debug: sockJSDebug,
          // ignore: deprecated_member_use_from_same_package
          noCredentials: sockJSNoCredentials,
          // ignore: deprecated_member_use_from_same_package
          protocolsWhitelist: sockJSProtocolsWhitelist,
          // ignore: deprecated_member_use_from_same_package
          timeout: sockJSTimeout);
    }

    return BrowserWebSocket.connect(uri,
        headers: headers, protocols: protocols);
  }
}
