import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ErrorPage extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorPage({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const FittedBox(fit: BoxFit.fitWidth, child: Text("Error")),
        titleTextStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            fontFamily: "NotoSans"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 20, right: 5, top: 0),
              // ★~(◠︿◕✿)
              // (◕︿◕✿)
              // (◕﹏◕✿)
              child: Text('(◕﹏◕✿)',
                  style: TextStyle(color: Colors.redAccent, fontSize: 45)),
            ),
            const Text(
              "Something is not right here...",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 25,
                  fontFamily: "NotoSans"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, bottom: 50, right: 20, top: 10),
              child: SelectableText(errorDetails.exception.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 20)),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.error, size: 18),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent, backgroundColor: Colors.white),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Error details'),
                  content:  SingleChildScrollView(
                      scrollDirection: Axis.vertical, //.horizontal
                      child: SelectableText(errorDetails.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12, fontFamily: "monospace")),
                    ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Clipboard.setData(ClipboardData(text: errorDetails.toString())),
                      child: const Text('Copy', style: TextStyle(color: Colors.redAccent)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK', style: TextStyle(color: Colors.redAccent)) ,
                    ),
                  ],
                ),
              ),
              label: const Text('Error details'),
            ),
          ],
        )),
      ),
    );
  }
}
