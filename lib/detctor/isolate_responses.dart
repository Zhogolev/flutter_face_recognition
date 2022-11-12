import 'dart:typed_data';

class IsolateResponse {
  final int reqId;

  IsolateResponse(this.reqId);
}

class IsolateDetectorResponse extends IsolateResponse {
  final Int16List data;

  IsolateDetectorResponse(
    super.reqId, {
    required this.data,
  });
}

class IsolateDestroyResponse extends IsolateResponse {
  IsolateDestroyResponse(super.reqId);
}
