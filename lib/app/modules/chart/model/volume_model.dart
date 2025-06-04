//ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types

///交易量图模型
mixin VolumeModel {
  ///开盘价
  late double open;

  ///收盘价
  late double close;

  ///成交量
  late double vol;

  ///5日均价
  double? MA5Volume;

  ///10日均价
  double? MA10Volume;
}
