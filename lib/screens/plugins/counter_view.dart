import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../main.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../states/ruler_magnification_provider.dart';

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
    fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
    _counter = widget.initNumber ?? 0;
    _onSelectedItemChanged = widget.onSelectedItemChanged ?? (int number) {};
    _minNumber = widget.minNumber ?? 0;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> setSharedPrefs(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ruler_magnification', index * 0.001 + 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Spacer(flex: 2),
            SizedBox(
              width:140,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: ElevatedButton(
                  onPressed: () async{
                     _reset();
                     var counter = context.read<RulerMagnificationProvider>();
                     counter.setValue(1.0); //save to provider
                     setSharedPrefs(200);//1.0
                  },
                  style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8.0),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: const Text('重置',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "MPLUS",
                      fontSize: 16,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
            SizedBox(
              width:140,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: ElevatedButton(
                  onPressed: () {
                     var counter = context.read<RulerMagnificationProvider>();
                     counter.setValue(_counter * 0.001 + 0.8); //save to provider
                     setSharedPrefs(_counter);
                     _showToast();
                     Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                  child: const Text('儲存',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "MPLUS",
                      fontSize: 16,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ],
    );
  }



  void _increment() {
    // var counter = context.read<RulerMagnificationProvider>();
    // counter.increment();
    setState(() {
      if (_counter < widget.children.length - 1) {
        Vibration.vibrate(duration: 50);
        _counter++;
        _onSelectedItemChanged(_counter);
      }
    });
  }

  void _decrement() {
    // var counter = context.read<RulerMagnificationProvider>();
    // counter.decrement();
    setState(() {
      if (_counter > _minNumber) {
        Vibration.vibrate(duration: 50);
        _counter--;
        _onSelectedItemChanged(_counter);
      }
    });
  }

  void _reset() {
    setState(() {
      _counter = 200;//1.0
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

  late FToast fToast;
  Container _toast() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey[800],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(
          //   Icons.lock_outline_rounded,
          //   color: Colors.white,
          //   size: 24,
          // ),
          // SizedBox(width: 6),
          Text('已儲存',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "MPLUS",
              fontSize: 16,
              letterSpacing: 2,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  _showToast() {
    fToast.showToast(
      child: _toast(),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
