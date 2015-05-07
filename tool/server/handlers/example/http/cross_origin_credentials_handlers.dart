library w_transport.tool.server.handlers.example.http.cross_origin_credentials_handlers;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:uuid/uuid.dart';

import '../../../handler.dart';
import '../../../router.dart';

String pathPrefix = 'example/http/cross_origin_credentials';

List<Route> exampleHttpCrossOriginCredentialsRoutes = [
  new Route('$pathPrefix/session', new SessionHandler()),
  new Route('$pathPrefix/credentialed', new CredentialedRequestHandler())
];

String session;
String generateSessionCookie() {
  session = new Uuid().v4();
  return session;
}

bool isValidSession(shelf.Request request) {
  if (session == null) {
    return false;
  }
  bool validSession = false;
  String cookieStr = request.headers['cookie'];
  if (cookieStr != null) {
    cookieStr.split('; ').forEach((String cookie) {
      List<String> parts = cookie.split('=');
      if (parts[0] == 'session') {
        if (parts[1] == session) {
          validSession = true;
        }
      }
    });
  }
  return validSession;
}

class SessionHandler extends Handler {
  SessionHandler() : super() {
    enableCors(credentials: true);
  }

  Map createSessionHeaders(String sessionCookieValue) {
    Cookie sessionCookie = new Cookie('session', sessionCookieValue);
    sessionCookie.httpOnly = true;
    sessionCookie.path = '/';
    return {'set-cookie': sessionCookie.toString()};
  }

  Future<shelf.Response> get(shelf.Request request) async {
    return new shelf.Response.ok(
        JSON.encode({'authenticated': isValidSession(request)}));
  }

  Future<shelf.Response> post(shelf.Request request) async {
    Map<String, String> headers = createSessionHeaders(generateSessionCookie());
    return new shelf.Response.ok(JSON.encode({'authenticated': true}),
        headers: headers);
  }

  Future<shelf.Response> delete(shelf.Request request) async {
    session = null;
    Map<String, String> headers = createSessionHeaders('deleted');
    return new shelf.Response.ok(JSON.encode({'authenticated': false}),
        headers: headers);
  }
}

class CredentialedRequestHandler extends Handler {
  CredentialedRequestHandler() : super() {
    enableCors(credentials: true);
  }

  Future<shelf.Response> get(shelf.Request request) async {
    // Verify the request has a valid session cookie
    if (isValidSession(request)) {
      return new shelf.Response.ok(
          'Session verified, credentialed request successful!');
    } else {
      return new shelf.Response(HttpStatus.UNAUTHORIZED,
          body: 'Invalid session, credentialed request failed!');
    }
  }
}
