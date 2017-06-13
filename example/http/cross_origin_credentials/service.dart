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

library w_transport.example.http.cross_origin_credentials.service;

import 'dart:async';

import 'package:w_transport/w_transport.dart';

/// URLs for this cross origin credentials example.
Uri authenticationServerUrl = Uri.parse('http://localhost:8024');
String pathPrefix = '/example/http/cross_origin_credentials';
Uri sessionUrl = authenticationServerUrl.replace(path: '$pathPrefix/session');
Uri credentialedEndpointUrl =
    authenticationServerUrl.replace(path: '$pathPrefix/credentialed');

/// Send a request to the /session endpoint to check authentication status.
/// Returns true if authenticated, false otherwise.
Future<bool> checkStatus() async {
  Request req = new Request()..withCredentials = true;

  try {
    Response response = await req.get(uri: sessionUrl);
    return response.body.asJson()['authenticated'];
  } catch (error) {
    // Server probably isn't running
    return false;
  }
}

/// Login by sending a POST request to the /session endpoint.
Future<bool> login() async {
  Request req = new Request()..withCredentials = true;
  Response response;
  try {
    response = await req.post(uri: sessionUrl);
  } catch (e) {
    return false;
  }
  return response.status == 200 && response.body.asJson()['authenticated'];
}

/// Logout by sending a request to the /logout endpoint.
Future<bool> logout() async {
  Request req = new Request()..withCredentials = true;
  Response response;
  try {
    response = await req.delete(uri: sessionUrl);
  } catch (e) {
    return false;
  }
  return response.status == 200 && !response.body.asJson()['authenticated'];
}

/// Attempt to make a request that requires credentials.
/// This request sets the `withCredentials` flag, which
/// means the session HTTP cookie (if set) will be included.
/// Thus, if authenticated, this request should succeed.
Future<String> makeCredentialedRequest() async {
  Request req = new Request()..withCredentials = true;

  Response response;
  response = await req.get(uri: credentialedEndpointUrl);
  return response.body.asString();
}

/// Attempt to make a request that requires credentials,
/// but without setting the `withCredentials` flag.
/// This request should fail regardless of authentication.
Future<String> makeUncredentialedRequest() async {
  // withCredentials is unset by default, so no need to do anything special here
  Response response = await Http.get(credentialedEndpointUrl);
  return response.body.asString();
}
