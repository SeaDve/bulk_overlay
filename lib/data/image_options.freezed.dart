// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageOptions implements DiagnosticableTreeMixin {

 Offset get offset; String? get overlayPath; double get scale;
/// Create a copy of ImageOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageOptionsCopyWith<ImageOptions> get copyWith => _$ImageOptionsCopyWithImpl<ImageOptions>(this as ImageOptions, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ImageOptions'))
    ..add(DiagnosticsProperty('offset', offset))..add(DiagnosticsProperty('overlayPath', overlayPath))..add(DiagnosticsProperty('scale', scale));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageOptions&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.overlayPath, overlayPath) || other.overlayPath == overlayPath)&&(identical(other.scale, scale) || other.scale == scale));
}


@override
int get hashCode => Object.hash(runtimeType,offset,overlayPath,scale);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ImageOptions(offset: $offset, overlayPath: $overlayPath, scale: $scale)';
}


}

/// @nodoc
abstract mixin class $ImageOptionsCopyWith<$Res>  {
  factory $ImageOptionsCopyWith(ImageOptions value, $Res Function(ImageOptions) _then) = _$ImageOptionsCopyWithImpl;
@useResult
$Res call({
 Offset offset, String? overlayPath, double scale
});




}
/// @nodoc
class _$ImageOptionsCopyWithImpl<$Res>
    implements $ImageOptionsCopyWith<$Res> {
  _$ImageOptionsCopyWithImpl(this._self, this._then);

  final ImageOptions _self;
  final $Res Function(ImageOptions) _then;

/// Create a copy of ImageOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offset = null,Object? overlayPath = freezed,Object? scale = null,}) {
  return _then(_self.copyWith(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Offset,overlayPath: freezed == overlayPath ? _self.overlayPath : overlayPath // ignore: cast_nullable_to_non_nullable
as String?,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// @nodoc


class _ImageOptions with DiagnosticableTreeMixin implements ImageOptions {
  const _ImageOptions({this.offset = ImageOptions.defaultOffset, this.overlayPath, this.scale = ImageOptions.defaultScale});
  

@override@JsonKey() final  Offset offset;
@override final  String? overlayPath;
@override@JsonKey() final  double scale;

/// Create a copy of ImageOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageOptionsCopyWith<_ImageOptions> get copyWith => __$ImageOptionsCopyWithImpl<_ImageOptions>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ImageOptions'))
    ..add(DiagnosticsProperty('offset', offset))..add(DiagnosticsProperty('overlayPath', overlayPath))..add(DiagnosticsProperty('scale', scale));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageOptions&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.overlayPath, overlayPath) || other.overlayPath == overlayPath)&&(identical(other.scale, scale) || other.scale == scale));
}


@override
int get hashCode => Object.hash(runtimeType,offset,overlayPath,scale);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ImageOptions(offset: $offset, overlayPath: $overlayPath, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$ImageOptionsCopyWith<$Res> implements $ImageOptionsCopyWith<$Res> {
  factory _$ImageOptionsCopyWith(_ImageOptions value, $Res Function(_ImageOptions) _then) = __$ImageOptionsCopyWithImpl;
@override @useResult
$Res call({
 Offset offset, String? overlayPath, double scale
});




}
/// @nodoc
class __$ImageOptionsCopyWithImpl<$Res>
    implements _$ImageOptionsCopyWith<$Res> {
  __$ImageOptionsCopyWithImpl(this._self, this._then);

  final _ImageOptions _self;
  final $Res Function(_ImageOptions) _then;

/// Create a copy of ImageOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offset = null,Object? overlayPath = freezed,Object? scale = null,}) {
  return _then(_ImageOptions(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Offset,overlayPath: freezed == overlayPath ? _self.overlayPath : overlayPath // ignore: cast_nullable_to_non_nullable
as String?,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
