library w_transport.example.http.cross_origin_file_transfer.components.upload_page;

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';
import './drop_zone_component.dart';
import './file_transfer_list_component.dart';


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
    return react.div({'className': this.props['active'] ? '' : 'hidden'}, [
      react.h2({}, 'Uploads'),
      dropZoneComponent({'onNewUploads': _newUploads, 'onDragStart': _dragStart, 'onDragEnd': _dragEnd}),
      fileTransferListComponent({
        'hideChildrenFromPointerEvents': this.state['dragging'],
        'noTransfersMessage': 'There are no pending uploads. Drag and drop some files to upload them.',
        'onTransferDone': _removeUpload,
        'transfers': this.state['uploads'],
      }),
    ]);
  }

}