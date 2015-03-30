library w_http.w_http;

// Dart imports
import 'dart:async';


abstract class IWHttp {

  IWHttp url(Uri url);
  IWHttp data(Object data);
  IWHttp headers(Map<String, String> headers);
  IWHttp header(String header, String value);
  IWHttp prepare(dynamic prepareRequest(dynamic request));

  Future<IWResponse> delete([Uri url]);
  Future<IWResponse> get([Uri url]);
  Future<IWResponse> head([Uri url]);
  Future<IWResponse> options([Uri url]);
  Future<IWResponse> patch([Uri url, Object data]);
  Future<IWResponse> post([Uri url, Object data]);
  Future<IWResponse> put([Uri url, Object data]);
  Future<IWResponse> trace([Uri url]);

}


abstract class IWHttpClient {

  IWHttp newRequest();
  void close();

}


abstract class IWResponse {

  Map<String, String> get headers;
  int get status;
  String get statusText;

}