import 'k_model.dart';

class KLineModel extends KModel {
  late double open; //开盘价
  late double high; //最高价
  late double low; //最低价
  late double close; //收盘价
  late double vol; //成交量
  late double? amount; //成交额
  late double? change; //涨跌幅
  late double? ratio; //涨跌幅
  late int? time; //时间

  KLineModel.fromCustom({
    this.amount,
    required this.open,
    required this.close,
    this.change,
    this.ratio,
    required this.time,
    required this.high,
    required this.low,
    required this.vol,
  });

  KLineModel.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toDouble() ?? 0;
    high = json['high']?.toDouble() ?? 0;
    low = json['low']?.toDouble() ?? 0;
    close = json['close']?.toDouble() ?? 0;
    vol = json['vol']?.toDouble() ?? 0;
    amount = json['amount']?.toDouble();
    int? tempTime = json['time']?.toInt();
    //兼容火币数据
    if (tempTime == null) {
      tempTime = json['id']?.toInt() ?? 0;
      tempTime = tempTime! * 1000;
    }
    time = tempTime;
    ratio = json['ratio']?.toDouble();
    change = json['change']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['ratio'] = this.ratio;
    data['change'] = this.change;
    return data;
  }

  @override
  String toString() {
    return '市场模型{open: $open, high: $high, low: $low, close: $close, vol: $vol, time: $time, amount: $amount, ratio: $ratio, change: $change}';
  }
}
