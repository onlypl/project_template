import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/log.dart';
import '../model/depth_model.dart';
import '../model/k_line_model.dart';
import '../utils/data_util.dart';

class ChartController extends GetxController {
  List<KLineModel>? datas;
  RxBool showLoading = true.obs;
  List<DepthModel>? _bids, _asks;
  @override
  void onInit() {
    super.onInit();
    getData('1day');
  }

  getDepth() {
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      final tick = parseJson['tick'] as Map<String, dynamic>;
      final List<DepthModel> bids =
          (tick['bids'] as List<dynamic>)
              .map<DepthModel>(
                (item) => DepthModel(item[0] as double, item[1] as double),
              )
              .toList();
      final List<DepthModel> asks =
          (tick['asks'] as List<dynamic>)
              .map<DepthModel>(
                (item) => DepthModel(item[0] as double, item[1] as double),
              )
              .toList();
      initDepth(bids, asks);
    });
  }

  void initDepth(List<DepthModel>? bids, List<DepthModel>? asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    bids.sort((left, right) => left.price.compareTo(right.price));
    //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _bids!.insert(0, item);
    });

    amount = 0.0;
    asks.sort((left, right) => left.price.compareTo(right.price));
    //累加卖出委托量
    asks.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _asks!.add(item);
    });
    update();
  }

  getData(String period) {
    final Future<String> future = getChartDataFromInternet('1day');
    //final Future<String> future = getChatDataFromJson();
    future
        .then((String result) {
          solveChartData(result);
        })
        .catchError((onError) {
          showLoading.value = false;
          update();
          Log().error('### 获取数据错误 $onError');
        });
  }

  //获取火币数据，需要翻墙
  Future<String> getChartDataFromInternet(String? period) async {
    var url =
        'https://api.htx.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    late String result;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      print('Failed getting IP address');
    }
    return result;
  }

  // 如果你不能翻墙，可以使用这个方法加载数据
  Future<String> getChatDataFromJson() async {
    return rootBundle.loadString('assets/chatData.json');
  }

  ///计算K线图数据
  solveChartData(String result) {
    final Map parseJson = json.decode(result) as Map<dynamic, dynamic>;
    final list = parseJson['data'] as List<dynamic>;
    datas =
        list
            .map((item) => KLineModel.fromJson(item as Map<String, dynamic>))
            .toList()
            .reversed
            .toList()
            .cast<KLineModel>();
    DataUtil.calculate(datas!);
    showLoading.value = false;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
