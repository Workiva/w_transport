library w_transport.src.http.mock.base_request;

import 'dart:async';

import 'package:w_transport/src/http/base_request.dart';
import 'package:w_transport/src/http/finalized_request.dart';
import 'package:w_transport/src/http/response.dart';

abstract class MockBaseRequest extends BaseRequest {
  Future get onCanceled;
  Future<FinalizedRequest> get onSent;
  void complete({BaseResponse response});
  void completeError({Object error, BaseResponse response});
  void causeFailureOnOpen();
}