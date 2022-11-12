import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class IsolateDetectorRequest {
  final int requestId;

  IsolateDetectorRequest(this.requestId);
}

class DestroyDetectorIsolateRequest extends IsolateDetectorRequest {
  DestroyDetectorIsolateRequest(super.requestId);
}

class FaceRecognitionIsolateRequest extends IsolateDetectorRequest {
  final CameraImage image;
  final int rotation;
  FaceRecognitionIsolateRequest(
    super.requestId, {
    required this.image,
    required this.rotation,
  });
}

class InitFaceDetectorIsolateRequest extends IsolateDetectorRequest {
  final SendPort port;
  //final ByteData imageData;
  final String placeToSave;
  InitFaceDetectorIsolateRequest(
    super.requestId, {
    required this.port,
    //required this.imageData,
    required this.placeToSave,
  });
}
