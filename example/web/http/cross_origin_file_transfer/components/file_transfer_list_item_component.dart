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

// ignore: uri_has_not_been_generated
part 'file_transfer_list_item_component.over_react.g.dart';

const Duration _transferCompleteLingerDuration = Duration(seconds: 4);
const Duration _transferCompleteFadeoutDuration = Duration(seconds: 2);

/// A single file upload or download.
///
/// Contains the file name, a progressbar, and a control
/// that allows cancellation of the upload or download.
@Factory()
// ignore: undefined_identifier
UiFactory<FileTransferListItemProps> FileTransferListItem =
    // ignore: undefined_identifier
    _$FileTransferListItem;

@Props()
class _$FileTransferListItemProps extends UiProps {
  FileTransfer transfer;
  @requiredProp
  TransferDoneCallback onTransferDone;
}

@State()
class _$FileTransferListItemState extends UiState {
  FileTransferItemStatus status;
}

@Component2()
class FileTransferListItemComponent extends UiStatefulComponent2<
    FileTransferListItemProps, FileTransferListItemState> {
  bool get fileTransferIsDone =>
      state.status == FileTransferItemStatus.doneSuccess ||
      state.status == FileTransferItemStatus.doneFailure;

  @override
  get initialState => (newState()..status = FileTransferItemStatus.idle);

  @override
  void componentDidMount() {
    super.componentDidMount();

    if (props.transfer != null) {
      props.transfer.progressStream.listen((_) => forceUpdate());
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
    await Future.delayed(_transferCompleteLingerDuration);

    setState(newState()..status = FileTransferItemStatus.willRemove);

    // wait for the css transition to complete
    await Future.delayed(_transferCompleteFadeoutDuration);
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
      ..modifyProps(addUnconsumedDomProps)
      ..className = classes.toClassName())(
      (Dom.div()..className = 'name')(
        _renderTransferItemLabel(),
      ),
      (Dom.div()..className = 'progress')((Dom.div()
        ..role = 'progress'
        ..className = 'progress-bar'
        ..style = {'width': '${props.transfer.percentComplete}%'}
        ..aria.valuemin = 0
        ..aria.valuemax = 100
        ..aria.valuenow = props.transfer.percentComplete)()),
    );
  }

  dynamic _renderTransferItemLabel() {
    final label = <dynamic>[props.transfer.name];
    if (!fileTransferIsDone) {
      label.addAll([
        ' (',
        (Dom.a()
          ..key = 'cancel-transfer-link'
          ..href = '#'
          ..onClick = _cancelTransfer)('cancel'),
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

// AF-3369 This will be removed once the transition to Dart 2 is complete.
class FileTransferListItemProps extends _$FileTransferListItemProps
    with
        // ignore: mixin_of_non_class, undefined_class
        _$FileTransferListItemPropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForFileTransferListItemProps;
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
class FileTransferListItemState extends _$FileTransferListItemState
    with
        // ignore: mixin_of_non_class, undefined_class
        _$FileTransferListItemStateAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const StateMeta meta = _$metaForFileTransferListItemState;
}
