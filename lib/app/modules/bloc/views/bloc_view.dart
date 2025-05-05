import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/bloc_controller.dart';

class BlocView extends GetView<BlocController> {
  const BlocView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'BlocView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
