library w_transport.src.http.browser.form_data_body;

import 'dart:convert';
import 'dart:html';

import 'package:http_parser/http_parser.dart';

import 'package:w_transport/src/http/http_body.dart';

class FormDataBody extends BaseHttpBody {
  final FormData formData;
  FormDataBody(FormData this.formData);
  int get contentLength => null;
  MediaType get contentType => null;
  Encoding get encoding => null;
}
