import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../data/image_repository.dart';
import '../data/output_config.dart';

const _defaultOutputFormat = OutputFormat.jpg;
const _defaultJpgOutputQuality = 80;

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ImageRepository imageRepository})
    : _imageRepository = imageRepository;

  final ImageRepository _imageRepository;

  String? _outputFolder;
  OutputFormat _outputFormat = _defaultOutputFormat;
  int _jpgOutputQuality = _defaultJpgOutputQuality;

  double? _saveProgress;
  String? _saveError;

  String? get outputFolder => _outputFolder;
  set outputFolder(String? value) {
    _outputFolder = value;
    _resetSaveProgress();
  }

  OutputFormat get outputFormat => _outputFormat;
  set outputFormat(OutputFormat value) {
    _outputFormat = value;
    _resetSaveProgress();
  }

  int get jpgOutputQuality => _jpgOutputQuality;
  set jpgOutputQuality(int value) {
    _jpgOutputQuality = value;
    _resetSaveProgress();
  }

  double? get saveProgress => _saveProgress;
  String? get saveError => _saveError;

  String? get overlayImagePath => _imageRepository.overlayImagePath;
  set overlayImagePath(String? value) {
    _imageRepository.overlayImagePath = value;
    _resetSaveProgress();
  }

  bool get hasImage => _imageRepository.isNotEmpty;
  int get nImages => _imageRepository.length;

  bool get canSaveImages =>
      _imageRepository.overlayImagePath != null &&
      _imageRepository.isNotEmpty &&
      _outputFolder != null &&
      _saveProgress == null;
  bool get canRemoveImages => _saveProgress == null || _saveProgress == 1.0;

  String? getImagePathAt(int index) => _imageRepository.getAt(index);

  Future<ui.Image?> getImage(String imagePath) async {
    return _imageRepository.getImage(imagePath);
  }

  void addImages(List<String> paths) {
    _imageRepository.add(paths);
    _resetSaveProgress();
  }

  void removeImage(String imagePath) {
    _imageRepository.remove(imagePath);
    _resetSaveProgress();
  }

  void removeAllImages() {
    _imageRepository.removeAll();
    _resetSaveProgress();
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
      overlayImagePath = (result.files.first.path);
    }
  }

  Future<void> selectOutputFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Output Folder',
    );

    if (result != null) {
      outputFolder = (result);
    }
  }

  Future<void> saveImages() async {
    _saveError = null;
    _saveProgress = 0.1;
    notifyListeners();

    final outputConfig = switch (_outputFormat) {
      OutputFormat.png => PngOutputConfig(),
      OutputFormat.jpg => JpgOutputConfig(quality: _jpgOutputQuality),
    };

    try {
      await _imageRepository.saveAll(_outputFolder!, outputConfig, (progress) {
        _saveProgress = progress * 0.9 + 0.1;
        notifyListeners();
      });
      assert(_saveProgress == 1.0);
    } on Exception catch (e) {
      _saveError = e.toString();
      _saveProgress = null;
      notifyListeners();
    }
  }

  void _resetSaveProgress() {
    _saveProgress = null;
    _saveError = null;
    notifyListeners();
  }
}
