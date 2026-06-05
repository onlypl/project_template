import 'dart:io';

import 'package:image/image.dart' as img;

/// 从源图生成图标资源。
/// source.png 放在 tool/ 目录，不会打进 APK。
///
/// 用法: dart run tool/prepare_icons.dart [tool/source.png]
Future<void> main(List<String> args) async {
  final sourcePath = args.isNotEmpty ? args.first : 'tool/source.png';

  final sourceBytes = File(sourcePath).readAsBytesSync();
  final decoded = img.decodePng(sourceBytes);
  if (decoded == null) {
    stderr.writeln('无法解码: $sourcePath');
    exit(1);
  }

  final flattened = _flattenOnWhite(decoded);

  // 1024 桌面图标源图（仅 build 时用，不进 APK）
  const appIconPath = 'assets/icon/app_icon.png';
  File(appIconPath).writeAsBytesSync(img.encodePng(flattened, level: 9));
  stdout.writeln('已生成 $appIconPath (${flattened.width}x${flattened.height})');

  // 256 启动页小图（打进 APK）
  const splashSize = 256;
  final splash = img.copyResize(
    flattened,
    width: splashSize,
    height: splashSize,
    interpolation: img.Interpolation.average,
  );
  const splashPath = 'assets/icon/splash_icon.png';
  File(splashPath).writeAsBytesSync(img.encodePng(splash, level: 9));
  stdout.writeln('已生成 $splashPath (${splash.width}x${splash.height})');

  const launchDir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  const launchSizes = <String, int>{
    'LaunchImage.png': 200,
    'LaunchImage@2x.png': 400,
    'LaunchImage@3x.png': 600,
  };

  for (final entry in launchSizes.entries) {
    final size = entry.value;
    final resized = img.copyResize(
      flattened,
      width: size,
      height: size,
      interpolation: img.Interpolation.average,
    );
    final output = File('$launchDir/${entry.key}');
    output.writeAsBytesSync(img.encodePng(resized, level: 9));
    stdout.writeln('已生成 ${output.path}');
  }
}

img.Image _flattenOnWhite(img.Image source) {
  final out = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 3,
  );

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final p = source.getPixel(x, y);
      final a = p.aNormalized;
      final r = (p.r * a + 255 * (1 - a)).round().clamp(0, 255);
      final g = (p.g * a + 255 * (1 - a)).round().clamp(0, 255);
      final b = (p.b * a + 255 * (1 - a)).round().clamp(0, 255);
      out.setPixelRgb(x, y, r, g, b);
    }
  }

  return out;
}
