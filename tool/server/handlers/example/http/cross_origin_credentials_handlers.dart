// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../handler.dart';

String pathPrefix = '/example/http/cross_origin_credentials';

Map<String, Handler> exampleHttpCrossOriginCredentialsRoutes = {
  '$pathPrefix/session': new SessionHandler(),
  '$pathPrefix/credentialed': new CredentialedRequestHandler()
};

String session;
String generateSessionCookie() {
  session = new Uuid().v4();
  return session;
}

bool isValidSession(HttpRequest request) {
  if (session == null) {
    return false;
  }
  bool validSession = false;
  request.cookies.forEach((Cookie cookie) {
    if (cookie.name == 'session') {
      if (cookie.value == session) {
        validSession = true;
      }
    }
  });
  return validSession;
}

class SessionHandler extends Handler {
  SessionHandler() : super() {
    enableCors(credentials: true);
  }

  Map<String, String> createSessionHeaders(String sessionCookieValue) {
    Cookie sessionCookie = new Cookie('session', sessionCookieValue);
    sessionCookie.httpOnly = true;
    sessionCookie.path = '/';
    return {'set-cookie': sessionCookie.toString()};
  }

  @override
  Future<Null> get(HttpRequest request) async {
    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
    request.response
        .write(JSON.encode({'authenticated': isValidSession(request)}));
  }

  @override
  Future<Null> post(HttpRequest request) async {
    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
    final headers = createSessionHeaders(generateSessionCookie());
    headers.forEach((h, v) {
      request.response.headers.set(h, v);
    });
    request.response.write(JSON.encode({'authenticated': true}));
  }

  @override
  Future<Null> delete(HttpRequest request) async {
    session = null;
    request.response.statusCode = HttpStatus.OK;
    setCorsHeaders(request);
    final headers = createSessionHeaders('deleted');
    headers.forEach((h, v) {
      request.response.headers.set(h, v);
    });
    request.response.write(JSON.encode({'authenticated': false}));
  }
}

class CredentialedRequestHandler extends Handler {
  CredentialedRequestHandler() : super() {
    enableCors(credentials: true);
  }

  @override
  Future<Null> get(HttpRequest request) async {
    // Verify the request has a valid session cookie
    if (isValidSession(request)) {
      request.response.statusCode = HttpStatus.OK;
      setCorsHeaders(request);
      request.response
          .write('Session verified, credentialed request successful!');
    } else {
      request.response.statusCode = HttpStatus.UNAUTHORIZED;
      setCorsHeaders(request);
      request.response.write('Invalid session, credentialed request failed!');
    }
  }
}
