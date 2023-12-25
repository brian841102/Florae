import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plugins/ruler.dart';

class SizeCompare extends StatefulWidget {
  const SizeCompare({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  _SizeCompareState createState() => _SizeCompareState();
}


class _SizeCompareState extends State<SizeCompare> {

  double scaleFactor = 1.0;
  @override
  void initState() {
    super.initState();
    // Hide the status bar when this page is displayed
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    // );
  }

  @override
  void dispose() {
    super.dispose();
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        setState(() {
          //scaleFactor = 1;
          //scaleFactor =  details.scale.clamp(0.3, 1.8);
        });
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          scaleFactor -= details.primaryDelta! * 0.005;
          scaleFactor = scaleFactor.clamp(0.3, 20);
        });
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Size Compare'),
        // ),
        body: SizedBox(
          child: Ruler(
            style: const TextStyle(color: Colors.black),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 200 * scaleFactor,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Image.asset('assets/images/cii_r.png'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}