library w_transport.src.http.request_dispatchers;

import 'dart:async';

import 'package:w_transport/src/http/response.dart';

abstract class RequestDispatchers {
  /// TODO
  Future<Response> delete({Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> get({Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> head({Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> options({Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> patch({body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> post({body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> put({body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> trace({Map<String, String> headers, Uri uri});

  /// TODO
  Future<Response> send(String method, {body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamDelete({Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamGet({Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamHead({Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamOptions({Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamPatch({body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamPost({body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamPut({body, Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamTrace({Map<String, String> headers, Uri uri});

  /// TODO
  Future<StreamedResponse> streamSend(String method, {body, Map<String, String> headers, Uri uri});
}