import 'dart:math';

class NumberUtil {
  ///格式化数字
  static String format(double n) {
    if (n >= 1000000000) {
      n /= 1000000000;
      return "${n.toStringAsFixed(2)}B";
    } else if (n >= 1000000) {
      n /= 1000000;
      return "${n.toStringAsFixed(2)}M";
    } else if (n >= 10000) {
      n /= 1000;
      return "${n.toStringAsFixed(2)}K";
    } else {
      return n.toStringAsFixed(4);
    }
  }

  ///接收 4 个 double 类型参数（如开盘价、收盘价、最高价、最低价）；
  ///返回它们中小数位数最多的值，以确保格式统一（比如 2 位或 4 位）。
  static int getMaxDecimalLength(double a, double b, double c, double d) {
    int result = max(getDecimalLength(a), getDecimalLength(b));
    result = max(result, getDecimalLength(c));
    result = max(result, getDecimalLength(d));
    return result;
  }

  ///获取小数位数
  static int getDecimalLength(double value) {
    if (value.isNaN || value.isInfinite) return 0;
    String s = value
        .toStringAsFixed(20)
        .replaceFirst(RegExp(r'0+$'), ''); // 将 double 转换成字符串
    int dotIndex = s.indexOf("."); // 查找小数点位置
    if (dotIndex < 0) return 0; // 没有小数点，说明是整数
    return s.length - dotIndex - 1; // 小数点后的位数
  }

  ///检查非空且非零
  static bool checkNotNullOrZero(double? a) {
    if (a == null || a == 0) {
      return false;
    } else if (a.abs().toStringAsFixed(4) == "0.0000") {
      return false;
    } else {
      return true;
    }
  }
}
