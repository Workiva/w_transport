/*
 * Copyright 2015 Workiva Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

library w_transport.example.http.cross_origin_file_transfer.components.file_transfer_list_item_component;

import 'dart:async';

import 'package:react/react.dart' as react;

import '../services/file_transfer.dart';

const int _transferCompleteLingerDuration = 4; // 4 seconds
const int _transferCompleteFadeoutDuration = 2; // 2 seconds

/// A single file upload or download. Contains the file name, a progressbar,
/// and a control that allows cancellation of the upload or download.
var fileTransferListItemComponent =
    react.registerComponent(() => new FileTransferListItemComponent());
class FileTransferListItemComponent extends react.Component {
  Map getInitialState() {
    return {'done': false, 'success': false, 'will-remove': false,};
  }

  Map getDefaultProps() {
    return {'transfer': null, 'onTransferDone': (_) {},};
  }

  void componentWillMount() {
    FileTransfer transfer = this.props['transfer'];
    if (transfer != null) {
      transfer.progressStream.listen((_) => this.redraw());
      transfer.done
          .then((_) => _transferSucceeded())
          .catchError((error) => _transferFailed());
    }
  }

  /// Abort the file transfer (if it's still in progress)
  void _cancelTransfer(e) {
    e.preventDefault();
    if (this.props['transfer'] == null || this.state['done']) return;
    this.props['transfer'].cancel('User cancelled the file transfer.');
    this.setState({'done': true, 'success': false});
  }

  void _transferSucceeded() {
    this.setState({'done': true, 'success': true});
    _fadeTransferOut().then((_) => _removeTransfer());
  }

  void _transferFailed() {
    this.setState({'done': true, 'success': false});
    _fadeTransferOut().then((_) => _removeTransfer());
  }

  Future _fadeTransferOut() async {
    // wait a few seconds before beginning to fade the item out
    await new Future.delayed(
        new Duration(seconds: _transferCompleteLingerDuration));
    this.setState({'will-remove': true});
    // wait for the css transition to complete
    await new Future.delayed(
        new Duration(seconds: _transferCompleteFadeoutDuration));
  }

  void _removeTransfer() {
    this.props['onTransferDone'](this.props['transfer']);
  }

  render() {
    FileTransfer transfer = this.props['transfer'];
    if (transfer == null) return react.div({});
    String transferClass = '';
    if (this.state['done']) {
      transferClass = this.state['success'] ? 'success' : 'error';
      transferClass += ' done';
    }
    if (this.state['will-remove']) {
      transferClass += ' hide';
    }

    var label = [transfer.name];
    if (!this.state['done']) {
      label.addAll([
        ' (',
        react.a({'href': '#', 'onClick': _cancelTransfer}, 'cancel'),
        ')',
      ]);
    }

    return react.li({'className': transferClass}, [
      react.div({'className': 'name'}, label),
      react.div({'className': 'progress'}, react.div({
        'className': 'progress-bar',
        'style': {'width': '${transfer.percentComplete}%'}
      })),
    ]);
  }
}
