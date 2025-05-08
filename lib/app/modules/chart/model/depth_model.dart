class DepthModel {
  double price; //价格
  double vol; //成交量指标

  DepthModel(this.price, this.vol);

  @override
  String toString() {
    return 'Data{price: $price, vol: $vol}';
  }
}