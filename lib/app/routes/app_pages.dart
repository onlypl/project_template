import 'package:get/get.dart';

import '../modules/base/base_web/bindings/base_web_binding.dart';
import '../modules/base/base_web/views/base_web_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.BASE_WEB;

  static final routes = [
    GetPage(
      name: _Paths.BASE_WEB,
      page: () => const BaseWebView(),
      binding: BaseWebBinding(),
    ),
  ];
}
