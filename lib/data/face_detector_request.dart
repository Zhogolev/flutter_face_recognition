import 'dart:isolate';

class InitFaceDetectorRequest {
  SendPort toMainThread;
  String cascadeFilePath;
  InitFaceDetectorRequest(
      {required this.toMainThread, required this.cascadeFilePath});
}
