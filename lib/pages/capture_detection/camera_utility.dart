import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:non_helmet_mobile/utility/convert_image.dart';
import 'package:non_helmet_mobile/utility/saveimage_video.dart';
import 'package:non_helmet_mobile/utility/upload_detect_image.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef Callback = void Function(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;
  const Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;
  int i = 0; //สำหรับแก้บัคข้อมูลซ้ำ
  List checkValue = []; //สำหรับแก้บัคข้อมูลซ้ำ
  List listimg = [];
  String? recordVideo;
  String? autoUpload;
  String? resolution;
  Size? screen; //สำหรับ Crop
  List<Color> listAvaColors = [];
  late int user_id;

  ///////////////////////////////////
  int indexFrame = 0;
  int frame = 5;
  int startTime = 0;
  int endTime = 0;
  ///////////////////////////////////

  @override
  void initState() {
    super.initState();
    //imageDetect();
    getData();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id') ?? 0;

    var listdata = await getDataSetting();
    if (listdata != "Error") {
      resolution = listdata["resolution"];
      autoUpload = listdata["autoUpload"];
      recordVideo = listdata["recordVideo"];
    } else {
      resolution = "1";
      autoUpload = "true";
      recordVideo = "false";
    }
    imageDetect();
  }

  imageDetect() {
    if (widget.cameras.isEmpty) {
      print('No camera is found');
    } else {
      controller = CameraController(
          widget.cameras[0],
          resolution == "1"
              ? ResolutionPreset.high
              : ResolutionPreset.veryHigh);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller!.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            ///////////////////////////////////////////////////////////////////
            if (indexFrame == 0) {
              startTime = DateTime.now().millisecondsSinceEpoch;
            }
            indexFrame++;
            ///////////////////////ส่วนตรวจจับ////////////////////////////////////
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 127.5,
              imageStd: 127.5,
              // numResultsPerClass: 4,
              // threshold: 0.1,
              numResultsPerClass: 8,
              numBoxesPerBlock: 8,
              threshold: 0.5,
            ).then((recognitions) {
              /////////////////////ส่วนเงื่อนไข////////////////////////////////////
              //print("indexFrame = ${indexFrame}");

              //เริ่มทำตามเฟรมที่กำหนด
              if (indexFrame == frame) {
                endTime = DateTime.now().millisecondsSinceEpoch;
                //print("In every $frame frame took ${endTime - startTime}ms");
                //listimg.add(img); //สำหรับวิดีโอ

                //เงื่อนไขเพื่อแก้บัคข้อมูลซ้ำ
                if (i == 0) {
                  print("ASASASASAS");
                  checkValue.add("value");
                  if (checkValue.length > 1) {
                    recognitions = [];
                  }
                }

                if (recognitions!.isNotEmpty) {
                  //print("recognitions = $recognitions");
                  List listdata = [];
                  listdata.add(img);
                  listdata.add(recognitions);
                  listdata.add(screen);
                  listdata.add(listAvaColors);
                  print("listAvaColors = $listAvaColors");

                  compute(convertImage, listdata).then((value) {
                    i = 1;
                    print("value = $value");
                    if (value.isNotEmpty) {
                      //print("listAvaColors = ${value[0].averageColor} 2");
                      listAvaColors = value[0].averageColor;
                      for (var i = 0; i < value[0].dataImage.length; i++) {
                        if (autoUpload == "true") {
                          uploadDatectedImage(
                              user_id,
                              value[0].dataImage[i].riderImg,
                              value[0].dataImage[i].license_plateImg);
                        } else {
                          saveImageDetect(value[0].dataImage[i].riderImg,
                              value[0].dataImage[i].license_plateImg);
                        }
                      }
                    }
                  });
                }
                indexFrame = 0;
              }
              //////////////////////////////////////////////////////////////////
              // print("Detection took ${endTime - startTime}");
              // print("recognitions : $recognitions");
              widget.setRecognitions(recognitions!, img.height, img.width);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    // if (recordVideo == "true") {
    //   convertImage(listimg, "Video");
    // } else {}
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    screen = MediaQuery.of(context).size; //สำหรับ Crop
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller!),
    );
  }
}
