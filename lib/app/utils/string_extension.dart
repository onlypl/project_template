extension TruncateToTwoDecimals on String {
  /// 将字符串数字保留两位小数，不四舍五入
  String toTruncated2Decimals() {
    final doubleValue = double.tryParse(this);
    if (doubleValue == null) return this;

    final parts = doubleValue.toString().split('.');
    if (parts.length == 1) return '${parts[0]}.00';

    final decimal = parts[1].padRight(2, '0');
    return '${parts[0]}.${decimal.substring(0, 2)}';
  }

  String maskMiddle() {
    if (length <= 7) return this; // 不足8位不处理
    return '${substring(0, 4)}****${substring(length - 3)}';
  }

  //不区分大小写字符串比较
  bool caseInsensitiveEquals(String str) {
    return toLowerCase() == str.toLowerCase();
  }
}
