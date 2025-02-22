import 'dart:ui';
import 'dart:async';

import 'package:image/image.dart' as img;

class ImageProcessor {
  final _processedImages = <String, Image>{};
  get processedImages => Map.unmodifiable(_processedImages);

  Image? _overlayImage;
  Future<Image?> get overlayImage async {
    final path = _overlayImagePath;

    if (path == null) {
      return null;
    }

    if (_overlayImage != null) {
      return _overlayImage;
    }

    final image = await _loadImage(path);
    _overlayImage = image;
    return image;
  }

  String? _overlayImagePath;
  set overlayImagePath(image) {
    _overlayImagePath = image;

    _processedImages.clear();
    _overlayImage = null;
  }

  Future<Image> processImage(String imagePath) async {
    if (_processedImages.containsKey(imagePath)) {
      return _processedImages[imagePath]!;
    }

    final image = await _loadImage(imagePath);

    if (image == null) {
      throw Exception('Failed to load image');
    }

    final overlay = await overlayImage;

    if (overlay == null) {
      throw Exception('Overlay image is null');
    }

    final processedImage = await _blendImages(image, overlay);
    _processedImages[imagePath] = processedImage;

    return processedImage;
  }
}

Future<Image?> _loadImage(String imagePath) async {
  final rawImage = await img.decodeImageFile(imagePath);

  if (rawImage == null) {
    throw Exception('Failed to decode image');
  }

  final codec = await instantiateImageCodec(rawImage.getBytes());
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<Image> _blendImages(Image baseImage, Image overlayImage) {
  final recorder = PictureRecorder();

  final overlayPaint = Paint()..blendMode = BlendMode.overlay;

  final canvas = Canvas(recorder);
  canvas.drawImage(baseImage, Offset.zero, Paint());
  canvas.drawImage(overlayImage, Offset.zero, overlayPaint);

  final compositeImage = recorder.endRecording().toImage(
    baseImage.width,
    baseImage.height,
  );

  return compositeImage;
}
