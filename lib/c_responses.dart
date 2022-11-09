import 'dart:ffi';
import 'package:ffi/ffi.dart';

class StringResponse extends Struct {
  external Pointer<Utf8> data;

  String get value => data.toDartString();
}
