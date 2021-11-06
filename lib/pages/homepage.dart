import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  children: <Widget>[
                    buildAc(
                      () => print('Login with Facebook'),
                      const NetworkImage("https://media.istockphoto.com/photos/freedom-chains-that-transform-into-birds-charge-concept-picture-id1322104312")
                    ),
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
                  ),
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
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 70.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildSocialBtn(() {
                      /* getImage(); */
                      /*  getVideo(); */
                    },
                        const Icon(
                          Icons.camera_alt,
                          size: 60,
                        ),
                        "ตรวจจับ"),
                    buildSocialBtn(
                        null,
                        const Icon(
                          Icons.video_collection,
                          size: 60,
                        ),
                        "แกลเลอรี"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildSocialBtn(
                        null,
                        const Icon(
                          Icons.cloud_download,
                          size: 60,
                        ),
                        "อัปโหลด"),
                    buildSocialBtn(
                        null,
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

  Widget buildSocialBtn(onTap, icon, content) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.0,
        width: 110.0,
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            icon,
            Text(
              "$content",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAc(onTap, logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            image: logo,
            fit: BoxFit.fill
          ),
        ),
      ),
    );
  }
}
