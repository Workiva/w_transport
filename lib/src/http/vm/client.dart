library w_transport.src.http.vm.client;

import 'dart:io';

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/client.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/vm/requests.dart';

/// VM-specific implementation of an HTTP client. All requests created from this
/// client will use the same dart:io.HttpClient. This allows for network
/// connections to be cached.
class VMClient extends CommonClient implements Client {
  /// The underlying HTTP client used to open and send requests.
  HttpClient _client = new HttpClient();

  /// Close the underlying HTTP client.
  @override
  void closeClient() {
    if (_client != null) {
      _client.close();
    }
  }

  /// Constructs a new [FormRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  FormRequest newFormRequest() {
    verifyNotClosed();
    FormRequest request = new VMFormRequest.withClient(_client);
    registerRequest(request);
    return request;
  }

  /// Constructs a new [JsonRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  JsonRequest newJsonRequest() {
    verifyNotClosed();
    JsonRequest request = new VMJsonRequest.withClient(_client);
    registerRequest(request);
    return request;
  }

  /// Constructs a new [MultipartRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  MultipartRequest newMultipartRequest() {
    verifyNotClosed();
    MultipartRequest request = new VMMultipartRequest.withClient(_client);
    registerRequest(request);
    return request;
  }

  /// Constructs a new [Request] that will use this client to send the request.
  /// Throws a [StateError] if this client has been closed.
  @override
  Request newRequest() {
    verifyNotClosed();
    Request request = new VMPlainTextRequest.withClient(_client);
    registerRequest(request);
    return request;
  }

  /// Constructs a new [StreamedRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  @override
  StreamedRequest newStreamedRequest() {
    verifyNotClosed();
    StreamedRequest request = new VMStreamedRequest.withClient(_client);
    registerRequest(request);
    return request;
  }
}
