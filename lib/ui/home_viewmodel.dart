import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../data/image_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ImageRepository imageRepository})
    : _imageRepository = imageRepository;

  final ImageRepository _imageRepository;

  String? _outputFolder;

  double? _saveProgress;
  String? _saveError;

  String? get outputFolder => _outputFolder;

  double? get saveProgress => _saveProgress;
  String? get saveError => _saveError;

  String? get overlayImagePath => _imageRepository.overlayImagePath;

  bool get hasImage => _imageRepository.isNotEmpty;
  int get nImages => _imageRepository.length;

  bool get canSaveImages =>
      _imageRepository.overlayImagePath != null &&
      _imageRepository.isNotEmpty &&
      _outputFolder != null;
  bool get canRemoveImages => _saveProgress == null;

  String? getImagePathAt(int index) => _imageRepository.getAt(index);

  Future<ui.Image?> getImage(String imagePath) async {
    return _imageRepository.getImage(imagePath);
  }

  void addImages(List<String> paths) {
    _imageRepository.add(paths);

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  void removeImage(String imagePath) {
    _imageRepository.remove(imagePath);

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  void removeAllImages() {
    _imageRepository.removeAll();

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  void setOverlayImagePath(String? value) {
    _imageRepository.overlayImagePath = value;

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  void setOutputFolder(String? value) {
    _outputFolder = value;

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  Future<void> selectImages() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Image(s)',
      allowMultiple: true,
    );

    if (result != null) {
      addImages(result.files.map((file) => file.path!).toList());
    }
  }

  Future<void> selectOverlayImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Overlay Image',
      allowMultiple: false,
    );

    if (result != null) {
      assert(result.isSinglePick);
      setOverlayImagePath(result.files.first.path);
    }
  }

  Future<void> selectOutputFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Output Folder',
    );

    if (result != null) {
      setOutputFolder(result);
    }
  }

  Future<void> saveImages() async {
    _saveError = null;
    _saveProgress = 0.0;
    notifyListeners();

    try {
      await _imageRepository.saveAll(_outputFolder!, (progress) {
        _saveProgress = progress;
        notifyListeners();
      });
    } on Exception catch (e) {
      _saveError = e.toString();
      _saveProgress = null;
      notifyListeners();
    }
  }
}
