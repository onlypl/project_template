/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Cairo-Medium.ttf
  String get cairoMedium => 'assets/fonts/Cairo-Medium.ttf';

  /// File path: assets/fonts/Cairo-Regular.ttf
  String get cairoRegular => 'assets/fonts/Cairo-Regular.ttf';

  /// File path: assets/fonts/Cairo-SemiBold.ttf
  String get cairoSemiBold => 'assets/fonts/Cairo-SemiBold.ttf';

  /// File path: assets/fonts/Poppins-Medium.ttf
  String get poppinsMedium => 'assets/fonts/Poppins-Medium.ttf';

  /// File path: assets/fonts/Poppins-Regular.ttf
  String get poppinsRegular => 'assets/fonts/Poppins-Regular.ttf';

  /// File path: assets/fonts/Poppins-SemiBold.ttf
  String get poppinsSemiBold => 'assets/fonts/Poppins-SemiBold.ttf';

  /// List of all assets
  List<String> get values => [
    cairoMedium,
    cairoRegular,
    cairoSemiBold,
    poppinsMedium,
    poppinsRegular,
    poppinsSemiBold,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/barrage
  $AssetsImagesBarrageGen get barrage => const $AssetsImagesBarrageGen();

  /// Directory path: assets/images/common
  $AssetsImagesCommonGen get common => const $AssetsImagesCommonGen();

  /// File path: assets/images/dummy_profile.png
  AssetGenImage get dummyProfile =>
      const AssetGenImage('assets/images/dummy_profile.png');

  /// List of all assets
  List<AssetGenImage> get values => [dummyProfile];
}

class $AssetsVectorsGen {
  const $AssetsVectorsGen();

  /// File path: assets/vectors/arrow_left.svg
  String get arrowLeft => 'assets/vectors/arrow_left.svg';

  /// File path: assets/vectors/arrow_next.svg
  String get arrowNext => 'assets/vectors/arrow_next.svg';

  /// File path: assets/vectors/arrow_right.svg
  String get arrowRight => 'assets/vectors/arrow_right.svg';

  /// File path: assets/vectors/close.svg
  String get close => 'assets/vectors/close.svg';

  /// File path: assets/vectors/close_ic.svg
  String get closeIc => 'assets/vectors/close_ic.svg';

  /// File path: assets/vectors/delete_ic.svg
  String get deleteIc => 'assets/vectors/delete_ic.svg';

  /// List of all assets
  List<String> get values => [
    arrowLeft,
    arrowNext,
    arrowRight,
    close,
    closeIc,
    deleteIc,
  ];
}

class $AssetsImagesBarrageGen {
  const $AssetsImagesBarrageGen();

  /// File path: assets/images/barrage/danmu_click_close_333.png
  AssetGenImage get danmuClickClose333 =>
      const AssetGenImage('assets/images/barrage/danmu_click_close_333.png');

  /// File path: assets/images/barrage/danmu_click_close_666.png
  AssetGenImage get danmuClickClose666 =>
      const AssetGenImage('assets/images/barrage/danmu_click_close_666.png');

  /// File path: assets/images/barrage/danmu_click_close_white.png
  AssetGenImage get danmuClickCloseWhite =>
      const AssetGenImage('assets/images/barrage/danmu_click_close_white.png');

  /// File path: assets/images/barrage/danmu_click_open_333.png
  AssetGenImage get danmuClickOpen333 =>
      const AssetGenImage('assets/images/barrage/danmu_click_open_333.png');

  /// File path: assets/images/barrage/danmu_click_open_666.png
  AssetGenImage get danmuClickOpen666 =>
      const AssetGenImage('assets/images/barrage/danmu_click_open_666.png');

  /// File path: assets/images/barrage/danmu_click_open_white.png
  AssetGenImage get danmuClickOpenWhite =>
      const AssetGenImage('assets/images/barrage/danmu_click_open_white.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    danmuClickClose333,
    danmuClickClose666,
    danmuClickCloseWhite,
    danmuClickOpen333,
    danmuClickOpen666,
    danmuClickOpenWhite,
  ];
}

class $AssetsImagesCommonGen {
  const $AssetsImagesCommonGen();

  /// File path: assets/images/common/arrow_right.png
  AssetGenImage get arrowRight =>
      const AssetGenImage('assets/images/common/arrow_right.png');

  /// File path: assets/images/common/back.png
  AssetGenImage get back =>
      const AssetGenImage('assets/images/common/back.png');

  /// List of all assets
  List<AssetGenImage> get values => [arrowRight, back];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsVectorsGen vectors = $AssetsVectorsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
