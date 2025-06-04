class DepthModel {
  ///价格
  double price;
  ///成交量指标
  double vol;
  DepthModel(this.price, this.vol);

  @override
  String toString() {
    return 'Data{price: $price, vol: $vol}';
  }
}