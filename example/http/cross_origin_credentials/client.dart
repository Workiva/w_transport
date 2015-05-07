library w_transport.example.http.cross_origin_credentials.client;

import 'package:react/react_client.dart' as react_client;

import '../../common/global_example_menu_component.dart';
import '../../common/loading_component.dart';
import './dom.dart' as dom;
import './service.dart' as service;
import './status.dart' as status;


/// Setup the example application.
main() async {
  react_client.setClientConfiguration();
  renderGlobalExampleMenu(serverStatus: true);
  dom.setupControlBindings();
  removeLoadingOverlay();

  // Check auth status right away to see if valid session already exists
  status.authenticated = await service.checkStatus();
  if (status.authenticated) {
    dom.updateAuthenticationStatus();
    dom.updateToggleAuthButton();
    dom.display('Logged in.', true);
  }
}