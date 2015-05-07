import '../../../router.dart';
import './ping_handler.dart';
import './reflect_handler.dart';

String pathPrefix = 'test/http';
List<Route> testHttpIntegrationRoutes = [
  new Route('$pathPrefix/ping', new PingHandler()),
  new Route('$pathPrefix/reflect', new ReflectHandler())
];
