library w_transport.example.http.cross_origin_file_transfer.components.file_transfer_list_component;

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';
import './file_transfer_list_item_component.dart';


/// List of all file uploads.
var fileTransferListComponent = react.registerComponent(() => new FileUploadListComponent());
class FileUploadListComponent extends react.Component {
  Map getDefaultProps() {
    return {
      'noTransfersMessage': 'There are no pending transfers.',
      'transfers': [],
      'onTransferDone': () {},
      'hideChildrenFromPointerEvents': false,
    };
  }

  render() {
    if (this.props['transfers'].length <= 0) {
      return react.p({'className': 'muted'}, this.props['noTransfersMessage']);
    }

    Iterable transfers = this.props['transfers'].map((FileTransfer transfer) {
      return fileTransferListItemComponent({'key': transfer.id, 'transfer': transfer, 'onTransferDone': this.props['onTransferDone']});
    });
    String fileListClass = 'transfers';
    if (this.props['hideChildrenFromPointerEvents']) {
      fileListClass += ' no-pointer-events';
    }
    return react.ul({'className': fileListClass}, transfers);
  }
}