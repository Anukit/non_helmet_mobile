import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/pages/video_page/video.dart';
import 'package:non_helmet_mobile/utility/utility.dart';

class VideoMain extends StatefulWidget {
  VideoMain({Key? key}) : super(key: key);

  @override
  _VideoMainState createState() => _VideoMainState();
}

class _VideoMainState extends State<VideoMain> {
  List<FileSystemEntity> videoList = [];
  @override
  void initState() {
    super.initState();
    getFile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getFile() async {
    Directory dir = await checkDirectory("Video");
    //ไฟล์รูป
    setState(() {
      List<FileSystemEntity> _photoLists = dir.listSync();
      videoList = List.from(_photoLists.reversed);
    });
    print("videoList = ${videoList}");
  }

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
      ),
      body: SafeArea(
          child: videoList.isNotEmpty && videoList != null
              ? ListView.builder(
                  // scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: videoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildVideoList(index);
                  },
                )
              : const Center(
                  child: Text("ไม่มีวิดีโอ"),
                )),
    );
  }

  Future<Widget> fileName(index) async {
    String filename = videoList[index].path.split('/').last;
    return Text(filename);
  }

  Future<Widget> datetimeVideo(index) async {
    String dateString =
        videoList[index].path.split('/').last.split('_').last.split('.').first;
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(dateString)).toString();
    return Text("วันที่" " " + formatDate(dateTime));
  }

  Widget buildVideoList(index) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoPage(videoList[index].path)));
        },
        onLongPress: () {
          print("AAAAAAA");
        },
        child: Card(
          child: Row(
            children: [
              Expanded(
                  child: Image.asset(
                "assets/images/playVideo.png",
                scale: 10,
              )),
              Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ชื่อไฟล์",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      FutureBuilder(
                        future: fileName(index),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data != null) {
                            return snapshot.data;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "วันที่บันทึก",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder(
                        future: datetimeVideo(index),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data != null) {
                            return snapshot.data;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  )),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          comfirmDialog("ต้องการดาวน์โหลดหรือไม่", index, 1);
                        },
                        icon: const Icon(Icons.download)),
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
        ));
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
                    downloadFile(index);
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

  Future<int> deleteFile(index) async {
    try {
      videoList[index].deleteSync();
      videoList.removeAt(index);
      Navigator.pop(context, 'OK');
      setState(() {});
      return 0;
    } catch (e) {
      return 1;
    }
  }

  Future<int> downloadFile(index) async {
    print("downloadFile");
    try {
      String? tempPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = tempPath! + '/file_$filename.mp4';
      File fileOutput = File(filePath);
      File fileInput = File(videoList[index].path);
      await fileOutput.writeAsBytes(fileInput.readAsBytesSync(),
          mode: FileMode.writeOnly);
      Navigator.pop(context, 'OK');
      print("Succeed");
      return 0;
    } catch (e) {
      return 1;
    }
  }
}
