import 'dart:ui';
import 'package:florae/objectbox.g.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final Color itemColor = widget.color ?? Colors.white;


    final List<TapToExpand> cards = <TapToExpand>[
      for (int index = 0; index < _items.length; index += 1)
        TapToExpand(
          key: Key('$index'),
          color: itemColor,
          title: Text(
            'Card ${_items[index]}', 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Container(
            height: 80,
            alignment: Alignment.center,
            child: Text(
              '這是展開後的內容 for item ${_items[index]}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 2),)],
          onTapPadding: 6,
          closedPadding: 20,
          closedHeight: 60,
          scrollable: false,
          borderRadius: 15,
          openedHeight: 300,
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
              child: TapToExpand(
                color: cards[index].color,
                title: cards[index].title,
                content: cards[index].content,
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 2),)],
                onTapPadding: 6,
                closedPadding: 20,
                closedHeight: 60,
                scrollable: false,
                borderRadius: 15,
              ),
            ),
          );
        },
        child: child,
      );
    }

    return ReorderableListView(
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
    );
  }
}