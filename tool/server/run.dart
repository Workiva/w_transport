library w_transport.tool.server.run;

import 'package:args/args.dart';

import './proxy.dart';
import './handlers/example/http/cross_origin_credentials_handlers.dart' show exampleHttpCrossOriginCredentialsRoutes;
import './handlers/example/http/cross_origin_file_transfer_handlers.dart' show exampleHttpCrossOriginFileTransferRoutes;
import './handlers/ping_handler.dart' show PingHandler;
import './handlers/test/http/routes.dart' show testHttpIntegrationRoutes;
import './logger.dart';
import './router.dart';
import './server.dart';


void startServer() {
  List<List<Route>> routeLists = [
    /// META Endpoints

    /// Allows clients to ping server to ensure it's running.
    [new Route('ping', new PingHandler())],

    /// EXAMPLES

    /// Cross Origin Credentials
    exampleHttpCrossOriginCredentialsRoutes,
    /// Cross Origin File Transfer
    exampleHttpCrossOriginFileTransferRoutes,

    /// TESTS

    /// HTTP Integration
    testHttpIntegrationRoutes
  ];
  List<Route> routes = [];
  routeLists.forEach((list) => routes.addAll(list));

  Router router = new Router(routes);
  Logger logger = new Logger('Server', cyan: true);
  Server.start('Server', 'localhost', 8024, router, logger);
}


void main(List<String> args) {
  ArgParser parser = new ArgParser();
  parser.addFlag('proxy', abbr: 'p');
  var parsedArgs = parser.parse(args);

  startServer();

  if (parsedArgs['proxy']) {
    startProxy();
  }
}