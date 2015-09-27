library w_transport.src.http.browser.multipart_request;

import 'dart:html';

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap, MediaType;

import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/request_mixin.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/requests.dart';

class BrowserMultipartRequest extends CommonRequest with BrowserRequestMixin implements MultipartRequest {
  BrowserMultipartRequest() : super();
  BrowserMultipartRequest.withClient(client) : super.withClient(client);

  Map<String, String> _fields = {};

  Map<String, Blob> _files = {};

  @override
  int get contentLength {
    // Let the browser set the content-length.
    return null;
  }

  @override
  set contentLength(int contentLength) {
    throw new UnsupportedError('The content-length of a multipart request cannot be set manually.');
  }

  @override
  MediaType get defaultContentType {
    // Let the browser set the content-type.
    return null;
  }

  Map<String, String> get fields
      => isSent ? new Map.unmodifiable(_fields) : _fields;

  Map<String, Blob> get files
      => isSent ? new Map.unmodifiable(_files) : _files;

  @override
  Map<String, String> finalizeHeaders() {
    var headers = new CaseInsensitiveMap.from(super.finalizeHeaders());

    // Remove the content-type header to allow the browser to set it.
    headers.remove('content-type');

    return new Map.unmodifiable(headers);
  }

  @override
  FormDataBody finalizeBody([body]) {
    if (body != null) {
      throw new UnsupportedError('The body of a Multipart request must be set via `fields` and/or `files`.');
    }

    FormData formData = new FormData();
    fields.forEach(formData.append);
    files.forEach((name, blob) {
      if (blob is File) {
        formData.appendBlob(name, blob, blob.name);
      } else {
        formData.appendBlob(name, blob);
      }
    });

    return new FormDataBody(formData);
  }
}