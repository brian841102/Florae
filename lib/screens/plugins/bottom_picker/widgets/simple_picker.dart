import 'package:flutter/cupertino.dart';
import '../resources/custom_cupertino_picker.dart';

class SimplePicker extends StatelessWidget {
  final int selectedItemIndex;
  final Function(int)? onChange;
  final List<Text> items;
  final TextStyle textStyle;
  final double itemExtent;
  final Widget? selectionOverlay;

  const SimplePicker({
    Key? key,
    required this.items,
    required this.onChange,
    required this.selectedItemIndex,
    required this.textStyle,
    required this.itemExtent,
    this.selectionOverlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: textStyle,
        ),
      ),
      child: CustomCupertinoPicker(
        itemExtent: itemExtent,
        selectionOverlay: selectionOverlay ?? const CupertinoPickerCustomSelectionOverlay(),
        scrollController: FixedExtentScrollController(
          initialItem: selectedItemIndex,
        ),
        onSelectedItemChanged: onChange,
        children: items,
      ),
    );
  }
}
