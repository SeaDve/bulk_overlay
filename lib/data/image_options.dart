import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_options.freezed.dart';

@freezed
abstract class ImageOptions with _$ImageOptions {
  const factory ImageOptions({
    @Default(ImageOptions.defaultOffset) Offset offset,
    String? overlayPath,
    @Default(ImageOptions.defaultScale) double scale,
  }) = _ImageOptions;

  static const defaultOffset = Offset.zero;
  static const defaultScale = 1.0;
}
