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

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage>
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
      await _camController!
          .startImageStream((image) => _processCameraImage(image));
    } catch (e) {
      log("Error initializing camera, error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
    return true;
  }

  void _processCameraImage(CameraImage image) async {
    if (_detectionInProgress ||
        !mounted ||
        DateTime.now().millisecondsSinceEpoch - _lastRun < 100) {
      return;
    }
    if (_camFrameToScreenScale == 0) {
      var w = (_camFrameRotation == 0 || _camFrameRotation == 180)
          ? image.width
          : image.height;
      _camFrameToScreenScale = MediaQuery.of(context).size.width / w;
    }

    _detectionInProgress = true;
    final data = await FaceDetectorProvoder.detect(image, _camFrameRotation);

    final res = data?.data;
    _detectionInProgress = false;
    _lastRun = DateTime.now().millisecondsSinceEpoch;

    if (!mounted || res == null) {
      return;
    }

    if ((res.length / 4) != (res.length ~/ 4)) {
      log('Got invalid response from FaceDetector, number of coords is ${res.length} and does not represent complete arucos with 4 corners');
      return;
    }

    final faces =
        res.map((x) => x * _camFrameToScreenScale).toList(growable: false);

    setState(() {
      _faces = faces;
    });
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
    print('--------');
    print(MediaQuery.of(context).size.width);
    print(MediaQuery.of(context).size.height);
    print('--------');
    return DetectionsLayer(
      arucos: _faces,
      child: CameraPreview(_camController!),
    );
  }
}
