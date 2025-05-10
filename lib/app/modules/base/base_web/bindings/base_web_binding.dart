import 'package:get/get.dart';

import '../controllers/base_web_controller.dart';

class BaseWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseWebController>(
      () => BaseWebController(),
    );
  }
}
