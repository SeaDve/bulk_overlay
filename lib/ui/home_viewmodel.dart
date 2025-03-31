import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../data/image_options.dart';
import '../data/image_repository.dart';
import '../data/output_config.dart';
import '../data/save_status.dart';

const _defaultOutputFormat = OutputFormat.jpg;
const _defaultJpgOutputQuality = 80;

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ImageRepository imageRepository})
    : _imageRepository = imageRepository;

  final ImageRepository _imageRepository;

  final _savedImagePaths = <String>{};

  String? _outputFolder;
  OutputFormat _outputFormat = _defaultOutputFormat;
  int _jpgOutputQuality = _defaultJpgOutputQuality;

  SaveStatus _saveStatus = SaveStatusIdle();

  String? get outputFolder => _outputFolder;
  set outputFolder(String? value) {
    _outputFolder = value;
    _resetSaveStatus();
  }

  OutputFormat get outputFormat => _outputFormat;
  set outputFormat(OutputFormat value) {
    _outputFormat = value;
    _resetSaveStatus();
  }

  int get jpgOutputQuality => _jpgOutputQuality;
  set jpgOutputQuality(int value) {
    _jpgOutputQuality = value;
    _resetSaveStatus();
  }

  SaveStatus get saveStatus => _saveStatus;

  ImageOptions get imageOptions => _imageRepository.imageOptions;
  set imageOptions(ImageOptions value) {
    _imageRepository.imageOptions = value;
    _resetSaveStatus();
  }

  bool get hasImage => _imageRepository.isNotEmpty;
  int get nImages => _imageRepository.length;

  bool get canSaveImages =>
      _imageRepository.imageOptions.overlayPath != null &&
      _imageRepository.isNotEmpty &&
      _outputFolder != null &&
      _saveStatus is SaveStatusIdle;
  bool get canModifyConfiguration => _saveStatus is! SaveStatusInProgress;

  String? getImagePathAt(int index) => _imageRepository.getAt(index);

  Future<ui.Image?> getImage(String imagePath) async {
    return _imageRepository.getImage(imagePath);
  }

  bool isImageSaved(String imagePath) {
    return _savedImagePaths.contains(imagePath);
  }

  void addImages(List<String> paths) {
    _imageRepository.add(paths);
    _resetSaveStatus();
  }

  void removeImage(String imagePath) {
    _imageRepository.remove(imagePath);
    _resetSaveStatus();
  }

  void removeAllImages() {
    _imageRepository.removeAll();
    _resetSaveStatus();
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
      imageOptions = imageOptions.copyWith(
        overlayPath: result.files.first.path,
      );
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
    _saveStatus = SaveStatusInProgress(0.1);
    notifyListeners();

    final outputConfig = switch (_outputFormat) {
      OutputFormat.png => PngOutputConfig(),
      OutputFormat.jpg => JpgOutputConfig(quality: _jpgOutputQuality),
    };

    try {
      await _imageRepository.saveAll(
        _outputFolder!,
        outputConfig,
        onItemDone: (imagePath) {
          _savedImagePaths.add(imagePath);
          _saveStatus = SaveStatusInProgress(
            0.1 + 0.9 * _savedImagePaths.length / _imageRepository.length,
          );
          notifyListeners();
        },
      );
      _saveStatus = SaveStatusSuccess();
      notifyListeners();
    } on Exception catch (e) {
      _saveStatus = SaveStatusFailure(e.toString());
      notifyListeners();
    }
  }

  void _resetSaveStatus() {
    _saveStatus = SaveStatusIdle();
    _savedImagePaths.clear();
    notifyListeners();
  }
}
