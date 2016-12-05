// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:html';

import 'package:w_transport/src/http/request_progress.dart';

/// Transforms an [ProgressEvent] stream from an [HttpRequest] into
/// a [WProgress] stream.
StreamTransformer<ProgressEvent, RequestProgress> transformProgressEvents =
    new StreamTransformer<ProgressEvent, RequestProgress>(
        (Stream<ProgressEvent> input, bool cancelOnError) {
  StreamController<RequestProgress> controller;
  StreamSubscription<ProgressEvent> subscription;
  controller = new StreamController<RequestProgress>(onListen: () {
    subscription = input.listen((ProgressEvent event) {
      controller.add(event.lengthComputable
          ? new RequestProgress(event.loaded, event.total)
          : new RequestProgress());
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
