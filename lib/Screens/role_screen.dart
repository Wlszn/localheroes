import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import '../Models/user_model.dart';

class Rolescreen extends StatelessWidget {
  const Rolescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        title: Text(
          'Join Local Helpers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(child: Text('How would you like to use the platform?')),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row(
                      children: [Icon(Icons.person, color: Colors.blue[300])],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'I Need Help',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            wordSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Post tasks and find qualified local helpers to assist you with various jobs.',
                      softWrap: true,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Post tasks and describe what you need \n'
                      'Browse verified heroes near you \n'
                      'Track progress and make secure payments',
                      style: TextStyle(height: 2),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LoginScreen(selectedRole: Role.seeker),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_right_alt_outlined,
                            color: Colors.blue[300],
                          ),
                          iconAlignment: IconAlignment.end,
                          label: Text(
                            'Continue as Seeker',
                            style: TextStyle(color: Colors.blue[300]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row(children: [Icon(Icons.work, color: Colors.pink[300])]),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'I Can Help',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            wordSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Earn money by offering your skills and helping people in your community.',
                      softWrap: true,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Find jobs that match your skills \n'
                      'Set your own schedule and rates \n'
                      'Build your reputation and earn more',
                      style: TextStyle(height: 2),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LoginScreen(selectedRole: Role.hero),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_right_alt,
                            color: Colors.pink[300],
                          ),
                          iconAlignment: IconAlignment.end,
                          label: Text(
                            'Continue as Hero',
                            style: TextStyle(color: Colors.pink[300]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
