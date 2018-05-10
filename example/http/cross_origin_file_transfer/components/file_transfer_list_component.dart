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

import '../../../common/typedefs.dart';
import '../services/file_transfer.dart';
import 'file_transfer_list_item_component.dart';

/// List of all file uploads.
@Factory()
UiFactory<FileTransferListProps> FileTransferList;

@Props()
class FileTransferListProps extends UiProps {
  List<FileTransfer> transfers;
  String noTransfersMessage;
  bool hideChildrenFromPointerEvents;
  @requiredProp
  TransferDoneCallback onTransferDone;
}

@Component()
class FileTransferListComponent extends UiComponent<FileTransferListProps> {
  @override
  Map getDefaultProps() => newProps()
    ..transfers = const <FileTransfer>[]
    ..noTransfersMessage = 'There are no pending transfers.'
    ..hideChildrenFromPointerEvents = false;

  @override
  dynamic render() {
    if (props.transfers.isEmpty) {
      return (Dom.p()..className = 'muted')(props.noTransfersMessage);
    }

    var classes = forwardingClassNameBuilder()
      ..add('transfers')
      ..add('no-pointer-events', props.hideChildrenFromPointerEvents);

    return (Dom.ul()
      ..addProps(copyUnconsumedDomProps())
      ..className = classes.toClassName()
    )(
      _renderFileTransferItems(),
    );
  }

  List<ReactElement> _renderFileTransferItems() {
    return props.transfers.map((transfer) {
      return (FileTransferListItem()
        ..key = transfer.id
        ..transfer = transfer
        ..onTransferDone = props.onTransferDone
      )();
    }).toList();
  }
}
