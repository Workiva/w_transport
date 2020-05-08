// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsBridgeGenerator
// **************************************************************************

dynamic _$bridgeResponseToJs(Response dartObj) {
  final jsObj = newObject();
  defineProperty(jsObj, 'body',
      PropertyDescriptor(get: allowInterop(() => dartObj.body.toJs())));
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(jsObj, 'status',
      PropertyDescriptor(get: allowInterop(() => dartObj.status)));
  defineProperty(jsObj, 'statusText',
      PropertyDescriptor(get: allowInterop(() => dartObj.statusText)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  setProperty(jsObj, 'replace', allowInterop(([$named]) {
    return dartObj
        .replace(
            bodyBytes: List.from(nullSafeGetProperty($named, 'bodyBytes')),
            bodyString: nullSafeGetProperty($named, 'bodyString'),
            status: nullSafeGetProperty($named, 'status'),
            statusText: nullSafeGetProperty($named, 'statusText'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')))
        .toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  return jsObj;
}

dynamic _$bridgeStreamedResponseToJs(StreamedResponse dartObj) {
  final jsObj = newObject();
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(jsObj, 'status',
      PropertyDescriptor(get: allowInterop(() => dartObj.status)));
  defineProperty(jsObj, 'statusText',
      PropertyDescriptor(get: allowInterop(() => dartObj.statusText)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  setProperty(jsObj, 'replace', allowInterop(([$named]) {
    return dartObj
        .replace(
            byteStream: null,
            status: nullSafeGetProperty($named, 'status'),
            statusText: nullSafeGetProperty($named, 'statusText'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')))
        .toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  return jsObj;
}
