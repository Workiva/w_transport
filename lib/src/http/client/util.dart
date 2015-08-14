library w_transport.src.http.client.util;

import 'dart:async';
import 'dart:html';

import 'package:w_transport/src/http/w_progress.dart';

/// Transforms an [ProgressEvent] stream from an [HttpRequest] into
/// a [WProgress] stream.
StreamTransformer<ProgressEvent, WProgress> wProgressTransformer =
    new StreamTransformer<ProgressEvent, WProgress>(
        (Stream<ProgressEvent> input, bool cancelOnError) {
  StreamController<WProgress> controller;
  StreamSubscription<ProgressEvent> subscription;
  controller = new StreamController<WProgress>(onListen: () {
    subscription = input.listen((ProgressEvent event) {
      controller.add(event.lengthComputable
          ? new WProgress(event.loaded, event.total)
          : new WProgress());
    },
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: cancelOnError);
  }, onPause: () {
    subscription.pause();
  }, onResume: () {
    subscription.resume();
  }, onCancel: () {
    subscription.cancel();
  });
  return controller.stream.listen(null);
});
