import 'package:flutter/material.dart';
import '../Registration/role_screen.dart';
import 'secure_screen.dart';
import '../../Widgets/initial_screen_indicator.dart';

class FindScreen extends StatelessWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/search.png', height: 120, width: 120),
                  SizedBox(height: 20),
                  Text(
                    'Find Local Heroes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Connect with verified helpers in your community ready to assist with any task, big or small.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IndicatorDot(active: true),
                IndicatorDot(active: false),
                IndicatorDot(active: false),
              ],
            ),

            SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Rolescreen()),
                      );
                    },
                    // icon: Icon(Icons.skip_next),
                    label: Text("Skip"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 20),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SecureScreen()),
                      );
                    },
                    icon: Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
                    label: Text("Next"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
