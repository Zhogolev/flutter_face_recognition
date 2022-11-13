import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:ffi_opencv/detctor/index.dart';
import 'package:flutter/material.dart';

import 'detections_layer.dart';

class FullInitData {
  final bool isCameraInitiated;
  final bool isDetectorInittiated;

  FullInitData({
    this.isCameraInitiated = false,
    this.isDetectorInittiated = false,
  });
}

class DetectionPage2 extends StatefulWidget {
  const DetectionPage2({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage2>
    with WidgetsBindingObserver {
  CameraController? _camController;
  int _camFrameRotation = 0;
  double _camFrameToScreenScale = 0;
  int _lastRun = 0;
  bool _detectionInProgress = false;
  List<double> _faces = List.empty();
  late Future<FullInitData> initWidgetFuture;

  @override
  void initState() {
    super.initState();
    initWidget();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  void initWidget() async {
    await FaceDetectorProvoder.initDetectorIsolate(
        'assets/data/haarcascade_frontalface_alt.xml');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _camController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FaceDetectorProvoder.disposeDetector();
    _camController?.dispose();
    super.dispose();
  }

  Future<bool> initCamera() async {
    final cameras = await availableCameras();
    var idx =
        cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    if (idx < 0) {
      return false;
    }

    var desc = cameras[idx];
    _camFrameRotation = Platform.isAndroid ? desc.sensorOrientation : 0;
    _camController = CameraController(
      desc,
      ResolutionPreset.high, // 720p
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _camController!.initialize();
    } catch (e) {
      log("Error initializing camera, error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
        ),
      );
    }
    return Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: CameraPreview(_camController!)),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 56,
              child: TextButton(
                child: const Text('Process'),
                onPressed: () async {
                  try {
                    XFile file = await _camController!.takePicture();
                    final path = file.path;
                    final filename = path.split('/').last;
                    final folder = path.replaceAll(filename, "");
                    final ext = filename.split(".").last;
                    final date = DateTime.now().millisecondsSinceEpoch;
                    final savedFile = '$folder$date.$ext';
                    await FaceDetectorProvoder.detectAndSave(path, savedFile);

                    await File(file.path).delete();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => DetectedFile(path: savedFile)));
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ))
      ],
    );
  }
}

class DetectedFile extends StatelessWidget {
  final String path;
  const DetectedFile({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Image.file(File(path)));
  }
}
