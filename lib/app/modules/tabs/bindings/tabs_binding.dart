import 'package:get/get.dart';

import '../../bloc/controllers/bloc_controller.dart';
import '../../chart/controllers/chart_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../mine/controllers/mine_controller.dart';
import '../../other/controllers/other_controller.dart';
import '../controllers/tabs_controller.dart';

class TabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabsController>(() => TabsController());

    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BlocController>(() => BlocController());
    Get.lazyPut<ChartController>(() => ChartController());
    Get.lazyPut<OtherController>(() => OtherController());
    Get.lazyPut<MineController>(() => MineController());
  }
}
