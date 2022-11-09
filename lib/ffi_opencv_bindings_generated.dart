import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

typedef HelloResult = ffi.Pointer<Utf8> Function();

class FfiOpencvBindings {
  final ffi.DynamicLibrary dl;

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  FfiOpencvBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup,
        dl = dynamicLibrary;

  int sum(
    int a,
    int b,
  ) {
    return _sum(
      a,
      b,
    );
  }

  late final getMajorVersion =
      dl.lookupFunction<HelloResult, HelloResult>('getMajorVersion');

  late final sayHelloFromFd =
      dl.lookupFunction<HelloResult, HelloResult>('sayHelloFromFd');

  late final _sumPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.IntPtr, ffi.IntPtr)>>(
          'sum');
  late final _sum = _sumPtr.asFunction<int Function(int, int)>();

  int sumLongRunning(
    int a,
    int b,
  ) {
    return _sumLongRunning(
      a,
      b,
    );
  }

  late final _sumLongRunningPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.IntPtr, ffi.IntPtr)>>(
          'sumLongRunning');
  late final _sumLongRunning =
      _sumLongRunningPtr.asFunction<int Function(int, int)>();
}
