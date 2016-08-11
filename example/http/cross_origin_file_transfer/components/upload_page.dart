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

library w_transport.example.http.cross_origin_file_transfer.components.upload_page;

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';
import 'drop_zone_component.dart';
import 'file_transfer_list_component.dart';

var uploadPage = react.registerComponent(() => new UploadPage());

class UploadPage extends react.Component {
  Map getDefaultProps() {
    return {
      'active': true,
    };
  }

  Map getInitialState() {
    return {
      // Whether or not the user is currently dragging something.
      // Used to fix a bug with dragover/dragleave events.
      'dragging': false,
      // List of in-progress or completed file transfers
      'uploads': [],
    };
  }

  /// Listen for new file uploads and forward them to the file transfer list component.
  void _newUploads(List<Upload> newUploads) {
    List<Upload> uploads = [];
    uploads.addAll(this.state['uploads']);
    uploads.addAll(newUploads);
    this.setState({'uploads': uploads});
  }

  /// Called when the file transfer list component is done with the transfer
  /// and no longer needs to display it, meaning we can remove it
  /// from memory.
  void _removeUpload(Upload upload) {
    List<Upload> uploads = [];
    uploads.addAll(this.state['uploads']);
    uploads.remove(upload);
    this.setState({'uploads': uploads});
  }

  void _dragStart() {
    this.setState({'dragging': true});
  }

  void _dragEnd() {
    this.setState({'dragging': false});
  }

  render() {
    return react.div({
      'className': this.props['active'] ? '' : 'hidden'
    }, [
      react.h2({}, 'Uploads'),
      dropZoneComponent({
        'onNewUploads': _newUploads,
        'onDragStart': _dragStart,
        'onDragEnd': _dragEnd,
      }),
      fileTransferListComponent({
        'hideChildrenFromPointerEvents': this.state['dragging'],
        'noTransfersMessage':
            'There are no pending uploads. Drag and drop some files to upload them.',
        'onTransferDone': _removeUpload,
        'transfers': this.state['uploads'],
      }),
    ]);
  }
}
