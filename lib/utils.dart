import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveImage(BuildContext context, Image img) {
  final completer = Completer<String>();

  img.image.resolve(new ImageConfiguration()).addListener(
      new ImageStreamListener(
          (ImageInfo imageInfo, bool synchronousCall) async {
    final byteData =
        await imageInfo.image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();

    final fileName = pngBytes.hashCode;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    completer.complete(filePath);
  }));

  return completer.future;
}

/*
姓名
身高
體重
年齡
居住地
語言
興趣
科技 運動 汽車 旅遊 繪畫 睡覺 品酒 
交友性別

 */
