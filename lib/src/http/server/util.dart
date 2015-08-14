library w_transport.src.http.server.util;

import 'dart:async';
import 'dart:io';

import 'package:w_transport/src/http/w_progress.dart';

Map<String, String> parseHeaders(HttpHeaders httpHeaders) {
  Map<String, String> headers = {};
  httpHeaders.forEach((String name, List<String> values) {
    headers[name] = values.join(',');
  });
  return headers;
}

/// Creates a [StreamTransformer] that monitors the progress of
/// a data stream instead of actually transforming it. The returned
/// stream is identical to the input stream, but [progressController]
/// will be populated with a stream of [WProgress] instances as long
/// as the data stream progress is computable.
StreamTransformer wProgressListener(
    int total, StreamController<WProgress> progressController) {
  int loaded = 0;
  return new StreamTransformer((Stream input, bool cancelOnError) {
    StreamController controller;
    StreamSubscription subscription;
    controller = new StreamController(onListen: () {
      subscription = input.listen((data) {
        controller.add(data);
        if (data is List<int>) {
          loaded += (data as List<int>).length;
          progressController.add(new WProgress(loaded, total));
        }
      }, onError: controller.addError, onDone: () {
        controller.close();
        progressController.close();
      }, cancelOnError: cancelOnError);
    }, onPause: () {
      subscription.pause();
    }, onResume: () {
      subscription.resume();
    }, onCancel: () {
      subscription.cancel();
    });
    return controller.stream.listen(null);
  });
}
