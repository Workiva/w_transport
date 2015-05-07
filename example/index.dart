library w_transport.example.index;

import 'package:react/react_client.dart' as react_client;

import './common/global_example_menu_component.dart';
import './common/loading_component.dart';


void main() {
  react_client.setClientConfiguration();
  renderGlobalExampleMenu(nav: false, serverStatus: true, proxyStatus: true);
  removeLoadingOverlay();
}