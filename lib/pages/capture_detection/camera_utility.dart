import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:non_helmet_mobile/models/data_image.dart';
import 'package:non_helmet_mobile/utility/convert_image.dart';
import 'package:non_helmet_mobile/utility/saveimage_video.dart';
import 'package:non_helmet_mobile/utility/upload_detect_image.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef Callback = void Function(
    List<dynamic> list, int h, int w, List<dynamic> lists);

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
  List<CameraImage> listCameraimg = [];
  String? recordVideo;
  String? autoUpload;
  String? resolution;
  Size? screen; //สำหรับ Crop
  List<DataAveColor> listAvgColors = [];
  List<dynamic> listDataForTrack = [];
  late int user_id;

  ///////////////////////////////////
  int indexFrame = 0;
  int frame = 5;
  int startTime = 0;
  int endTime = 0;
  ///////////////////////////////////

  String frameImgDirPath = ""; // path โฟลเดอร์เฟรมภาพ
  String videoDirPath = ""; // path โฟลเดอร์วิดีโอ
  int starttimeRec = 0;
  int endtimeRec = 0;
  bool saveRecordVideo = false; //เริ่มเซฟวิดีโอ
  bool calEndtimeRec = true; // สำหรับเช็ค เพื่อคำนวณเวลาที่จะเซฟวิดีโอ

  @override
  void initState() {
    super.initState();
    //imageDetect();
    getData();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id') ?? 0;

    //รับ path โฟลเดอร์เฟรมภาพ
    frameImgDirPath = await createFolder("FrameImage");
    //รับ path โฟลเดอร์วิดีโอ
    videoDirPath = await createFolder("Video");

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
          ///////////////////////////ส่วนอัดวิดีโอ/////////////////////////////
          if (recordVideo == "true") {
            indexFrame++;
            starttimeRec = DateTime.now().millisecondsSinceEpoch;

            //ใเก็บเฟรมภาพตามเฟรมที่กำหนด
            if (indexFrame == 20) {
              listCameraimg.add(img);
              indexFrame = 0;
            }

            if (calEndtimeRec) {
              //เวลาที่จะให้เริ่มเซฟวิดีโอ ทุก ๆ 10 นาที
              endtimeRec = starttimeRec + 600000;
              calEndtimeRec = false;
            }

            if (!saveRecordVideo) {
              if (starttimeRec > endtimeRec) {
                saveRecordVideo = true;
                print("AAAAAAAAAAAASSSSSSSSSSAAAAAAAAAAAAAA");
                if (frameImgDirPath.isNotEmpty && videoDirPath.isNotEmpty) {
                  SaveVideo(listCameraimg, frameImgDirPath, videoDirPath,
                      (value) {
                    print("XXXXXXXXXXXXXXXXXXXXX = $value");
                    listCameraimg.clear();
                    saveRecordVideo = false;
                    calEndtimeRec = true;
                  }).init();
                }
              }
            }
          }
          /////////////////////////////ส่วนตรวจจับ////////////////////////////
          if (!isDetecting) {
            isDetecting = true;
            ////////////////////////////////////////////////////////////////
            startTime = DateTime.now().millisecondsSinceEpoch;
            ////////////////////////////////////////////////////////////////
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

              //เงื่อนไขเพื่อแก้บัคข้อมูลซ้ำ
              if (i == 0) {
                checkValue.add("value");
                if (checkValue.length > 1) {
                  recognitions = [];
                }
              }

              if (i == 1) {
                if (listAvgColors.isEmpty) {
                  recognitions = [];
                }
              }

              if (recognitions!.isNotEmpty) {
                //print("recognitions = $recognitions");
                List listdata = [];
                listdata.add(img);
                listdata.add(recognitions);
                listdata.add(screen);
                listdata.add(listAvgColors);
                // print("listAvgColors 1 = ${listdata[3]}");
                // print("iiiiiii 2 = $i");

                compute(convertImage, listdata).then((value) {
                  i = 1;
                  //print("value = $value");
                  if (value.isNotEmpty) {
                    //print("listAvgColors = ${value[0].averageColor} 2");
                    //print("data track = ${value[0].dataforTrack}");
                    listDataForTrack = value[0].dataforTrack;

                    if (value[0].dataImage.isNotEmpty &&
                        value[0].listAvgColor.isNotEmpty) {
                      listAvgColors = value[0].listAvgColor;
                      // print("ListColorss = ${value[0].listAvgColor}");
                      // print("Listimage = ${value[0].dataImage}");
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
                  } else {
                    listDataForTrack = [];
                  }
                });

                // print("listDataForTrack = $listDataForTrack 1");
              } else {
                listDataForTrack = [];
              }
              //////////////////////////////////////////////////////////////////
              endTime = DateTime.now().millisecondsSinceEpoch;
              // print("Detection took ${endTime - startTime}ms");
              // print("listDataForTrack = $listDataForTrack 2");
              widget.setRecognitions(
                  recognitions, img.height, img.width, listDataForTrack);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    if (recordVideo == "true" && !saveRecordVideo) {
      if (frameImgDirPath.isNotEmpty && videoDirPath.isNotEmpty) {
        SaveVideo(listCameraimg, frameImgDirPath, videoDirPath, (value) {
          print("XXXXXXXXXXXXXXXXXXXXX = $value");
        }).init();
      }
    }
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
