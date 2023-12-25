import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Ruler extends StatelessWidget {
  
  final Color? tickColor;
  final TextStyle? style;
  final bool? showZero;
  final double? length;
  final Widget? child;

  const Ruler({super.key,
    this.tickColor,
    this.style,
    this.showZero,
    this.length,
    this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter:
          _RulerPainter(context,
              tickColor: tickColor ?? Colors.black ,
              style: style ?? const TextStyle(color: Colors.blue),
              showZero: showZero ?? true,
              length: length ?? MediaQuery.of(context).size.height*0.9/
                      (455.6/MediaQuery.of(context).devicePixelRatio/25.4),
          ),
      child: child,
    );
  }
}

class _RulerPainter extends CustomPainter {
  final Color tickColor;
  final TextStyle style;
  final bool showZero;
  final double length;

  late double dpr;
  late double screenHeight;
  _RulerPainter(BuildContext context,
    {required this.tickColor, required this.style, required this.showZero, required this.length}) {
    dpr = MediaQuery.of(context).devicePixelRatio;
    screenHeight = MediaQuery.of(context).size.height;
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

    double dpi = 455.6;
    double maxSize = length;
    //double maxSize = size.height / (dpi/dpr/25.4);
    //double maxSize = screenHeight / (dpi/dpr/25.4);
    // print(screenHeight);
    // print('dpr: $dpr');
    // print((dpi/dpr/25.4));
    int ticker = 0;
    while (ticker <= maxSize) {
      double y =   (maxSize - ticker) * (dpi/dpr/25.4) + screenHeight*0.95 - maxSize* (dpi/dpr/25.4);
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
          canvas.drawParagraph(
              paragraph, Offset(30, y - (paragraph.height / 2)));
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
