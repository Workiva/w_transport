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

/// A representation of a `StreamSubscription` specific to the [WSocket] class.
/// This subscription proxies the underlying subscription to the WebSocket while
/// taking into account both the outgoing and incoming streams. In other words,
/// this subscription is exactly the same, except that it isn't considered
/// "done" until both the incoming and the outgoing subscriptions are closed.
class WSocketSubscription<T> implements StreamSubscription<T> {
  bool _isCanceled = false;

  /// The callback given by the [WSocket] implementation to be called when this
  /// subscription is canceled. This allows the [WSocket] instance to perform
  /// necessary cleanup.
  Function _onCancel;

  /// The `StreamSubscription` being proxied.
  StreamSubscription<T> _sub;

  WSocketSubscription(this._sub, this._doneHandler, {Function onCancel})
      : _onCancel = onCancel;

  /// The callback given by the listener to be called when this subscription
  /// is completely done.
  Function get doneHandler => _isCanceled ? null : _doneHandler;
  Function _doneHandler;

  @override
  bool get isPaused => _sub.isPaused;

  @override
  Future cancel() async {
    if (_isCanceled) return;

    // Make the onData, onError, and onDone handlers no-ops.
    onData((_) {});
    onError((_) {});
    onDone(() {});

    _isCanceled = true;

    if (_onCancel != null) {
      await _onCancel();
    }
  }

  @override
  Future/*<E>*/ asFuture/*<E>*/([var/*=E*/ futureValue]) {
    final c = new Completer/*<E>*/();
    _doneHandler = () {
      c.complete(futureValue);
    };
    return c.future;
  }

  @override
  void resume() {
    if (_isCanceled) return;
    _sub.resume();
  }

  @override
  void pause([Future resumeSignal]) {
    if (_isCanceled) return;
    _sub.pause();
    if (resumeSignal != null) {
      () async {
        try {
          await resumeSignal;
        } catch (e) {
          rethrow;
        } finally {
          resume();
        }
      }();
    }
  }

  @override
  void onDone(void handleDone()) {
    if (_isCanceled) return;
    _doneHandler = handleDone;
  }

  @override
  void onError(Function handleError) {
    if (_isCanceled) return;
    _sub.onError(handleError);
  }

  @override
  void onData(void handleData(T data)) {
    if (_isCanceled) return;
    _sub.onData(handleData);
  }
}
