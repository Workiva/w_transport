library http_server.handlers;

import 'dart:convert';
import 'dart:io';
import 'http_server_constants.dart';


class Handler {

  Object defaultResponse = null;
  int defaultStatusCode = HttpStatus.METHOD_NOT_ALLOWED;

  void handleRequest(HttpRequest request, {void onDone()}) {
    switch (request.method.toUpperCase()) {
      case 'DELETE': delete(request); break;
      case 'GET': get(request); break;
      case 'HEAD': head(request); break;
      case 'OPTIONS': options(request); break;
      case 'PATCH': patch(request); break;
      case 'POST': post(request); break;
      case 'PUT': put(request); break;
      case 'TRACE': trace(request); break;
      default: _writeResponse(request); break;
    }
    onDone();
  }

  void delete(HttpRequest request) { _writeResponse(request); }
  void get(HttpRequest request) { _writeResponse(request); }
  void head(HttpRequest request) { _writeResponse(request); }
  void options(HttpRequest request) { _writeResponse(request); }
  void patch(HttpRequest request) { _writeResponse(request); }
  void post(HttpRequest request) { _writeResponse(request); }
  void put(HttpRequest request) { _writeResponse(request); }
  void trace(HttpRequest request) { _writeResponse(request); }

  void _writeResponse(HttpRequest request) {
    request.response.statusCode = defaultStatusCode;
    if (defaultResponse != null) {
      request.response.write(defaultResponse);
    }
  }

}

class CorsSupport {

  void setCorsHeaders(HttpRequest request) {
    request.response.headers.set('Access-Control-Allow-Origin', request.headers.value('Origin'));
    request.response.headers.set('Access-Control-Allow-Headers', request.headers.value('Access-Control-Request-Headers'));
    request.response.headers.set('Access-Control-Allow-Methods', [
        'DELETE',
        'GET',
        'HEAD',
        'OPTIONS',
        'PATCH',
        'POST',
        'PUT',
        'TRACE',
    ].join(', '));
  }

}

class CorsHandler extends Handler with CorsSupport {

  void handleRequest(HttpRequest request, {void onDone()}) {
    setCorsHeaders(request);
    super.handleRequest(request, onDone: onDone);
  }
}


class OkHandler extends CorsHandler {

  int defaultStatusCode = HttpStatus.OK;

}


class PingHandler extends CorsHandler {

  void get(HttpRequest request) {
    request.response.statusCode = HttpStatus.OK;
    request.response.write(pingResponse);
  }

}


class ReflectHandler extends CorsHandler {

  void handleRequest(HttpRequest request, {void onDone()}) {
    setCorsHeaders(request);
    request.response.statusCode = HttpStatus.OK;

    Map reflection = {
        'method': request.method,
        'path': request.uri.path,
        'headers': request.headers.toString(),
        'body': ''
    };

    request.transform(new Utf8Decoder()).listen((Object body) {
      reflection['body'] = '${reflection['body']}$body';
    }, onDone: () {
      request.response.write(JSON.encode(reflection));
      onDone();
    });
  }

}