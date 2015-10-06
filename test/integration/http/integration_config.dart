library w_transport.test.integration.http.integration_config;

import '../../naming.dart';

class HttpIntegrationConfig {
  final Uri hostUri = Uri.parse('http://localhost:8024');

  final String platform;

  HttpIntegrationConfig.browser() : platform = platformBrowser;
  HttpIntegrationConfig.mock() : platform = platformMock;
  HttpIntegrationConfig.vm() : platform = platformVM;

  Uri get downloadEndpointUri => hostUri.replace(path: '/test/http/download');

  Uri get echoEndpointUri => hostUri.replace(path: '/test/http/echo');

  Uri get fourOhFourEndpointUri => hostUri.replace(path: '/test/http/404');

  Uri get pingEndpointUri => hostUri.replace(path: '/test/http/ping');

  Uri get reflectEndpointUri => hostUri.replace(path: '/test/http/reflect');

  Uri get timeoutEndpointUri => hostUri.replace(path: '/test/http/timeout');

  Uri get uploadEndpointUri => hostUri.replace(path: '/test/http/upload');

  String get title => 'HTTP ($platform):';
}
