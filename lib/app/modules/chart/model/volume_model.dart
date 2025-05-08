//ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types

///交易量图模型
mixin VolumeModel {
  late double open; //开盘价
  late double close; //收盘价
  late double vol; //成交量
  double? MA5Volume; //5日均价
  double? MA10Volume; //10日均价
}
