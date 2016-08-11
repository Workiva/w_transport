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

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WSocket, WSocketException;

import '../integration_paths.dart';

void runCommonWebSocketIntegrationTests(
    {Future<WSocket> connect(Uri uri), int port}) {
  if (connect == null) {
    connect = (uri) => WSocket.connect(uri);
  }
  var closeUri = IntegrationPaths.closeUri;
  var echoUri = IntegrationPaths.echoUri;
  var fourOhFourUri = IntegrationPaths.fourOhFourUri;
  var pingUri = IntegrationPaths.pingUri;
  if (port != null) {
    closeUri = closeUri.replace(port: port);
    echoUri = echoUri.replace(port: port);
    pingUri = pingUri.replace(port: port);
  }

  test('should throw if connection cannot be established', () async {
    expect(
        connect(fourOhFourUri), throwsA(new isInstanceOf<WSocketException>()));
  });

  test('add() should send a message', () async {
    var webSocket = await connect(echoUri);
    var helper = new WSHelper(webSocket);

    webSocket.add('message');
    await helper.messagesReceived(1);
    expect(helper.messages.single, equals('message'));
    await webSocket.close();
  });

  test('add() should support sending multiple messages', () async {
    var webSocket = await connect(echoUri);
    var helper = new WSHelper(webSocket);

    webSocket.add('message1');
    webSocket.add('message2');
    await helper.messagesReceived(2);
    expect(helper.messages, unorderedEquals(['message1', 'message2']));
    await webSocket.close();
  });

  test('add() should throw after sink has been closed', () async {
    var webSocket = await connect(echoUri);
    await webSocket.close();
    expect(() {
      webSocket.add('too late');
    }, throwsStateError);
  });

  test('addError() should close the socket with an error that can be caught',
      () async {
    var webSocket = await connect(echoUri);
    webSocket.addError(
        new Exception('Exception should close the socket with an error.'));

    var error;
    try {
      await webSocket.done;
    } catch (e) {
      error = e;
    }

    expect(error, isNotNull);
    expect(error, isException);
  });

  test('addStream() should send a Stream of data', () async {
    var webSocket = await connect(echoUri);
    var helper = new WSHelper(webSocket);

    var stream = new Stream.fromIterable(['message1', 'message2']);
    webSocket.addStream(stream);
    await helper.messagesReceived(2);
    expect(helper.messages, unorderedEquals(['message1', 'message2']));
    await webSocket.close();
  });

  test('addStream() should support sending multiple Streams serially',
      () async {
    var webSocket = await connect(echoUri);
    var helper = new WSHelper(webSocket);

    var stream1 = new Stream.fromIterable(['message1a', 'message2a']);
    var stream2 = new Stream.fromIterable(['message1b', 'message2b']);
    await webSocket.addStream(stream1);
    await webSocket.addStream(stream2);
    await helper.messagesReceived(4);
    expect(helper.messages,
        unorderedEquals(['message1a', 'message1b', 'message2a', 'message2b']));
    await webSocket.close();
  });

  test('addStream() should throw if multiple Streams added concurrently',
      () async {
    var webSocket = await connect(echoUri);

    var stream = new Stream.fromIterable(['message1', 'message2']);
    var firstFuture = webSocket.addStream(stream);
    var lateFuture = webSocket.addStream(stream);
    expect(lateFuture, throwsStateError);
    await firstFuture;
    try {
      await lateFuture;
    } catch (e) {}
    try {
      await webSocket.close();
    } catch (e) {}
  });

  test('addStream() should throw after sink has been closed', () async {
    var webSocket = await connect(echoUri);
    await webSocket.close();
    expect(webSocket.addStream(new Stream.fromIterable(['too late'])),
        throwsStateError);
  });

  test('addStream() should cause socket to close if error is added', () async {
    var webSocket = await connect(echoUri);
    var controller = new StreamController();
    controller.add('message1');
    controller.addError(new Exception('addStream error, should close socket'));
    controller.close();
    await webSocket.addStream(controller.stream);
    expect(webSocket.done, throwsException);
  });

  test('should support listening to incoming messages', () async {
    var webSocket = await connect(pingUri);
    var helper = new WSHelper(webSocket);

    webSocket.add('ping2');
    await helper.messagesReceived(2);

    expect(helper.messages, unorderedEquals(['pong', 'pong']));
    await webSocket.close();
  });

  test('should not allow multiple listeners by default', () async {
    var webSocket = await connect(echoUri);
    webSocket.listen((_) {});
    expect(() {
      webSocket.listen((_) {});
    }, throwsStateError);
    await webSocket.close();
  });

  test('should lose messages if a listener is registered late', () async {
    var webSocket = await connect(pingUri);
    // First two pings should be lost because no listener has been registered.
    webSocket.add('ping2');

    await new Future.delayed(new Duration(milliseconds: 200));
    var helper = new WSHelper(webSocket);

    // Next round of pings should now be received.
    webSocket.add('ping3');
    await new Future.delayed(new Duration(milliseconds: 200));
    await helper.messagesReceived(3);

    expect(helper.messages, unorderedEquals(['pong', 'pong', 'pong']));
    await webSocket.close();
  });

  test('should call onDone() when socket closes', () async {
    var webSocket = await connect(echoUri);

    Completer c = new Completer();
    webSocket.listen((_) {}, onDone: () {
      c.complete();
    });

    webSocket.close();
    await c.future;
  });

  test('should have the close code and reason available in onDone() callback',
      () async {
    var webSocket = await connect(echoUri);

    Completer c = new Completer();
    webSocket.listen((_) {}, onDone: () {
      expect(webSocket.closeCode, equals(4001));
      expect(webSocket.closeReason, equals('Closed.'));

      c.complete();
    });

    webSocket.add('echo');

    new Timer(new Duration(milliseconds: 200), () {
      webSocket.close(4001, 'Closed.');
    });

    await c.future;
  });

  test('should work as a broadcast stream', () async {
    var webSocket = await connect(pingUri);
    Stream stream = webSocket.asBroadcastStream();

    Completer c1 = new Completer();
    Completer c2 = new Completer();

    stream.listen((_) {
      c1.complete();
    });
    stream.listen((_) {
      c2.complete();
    });

    webSocket.add('ping');

    await Future.wait([c1.future, c2.future]);
    await webSocket.close();
  });

  test('should have the close code and reason available after closing',
      () async {
    var webSocket = await connect(echoUri);
    await webSocket.close(4001, 'Closed.');
    expect(webSocket.closeCode, equals(4001));
    expect(webSocket.closeReason, equals('Closed.'));
  });

  test(
      'should close and properly drain stream even if no listeners were registered',
      () async {
    var webSocket = await connect(echoUri);
    await webSocket.close();
  });

  test('should handle the server closing the connection', () async {
    var webSocket = await connect(closeUri);
    webSocket.add(_closeRequest());
    await webSocket.done;
  });

  test(
      'should ignore close() being called after the server closes the connection',
      () async {
    var webSocket = await connect(closeUri);
    webSocket.add(_closeRequest(4001, 'Closed by server.'));
    await webSocket.done;
    await webSocket.close(4002, 'Late close.');
    expect(webSocket.closeCode, equals(4001));
    expect(webSocket.closeReason, equals('Closed by server.'));
  });

  test('should ignore close() calls after the first', () async {
    var webSocket = await connect(echoUri);
    await webSocket.close(4001, 'Custom close.');
    await webSocket.close(4002, 'Late close.');
    expect(webSocket.closeCode, equals(4001));
    expect(webSocket.closeReason, equals('Custom close.'));
  });

  test(
      'should report the close code and reason that the server used when closing the connection',
      () async {
    var socket = await connect(closeUri);
    socket.add(_closeRequest(4001, 'Closed by server.'));
    await socket.done;
    expect(socket.closeCode, equals(4001));
    expect(socket.closeReason, equals('Closed by server.'));
  });

  test('message events should be discarded prior to a subscription', () async {
    var webSocket = await connect(echoUri);

    webSocket.add('1');
    webSocket.add('2');
    await new Future.delayed(new Duration(milliseconds: 200));

    var messages = [];
    webSocket.listen((data) {
      messages.add(data);
    });

    webSocket.add('3');
    webSocket.add('4');
    await new Future.delayed(new Duration(milliseconds: 200));

    await webSocket.close();
    expect(messages, orderedEquals(['3', '4']));
  });

  test(
      'the first event should be received if a subscription is made immediately',
      () async {
    var webSocket = await connect(echoUri);

    var c = new Completer();
    webSocket.listen((data) {
      c.complete(data);
    });
    webSocket.add('first');

    expect(await c.future, equals('first'));
    await webSocket.close();
  });

  test('all event streams should respect pause() and resume() signals',
      () async {
    var webSocket = await connect(echoUri);
    var messages = [];

    // no subscription yet, messages should be discarded
    webSocket.add('1');
    await new Future.delayed(new Duration(milliseconds: 200));

    // setup a subscription, messages should be recorded
    var sub = webSocket.listen((data) {
      messages.add(data);
    });
    webSocket.add('2');
    await new Future.delayed(new Duration(milliseconds: 200));

    // pause the subscription, messages should be discarded
    sub.pause();
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('3');
    await new Future.delayed(new Duration(milliseconds: 200));

    // resume the subscription, messages should be recorded again
    sub.resume();
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('4');
    await new Future.delayed(new Duration(milliseconds: 200));

    expect(messages, orderedEquals(['2', '4']));
    await webSocket.close();
  });

  test('should support calling pause() with a resume signal', () async {
    var webSocket = await connect(echoUri);
    var messages = [];

    // setup a subscription, messages should be recorded
    var sub = webSocket.listen((data) {
      messages.add(data);
    });
    webSocket.add('1');
    await new Future.delayed(new Duration(milliseconds: 200));

    // pause the subscription, messages should be discarded until the resume
    // signal future resolves.
    var c = new Completer();
    sub.pause(c.future);
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('2');
    await new Future.delayed(new Duration(milliseconds: 200));

    // resume the subscription, messages should be recorded again
    c.complete();
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('3');
    await new Future.delayed(new Duration(milliseconds: 200));

    expect(messages, orderedEquals(['1', '3']));
    await webSocket.close();
  });

  test(
      'should support calling pause() with a resume signal even if it resolves with an error',
      () async {
    var webSocket = await connect(echoUri);
    var messages = [];

    // setup a subscription, messages should be recorded
    var sub = webSocket.listen((data) {
      messages.add(data);
    });
    webSocket.add('1');
    await new Future.delayed(new Duration(milliseconds: 200));

    // pause the subscription, messages should be discarded until the resume
    // signal future resolves.
    var c = new Completer();
    sub.pause(c.future);
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('2');
    await new Future.delayed(new Duration(milliseconds: 200));

    // resume the subscription, messages should be recorded again
    c.completeError(new Exception('Ignore. This error is expected.'));
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('3');
    await new Future.delayed(new Duration(milliseconds: 200));

    expect(messages, orderedEquals(['1', '3']));
    await webSocket.close();
  }, skip: 'Can\'t test without the exception causing the test to fail.');

  test('should handle calling pause() multiple times', () async {
    var webSocket = await connect(echoUri);
    var messages = [];

    // setup a subscription, messages should be recorded
    var sub = webSocket.listen((data) {
      messages.add(data);
    });
    webSocket.add('1');
    await new Future.delayed(new Duration(milliseconds: 200));

    // call pause() twice, this will require two calls to resume()
    sub.pause();
    sub.pause();
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('2');
    await new Future.delayed(new Duration(milliseconds: 200));

    // call resume once - the subscription should remain in the paused state
    sub.resume();
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('3');
    await new Future.delayed(new Duration(milliseconds: 200));

    // call resume a second time - now the subscription should be active again
    sub.resume();
    await new Future.delayed(new Duration(milliseconds: 200));
    webSocket.add('4');
    await new Future.delayed(new Duration(milliseconds: 200));

    expect(messages, orderedEquals(['1', '4']));
    await webSocket.close();
  });

  test('should support converting StreamSubscription to a Future', () async {
    var webSocket = await connect(pingUri);
    var sub = webSocket.listen((_) {});
    var future = sub.asFuture('futureValue');
    webSocket.close();
    expect(await future, equals('futureValue'));
  });

  test('should support reassigning the onData() handler', () async {
    var webSocket = await connect(echoUri);

    var origMessages = [];
    var origOnData = (data) {
      origMessages.add(data);
    };

    var newMessages = [];
    var newOnData = (data) {
      newMessages.add(data);
    };

    var subscription = webSocket.listen(origOnData);
    webSocket.add('1');
    webSocket.add('2');
    // SockJS requires a delay longer than 1 tick for the echos to be received.
    await new Future.delayed(new Duration(milliseconds: 200));

    subscription.onData(newOnData);
    webSocket.add('3');
    webSocket.add('4');
    // SockJS requires a delay longer than 1 tick for the echos to be received.
    await new Future.delayed(new Duration(milliseconds: 200));

    expect(origMessages, orderedEquals(['1', '2']));
    expect(newMessages, orderedEquals(['3', '4']));
    await webSocket.close();
  });

  test('should support reassigning the onDone() handler', () async {
    var webSocket = await connect(closeUri);
    var c = new Completer();
    var subscription = webSocket.listen((_) {}, onDone: () {});
    subscription.onDone(() {
      c.complete();
    });
    webSocket.add(_closeRequest());
    await c.future;
  });
}

String _closeRequest([int closeCode, String closeReason]) {
  var c = 'close';
  if (closeCode != null) {
    c = '$c:$closeCode';
    if (closeReason != null) {
      c = '$c:$closeReason';
    }
  }
  return c;
}

class WSHelper {
  WSocket socket;
  Map<int, Completer> _completers = {};
  List<String> _messages = [];

  WSHelper(WSocket this.socket) {
    socket.listen((message) {
      _messages.add(message);
      _completers.forEach((k, v) {
        if (k <= _messages.length && !v.isCompleted) {
          v.complete();
        }
      });
    });
  }

  Iterable<String> get messages => _messages;

  Future messagesReceived(int numMessages) async {
    if (_messages.length >= numMessages) return;

    Completer c = new Completer();
    _completers[numMessages] = c;
    await c.future;
  }
}
