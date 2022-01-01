import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/capture_detection/home_screen_camera.dart';
import 'package:non_helmet_mobile/pages/edit_profile.dart';
import 'package:non_helmet_mobile/pages/settings.dart';
import 'package:non_helmet_mobile/pages/upload_Page/upload_home.dart';
import 'package:non_helmet_mobile/pages/video_page/video_main.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? countAllRider;
  int? countMeRider;

  @override
  void initState() {
    super.initState();
    checkInternet(context);
    permissionCamera()
        .then((value) => !value ? settingPermissionDialog(context) : null);
    getData();
  }

  Future<void> getData() async {
    print("AAAAAAAAAAAAAAAAA");
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getAmountRider(user_id);
      if (result.pass) {
        if (result.data["status"] == "Succeed") {
          setState(() {
            //var listdata = result.data["data"][0];
            countMeRider = result.data["data"]["countMeRider"];
            countAllRider = result.data["data"]["countAllRider"];
          });
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    print("countAllRider = $countAllRider");
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Helmet',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Capture',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  children: <Widget>[
                    buildimageAc(EditProfile()),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'รถที่คุณตรวจจับได้:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      // height: 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                      margin: const EdgeInsets.all(20.0),
                      height: 25.0,
                      width: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey[200],
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Align(
                          alignment: Alignment.center,
                          child: countMeRider != null
                              ? Text(countMeRider.toString())
                              : const Text("กำลังโหลด"))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'รถที่ตรวจจับได้ทั้งหมด:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      // height: 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.all(20.0),
                      height: 25.0,
                      width: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey[200],
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Align(
                          alignment: Alignment.center,
                          child: countAllRider != null
                              ? Text(countAllRider.toString())
                              : const Text("กำลังโหลด")))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildMenuBtn(
                        1,
                        const Icon(
                          Icons.camera_alt,
                          size: 60,
                        ),
                        "ตรวจจับ"),
                    buildMenuBtn(
                        2,
                        const Icon(
                          Icons.video_collection,
                          size: 60,
                        ),
                        "วิดีโอ"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildMenuBtn(
                        3,
                        const Icon(
                          Icons.cloud_download,
                          size: 60,
                        ),
                        "อัปโหลด"),
                    buildMenuBtn(
                        4,
                        const Icon(
                          Icons.settings_outlined,
                          size: 60,
                        ),
                        "ตั้งค่า"),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  Widget buildMenuBtn(onPressed, icon, content) {
    print("1");
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 2),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (onPressed == 1) {
            late List<CameraDescription> cameras;
            try {
              cameras = await availableCameras();
            } on CameraException catch (e) {
              print('Error: $e.code \n Eooro Message: $e.message');
              cameras = [];
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomeScreen(cameras)));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => onPressed == 2
                      ? VideoMain()
                      : onPressed == 3
                          ? Upload()
                          : onPressed == 4
                              ? SettingPage()
                              : HomePage()),
            );
          }
        },
        child: Column(
          children: [
            icon,
            Text(
              "$content",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )
          ],
        ),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(25),
          // primary: Colors.blue, // <-- Button color
          // onPrimary: Colors.red, // <-- Splash color
        ),
      ),
    );
  }

  Widget buildimageAc(onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => onTap),
        );
      },
      child: FutureBuilder(
        future: getImage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data != null &&
              snapshot.data != "false" &&
              snapshot.data != "Error") {
            return Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
                image: DecorationImage(
                    image: NetworkImage("${snapshot.data}"), fit: BoxFit.fill),
              ),
            );
          } else if (snapshot.data == "Error") {
            return const CircleAvatar();
          } else {
            return const CircleAvatar(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<String> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getDataUser(user_id);
      if (result.pass) {
        var imagename = result.data["data"][0]["image_profile"];
        String urlImage = "${Constant().domain}/profiles/$imagename";
        var response = await Dio().get(urlImage);
        if (response.statusCode == 200) {
          return urlImage;
        } else {
          return "false";
        }
      } else {
        return "false";
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return "Error";
    }
  }
}
