import 'k_line_model.dart';

class InfoWindowModel {
  ///K线模型数据
  KLineModel kLineModel;
  bool isLeft;

  InfoWindowModel(this.kLineModel, {this.isLeft = false});
}
