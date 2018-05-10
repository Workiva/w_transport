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

import 'package:over_react/over_react.dart';

import '../../../common/typedefs.dart';
import '../services/file_transfer.dart';

const Duration _transferCompleteLingerDuration = const Duration(seconds: 4);
const Duration _transferCompleteFadeoutDuration = const Duration(seconds: 2);

/// A single file upload or download.
///
/// Contains the file name, a progressbar, and a control
/// that allows cancellation of the upload or download.
@Factory()
UiFactory<FileTransferListItemProps> FileTransferListItem;

@Props()
class FileTransferListItemProps extends UiProps {
  FileTransfer transfer;
  @requiredProp
  TransferDoneCallback onTransferDone;
}

@State()
class FileTransferListItemState extends UiState {
  FileTransferItemStatus status;
}

@Component()
class FileTransferListItemComponent extends UiStatefulComponent<FileTransferListItemProps, FileTransferListItemState> {
  bool get fileTransferIsDone => state.status == FileTransferItemStatus.doneSuccess ||
      state.status == FileTransferItemStatus.doneFailure;

  @override
  Map getInitialState() => newState()..status = FileTransferItemStatus.idle;

  @override
  void componentWillMount() {
    super.componentWillMount();

    if (props.transfer != null) {
      props.transfer.progressStream.listen((_) => redraw());
      props.transfer.done
          .then((_) => _transferSucceeded())
          .catchError((error, sT) => _transferFailed(error, sT));
    }
  }

  /// Abort the file transfer (if it's still in progress)
  void _cancelTransfer(SyntheticMouseEvent event) {
    event.preventDefault();

    if (props.transfer == null || fileTransferIsDone) return;

    props.transfer.cancel('User canceled the file transfer.');

    setState(newState()..status = FileTransferItemStatus.doneFailure);
  }

  void _transferSucceeded() {
    if (state.status != FileTransferItemStatus.doneSuccess) {
      setState(newState()..status = FileTransferItemStatus.doneSuccess);
    }

    _fadeTransferOut().then((_) => _removeTransfer());
  }

  void _transferFailed(error, [StackTrace sT]) {
    print('Transfer failed: $error');
    if (sT != null) {
      print('$sT');
    }

    if (state.status != FileTransferItemStatus.doneFailure) {
      setState(newState()..status = FileTransferItemStatus.doneFailure);
    }

    _fadeTransferOut().then((_) => _removeTransfer());
  }

  Future<Null> _fadeTransferOut() async {
    // wait a few seconds before beginning to fade the item out
    await new Future.delayed(_transferCompleteLingerDuration);

    setState(newState()..status = FileTransferItemStatus.willRemove);

    // wait for the css transition to complete
    await new Future.delayed(_transferCompleteFadeoutDuration);
  }

  void _removeTransfer() {
    props.onTransferDone(props.transfer);
  }

  @override
  dynamic render() {
    if (props.transfer == null) return false;

    var classes = forwardingClassNameBuilder()
      ..add('success done', state.status == FileTransferItemStatus.doneSuccess)
      ..add('error done', state.status == FileTransferItemStatus.doneFailure)
      ..add('hide', state.status == FileTransferItemStatus.willRemove);

    return (Dom.li()
      ..addProps(copyUnconsumedDomProps())
      ..className = classes.toClassName()
    )(
      (Dom.div()..className = 'name')(
        _renderTransferItemLabel(),
      ),
      (Dom.div()..className = 'progress')(
        (Dom.div()
          ..role = 'progress'
          ..className = 'progress-bar'
          ..style = {'width': '${props.transfer.percentComplete}%'}
          ..aria.valuemin = 0
          ..aria.valuemax = 100
          ..aria.valuenow = props.transfer.percentComplete
        )()
      ),
    );
  }

  List<ReactElement> _renderTransferItemLabel() {
    final label = <dynamic>[props.transfer.name];
    if (!fileTransferIsDone) {
      label.addAll([
        ' (',
        (Dom.a()
          ..key = 'cancel-transfer-link'
          ..href = '#'
          ..onClick = _cancelTransfer
        )('cancel'),
        ')',
      ]);
    }

    return label;
  }
}

/// The possible values for [FileTransferListItemState.status].
enum FileTransferItemStatus {
  idle,
  doneSuccess,
  doneFailure,
  willRemove,
}
