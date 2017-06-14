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

library w_transport.example.web_socket.echo.client;

import 'dart:convert';
import 'dart:html';

import 'package:react/react_client.dart' as react_client;
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_browser.dart'
    show configureWTransportForBrowser;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';

final Uri wsServer = Uri.parse('ws://localhost:8024/example/ws/echo');
final Uri sockJSServer = Uri.parse('ws://localhost:8026/example/ws/echo');

String _echo(String message) =>
    JSON.encode({'action': 'echo', 'message': message});
String _unecho(String response) => JSON.decode(response)['message'];

ButtonElement connect = querySelector('#connect');
FormElement form = querySelector('#prompt-form');
TextInputElement prompt = querySelector('#prompt');
PreElement logs = querySelector('#logs');
NumberInputElement sockJSTimeout = querySelector('#sockjs-timeout');
CheckboxInputElement sockJSWebSocket = querySelector('#sockjs-ws');
CheckboxInputElement sockJSXhr = querySelector('#sockjs-xhr');
CheckboxInputElement useSockJS = querySelector('#sockjs');

main() async {
  react_client.setClientConfiguration();
  configureWTransportForBrowser();

  renderGlobalExampleMenu(serverStatus: true);

  // TODO
  WSocket webSocket;

  // TODO
  // Connect (or reconnect) when the connect button is clicked.
  var sub = connect.onClick.listen((e) async {
    logs.appendText('Connecting...\n');

    bool sockjs = useSockJS.checked;
    Duration timeout = sockJSTimeout.value.isEmpty
        ? null
        : new Duration(milliseconds: sockJSTimeout.valueAsNumber);
    var protocols = [];
    if (sockJSWebSocket.checked) {
      protocols.add('websocket');
    }
    if (sockJSXhr.checked) {
      protocols.add('xhr-streaming');
    }
    Uri uri = sockjs ? sockJSServer : wsServer;

    try {
      webSocket = await WSocket.connect(uri,
          useSockJS: sockjs,
          sockJSTimeout: timeout,
          sockJSProtocolsWhitelist: protocols);

      // TODO
      // Display messages from web socket
      var sub = webSocket.listen((message) {
        logs.appendText('${_unecho(message)}\n');
      });

      logs.appendText('Connected.\n');
    } on WSocketException catch (e, stackTrace) {
      logs.appendText(
          '> ERROR: Could not connect to web socket on $wsServer\n');
      print('Could not connect to web socket.\n$e\n$stackTrace');
    }
  });

  // TODO
  // Send message upon form submit.
  var submitSub = form.onSubmit.listen((e) {
    e.preventDefault();

    if (webSocket == null) return;

    String message = prompt.value;
    logs.appendText('> $message\n');
    webSocket.add(_echo(message));
  });

  // Remove the loading overlay
  removeLoadingOverlay();
}
