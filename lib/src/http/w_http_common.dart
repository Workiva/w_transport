/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/// Common HTTP logic pieces.
library w_transport.lib.src.http.w_http_common;

import 'dart:async';
import 'dart:convert';

import 'w_http.dart';

bool _configurationSet = false;

void verifyWHttpConfigurationIsSet() {
  if (!_configurationSet) throw new StateError(
      'w_transport configuration must be set prior to use. ' +
          'Import \'package:w_transport/w_transport_client.dart\' ' +
          'or \'package:w_transport/w_transport_server.dart\' and call ' +
          'configureWTransportForBrowser() or configureWTransportForServer()');
}

void abort(request) {
  verifyWHttpConfigurationIsSet();
  _abort(request);
}
typedef void RequestAborter(request);
RequestAborter _abort;

getNewHttpClient() {
  verifyWHttpConfigurationIsSet();
  return _getNewHttpClient();
}
typedef HttpClientFactory();
HttpClientFactory _getNewHttpClient;

Map<String, String> parseResponseHeaders(response) {
  verifyWHttpConfigurationIsSet();
  return _parseResponseHeaders(response);
}
typedef Map<String, String> ResponseHeadersParser(response);
ResponseHeadersParser _parseResponseHeaders;

int parseResponseStatus(response) {
  verifyWHttpConfigurationIsSet();
  return _parseResponseStatus(response);
}
typedef int ResponseStatusParser(response);
ResponseStatusParser _parseResponseStatus;

String parseResponseStatusText(response) {
  verifyWHttpConfigurationIsSet();
  return _parseResponseStatusText(response);
}
typedef String ResponseStatusTextParser(response);
ResponseStatusTextParser _parseResponseStatusText;

Future<Object> parseResponseData(response, int total,
    StreamController<WProgress> downloadProgressController) {
  verifyWHttpConfigurationIsSet();
  return _parseResponseData(response, total, downloadProgressController);
}
typedef Future<Object> ResponseDataParser(response, int total,
    StreamController<WProgress> downloadProgressController);
ResponseDataParser _parseResponseData;

Future<String> parseResponseText(response, Encoding encoding, int total,
    StreamController<WProgress> downloadProgressController) {
  verifyWHttpConfigurationIsSet();
  return _parseResponseText(
      response, encoding, total, downloadProgressController);
}
typedef Future<String> ResponseTextParser(response, Encoding encoding,
    int total, StreamController<WProgress> downloadProgressController);
ResponseTextParser _parseResponseText;

Stream parseResponseStream(response, int total,
    StreamController<WProgress> downloadProgressController) {
  verifyWHttpConfigurationIsSet();
  return _parseResponseStream(response, total, downloadProgressController);
}
typedef Stream ResponseStreamParser(response, int total,
    StreamController<WProgress> downloadProgressController);
ResponseStreamParser _parseResponseStream;

Future openRequest(String method, Uri uri, [client]) {
  verifyWHttpConfigurationIsSet();
  return _openRequest(method, uri, client);
}
typedef Future RequestOpener(String method, Uri uri, [client]);
RequestOpener _openRequest;

Future<WResponse> send(String method, WRequest wRequest, request,
    StreamController<WProgress> downloadProgressController,
    StreamController<WProgress> uploadProgressController,
    [RequestConfigurer configure]) async {
  verifyWHttpConfigurationIsSet();
  return _send(method, wRequest, request, downloadProgressController,
      uploadProgressController, configure);
}
typedef RequestConfigurer(request);
typedef Future<WResponse> RequestSender(String method, WRequest wRequest,
    request, StreamController<WProgress> downloadProgressController,
    StreamController<WProgress> uploadProgressController,
    [RequestConfigurer configure]);
RequestSender _send;

void validateDataType(Object data) {
  verifyWHttpConfigurationIsSet();
  _validateDataType(data);
}
typedef void DataTypeValidator(Object data);
DataTypeValidator _validateDataType;

/// Configures the w_http library for use on a particular platform
/// (client or server) by providing concrete implementations for all
/// of the above pieces of HTTP logic.
void configureWHttp(RequestAborter abort, HttpClientFactory getNewHttpClient,
    ResponseHeadersParser parseResponseHeaders,
    ResponseStatusParser parseResponseStatus,
    ResponseStatusTextParser parseResponseStatusText,
    ResponseDataParser parseResponseData, ResponseTextParser parseResponseText,
    ResponseStreamParser parseResponseStream, RequestOpener openRequest,
    RequestSender send, DataTypeValidator validateDataType) {
  _configurationSet = true;

  _abort = abort;
  _getNewHttpClient = getNewHttpClient;
  _parseResponseHeaders = parseResponseHeaders;
  _parseResponseStatus = parseResponseStatus;
  _parseResponseStatusText = parseResponseStatusText;
  _parseResponseData = parseResponseData;
  _parseResponseText = parseResponseText;
  _parseResponseStream = parseResponseStream;
  _openRequest = openRequest;
  _send = send;
  _validateDataType = validateDataType;
}
