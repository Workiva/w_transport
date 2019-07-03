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
import 'dart:math' as math;

import 'package:w_transport/w_transport.dart';

import 'proxy.dart';
import 'remote_files.dart';

// Counter used to create unique upload IDs.
int _transferNum = 0;

// Current number of bytes in memory from concurrent file transfers.
int _concurrentFileTransferSize = 0;

// Maximum number of bytes from concurrent file transfers that can be
// loaded into memory before potentially crashing the browser tab.
final int _concurrentFileTransferSizeLimit = math.pow(2, 20) * 75; // 75 MB

/// Encapsulates the file upload to or file download from the server.
class FileTransfer {
  BaseRequest _request;
  bool _canceled;

  FileTransfer(this.name)
      : id = 'fileTransfer${_transferNum++}',
        _canceled = false,
        _doneCompleter = Completer<Null>(),
        _percentComplete = 0.0;

  /// Unique file transfer identifier.
  final String id;

  /// Name of the file being transferred.
  final String name;

  /// Stream of ProgressEvents that may be used to monitor upload progress.
  Stream<RequestProgress> get progressStream => _progressStream;
  Stream<RequestProgress> _progressStream;

  /// Current completion percentage.
  double get percentComplete => _percentComplete;
  double _percentComplete;

  /// Whether or not the request has finished.
  Future<Null> get done => _doneCompleter.future;
  Completer<Null> _doneCompleter;

  /// Cancel the request (will do nothing if the request has already finished).
  void cancel(String reason) {
    _canceled = true;
    _request.abort(reason != null ? Exception(reason) : null);
  }

  void _progressListener(RequestProgress progress) {
    if (_canceled) return;
    _percentComplete = progress.percent;
  }
}

/// Encapsulates the upload of a file from the client to the server.
class Upload extends FileTransfer {
  /// Construct a new file upload.
  Upload._fromFile(File file) : super(file.name) {
    // Prepare the upload request.
    _request = MultipartRequest()
      ..uri = getUploadEndpointUrl()
      ..fields['datetime'] = DateTime.now().toIso8601String()
      ..files['file'] = file;

    // Convert the progress stream into a broadcast stream to
    // allow multiple listeners.
    _progressStream = _request.uploadProgress.asBroadcastStream();
    _progressStream.listen(_progressListener);

    // Send the request.
    _request
        .post()
        .then((_) => _doneCompleter.complete())
        .catchError((error, sT) => _doneCompleter.completeError(error, sT));
  }

  /// Start a new file upload. This will begin the upload to the server immediately.
  static Upload start(File file) {
    return Upload._fromFile(file);
  }
}

class Download extends FileTransfer {
  int _bytesLoaded;

  /// Construct a new file download.
  Download._ofRemoteFile(RemoteFileDescription rfd) : super(rfd.name) {
    _bytesLoaded = 0;

    // Prepare the download request.
    _request = Request()..uri = getDownloadEndpointUrl(rfd.name);

    // Convert the progress stream into a broadcast stream to
    // allow multiple listeners.
    _progressStream = _request.downloadProgress.asBroadcastStream();
    _progressStream.listen(_progressListener);

    _progressStream.listen((progress) {
      if (_canceled) return;

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
    _request.get().then((response) {
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

  /// Start a new file download. This will begin the download from the server immediately.
  static Download start(RemoteFileDescription rfd) {
    return Download._ofRemoteFile(rfd);
  }
}
