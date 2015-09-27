library w_transport.src.http.client;

import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/platform_adapter.dart';

// TODO: abort all in-flight requests when closed

abstract class Client {
  factory Client() => PlatformAdapter.retrieve().newClient();

  /// Whether or not the HTTP client has been closed.
  bool get isClosed;

  /// Closes the client, cancelling or closing any outstanding connections.
  void close();

  /// Constructs a new [FormRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  FormRequest newFormRequest();

  /// Constructs a new [JsonRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  JsonRequest newJsonRequest();

  /// Constructs a new [MultipartRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  MultipartRequest newMultipartRequest();

  /// Constructs a new [Request] that will use this client to send the request.
  /// Throws a [StateError] if this client has been closed.
  Request newRequest();

  /// Constructs a new [StreamedRequest] that will use this client to send the
  /// request. Throws a [StateError] if this client has been closed.
  StreamedRequest newStreamedRequest();
}