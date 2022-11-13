import 'package:flutter/material.dart';

class DetectionsLayer extends StatelessWidget {
  const DetectionsLayer({
    Key? key,
    this.child,
    required this.arucos,
  }) : super(key: key);

  final Widget? child;
  final List<double> arucos;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      foregroundPainter: ArucosPainter(faces: arucos),
      child: child,
    );
  }
}

class ArucosPainter extends CustomPainter {
  ArucosPainter({required this.faces});

  // list of aruco coordinates, each aruco has 4 corners with x/y, total of 8 numbers per aruco
  final List<double> faces;

  // paint we will use to draw to arucos
  final _paint = Paint()
    ..strokeWidth = 2.0
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) {
      return;
    }
    print(size);
    print(faces);
    // 1280 x 720
    // 756 x 360
    final count = faces.length ~/ 4;
    for (int i = 0; i < count; ++i) {
      final tly = faces[i] * 756 / 1280;
      final tlx = faces[i + 1] * 360 / 720;
      final bry = faces[i + 2] * 756 / 1280;
      final brx = faces[i + 3] * 360 / 720;
      final from = Offset(tlx, tly);
      final size = Size(brx - tlx, bry - tly);
      //canvas.drawRect(Rect.fromLTRB(tlx, tly, brx, bry), _paint);
      canvas.drawRect(from & size, _paint);
    }
  }

  @override
  bool shouldRepaint(ArucosPainter oldDelegate) {
    return true;
    // We check if the arucos array was changed, if so we should re-paint
    if (faces.length != oldDelegate.faces.length) {
      return true;
    }

    for (int i = 0; i < faces.length; ++i) {
      if (faces[i] != oldDelegate.faces[i]) {
        return true;
      }
    }

    return false;
  }
}
