import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'isolate_responses.dart';

import '../ffi_opencv.dart';
import 'isolate_requests.dart';
import 'logger.dart';

class IsolatedDetector {
  static FaceDetector? detector;
  static SendPort? _sendToMainThreadPort;

  static void init(InitFaceDetectorIsolateRequest req) async {
    detector = await FaceDetector.init(req.placeToSave);

    _sendToMainThreadPort = req.port;

    ReceivePort fromMainThread = ReceivePort();
    fromMainThread.listen(_handleMainThreadRequests);

    _sendToMainThreadPort!.send(fromMainThread.sendPort);
  }

  static void _handleMainThreadRequests(request) {
    if (detector == null) {
      logW('_FaceDetector: dector == null!!!');
      return;
    }
    if (_sendToMainThreadPort == null) {
      logW('_FaceDetector: _sendToMainThreadPort == null!!!');
      return;
    }

    if (request is IsolateDetectorRequest) {
      if (request is FaceRecognitionIsolateRequest) {
        final res = detector!.detect(request.image, request.rotation);
        // faces: ${res.length}');
        _sendToMainThreadPort
            ?.send(IsolateDetectorResponse(request.requestId, data: res));
        return;
      }

      if (request is DestroyDetectorIsolateRequest) {
        detector!.destroy();
        _sendToMainThreadPort?.send(IsolateDestroyResponse(request.requestId));
        return;
      }
    }
  }
}

class FaceDetector {
  FaceDetector._constructor();

  static Future<FaceDetector> init(String cascadePath) async {
    initFaceDetectorCpp(cascadePath);
    final fd = FaceDetector._constructor();
    return Future.value(fd);
  }

  Int16List detect(CameraImage image, int rotation) {
    var res = detectCpp(image, rotation);
    return res;
  }

  void destroy() {
    destroyCpp();
  }
}
