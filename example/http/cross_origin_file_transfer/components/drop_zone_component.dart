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

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';

/// File drop zone. Listens to drag and drop events and accepts
/// one or many dropped files. Uploads each dropped file to a
/// server via a POST request with a FormData payload.
dynamic dropZoneComponent =
    react.registerComponent(() => new DropZoneComponent());

class DropZoneComponent extends react.Component {
  Timer _hideDropTargetTimer;

  @override
  Map getInitialState() {
    return {
      // True when user is dragging something over the drop zone
      'overDropZone': false,
      // True when user is dragging something onto the drop target
      'overDropTarget': false,
    };
  }

  @override
  Map getDefaultProps() {
    return {
      'onNewUploads': (_) {},
      'onDragStart': () {},
      'onDragEnd': () {},
    };
  }

  @override
  void componentWillMount() {
    // Show the drop zone and drop target whenever a user
    // drags something onto the document.
    document.addEventListener('dragover', showDropTarget);
    document.addEventListener('dragleave', hideDropTarget);
    document.addEventListener('drop', preventNavigateOnDrop);
  }

  @override
  void componentWillUnmount() {
    document.removeEventListener('dragover', showDropTarget);
    document.removeEventListener('dragleave', hideDropTarget);
    document.removeEventListener('drop', preventNavigateOnDrop);
  }

  void showDropTarget(Event e) {
    if (_hideDropTargetTimer != null) {
      _hideDropTargetTimer.cancel();
    }
    e.preventDefault();
    this.props['onDragStart']();
    this.setState({'overDropZone': true});
  }

  void hideDropTarget(Event e) {
    // Delay this action slightly to allow it to be canceled.
    // This helps prevent a flicker when moving from the drop zone
    // to the drop target.
    _hideDropTargetTimer = new Timer(new Duration(milliseconds: 100), () {
      this.props['onDragEnd']();
      this.setState({'overDropZone': false});
    });
  }

  void preventNavigateOnDrop(Event e) {
    e.preventDefault();
    hideDropTarget(e);
  }

  void enlargeDropTarget(react.SyntheticMouseEvent e) {
    // Prevent default to allow the drop
    e.preventDefault();
    this.setState({'overDropTarget': true, 'overDropZone': true});
  }

  void shrinkDropTarget(react.SyntheticMouseEvent e) {
    this.setState({'overDropTarget': false, 'overDropZone': true});
  }

  void uploadFiles(react.SyntheticMouseEvent e) {
    // Prevent drop from propagating to the browser,
    // which would normally navigate to the dropped file.
    e.preventDefault();

    // Start an upload for each dropped file
    List<Upload> newUploads = e.dataTransfer.files.map((File file) {
      return Upload.start(file);
    }).toList();

    // Notify parent of new uploads
    this.props['onNewUploads'](newUploads);
    this.props['onDragEnd']();

    this.setState({'overDropZone': false, 'overDropTarget': false});
  }

  @override
  dynamic render() {
    String dropZoneClass = 'drop-zone';
    String dropTargetClass = 'drop-target';

    if (this.state['overDropZone'] || this.state['overDropTarget']) {
      dropZoneClass += ' active';
      dropTargetClass += ' show';
    }
    if (this.state['overDropTarget']) {
      dropTargetClass += ' over';
    }

    var dropZoneProps = {'className': dropZoneClass};
    var dropTargetProps = {
      'className': dropTargetClass,
      'onDragOver': enlargeDropTarget,
      'onDragLeave': shrinkDropTarget,
      'onDrop': uploadFiles,
    };

    return react.div(
        dropZoneProps, react.div(dropTargetProps, 'Drop Here to Upload'));
  }
}
