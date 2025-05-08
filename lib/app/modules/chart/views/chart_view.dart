import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_template/app/widgets/base_appbar.dart';

import '../controllers/chart_controller.dart';

class ChartView extends GetView<ChartController> {
  const ChartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: '走势图'),
      body: Column(children: []),
    );
  }
}
