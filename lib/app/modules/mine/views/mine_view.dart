import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_template/app/widgets/jackpot_widget.dart';

import '../controllers/mine_controller.dart';

class MineView extends GetView<MineController> {
  const MineView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MineView'), centerTitle: true),
      body: JackpotWidget(),
    );
  }
}
