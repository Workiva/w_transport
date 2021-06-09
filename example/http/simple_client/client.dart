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
import 'dart:html';

import 'package:w_transport/w_transport.dart';
import 'package:w_transport/browser.dart' show configureWTransportForBrowser;

import '../../common/global_example_menu.dart';
import '../../common/loading_component.dart';

/// Handle clicks on file names.
/// Sends a GET request to retrieve the file contents,
/// then displays the contents in the response pane.
Future<Null> handleFileClick(MouseEvent event) async {
  // Prevent link navigation
  event.preventDefault();

  // Grab file path from anchor element
  final AnchorElement anchor = event.target;
  final filePath = anchor.href;

  // Send GET request instead
  try {
    showFileContents(await requestFile(filePath));
  } on RequestException catch (error) {
    showFileContents(error.message);
  }
}

/// Requests the contents of a file using WRequest.
Future<String> requestFile(String filePath) async {
  final response = await Http.get(Uri.parse(filePath));
  return response.body.asString();
}

/// Displays the file contents in the response pane.
void showFileContents(String contents) {
  querySelector('#response').text = contents;
}

void main() {
  configureWTransportForBrowser();

  renderGlobalExampleMenu();

  // Wire all anchors up to the file click handler
  for (Element elem in querySelectorAll('a.file')) {
    elem.onClick.listen(handleFileClick);
  }

  // Remove the loading overlay
  removeLoadingOverlay();
}
