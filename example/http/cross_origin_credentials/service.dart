library w_transport.example.http.cross_origin_credentials.service;

import 'dart:async';
import 'dart:convert';

import 'package:w_transport/w_http_client.dart';


/// URLs for this cross origin credentials example.
Uri authenticationServerUrl = Uri.parse('http://localhost:8024');
String pathPrefix = '/example/http/cross_origin_credentials';
Uri sessionUrl = authenticationServerUrl.replace(path: '$pathPrefix/session');
Uri credentialedEndpointUrl = authenticationServerUrl.replace(path: '$pathPrefix/credentialed');


/// Send a request to the /session endpoint to check authentication status.
/// Returns true if authenticated, false otherwise.
Future<bool> checkStatus() async {
  WRequest req = new WRequest()
    ..withCredentials = true;

  try {
    WResponse response = await req.get(sessionUrl);
    return JSON.decode(response.text)['authenticated'];
  } catch (error) {
    // Server probably isn't running
    return false;
  }
  return false;
}

/// Login by sending a POST request to the /session endpoint.
Future<bool> login() async {
  WRequest req = new WRequest()..withCredentials = true;
  WResponse response;
  try {
    response = await req.post(sessionUrl);
  } catch (e) {
    return false;
  }
  return response.status == 200 && JSON.decode(response.text)['authenticated'];
}

/// Logout by sending a request to the /logout endpoint.
Future<bool> logout() async {
  WRequest req = new WRequest()..withCredentials = true;
  WResponse response;
  try {
    response = await req.delete(sessionUrl);
  } catch (e) {
    return false;
  }
  return response.status == 200 && !JSON.decode(response.text)['authenticated'];
}

/// Attempt to make a request that requires credentials.
/// This request sets the `withCredentials` flag, which
/// means the session HTTP cookie (if set) will be included.
/// Thus, if authenticated, this request should succeed.
Future<String> makeCredentialedRequest() async {
  WRequest req = new WRequest()
    ..withCredentials = true;

  WResponse response;
  response = await req.get(credentialedEndpointUrl);
  return response.text;
}

/// Attempt to make a request that requires credentials,
/// but without setting the `withCredentials` flag.
/// This request should fail regardless of authentication.
Future<String> makeUncredentialedRequest() async {
  // withCredentials is unset by default, so no need to do anything special here
  WRequest req = new WRequest();

  WResponse response;
  response = await req.get(credentialedEndpointUrl);
  return response.text;
}
