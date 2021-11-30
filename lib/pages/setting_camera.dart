// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:non_helmet_mobile/modules/resolution.dart';

class SettingCamera extends StatefulWidget {
  SettingCamera({Key? key}) : super(key: key);

  @override
  _SettingCameraState createState() => _SettingCameraState();
}

class _SettingCameraState extends State<SettingCamera> {
  bool autoUpload = false;
  bool recordVideo = false;
  bool boundingBox = false;
  List<Resolution> resolution = <Resolution>[
    const Resolution(1, '720p'),
    const Resolution(2, '1080p'),
  ];

  Resolution valueRes = const Resolution(1, '720p');

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
            'ตั้งค่ากล้อง',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            //textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 25.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 10.0),
                dnResolution(),
                const SizedBox(height: 15.0),
                swAutoUpload(),
                const SizedBox(height: 15.0),
                swRecordVideo(),
                const SizedBox(height: 15.0),
                swBoundingBox(),
              ],
            ),
          ),
        ));
  }

  Widget dnResolution() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "ความละเอียดกล้อง",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 10.0),
        Container(
          width: 100,
          decoration: const BoxDecoration(
              border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.black),
          )),
          child: DropdownButtonHideUnderline(
            child: new DropdownButton<Resolution>(
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              //isExpanded: true,
              hint: const Text('กรุณาเลือก'),
              value: valueRes,
              onChanged: (value) {
                setState(() {
                  valueRes = value!;
                });
                print("valueRes = ${valueRes.id}");
              },
              items: resolution.map((Resolution persontypes) {
                return new DropdownMenuItem<Resolution>(
                  value: persontypes,
                  child: new Text(
                    persontypes.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget swAutoUpload() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "อัปโหลดรูปภาพอัติโนมัติ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 10.0),
        FlutterSwitch(
          height: 30.0,
          width: 60.0,
          padding: 4.0,
          toggleSize: 20.0,
          //borderRadius: 10.0,
          activeColor: Colors.black,
          value: autoUpload,
          onToggle: (value) {
            setState(() {
              autoUpload = value;
            });
            print("autoUpload = ${autoUpload}");
          },
        )
      ],
    );
  }

  Widget swRecordVideo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "บันทึกวิดีโอขณะตรวจจับ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 10.0),
        FlutterSwitch(
          height: 30.0,
          width: 60.0,
          padding: 4.0,
          toggleSize: 20.0,
          //borderRadius: 10.0,
          activeColor: Colors.black,
          value: recordVideo,
          onToggle: (value) {
            setState(() {
              recordVideo = value;
            });
            print("recordVideo = ${recordVideo}");
          },
        )
      ],
    );
  }

  Widget swBoundingBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "แสดง BoundingBox",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 10.0),
        FlutterSwitch(
          height: 30.0,
          width: 60.0,
          padding: 4.0,
          toggleSize: 20.0,
          //borderRadius: 10.0,
          activeColor: Colors.black,
          value: boundingBox,
          onToggle: (value) {
            setState(() {
              boundingBox = value;
            });
            print("boundingBox = ${boundingBox}");
          },
        )
      ],
    );
  }
}
