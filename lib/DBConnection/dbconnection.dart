import 'package:firebase_core/firebase_core.dart';


class DBConnection {

  static Future<void> connection() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyD0-Bah8o8UjgG0g0UOVXts3Gg8fxXDHdY",
          appId: "368090559485",
          messagingSenderId: "1:368090559485:android:2e8b4899a38fb92a76df94",
          projectId: "applicationdev2-63076"),
    );
  }
}