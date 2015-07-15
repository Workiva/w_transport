library w_transport.src.configuration.configuration_client;

import 'package:w_transport/src/configuration/configuration.dart'
    show isConfigurationSet;
import 'package:w_transport/src/http/w_http_client.dart'
    show configureWHttpForBrowser;
import 'package:w_transport/src/web_socket/w_socket_client.dart'
    show configureWSocketForBrowser;

void configureForBrowser() {
  configureWHttpForBrowser();
  configureWSocketForBrowser();
  isConfigurationSet = true;
}
