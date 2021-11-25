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
      title: const Text("กรุณาอนุญาตตั้งค่าแอปทั้งหมดก่อน",
        style: TextStyle(fontSize: 17),),
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
              child:  Text(
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
