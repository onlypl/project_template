import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'flutter_gifimage.dart';

////有问题
class RefreshHeader extends RefreshIndicator {
  const RefreshHeader({super.key})
      : super(height: 80.0, refreshStyle: RefreshStyle.Follow);
  @override
  State<RefreshHeader> createState() => _RefreshHeaderState();
}

class _RefreshHeaderState extends RefreshIndicatorState<RefreshHeader>
    with SingleTickerProviderStateMixin {
  late GifController _gifController;
  @override
  void initState() {
    // init frame is 2
    _gifController = GifController(
      vsync: this,
      value: 1,
    );
    super.initState();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {
      _gifController.repeat(
          min: 0, max: 29, period: const Duration(milliseconds: 500));
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    _gifController.value = 30;
    return _gifController.animateTo(59,
        duration: const Duration(milliseconds: 500));
  }

  @override
  void resetValue() {
    _gifController.value = 0;
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    return GifImage(
      image: const AssetImage("images/gifindicator1.gif"),
      controller: _gifController,
      height: 80.0,
      width: 537.0,
    );
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }
}
