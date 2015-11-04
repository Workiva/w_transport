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

library w_transport.test.integration.ws.common;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WSocket, WSocketException;

class WebSocketIntegrationConfig {
  Uri hostUri;

  String platform;

  WebSocketIntegrationConfig(String this.platform, this.hostUri);

  Uri get closeUri => hostUri.replace(path: '/test/ws/close');

  Uri get echoUri => hostUri.replace(path: '/test/ws/echo');

  Uri get fourOhFourUri => Uri.parse('ws://localhost:9999');

  Uri get pingUri => hostUri.replace(path: '/test/ws/ping');

  String get title => 'WebSocket ($platform):';
}

void runCommonWebSocketIntegrationTests(WebSocketIntegrationConfig config) {
  test('should throw if connection cannot be established', () async {
    expect(WSocket.connect(config.fourOhFourUri),
        throwsA(new isInstanceOf<WSocketException>()));
  });

  test('add() should send a message', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    WSHelper helper = new WSHelper(socket);

    socket.add('message');
    await helper.messagesReceived(1);
    expect(helper.messages.single, equals('message'));
    socket.close();
  });

  test('add() should support sending multiple messages', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    WSHelper helper = new WSHelper(socket);

    socket.add('message1');
    socket.add('message2');
    await helper.messagesReceived(2);
    expect(helper.messages, unorderedEquals(['message1', 'message2']));
    socket.close();
  });

  test('add() should throw after sink has been closed', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    await socket.close();
    expect(() {
      socket.add('too late');
    }, throwsStateError);
  });

  test('addError() should close the socket with an error that can be caught',
      () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    socket.addError(
        new Exception('Exception should close the socket with an error.'));

    var error;
    try {
      await socket.done;
    } catch (e) {
      error = e;
    }

    expect(error, isNotNull);
    expect(error, isException);
  });

  test('addStream() should send a Stream of data', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    WSHelper helper = new WSHelper(socket);

    var stream = new Stream.fromIterable(['message1', 'message2']);
    socket.addStream(stream);
    await helper.messagesReceived(2);
    expect(helper.messages, unorderedEquals(['message1', 'message2']));
  });

  test('addStream() should support sending multiple Streams serially',
      () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    WSHelper helper = new WSHelper(socket);

    var stream1 = new Stream.fromIterable(['message1a', 'message2a']);
    var stream2 = new Stream.fromIterable(['message1b', 'message2b']);
    await socket.addStream(stream1);
    await socket.addStream(stream2);
    await helper.messagesReceived(4);
    expect(helper.messages,
        unorderedEquals(['message1a', 'message1b', 'message2a', 'message2b']));
  });

  test('addStream() should throw if multiple Streams added concurrently',
      () async {
    WSocket socket = await WSocket.connect(config.echoUri);

    var stream = new Stream.fromIterable(['message1', 'message2']);
    socket.addStream(stream);
    expect(socket.addStream(stream), throwsStateError);
  });

  test('addStream() should throw after sink has been closed', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    await socket.close();
    expect(socket.addStream(new Stream.fromIterable(['too late'])),
        throwsStateError);
  });

  test('addStream() should cause socket to close if error is added', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    var controller = new StreamController();
    controller.add('message1');
    controller.addError(new Exception('addStream error, should close socket'));
    controller.close();
    await socket.addStream(controller.stream);
    expect(socket.done, throwsException);
  });

  test('should support listening to incoming messages', () async {
    WSocket socket = await WSocket.connect(config.pingUri);
    WSHelper helper = new WSHelper(socket);

    socket.add('ping2');
    await helper.messagesReceived(2);

    expect(helper.messages, unorderedEquals(['pong', 'pong']));
  });

  test('should allow multiple listeners by default', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    socket.listen((_) {});
    expect(() {
      socket.listen((_) {});
    }, throwsStateError);
  });

  test('should not lose messages if a listener is registered late', () async {
    WSocket socket = await WSocket.connect(config.pingUri);
    socket.add('ping3');

    await new Future.delayed(new Duration(seconds: 1));
    WSHelper helper = new WSHelper(socket);
    await helper.messagesReceived(3);

    expect(helper.messages, unorderedEquals(['pong', 'pong', 'pong']));
  });

  test('should call onDone() when socket closes', () async {
    WSocket socket = await WSocket.connect(config.echoUri);

    Completer c = new Completer();
    socket.listen((_) {}, onDone: () {
      c.complete();
    });

    socket.close();
    await c.future;
  });

  test('should have the close code and reason available in onDone() callback',
      () async {
    WSocket socket = await WSocket.connect(config.echoUri);

    Completer c = new Completer();
    socket.listen((_) {}, onDone: () {
      expect(socket.closeCode, equals(4001));

      // TODO: Dart's WebSocket server did not previously set the closeReason
      // See: https://github.com/dart-lang/sdk/issues/23964
      // expect(socket.closeReason, equals('Closed.'));

      c.complete();
    });

    socket.add('echo');

    new Timer(new Duration(seconds: 1), () {
      socket.close(4001, 'oops');
    });

    await c.future;
  });

  test('should work as a broadcast stream', () async {
    WSocket socket = await WSocket.connect(config.pingUri);
    Stream stream = socket.asBroadcastStream();

    Completer c1 = new Completer();
    Completer c2 = new Completer();

    stream.listen((_) {
      c1.complete();
    });
    stream.listen((_) {
      c2.complete();
    });

    socket.add('ping');

    return Future.wait([c1.future, c2.future]);
  });

  test('should have the close code and reason available after closing',
      () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    await socket.close(4001, 'Closed.');
    expect(socket.closeCode, equals(4001));

    // TODO: Dart's WebSocket server did not previously set the closeReason
    // See: https://github.com/dart-lang/sdk/issues/23964
    // expect(socket.closeReason, equals('Closed.'));
  });

  test(
      'should close and properly drain stream even if no listeners were registered',
      () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    await socket.close();
  });

  test('should handle the server closing the connection', () async {
    WSocket socket = await WSocket.connect(config.closeUri);
    socket.add(_closeRequest());
    await socket.done;
  });

  test(
      'should ignore close() being called after the server closes the connection',
      () async {
    WSocket socket = await WSocket.connect(config.closeUri);
    socket.add(_closeRequest(4001, 'Closed by server.'));
    await socket.done;
    await socket.close(4002, 'Late close.');
    expect(socket.closeCode, equals(4001));
    expect(socket.closeReason, equals('Closed by server.'));
  });

  test('should ignore close() calls after the first', () async {
    WSocket socket = await WSocket.connect(config.echoUri);
    await socket.close(4001, 'Custom close.');
    await socket.close(4002, 'Late close.');
    expect(socket.closeCode, equals(4001));
    expect(socket.closeReason, equals('Custom close.'));
  });

  test(
      'should report the close code and reason that the server used when closing the connection',
      () async {
    WSocket socket = await WSocket.connect(config.closeUri);
    socket.add(_closeRequest(4001, 'Closed by server.'));
    await socket.done;
    expect(socket.closeCode, equals(4001));
    expect(socket.closeReason, equals('Closed by server.'));
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
