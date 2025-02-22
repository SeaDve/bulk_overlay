import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../data/image_processor.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.imageProcessor});

  final ImageProcessor imageProcessor;

  final _imageFiles = <PlatformFile>[];
  get imageFiles => List.unmodifiable(_imageFiles);

  PlatformFile? _overlayImageFile;
  get overlayImageFile => _overlayImageFile;

  String? _outputFolder;
  get outputFolder => _outputFolder;

  bool get canProcess {
    return _imageFiles.isNotEmpty &&
        _overlayImageFile != null &&
        _outputFolder != null;
  }

  Future<void> selectImages() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      _imageFiles.addAll(result.files);

      notifyListeners();
    }
  }

  Future<void> selectOverlayImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      assert(result.isSinglePick);

      final imageFile = result.files.first;
      _overlayImageFile = imageFile;
      imageProcessor.overlayImagePath = imageFile.path;

      notifyListeners();
    }
  }

  Future<void> selectOutputFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      _outputFolder = result;

      notifyListeners();
    }
  }

  Future<void> startProcessing() async {
    for (final imageFile in _imageFiles) {
      final imagePath = imageFile.path;

      if (imagePath == null) {
        throw Exception('Image file path is null');
      }

      final image = await imageProcessor.processImage(imagePath);
      final byteData = await image.toByteData();

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final bytes = byteData.buffer.asUint8List();
      await File(path.join(outputFolder, imageFile.name)).writeAsBytes(bytes);
    }
  }
}
