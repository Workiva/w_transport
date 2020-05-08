// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_body.dart';

// **************************************************************************
// JsBridgeGenerator
// **************************************************************************

dynamic _$bridgeHttpBodyToJs(HttpBody dartObj) {
  final jsObj = newObject();
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  setProperty(jsObj, 'asString', allowInterop(() {
    return dartObj.asString();
  }));
  setProperty(jsObj, 'asJson', allowInterop(() {
    return jsify(dartObj.asJson());
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  return jsObj;
}
