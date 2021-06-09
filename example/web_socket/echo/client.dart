// @dart=2.7
// ^ Do not remove until migrated to null safety. More info at https://wiki.atl.workiva.net/pages/viewpage.action?pageId=189370832
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

import 'package:w_transport/w_transport.dart';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import '../../common/global_example_menu.dart';
import '../../common/loading_component.dart';

final _wsServer = Uri.parse('ws://localhost:8024/example/ws/echo');
final _sockJSServer = Uri.parse('ws://localhost:8026/example/ws/echo');

String _echo(String message) =>
    json.encode({'action': 'echo', 'message': message});
String _unecho(String response) => json.decode(response)['message'];

ButtonElement _connect = querySelector('#connect');
FormElement _form = querySelector('#prompt-form');
TextInputElement _prompt = querySelector('#prompt');
PreElement _logs = querySelector('#logs');
NumberInputElement _sockJSTimeout = querySelector('#sockjs-timeout');
CheckboxInputElement _sockJSWebSocket = querySelector('#sockjs-ws');
CheckboxInputElement _sockJSXhrStreaming =
    querySelector('#sockjs-xhr-streaming');
CheckboxInputElement _sockJSXhrPolling = querySelector('#sockjs-xhr-polling');
CheckboxInputElement _useSockJS = querySelector('#sockjs');

Future<Null> main() async {
  configureWTransportForBrowser();

  renderGlobalExampleMenu(includeServerStatus: true);

  // ignore: close_sinks,deprecated_member_use_from_same_package
  WSocket webSocket;

  // Connect (or reconnect) when the connect button is clicked.
  _connect.onClick.listen((e) async {
    _logs.appendText('Connecting...\n');

    final sockjs = _useSockJS.checked;
    final timeout = _sockJSTimeout.value.isEmpty
        ? null
        : Duration(milliseconds: _sockJSTimeout.valueAsNumber);
    final protocols = <String>[];
    if (_sockJSWebSocket.checked) {
      protocols.add('websocket');
    }
    if (_sockJSXhrStreaming.checked) {
      protocols.add('xhr-streaming');
    }
    if (_sockJSXhrPolling.checked) {
      protocols.add('xhr-polling');
    }
    final uri = sockjs ? _sockJSServer : _wsServer;

    try {
      // ignore: deprecated_member_use_from_same_package
      webSocket = await WSocket.connect(uri,
          // ignore: deprecated_member_use_from_same_package
          useSockJS: sockjs,
          // ignore: deprecated_member_use_from_same_package
          sockJSTimeout: timeout,
          // ignore: deprecated_member_use_from_same_package
          sockJSProtocolsWhitelist: protocols);

      // Display messages from web socket
      webSocket.listen((message) {
        _logs.appendText('${_unecho(message)}\n');
      });

      _logs.appendText('Connected.\n');
    } on WebSocketException catch (e, stackTrace) {
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
}
