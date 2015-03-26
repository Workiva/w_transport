library http_server;

import 'dart:async';
import 'dart:io';
import 'http_handlers.dart';
import 'http_server_constants.dart';

bool dumpHeaders = true;

void logRequest(HttpRequest request) {
  print('[${new DateTime.now()}] ${request.method} ${request.requestedUri} - ${request.response.statusCode}');
  if (dumpHeaders) {
    print('\tRequest Headers:');
    request.headers.forEach((String name, List<String> values) {
      print('\t\t$name: ${values.join(', ')}');
    });
    print('\tResponse Headers:');
    request.response.headers.forEach((String name, List<String> values) {
      print('\t\t$name: ${values.join(', ')}');
    });
  }
}


class Route {
  String path;
  Handler handler;

  Route(this.path, this.handler);
}


class Router extends StreamConsumer<HttpRequest> {
  StreamController _controller;
  Map<String, Route> _routes;

  Router(List<Route> routes) {
    _routes = new Map<String, Route>();
    routes.forEach((Route route) {
      _routes[route.path] = route;
    });
  }

  Future addStream(Stream<HttpRequest> requestStream) {
    return requestStream.listen((HttpRequest request) {
      if (_routes.containsKey(request.uri.path)) {
        // Found a route handler
        _routes[request.uri.path].handler.handleRequest(request, onDone: () {
          request.response.close();
          logRequest(request);
        });
      } else {
        // 404
        request.response.statusCode = HttpStatus.NOT_FOUND;
        request.response.close();
        logRequest(request);
      }
    }).asFuture();
  }

  Future close() {
    return new Future.value();
  }
}


void main() {
  // Create a router
  Router router = new Router([
      new Route(Routes.ok, new OkHandler()),
      new Route(Routes.ping, new PingHandler()),
      new Route(Routes.reflect, new ReflectHandler()),
  ]);

  // Create an HTTP server
  HttpServer.bind(httpServerHost, httpServerPort).then((HttpServer server) {
    print('Server ready - listening on $httpServerAddress');

    // Pipe requests through the router
    server.pipe(router);
  });
}