library w_transport.src.configuration.configuration_server;

import 'package:w_transport/src/configuration/configuration.dart'
    show isConfigurationSet;
import 'package:w_transport/src/http/w_http_server.dart'
    show configureWHttpForServer;
import 'package:w_transport/src/web_socket/w_socket_server.dart'
    show configureWSocketForServer;

void configureForServer() {
  configureWHttpForServer();
  configureWSocketForServer();
  isConfigurationSet = true;
}
