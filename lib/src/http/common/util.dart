library w_transport.src.http.common.util;

import 'dart:async';
import 'dart:convert';

StreamTransformer decodeAttempt(Encoding encoding) {
  return new StreamTransformer((Stream input, bool cancelOnError) {
    StreamController controller;
    StreamSubscription subscription;
    controller = new StreamController(onListen: () {
      subscription = input.listen((data) {
        try {
          data = encoding.decode(data);
        } catch (e) {}
        controller.add(data);
      }, onError: controller.addError, onDone: () {
        controller.close();
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
