import 'package:ffi_opencv/c_responses.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ffi_opencv/ffi_opencv.dart' as ffi_opencv;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<int> sumAsyncResult;

  late String hello;
  @override
  void initState() {
    super.initState();
    sumResult = ffi_opencv.sum(1, 2);
    sumAsyncResult = ffi_opencv.sumAsync(3, 4);

    hello = ffi_opencv.helloFromFd();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'sum(1, 2) = $sumResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                FutureBuilder<int>(
                  future: sumAsyncResult,
                  builder: (BuildContext context, AsyncSnapshot<int> value) {
                    final displayValue =
                        (value.hasData) ? value.data : 'loading';
                    return Text(
                      'await sumAsync(3, 4) = $displayValue',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                spacerSmall,
                Text(
                  'CVV_VERSION = ${ffi_opencv.getMajorVersion()}',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'Hello! = $hello',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
