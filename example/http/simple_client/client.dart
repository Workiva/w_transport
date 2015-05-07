library w_transport.example.http.simple_client.client;

import 'dart:async';
import 'dart:html';

import 'package:react/react_client.dart' as react_client;
import 'package:w_transport/w_http_client.dart';

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
  WResponse response = await new WRequest().get(Uri.parse(filePath));
  return response.text;
}

/// Displays the file contents in the response pane.
void showFileContents(String contents) {
  querySelector('#response').text = contents;
}


void main() {
  react_client.setClientConfiguration();
  renderGlobalExampleMenu();

  // Wire all anchors up to the file click handler
  querySelectorAll('a.file').forEach((Element elem) {
    elem.onClick.listen(handleFileClick);
  });

  // Remove the loading overlay
  removeLoadingOverlay();
}