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

library w_transport.test.integration.ws.w_socket_common;

import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WSocket, WSocketException;

/// These are WebSocket integration tests that should work from client or server.
/// These will not pass if run on their own!
void run(String usage) {
  group('WSocket ($usage)', () {
    WSocket socket;
    Uri closeUri;
    Uri echoUri;
    Uri pingUri;

    setUp(() {
      closeUri = Uri.parse('ws://localhost:8024/test/ws/close');
      echoUri = Uri.parse('ws://localhost:8024/test/ws/echo');
      pingUri = Uri.parse('ws://localhost:8024/test/ws/ping');
    });

    tearDown(() async {
      if (socket != null) {
        await socket.close();
      }
    });

    test('should throw if connection cannot be established', () async {
      expect(WSocket.connect(Uri.parse('ws://localhost:9999')),
          throwsA(new isInstanceOf<WSocketException>()));
    });

    group('add()', () {
      test('should be able to send a message', () async {
        socket = await WSocket.connect(echoUri);
        WSHelper helper = new WSHelper(socket);

        socket.add('message');
        await helper.messagesReceived(1);
        expect(helper.messages.single, equals('message'));
      });

      test('should be able to send multiple messages', () async {
        socket = await WSocket.connect(echoUri);
        WSHelper helper = new WSHelper(socket);

        socket.add('message1');
        socket.add('message2');
        await helper.messagesReceived(2);
        expect(helper.messages, unorderedEquals(['message1', 'message2']));
      });

      test('should throw after sink has been closed', () async {
        socket = await WSocket.connect(echoUri);
        await socket.close();
        expect(() {
          socket.add('too late');
        }, throwsStateError);
      });
    });

    group('addError()', () {
      // TODO: Adding an error forwards the error through to the underyling
      // TODO:    WebSocket sink, which causes the error to be thrown, but
      // TODO:    it can't be caught since it's thrown in an async zone.
      // TODO:    Can we test this?
    });

    group('addStream()', () {
      test('should be able to send a Stream', () async {
        socket = await WSocket.connect(echoUri);
        WSHelper helper = new WSHelper(socket);

        var stream = new Stream.fromIterable(['message1', 'message2']);
        socket.addStream(stream);
        await helper.messagesReceived(2);
        expect(helper.messages, unorderedEquals(['message1', 'message2']));
      });

      test('should be able to add multiple Streams serially', () async {
        socket = await WSocket.connect(echoUri);
        WSHelper helper = new WSHelper(socket);

        var stream1 = new Stream.fromIterable(['message1a', 'message2a']);
        var stream2 = new Stream.fromIterable(['message1b', 'message2b']);
        await socket.addStream(stream1);
        await socket.addStream(stream2);
        await helper.messagesReceived(4);
        expect(
            helper.messages,
            unorderedEquals(
                ['message1a', 'message1b', 'message2a', 'message2b']));
      });

      test('should not be able to add multiple Streams concurrently', () async {
        socket = await WSocket.connect(echoUri);

        var stream = new Stream.fromIterable(['message1', 'message2']);
        socket.addStream(stream);
        expect(socket.addStream(stream), throwsStateError);
      });

      test('should throw after sink has been closed', () async {
        socket = await WSocket.connect(echoUri);
        await socket.close();
        expect(socket.addStream(new Stream.fromIterable(['too late'])),
            throwsStateError);
      });
    });

    group('listen()', () {
      test('should be able to listen to incoming messages', () async {
        socket = await WSocket.connect(pingUri);
        WSHelper helper = new WSHelper(socket);

        socket.add('ping2');
        await helper.messagesReceived(2);

        expect(helper.messages, unorderedEquals(['pong', 'pong']));
      });

      test('should not allow multiple listeners by default', () async {
        socket = await WSocket.connect(echoUri);
        socket.listen((_) {});
        expect(() {
          socket.listen((_) {});
        }, throwsStateError);
      });

      test('should not miss messages if a listener is registered late',
          () async {
        socket = await WSocket.connect(pingUri);
        socket.add('ping3');
        await new Future.delayed(new Duration(milliseconds: 200));
        expect(socket.toList(), completion(equals(['pong', 'pong', 'pong'])));
        socket.close();
      });

      test('should call onDone() when socket closes', () async {
        socket = await WSocket.connect(echoUri);

        Completer c = new Completer();
        socket.listen((_) {}, onDone: () {
          c.complete();
        });

        socket.close();
        await c.future;
      });

      test(
          'should have the close code and reason available in onDone() callback',
          () async {
        socket = await WSocket.connect(echoUri);

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
        socket = await WSocket.connect(pingUri);
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
    });

    group('closing', () {
      test('should have the close code and reason available after closing',
          () async {
        socket = await WSocket.connect(echoUri);
        await socket.close(4001, 'Closed.');
        expect(socket.closeCode, equals(4001));

        // TODO: Dart's WebSocket server did not previously set the closeReason
        // See: https://github.com/dart-lang/sdk/issues/23964
        // expect(socket.closeReason, equals('Closed.'));
      });

      test(
          'should close and properly drain stream even if no listeners were registered',
          () async {
        socket = await WSocket.connect(echoUri);
        await socket.close();
      });

      test('should handle the server closing the connection', () async {
        socket = await WSocket.connect(closeUri);
        socket.add(_closeRequest());
        await socket.done;
      });

      test(
          'should report the close code and reason that the server used when closing the connection',
          () async {
        socket = await WSocket.connect(closeUri);
        socket.add(_closeRequest(4001, 'Closed by server.'));
        await socket.done;
        expect(socket.closeCode, equals(4001));
        expect(socket.closeReason, equals('Closed by server.'));
      });
    });

    test('should throw when attempting to send invalid data', () async {
      socket = await WSocket.connect(pingUri);
      expect(() {
        socket.add(true);
      }, throwsArgumentError);
    });
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
