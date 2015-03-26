library w_transport.example.http.cross_origin_file_transfer.services.file_transfer;

import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

import 'package:w_transport/w_http_client.dart';

import './proxy.dart';
import './remote_files.dart';


// Counter used to create unique upload IDs.
int _transferNum = 0;

// Maximum number of bytes from concurrent file transfers that can be
// loaded into memory before potentially crashing the browser tab.
int _concurrentFileTransferSizeLimit = math.pow(2, 20) * 75; // 75 MB

// Current number of bytes in memory from concurrent file transfers.
int _concurrentFileTransferSize = 0;


/// Encapsulates the file upload to or file download from the server.
class FileTransfer {
  WRequest _http;
  bool _cancelled;

  FileTransfer(String name) : id = 'fileTransfer${_transferNum++}',
                              _name = name,
                              _cancelled = false,
                              _doneCompleter = new Completer(),
                              _percentComplete = 0.0 {
  }

  /// Unique file transfer identifier.
  final String id;

  /// Name of the file being transferred.
  String get name => _name;
  String _name;

  /// Stream of ProgressEvents that may be used to monitor upload progress.
  Stream<ProgressEvent> get progressStream => _progressStream;
  Stream<ProgressEvent> _progressStream;

  /// Current completion percentage.
  double get percentComplete => _percentComplete;
  double _percentComplete;

  /// Whether or not the request has finished.
  Future get done => _doneCompleter.future;
  Completer _doneCompleter;

  /// Cancel the request (will do nothing if the request has already finished).
  void cancel(String reason) {
    _cancelled = true;
    _http.abort();
    _doneCompleter.completeError(reason != null ? new Exception(reason) : null);
  }

  void _progressListener(ProgressEvent event) {
    if (_cancelled) return;

    if (event.lengthComputable) {
      _percentComplete = event.loaded / event.total * 100;
    }
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
    _http = new WRequest()
      ..url = getUploadEndpointUrl()
      ..data = data;

    // Convert the progress stream into a broadcast stream to
    // allow multiple listeners.
    _progressStream = _http.uploadProgress.asBroadcastStream();
    _progressStream.listen(_progressListener);

    // Send the request.
    _http
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
    _http = new WRequest()..url = getDownloadEndpointUrl(rfd.name);

    // Convert the progress stream into a broadcast stream to
    // allow multiple listeners.
    _progressStream = _http.downloadProgress.asBroadcastStream();
    _progressStream.listen(_progressListener);

    _progressStream.listen((ProgressEvent event) {
      if (_cancelled) return;

      if (event.lengthComputable) {
        int delta = event.loaded - _bytesLoaded;
        _concurrentFileTransferSize += delta;

        // When dealing with large (or many) files, it's possible that
        // we can run out of memory. Cancel requests after a certain threshold.
        if (_concurrentFileTransferSize > _concurrentFileTransferSizeLimit) {
          cancel('Maximum concurrent file transfer size exceeded. Large files cannot be loaded into memory.');
        }

        _bytesLoaded = event.loaded;
      }
    });

    // Send the request.
    _http
      .get()
      .then((WResponse response) {
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