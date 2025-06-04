// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
///蜡烛图模型
mixin CandleModel {
  ///开盘价
  late double open;

  ///最高价
  late double high;

  ///最低价
  late double low;

  ///收盘价
  late double close;

  List<double>? maValueList;

  ///  上轨线
  double? up;

  ///  中轨线
  double? mb;

  ///  下轨线
  double? dn;

  ///布林线和均线综合指标
  double? BOLLMA;
}
