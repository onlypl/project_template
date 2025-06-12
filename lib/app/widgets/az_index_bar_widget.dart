import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class AzIndexBarWidget extends StatefulWidget {
  final List<String> symbols;
  final ValueChanged<int>? onSelectionUpdate;

  const AzIndexBarWidget({
    required this.symbols,
    super.key,
    this.onSelectionUpdate,
  });

  @override
  State createState() => _AzIndexBarWidgetState();
}

class _AzIndexBarWidgetState extends State<AzIndexBarWidget> {
  double observeOffset = 0;
  ListObserverController observerController = ListObserverController();
  ValueNotifier<int> selectedIndex = ValueNotifier(-1);
  @override
  void dispose() {
    selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onGestureHandler,
      onVerticalDragDown: _onGestureHandler,
      onVerticalDragCancel: _onGestureEnd,
      onVerticalDragEnd: _onGestureEnd,
      child: ListViewObserver(
        controller: observerController,
        child: _buildListView(),
        dynamicLeadingOffset: () => observeOffset,
      ),
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (BuildContext context, int value, Widget? child) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.symbols.length,
          itemBuilder: (context, index) {
            final isSelected = value == index;
            return SizedBox(
              width: 10.w,
              height: 17.w,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xffffc600) : null,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.symbols[index],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xff6c727d),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onGestureHandler(details) async {
    if (details is! DragUpdateDetails && details is! DragDownDetails) {
      return;
    }
    observeOffset = details.localPosition.dy;

    final result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
    );
    final observeResult = result.observeResult;
    // Nothing has changed.
    if (observeResult == null) {
      return;
    }

    final firstChildModel = observeResult.firstChild;
    if (firstChildModel == null) {
      return;
    }
    final firstChildIndex = firstChildModel.index;
    selectedIndex.value = firstChildIndex;

    widget.onSelectionUpdate?.call(firstChildIndex);
  }

  void _onGestureEnd([_]) {
    selectedIndex.value = -1;
  }
}
