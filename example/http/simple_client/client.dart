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

library w_transport.example.http.simple_client.client;

import 'dart:async';
import 'dart:html';

import 'package:react/react_client.dart' as react_client;
import 'package:w_transport/w_http.dart';
import 'package:w_transport/w_transport_client.dart' show configureWTransportForBrowser;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';

/// Handle clicks on file names.
/// Sends a GET request to retrieve the file contents,
/// then displays the contents in the response pane.
handleFileClick(MouseEvent event) async {
  // Prevent link navigation
  event.preventDefault();

  // Grab file path from anchor element
  AnchorElement anchor = event.target;
  String filePath = anchor.href;

  // Send GET request instead
  try {
    showFileContents(await requestFile(filePath));
  } on WHttpException catch (error) {
    showFileContents(error.message);
  }
}

/// Requests the contents of a file using WRequest.
Future<String> requestFile(String filePath) async {
  WResponse response = await WHttp.get(Uri.parse(filePath));
  return response.text;
}

/// Displays the file contents in the response pane.
void showFileContents(String contents) {
  querySelector('#response').text = contents;
}

void main() {
  react_client.setClientConfiguration();
  configureWTransportForBrowser();

  renderGlobalExampleMenu();

  // Wire all anchors up to the file click handler
  querySelectorAll('a.file').forEach((Element elem) {
    elem.onClick.listen(handleFileClick);
  });

  // Remove the loading overlay
  removeLoadingOverlay();
}
