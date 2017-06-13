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
import 'dart:html';

import 'package:react/react_client.dart' as react_client;
import 'package:w_transport/w_transport.dart' as transport;
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';

final _wsServer = Uri.parse('ws://localhost:8024/example/ws/echo');
final _sockJSServer = Uri.parse('ws://localhost:8026/example/ws/echo');

String _echo(String message) =>
    JSON.encode({'action': 'echo', 'message': message});
String _unecho(String response) => JSON.decode(response)['message'];

ButtonElement _connect = querySelector('#connect');
FormElement _form = querySelector('#prompt-form');
TextInputElement _prompt = querySelector('#prompt');
PreElement _logs = querySelector('#logs');
NumberInputElement _sockJSTimeout = querySelector('#sockjs-timeout');
CheckboxInputElement _sockJSWebSocket = querySelector('#sockjs-ws');
CheckboxInputElement _sockJSXhr = querySelector('#sockjs-xhr');
CheckboxInputElement _useSockJS = querySelector('#sockjs');

Future<Null> main() async {
  react_client.setClientConfiguration();
  configureWTransportForBrowser();

  renderGlobalExampleMenu(serverStatus: true);

  transport.WebSocket webSocket;

  // Connect (or reconnect) when the connect button is clicked.
  _connect.onClick.listen((e) async {
    _logs.appendText('Connecting...\n');

    final sockjs = _useSockJS.checked;
    final timeout = _sockJSTimeout.value.isEmpty
        ? null
        : new Duration(milliseconds: _sockJSTimeout.valueAsNumber);
    final protocols = <String>[];
    if (_sockJSWebSocket.checked) {
      protocols.add('websocket');
    }
    if (_sockJSXhr.checked) {
      protocols.add('xhr-streaming');
    }
    final uri = sockjs ? _sockJSServer : _wsServer;

    try {
      webSocket = await transport.WebSocket.connect(uri,
          useSockJS: sockjs,
          sockJSTimeout: timeout,
          sockJSProtocolsWhitelist: protocols);

      // Display messages from web socket
      webSocket.listen((message) {
        _logs.appendText('${_unecho(message)}\n');
      });

      _logs.appendText('Connected.\n');
    } on transport.WebSocketException catch (e, stackTrace) {
      _logs.appendText(
          '> ERROR: Could not connect to web socket on $_wsServer\n');
      print('Could not connect to web socket.\n$e\n$stackTrace');
    }
  });

  // Send message upon form submit.
  _form.onSubmit.listen((e) {
    e.preventDefault();

    if (webSocket == null) return;

    final message = _prompt.value;
    _logs.appendText('> $message\n');
    webSocket.add(_echo(message));
  });

  // Remove the loading overlay
  removeLoadingOverlay();
  await webSocket?.close();
}
