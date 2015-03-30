library http_server.constants;


String httpServerHost = 'localhost';
int httpServerPort = 8024;
String httpServerAddress = 'http://$httpServerHost:$httpServerPort';
String pingResponse = 'ping';

class Routes {
  // Returns a 200 OK for everything
  static String ok = '/ok';

  // Returns a 200 OK with a 'ping' response for a GET request
  static String ping = '/ping';

  // Returns a reflection of the request in the response
  static String reflect = '/reflect';
}