/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.example.web_socket.echo.client;

import 'dart:convert';
import 'dart:html';

import 'package:react/react_client.dart' as react_client;
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_client.dart'
    show configureWTransportForBrowser;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';

final Uri wsServer = Uri.parse('ws://localhost:8024/example/ws/echo');

String _echo(String message) =>
    JSON.encode({'action': 'echo', 'message': message});
String _unecho(String response) => JSON.decode(response)['message'];

main() async {
  react_client.setClientConfiguration();
  configureWTransportForBrowser();

  renderGlobalExampleMenu(serverStatus: true);

  WSocket webSocket;

  // Send message upon form submit
  (querySelector('#prompt-form') as FormElement).onSubmit.listen((e) {
    e.preventDefault();

    if (webSocket == null) return;

    String message = (querySelector('#prompt') as TextInputElement).value;
    querySelector('#logs').appendText('> $message\n');
    webSocket.add(_echo(message));
  });

  try {
    webSocket = await WSocket.connect(wsServer);

    // Display messages from web socket
    webSocket.listen((message) {
      querySelector('#logs').appendText('${_unecho(message)}\n');
    });
  } on WSocketException catch (e, stackTrace) {
    querySelector('#logs')
        .appendText('> ERROR: Could not connect to web socket on $wsServer');
    print('Could not connect to web socket.\n$e\n$stackTrace');
  }

  // Remove the loading overlay
  removeLoadingOverlay();
}
