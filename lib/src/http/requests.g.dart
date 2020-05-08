// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// **************************************************************************
// JsBridgeGenerator
// **************************************************************************

dynamic _$bridgeFormRequestToJs(FormRequest dartObj) {
  final jsObj = newObject();
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  defineProperty(jsObj, 'withCredentials',
      PropertyDescriptor(get: allowInterop(() => dartObj.withCredentials)));
  defineProperty(
      jsObj,
      'done',
      PropertyDescriptor(
          get: allowInterop(() => futureToPromise<Null>(dartObj.done))));
  defineProperty(jsObj, 'isDone',
      PropertyDescriptor(get: allowInterop(() => dartObj.isDone)));
  defineProperty(jsObj, 'method',
      PropertyDescriptor(get: allowInterop(() => dartObj.method)));
  defineProperty(jsObj, 'uri',
      PropertyDescriptor(get: allowInterop(() => uriToUrl(dartObj.uri))));
  defineProperty(jsObj, 'scheme',
      PropertyDescriptor(get: allowInterop(() => dartObj.scheme)));
  defineProperty(
      jsObj, 'host', PropertyDescriptor(get: allowInterop(() => dartObj.host)));
  defineProperty(
      jsObj, 'port', PropertyDescriptor(get: allowInterop(() => dartObj.port)));
  defineProperty(
      jsObj, 'path', PropertyDescriptor(get: allowInterop(() => dartObj.path)));
  defineProperty(jsObj, 'query',
      PropertyDescriptor(get: allowInterop(() => dartObj.query)));
  defineProperty(
      jsObj,
      'queryParameters',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.queryParameters))));
  defineProperty(jsObj, 'fragment',
      PropertyDescriptor(get: allowInterop(() => dartObj.fragment)));
  setProperty(jsObj, 'clone', allowInterop(() {
    return dartObj.clone().toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  setProperty(jsObj, 'abort', allowInterop(() {
    dartObj.abort();
  }));
  setProperty(jsObj, 'retry', allowInterop(() {
    return futureToPromise<Response>(dartObj.retry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamRetry', allowInterop(() {
    return futureToPromise<StreamedResponse>(
        dartObj.streamRetry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'appendToPath', allowInterop((pathToAppend) {
    dartObj.appendToPath(pathToAppend);
  }));
  setProperty(jsObj, 'addPathSegment', allowInterop((pathSegment) {
    dartObj.addPathSegment(pathSegment);
  }));
  setProperty(jsObj, 'setQueryParam', allowInterop((param, value) {
    dartObj.setQueryParam(param, value);
  }));
  setProperty(jsObj, 'updateQuery',
      allowInterop((queryParametersToUpdate, [$named]) {
    dartObj.updateQuery(null,
        mergeValues: nullSafeGetProperty($named, 'mergeValues') ?? false);
  }));
  setProperty(jsObj, 'delete', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.delete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'get', allowInterop(([$named]) {
    print('getting');
    final promise = futureToPromise<Response>(
        dartObj.get(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
            (value) {
              print('value');
              value.toJs();
            });
    print('returning promise');
    return promise;
  }));
  setProperty(jsObj, 'head', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.head(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'options', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.options(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'patch', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.patch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'post', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.post(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'put', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.put(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'send', allowInterop((method, [$named]) {
    return futureToPromise<Response>(
        dartObj.send(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamDelete', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamDelete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamGet', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamGet(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamHead', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamHead(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamOptions', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamOptions(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPatch', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPatch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPost', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPost(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPut', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPut(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamSend', allowInterop((method, [$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamSend(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  return jsObj;
}

dynamic _$bridgeJsonRequestToJs(JsonRequest dartObj) {
  final jsObj = newObject();
  defineProperty(jsObj, 'body',
      PropertyDescriptor(get: allowInterop(() => jsify(dartObj.body))));
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  defineProperty(jsObj, 'withCredentials',
      PropertyDescriptor(get: allowInterop(() => dartObj.withCredentials)));
  defineProperty(
      jsObj,
      'done',
      PropertyDescriptor(
          get: allowInterop(() => futureToPromise<Null>(dartObj.done))));
  defineProperty(jsObj, 'isDone',
      PropertyDescriptor(get: allowInterop(() => dartObj.isDone)));
  defineProperty(jsObj, 'method',
      PropertyDescriptor(get: allowInterop(() => dartObj.method)));
  defineProperty(jsObj, 'uri',
      PropertyDescriptor(get: allowInterop(() => uriToUrl(dartObj.uri))));
  defineProperty(jsObj, 'scheme',
      PropertyDescriptor(get: allowInterop(() => dartObj.scheme)));
  defineProperty(
      jsObj, 'host', PropertyDescriptor(get: allowInterop(() => dartObj.host)));
  defineProperty(
      jsObj, 'port', PropertyDescriptor(get: allowInterop(() => dartObj.port)));
  defineProperty(
      jsObj, 'path', PropertyDescriptor(get: allowInterop(() => dartObj.path)));
  defineProperty(jsObj, 'query',
      PropertyDescriptor(get: allowInterop(() => dartObj.query)));
  defineProperty(
      jsObj,
      'queryParameters',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.queryParameters))));
  defineProperty(jsObj, 'fragment',
      PropertyDescriptor(get: allowInterop(() => dartObj.fragment)));
  setProperty(jsObj, 'clone', allowInterop(() {
    return dartObj.clone().toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  setProperty(jsObj, 'abort', allowInterop(() {
    dartObj.abort();
  }));
  setProperty(jsObj, 'retry', allowInterop(() {
    return futureToPromise<Response>(dartObj.retry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamRetry', allowInterop(() {
    return futureToPromise<StreamedResponse>(
        dartObj.streamRetry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'appendToPath', allowInterop((pathToAppend) {
    dartObj.appendToPath(pathToAppend);
  }));
  setProperty(jsObj, 'addPathSegment', allowInterop((pathSegment) {
    dartObj.addPathSegment(pathSegment);
  }));
  setProperty(jsObj, 'setQueryParam', allowInterop((param, value) {
    dartObj.setQueryParam(param, value);
  }));
  setProperty(jsObj, 'updateQuery',
      allowInterop((queryParametersToUpdate, [$named]) {
    dartObj.updateQuery(null,
        mergeValues: nullSafeGetProperty($named, 'mergeValues') ?? false);
  }));
  setProperty(jsObj, 'delete', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.delete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'get', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.get(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'head', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.head(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'options', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.options(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'patch', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.patch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'post', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.post(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'put', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.put(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'send', allowInterop((method, [$named]) {
    return futureToPromise<Response>(
        dartObj.send(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamDelete', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamDelete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamGet', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamGet(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamHead', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamHead(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamOptions', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamOptions(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPatch', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPatch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPost', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPost(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPut', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPut(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamSend', allowInterop((method, [$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamSend(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  return jsObj;
}

dynamic _$bridgeMultipartRequestToJs(MultipartRequest dartObj) {
  final jsObj = newObject();
  defineProperty(
      jsObj,
      'fields',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.fields))));
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  defineProperty(jsObj, 'withCredentials',
      PropertyDescriptor(get: allowInterop(() => dartObj.withCredentials)));
  defineProperty(
      jsObj,
      'done',
      PropertyDescriptor(
          get: allowInterop(() => futureToPromise<Null>(dartObj.done))));
  defineProperty(jsObj, 'isDone',
      PropertyDescriptor(get: allowInterop(() => dartObj.isDone)));
  defineProperty(jsObj, 'method',
      PropertyDescriptor(get: allowInterop(() => dartObj.method)));
  defineProperty(jsObj, 'uri',
      PropertyDescriptor(get: allowInterop(() => uriToUrl(dartObj.uri))));
  defineProperty(jsObj, 'scheme',
      PropertyDescriptor(get: allowInterop(() => dartObj.scheme)));
  defineProperty(
      jsObj, 'host', PropertyDescriptor(get: allowInterop(() => dartObj.host)));
  defineProperty(
      jsObj, 'port', PropertyDescriptor(get: allowInterop(() => dartObj.port)));
  defineProperty(
      jsObj, 'path', PropertyDescriptor(get: allowInterop(() => dartObj.path)));
  defineProperty(jsObj, 'query',
      PropertyDescriptor(get: allowInterop(() => dartObj.query)));
  defineProperty(
      jsObj,
      'queryParameters',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.queryParameters))));
  defineProperty(jsObj, 'fragment',
      PropertyDescriptor(get: allowInterop(() => dartObj.fragment)));
  setProperty(jsObj, 'clone', allowInterop(() {
    return dartObj.clone().toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  setProperty(jsObj, 'abort', allowInterop(() {
    dartObj.abort();
  }));
  setProperty(jsObj, 'retry', allowInterop(() {
    return futureToPromise<Response>(dartObj.retry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamRetry', allowInterop(() {
    return futureToPromise<StreamedResponse>(
        dartObj.streamRetry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'appendToPath', allowInterop((pathToAppend) {
    dartObj.appendToPath(pathToAppend);
  }));
  setProperty(jsObj, 'addPathSegment', allowInterop((pathSegment) {
    dartObj.addPathSegment(pathSegment);
  }));
  setProperty(jsObj, 'setQueryParam', allowInterop((param, value) {
    dartObj.setQueryParam(param, value);
  }));
  setProperty(jsObj, 'updateQuery',
      allowInterop((queryParametersToUpdate, [$named]) {
    dartObj.updateQuery(null,
        mergeValues: nullSafeGetProperty($named, 'mergeValues') ?? false);
  }));
  setProperty(jsObj, 'delete', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.delete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'get', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.get(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'head', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.head(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'options', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.options(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'patch', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.patch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'post', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.post(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'put', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.put(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'send', allowInterop((method, [$named]) {
    return futureToPromise<Response>(
        dartObj.send(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamDelete', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamDelete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamGet', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamGet(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamHead', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamHead(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamOptions', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamOptions(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPatch', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPatch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPost', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPost(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPut', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPut(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamSend', allowInterop((method, [$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamSend(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  return jsObj;
}

dynamic _$bridgeRequestToJs(Request dartObj) {
  final jsObj = newObject();
  defineProperty(
      jsObj, 'body', PropertyDescriptor(get: allowInterop(() => dartObj.body)));
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  defineProperty(jsObj, 'withCredentials',
      PropertyDescriptor(get: allowInterop(() => dartObj.withCredentials)));
  defineProperty(
      jsObj,
      'done',
      PropertyDescriptor(
          get: allowInterop(() => futureToPromise<Null>(dartObj.done))));
  defineProperty(jsObj, 'isDone',
      PropertyDescriptor(get: allowInterop(() => dartObj.isDone)));
  defineProperty(jsObj, 'method',
      PropertyDescriptor(get: allowInterop(() => dartObj.method)));
  defineProperty(jsObj, 'uri',
      PropertyDescriptor(get: allowInterop(() => uriToUrl(dartObj.uri))));
  defineProperty(jsObj, 'scheme',
      PropertyDescriptor(get: allowInterop(() => dartObj.scheme)));
  defineProperty(
      jsObj, 'host', PropertyDescriptor(get: allowInterop(() => dartObj.host)));
  defineProperty(
      jsObj, 'port', PropertyDescriptor(get: allowInterop(() => dartObj.port)));
  defineProperty(
      jsObj, 'path', PropertyDescriptor(get: allowInterop(() => dartObj.path)));
  defineProperty(jsObj, 'query',
      PropertyDescriptor(get: allowInterop(() => dartObj.query)));
  defineProperty(
      jsObj,
      'queryParameters',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.queryParameters))));
  defineProperty(jsObj, 'fragment',
      PropertyDescriptor(get: allowInterop(() => dartObj.fragment)));
  setProperty(jsObj, 'clone', allowInterop(() {
    return dartObj.clone().toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  setProperty(jsObj, 'abort', allowInterop(() {
    dartObj.abort();
  }));
  setProperty(jsObj, 'retry', allowInterop(() {
    return futureToPromise<Response>(dartObj.retry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamRetry', allowInterop(() {
    return futureToPromise<StreamedResponse>(
        dartObj.streamRetry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'appendToPath', allowInterop((pathToAppend) {
    dartObj.appendToPath(pathToAppend);
  }));
  setProperty(jsObj, 'addPathSegment', allowInterop((pathSegment) {
    dartObj.addPathSegment(pathSegment);
  }));
  setProperty(jsObj, 'setQueryParam', allowInterop((param, value) {
    dartObj.setQueryParam(param, value);
  }));
  setProperty(jsObj, 'updateQuery',
      allowInterop((queryParametersToUpdate, [$named]) {
    dartObj.updateQuery(null,
        mergeValues: nullSafeGetProperty($named, 'mergeValues') ?? false);
  }));
  setProperty(jsObj, 'delete', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.delete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'get', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.get(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'head', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.head(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'options', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.options(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'patch', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.patch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'post', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.post(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'put', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.put(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'send', allowInterop((method, [$named]) {
    return futureToPromise<Response>(
        dartObj.send(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamDelete', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamDelete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamGet', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamGet(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamHead', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamHead(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamOptions', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamOptions(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPatch', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPatch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPost', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPost(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPut', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPut(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamSend', allowInterop((method, [$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamSend(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  return jsObj;
}

dynamic _$bridgeStreamedRequestToJs(StreamedRequest dartObj) {
  final jsObj = newObject();
  defineProperty(
      jsObj,
      'body',
      PropertyDescriptor(
          get: allowInterop(() =>
              streamToEventTarget(dartObj.body, (value) => List.from(value)))));
  defineProperty(jsObj, 'contentLength',
      PropertyDescriptor(get: allowInterop(() => dartObj.contentLength)));
  defineProperty(
      jsObj,
      'headers',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.headers))));
  defineProperty(jsObj, 'withCredentials',
      PropertyDescriptor(get: allowInterop(() => dartObj.withCredentials)));
  defineProperty(
      jsObj,
      'done',
      PropertyDescriptor(
          get: allowInterop(() => futureToPromise<Null>(dartObj.done))));
  defineProperty(jsObj, 'isDone',
      PropertyDescriptor(get: allowInterop(() => dartObj.isDone)));
  defineProperty(jsObj, 'method',
      PropertyDescriptor(get: allowInterop(() => dartObj.method)));
  defineProperty(jsObj, 'uri',
      PropertyDescriptor(get: allowInterop(() => uriToUrl(dartObj.uri))));
  defineProperty(jsObj, 'scheme',
      PropertyDescriptor(get: allowInterop(() => dartObj.scheme)));
  defineProperty(
      jsObj, 'host', PropertyDescriptor(get: allowInterop(() => dartObj.host)));
  defineProperty(
      jsObj, 'port', PropertyDescriptor(get: allowInterop(() => dartObj.port)));
  defineProperty(
      jsObj, 'path', PropertyDescriptor(get: allowInterop(() => dartObj.path)));
  defineProperty(jsObj, 'query',
      PropertyDescriptor(get: allowInterop(() => dartObj.query)));
  defineProperty(
      jsObj,
      'queryParameters',
      PropertyDescriptor(
          get: allowInterop(() => mapToJs<String>(dartObj.queryParameters))));
  defineProperty(jsObj, 'fragment',
      PropertyDescriptor(get: allowInterop(() => dartObj.fragment)));
  setProperty(jsObj, 'clone', allowInterop(() {
    return dartObj.clone().toJs();
  }));
  setProperty(jsObj, 'toJs', allowInterop(() {
    return jsify(dartObj.toJs());
  }));
  setProperty(jsObj, 'abort', allowInterop(() {
    dartObj.abort();
  }));
  setProperty(jsObj, 'retry', allowInterop(() {
    return futureToPromise<Response>(dartObj.retry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamRetry', allowInterop(() {
    return futureToPromise<StreamedResponse>(
        dartObj.streamRetry(), (value) => value.toJs());
  }));
  setProperty(jsObj, 'appendToPath', allowInterop((pathToAppend) {
    dartObj.appendToPath(pathToAppend);
  }));
  setProperty(jsObj, 'addPathSegment', allowInterop((pathSegment) {
    dartObj.addPathSegment(pathSegment);
  }));
  setProperty(jsObj, 'setQueryParam', allowInterop((param, value) {
    dartObj.setQueryParam(param, value);
  }));
  setProperty(jsObj, 'updateQuery',
      allowInterop((queryParametersToUpdate, [$named]) {
    dartObj.updateQuery(null,
        mergeValues: nullSafeGetProperty($named, 'mergeValues') ?? false);
  }));
  setProperty(jsObj, 'delete', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.delete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'get', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.get(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'head', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.head(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'options', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.options(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'patch', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.patch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'post', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.post(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'put', allowInterop(([$named]) {
    return futureToPromise<Response>(
        dartObj.put(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'send', allowInterop((method, [$named]) {
    return futureToPromise<Response>(
        dartObj.send(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamDelete', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamDelete(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamGet', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamGet(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamHead', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamHead(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamOptions', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamOptions(
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPatch', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPatch(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPost', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPost(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamPut', allowInterop(([$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamPut(
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  setProperty(jsObj, 'streamSend', allowInterop((method, [$named]) {
    return futureToPromise<StreamedResponse>(
        dartObj.streamSend(method,
            body: nullSafeGetProperty($named, 'body'),
            headers: mapFromJs<String>(nullSafeGetProperty($named, 'headers')),
            uri: urlToUri(nullSafeGetProperty($named, 'uri'))),
        (value) => value.toJs());
  }));
  return jsObj;
}
