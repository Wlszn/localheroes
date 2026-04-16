import 'package:flutter/material.dart';
import 'package:localheroes/Screens/profile_screen.dart';
//import 'package:localheroes/DBConnection/dbconnection.dart';
import 'package:localheroes/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//TODO: Easier version of the database, just run firebase login in terminal then login with your google account. After that it will ask you which database, pick the one for the project and that's it.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await DBConnection.connection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Profilescreen(),
    );
  }
}

