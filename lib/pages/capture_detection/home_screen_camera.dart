// ignore: file_names
// ignore: file_names
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'bounding_box.dart';
import 'camera_utility.dart';

const String ssd = "My model";

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen(this.cameras);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  loadModel() async {
    String? result;
    switch (_model) {
      case ssd:
        result = await Tflite.loadModel(
            labels: "assets/tflite/ssd_mobilenet.txt",
            model: "assets/tflite/ssd_mobilenet.tflite",
            useGpuDelegate: false);
    }
    print(result);
  }

  onSelectModel(model) {
    setState(() {
      _model = model;
    });

    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    checkGPS().then((value) => value
        ? onSelectModel(ssd)
        : succeedDialog(context, "กรุณาเปิด GPS", HomePage()));
    //onSelectModel(ssd);
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
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
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         print("ไปหน้าตั้งค่ากล้อง");
        //       },
        //       icon: const Icon(Icons.settings_outlined, color: Colors.black))
        // ],
      ),
      body: _model == ""
          ? Container()
          : Stack(
              children: [
                Camera(widget.cameras, _model, setRecognitions),
                BoundingBox(
                    _recognitions ?? [],
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.width,
                    screen.height,
                    _model)
              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     onSelectModel(ssd);
      //   },
      //   child: const Icon(Icons.photo_camera),
      // ),
    );
  }
}
