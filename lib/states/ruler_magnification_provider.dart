import 'package:flutter/material.dart';

class RulerMagnificationProvider extends ChangeNotifier {
  double rulerMagnification = 1.0;

   void setValue(double value) {
    rulerMagnification = value;
    notifyListeners();
  }

  void increment() {
    rulerMagnification += 0.001;
    notifyListeners();
  }
  void decrement() {
    rulerMagnification -= 0.001;
    notifyListeners();
  }

  void reset() {
    rulerMagnification = 1.0;
    notifyListeners();
  }

  
}