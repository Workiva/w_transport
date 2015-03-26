library w_transport.example.http.cross_origin_file_transfer.client;

import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as react_client;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';
import './components/app_component.dart';


void main() {
  // Setup and bootstrap the react app
  react_client.setClientConfiguration();
  renderGlobalExampleMenu(serverStatus: true, proxyStatus: true);
  Element container = querySelector('#app');
  react.render(appComponent({}), container);
  removeLoadingOverlay();
}