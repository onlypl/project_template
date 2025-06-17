import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_template/app/widgets/jackpot_widget.dart';

import '../controllers/mine_controller.dart';

class MineView extends GetView<MineController> {
  const MineView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // [
        //   '玩家 Tia*** 提现1680元 玩家 Jak*** 提现5800元',
        //   '玩家 Lia*** 提现3200元 玩家 Pau*** 提现9800元',
        //   '玩家 Poo*** 提现7500元 玩家 lili*** 提现4500元',
        //   '玩家 Ken*** 提现2800元 玩家 Sun*** 提现1200元',
        //   '玩家 Ping*** 提现6000元 玩家 Che*** 提现8000元',
        //   '玩家 Ger*** 提现15000元 玩家 Chen*** 提现1800元',
        //   '玩家 Yan*** 提现11000元 玩家 Li*** 提现3000元',
        //   '玩家 Fly*** 提现5000元 玩家 Hoo*** 提现18000元',
        //   '玩家 Line*** 提现10000元 玩家 Fim*** 提现7000元',
        //   '玩家 Lin*** 提现2200元 玩家 Zho*** 提现6000元',
        //   '玩家 Dak*** 提现8000元 玩家 Tim*** 提现4000元',
        //   '玩家 Jun*** 提现13000元 玩家 Sun*** 提现9000元',
        //   '玩家 Wu*** 提现5500元 玩家 Re*** 提现1500元',
        //   '玩家 Jer*** 提现7700元 玩家 Xu*** 提现12400元',
        //   '玩家 Kai*** 提现1900元 玩家 Lin*** 提现8800元'
        // ]

      appBar: AppBar(title: const Text('MineView'), centerTitle: true),
      body: JackpotWidget(),
    );
  }
}
