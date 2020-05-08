// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_client.dart';

// **************************************************************************
// JsBridgeGenerator
// **************************************************************************

dynamic _$bridgeHttpClientToJs(HttpClient dartObj) {
  final jsObj = newObject();
  defineProperty(jsObj, 'baseUri',
      PropertyDescriptor(get: allowInterop(() => uriToUrl(dartObj.baseUri))));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  defineProperty(jsObj, 'withCredentials',
      PropertyDescriptor(get: allowInterop(() => dartObj.withCredentials)));
  defineProperty(jsObj, 'isClosed',
      PropertyDescriptor(get: allowInterop(() => dartObj.isClosed)));
  setProperty(jsObj, 'close', allowInterop(() {
    dartObj.close();
  }));
  setProperty(jsObj, 'newFormRequest', allowInterop(() {
    return dartObj.newFormRequest().toJs();
  }));
  setProperty(jsObj, 'newJsonRequest', allowInterop(() {
    return dartObj.newJsonRequest().toJs();
  }));
  setProperty(jsObj, 'newMultipartRequest', allowInterop(() {
    return dartObj.newMultipartRequest().toJs();
  }));
  setProperty(jsObj, 'newRequest', allowInterop(() {
    return dartObj.newRequest().toJs();
  }));
  setProperty(jsObj, 'newStreamedRequest', allowInterop(() {
    return dartObj.newStreamedRequest().toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  return jsObj;
}
