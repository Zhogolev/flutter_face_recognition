import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

typedef HelloResult = ffi.Pointer<Utf8> Function();
typedef StringFunctionByString = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);
typedef InitFaceDetector = ffi.Pointer<ffi.Void> Function(
    ffi.Pointer<Utf8> cascadeFilePath);

typedef ProcedureCpp = ffi.Pointer<ffi.Void> Function();
typedef Procedure = ffi.Pointer<ffi.Void> Function();

typedef DetectFunctionC = ffi.Pointer<ffi.Int16> Function(
  ffi.Pointer<ffi.Uint8> bytes,
  ffi.Int16 rotation,
  ffi.Bool isYUV,
  ffi.Int16 width,
  ffi.Int16 height,
  ffi.Int32 size,
  ffi.Pointer<ffi.Int32> resCount,
);

typedef DetectFunctionDart = ffi.Pointer<ffi.Int16> Function(
  ffi.Pointer<ffi.Uint8> bytes,
  int rotation,
  bool isYUV,
  int width,
  int height,
  int size,
  ffi.Pointer<ffi.Int32> resCount,
);

class FfiOpencvBindings {
  final ffi.DynamicLibrary dl;

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  FfiOpencvBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup,
        dl = dynamicLibrary;

  late final initFaceDetector =
      dl.lookupFunction<InitFaceDetector, InitFaceDetector>('initFaceDetector');

  late final detect =
      dl.lookupFunction<DetectFunctionC, DetectFunctionDart>('detect');

  late final destroy = dl.lookupFunction<ProcedureCpp, Procedure>('deactivate');
}
