import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {
  VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
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
        'วิดีโอ',
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
