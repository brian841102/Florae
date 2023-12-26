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

  double bgScale = 2.5;

  double _scale = 1.0;
  double _lastUpdateScale = 1.0;

  double _rotation = 0.0;
  double _lastUpdateRotation = 0.0;

  double _offsetX = 0.0;
  double _pointX = 0.0;
  double _lastUpdatePointX = 0.0;
  double _deltaPointX = 0.0;

  double _offsetY = 0.0;
  double _pointY = 0.0;
  double _lastUpdatePointY = 0.0;
  double _deltaPointY = 0.0;
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
      // onVerticalDragUpdate: (details) {
      //   setState(() {
      //     bgScale -= details.primaryDelta! * 0.005;
      //     bgScale = bgScale.clamp(0.3, 20);
      //   });
      // },
      onScaleStart: (details) {
        _pointX = details.focalPoint.dx;
        _lastUpdatePointX = details.focalPoint.dx;
        _pointY = details.focalPoint.dy;
        _lastUpdatePointY = details.focalPoint.dy;
      },
      onScaleUpdate: (details) {
        _scale = details.scale*_lastUpdateScale;
        _scale = _scale.clamp(0.3, 20);
        // print("Scale: ");
        // print(_scale);
        _rotation = details.rotation+_lastUpdateRotation;
        
        _deltaPointX = (details.focalPoint.dx - _lastUpdatePointX);
        _lastUpdatePointX = details.focalPoint.dx;
        _deltaPointY = (details.focalPoint.dy - _lastUpdatePointY);
        _lastUpdatePointY = details.focalPoint.dy;
        
        setState(() {
          _offsetX += _deltaPointX;
          _offsetY += _deltaPointY;
        });
      },
      onScaleEnd: (details) {
        _lastUpdateScale = _scale;
        _lastUpdateRotation= _rotation;
        // print("_lastUpdateScale: ");
        // print(_lastUpdateScale);
      },
      onDoubleTap: () {
        setState(() {
          _scale = 1.0;
          _lastUpdateScale = 1.0;
          _rotation = 0.0;
          _lastUpdateRotation = 0.0;
          _offsetX = 0.0;
          _lastUpdatePointX = 0.0;
          _offsetY = 0.0;
          _lastUpdatePointY = 0.0;
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
              child: Stack(
                children: [
                  Transform(
                    transform: Matrix4.translationValues(_offsetX, _offsetY, 0)
                      ..rotateZ(_rotation),
                    child: SizedBox(
                      height: 500 * _scale,
                      width: double.maxFinite,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Image.asset('assets/images/cii_r.png'),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 200 * bgScale,
                  //   width: double.maxFinite,
                  //   child: FittedBox(
                  //     fit: BoxFit.fitHeight,
                  //     child: Image.asset('assets/images/cii_r.png'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}