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

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';
import 'file_transfer_list_item_component.dart';

/// List of all file uploads.
dynamic fileTransferListComponent =
    react.registerComponent(() => new FileUploadListComponent());

class FileUploadListComponent extends react.Component {
  @override
  Map getDefaultProps() {
    return {
      'noTransfersMessage': 'There are no pending transfers.',
      'transfers': [],
      'onTransferDone': () {},
      'hideChildrenFromPointerEvents': false,
    };
  }

  @override
  dynamic render() {
    if (props['transfers'].length <= 0) {
      return react.p({'className': 'muted'}, props['noTransfersMessage']);
    }

    Iterable transfers = props['transfers'].map((FileTransfer transfer) {
      return fileTransferListItemComponent({
        'key': transfer.id,
        'transfer': transfer,
        'onTransferDone': props['onTransferDone'],
      });
    });
    String fileListClass = 'transfers';
    if (props['hideChildrenFromPointerEvents']) {
      fileListClass += ' no-pointer-events';
    }
    return react.ul({'className': fileListClass}, transfers);
  }
}
