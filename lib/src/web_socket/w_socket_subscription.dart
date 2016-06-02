import 'dart:async';

class WSocketSubscription<T> implements StreamSubscription<T> {
  Function get doneHandler => _doneHandler;
  Function _doneHandler;
  Function _onCancel;
  StreamSubscription<T> _sub;

  WSocketSubscription(StreamSubscription this._sub, this._doneHandler,
      {Function onCancel})
      : _onCancel = onCancel;

  @override
  Future cancel() async {
    await _sub.cancel();
    return _onCancel();
  }

  @override
  Future asFuture([var futureValue]) {
    var c = new Completer();
    _doneHandler = () {
      c.complete();
    };
    return c.future;
  }

  @override
  bool get isPaused => _sub.isPaused;

  @override
  void resume() {
    _sub.resume();
  }

  @override
  void pause([Future resumeSignal]) {
    _sub.pause();
  }

  @override
  void onDone(void handleDone()) {
    _doneHandler = handleDone;
  }

  @override
  void onError(Function handleError) {
    _sub.onError(handleError);
  }

  @override
  void onData(void handleData(T data)) {
    _sub.onData(handleData);
  }
}
