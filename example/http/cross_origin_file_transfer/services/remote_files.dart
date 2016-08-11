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

import 'package:w_transport/w_transport.dart';

import './proxy.dart';

int _remoteFilePollingInterval = 10; // 10 seconds

class RemoteFiles {
  /// Establish a connection with the remote files server.
  static RemoteFiles connect() {
    return new RemoteFiles._();
  }

  static void deleteAll() {
    Http.delete(getFilesEndpointUrl());
  }

  /// Close the connection with the remote files server.
  void close() {
    _connected = false;
    _endPolling();
  }

  /// Stream that updates with the latest list of remote files.
  Stream<List<RemoteFileDescription>> get stream => _fileStream;

  /// Stream of errors that may occur when trying to communicate with the proxy file server.
  Stream<RequestException> get errorStream => _errorStream;

  bool _connected;
  StreamController _errorStreamController;
  Stream _errorStream;
  StreamController<List<RemoteFileDescription>> _fileStreamController;
  Stream<List<RemoteFileDescription>> _fileStream;
  Timer _pollingTimer;

  /// Construct a RemoteFiles instance and connect to the proxy server
  /// via HTTP polling.
  RemoteFiles._() {
    _connected = true;
    _errorStreamController = new StreamController();
    _errorStream = _errorStreamController.stream.asBroadcastStream();
    _fileStreamController = new StreamController<List<RemoteFileDescription>>();
    _fileStream = _fileStreamController.stream.asBroadcastStream();
    _startPolling();
  }

  /// Send polling requests 2 seconds apart.
  void _startPolling() {
    if (!_connected) return;
    _poll().then((_) {
      _pollingTimer = new Timer(
          new Duration(seconds: _remoteFilePollingInterval), _startPolling);
    });
  }

  /// Send the HTTP polling request.
  Future _poll() async {
    if (!_connected) return;
    try {
      Response response = await Http.get(getFilesEndpointUrl());

      // Parse the file list from the response
      List results = response.body.asJson()['results'];
      List<RemoteFileDescription> files = results
          .map((Map file) =>
              new RemoteFileDescription(file['name'], file['size']))
          .toList();

      // Send the updated file list to listeners
      _fileStreamController.add(files);
    } catch (e, stackTrace) {
      // Send the error to listeners
      _errorStreamController.add(e);
      print(e);
      print(stackTrace);
    }
  }

  /// Cancel polling.
  void _endPolling() {
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
  }
}

class RemoteFileDescription {
  final String name;
  final int size;

  RemoteFileDescription(this.name, this.size);
}
