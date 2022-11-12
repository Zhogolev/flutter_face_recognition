import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'detctor/logger.dart';
import 'ffi_opencv_bindings.dart';

Directory? appDir;
Pointer<Uint8>? _imageBuffer;

class RectPoint {
  final Point tl;
  final Point br;

  RectPoint({required this.tl, required this.br});
}

void initFaceDetectorCpp(String path) =>
    _bindings.initFaceDetector(path.toNativeUtf8());

Uint8List prepareBuffer(CameraImage image) {
  final planes = image.planes;
  Uint8List a = planes[0].bytes;
  Uint8List? b, c;
  if (Platform.isAndroid) {
    b = planes[1].bytes;
    c = planes[2].bytes;
  }
  var aSize = a.lengthInBytes;
  var bSize = b?.lengthInBytes ?? 0;
  var cSize = c?.lengthInBytes ?? 0;
  Uint8List buffer = Uint8List(aSize + bSize + cSize);
  buffer.setAll(0, a);
  if (Platform.isAndroid) {
    buffer.setAll(aSize, c!);
    buffer.setAll(aSize + cSize, b!);
  }
  return buffer;
}

void destroyCpp() {
  _bindings.destroy();
}

Int16List detectCpp(CameraImage image, int rotation) {
  var planes = image.planes;
  Uint8List yBuffer = planes[0].bytes;
  Uint8List? uBuffer;
  Uint8List? vBuffer;

  if (Platform.isAndroid) {
    uBuffer = planes[1].bytes;
    vBuffer = planes[2].bytes;
  }

  var ySize = yBuffer.lengthInBytes;
  var uSize = uBuffer?.lengthInBytes ?? 0;
  var vSize = vBuffer?.lengthInBytes ?? 0;
  var totalSize = ySize + uSize + vSize;

  _imageBuffer ??= malloc.allocate<Uint8>(totalSize);

  // We always have at least 1 plane, on Android it si the yPlane on iOS its the rgba plane
  Uint8List _bytes = _imageBuffer!.asTypedList(totalSize);
  _bytes.setAll(0, yBuffer);

  if (Platform.isAndroid) {
    // Swap u&v buffer for opencv
    _bytes.setAll(ySize, vBuffer!);
    _bytes.setAll(ySize + vSize, uBuffer!);
  }

  Pointer<Int32> outCount = malloc.allocate<Int32>(1);
  if (_imageBuffer != null) {
    final res = _bindings.detect(_imageBuffer!, rotation, Platform.isAndroid,
        image.width, image.height, min(image.width, image.height), outCount);
    final count = outCount.value;
    malloc.free(outCount);
    Int16List list = res.asTypedList(count);

    return list;
  }

  return Int16List.fromList([]);
}

const String _libName = 'ffi_opencv';

/// The dynamic library in which the symbols for [FfiOpencvBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final FfiOpencvBindings _bindings = FfiOpencvBindings(_dylib);
