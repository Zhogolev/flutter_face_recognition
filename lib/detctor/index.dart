import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ffi_opencv/detctor/logger.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'logger.dart';
import 'index_isolate.dart';
import 'isolate_requests.dart';
import 'isolate_responses.dart';

/// Так как процесс распознования занимает время -
/// нужно вынести его в отдельный процесс.
class FaceDetectorProvoder {
  static Isolate? _detectorIsolate;
  static SendPort? _dectorIsolateSendPort;
  static bool _isIsolatReady = false;
  static Map<int, Completer<IsolateResponse>> _cbs = {};
  static int _reqId = 0;

  static bool get isFaceDetectorReady =>
      !_isIsolatReady || _dectorIsolateSendPort == null;

  static void disposeDetector() async {
    if (isFaceDetectorReady) {
      _isIsolatReady = false;
      return;
    }
    _isIsolatReady = false;
    final reqId = ++_reqId;
    final res = Completer<IsolateDestroyResponse>();
    _cbs[reqId] = res;
    final msg = DestroyDetectorIsolateRequest(reqId);
    _dectorIsolateSendPort?.send(msg);
    await res.future;
    _dectorIsolateSendPort = null;
    _detectorIsolate?.kill();
    _detectorIsolate = null;
    _reqId = 0;
    _cbs = {};
  }

  static Future<IsolateDetectorResponse?> detect(CameraImage image,
      [int rotation = 0]) async {
    if (isFaceDetectorReady) {
      return null;
    }

    var reqId = ++_reqId;
    var res = Completer<IsolateDetectorResponse>();
    _cbs[reqId] = res;
    var msg = FaceRecognitionIsolateRequest(
      reqId,
      image: image,
      rotation: rotation,
    );

    /// Может ли потеряться порт? Например если диспоз будет вызван паралельно с выполнением этой функции.
    /// Нужно проверять.
    _dectorIsolateSendPort!.send(msg);
    return res.future;
  }

  static Future<bool> initDetectorIsolate(String cascadePath) async {
    disposeDetector();

    ReceivePort fromDetectorThread = ReceivePort();
    fromDetectorThread.listen(_handleMessage, onDone: () {
      disposeDetector();
    });
    final data = await rootBundle.load(cascadePath);
    final cascadeName = cascadePath.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final savedCascadePath = '${dir.path}/$cascadeName';
    final file = File(savedCascadePath);
    await file
        .writeAsBytes(data.buffer.asUint8List(0, data.buffer.lengthInBytes));

    final initReq = InitFaceDetectorIsolateRequest(
      _reqId,
      port: fromDetectorThread.sendPort,
      placeToSave: savedCascadePath,
    );
    _detectorIsolate = await Isolate.spawn(IsolatedDetector.init, initReq);

    return true;
  }

  static void _setIsolatePort(SendPort port) {
    _dectorIsolateSendPort = port;
    _isIsolatReady = true;
  }

  static void _onIsolateDataResponse(IsolateResponse data) {
    final reqId = data.reqId;
    _cbs[reqId]?.complete(data);
    _cbs.remove(reqId);
  }

  static void _handleMessage(data) {
    if (data is SendPort) {
      return _setIsolatePort(data);
    }

    if (data is IsolateResponse) {
      return _onIsolateDataResponse(data);
    }
  }
}
