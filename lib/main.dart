import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Non Helmet Detection',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: SplashPage());
  }
}
