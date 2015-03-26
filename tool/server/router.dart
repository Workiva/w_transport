library w_transport.tool.server.router;

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;

import 'handler.dart';


/// Simple mapping of a path to a handler.
class Route {
  String path;
  Handler handler;
  Route(this.path, this.handler);
}


/// Routes incoming HTTP requests to a handler based on
/// a routing table supplied upon construction.
/// If a matching patch can't be found for a request,
/// a "404 Not Found" response is delivered.
///
/// An HttpServer can be piped directly to an instance of Router.
class Router {
  StreamController _controller;
  Map<String, Route> _routes;

  Router(List<Route> routes) {
    _routes = new Map<String, Route>();
    routes.forEach((Route route) {
      _routes[route.path] = route;
    });
  }

  Future route(shelf.Request request) async {
    if (_routes.containsKey(request.url.path)) {
      return _routes[request.url.path].handler.processRequest(request);
    }
    return new shelf.Response.notFound('');
  }
}