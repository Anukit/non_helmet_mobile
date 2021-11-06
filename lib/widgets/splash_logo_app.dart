import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/pages/login.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: Login_Page(),
      duration: 3000,
      imageSize: 200,
      imageSrc: "assets/images/LogoApp.png",
      backgroundColor: Colors.white,
    );
  }
}