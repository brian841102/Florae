import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class CounterView extends StatefulWidget {
  final int? initNumber;
  final Function(int)? onSelectedItemChanged;   
  final int? minNumber;
  final List<Widget> children;

  const CounterView({
    super.key,
    this.initNumber,
    this.onSelectedItemChanged,
    this.minNumber,
    required this.children,
  });

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late int _counter;
  late Function(int) _onSelectedItemChanged;
  late int _minNumber;
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    _counter = widget.initNumber ?? 0;
    _onSelectedItemChanged = widget.onSelectedItemChanged ?? (int number) {};
    _minNumber = widget.minNumber ?? 0;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 180,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.secondaryContainer, //Colors.grey[300],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _createIncrementDecrementButton(Icons.remove, _decrement, _decrement),
            widget.children[_counter],
            _createIncrementDecrementButton(Icons.add, _increment, _increment),
          ],
        ),
      ),
    );
  }

  void _increment() {
    setState(() {
      if (_counter < widget.children.length - 1) {
        Vibration.vibrate(duration: 50);
        _counter++;
        _onSelectedItemChanged(_counter);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_counter > _minNumber) {
        Vibration.vibrate(duration: 50);
        _counter--;
        _onSelectedItemChanged(_counter);
      }
    });
  }

  void _startLongPress(Function callback) {
    // Start a timer to repeatedly call the callback for faster increment/decrement
    _longPressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      callback();
    });
  }

  void _stopLongPress() {
    // Cancel the timer when the long-press is released
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();
    }
  }

  Widget _createIncrementDecrementButton(IconData icon, Function onPressed, Function onLongPressed) {
    return GestureDetector(
      onLongPress: () {
        _startLongPress(onLongPressed);
      },
      onLongPressUp: () {
        _stopLongPress();
      },
      child: RawMaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        constraints: const BoxConstraints(minWidth: 38.0, minHeight: 38.0),
        onPressed: () => onPressed(),
        elevation: 0.0,
        highlightElevation: 0,
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        fillColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: const CircleBorder(),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 24.0,
        ),
      ),
    );
  }
}
