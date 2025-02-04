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

import 'package:opentelemetry/api.dart';
import 'package:sockjs_client_wrapper/sockjs_client_wrapper.dart';

import 'package:w_transport/src/web_socket/common/web_socket.dart';
import 'package:w_transport/src/web_socket/global_web_socket_monitor.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';
import 'package:w_transport/src/web_socket/web_socket_exception.dart';

/// Implementation of the platform-dependent pieces of the [WebSocket] class for
/// the SockJS browser configuration. This class uses the SockJS library to
/// establish a WebSocket-like connection (could be a native WebSocket, could
/// be XHR-streaming).
class SockJSWrapperWebSocket extends CommonWebSocket implements WebSocket {
  /// The "WebSocket" - in this case, it's a SockJS Client that has an API
  /// similar to that of a WebSocket, regardless of what protocol is actually
  /// used.
  SockJSClient _webSocket;

  SockJSWrapperWebSocket._(this._webSocket, Future webSocketClosed) : super() {
    webSocketClosed.then((closeEvent) {
      closeCode = closeEvent.code;
      closeReason = closeEvent.reason;
      onIncomingDone();
    });

    // Note: We don't listen to the SockJS client for messages immediately like
    // we do with the native WebSockets. This is because the event streams from
    // the SockJS client are all drawn from a single broadcast stream. To make
    // it act like a single subscription stream (and thus make it fit the
    // interface of a standard Stream), we create a subscription when a consumer
    // listens to this WSocket instance, cancel that subscription when the
    // consumer's subscription is paused, and re-listen when the consumer
    // resumes listening. See [onIncomingListen], [onIncomingPause], and
    // [onIncomingResume].

    // Additional note: the SockJS Client has no error stream, so no need to
    // listen for errors.
  }

  static Future<WebSocket> connect(Uri uri,
      {bool debug = false,
      bool noCredentials = false,
      List<String>? protocolsWhitelist,
      Duration? timeout}) async {
    return trace(
        'SockJSWrapperWebSocket.connect',
        () => SockJSWrapperWebSocket._connect(uri,
            debug: debug,
            noCredentials: noCredentials,
            protocolsWhitelist: protocolsWhitelist,
            timeout: timeout),
        tracer: globalTracerProvider.getTracer('w_transport'));
  }

  static Future<WebSocket> _connect(Uri uri,
      {bool debug = false,
      bool noCredentials = false,
      List<String>? protocolsWhitelist,
      Duration? timeout}) async {
    final span = spanFromContext(Context.current);
    Uri sockjsUri = uri.scheme == 'ws'
        ? uri.replace(scheme: 'http')
        : uri.replace(scheme: 'https');
    // TODO: pass `debug`, `noCredentials`, and `timeout` through when possible.
    final client = SockJSClient(sockjsUri,
        options: SockJSOptions(transports: protocolsWhitelist));

    final open = client.onOpen.first.then((e) {
      span.setAttribute(Attribute.fromString('sockjs.transport', e.transport));
      return newWebSocketConnectEvent(
        url: uri.toString(),
        wasSuccessful: true,
        debugUrl: e.debugUrl.toString(),
        sockJsProtocolsWhitelist: protocolsWhitelist,
        sockJsSelectedProtocol: e.transport,
      );
    });

    final close = client.onClose.first.then((e) => newWebSocketConnectEvent(
        url: uri.toString(),
        wasSuccessful: false,
        sockJsProtocolsWhitelist: protocolsWhitelist));

    // Wait for the first open, close, or timeout.
    // The timeout will most likely apply to the initial info request made by
    // SockJS. The actual websocket connection has a dynamic timeout set by
    // SockJS based on the round trip time (RTT) of the info request. The
    // dynamic timeout is RTT * 4 * 2. RTT will generally be 50 to 150 ms. This
    // means the dynamic timeout will most likely be less than 1.2 seconds.
    final event = await Future.any([open, close]).timeout(
        timeout ?? const Duration(seconds: 5),
        onTimeout: () => throw WebSocketException('Could not connect to $uri'));
    emitWebSocketConnectEvent(event);

    return SockJSWrapperWebSocket._(client, client.onClose.first);
  }

  @override
  void closeWebSocket(int code, String? reason) {
    _webSocket.close(code, reason);
  }

  @override
  void onIncomingListen() {
    // When this [WSocket] instance is listened to, start listening to the
    // SockJS client's broadcast stream.
    webSocketSubscription = _webSocket.onMessage.listen((messageEvent) {
      onIncomingData(messageEvent.data);
    });
  }

  @override
  void onIncomingPause() {
    // When this [WSocket]'s subscription is paused, cancel the subscription to
    // the SockJS client's broadcast stream. This is the recommended behavior
    // when proxying a subscription to a broadcast stream. This effectively
    // prevents buffering events indefinitely (a possible memory leak) by
    // canceling the subscription altogether. When the subscription to this
    // [WSocket] instance is resumed, we will re-subscribe.
    webSocketSubscription.cancel();
  }

  @override
  void onIncomingResume() {
    // Resubscribe to the SockJS client's broadcast stream to effectively resume
    // the consumer's subscription to this [WSocket] instance.
    webSocketSubscription = _webSocket.onMessage.listen((messageEvent) {
      onIncomingData(messageEvent.data);
    });
  }

  @override
  void onOutgoingData(dynamic data) {
    // Pipe messages through to the underlying socket.
    _webSocket.send(data);
  }

  @override
  void validateOutgoingData(Object data) {
    if (data is! String) {
      throw ArgumentError(
          'WSocket data type must be a String when using SockJS.');
    }
  }
}
