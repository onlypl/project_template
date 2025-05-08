import 'k_line_model.dart';

class InfoWindowModel {
  KLineModel kLineModel;
  bool isLeft;

  InfoWindowModel(this.kLineModel, {this.isLeft = false});
}
