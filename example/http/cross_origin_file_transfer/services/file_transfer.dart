/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.example.http.cross_origin_file_transfer.services.file_transfer;

import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

import 'package:w_transport/w_transport.dart';

import './proxy.dart';
import './remote_files.dart';

// Counter used to create unique upload IDs.
int _transferNum = 0;

// Maximum number of bytes from concurrent file transfers that can be
// loaded into memory before potentially crashing the browser tab.
final int _concurrentFileTransferSizeLimit = math.pow(2, 20) * 75; // 75 MB

// Current number of bytes in memory from concurrent file transfers.
int _concurrentFileTransferSize = 0;

/// Encapsulates the file upload to or file download from the server.
class FileTransfer {
  WRequest _request;
  bool _cancelled;

  FileTransfer(this.name)
      : id = 'fileTransfer${_transferNum++}',
        _cancelled = false,
        _doneCompleter = new Completer(),
        _percentComplete = 0.0 {}

  /// Unique file transfer identifier.
  final String id;

  /// Name of the file being transferred.
  final String name;

  /// Stream of ProgressEvents that may be used to monitor upload progress.
  Stream<WProgress> get progressStream => _progressStream;
  Stream<WProgress> _progressStream;

  /// Current completion percentage.
  double get percentComplete => _percentComplete;
  double _percentComplete;

  /// Whether or not the request has finished.
  Future get done => _doneCompleter.future;
  Completer _doneCompleter;

  /// Cancel the request (will do nothing if the request has already finished).
  void cancel(String reason) {
    _cancelled = true;
    _request.abort();
    _doneCompleter.completeError(reason != null ? new Exception(reason) : null);
  }

  void _progressListener(WProgress progress) {
    if (_cancelled) return;
    _percentComplete = progress.percent;
  }
}

/// Encapsulates the upload of a file from the client to the server.
class Upload extends FileTransfer {
  /// Start a new file upload. This will begin the upload to the server immediately.
  static Upload start(File file) {
    return new Upload._fromFile(file);
  }

  /// Construct a new file upload.
  Upload._fromFile(File file) : super(file.name) {
    // Create the payload.
    FormData data = new FormData();
    data.appendBlob('file', file);

    // Prepare the upload request.
    _request = new WRequest()
      ..uri = getUploadEndpointUrl()
      ..data = data;

    // Convert the progress stream into a broadcast stream to
    // allow multiple listeners.
    _progressStream = _request.uploadProgress.asBroadcastStream();
    _progressStream.listen(_progressListener);

    // Send the request.
    _request
        .post()
        .then((_) => _doneCompleter.complete())
        .catchError((error) => _doneCompleter.completeError(error));
  }
}

class Download extends FileTransfer {
  /// Start a new file download. This will begin the download from the server immediately.
  static Download start(RemoteFileDescription rfd) {
    return new Download._ofRemoteFile(rfd);
  }

  int _bytesLoaded;

  /// Construct a new file download.
  Download._ofRemoteFile(RemoteFileDescription rfd) : super(rfd.name) {
    _bytesLoaded = 0;

    // Prepare the download request.
    _request = new WRequest()..uri = getDownloadEndpointUrl(rfd.name);

    // Convert the progress stream into a broadcast stream to
    // allow multiple listeners.
    _progressStream = _request.downloadProgress.asBroadcastStream();
    _progressStream.listen(_progressListener);

    _progressStream.listen((WProgress progress) {
      if (_cancelled) return;

      if (progress.lengthComputable) {
        int delta = progress.loaded - _bytesLoaded;
        _concurrentFileTransferSize += delta;

        // When dealing with large (or many) files, it's possible that
        // we can run out of memory. Cancel requests after a certain threshold.
        if (_concurrentFileTransferSize > _concurrentFileTransferSizeLimit) {
          cancel(
              'Maximum concurrent file transfer size exceeded. Large files cannot be loaded into memory.');
        }

        _bytesLoaded = progress.loaded;
      }
    });

    // Send the request.
    _request.get().then((WResponse response) {
      _doneCompleter.complete();
    }, onError: (error) {
      _doneCompleter.completeError(error);
    });

    done.then((_) {
      _concurrentFileTransferSize -= _bytesLoaded;
    }, onError: (_) {
      _concurrentFileTransferSize -= _bytesLoaded;
    });
  }

  /// File being downloaded.
  File get file => _file;
  File _file;
}