import 'package:flutter/material.dart';

class GallertPage extends StatefulWidget {
  GallertPage({Key? key}) : super(key: key);

  @override
  _GallertPageState createState() => _GallertPageState();
}

class _GallertPageState extends State<GallertPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      title: const Text(
        'แกลเลอรี',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        //textAlign: TextAlign.center,
      ),
      centerTitle: true,
    ));
  }
}
