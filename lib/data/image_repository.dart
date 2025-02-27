import 'dart:ui';

import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart';

import 'output_config.dart';
import 'image_service.dart';

const _maxLoadedImages = 16;
const _batchSaveSize = 8;

class ImageRepository {
  final _store = <String, Image?>{};
  final _recentlyRequested = <String>{};

  Image? _overlayImage;
  String? _overlayImagePath;

  int get length => _store.length;
  bool get isEmpty => _store.isEmpty;
  bool get isNotEmpty => _store.isNotEmpty;

  String? get overlayImagePath => _overlayImagePath;
  set overlayImagePath(String? value) {
    _overlayImagePath = value;

    for (final path in _store.keys) {
      _store[path] = null;
    }

    _overlayImage = null;
  }

  Future<Image?> _getOverlayImage() async {
    final overlayImagePath = _overlayImagePath;

    if (overlayImagePath == null) {
      return null;
    }

    _overlayImage ??= await loadImage(overlayImagePath);

    return _overlayImage;
  }

  Future<void> saveAll(
    String outputFolder,
    OutputConfig outputConfig, {
    required Function(String imagePath) onItemDone,
  }) async {
    for (final partition in partition(_store.entries, _batchSaveSize)) {
      await Future.wait(
        partition.map((entry) async {
          final imagePath = entry.key;

          final overlayImage = await _getOverlayImage();
          final processedImage =
              entry.value ?? await _processImage(imagePath, overlayImage);

          final outputPath = path.join(
            outputFolder,
            path.setExtension(
              path.basename(imagePath),
              outputConfig.format.extension,
            ),
          );
          await saveImage(processedImage, outputPath, outputConfig);

          onItemDone(imagePath);
        }),
      );
    }
  }

  Future<Image?> getImage(String path) async {
    _updateRecentlyRequested(path);

    if (_store[path] != null) {
      return _store[path];
    }

    final overlayImage = await _getOverlayImage();
    final processedImage = await _processImage(path, overlayImage);
    _store[path] = processedImage;

    _ensureMaxLoadedImages();

    return processedImage;
  }

  String? getAt(int index) {
    return _store.keys.elementAtOrNull(index);
  }

  void add(List<String> paths) {
    _store.addEntries(paths.map((path) => MapEntry(path, null)));
  }

  void remove(String path) {
    _store.remove(path);
    _recentlyRequested.remove(path);
  }

  void removeAll() {
    _store.clear();
    _recentlyRequested.clear();
  }

  void _updateRecentlyRequested(String path) {
    _recentlyRequested.remove(path);
    _recentlyRequested.add(path);
  }

  void _ensureMaxLoadedImages() {
    while (_recentlyRequested.length > _maxLoadedImages) {
      final oldestPath = _recentlyRequested.first;
      _store[oldestPath] = null;
      _recentlyRequested.remove(oldestPath);
    }
  }
}

Future<Image> _processImage(String path, Image? overlayImage) async {
  final image = await loadImage(path);

  if (overlayImage == null) {
    return image;
  }

  return await blendImages(image, overlayImage);
}
