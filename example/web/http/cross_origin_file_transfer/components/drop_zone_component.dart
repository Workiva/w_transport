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

import 'package:over_react/over_react.dart';

import '../services/file_transfer.dart';

// ignore: uri_has_not_been_generated
part 'drop_zone_component.over_react.g.dart';

typedef dynamic NewUploadsCallback(List<Upload> uploads);
typedef dynamic DragEventCallback(Event event);

/// File drop zone.
///
/// * Listens to drag and drop events and accepts one or many dropped files.
/// * Uploads each dropped file to a server via a POST request with a FormData payload.
@Factory()
// ignore: undefined_identifier
UiFactory<DropZoneProps> DropZone = $DropZone;

@Props()
class _$DropZoneProps extends UiProps {
  @requiredProp
  NewUploadsCallback onNewUploads;
  @requiredProp
  DragEventCallback onNativeDragStart;
  @requiredProp
  DragEventCallback onNativeDragEnd;
}

@State()
class _$DropZoneState extends UiState {
  /// True when user is dragging something over the drop zone
  bool overDropZone;

  /// True when user is dragging something onto the drop target
  bool overDropTarget;
}

@Component()
class DropZoneComponent
    extends UiStatefulComponent<DropZoneProps, DropZoneState> {
  Timer _hideDropTargetTimer;

  @override
  Map getInitialState() => newState()
    ..overDropZone = false
    ..overDropTarget = false;

  @override
  void componentWillMount() {
    super.componentWillMount();

    // Show the drop zone and drop target whenever a user
    // drags something onto the document.
    document.addEventListener('dragover', showDropTarget);
    document.addEventListener('dragleave', hideDropTarget);
    document.addEventListener('drop', preventNavigateOnDrop);
  }

  @override
  void componentWillUnmount() {
    super.componentWillUnmount();

    document.removeEventListener('dragover', showDropTarget);
    document.removeEventListener('dragleave', hideDropTarget);
    document.removeEventListener('drop', preventNavigateOnDrop);
  }

  void showDropTarget(Event e) {
    e.preventDefault();
    _hideDropTargetTimer?.cancel();
    props.onNativeDragStart(e);

    if (!state.overDropZone) {
      setState(newState()..overDropZone = true);
    }
  }

  void hideDropTarget(Event e) {
    // Delay this action slightly to allow it to be canceled.
    // This helps prevent a flicker when moving from the drop zone
    // to the drop target.
    _hideDropTargetTimer = new Timer(const Duration(milliseconds: 100), () {
      props.onNativeDragEnd(e);

      if (state.overDropZone) {
        setState(newState()..overDropZone = false);
      }
    });
  }

  void preventNavigateOnDrop(Event e) {
    e.preventDefault();
    hideDropTarget(e);
  }

  void enlargeDropTarget(SyntheticMouseEvent e) {
    // Prevent default to allow the drop
    e.preventDefault();

    var stateToSet = newState();

    if (!state.overDropTarget) {
      stateToSet.overDropTarget = true;
    }

    if (!state.overDropZone) {
      stateToSet.overDropZone = true;
    }

    if (stateToSet != null) {
      setState(stateToSet);
    }
  }

  void shrinkDropTarget(_) {
    var stateToSet = newState();

    if (state.overDropTarget) {
      stateToSet.overDropTarget = false;
    }

    if (!state.overDropZone) {
      stateToSet.overDropZone = true;
    }

    if (stateToSet != null) {
      setState(stateToSet);
    }
  }

  void uploadFiles(SyntheticMouseEvent e) {
    // Prevent drop from propagating to the browser,
    // which would normally navigate to the dropped file.
    e.preventDefault();

    // Start an upload for each dropped file
    List<Upload> newUploads = e.dataTransfer.files.map((file) {
      return Upload.start(file);
    }).toList();

    // Notify parent of new uploads
    props.onNewUploads(newUploads);
    props.onNativeDragEnd(null);

    var stateToSet = newState();

    if (state.overDropTarget) {
      stateToSet.overDropTarget = false;
    }

    if (state.overDropZone) {
      stateToSet.overDropZone = false;
    }

    if (stateToSet != null) {
      setState(stateToSet);
    }
  }

  @override
  dynamic render() {
    var dropZoneClasses = forwardingClassNameBuilder()
      ..add('drop-zone')
      ..add('active', state.overDropZone || state.overDropTarget);

    var dropTargetClasses = new ClassNameBuilder()
      ..add('drop-target')
      ..add('show', state.overDropZone || state.overDropTarget)
      ..add('over', state.overDropTarget);

    return (Dom.div()
      ..addProps(copyUnconsumedDomProps())
      ..className = dropZoneClasses.toClassName())((Dom.div()
      ..className = dropTargetClasses.toClassName()
      ..onDragOver = enlargeDropTarget
      ..onDragLeave = shrinkDropTarget
      ..onDrop = uploadFiles)('Drop Here to Upload'));
  }
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: mixin_of_non_class, undefined_class
class DropZoneProps extends _$DropZoneProps with _$DropZonePropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = $metaForDropZoneProps;
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: mixin_of_non_class, undefined_class
class DropZoneState extends _$DropZoneState with _$DropZoneStateAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const StateMeta meta = $metaForDropZoneState;
}
