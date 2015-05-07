/**
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

library w_transport.example.http.cross_origin_file_transfer.components.download_page;

import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';
import '../services/remote_files.dart';
import './file_transfer_list_component.dart';

final double _gb = math.pow(2, 30);
final double _mb = math.pow(2, 20);
final double _kb = math.pow(2, 10);

var downloadPage = react.registerComponent(() => new DownloadPage());
class DownloadPage extends react.Component {
  RemoteFiles remoteFiles;
  StreamSubscription fileStreamSubscription;
  StreamSubscription fileStreamErrorSubscription;

  Map getDefaultProps() {
    return {'active': false,};
  }

  Map getInitialState() {
    return {
      // List of in-progress or completed downloads
      'downloads': [],
      // Error (if any) when trying to communicate with the remote files server
      'error': null,
      // List of descriptions of files on the remote server
      'fileDescriptions': [],
    };
  }

  void componentWillMount() {
    remoteFiles = RemoteFiles.connect();
    fileStreamSubscription = remoteFiles.stream
        .listen((List<RemoteFileDescription> fileDescriptions) {
      this.setState({'fileDescriptions': fileDescriptions, 'error': null,});
    });
    fileStreamErrorSubscription = remoteFiles.errorStream.listen((error) {
      this.setState({'error': error});
    });
  }

  void componentWillUnmount() {
    remoteFiles.close();
    fileStreamSubscription.cancel();
    fileStreamErrorSubscription.cancel();
  }

  Function _createDownloadFileCallback(RemoteFileDescription rfd) {
    return (e) {
      e.preventDefault();
      _downloadFile(rfd);
    };
  }

  void _deleteAllRemoteFiles(e) {
    e.preventDefault();
    RemoteFiles.deleteAll();
  }

  void _downloadFile(RemoteFileDescription rfd) {
    List downloads = new List.from(this.state['downloads']);
    downloads.add(Download.start(rfd));
    this.setState({'downloads': downloads});
  }

  String _humanizeFileSize(int bytes) {
    double size = bytes.toDouble();
    String unit = 'bytes';

    // GB
    if (bytes > _gb) {
      size = bytes / _gb;
      unit = 'GB';
    }

    // MB
    else if (bytes > _mb) {
      size = bytes / _mb;
      unit = 'MB';
    }

    // KB
    else if (bytes > _kb) {
      size = bytes / _kb;
      unit = 'KB';
    }

    return '${size.toStringAsFixed(1)} ${unit}';
  }

  /// Called when the file transfer list component is done with the transfer
  /// and no longer needs to display it, meaning we can remove it
  /// from memory.
  void _removeDownload(Download download) {
    List<Download> downloads = [];
    downloads.addAll(this.state['downloads']);
    downloads.remove(download);
    this.setState({'downloads': downloads});
  }

  render() {
    if (!this.props['active']) return null;

    var error = '';
    if (this.state['error'] != null) {
      error = react.p({
        'className': 'error'
      }, 'Could not retrieve the remote file list from the server.');
    }

    var fileDescriptions = [];
    this.state['fileDescriptions'].forEach((RemoteFileDescription rfd) {
      fileDescriptions.add(react.a({
        'className': 'file',
        'href': '#',
        'key': rfd.name,
        'onClick': _createDownloadFileCallback(rfd)
      }, [
        react.div({'className': 'file-name',}, rfd.name),
        react.div({'className': 'file-size'}, _humanizeFileSize(rfd.size)),
      ]));
    });

    return react.div({'className': this.props['active'] ? '' : 'hidden'}, [
      react.h2({}, 'File Downloads'),
      react.p({
        'className': 'note'
      }, 'Note: Loading large files into memory will crash the browser tab. For this reason, downloads will be cancelled automatically if a concurrent file transfer size of 75 MB is exceeded.'),
      fileTransferListComponent({
        'transfers': this.state['downloads'],
        'onTransferDone': _removeDownload
      }),
      react.h2({}, 'Remote Files'),
      react.p({}, [
        react.div({'className': 'muted'}, 'Click a file to download it. '),
        react.a({
          'href': '#',
          'onClick': _deleteAllRemoteFiles
        }, 'Click here to delete all remote files.'),
      ]),
      error,
      react.div({'className': 'files clear'}, fileDescriptions),
    ]);
  }
}
