import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Ruler extends StatelessWidget {
  final Color? tickColor;
  final TextStyle? style;
  final bool? showZero;
  final double? length;
  final Widget? child;
  final double? rulerMagnification;

  const Ruler({super.key, this.tickColor, this.style, this.showZero, this.length, this.child, this.rulerMagnification});

  @override
  Widget build(BuildContext context) {
    final double dpi = 453 * (rulerMagnification ?? 1.0);
    return CustomPaint(
      foregroundPainter: _RulerPainter(
        context: context,
        tickColor: tickColor ?? Colors.black,
        style: style ?? const TextStyle(color: Colors.blue),
        showZero: showZero ?? true,
        length: length ?? MediaQuery.of(context).size.height * 0.9 /
                (dpi / MediaQuery.of(context).devicePixelRatio / 25.4),
        dpi: dpi
      ),
      child: child,
    );
  }
}

class _RulerPainter extends CustomPainter {
  final BuildContext context;
  final Color tickColor;
  final TextStyle style;
  final bool showZero;
  final double length;
  final double dpi;

  late double dpr;
  late double screenHeight;
  late double screenWidth;
  _RulerPainter(
      {required this.context,
      required this.tickColor,
      required this.style,
      required this.showZero,
      required this.length,
      required this.dpi}) {
    dpr = MediaQuery.of(context).devicePixelRatio;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint mmTick = Paint()
      ..color = tickColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    Paint cmTick = Paint()
      ..color = tickColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    Paint dashLine = Paint()
      ..color = Theme.of(context).colorScheme.surfaceTint.withOpacity(0.6)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double maxSize = length;
    //double maxSize = size.height / (dpi/dpr/25.4);
    //double maxSize = screenHeight / (dpi/dpr/25.4);
    // print(screenHeight);
    // print('dpr: $dpr');
    // print((dpi/dpr/25.4));
    int ticker = 0;
    while (ticker <= maxSize) {
      double y = (maxSize - ticker) * (dpi/dpr/25.4) + screenHeight*0.95 - maxSize * (dpi/dpr/25.4);
      //print('ticker: $ticker, y: $y');
      if (ticker % 10 == 0) {
        canvas.drawLine(Offset(0, y), Offset(20, y), cmTick);
        var paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
          ..pushStyle(style.getTextStyle())
          ..addText('${ticker ~/ 10}');
        //..pop();
        var paragraph = paragraphBuilder.build()
          ..layout(const ui.ParagraphConstraints(width: 20));

        if (ticker != 0.0 || showZero) {
          canvas.drawParagraph(paragraph, Offset(30, y - (paragraph.height / 2)));
        }
        if (ticker == 0.0) {
          canvas.drawLine(Offset(45, y), Offset(screenWidth, y), dashLine);
        }
      } else if (ticker % 5 == 0) {
        canvas.drawLine(Offset(0, y), Offset(15, y), cmTick);
      } else {
        canvas.drawLine(Offset(0, y), Offset(10, y), mmTick);
      }
      ticker++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
