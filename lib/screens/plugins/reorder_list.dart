import 'dart:ui';
import 'package:florae/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './tap_to_expand.dart';

class ReorderableExample extends StatefulWidget {

  final Widget? item;

  /// A parameter that is used to set the color of the widget.
  final Color? color;


  const ReorderableExample({
    super.key,
    this.item,
    this.color,
  });

  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  final List<int> _items = List<int>.generate(10, (int index) => index);
  final Set<int> _expandedItems = {};
  bool _isDraggingMode = false; // 控制是否進入拖動模式

  @override
  Widget build(BuildContext context) {
    final Color itemColor = widget.color ?? Colors.white;


    final List<Widget> cards = <Widget>[
      for (int index = 0; index < _items.length; index += 1)
        Container(
          key: Key('$index'),
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          child: GestureDetector(
            onLongPress: () {
              setState(() {
                HapticFeedback.heavyImpact();
                _isDraggingMode = true; // 長按進入拖動模式
              });
            },
            child: Stack(
              children: [
                TapToExpand(
                  useInkWell: false,
                  color: itemColor,
                  title: Text(
                    'Card ${_items[index]}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  content: Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Text(
                      '這是展開後的內容 for item ${_items[index]}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isDraggingMode
                          ? Colors.teal.withOpacity(0.6) // 拖動模式下藍色陰影
                          : Colors.black.withOpacity(0.3),
                      blurRadius: _isDraggingMode ? 6 : 2, // 陰影加深
                      offset: const Offset(0, 2),
                    )
                  ],
                  onTapPadding: 6,
                  closedPadding: 20,
                  closedHeight: 80,
                  scrollable: false,
                  borderRadius: 15,
                  openedHeight: 300,
                  isExpanded: !_expandedItems.contains(index),
                  onExpansionChanged: (expanded) {
                    if (_isDraggingMode) return; // 拖動模式下禁用展開
                    setState(() {
                      if (!expanded) {
                        _expandedItems.add(index);
                      } else {
                        _expandedItems.remove(index);
                      }
                    });
                  },
                ),

                // 拖曳手把：只在拖動模式下顯示
                if (_isDraggingMode)
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: ReorderableDragStartListener(
                      enabled: _isDraggingMode,
                      index: index,
                      child: Container(
                        width: 60,  // 控制可拖動區域寬度
                        color: Colors.transparent, // 保持透明但可點擊
                        alignment: Alignment.center,
                        child: const Icon(Icons.drag_indicator_sharp, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
    ];


    Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.05, animValue)!;

          return Transform.scale(
            scale: scale,
            child: Material(
              elevation: elevation,
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: child,
            ),
          );
        },
        child: child,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isDraggingMode) {
          setState(() {
            _isDraggingMode = false; // 返回鍵退出拖動模式
          });
          return false; // 阻止直接退出頁面
        }
        return true;
      },
      child: ReorderableListView(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        proxyDecorator: proxyDecorator,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final int item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        children: cards,
      ),
    );
  }
}