import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unicons/unicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plugins/ruler.dart';
import 'plugins/expandable_fab.dart';
import 'plugins/bottom_picker/bottom_picker.dart';
import '../main.dart';
import '../data/beetle_wiki.dart';
import 'package:provider/provider.dart';
import '../../states/ruler_magnification_provider.dart';

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

  double rulerMagnification = 1.0;
  @override
  void initState() {
    super.initState();
    // Hide the status bar when this page is displayed
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    // );
    fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
    getSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    final double originalScale = MediaQuery.of(context).textScaleFactor;
    // Generating values from 0.8 to 1.2 with a step of 0.001
    final decimalList = List.generate(401, (index) {
      double number = (index + 800) / 1000; 
      String formattedNumber = number.toStringAsFixed(3);

      return Text(
        formattedNumber,
        style: TextStyle(fontSize: 18 / originalScale),
      );
    }).toList();

    return Scaffold(
      body: GestureDetector(
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
          if (!lock) {
            _scale = details.scale * _lastUpdateScale;
            _scale = _scale.clamp(0.3, 20);
            // print("Scale: ");
            // print(_scale);
            _rotation = details.rotation + _lastUpdateRotation;
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
          _lastUpdateRotation = _rotation;
          // print("_lastUpdateScale: ");
          // print(_lastUpdateScale);
        },
        onDoubleTap: () {
          if (!lock) {
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
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          HapticFeedback.vibrate();
          _showToast(lock);
          setState(() {
            lock = !lock;
          });
        },
        child: Ruler(
          style: const TextStyle(color: Colors.black),
          rulerMagnification: context.watch<RulerMagnificationProvider>().rulerMagnification,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Transform(
                  transform: Matrix4.identity()
                    ..translate(_offsetX + MediaQuery.of(context).size.width * 0.5,
                        _offsetY + MediaQuery.of(context).size.height * 0.342)
                    ..rotateZ(_rotation)
                    ..scale(_scale)
                    ..translate(
                        -MediaQuery.of(context).size.width * 0.5,
                        -MediaQuery.of(context).size.height *
                            occupyRatio *
                            0.5), //setup rotate origin
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
      floatingActionButton: ExpandableFab(
        distance: 50,
        children: [
          ActionButton(
            onPressed: () => _showGuide(context),
            // icon: const Icon(Icons.arrow_back_rounded, size: 24),
            icon: const Icon(Icons.question_mark_rounded, size: 24),
            text: Text(
              "教學",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: "MPLUS",
                  fontSize: 14,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500),
            ),
          ),
          ActionButton(
            onPressed: () => _showNumberPicker(context, decimalList),
            icon: const Icon(UniconsLine.ruler, size: 24),
            text: Text(
              "校正",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: "MPLUS",
                  fontSize: 14,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500),
            ),
          ),
          ActionButton(
            onPressed: () => print("3"), //_showAction(context, 2),
            icon: const Icon(UniconsLine.camera, size: 24),
            text: Text(
              "拍攝",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: "MPLUS",
                  fontSize: 14,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
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
          Icon(
            lock == false ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
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

  _showGuide(BuildContext context) {
    // showDialog<void>(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       contentPadding: const EdgeInsets.only(left: 20, right: 20,top: 16),
    //       content: const SizedBox(
    //         height: 85,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Text("長按：鎖定/解除鎖定"),
    //             Text("雙擊：重設視圖"),
    //             Text("單指拖動：移動"),
    //             Text("雙指拖動：旋轉/縮放"),
    //           ],
    //         ),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: const Text('Close'),
    //         ),
    //       ],
    //     );
    //   },
    // );
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey[500],
                  ),
                ),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("長按：鎖定/解除鎖定"),//, style: TextStyle(fontFamily: "MPLUS")),
                      Text("雙擊：重設視圖"),//, style: TextStyle(fontFamily: "MPLUS")),
                      Text("單指拖動：移動"),//, style: TextStyle(fontFamily: "MPLUS")),
                      Text("雙指拖動：旋轉/縮放"),//, style: TextStyle(fontFamily: "MPLUS")),
                    ],
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                      ),
                      child: const Text(
                        '返回',
                        style: TextStyle(
                            fontFamily: "MPLUS",
                            fontSize: 16,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rulerMagnification = prefs.getDouble('ruler_magnification') ?? 1.0;
    });
  }

  Future<void> _showNumberPicker(BuildContext context, List<Text> items) async {
    await getSharedPrefs();
    if (context.mounted) {
      return BottomPicker(
        height: 240,
        displayCloseIcon: false,
        dismissable: true,
        items: items,
        title: '設定尺規縮放係數',
        titleStyle: const TextStyle(fontSize: 19, letterSpacing: 2, fontWeight: FontWeight.bold),
        titleAlignment: CrossAxisAlignment.center,
        titlePadding: const EdgeInsets.only(bottom: 12),
        // onSubmit: (index) {
        // },
        displayButtonIcon: false,
        displaySubmitButton: false,
        buttonText: '儲存',
        buttonTextReset: '重置',
        buttonTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: "MPLUS",
            fontSize: 16,
            letterSpacing: 6,
            fontWeight: FontWeight.w500),
        buttonWidth: 140,
        buttonSingleColor: Colors.transparent,
        buttonAlignment: MainAxisAlignment.spaceEvenly,
        selectedItemIndex: ((rulerMagnification - 0.8) / 0.001).round(),
        pickerTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
      ).show(context);
    }
  }
}
