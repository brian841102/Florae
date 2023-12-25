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
  @override
  void initState() {
    super.initState();
    // Hide the status bar when this page is displayed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Size Compare'),
      // ),
      body: Container(
        alignment: Alignment.topLeft,
        height: 600,
        child: const Ruler(
          style: TextStyle(color: Colors.black),
          length: 170,//mm
        ),
      ),
    );

  }
}