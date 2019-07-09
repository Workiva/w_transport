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
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:over_react/over_react.dart';
import 'package:w_transport/w_transport.dart';

import '../services/file_transfer.dart';
import '../services/remote_files.dart';
import 'file_transfer_list_component.dart';

// ignore: uri_has_not_been_generated
part 'download_page.over_react.g.dart';

final _gb = math.pow(2, 30);
final _mb = math.pow(2, 20);
final _kb = math.pow(2, 10);

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

  return '${size.toStringAsFixed(1)} $unit';
}

@Factory()
// ignore: undefined_identifier
UiFactory<DownloadPageProps> DownloadPage =
    // ignore: undefined_identifier
    _$DownloadPage;

@Props()
class _$DownloadPageProps extends UiProps {
  bool isActive;
}

@State()
class _$DownloadPageState extends UiState {
  /// List of in-progress or completed downloads.
  List<Download> downloads;

  /// Error (if any) when trying to communicate with the remote files server.
  RequestException error;

  /// List of descriptions of files on the remote server.
  List<RemoteFileDescription> fileDescriptions;
}

@Component()
class DownloadPageComponent
    extends UiStatefulComponent<DownloadPageProps, DownloadPageState> {
  RemoteFiles remoteFiles;
  StreamSubscription<List<RemoteFileDescription>> fileStreamSubscription;
  StreamSubscription<RequestException> fileStreamErrorSubscription;

  @override
  getDefaultProps() => newProps()..isActive = false;

  @override
  getInitialState() => newState()
    ..downloads = const <Download>[]
    ..fileDescriptions = const <RemoteFileDescription>[];

  @override
  void componentWillMount() {
    super.componentWillMount();

    remoteFiles = RemoteFiles.connect();
    fileStreamSubscription = remoteFiles.stream.listen((fileDescriptions) {
      var stateToSet = newState();

      if (!ListEquality<RemoteFileDescription>()
          .equals(fileDescriptions, state.fileDescriptions)) {
        stateToSet.fileDescriptions = fileDescriptions;
      }

      if (state.error != null) {
        stateToSet.error = null;
      }

      if (stateToSet != null) {
        setState(stateToSet);
      }
    });
    fileStreamErrorSubscription = remoteFiles.errorStream.listen((error) {
      if (state.error != error) {
        setState(newState()..error = error);
      }
    });
  }

  @override
  void componentWillUnmount() {
    super.componentWillUnmount();

    remoteFiles.close();
    fileStreamSubscription.cancel();
    fileStreamErrorSubscription.cancel();
  }

  MouseEventCallback _createDownloadFileCallback(RemoteFileDescription rfd) {
    return (event) {
      event.preventDefault();
      _downloadFile(rfd);
    };
  }

  void _deleteAllRemoteFiles(SyntheticMouseEvent event) {
    event.preventDefault();
    RemoteFiles.deleteAll();
  }

  void _downloadFile(RemoteFileDescription rfd) {
    final downloads = List<Download>.from(state.downloads);
    downloads.add(Download.start(rfd));
    setState(newState()..downloads = downloads);
  }

  /// Called when the file transfer list component is done with the transfer
  /// and no longer needs to display it, meaning we can remove it
  /// from memory.
  void _removeDownload(Download download) {
    final downloads = <Download>[];
    downloads.addAll(state.downloads);
    downloads.remove(download);
    setState(newState()..downloads = downloads);
  }

  @override
  dynamic render() {
    var classes = forwardingClassNameBuilder()..add('hidden', !props.isActive);

    return (Dom.div()
      ..addProps(copyUnconsumedDomProps())
      ..className = classes.toClassName()
      ..aria.hidden = !props.isActive)(
      Dom.h2()('File Downloads'),
      (Dom.p()..className = 'note')('''
        Note: Loading large files into memory will crash the browser tab. 
        For this reason, downloads will be canceled automatically if a 
        concurrent file transfer size of 75 MB is exceeded.
        '''),
      (FileTransferList()
        ..transfers = state.downloads
        ..onTransferDone = _removeDownload)(),
      Dom.h3()('Remote Files'),
      Dom.p()(
        (Dom.span()..className = 'muted d-block')(
          'Click a file to download it. ',
        ),
        (Dom.a()
          ..href = '#'
          ..onClick = _deleteAllRemoteFiles)(
          'Click here to delete all remote files.',
        ),
      ),
      _renderErrorMessage(),
      (Dom.div()..className = 'files clear')(
        _renderFileDescriptionLinks(),
      ),
    );
  }

  ReactElement _renderErrorMessage() {
    if (state.error == null) return null;

    return (Dom.p()..className = 'error')(
      'Could not retrieve the remote file list from the server.',
    );
  }

  List<ReactElement> _renderFileDescriptionLinks() {
    if (state.fileDescriptions.isEmpty) return null;

    final fileDescriptionLinks = <ReactElement>[];
    for (var fileDescription in state.fileDescriptions) {
      fileDescriptionLinks.add((Dom.a()
        ..key = fileDescription.name
        ..className = 'file'
        ..href = '#'
        ..onClick = _createDownloadFileCallback(fileDescription))(
        (Dom.div()..className = 'file-name')(
          fileDescription.name,
        ),
        (Dom.div()..className = 'file-size')(
          _humanizeFileSize(fileDescription.size),
        ),
      ));
    }

    return fileDescriptionLinks;
  }
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: undefined_class
class DownloadPageProps extends _$DownloadPageProps
    // ignore: mixin_of_non_class, undefined_class
    with _$DownloadPagePropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForDownloadPageProps;
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: undefined_class
class DownloadPageState extends _$DownloadPageState
    // ignore: mixin_of_non_class, undefined_class
    with _$DownloadPageStateAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const StateMeta meta = _$metaForDownloadPageState;
}
