import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> normalDialog(BuildContext context, String message) async {
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
              child: const Text('ปิด'),
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

Future<void> succeedDialog(
    BuildContext context, String message, dynamic onpressed) async {
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
              child: const Text('ปิด'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => onpressed),
                );
              },
            ),
          ],
        )
      ],
    ),
  );
}

Future<void> settingPermissionDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      title: const Text(
        "กรุณาอนุญาตตั้งค่าแอปทั้งหมดก่อน",
        style: TextStyle(fontSize: 17),
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text(
                "ไปหน้าตั้งค่าแอป",
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
              onPressed: () {
                openAppSettings();
              },
            ),
            TextButton(
              child: Text(
                "เริ่มแอปใหม่",
                style: TextStyle(fontSize: 15, color: Colors.amber.shade700),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SplashPage()),
                );
              },
            ),
          ],
        )
      ],
    ),
  );
}

Future<void> zoomPictureDialog(BuildContext context, file) async {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black12.withOpacity(0.6), // Background color
    barrierDismissible: false,
    barrierLabel: 'Dialog',
    // transitionDuration: const Duration(
    //     milliseconds:
    //         400), // How long it takes to popup dialog after button click
    pageBuilder: (_, __, ___) {
      // Makes widget fullscreen
      return SizedBox.expand(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: SizedBox.expand(
                  child: Center(
                child: InteractiveViewer(
                  panEnabled: true, // Set it to false
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 2,
                  child: Image.file(
                    file,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
            ),
          ],
        ),
      );
    },
  );
}
