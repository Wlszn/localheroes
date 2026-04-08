import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'mainScreen.dart';
//Code for Splash screen

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SplashScreen(
        seconds: 5,
        navigateAfterSeconds: MainScreen(),
        title: Text(''),
        backgroundColor: Colors.blueAccent,
        image: Image.asset('assets/logo.png'),
        photoSize: 200,
        styleTextUnderTheLoader: TextStyle(),
        loadingText: Text(''),
        loadingTextPadding: EdgeInsets.only(top: 20),
        useLoader: true,
      ),
    );
  }
}
