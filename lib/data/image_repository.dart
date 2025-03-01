import 'dart:ui';

import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart';

import 'image_options.dart';
import 'output_config.dart';
import 'image_service.dart';

const _maxLoadedImages = 16;
const _batchSaveSize = 8;

class ImageRepository {
  final _store = <String, Image?>{};
  final _recentlyRequested = <String>{};

  Image? _overlayImage;
  ImageOptions _imageOptions = ImageOptions();

  int get length => _store.length;
  bool get isEmpty => _store.isEmpty;
  bool get isNotEmpty => _store.isNotEmpty;

  ImageOptions get imageOptions => _imageOptions;
  set imageOptions(ImageOptions value) {
    final prevValue = _imageOptions;

    if (prevValue == value) {
      return;
    }

    _imageOptions = value;

    for (final path in _store.keys) {
      _store[path] = null;
    }

    if (prevValue.overlayPath != value.overlayPath) {
      _overlayImage = null;
    }
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

          final processedImage = entry.value ?? await _processImage(imagePath);

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

    final processedImage = await _processImage(path);
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

  Future<Image?> _getOverlayImage() async {
    final overlayImagePath = _imageOptions.overlayPath;

    if (overlayImagePath == null) {
      return null;
    }

    _overlayImage ??= await loadImage(overlayImagePath);

    return _overlayImage;
  }

  Future<Image> _processImage(String path) async {
    final image = await loadImage(path);
    return await blendImages(
      image,
      _imageOptions.offset,
      _imageOptions.scale,
      await _getOverlayImage(),
    );
  }
}
