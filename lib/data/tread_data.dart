import 'dart:isolate';

class InitRequest {
  SendPort toMainThread;
  String cascadePath;
  InitRequest({required this.toMainThread, required this.cascadePath});
}

class Request {
  int reqId;
  String method;
  dynamic params;
  Request({required this.reqId, required this.method, this.params});
}
