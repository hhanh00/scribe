import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'whisper_generated.dart' hide bool;

final whisper_lib = init();

NativeLibrary init() {
  var lib = NativeLibrary(Whisper.open());
  return lib;
}

class Whisper {
  static DynamicLibrary open() {
    if (Platform.isAndroid) return DynamicLibrary.open('libscribe_whisper.so');
    if (Platform.isMacOS) return DynamicLibrary.open('libscribe_whisper.dylib');
    if (Platform.isLinux) return DynamicLibrary.open('libscribe_whisper.so');
    throw UnsupportedError('This platform is not supported.');
  }

  static Future<String> transcribe(String audioFilePath) async {
    return compute((_) {
      return utf8.decode(unwrapResultBytes(whisper_lib.transcribe_file(toNative(audioFilePath))));
    }, null);
  }
}

List<int> unwrapResultBytes(CResultBytes r) {
  if (r.error != nullptr) throw convertCString(r.error);
  return convertBytes(r.value, r.len);
}

void unwrapResult(CResult r) {
  if (r.error != nullptr) throw convertCString(r.error);
}

String convertCString(Pointer<Char> s) {
  final str = s.cast<Utf8>().toDartString();
  // warp_api_lib.deallocate_str(s);
  return str;
}

List<int> convertBytes(Pointer<Uint8> s, int len) {
  final bytes = [...s.asTypedList(len)];
  // warp_api_lib.deallocate_bytes(s, len);
  return bytes;
}

Pointer<Char> toNative(String s) {
  return s.toNativeUtf8().cast<Char>();
}

Pointer<Uint8> toBytePtr(ByteBuffer buffer) {
  final Pointer<Uint8> result = malloc<Uint8>(buffer.lengthInBytes);
  final Uint8List nativeBytes = result.asTypedList(buffer.lengthInBytes);
  nativeBytes.setAll(0, buffer.asUint8List());
  return result.cast();
}
