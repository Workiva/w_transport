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

import 'package:over_react/over_react.dart';

import '../services/file_transfer.dart';
import 'drop_zone_component.dart';
import 'file_transfer_list_component.dart';

// ignore: uri_has_not_been_generated
part 'upload_page.over_react.g.dart';

@Factory()
// ignore: undefined_identifier
UiFactory<UploadPageProps> UploadPage =
    // ignore: undefined_identifier
    _$UploadPage;

@Props()
class _$UploadPageProps extends UiProps {
  bool isActive;
}

@State()
class _$UploadPageState extends UiState {
  bool isDragging;
  List<Upload> uploads;
}

@Component()
class UploadPageComponent
    extends UiStatefulComponent<UploadPageProps, UploadPageState> {
  @override
  Map getDefaultProps() => newProps()..isActive = true;

  @override
  Map getInitialState() => newState()
    ..isDragging = false
    ..uploads = const <Upload>[];

  /// Listen for new file uploads and forward them to the file transfer list component.
  void _newUploads(List<Upload> newUploads) {
    final uploads = <Upload>[];
    uploads.addAll(state.uploads);
    uploads.addAll(newUploads);
    setState(newState()..uploads = uploads);
  }

  /// Called when the file transfer list component is done with the transfer
  /// and no longer needs to display it, meaning we can remove it
  /// from memory.
  void _removeUpload(Upload upload) {
    final uploads = <Upload>[];
    uploads.addAll(state.uploads);
    uploads.remove(upload);
    setState(newState()..uploads = uploads);
  }

  void _dragStart(_) {
    if (state.isDragging) return;

    setState(newState()..isDragging = true);
  }

  void _dragEnd(_) {
    if (!state.isDragging) return;

    setState(newState()..isDragging = false);
  }

  @override
  dynamic render() {
    var classes = forwardingClassNameBuilder()..add('hidden', !props.isActive);

    return (Dom.div()
      ..addProps(copyUnconsumedDomProps())
      ..className = classes.toClassName()
      ..aria.hidden = !props.isActive)(
      Dom.h2()('File Uploads'),
      (DropZone()
        ..onNewUploads = _newUploads
        ..onNativeDragStart = _dragStart
        ..onNativeDragEnd = _dragEnd)(),
      (FileTransferList()
        ..transfers = state.uploads
        ..onTransferDone = _removeUpload
        ..hideChildrenFromPointerEvents = state.isDragging
        ..noTransfersMessage =
            'There are no pending uploads. Drag and drop some files to upload them.')(),
    );
  }
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: mixin_of_non_class, undefined_class
class UploadPageProps extends _$UploadPageProps
    with _$UploadPagePropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForUploadPageProps;
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: mixin_of_non_class, undefined_class
class UploadPageState extends _$UploadPageState
    with _$UploadPageStateAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const StateMeta meta = _$metaForUploadPageState;
}
