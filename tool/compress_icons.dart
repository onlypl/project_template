import 'dart:io';

import 'package:image/image.dart' as img;

Future<void> main() async {
  final roots = [
    'android/app/src/main/res',
    'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    'assets/icon',
  ];

  var totalBefore = 0;
  var totalAfter = 0;

  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.png')) continue;
      if (!entity.path.contains('ic_launcher') &&
          !entity.path.contains('AppIcon.appiconset') &&
          !entity.path.contains('assets/icon')) {
        continue;
      }

      final before = entity.lengthSync();
      final bytes = entity.readAsBytesSync();
      final image = img.decodePng(bytes);
      if (image == null) continue;

      // 大图不量化，避免圆角处产生暗色描边
      final encoded = img.encodePng(image, level: 9);
      entity.writeAsBytesSync(encoded);
      final after = entity.lengthSync();
      totalBefore += before;
      totalAfter += after;
      stdout.writeln(
        '${entity.path}: ${_formatKb(before)} -> ${_formatKb(after)}',
      );
    }
  }

  stdout.writeln(
    'Total: ${_formatKb(totalBefore)} -> ${_formatKb(totalAfter)} '
    '(saved ${_formatKb(totalBefore - totalAfter)})',
  );
}

String _formatKb(int bytes) => '${(bytes / 1024).toStringAsFixed(1)}KB';
