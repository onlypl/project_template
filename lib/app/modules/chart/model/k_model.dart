import 'package:project_template/app/modules/chart/model/rsi_model.dart';
import 'package:project_template/app/modules/chart/model/rw_model.dart';
import 'package:project_template/app/modules/chart/model/volume_model.dart';

import 'candle_model.dart';
import 'cci_model.dart';
import 'kdj_model.dart';
import 'macd_model.dart';

class KModel
    with
        CandleModel,
        VolumeModel,
        KDJModel,
        RSIModel,
        WRModel,
        CCIModel,
        MACDModel {}
