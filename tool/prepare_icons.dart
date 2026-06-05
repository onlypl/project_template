import 'dart:io';

import 'package:image/image.dart' as img;

/// 将带透明圆角的源图铺白底、去除 alpha，生成 app_icon 与 iOS LaunchImage。
Future<void> main(List<String> args) async {
  final sourcePath =
      args.isNotEmpty
          ? args.first
          : 'assets/icon/source.png';

  final sourceBytes = File(sourcePath).readAsBytesSync();
  final decoded = img.decodePng(sourceBytes);
  if (decoded == null) {
    stderr.writeln('无法解码: $sourcePath');
    exit(1);
  }

  final flattened = _flattenOnWhite(decoded);
  final appIconPath = 'assets/icon/app_icon.png';
  File(appIconPath).writeAsBytesSync(
    img.encodePng(flattened, level: 9),
  );
  stdout.writeln('已生成 $appIconPath (${flattened.width}x${flattened.height}, 无透明)');

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

/// 透明像素与白色背景混合，避免 iOS 启动页黑边。
img.Image _flattenOnWhite(img.Image source) {
  final out = img.Image(width: source.width, height: source.height, numChannels: 3);

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
