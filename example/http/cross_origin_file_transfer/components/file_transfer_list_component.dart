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

// ignore: uri_has_not_been_generated
part 'file_transfer_list_component.over_react.g.dart';

/// List of all file uploads.
@Factory()
// ignore: undefined_identifier
UiFactory<FileTransferListProps> FileTransferList =
    // ignore: undefined_identifier
    _$FileTransferList;

@Props()
class _$FileTransferListProps extends UiProps {
  List<FileTransfer> transfers;
  String noTransfersMessage;
  bool hideChildrenFromPointerEvents;
  @requiredProp
  TransferDoneCallback onTransferDone;
}

@Component()
class FileTransferListComponent extends UiComponent<FileTransferListProps> {
  @override
  getDefaultProps() => newProps()
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
      ..className = classes.toClassName())(
      _renderFileTransferItems(),
    );
  }

  List<ReactElement> _renderFileTransferItems() {
    return props.transfers.map((transfer) {
      return (FileTransferListItem()
        ..key = transfer.id
        ..transfer = transfer
        ..onTransferDone = props.onTransferDone)();
    }).toList();
  }
}

// AF-3369 This will be removed once the transition to Dart 2 is complete.
// ignore: undefined_class
class FileTransferListProps extends _$FileTransferListProps
    // ignore: mixin_of_non_class, undefined_class
    with _$FileTransferListPropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForFileTransferListProps;
}
