import 'package:flutter/material.dart';

class Template extends StatefulWidget {
  const Template({super.key, required this.index});
  final int index;

  @override
  _TemplateState createState() => _TemplateState();
}


class _TemplateState extends State<Template> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: const Center(
        child: Text(''),
      ),
    );

  }
}