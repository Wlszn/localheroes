import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'main_screen.dart';
import 'role_screen.dart';
import 'register_screen.dart';
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
        navigateAfterSeconds: Registerscreen(),
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
