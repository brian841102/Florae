import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class CounterView extends StatefulWidget {
  final int initNumber;
  final Function(int) counterCallback;
  final Function increaseCallback;
  final Function decreaseCallback;
  final int minNumber;

  const CounterView({
    super.key,
    required this.initNumber,
    required this.counterCallback,
    required this.increaseCallback,
    required this.decreaseCallback,
    required this.minNumber,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CounterViewState createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late int _currentCount;
  late Function(int) _counterCallback;
  late Function _increaseCallback;
  late Function _decreaseCallback;
  late int _minNumber;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.initNumber ?? 1;
    _counterCallback = widget.counterCallback ?? (int number) {};
    _increaseCallback = widget.increaseCallback ?? () {};
    _decreaseCallback = widget.decreaseCallback ?? () {};
    _minNumber = widget.minNumber ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[400],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _createIncrementDecrementButton(Icons.remove, _decrement),
          Text(_currentCount.toString()),
          _createIncrementDecrementButton(Icons.add, _increment),
        ],
      ),
    );
  }

  void _increment() {
    setState(() {
      _currentCount++;
      _counterCallback(_currentCount);
      _increaseCallback();
    });
  }

  void _decrement() {
    setState(() {
      if (_currentCount > _minNumber) {
        _currentCount--;
        _counterCallback(_currentCount);
        _decreaseCallback();
      }
    });
  }

  Widget _createIncrementDecrementButton(IconData icon, Function onPressed) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
      onPressed: () => onPressed(),
      elevation: 2.0,
      fillColor: Colors.grey[400],
      shape: const CircleBorder(),
      child: Icon(
        icon,
        color: Colors.black,
        size: 12.0,
      ),
    );
  }
}
