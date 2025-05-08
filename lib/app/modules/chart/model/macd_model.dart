import 'package:project_template/app/modules/chart/model/rsi_model.dart';
import 'package:project_template/app/modules/chart/model/rw_model.dart';

import 'cci_model.dart';
import 'kdj_model.dart';

mixin MACDModel on KDJModel, RSIModel, WRModel, CCIModel {
  double? dea;
  double? dif;
  double? macd;
}
