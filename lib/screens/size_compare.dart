import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'plugins/ruler.dart';
import '../main.dart';
import '../data/beetle_wiki.dart';

class SizeCompare extends StatefulWidget {
  const SizeCompare({super.key, required this.index});
  final int index;

  @override
  State<SizeCompare> createState() => _SizeCompareState();
}


class _SizeCompareState extends State<SizeCompare> {

  double bgScale = 2.5;

  double occupyRatio = 0.6;

  double _scale = 1.0;
  double _lastUpdateScale = 1.0;

  double _rotation = 0.0;
  double _lastUpdateRotation = 0.0;

  double _offsetX = 0.0;
  double _lastUpdatePointX = 0.0;
  double _deltaPointX = 0.0;

  double _offsetY = 0.0;
  double _lastUpdatePointY = 0.0;
  double _deltaPointY = 0.0;

  bool lock = false;
  @override
  void initState() {
    super.initState();
    // Hide the status bar when this page is displayed
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    // );
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    super.dispose();
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }
  @override
  Widget build(BuildContext context) {
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    return GestureDetector(
      // onVerticalDragUpdate: (details) {
      //   setState(() {
      //     bgScale -= details.primaryDelta! * 0.005;
      //     bgScale = bgScale.clamp(0.3, 20);
      //   });
      // },
      onScaleStart: (details) {
        _lastUpdatePointX = details.focalPoint.dx;
        _lastUpdatePointY = details.focalPoint.dy;
      },
      onScaleUpdate: (details) {
        if(!lock){
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
        }
      },
      onScaleEnd: (details) {
        _lastUpdateScale = _scale;
        _lastUpdateRotation= _rotation;
        // print("_lastUpdateScale: ");
        // print(_lastUpdateScale);
      },
      onDoubleTap: () {
        if(!lock) {
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
        }
      },
      onLongPress: () {
        // var snackBar = SnackBar(
        //   content: Text(
        //     lock == false
        //         ? '已鎖定'
        //         : '已解鎖',
        //     style: const TextStyle(fontSize: 16),
        //     textAlign: TextAlign.center,
        //   ),
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        //   duration: const Duration(seconds: 2),
        //   margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 140),
        //   behavior: SnackBarBehavior.floating,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);//TODO: change to toast
        //SystemSound.play(SystemSoundType.click);
        HapticFeedback.heavyImpact();
        _showToast(lock);
        setState(() {
          lock = !lock;
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
                    transform: Matrix4.identity()
                      ..translate(_offsetX+MediaQuery.of(context).size.width * 0.5,
                          _offsetY+MediaQuery.of(context).size.height * 0.342)
                      ..rotateZ(_rotation)
                      ..scale(_scale)
                      ..translate(-MediaQuery.of(context).size.width * 0.5,
                          -MediaQuery.of(context).size.height * occupyRatio * 0.5),//setup rotate origin
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * occupyRatio,
                      width: double.maxFinite,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Image.asset(bt.imagePathR),
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

  late FToast fToast;
  Container _toast(bool lock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey[800],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(lock == false ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
              color: Colors.white,
              size: 24,
          ),
          // const SizedBox(width: 6),
          // Text(lock == false ? '已鎖定' : '已解鎖',
          //   style: const TextStyle(
          //     color: Colors.white,
          //     fontSize: 16,
          //   ),
          // ),
        ],
      ),
    );
  }

  _showToast(bool lock) {
    fToast.showToast(
      child: _toast(lock),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }
}