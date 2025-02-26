import 'dart:ui';

import 'package:path/path.dart' as path;

import '../data/image_processor.dart' as image_processor;

class ImageRepository {
  final _map = <String, Image?>{};

  Image? _overlayImage;
  String? _overlayImagePath;

  int get length => _map.length;
  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => _map.isNotEmpty;

  String? get overlayImagePath => _overlayImagePath;
  set overlayImagePath(String? value) {
    _overlayImagePath = value;

    for (final path in _map.keys) {
      _map[path] = null;
    }

    _overlayImage = null;
  }

  Future<Image?> _getOverlayImage() async {
    final overlayImagePath = _overlayImagePath;

    if (overlayImagePath == null) {
      return null;
    }

    _overlayImage ??= await image_processor.loadImage(overlayImagePath);

    return _overlayImage;
  }

  Future<void> saveAll(
    String outputFolder,
    Function(double progress) progressCallback,
  ) async {
    for (final (index, entry) in _map.entries.indexed) {
      final imagePath = entry.key;

      final overlayImage = await _getOverlayImage();
      final processedImage =
          entry.value ?? await _processImage(imagePath, overlayImage);

      final outputPath = path.join(
        outputFolder,
        path.setExtension(path.basename(imagePath), '.png'),
      );
      await image_processor.saveImage(processedImage, outputPath);

      progressCallback((index + 1) / _map.length);
    }
  }

  Future<Image?> getImage(String path) async {
    if (_map[path] != null) {
      return _map[path];
    }

    final overlayImage = await _getOverlayImage();
    final processedImage = await _processImage(path, overlayImage);
    _map[path] = processedImage;

    return processedImage;
  }

  String? getAt(int index) {
    return _map.keys.elementAtOrNull(index);
  }

  void add(List<String> paths) {
    _map.addEntries(paths.map((path) => MapEntry(path, null)));
  }

  void remove(String path) {
    _map.remove(path);
  }

  void removeAll() {
    _map.clear();
  }
}

Future<Image> _processImage(String path, Image? overlayImage) async {
  final image = await image_processor.loadImage(path);

  if (overlayImage == null) {
    return image;
  }

  return await image_processor.blendImages(image, overlayImage);
}
