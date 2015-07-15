library w_transport.test.integration.w_socket_common;

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart' show WSocket;

/// These are WebSocket integration tests that should work from client or server.
/// These will not pass if run on their own!
void run(String usage) {
  group('WSocket ($usage)', () {
    Uri uri;
    WSocket socket;

    setUp(() {
      uri = Uri.parse('ws://localhost:8026');
    });

    tearDown(() {
      if (socket != null) {
        socket.close();
      }
    });

    test('should throw if connection cannot be established', () async {
      expect(WSocket.connect(Uri.parse('ws://localhost:9999')),
          throwsA(new isInstanceOf<WSocketException>()));
    });

    group('add()', () {
      test('should be able to send a message', () async {
        socket = await WSocket.connect(uri);
        WSHelper helper = new WSHelper(socket);

        socket.add(_echo('message'));
        await helper.messagesReceived(1);
        expect(helper.echos.single, equals('message'));
      });

      test('should be able to send multiple messages', () async {
        socket = await WSocket.connect(uri);
        WSHelper helper = new WSHelper(socket);

        socket.add(_echo('message1'));
        socket.add(_echo('message2'));
        await helper.messagesReceived(2);
        expect(helper.echos, unorderedEquals(['message1', 'message2']));
      });

      test('should throw after sink has been closed', () async {
        socket = await WSocket.connect(uri);
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
        socket = await WSocket.connect(uri);
        WSHelper helper = new WSHelper(socket);

        var stream =
            new Stream.fromIterable([_echo('message1'), _echo('message2')]);
        socket.addStream(stream);
        await helper.messagesReceived(2);
        expect(helper.echos, unorderedEquals(['message1', 'message2']));
      });

      test('should be able to add multiple Streams serially', () async {
        socket = await WSocket.connect(uri);
        WSHelper helper = new WSHelper(socket);

        var stream1 =
            new Stream.fromIterable([_echo('message1a'), _echo('message2a')]);
        var stream2 =
            new Stream.fromIterable([_echo('message1b'), _echo('message2b')]);
        await socket.addStream(stream1);
        await socket.addStream(stream2);
        await helper.messagesReceived(4);
        expect(helper.echos, unorderedEquals(
            ['message1a', 'message1b', 'message2a', 'message2b']));
      });

      test('should not be able to add multiple Streams concurrently', () async {
        socket = await WSocket.connect(uri);

        var stream =
            new Stream.fromIterable([_echo('message1'), _echo('message2')]);
        socket.addStream(stream);
        expect(socket.addStream(stream), throwsStateError);
      });

      test('should throw after sink has been closed', () async {
        socket = await WSocket.connect(uri);
        await socket.close();
        expect(socket.addStream(new Stream.fromIterable(['too late'])),
            throwsStateError);
      });
    });

    group('listen()', () {
      test('should be able to listen to incoming messages', () async {
        socket = await WSocket.connect(uri);
        WSHelper helper = new WSHelper(socket);

        socket.add(_ping(2));
        await helper.messagesReceived(2);

        expect(helper.messages, unorderedEquals(['pong', 'pong']));
      });

      test('should not allow multiple listeners by default', () async {
        socket = await WSocket.connect(uri);
        socket.listen((_) {});
        expect(() {
          socket.listen((_) {});
        }, throwsStateError);
      });

      test('should not miss messages if a listener is registered late',
          () async {
        socket = await WSocket.connect(uri);
        socket.add(_ping(3));
        await new Future.delayed(new Duration(milliseconds: 200));
        expect(socket.toList(), completion(equals(['pong', 'pong', 'pong'])));
        socket.close();
      });

      test('should call onDone() when socket closes', () async {
        socket = await WSocket.connect(uri);

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
        socket = await WSocket.connect(uri);

        Completer c = new Completer();
        socket.listen((_) {}, onDone: () {
          expect(socket.closeCode, equals(4001));

          // TODO: Bug with Dart's WebSocket server prevents the closeReason from being set properly
          // See: http://stackoverflow.com/questions/31434394/support-websocket-close-reason-with-a-dart-websocket-server
          // expect(socket.closeReason, equals('Closed.'));

          c.complete();
        });

        socket.add(_echo('echo'));

        new Timer(new Duration(seconds: 1), () {
          socket.close(4001, 'oops');
        });

        await c.future;
      });

      test('should work as a broadcast stream', () async {
        socket = await WSocket.connect(uri);
        Stream stream = socket.asBroadcastStream();

        Completer c1 = new Completer();
        Completer c2 = new Completer();

        stream.listen((_) {
          c1.complete();
        });
        stream.listen((_) {
          c2.complete();
        });

        socket.add(_ping());

        await c1.future;
        await c2.future;
      });
    });

    group('closing', () {
      test('should have the close code and reason available after closing',
          () async {
        socket = await WSocket.connect(uri);
        await socket.close(4001, 'Closed.');
        expect(socket.closeCode, equals(4001));

        // TODO: Bug with Dart's WebSocket server prevents the closeReason from being set properly
        // See: http://stackoverflow.com/questions/31434394/support-websocket-close-reason-with-a-dart-websocket-server
        // expect(socket.closeReason, equals('Closed.'));
      });

      test(
          'should close and properly drain stream even if no listeners were registered',
          () async {
        socket = await WSocket.connect(uri);
        await socket.close();
      });

      test('should handle the server closing the connection', () async {
        socket = await WSocket.connect(uri);
        socket.add(_closeRequest());
        await socket.done;
      });
    });
  });
}

String _closeRequest() => JSON.encode({'action': 'close'});
String _echo(message) => JSON.encode({'action': 'echo', 'message': message});
String _ping([int numPongs = 1]) =>
    JSON.encode({'action': 'ping', 'pongs': numPongs});

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

  Iterable<String> get echos => _messages.where((m) {
    bool jsonDecodable = true;
    try {
      JSON.decode(m);
    } catch (e) {
      jsonDecodable = false;
    }
    return jsonDecodable;
  })
      .map((m) => JSON.decode(m))
      .where((m) => m['action'] == 'echo')
      .map((m) => m['message']);
  Iterable<String> get messages => _messages;

  Future messagesReceived(int numMessages) async {
    if (_messages.length >= numMessages) return;

    Completer c = new Completer();
    _completers[numMessages] = c;
    await c.future;
  }
}
