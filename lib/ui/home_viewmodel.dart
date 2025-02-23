import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/image_processor.dart' as image_processor;

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _loadState();
  }

  final _prefs = SharedPreferencesAsync();

  final _imagePaths = <String, ui.Image?>{};
  Map<String, ui.Image?> get imagePaths => Map.unmodifiable(_imagePaths);

  String? _overlayImagePath;
  String? get overlayImagePath => _overlayImagePath;

  String? _outputFolder;
  String? get outputFolder => _outputFolder;

  bool get canSaveImages =>
      _overlayImagePath != null &&
      imagePaths.isNotEmpty &&
      _outputFolder != null;
  bool get canRemoveImages => _saveProgress == null;

  double? _saveProgress;
  double? get saveProgress => _saveProgress;

  String? _saveError;
  String? get saveError => _saveError;

  String? getImagePathAt(int index) => _imagePaths.keys.elementAtOrNull(index);

  Future<void> _loadState() async {
    final imagePaths = await _prefs.getStringList('imagePaths');
    if (imagePaths != null) {
      addImagePaths(imagePaths);
    }

    final overlayImagePath = await _prefs.getString('overlayImagePath');
    setOverlayImagePath(overlayImagePath, updatePrefs: false);

    var outputFolder = await _prefs.getString('outputFolder');
    setOutputFolder(outputFolder);
  }

  Future<ui.Image?> getImage(String imagePath) async {
    if (_imagePaths[imagePath] != null) {
      return _imagePaths[imagePath];
    }

    final image = await image_processor.processImages([
      imagePath,
    ], _overlayImagePath);
    assert(image.length == 1);
    _imagePaths[imagePath] = image.values.first;

    return image.values.first;
  }

  void addImagePaths(List<String> paths, {updatePrefs = true}) {
    _imagePaths.addEntries(paths.map((path) => MapEntry(path, null)));

    _saveProgress = null;
    _saveError = null;

    notifyListeners();

    if (updatePrefs) {
      _prefs.setStringList('imagePaths', _imagePaths.keys.toList());
    }
  }

  void removeImage(String imagePath) {
    _imagePaths.remove(imagePath);

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  void removeAllImages() {
    _imagePaths.clear();

    _saveProgress = null;
    _saveError = null;

    notifyListeners();
  }

  void setOverlayImagePath(String? value, {updatePrefs = true}) {
    _overlayImagePath = value;

    for (final imagePath in _imagePaths.keys) {
      _imagePaths[imagePath] = null;
    }

    _saveProgress = null;
    _saveError = null;

    notifyListeners();

    if (updatePrefs) {
      if (value == null) {
        _prefs.remove('overlayImagePath');
      } else {
        _prefs.setString('overlayImagePath', value);
      }
    }
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
      addImagePaths(result.files.map((file) => file.path!).toList());
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
    _saveProgress = 0.1;
    notifyListeners();

    final unprocessed =
        _imagePaths.entries
            .where((e) => e.value == null)
            .map((e) => e.key)
            .toList();

    final prevLen = _imagePaths.length;
    try {
      final processed = await image_processor.processImages(
        unprocessed,
        _overlayImagePath!,
      );
      _imagePaths.addAll(processed);
      assert(_imagePaths.length == prevLen);

      _saveProgress = 0.5;
      notifyListeners();

      for (final (index, entry) in _imagePaths.entries.indexed) {
        final imagePath = entry.key;
        final image = entry.value!;

        final outputPath = path.join(
          outputFolder!,
          path.setExtension(path.basename(imagePath), '.png'),
        );
        await image_processor.saveImage(image, outputPath);

        _saveProgress = 0.5 + (index + 1) / _imagePaths.length / 2;
        notifyListeners();
      }

      _saveProgress = 1.0;
      notifyListeners();
    } on Exception catch (e) {
      _saveError = e.toString();
      _saveProgress = null;
      notifyListeners();
    }
  }
}
