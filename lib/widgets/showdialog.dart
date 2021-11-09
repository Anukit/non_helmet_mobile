import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';

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

Future<void> normalDialog2(BuildContext context, String message) async {
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
