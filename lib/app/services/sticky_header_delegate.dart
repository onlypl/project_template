import 'package:flutter/material.dart';

///头部吸附悬浮委托
///Widget _stickyHeader() {
//     return SliverPersistentHeader(
//       pinned: true,
//       floating: true,
//       delegate: StickyHeaderDelegate(
//         minHeight: 26.h + 9.h,
//         maxHeight: 26.h + 9.h,
//         child: _buildTitle(),
//       ),
//     );
//   }
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  StickyHeaderDelegate(
      {required this.maxHeight, required this.minHeight, required this.child});
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return (maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child);
  }
}
