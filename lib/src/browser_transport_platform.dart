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
    const BrowserTransportPlatform();

class BrowserTransportPlatform implements TransportPlatform {
  const BrowserTransportPlatform();

  /// Construct a [HttpClient] instance for use in the browser.
  @override
  HttpClient newHttpClient() => new BrowserHttpClient();

  /// Construct a [FormRequest] instance for use in the browser.
  @override
  FormRequest newFormRequest() => new BrowserFormRequest(this);

  /// Construct a [JsonRequest] instance for use in the browser.
  @override
  JsonRequest newJsonRequest() => new BrowserJsonRequest(this);

  /// Construct a [MultipartRequest] instance for use in the browser.
  @override
  MultipartRequest newMultipartRequest() => new BrowserMultipartRequest(this);

  /// Construct a [Request] instance for use in the browser.
  @override
  Request newRequest() => new BrowserPlainTextRequest(this);

  /// Construct a [StreamedRequest] instance for use in the browser.
  @override
  StreamedRequest newStreamedRequest() => new BrowserStreamedRequest(this);

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
    // ignore: deprecated_member_use
    if (useSockJS == true) {
      return SockJSWebSocket.connect(uri,
          // ignore: deprecated_member_use
          debug: sockJSDebug,
          // ignore: deprecated_member_use
          noCredentials: sockJSNoCredentials,
          // ignore: deprecated_member_use
          protocolsWhitelist: sockJSProtocolsWhitelist,
          // ignore: deprecated_member_use
          timeout: sockJSTimeout);
    }

    return BrowserWebSocket.connect(uri,
        headers: headers, protocols: protocols);
  }
}
