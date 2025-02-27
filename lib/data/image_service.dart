import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jpeg_encode/jpeg_encode.dart';

import 'output_config.dart';

Future<Image> loadImage(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<void> saveImage(
  Image image,
  String imagePath,
  OutputConfig outputConfig,
) async {
  Uint8List bytes;
  switch (outputConfig) {
    case PngOutputConfig _:
      final data = await image.toByteData(format: ImageByteFormat.png);

      if (data == null) {
        throw Exception('Failed to convert image to PNG bytes');
      }

      bytes = data.buffer.asUint8List();
    case JpgOutputConfig _:
      final data = await image.toByteData(format: ImageByteFormat.rawRgba);

      if (data == null) {
        throw Exception('Failed to convert image to raw RGBA bytes');
      }

      bytes = await _encodeJpeg(
        data.buffer.asUint8List(),
        image.width,
        image.height,
        outputConfig.quality,
      );
  }

  await File(imagePath).writeAsBytes(bytes);
}

Future<Image> blendImages(Image baseImage, Image overlayImage) async {
  final recorder = PictureRecorder();

  final canvas = Canvas(recorder);
  canvas.drawImage(baseImage, Offset.zero, Paint());

  final footerRatio = overlayImage.width / overlayImage.height;
  final newFooterWidth = baseImage.width.toDouble();
  final newFooterHeight = newFooterWidth / footerRatio;

  final footerPosition = Offset(
    0,
    baseImage.height.toDouble() - newFooterHeight,
  );
  final overlayPaint = Paint()..blendMode = BlendMode.srcOver;
  canvas.drawImageRect(
    overlayImage,
    Rect.fromLTWH(
      0,
      0,
      overlayImage.width.toDouble(),
      overlayImage.height.toDouble(),
    ),
    Rect.fromLTWH(
      footerPosition.dx,
      footerPosition.dy,
      newFooterWidth,
      newFooterHeight,
    ),
    overlayPaint,
  );

  final compositeImage = await recorder.endRecording().toImage(
    baseImage.width,
    baseImage.height,
  );

  return compositeImage;
}

Future<Uint8List> _encodeJpeg(
  Uint8List pixels,
  int width,
  int height,
  int quality,
) async {
  return await Isolate.run(() {
    return JpegEncoder().compress(pixels, width, height, quality);
  });
}
