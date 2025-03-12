import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshFooter extends StatefulWidget {
  const RefreshFooter({super.key});

  @override
  State<RefreshFooter> createState() => _RefreshFooterState();
}

class _RefreshFooterState extends State<RefreshFooter> {
  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = const Text("上拉加载");
        } else if (mode == LoadStatus.loading) {
          body = const CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = const Text("加载失败！点击重试！");
        } else if (mode == LoadStatus.canLoading) {
          body = const Text("松手,加载更多!");
        } else {
          body = const Text("我是有底线的～");
        }
        return Container(
          height: 44.0,
          child: Center(child: body),
        );
      },
    );
  }
}
