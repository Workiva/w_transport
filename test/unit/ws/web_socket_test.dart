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

@TestOn('vm || browser')
import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';
import '../../utils.dart' show nextTick;

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicWebSocket;

  group(naming.toString(), () {
    group('WSocket', () {
      _runWebSocketSuite((Uri uri) => WSocket.connect(uri));
    });

    group('WebSocket', () {
      _runWebSocketSuite((Uri uri) => WebSocket.connect(uri));
    });
  });
}

_runWebSocketSuite(Future<WSocket> getWebSocket(Uri uri)) {
  Uri webSocketUri = Uri.parse('ws://mock.com/ws');

  setUp(() {
    configureWTransportForTest();
    MockTransports.reset();
  });

  test('message events should be discarded prior to a subscription', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    mockWebSocket.addIncoming('1');
    mockWebSocket.addIncoming('2');
    await nextTick();

    var messages = [];
    webSocket.listen((data) {
      messages.add(data);
    });

    mockWebSocket.addIncoming('3');
    mockWebSocket.addIncoming('4');
    await nextTick();

    mockWebSocket.triggerServerClose();
    await webSocket.done;
    expect(messages, orderedEquals(['3', '4']));
  });

  test(
      'the first event should be received if a subscription is made immediately',
      () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    var c = new Completer();
    webSocket.listen((data) {
      c.complete(data);
    });
    mockWebSocket.addIncoming('first');

    expect(await c.future, equals('first'));
  });

  test('all event streams should respect pause() and resume() signals',
      () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);
    var messages = [];

    // no subscription yet, messages should be discarded
    mockWebSocket.addIncoming('1');
    await nextTick();

    // setup a subscription, messages should be recorded
    var sub = webSocket.listen((data) {
      messages.add(data);
    });
    mockWebSocket.addIncoming('2');
    await nextTick();

    // pause the subscription, messages should be discarded
    sub.pause();
    mockWebSocket.addIncoming('3');
    await nextTick();

    // resume the subscription, messages should be recorded again
    sub.resume();
    mockWebSocket.addIncoming('4');
    await nextTick();

    expect(messages, orderedEquals(['2', '4']));
  });

  test('onData() handler should be reassignable', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    var origHandlerMessages = [];
    var newHandlerMessages = [];

    // Messages from original handler should be recorded
    var sub = webSocket.listen((data) {
      origHandlerMessages.add(data);
    });
    mockWebSocket.addIncoming('orig');
    await nextTick();

    // New handler should completely replace original handler
    sub.onData((data) {
      newHandlerMessages.add(data);
    });
    mockWebSocket.addIncoming('new');
    await nextTick();

    expect(origHandlerMessages, equals(['orig']));
    expect(newHandlerMessages, equals(['new']));
  });

  test('onDone() handler should be reassignable', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    var sub = webSocket.listen((_) {}, onDone: () {});

    var c = new Completer();
    sub.onDone(() {
      c.complete();
    });

    mockWebSocket.triggerServerClose();
    await c.future;
  });

  test('add() should send data to underlying web socket', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    var c = new Completer();
    mockWebSocket.onOutgoing(c.complete);

    webSocket.add('message');

    expect(await c.future, equals('message'));
    await webSocket.close();
  });

  test('addStream() should send data to underlying web socket', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    var controller = new StreamController();
    mockWebSocket.onOutgoing(controller.add);

    await webSocket.addStream(new Stream.fromIterable(['one', 'two']));
    controller.close();
    webSocket.close();

    expect(await controller.stream.toList(), equals(['one', 'two']));
  });

  test('addStream() should cause the web socket to close when erorr is added',
      () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    var controller = new StreamController();
    controller.add('message');
    controller.addError(new Exception('addStream error, should close socket'));
    controller.close();

    await webSocket.addStream(controller.stream);
    expect(webSocket.done, throwsException);
  });

  test('addError() should cause the web socket to close', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    expect(webSocket.done, throwsException);
    webSocket.addError(new Exception('web socket consumer error'));
  });

  // TODO: remove this test once triggerServerError has been removed
  test('DEPRECATED: error should close the socket', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);

    mockWebSocket.triggerServerError(new Exception('Server Exception'));
    await webSocket.done;
  });

  test('server closing the connection should close the socket', () async {
    var mockWebSocket = new MockWSocket();
    MockTransports.webSocket.expect(webSocketUri, connectTo: mockWebSocket);
    var webSocket = await WSocket.connect(webSocketUri);
    mockWebSocket.triggerServerClose(1000, 'closed');
    await webSocket.done;
    expect(webSocket.closeCode, equals(1000));
    expect(webSocket.closeReason, equals('closed'));
  });
}
