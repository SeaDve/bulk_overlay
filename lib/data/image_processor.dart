import 'dart:io';
import 'dart:ui';
import 'dart:async';

Future<Map<String, Image>> processImages(
  List<String> imagePaths,
  String? overlayImagePath,
) async {
  if (overlayImagePath == null) {
    final ret = <String, Image>{};
    for (final imagePath in imagePaths) {
      ret[imagePath] = await _loadImage(imagePath);
    }
    return ret;
  }

  final overlay = await _loadImage(overlayImagePath);

  final ret = <String, Image>{};
  for (final imagePath in imagePaths) {
    final image = await _loadImage(imagePath);
    ret[imagePath] = await _blendImages(image, overlay);
  }
  return ret;
}

Future<void> saveImage(Image image, String imagePath) async {
  final pngData = await image.toByteData(format: ImageByteFormat.png);

  if (pngData == null) {
    throw Exception('Failed to convert image to PNG bytes');
  }

  final bytes = pngData.buffer.asUint8List();
  await File(imagePath).writeAsBytes(bytes);
}

Future<Image> _loadImage(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<Image> _blendImages(Image baseImage, Image overlayImage) async {
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
