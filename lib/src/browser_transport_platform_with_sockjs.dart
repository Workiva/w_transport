import 'dart:async';

import 'package:w_transport/src/browser_transport_platform.dart';
import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/transport_platform.dart';
import 'package:w_transport/src/web_socket/browser/sockjs.dart';
import 'package:w_transport/src/web_socket/browser/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

const BrowserTransportPlatformWithSockJS browserTransportPlatformWithSockJS =
    const BrowserTransportPlatformWithSockJS();

class BrowserTransportPlatformWithSockJS extends BrowserTransportPlatform
    implements TransportPlatform {
  final bool _sockJSDebug;
  final bool _sockJSNoCredentials;
  final List<String> _sockJSProtocolsWhitelist;
  final Duration _sockJSTimeout;

  const BrowserTransportPlatformWithSockJS(
      {bool sockJSNoCredentials: false,
      bool sockJSDebug: false,
      List<String> sockJSProtocolsWhitelist,
      Duration sockJSTimeout})
      : _sockJSDebug = sockJSDebug == true,
        _sockJSProtocolsWhitelist = sockJSProtocolsWhitelist,
        _sockJSNoCredentials = sockJSNoCredentials == true,
        _sockJSTimeout = sockJSTimeout;

  bool get sockJSDebug => _sockJSDebug;
  bool get sockJSNoCredentials => _sockJSNoCredentials;
  List<String> get sockJSProtocolsWhitelist => _sockJSProtocolsWhitelist != null
      ? new List.from(_sockJSProtocolsWhitelist)
      : null;
  Duration get sockJSTimeout => _sockJSTimeout;

  /// Construct a [WebSocket] instance that leverages SockJS for use in the
  /// browser.
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

    // If useSockJS is for some reason disabled, revert to standard WebSocket.
    if (useSockJS == false) {
      return BrowserWebSocket.connect(uri,
          headers: headers, protocols: protocols);
    }

    // Otherwise, use the given sockJS params if given and fallback to the
    // settings configured with this TransportPlatform instance.
    return SockJSWebSocket.connect(uri,
        debug: sockJSDebug ?? _sockJSDebug,
        noCredentials: sockJSNoCredentials ?? _sockJSNoCredentials,
        protocolsWhitelist:
            sockJSProtocolsWhitelist ?? _sockJSProtocolsWhitelist,
        timeout: sockJSTimeout ?? _sockJSTimeout);
  }
}
