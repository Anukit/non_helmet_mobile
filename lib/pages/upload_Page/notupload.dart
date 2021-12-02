import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:non_helmet_mobile/pages/upload_Page/google_map.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';

class NotUpload extends StatelessWidget {
  NotUpload();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _MyPage(),
    );
  }
}

class _MyPage extends StatefulWidget {
  const _MyPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<_MyPage> with AutomaticKeepAliveClientMixin {
  List<FileSystemEntity> _photoList = [];
  // ใส่เพื่อเมื่อสลับหน้า(Tab) ให้ใช้ข้อมูลเดิมที่เคยโหลดแล้ว ไม่ต้องโหลดใหม่
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    getFile();
  }

  Future<int> deleteFile(index) async {
    try {
      _photoList[index].deleteSync();
      _photoList.removeAt(index);
      Navigator.pop(context, 'OK');
      setState(() {});
      return 0;
    } catch (e) {
      return 1;
    }
  }

  Future<void> getFile() async {
    Directory dir = await checkDirectory("Pictures");
    //ไฟล์รูป
    setState(() {
      List<FileSystemEntity> _photoLists = dir.listSync();
      _photoList = List.from(_photoLists.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: _photoList.isNotEmpty
              ? ListView.builder(
                  // scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _photoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildDataImage(index);
                  },
                )
              : const Center(
                  child: Text("ไม่มีรูปภาพ"),
                )),
    );
  }

  Future<Widget> datetimeImage(index) async {
    final tags = await readExifFromFile(_photoList[index]);
    var dateTime = tags['EXIF DateTimeOriginal'].toString();
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Text("วันที่" " " + formatDate(dateTime)));
  }

  Future<Widget> displayPicture(index) async {
    return Image.file(
      _photoList[index] as File,
      width: 150.0,
      height: 150.0,
      //scale: 16.0,
      fit: BoxFit.contain,
    );
  }

  Future<List<double>> coordinates(index) async {
    List<double> latlong = [];
    final tags = await readExifFromFile(_photoList[index]);
    /////////////////////////////////// พิกัด////////////////////////////////////
    final latitudeValue = tags['GPS GPSLatitude']!
        .values
        .toList()
        .map<double>(
            (item) => (item.numerator.toDouble() / item.denominator.toDouble()))
        .toList();
    final latitudeSignal = tags['GPS GPSLatitudeRef']!.printable;
    final longitudeValue = tags['GPS GPSLongitude']!
        .values
        .toList()
        .map<double>(
            (item) => (item.numerator.toDouble() / item.denominator.toDouble()))
        .toList();
    final longitudeSignal = tags['GPS GPSLongitudeRef']!.printable;

    double latitude =
        latitudeValue[0] + (latitudeValue[1] / 60) + (latitudeValue[2] / 3600);

    double longitude = longitudeValue[0] +
        (longitudeValue[1] / 60) +
        (longitudeValue[2] / 3600);

    if (latitudeSignal == 'S') latitude = -latitude;
    if (longitudeSignal == 'W') longitude = -longitude;
    latlong.add(latitude);
    latlong.add(longitude);
    //////////////////////////////////////////////////////////////////////////
    return latlong;
  }

  Widget buildDataImage(index) {
    return GestureDetector(
        onTap: () {
          zoomPictureDialog(context, _photoList[index]);
        },
        child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FutureBuilder(
                        future: displayPicture(index),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data != null) {
                            return snapshot.data;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                  ),
                  Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("วันที่ตรวจจับ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          FutureBuilder(
                              future: datetimeImage(index),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.data != null) {
                                  return snapshot.data;
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                          const Text("ละติจูด, ลองติจูด",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          Container(
                              //margin: const EdgeInsets.symmetric(vertical: 10),
                              child: TextButton(
                            onPressed: () {
                              coordinates(index).then((value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowMap(value)),
                                );
                              });
                            },
                            child: FutureBuilder(
                                future: coordinates(index),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.data != null) {
                                    return Text(
                                        "${snapshot.data[0].toStringAsFixed(3)}, ${snapshot.data[1].toStringAsFixed(3)}",
                                        style:
                                            TextStyle(color: Colors.blue[900]));
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          )),
                        ],
                      )),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                            onPressed: () {
                              comfirmDialog("ต้องการอัปโหลดหรือไม่", index, 1);
                            },
                            icon: const Icon(Icons.file_upload)),
                        const SizedBox(
                          height: 100,
                        ),
                        IconButton(
                            onPressed: () {
                              comfirmDialog("ต้องการลบหรือไม่", index, 2);
                            },
                            icon: const Icon(
                              Icons.restore_from_trash,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  comfirmDialog(String message, index, type) {
    //type 1 = อัปโหลก type 2 = ลบไฟล์
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Text(
          message,
          style: const TextStyle(
            fontSize: 17,
          ),
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: Text(
                  'ใช่',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (type == 1) {
                    Navigator.of(context).pop();
                  } else {
                    deleteFile(index);
                  }
                },
              ),
              TextButton(
                child: Text(
                  'ไม่',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
